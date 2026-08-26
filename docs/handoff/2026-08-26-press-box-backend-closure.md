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

## Important remaining blocker

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
