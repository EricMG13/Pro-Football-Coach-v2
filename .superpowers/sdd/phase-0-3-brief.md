# Phase 0.3 — backend-only loop deltas

Implement only these two vetted backend changes. Do not build or alter views.

1. `PracticePlanReadModel` exposes `weeklyMinutes`, populated by `CoachWorldReadModelProvider.practicePlan(from:)` from `TacticalPracticePlan.weeklyMinutes`. A provider test proves the exposed budget equals the authority and every option sums to it.
2. `CoachWorldStore.acceptCareerOpportunity(_:)` persists a reachable Career Hub presentation route after successfully consuming a real promotion offer. A real app-store save/reload journey proves the pending offer, accepted appointment/history, removal of the promotion decision, and restored Career Hub route.

Constraints:

- Reuse existing models and state; add no dependency or abstraction.
- Do not port any loop-branch view or root-view changes.
- Preserve unrelated dirty worktree changes.
- Test-first: observe each missing behaviour fail, then make the minimum production change.
