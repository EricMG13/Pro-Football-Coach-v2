# Codex handoff — Press Box deployment, Phase 0

**2026-08-24.** Start of the Press Box frontend rebuild.
Plan: `docs/plans/2026-08-24-press-box-deployment.md`. **Read it before starting.**

**This handoff covers Phase 0 only.** `CLAUDE.md` requires one phase at a time. Phase 0 is a port and
a doc reconciliation; it changes no behaviour and draws no surface. Stop when its gate is green and
hand back.

---

## Read these first, in this order

1. `CLAUDE.md` — standing rules. **`AGENTS.md` does not point at it and it is not optional.**
2. `docs/plans/2026-08-24-press-box-deployment.md` — the plan this executes.
3. `docs/DOC-MANIFEST.md` — what is canon. A document not listed there carries no authority.

---

## The one constraint that will bite

**Press Box lives in a Claude Design project you cannot open.** It is the design standard, and the
decided change flow is **Press Box → `04` → Swift**: no change lands in code before it is in the
standard and in canon.

You cannot write to the standard. So:

- **Never amend the standard, and never work around it.** If you find something that would need the
  standard changed, **stop and escalate to the owner**. Do not decide it, do not draw around it, and
  do not leave it implicit in a commit message.
- Everything you need for Phase 0 is in the repository after step 2 below. `docs/FRONTEND-CHANGE-LEDGER.md`
  is written to be self-sufficient on purpose: *"If an entry says 'see the standard' and nothing
  else, that entry is incomplete and should be treated as a defect in this document."*

---

## Prerequisite — satisfied 2026-08-24, nothing to do

Two v1 branches carry `docs/reviews/2026-08-22-all-screen-presentation-contract.md`. That file states
what each screen's read model holds and what it must omit; it outranks the design standard on facts,
and the whole build depends on it. **Both are on v1's `origin` and fetchable.**

The two versions differ: `codex/mock-reconciliation-vertical-slice` carries per-screen omission
lists, `codex/integrate-mock-reconciliation` collapses them to boilerplate. **Use the vertical-slice
version.**

*An earlier draft of this handoff blocked here, on a claim that both branches were local-only and
never pushed. That was wrong — the check behind it tested whether a remote contained each branch's*
***tip***, *which was 8 commits ahead, and read the negative as "not on origin at all". The contract
itself was already on `origin`, byte-identical. The 8 commits have since been pushed.*

---

## Phase 0 tasks

Work on a fresh branch off `main`. One task, one commit, Conventional Commits.

### 0.1 · Add v1 as a remote and fetch

v2 is a squash of v1's `claude/match-day-animation-movement-019bcd` at `9a4b7813`, so there is **no
shared history** — cherry-pick applies diffs, which works, but nothing will fast-forward.

```bash
git remote add v1 https://github.com/EricMG13/Pro-Football-Coach.git
git fetch v1 main
```

### 0.2 · Cherry-pick 19 commits, in this order

Merge commits are excluded deliberately. Pick them **one at a time** and resolve as you go; do not
batch them.

```
aec30b9c  docs(briefs): the Claude Design brief, and surface coverage against the registry
d3e0571d  docs(briefs): correct the coverage denominator, and record why the sheets are not the source
34857de9  docs: open the frontend change ledger against the Press Box standard
6e1059a0  docs(ledger): withdraw the confidence-model ask, and record two corrections it forced
ef10e720  feat(design): draw the Personnel family, and record it in the ledger
a03ff4b6  fix(design): retire ConfidenceRange from use, and correct signing day
6a5d0fd8  docs(ledger): read the all-screen reconciliation plan, and let it correct the standard once
c89bca2e  feat(design): draw the entry surfaces without a band, and correct what "bandless" means
9af824f4  feat(design): draw the Recruiting family, and generalise the gold rule
cd88a283  feat(design): draw the Pro management family, and record the unavailable-action rule
ab4673dc  feat(design): draw the Career family, including the first two non-table shapes
2156129d  feat(design): close the registry at 47 of 47 with League and Entry
691f6a6a  fix(design): name the demos that exist, and drop a partial that is no longer one
87430a0e  docs(canon): amend 04 and 04b to the standard, and close D6 by disproving half of it
317cd746  docs(canon): name the two navigation moves, and reverse the one amendment that was wrong
859af492  docs(canon): point the new cross-references at the section that holds the stage
3bd44a58  feat(ui): remove the icon rail, and ship the five-band heat scale
e71bf1f4  docs(ledger): write out every value the frontend build needs, so the repo is self-sufficient
55d8d43d  feat(ui): ship the surfacing, hairline, banner and ink tokens, and record what is left
```

**Seventeen of these are docs-only.** The `feat(design)` commits touch no Swift — the drawing happened
in the design tool and the repo commit is the ledger row. Only `3bd44a58` (9 code files) and
`55d8d43d` (1) change code.

#### The conflict rule

Measured on a dry run. `3bd44a58` auto-merges `ScreenRegistry.swift`, `FloodlitChrome.swift`,
`ScreenReadModels.swift` and `ContractTests.swift`, and conflicts in three files, ~184 lines:

| File | Hunks | Resolve |
|---|---:|---|
| `Sources/ProFootballCoachUI/DesignTokens.swift` | 2 (81 lines) | `Heat` hunk → **keep HEAD**. `Stage` hunk → **take theirs**. |
| `Tests/SimTests/Suites/DesignContractTests.swift` | 1 (94 lines) | Same rule. |
| `docs/04-UX-AND-DESIGN-SYSTEM.md` | 2 (9 lines) | Trivial. |

**The rule generalises: a conflict about A2 (the five-band heat scale) or A3 (`stateWarning: 0xC9704A`)
resolves to HEAD, because v2 already has both. A conflict about A1 (the rail and the stage) or A4
(`Surfacing`) resolves to theirs.**

Expect conflicts on `docs/STATUS.md`, `CLAUDE.md`, `docs/DOC-MANIFEST.md`,
`docs/PRE-DEPLOYMENT-CHECKLIST.md` and `docs/HANDOFF-CLAUDE.md`. **v2 is ahead on all of these** —
keep HEAD and merge v1's additions in by hand.

#### What must survive untouched

v2 has 16 commits v1 does not, all match-engine work. **Do not let any cherry-pick revert them:**

`Sources/FootballSimCore/Engine/SnapAnchors.swift`, `SnapResolver.swift`, `Assignment.swift`,
`Sources/FootballSimCore/Rules/MatchupRules.swift`,
`Sources/ProFootballCoachUI/MatchDayView.swift`,
`Sources/CoachWorldApp/CoachWorldMatchProvider.swift`,
`Tests/SimTests/Suites/SnapAnchorTests.swift`, `EngineTests.swift`,
`docs/03-MATCH-ENGINE.md`, `docs/plans/2026-08-22-match-day-template-motion.md`.

`git diff main -- Sources/FootballSimCore/Engine/` at the end must show only intended change.

### 0.3 · Bring the presentation contract across

```bash
git fetch v1 codex/mock-reconciliation-vertical-slice
git checkout v1/codex/mock-reconciliation-vertical-slice -- docs/reviews/2026-08-22-all-screen-presentation-contract.md
```

Take **only that file** from that branch. Nothing else on it is in scope.

### 0.4 · Amend the standing rules

Three edits, all decided by the owner on 2026-08-24. Doc-first, per `CLAUDE.md`.

1. **`CLAUDE.md`** — the `*-v3.dc.html` row currently reads *"The definitive design references
   (owner-approved 2026-08-12)"*. It is superseded by the 2026-08-23 grant. Replace with
   `AUTHORITY.md`'s own words: **"a visual shell and hierarchy prompt, never a source of facts"**.
2. **`docs/DOC-MANIFEST.md`** — add two `RETAINED` entries: **Press Box** (Claude Design project
   `3e8bedda-4c56-4be1-8f3a-98f9c2e82d9d`, with its `AUTHORITY.md` as the boundary of what it
   overrides) and **`docs/reviews/2026-08-22-all-screen-presentation-contract.md`**. Note that `04`
   remains the canon a builder implements against, because the repository cannot open a design tool.
3. **`CLAUDE.md` process section** — add the change flow: **Press Box → `04` → Swift**, and the rule
   that an agent which cannot write the standard escalates rather than decides.

### 0.5 · Mark the stale brief

`docs/briefs/2026-08-23-surface-coverage.md` records Press Box at **12 of 62**. The current figure is
**47 of 47 canonical destinations** (62 identities, 15 aliases). Add a superseding line at the top
pointing at the plan. Do not rewrite the body — its branch survey is still the record of where the
work was.

---

## Gate — all of it, before handing back

```bash
./scripts/verify.sh
```

| | Must be true |
|---|---|
| Build | `swift build` green across all targets. **A Swift toolchain is present** (Swift 6.3.3, `xcodebuild`) — no part of this may be reported as "unverified, never compiled". |
| Tests | Full `SimTests` green. The ledger records that the full lane was **never run** after the banner grounds were added to canon — so this is the first honest run of it, and a failure here is a finding, not a regression you caused. Report it either way. |
| Colour scan | Passes. It reads `04` as a whitelist, so an unstated hex fails to compile. That is the scan working. |
| Behaviour | **No behaviour change.** Phase 0 ports and reconciles. If a surface renders differently, something was resolved wrong. |
| Engine | `git diff main -- Sources/FootballSimCore/` shows no unintended revert of v2's match-engine work. |
| Review | `adversarial-reviewer` (or `/code-review`) on the phase diff. Fix confirmed findings before declaring done. |

**An adversarial review is not a build and must never be reported as one.**

---

## Escalate, do not decide

Stop and hand back if any of these appear:

- Anything that would need the **design standard** amended. You cannot write it.
- `04` §9 line 1291 cites **§9.4**, which does not exist — introduced by `1f236d4e`. **Do not guess
  what it meant.** The ledger declines it for the same reason: a confident wrong pointer is worse
  than an obviously broken one. Owner or original author answers this.
- Any conflict where the A1/A2/A3/A4 rule above does not decide it.
- The full `SimTests` lane failing in a way that predates this branch.

---

## What comes after, so you know the shape

Phase 1 is the shared layer: A5 (the four accessibility branches), **A6** — `FamilySwitcher`,
`BackControl` and `HostPanel`, which is the only remaining blocker on any surface work — A6b, A7's
gold audit, D4's `contextShort`, and the two adopted game-test repairs. **Until `HostPanel` exists,
15 of the 62 registry identities are reachable by saved route and by nothing on screen.**

Do not start it in this session.
