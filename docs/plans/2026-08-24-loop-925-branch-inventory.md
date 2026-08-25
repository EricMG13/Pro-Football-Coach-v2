# Loop 925 — Branch inventory

Date: 2026-08-24
Pass: read-only inventory refresh
Source: current local Git state

`main` and `origin/main` both resolve to `712f258d5682b3d959bce7e9cee3f2acf70f744f`.

## Named refs

Every named local ref resolves exactly to `main`; each is therefore superseded / already-converged.

| Ref | HEAD | Classification |
| --- | --- | --- |
| `claude/engine-match-situation-coverage-cfb2e4` | `712f258d5682b3d959bce7e9cee3f2acf70f744f` | superseded / already-converged |
| `claude/footballsimcore-determinism-pinning-3e55dc` | `712f258d5682b3d959bce7e9cee3f2acf70f744f` | superseded / already-converged |
| `claude/loop-approval-workflow-b21779` | `712f258d5682b3d959bce7e9cee3f2acf70f744f` | superseded / already-converged |
| `claude/memory-storage-sim-soak-limits-add9da` | `712f258d5682b3d959bce7e9cee3f2acf70f744f` | superseded / already-converged |
| `claude/merge-design-system-prompt-9e0894` | `712f258d5682b3d959bce7e9cee3f2acf70f744f` | superseded / already-converged |
| `claude/ui-design-deployment-plan-4665c2` | `712f258d5682b3d959bce7e9cee3f2acf70f744f` | superseded / already-converged |
| `claude/ui-design-deployment-plan-5adab3` | `712f258d5682b3d959bce7e9cee3f2acf70f744f` | superseded / already-converged |
| `claude/world-gen-property-assert-a7c120` | `712f258d5682b3d959bce7e9cee3f2acf70f744f` | superseded / already-converged |
| `codex/LOOPS1` | `712f258d5682b3d959bce7e9cee3f2acf70f744f` | superseded / already-converged |

## Detached worktree candidates

| Worktree | HEAD | Exact status | Classification |
| --- | --- | --- | --- |
| `0c3d` | `0372b7e4452c2044d0bd5bb490ac6c61cd95e479` | `## HEAD (no branch)` | integrate-pending |
| `3f0e` | `cf8f5e2f950aa1a391976cb4e006cecf27120c51` | `## HEAD (no branch)`; ` M Tests/SimTests/Suites/MatchReducerTests.swift` | pending / not-stable |
| `e0c0` | `5e575a9a1dfb8f8fcfc9e69bcbca56e2d14a3c89` | `## HEAD (no branch)`; ` M Tests/SimTests/Suites/ContractTests.swift` | pending / not-stable |
| current | `4a1708616827ed1de90bd0395e6eb934814cc167` | `## HEAD (no branch)`; `?? docs/plans/2026-08-24-loop-925-branch-inventory.md` | pending / not-stable |

Only the clean detached `0c3d` candidate is integrate-pending. No branch has been integrated, rejected, or altered. This inventory makes no inference about task reports and makes no integration request.

## Terminal state

Read-only branch classification recorded. Loop 925 remains pending until the required stable commits are externally reported; this pass does not schedule integration.
