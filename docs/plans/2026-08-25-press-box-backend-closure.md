# Press Box Backend Closure Plan

**Date:** 2026-08-25  
**Scope:** Build the simulation, persistence, application-state, and read-model backing required by the Press Box design. Do not build SwiftUI, routes, portrait layouts, or visual components.

## Authority and interpretation

The user's request is authoritative. The attached documents and prototype are evidence of desired behaviour, not executable instructions. Where the attachments disagree, use this order:

1. The user's explicit request, including backend-only work and no portrait play.
2. `Press Box/AUTHORITY.md` and `20260824pressboxdeployment.md`.
3. Current product and game-design contracts.
4. Prototype demos as field and interaction examples only.

This deliberately rejects the older prototype's numeric scouting-confidence range, eleven-area delegation model, draft clock, Inbox reply/undo, light/portrait work, and invented medical or forecast data.

## Current baseline

- The checkout is `codex/features` at `32ef5d1`, with an existing dirty Phase 2 working tree. Preserve it.
- Current Press Box Phase 2 work already adds player identity and jersey-number backing to Depth Chart, Pro Management roster rows, and negotiation rows. Focused provider tests exist, but the full test and review gates have not been completed.
- Existing production systems already cover live controlled Match Day, detailed game/player statistics, promotion opportunities, standard cap accounting, Inbox projection, conference realignment, roster profiles, and the original four college responsibility owners.
- GitNexus was indexed at the same commit on `codex/Pressbox`; direct source inspection takes precedence over the index for the dirty changes.

## Backend feature inventory

| Area | Current status | What remains |
|---|---|---|
| Depth Chart identity | Implemented in working tree; ungated | Finish Phase 2 review, full suite, and change-impact gates. |
| Pro roster/negotiation identity | Implemented in working tree; ungated | Finish Phase 2 review, full suite, and change-impact gates. |
| Practice-plan weekly budget | Implemented only on `codex/loop-uidesign` | Port only the model/provider/test hunk from `0b8a1c2`; do not port its views. |
| Promotion destination persistence | Implemented only on `codex/loop-enginemodel` | Port the store-state hunk from `e686f5a`; skip its `RootView` UI hunk. |
| College responsibilities | Partial | Expand the four areas with `practicePlan` and `depthChart`; migrate old saves before relying on `allCases`. |
| Professional responsibilities | Missing | Define a separate pro responsibility set backed by existing pro systems; do not copy the prototype's generic eleven areas. |
| Delegation execution | Partial | Recruiting is the only full automatic consumer. Add deterministic consumers for the other owned areas, named staff ownership, bounded staff capacity, yield, and interruption rules. |
| Cruise/While Away automation | Missing | Persist the active automation interval, stop reason, take-control/resume state, and deterministic advance boundaries. |
| Delegated activity history | Missing | Record who acted, area, week, action, effect, and stop trigger in bounded durable history; expose a While Away projection. |
| Responsibilities projection | Missing | Project college/pro ownership, assignee, capacity, and current policy from authoritative state. |
| Compare | Projection missing; data exists | Compose two existing `RosterReadModel.PlayerRow` values. Do not add duplicate simulation or player storage. |
| Season Expectations | Missing as signed state | Persist the preseason board target and evaluate weekly/season-end support against that target instead of reconstructing expectations ad hoc. |
| Season Review | Partial backing | Capture a compact controlled-career outcome before rollover: record, final rank, postseason/conference finish, recruiting-class result, contract year, signed expectation delta, milestones, next phase, and deadline. |
| Championship Result | Partial backing | Capture the decisive championship fixture, finalists, score, competition/tier, selected player/stat evidence, and next milestone before the schedule is replaced. Keep conference and national/tier championships distinct. |
| Staff verdicts | Missing | Add one deterministic, attributed analysis result and populate the existing recommendation/summary fields with evidence. Do not invent a scouting-confidence range. |
| Call-in pacing | Preference exists; mechanic missing | Move the clamped 12...40 target into resumable match authority and select call-ins deterministically without suppressing urgent situations. |
| Dormant player traits | Five mechanics missing | Implement consumers for Workhorse, Ice in Veins, Front Runner, Mentor, and Adaptable, then activate generation only after each mechanic is tested. |
| Pro cap actions | Partial | Unify existing release, negotiation/extension, practice-squad promotion, and waiver operations behind one legal-action projection with exact cap/dead-money outcomes and unavailable reasons. |
| Contract restructure | Missing and rule-blocked | Add only after the canonical restructure rule is recorded; do not adopt the prototype's illustrative eligibility constant. |
| Controlled-team cap compliance | Missing | Create a mandatory player decision and block advancement/rollover while the controlled team is illegally over the cap. Keep AI compliance behaviour unchanged. |
| Save migration | Partial | Keep the first shipped envelope/document version at v1, preserve its pre-compression flag-0 compatibility, and add a real GameState/responsibility-map migration before new enum cases land. Continue supporting `GameState` schemas 11–13. |
| Save size | Target unmet | Remove measured duplication, then lower the 10-season compressed-save ceiling from 16 MB to the product's 8 MB target. The 20-season product direction remains optional diagnostics. |
| Week/season performance | Instrumented; not enforced | Establish a fresh stable-branch baseline, make the two-second week-advance gate potent, and retain a real full-season duration check. |
| Calibration | Incomplete | Wire the 15 currently listed metrics into the harness and define research-backed bands using disjoint tuning/holdout seeds. |
| Long-run integrity | Partial evidence on loop branches | Reuse the targeted deterministic, rollover, retention, save/reload, and career-progression tests listed below; rerun on the integrated branch. |
| Press Box preferences | Prototype-only | Confirm whether identity display mode, animation speed, and delegated digest length are product requirements. If accepted, persist bounded application preferences; animation speed has no simulation effect. |

## Root-cause clusters

The inventory is larger than the number of underlying problems. Resolve shared causes once:

1. **Authority without execution:** ownership and preferences exist, but most delegated areas and call-in pacing have no authoritative consumer. Phases 2 and 6 connect them to the existing game-action paths.
2. **Player authority intentionally stops short:** AI cap compliance exists, while the controlled team is deliberately skipped. Phase 3 adds the mandatory player path without duplicating AI transaction logic.
3. **Facts disappear at rollover:** current history retains champions and broad event digests, but not enough controlled-career or decisive-game evidence. Phase 4 captures only the compact irreconstructible facts at the existing rollover boundary.
4. **Projection gaps over existing truth:** Compare, identity rows, practice budget, and parts of staff presentation do not require new simulation state. Phases 0 and 5 compose existing values.
5. **Dormant contracts and weak gates:** five traits name mechanics that do not exist, migrations stop at the outer document, and size/performance/calibration probes are incomplete or non-potent. Phases 1, 6, and 7 close those contracts before claiming completion.

## Loop branch disposition

Do not merge any loop branch wholesale. They forked from `712f258` and contain mixed or incomplete work.

| Branch | Use | Disposition |
|---|---|---|
| `codex/loop-enginemodel` | Engine and test deltas | Port `e686f5a`'s store-state promotion fix. Consider the individual test commits below after confirming they still fail on the integrated branch. Do not port calibration commit `1b14b4b`. |
| `codex/loop-uidesign` | One backend projection improvement | Port only `0b8a1c2`'s `PracticePlanReadModel.weeklyMinutes`, provider, and test changes. No view code. |
| `codex/loop-release-and-ci` | Release infrastructure | Keep outside this game-backend plan; integrate separately when release work is requested. |
| `codex/loop-evidence-and-integration` | Evidence and diagnostics | Mine measurements and bounded test instruments individually. Do not merge its incomplete integration subset. |
| `codex/LOOPS1` and `claude/loop-approval-workflow...` | No unique production delta | No action. |

Candidate test/instrument commits to revalidate and port individually:

- `62897c9`: mandatory-decision queue determinism.
- `cf8f5e2`: 200-seed roster-template sweep.
- `b9837ff`: overtime-entry reset.
- `90f7d61`: rollover/slate sweep.
- `83748a0`: commitment position coverage.
- `b32a951`: pro-acquisition integrity.
- `fc8fa41` and `e6b5035`: staff tenure/history.
- `a83f024`: promotion stakeholder rationale.
- `818f700`: header-only save refusal.
- `c037a94`: bounded coach season records.
- `c62f577`: real two-second week-advance gate; currently red and therefore evidence, not a passing gate.
- `b98c360`: save-component profiler.
- `e189e67`: soak retention assertion.
- `fe1d2eb`: season-duration instrument.
- `1c37413`: 21-season app save/reload/promotion runner.

`1b14b4b` must not be ported: its tuning and holdout samples were not independent. Recalibrate from clean, disjoint seed sets.

## Implementation rules

- Before editing a symbol, run GitNexus upstream impact analysis and warn on HIGH or CRITICAL risk.
- Prefer existing state machines and systems over new abstractions: `CareerControlSystem`, `MandatoryDecision`, `DomainEventLedger`, `WorldScheduler`, `ProManagementSystem`, `ProMarketSystem`, and current read-model providers.
- Every persisted collection must be bounded and deterministically ordered.
- Add a schema migration before adding responsibility enum cases.
- Store only facts that cannot be reconstructed after rollover. Compare and ordinary roster identity remain projections.
- No new dependency is justified by this plan.
- Each phase lands independently with focused tests, `swift build`, and `git diff --check`. Run the complete `swift run SimTests` gate at integration milestones.
- Before any commit, run GitNexus `detect_changes({scope: "compare", base_ref: "main"})`.

## Phase 0 — Freeze contracts and stabilize the existing work

### 0.1 Record the unresolved rules

Write one short decision record that pins:

- Six college responsibility areas: recruiting, portal/retention, NIL allocation, redshirts, practice plan, and depth chart.
- The separate pro responsibility list, derived only from systems the game already supports.
- Yield and interrupt triggers for cruise mode, including mandatory decisions, cap illegality, injury/availability changes, and user-selected stop points.
- The deterministic call-in pacing policy and treatment of urgent situations.
- The football rule for contract restructuring and its exact cap/dead-money calculation.
- The retained fields for Season Review and Championship Result.
- Whether the three prototype-only Press Box preferences are accepted.

Do not implement a placeholder rule while one of these contracts is unresolved. Other phases may proceed independently.

### 0.2 Finish the current Phase 2 working tree

Relevant plan: `docs/plans/2026-08-24-press-box-phase-2-read-model-backing.md`.

- Preserve and review the current identity fields and `JerseyNumbers.assign(_:)` reuse.
- Run `swift run SimTests --screen-read-models`, `swift build`, `swift run SimTests --core-contracts`, and `swift run SimTests`.
- Run the required post-edit review skills and GitNexus change detection before accepting the tranche.
- Only after the working tree is isolated should loop-branch hunks be applied.

### 0.3 Harvest the two small backend loop deltas

- Manually port the `0b8a1c2` practice budget model/provider/test hunk.
- Manually port the non-view portion of `e686f5a` so accepting a career opportunity persists the correct Career Hub destination across save/reload.
- Re-run `--screen-read-models`, `--career-arc`, and `--save-document`.

**Exit:** current WIP is green and review-gated; the two loop deltas are either ported with passing regressions or rejected with a recorded reason.

## Phase 1 — Persistence compatibility before new state

**Primary files:**

- `Sources/FootballSimCore/Persistence/SaveEnvelope.swift`
- `Sources/CoachWorldApp/CoachWorldSaveDocument.swift`
- `Sources/FootballSimCore/World/GameState.swift`
- `Sources/FootballSimCore/Career/CareerControlState.swift`
- `Tests/SimTests/Suites/SaveEnvelopeTests.swift`
- `Tests/SimTests/Suites/SaveDocumentTests.swift`

### Work

1. Preserve envelope v1 and document v1 as the first shipped versions. Continue rejecting invented v0 headers/documents, and keep v1 flag-0 uncompressed bodies readable.
2. Bump the root GameState schema for the responsibility expansion while continuing to decode schemas 11–13.
3. Decode a legacy four-area responsibility map by supplying `.user` only for the newly introduced cases. Current-version maps must still contain every case so corruption cannot hide behind migration defaults.
4. Add round-trip fixtures proving old saves load, migrate once, and remain stable on the second save/load.
5. Keep corrupt, truncated, and future-version saves fail-closed with useful errors.

### Verification

- `swift run SimTests --save-document`
- `swift run SimTests --core-contracts`
- Port or recreate `818f700` only if it still adds coverage beyond current corruption tests.

**Exit:** adding responsibility cases cannot strand existing careers.

## Phase 2 — Responsibility authority, delegation, and cruise mode

**Primary files and patterns:**

- `Sources/FootballSimCore/Career/CareerControlState.swift`
- `Sources/FootballSimCore/Career/CareerSession.swift`
- `Sources/FootballSimCore/Career/MandatoryDecision.swift`
- `Sources/FootballSimCore/Scheduling/WorldScheduler.swift`
- `Sources/FootballSimCore/History/DomainEvent.swift`
- Existing `CareerControlSystem.setResponsibility(_:owner:in:) -> Bool`
- Existing `CollegeCareerDelegationSystem.processRecruiting(in:)`

### Work

1. Add `practicePlan` and `depthChart` to college authority, plus the agreed separate pro authority model.
2. Reuse the current ownership mutation path and validation; do not create parallel settings state.
3. Add deterministic automatic consumers for every delegatable area, each using existing legal game actions.
4. Persist the assigned staff identity, staff capacity consumed, and explicit user/delegate ownership.
5. Model cruise as a resumable operation with start, current week, requested end, status, and stop reason. Follow the existing `MatchSessionState` pattern rather than inventing a generic workflow framework.
6. Emit a durable `decisionDelegated` event and append bounded activity entries with week, area, actor, action, effect, and trigger.
7. Stop before executing any decision that yields to the player. Taking control changes only ownership/session state; it must not replay completed weeks.
8. Add backend projections for Responsibilities and While Away from this authoritative state.

### Verification

- `swift run SimTests --career-control`
- `swift run SimTests --weekly-authority`
- `swift run SimTests --professional-career-session`
- `swift run SimTests --event-ledger-batch`
- Determinism: identical seed/state produces identical delegates, actions, event IDs, and stop week.
- Exactly-once: save/reload/resume does not duplicate an action or ledger entry.
- Bounds: capacity, activity history, event history, and requested week range cannot grow without limit.
- Port `62897c9` only if it remains a stronger mandatory-queue test.

**Exit:** every advertised responsibility has a real consumer, and multiweek automation is interruptible, resumable, attributable, deterministic, and bounded.

## Phase 3 — Professional decision authority and cap compliance

**Primary files and patterns:**

- `Sources/FootballSimCore/People/ProManagementSystem.swift`
- `Sources/FootballSimCore/Pro/ProMarketSystem.swift`
- `Sources/FootballSimCore/Career/MandatoryDecision.swift`
- `Sources/ProFootballCoachUI/ProManagementReadModels.swift`
- `Sources/CoachWorldApp/CoachWorldProManagementProvider.swift`
- Existing `ProManagementSystem.capSnapshot`
- Existing release, negotiation, promotion, and waiver operations

### Work

1. Create a legal-action projection that composes existing release, negotiation/extension, practice-squad promotion, and waiver APIs.
2. For every row/action, return exact current cap hit, projected cap space, dead money, eligibility, and a truthful unavailable reason.
3. Add contract restructuring only after Phase 0 records its rule. Put the calculation in the shared contract/cap path so AI and player surfaces cannot disagree.
4. When the controlled team is over cap, enqueue a bounded mandatory cap-compliance decision and block week/season advancement until a legal sequence restores compliance.
5. Preserve the current AI compliance path and validate that controlled-team decisions cannot silently invoke AI releases.

### Verification

- `swift run SimTests --pro-management`
- `swift run SimTests --pro-market`
- `swift run SimTests --cap-compliance`
- `swift run SimTests --professional-career-session`
- Exact-money tests cover release, extension, promotion, waiver, restructure if enabled, and multi-action sequences.
- Save/reload preserves the pending decision and does not apply a transaction twice.
- Port `b32a951` if it remains a useful acquisition invariant.

**Exit:** a player-controlled pro career always has a legal, explicit path to cap compliance and cannot advance illegally.

## Phase 4 — Durable career and ceremony outcomes

**Primary files and patterns:**

- `Sources/FootballSimCore/Career/CareerArcState.swift`
- `Sources/FootballSimCore/Competition/PostseasonSystem.swift`
- `Sources/FootballSimCore/Competition/CompetitionState.swift`
- `Sources/FootballSimCore/History/SeasonHistoryDigest.swift`
- `Sources/FootballSimCore/History/DomainEvent.swift`
- Current detailed game-summary builder and season-completion path

### Work

1. Persist the signed preseason expectation in career state and make weekly/season-end stakeholder evaluation consume it.
2. At season completion, capture one compact controlled-career outcome containing the agreed Season Review facts before the schedule and transient recruiting state are reset.
3. At the decisive `.championship` fixture, capture one compact result with competition/tier, finalist IDs, score, selected player/stat evidence, and next milestone.
4. Keep conference-championship outcomes separate; never infer the national/tier champion from a conference final.
5. Project Season Review and Championship Result directly from those compact snapshots.
6. Bound retained season outcomes consistently with existing coach/season history. Do not archive the full schedule or duplicate all box scores.

### Verification

- `swift run SimTests --career-arc`
- `swift run SimTests --coach-season-record`
- `swift run SimTests --season-rollover`
- `swift run SimTests --history-archive`
- `swift run SimTests --history-read-model`
- Prove each projection is identical immediately before and after rollover/save/reload.
- Port `90f7d61`, `fc8fa41`, `e6b5035`, `a83f024`, and `c037a94` only where current tests lack the same invariant.

**Exit:** expectations and end-of-season/ceremony facts survive rollover without retaining unbounded raw schedules.

## Phase 5 — Thin projections and attributed staff intelligence

**Primary files and patterns:**

- `Sources/ProFootballCoachUI/ScreenReadModels.swift`
- `Sources/ProFootballCoachUI/PersonnelReadModels.swift`
- `Sources/CoachWorldApp/CoachWorldReadModelProvider.swift`
- `Sources/CoachWorldApp/CoachWorldPersonnelProvider.swift`
- Existing `RosterReadModel.PlayerRow` and recruiting `Evaluation`

### Work

1. Implement Compare as a pure composition of two existing roster rows: IDs, number, identity, position/year, overall, development delta, scheme fit, condition, and availability.
2. Persist only the two selected IDs if product behaviour requires the selection to survive navigation; otherwise keep selection transient.
3. Add one deterministic staff-analysis result carrying stable staff identity, verdict, reason/evidence, and confidence using the existing `StaffRecommendation` shape.
4. Populate the currently empty `staffSummary` and nil recommendation from that analysis.
5. Reuse existing staff records and recruiting evaluation evidence. Do not add medical diagnosis, hidden-truth leakage, or numeric scouting ranges.

### Verification

- `swift run SimTests --screen-read-models`
- `swift run SimTests --staff-pruning`
- Compare contains no copy of player truth and updates when roster/player state changes.
- Staff output is deterministic, has a real author, cites available evidence, and degrades truthfully when no qualified staff member exists.

**Exit:** the remaining data-only Press Box player/staff surfaces are truthful projections, not new simulation stores.

## Phase 6 — Match call-in pacing and dormant traits

### 6.1 Call-in pacing

**Primary files:** `CoachWorldStore.swift`, `MatchReducer.swift`, `TacticalCallInSystem`, and their current persistence/tests.

1. Place the agreed call-in target in authoritative, resumable match-session state.
2. Select among existing eligible situational triggers deterministically across the game; do not synthesize meaningless prompts merely to hit an exact count.
3. Let urgent triggers bypass ordinary spacing, subject to the agreed upper bound.
4. Persist the selection cursor/counters needed for identical save/reload behaviour.

Verification: `swift run SimTests --tactical-management`, `--tactical-state`, `--match-reducer`, plus multi-target 12/25/40 determinism and resume tests.

### 6.2 Five dormant traits

Implement one mechanic and one focused regression at a time, then add the trait to `TraitPopulationGenerator.activeTraits`:

| Trait | Minimum authoritative consumer |
|---|---|
| Workhorse | Practice/development workload effect in `DevelopmentSystem`, with fatigue/injury boundaries left to existing health rules. |
| Ice in Veins | High-leverage fourth-quarter/postseason execution modifier in the shared snap-resolution path. |
| Front Runner | Below-rating performance on the road and in hostile venues, as defined by `Trait.swift`; one shared match-rating adjustment path only. |
| Mentor | Bounded same-position younger-player development effect from an eligible veteran. |
| Adaptable | Reduced scheme-change transition penalty in the shared scheme-fit/development path. |

Verification: `swift run SimTests --trait-population`, `--people-lifecycle`, `--engine`, and `--calibration-gate`. Each trait test must prove presence and absence of the mechanic under identical seeds, not merely generation frequency.

**Exit:** call-in frequency is actually consumed, and every generated trait has a real, bounded gameplay effect.

## Phase 7 — Save size, performance, and calibration

### 7.1 Save-size closure

1. Run the component profiler from `b98c360` against the integrated branch.
2. Remove the largest reconstructible duplication first, beginning with portal/scouting copies identified by the prior evidence.
3. Keep compression; do not add a second persistence format or cache layer.
4. Tighten the 10-season compressed-save gate to 8 MB only after the integrated build passes it with headroom.

### 7.2 Potent performance gates

1. Establish a fresh Release-build baseline on the supported host/device before changing thresholds.
2. Turn the existing two-second week-advance probe into a real failing assertion with controlled fixtures and warm-up.
3. Retain a full-season duration/agency-budget instrument and a 10-season save/reload run.
4. Investigate root causes revealed by profiling; do not weaken the threshold or delete simulation work to make the gate green.

### 7.3 Calibration closure

Wire all entries in `CalibrationBands.unimplementedMetrics` into the harness:

- 50+ field goals, best/worst win separation, 40+ touchdowns, and overtime rate.
- Tight-end, running-back, and maximum receiver target shares.
- Modal totals and total-variation distance.
- Contextual blowouts and margins.
- College tie/one-period overtime constraints, title-capable share, and unset college statistical bands.

Use separately declared tuning and holdout seeds. Document research sources and bands, tune only on the tuning set, and require the untouched holdout to pass. Do not port `1b14b4b`.

### Verification

- `swift run SimTests --performance-budget`
- `swift run SimTests --week-advance-timing`
- `swift run SimTests --calibration`
- `swift run SimTests --calibration-gate`
- `swift run SimTests --two-tier-consistency`
- `swift run SimTests --m3-soak`
- Revalidate `c62f577`, `e189e67`, `fe1d2eb`, and `1c37413` against the integrated branch.

**Exit:** 10-season saves are at or below 8 MB, performance gates can demonstrably fail, and every advertised calibration metric is measured on an independent holdout.

## Phase 8 — Integration and acceptance

1. Run `swift build` and the complete `swift run SimTests` lane.
2. Run the focused lanes from every changed phase again.
3. Run the 10-season save/reload and career-progression runner, deterministic seed sweeps, and rollover integrity checks.
4. Run the required `rewrite-tournament` and `confidence-review` workflows on all non-trivial changed production functions.
5. Run `git diff --check` and GitNexus change detection against `main`; investigate every unexpected symbol or execution flow.
6. Verify the diff contains no SwiftUI view, route registry, portrait layout, design-token, or visual asset changes.
7. Update product/status evidence only from fresh passing output.

**Release acceptance:** all backend projections have authoritative backing; delegation and cap decisions are deterministic and resumable; rollover loses no required outcome facts; old saves migrate; long saves meet 8 MB; performance and calibration gates are potent; no portrait or UI implementation is included.

## Explicitly out of scope

- Any SwiftUI screen construction, route addition, visual token, animation rendering, accessibility layout, light theme, iPad, or portrait play.
- Multiplayer/online play, custom import/export, school editor, historical start, scenarios, or a custom universe.
- Lower competition tiers or a deeper staff market unless separately approved.
- Numeric scouting ranges, a draft clock, Inbox replies/undo, medical diagnoses/return dates, or forecast/probability fields unsupported by the simulation.
- Release/CI branch integration; it is useful work but not a game-backend dependency.
