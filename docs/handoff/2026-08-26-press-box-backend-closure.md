# Press Box Backend Closure Handoff

**Branch:** `codex/list-undeveloped-game-features`
**Scope:** backend, persistence, simulation, application state, read models, and tests only. Do not build UI and do not add portrait play.

## Completed work

- Audited the supplied Press Box material against the live codebase and recorded the backend-only closure plan in `docs/plans/2026-08-25-press-box-backend-closure.md`.
- Reviewed the Codex loop branches individually. Ported only the backend-safe promotion-destination store state and the practice-plan weekly-minutes read model; no wholesale branch merge and no UI/portrait code.
- Completed the responsibility, delegation, cruise, cap-compliance, career-outcome, championship-evidence, compare/staff, call-in, trait, save-size, performance, and calibration tranches described in the closure plan.
- Fixed delegation so handing one user decision to staff resolves every queued sibling decision for that responsibility atomically.
- Added controlled-match completion to E2E-H. It advances the persisted match checkpoint through public app controls rather than silently simulating a controlled fixture.
- Diagnosed the missing post-season portal-decision path. A partial preview prototype was deliberately removed before commit because it did not reproduce every scheduler transition.
- Added focused career-control regressions for redshirt recommendations, sibling decision delegation, and a user-owned portal responsibility at the season boundary.
- Calibrated `CompetitionRules` and reduced required soak horizons after the calibration suite passed.

## Update, 2026-08-27 — the week-21 blocker is closed

`portalMarketFailed(.postseason)` is fixed. The section below is retained as the record of the
diagnosis; it is no longer the open item.

What landed:

- `CareerMandatoryDecisionSystem.portalRetentionDecisions(window:in:)` derives retention decisions
  for either window from whatever root it is handed. `refreshSpringPortal` now consumes it, so the
  spring path is unchanged. Postseason uses discriminators 13/14/15, disjoint from spring's
  10/11/12, because season S carries the spring window for S and the postseason window for S + 1.
- `WorldScheduler.resolveAndCommitPortal` derives the required decisions at the portal boundary,
  before `makeMarketSnapshot`, and throws `portalDecisionsRequired(window, decisions)`. No
  pre-portal preview: postseason intents read the career season rows and the recruiting season that
  only exist part-way through the season-boundary step.
- `CareerSession` catches it, queues the decisions against the unadvanced week, and refuses with the
  existing `unresolvedMandatoryDecisions`. Cruise stops with `.mandatoryDecision`. If the queue
  would fail `WorldIntegrity`, the scheduler's own error is rethrown rather than a queue nothing can
  drain being written.

The handoff's "first small fix" — refreshing mandatory decisions before the resolver — was not made.
`refresh` already runs at session init and after every committed intent, and it cannot derive a
postseason decision from a pre-boundary root, so it was a no-op for this blocker.

Verified: `swift build`; a new focused regression, `a user-owned postseason portal holds the season
boundary open`, shown potent by reproducing `portalMarketFailed(.postseason)` with the guard
removed; `--career-portal-decisions`, `--career-control`, `--portal-policy`, `--portal-matching`,
`--portal-contracts`, `--portal-scheduler`, `--weekly-authority` all green;
`E2E_HORIZON=1 --e2e-h-durability-child` PASS; release `--performance-budget` median 1.750 s against
the 2.000 s ceiling; the four pinned cross-process fingerprints produce values identical to HEAD's,
so world evolution did not move.

## Escalation, 2026-08-27 — WR3 and below never catch a pass, in either model

`CompetitionRules.wr3PlusTargetShare` is `0.0`, so `AbstractGameSimulator` gives every receiver
from WR3 down a weight of exactly zero and no off-screen game can target them. That is not a
one-line constant defect: `TwoTierConsistencyGateTests` measures the detailed engine's WR3+ share at
`mean=0.00, sd=0.00, min=0, max=0` as well. The zero is the abstracted model being brought into
agreement with the detailed one, which is what that gate demands.

The root cause is `Sources/FootballSimCore/Engine/Assignment.swift:130`: a pass sends four players
into a route -- `prefix(2)` wide receivers, one tight end, one back, capped at
`MatchupRules.receiversInRoute = 4`. WR3 and below are never in a pattern, so they can never be
targeted on screen, and the off-screen model is correct to match.

What it costs: every WR3+ in the league finishes a career with no reception, no receiving yard and
no receiving touchdown, and development, awards, statistics leaders, draft and recruiting evaluation
all read that hole as fact.

Raising the constant alone was tried and reverted -- it breaks the two-tier gate on both tiers
(`theta=0.0293`, band `±0.02`) and leaves the two models disagreeing, which is worse than agreeing
on something wrong. The fix is to widen the detailed engine's route distribution first, which is a
`03-MATCH-ENGINE.md` question and a calibration re-run, and only then give the abstracted constant
the share that follows. Escalated, not attempted.

## The next blocker — a controlled season-1 week-1 match cannot be finalised

Ten-season `--e2e-h-durability` now clears season 0 week 21 and the season-1 checkpoint, then stops
in season 1 week 1. `WorldScheduler.finalizeControlledMatch` refuses with
`integrityFailed([invalidPortalState])`.

Root cause: `WorldIntegrity.checkPortalState`'s `.awaitingSpring` shape requires that no game of the
portal's target season has a result. The scheduler commits the spring portal in `marketInteractions`,
ahead of `nonUserGames` and `userGame`, so an abstracted week satisfies that. A **controlled**
fixture does not: `preparedForWeekAdvance` installs the match and returns before the week advances at
all, so the result is recorded while the portal is still `.awaitingSpring`.

This is pre-existing, not a consequence of the fix above. Proved on a clean HEAD worktree: advance a
bootstrap 21 weeks, start a college career at a programme with an unplayed season-1 week-1 fixture,
play the session to completion and call `finalizeControlledMatch` — it refuses with the same issue.
E2E-H never reached it before because week 21 stopped first.

Choosing between moving the spring commit ahead of controlled preparation, splitting the week
transaction around the controlled fixture, and amending the invariant is a canon question for `02`
and `03`, not a repair to make in passing. It is escalated, not attempted.

Also open, both confirmed pre-existing against HEAD:

- `--portal-transaction`: 8 checks fail in "Portal-touched departed-player retention"
  (`expected 1024, got 4754`) — departed-player eviction is not bounding.
- `--architecture-only`: five pinned cross-process fingerprints are stale. Identical values on HEAD
  and on this work, so the pins date from an earlier tranche that changed world evolution.
- `--core-contracts`: `[ProCareerResponsibility: ...]` and `[CoachGroupKey: ...]` are not
  `CodingKeyRepresentable`, so those maps encode in hash order. (The second failure, `docs/handoff/`
  unclassified in `DOC-MANIFEST` §8, is fixed here.)

`E2EJourneyTests.finishControlledMatch` now fails on the first window in which the persisted
revision does not move, reporting the refusal that actually stopped the match. It used to burn the
whole 2,400-snap budget and report the stale-checkpoint refusals that overwrote it.

## Original remaining blocker, as recorded on 2026-08-26

E2E-H still stops at season 0, week 21 with `portalMarketFailed(.postseason)`.

The exact replay from the saved app state established:

1. `CollegePortalPolicyV1.makeSnapshot` succeeds.
2. `CollegePortalPolicyV1.makeMarketSnapshot` fails before matching.
3. The app state reaches week 21 without invoking `CareerMandatoryDecisionSystem.refresh` because `CareerSession.prepareWeek` requires an unplayed fixture, and the last week has none.
4. Consequently no user-owned postseason retention decisions exist before `WorldScheduler` checks their required resolutions.

The first small fix is in `CareerSession.resolve(.advanceWeek)`: refresh mandatory decisions before the scheduler/intent resolver is allowed to advance a week. If this creates user-owned decisions, persist that refreshed state and return the existing unresolved-decision refusal; do not run the scheduler. Keep the existing post-scheduler refresh for new-week decisions.

Then implement post-season decision derivation from the same pre-portal transition used by `WorldScheduler`, rather than an independently maintained partial preview. The rejected prototype omitted contract expiry, dead-money discharge, cap compliance, realignment/schedule regeneration, scholarship reconciliation, and the associated history application. Extract a minimal pure shared preparation helper only if it can be consumed by both paths without changing transaction order; otherwise derive the decision snapshot at the scheduler boundary before portal commitment.

## Do not repeat completed tests

These passed during this branch's work and do not need to be rerun solely for the handoff:

- `swift build`
- `swift run SimTests --career-control` — 18 tests, 144 checks (before the final unexecuted week-21 refresh fix)
- `swift run SimTests --career-portal-decisions`
- `swift run SimTests --match-reducer` — 21 tests, 102 checks
- `swift run SimTests --engine` — 69 tests, 31,978 checks
- `swift run SimTests --two-tier-consistency` — 54 tests, 84 checks
- Calibration release gate (college and pro)
- Release performance median: about 1.876 seconds, under the 2-second ceiling
- M3 ten-season soak: passed, 8.35 MB, under the 8 MiB target

Run only the unfinished verification after the remaining fix:

1. A focused deterministic regression for week-21 user-owned portal retention.
2. `E2E_HORIZON=1 swift run SimTests --e2e-h-durability-child`.
3. The default ten-season `swift run SimTests --e2e-h-durability`.
4. Required post-edit reviews, `git diff --check`, final build, and GitNexus change detection.

## Temporary diagnostic state

The failed E2E checkpoint is outside the repository at:

`/private/var/folders/81/bwblpst93lb6wb3lwrk8k6800000gn/T/pfc-e2e-week21.state`

It was used only to establish the facts above. It is not part of the commit and can be deleted once the focused regression replaces it.

## Review and commit discipline

- Preserve the user’s working tree; do not reset, stash, or touch UI files.
- Before editing a production symbol, run GitNexus upstream impact analysis and warn the user on HIGH/CRITICAL risk.
- Before a further commit, run `detect_changes({scope: "compare", base_ref: "main"})`.
- After production changes, run `rewrite-tournament` and `confidence-review` before declaring completion.
