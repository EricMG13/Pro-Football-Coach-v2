# Phase 0.3 implementation report

## Implemented

- Added `PracticePlanReadModel.weeklyMinutes` and populated it from `TacticalPracticePlan.weeklyMinutes` in the existing provider.
- Added a focused provider assertion covering the total and every option.
- Updated `CoachWorldStore.acceptCareerOpportunity(_:)` to move the persisted presentation route to Career Hub after a real offer is consumed.
- Added a child-process app-store journey covering offer, save/reload, accept, appointment/history, route removal, and post-accept save/reload.
- Added a dedicated `--e2e-journey` test command. No view was changed for this tranche.

## TDD evidence

### Practice budget

- RED: `swift run SimTests --screen-read-models` failed to compile with `PracticePlanReadModel has no member 'weeklyMinutes'` at `ReadModelProviderTests.swift:1488`.
- GREEN: the same command passed: 75 tests, 10,003 checks, all passed.

### Promotion destination

- RED: `swift run SimTests --e2e-journey` failed with `reload restored an unreachable promotion destination`, 1 failing test.
- GREEN: the same command passed: 1 test, 2 checks, all passed.

## Files changed by this tranche

- `Sources/ProFootballCoachUI/ScreenReadModels.swift`
- `Sources/CoachWorldApp/CoachWorldReadModelProvider.swift`
- `Sources/CoachWorldApp/CoachWorldStore.swift`
- `Tests/SimTests/Suites/ReadModelProviderTests.swift`
- `Tests/SimTests/Suites/E2EJourneyTests.swift`
- `Tests/SimTests/main.swift`

## Self-review

- The practice budget is a direct authoritative constant, not duplicate state.
- The route changes only when the requested offer existed and the promotion destination disappears after the mutation; a failed/stale action retains its current route.
- No UI implementation was added.
- The new runner is intentionally dedicated so promotion persistence can be retested without the multi-minute read-model suite.
