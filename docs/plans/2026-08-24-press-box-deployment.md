# Press Box deployment plan

**2026-08-24.** A phase plan, not canon. `docs/DOC-MANIFEST.md` governs what is canon; nothing here
amends a canon document. It is the sequencing for deploying **Press Box** (Claude Design project
`3e8bedda-4c56-4be1-8f3a-98f9c2e82d9d`, owner-approved 2026-08-23 as the design standard) into the
SwiftUI frontend of this repository.

**It supersedes nothing.** `docs/FRONTEND-CHANGE-LEDGER.md` — which lives in the v1 repository and
arrives here in Phase 0 — is the per-change detail. This document is the order, the corrections to
that ledger, and the work the ledger does not cover.

---

## Owner decisions taken 2026-08-24

| | Decision |
|---|---|
| **Target repository** | **v2**, after porting v1's design work. v2 keeps its match-engine lead. |
| **The game-test call** | Repairs 1 and 3 adopted into the standard. Repair 4 resolved (below). Repair 2 buildable under the scope call. |
| **Scope** | **The design system leads: build all its required surfaces, and the backend to hold them.** |
| **Change flow** | **Press Box first, then `04`, then Swift.** No change lands in code before it is in the standard and in canon. |
| **Repair 4** | The world shows **around the plate, not through it**. `--depth-glass-opacity` does not move. |
| **Phasing** | Shared layer, then engine, then one phase per family, then the new surfaces. |
| **Canon status** | The `*-v3.dc.html` sheets are demoted to composition reference. Press Box and the presentation contract are added to `DOC-MANIFEST.md`. |
| **Responsibilities** | Enumerates every delegable area by construction, not a hand-written list. |

**The scope call inverts a stated boundary, deliberately.** `AUTHORITY.md` reads *"Being the design
standard means deciding how a thing is drawn. It does not license drawing a thing that does not
exist."* The owner's call reverses the direction: the drawings become the requirement and the engine
is built to hold them. That is coherent and it is recorded here because a later reader will
otherwise find the two in conflict and treat the reversal as drift. **It does not license invented
facts on screen** — it moves the fix from "omit the field" to "build the field", and until the field
is built the omission still stands.

---

## What the ledger gets wrong, and it matters to the size of this

Three of the ledger's blockers do not survive checking against v2's source. Two of them are the two
largest items in it.

### D3 "commits do not propagate" — already satisfied

[`CoachWorldStore.swift:141`](../../Sources/CoachWorldApp/CoachWorldStore.swift)

```swift
private func adopt(_ snapshot: GameState) {
    world = snapshot
    models.removeAll(keepingCapacity: true)
    revision &+= 1
}
```

Every commit routes through one `run(_:)`, documented as *"so no caller can advance the world and
forget to refresh the screen"*. It calls `session.resolve(...)` then `adopt(...)`, which drops the
entire read-model cache. Propagation is by construction — there is no per-screen cached state that
*can* go stale. Money spent on 9b does move 9a's cap line.

The ledger's own wording gives it away: *"per the reference register: 36 committing controls run
commit → loading → success → undo inside their own screen"*. That is a finding about the HTML
mockups, filed as a simulation ask against Swift that does not have the defect. **Removed from the
plan.**

### D7 "there is no delegation state anywhere" — three-quarters wrong

[`CareerControlState.swift:3`](../../Sources/FootballSimCore/Career/CareerControlState.swift)

```swift
public enum CollegeCareerResponsibility: String, Codable, Sendable, CaseIterable, Hashable {
    case recruiting, portalAndRetention, nilAllocation, redshirts
}
public enum CareerResponsibilityOwner: Codable, Sendable, Equatable {
    case user
    case delegated(staffID: UUID)
}
public struct CollegeCareerControl: Codable, Sendable, Equatable {
    public private(set) var responsibilityOwners: [CollegeCareerResponsibility: CareerResponsibilityOwner]
```

A persisted ownership mapping from an area to a named person — the exact thing D7 says is absent.
`CareerSessionIntent.setResponsibility(responsibility:owner:)` already exists, so configuring it is
already a supported intent, and the decoder guards that every case is present. What is actually
missing is narrower and is the Phase 2 work:

| | State |
|---|---|
| Ownership mapping | **Exists**, 4 college areas. |
| Pro-tier equivalent | Does not exist. No `ProCareerResponsibility`. |
| What an area yields, and the threshold that ends a cruise | Does not exist. |
| A record of what a delegate **did** | Does not exist. `decisionDelegated` is a transient `CareerSession` outcome; it appears in no `DomainEvent` and no history type. |

The last row, not the mapping, is what blocks *While You Were Away*.

**The ledger's "eleven ownership areas" is also wrong.** The drawn surface (`demo/Admin.jsx`) holds
four, and only two of them are areas the engine has:

| Drawn | `CollegeCareerResponsibility` |
|---|---|
| Recruiting board | `recruiting` |
| Transfer portal | `portalAndRetention` |
| Practice plan | *(none)* |
| Depth chart | *(none)* |
| *(not drawn)* | `nilAllocation` |
| *(not drawn)* | `redshirts` |

So the gap is not four-to-eleven. It is **two areas to add, two the drawing omits, and the two
columns neither side has** — `YIELDS` and `INTERRUPTS WHEN`. The drawing's own note names the second
as the load-bearing one: *"yields are what a delegation buys; INTERRUPTS is what ends a cruise, and
it is the only reason a coach would trust one. A delegation you cannot bound is an abdication."*

**And the two the drawing omits are a live defect today.** `nilAllocation` and `redshirts` route
through `CareerSession` and are read at
[`MandatoryDecision.swift:301`](../../Sources/FootballSimCore/Career/MandatoryDecision.swift), so
either can be handed to an assistant right now with no screen that records the arrangement — which
is the failure Press Box has been arguing about, pointing the other way. **Owner decision 2026-08-24:
Responsibilities enumerates `allCases`**, so the table cannot go stale when an area is added.

### The coverage brief is stale

`docs/briefs/2026-08-23-surface-coverage.md` records Press Box at **12 of 62**. Its own
`coverage.card.html` now computes **47 of 47 canonical destinations** — 62 registry identities
resolved by the presentation contract to 47 destinations and 15 aliases — counted by verifying each
named demo actually exports, so a rename shows as a hole rather than as coverage. The registry is
closed. The brief is superseded by this document and should say so.

### And one the ledger could not have known

`guidelines/game-test.card.html` is dated **2026-08-24**, a day after the ledger closed. It is not in
the ledger at all. Its repairs are Phase 1 work.

---

## Phase 0 — port and reconcile

**Gate: `swift build` green, full `SimTests` green, no behaviour change.**

v2 and v1 hold the same 556 tracked source and doc files. **26 differ, in two clean directions**, so
this is a two-way merge and not a fast-forward.

### 0.1 The contract's two branches — DONE 2026-08-24, and the alarm was overstated

Both branches are on v1's `origin`:

- `codex/mock-reconciliation-vertical-slice` — carries per-screen omission lists ("no playoff
  probability, no projected seed, no tiebreak the model does not state")
- `codex/integrate-mock-reconciliation` — collapses those same rows to boilerplate

**The vertical-slice version is strictly more informative and is the one to adopt.**

**This section previously said both branches were local-only and never pushed, and that was wrong.**
The check behind it was `git branch -r --contains <branch>`, which tests whether any remote branch
contains that branch's **tip commit**. Nothing did, because the tip was 8 commits ahead of
`origin` — and that was read as "the branch is not on origin at all". It is the same class of error
`docs/briefs/2026-08-23-surface-coverage.md` made when it called this *"the single most important
finding of the survey"*: **a negative result about a tip is not a negative result about a branch.**

What was actually unpushed was 8 commits. `docs/reviews/2026-08-22-all-screen-presentation-contract.md`
was **already on `origin` and byte-identical** at the old tip, so the file this whole build depends
on was never at risk. The 8 commits were pushed on 2026-08-24 and both branches now track `origin`.

### 0.2 Bring across from v1 — 21 commits, and 19 of them are docs

**v2 is a squash of v1's `claude/match-day-animation-movement-019bcd` at `9a4b7813`.** That is not a
guess: v2's `docs/04-UX-AND-DESIGN-SYSTEM.md` is byte-identical to that commit's, and v2's
`DesignTokens.swift` is byte-identical to v1's at `b070c05d`. So the port is a known commit range,
not a file-by-file reconciliation.

`git log 9a4b7813..main` in v1 is **21 commits**, all of them on `origin/main` and fetchable:

| Commits | Touch | What |
|---|---|---|
| `aec30b9c` … `859af492` (18) | **`docs/` only** | The briefs, the ledger and its revisions, the seven `feat(design)` family commits, and the three `docs(canon)` amendments to `04` / `04b` / `10-CANON-AMENDMENT-04`. They touch no Swift because the drawing happened in the design tool — the repo commit is the ledger row. |
| **`3bd44a58`** | 9 code, 1 doc | A1: icon rail removed, content column 709 → **761** |
| **`55d8d43d`** | 1 code, 2 docs | A4: `CoachWorldTokens.Surfacing` — `Wash`, `Recess`, `Select`, `plate`, plus `Rule`, `Banner`, `Ink`, `Mask` |
| `783ef677` | 3 code, 1 doc | the merge resolution |

**Dry-run result.** `git cherry-pick 3bd44a58` onto v2 auto-merges `ScreenReadModels.swift`,
`ContractTests.swift`, `ScreenRegistry.swift` and `FloodlitChrome.swift` cleanly and conflicts in
three files, ~184 lines total:

| File | Hunks | Resolution |
|---|---:|---|
| `DesignTokens.swift` | 2 (81 lines) | **Keep HEAD** on the `Heat` hunk — v2 already has A2's five-band scale. **Take theirs** on the `Stage` hunk. |
| `DesignContractTests.swift` | 1 (94 lines) | Same rule: A2/A3 assertions already exist in v2. |
| `04-UX-AND-DESIGN-SYSTEM.md` | 2 (9 lines) | Trivial. |

**The general rule: where the conflict is A2 (five-band heat) or A3 (`stateWarning: 0xC9704A`), keep
HEAD — v2 already has them. Where it is A1 or A4, take theirs.**

Also needed, and **not** in the range: `docs/reviews/2026-08-22-all-screen-presentation-contract.md`,
vertical-slice version, from 0.1.

**v2 stays ahead and must not be overwritten** on the 16 commits `main..9a4b7813` — `SnapAnchors`,
`SnapResolver`, `Assignment`, `MatchupRules`, `MatchDayView`, `CoachWorldMatchProvider`,
`03-MATCH-ENGINE.md`, `docs/STATUS.md`, `CLAUDE.md` (the legal-deferral commit), and
`docs/plans/2026-08-22-match-day-template-motion.md`.

### 0.3 Amend the standing rules

- `CLAUDE.md`: the `*-v3.dc.html` row changes from *"The definitive design references"* to
  `AUTHORITY.md`'s own words — *"a visual shell and hierarchy prompt, never a source of facts"*.
- `docs/DOC-MANIFEST.md`: add two `RETAINED` entries — **Press Box** (project `3e8bedda`, with
  `AUTHORITY.md` as its boundary) and **the presentation contract**. `04` remains the canon a builder
  implements against, because the repository cannot open a design tool.
- Add the change flow — Press Box → `04` → Swift — to `CLAUDE.md`'s process section.

### 0.4 One dangling pointer, not fixed here

`04` §9 has no numbered subsections but line 1291 cites **§9.4**, introduced by `1f236d4e`. The ledger
declines to fix it because fixing it means guessing what it named. **Owner or original author to
answer**; a confident wrong pointer is worse than an obviously broken one.

---

## Phase 1 — the shared layer

**Gate: `swift build` green; `SimTests --design-contracts` green; the retired-symbol scan passes;
touched surfaces ≥31/40 with zero P0/P1 against `04b`.**

Six files here are read by every surface, so each fix removes the same defect from dozens of views.

| | Work |
|---|---|
| **A1–A4** | Arrive in Phase 0. Verify, do not rebuild. |
| **A5** | The four accessibility branches. `Rule.color(palette:contrast:reduceTransparency:)` carries the Increase Contrast branch — a view that reads the token gets it whether or not its author remembered. |
| **A6** | **The only remaining blocker on Part B.** The band is the whole of navigation and three of its controls do not exist: `FamilySwitcher`, `BackControl` (three exclusive states), `HostPanel`. |
| **A6b** | Keep the testable chrome contracts. |
| **A7** | Audit, not build: every view checked for gold on a family chip, a sorted column, a selected row or a possession marker. All four are position, not commitment — they take ink. |
| **D4** | `contextShort` on `FloodlitChromeReadModel`. One field; A6's yielding rule needs it. |

**The back control's dead state is drawn, not omitted.** It is a fact about position — you are at a
root, nothing is behind you — and it holds the leading edge still. Omit it and the band's left edge
moves 25 pt between screens.

**Until `HostPanel` exists, 15 of the 62 registry identities are reachable by saved route and by
nothing on screen.**

### The game-test repairs, adopted

Written into Press Box first, then `04`, then built.

| Repair | What |
|---|---|
| **1 · Club at plate scale** | The mark and the accent hairline in the plate head, at the scale `register.css` already documents. Fixes *belongs to nobody* on every desk surface at once. Spends no gold and no cells. |
| **3 · Values as bands** | `HeatBand` where bare numerals sit: Rankings, Statistics, Team health, Cap. Built and contrast-checked; used three times today. |
| **4 · Let the world show** | **Around the plate, not through it.** `--depth-glass-opacity: 0.56` is a measured contrast floor and its own comment forbids lowering it. Raise atmosphere in the margins, the head above the plate, and the bottom fade — which is why Film room and Career line already pass. |
| **2 · A subject on the boards** | Deferred to the family phases; it needs a per-board read-model check. See below. |

**Repair 2 is not one change.** `JerseyLockup` needs a number and a jersey. `StaffRow` carries name,
role, age, reputation, development, recruiting, gamePlanning, schemeAffinity, seasonsWithProgramme —
**no number and no jersey**. Staff boards take the monogram the staff-voice pattern already owns;
player boards take the lockup. Each of the ten boards is audited in its own family phase.

---

## Phase 2 — the engine behind the drawings

**Gate: TDD throughout (`superpowers:test-driven-development`); determinism preserved across
processes; every new collection has a stated bound; `swift build` and full `SimTests` green.**

This is simulation work, not UI work. It exists because of the scope call.

### 2.1 Delegation

| | Work |
|---|---|
| Areas | Add `practicePlan` and `depthChart` to `CollegeCareerResponsibility` — **six at college**. `nilAllocation` and `redshirts` are drawn too: the surface **enumerates `allCases` by construction**, so a new area is covered the day it is added rather than the day someone remembers it. That is `CLAUDE.md`'s coverage-boundary rule applied to a screen, and it is why the table is generated rather than listed. |
| Pro tier | Add `ProCareerResponsibility` and `ProCareerControl`, mirroring `CollegeCareerControl`. None exists. |
| Yield and threshold | Per area: what delegating it buys, and the threshold that hands control back. **New model, and the reason the surface is worth building.** |
| The record | Persist `decisionDelegated` as a `DomainEvent` case and retain a **bounded** delegated-activity log. This is what *While You Were Away* renders. |
| Intent | `setResponsibility` exists for college; extend for pro. |
| Migration | `CollegeCareerControl`'s decoder requires every case present. Adding cases **breaks existing saves** unless the decoder defaults new areas to `.user`. Cover it with a save-migration test. |

### 2.2 Read-model fields the drawings need

| For | Field work |
|---|---|
| Repair 2, per board | Depth chart, staff, shortlist, cuts, negotiation — each needs enough for a lockup or a monogram. Audit each against its contract row before adding. |
| **Compare** | Two subjects side by side from `RosterReadModel` / `PlayerProfileReadModel`. **`Versus` declines to mark a lead where either side is unobserved** — that rule ships with it. |
| **Season Review** | `SeasonHistoryDigest` exists; audit its fields against what the drawing states. |
| **Championship Result** | Backed already: `DomainEvent.seasonCompleted(season:collegeChampionID:proChampionID:)` is retained. |
| **Responsibilities** | 2.1 above. |
| **While You Were Away** | 2.1's log. |

### 2.3 Registry entries — D5

Five surfaces get numbers 63–67 and a family, which the registry forces at compile time.

| Surface | Family | Why |
|---|---|---|
| Compare | `personnel` | Two players, attribute against attribute; Player Profile omits it by name. |
| Responsibilities | `career` | Where delegation is configured, as against exercised. |
| While You Were Away | `weeklyCommand` | Automation halts mid-week and hands control back. |
| Season Review | `career` | *"A season has no ending"* — Aftermath is per-match, and this is the arc's last page. |
| Championship Result | `league` | The fifth ceremony. Bracket / postseason is a table, not a verdict. |

---

## Phases 3–9 — one per family

**Gate, each phase: `swift build` green; full `SimTests` green; every surface in the family
≥31/40 with zero P0/P1 against `04b`; `adversarial-reviewer` on the phase diff before the phase is
declared done.**

Every surface already has a SwiftUI view. **This is a rewrite against a moved standard, not a
greenfield build** — and the regression cover is already there: `DesignContractTests`,
`AccessibilityReflowTests`, `MotionContractTests`, `ReduceMotionContractTests`. 43 of 70 view files
already read the token layer and only 17 raw numeric literals sit in `padding` / `font` / `frame` /
`cornerRadius` across all of them.

| Phase | Family | Canonical | Aliases | Notes |
|---|---|---:|---:|---|
| 3 | **This week** | 9 | 0 | Match Day is v2's own lead — reconcile, do not overwrite. Box score is one of the two surfaces the game-test names as costing the most. |
| 4 | **Personnel** | 5 | 3 | Repair 2 lands properly here; Roster already does it. |
| 5 | **Recruiting** | 7 | 4 | Four aliases fold into College offseason (61). |
| 6 | **Pro management** | 5 | 3 | Three aliases fold into Pro front office (62). |
| 7 | **League** | 11 | 0 | Largest, and the prediction that it would force a new component **was falsified** — standings measured at six columns in 737 pt. Two redefinitions stand: derived geography is structural, and *probability* is forbidden on the screen named after one. |
| 8 | **Career** | 9 | 4 | Four aliases fold into Career hub (52). Title / Continue is the other most-costly *no*. |
| 9 | **Entry** | 1 | 1 | Appointment aliases to Career hub. Smallest phase, first thing a player ever sees. |

**47 canonical, 15 aliases, 62 identities.** An alias needs routing, not a drawing — but it does need
`HostPanel` from Phase 1 to be reachable at all.

### The three rules that apply across every family phase

- **C5 — the gold count.** A surface offering several equal actions has a budget of **zero**, by
  construction. Only a surface with exactly one committing action may gild it. Destructive actions
  take `state.negative` — equal in weight is not equal in kind.
- **C6 — an unavailable action stays drawn and prints its reason.** A control that vanishes teaches
  the coach the screen is inconsistent; one that greys out silently teaches them it is broken.
- **C7 — never *derive* a remainder.** Print one where the read model retains it; otherwise print
  committed-of-total.

### And the one that governs all of them

**The presentation contract's omission lists bind in full.** No reply or composition on Inbox and no
undo; no by-situation tendency table in the film room; no editable sliders, no remaining-minutes
field and no cost on either weekly plan; no diagnosis, return date or treatment on team health; no
trend or prior-grade delta on aftermath; no opposed team totals, quarter scoring or play-by-play on
the box score. **The reference sheets draw all seven.** Building from the sheets rather than the
contract ships all seven.

---

## Phase 10 — the five new surfaces

**Gate: as Phases 3–9, plus each surface's engine backing demonstrably present.**

Built last because every one depends on Phase 2. `Versus` is the only genuinely new component and it
**must never be collapsed into `ForkPanel`** — a fork draws its sides identically because weighting
one would be the interface recommending; a comparison exists *to* show which side is ahead. Same
geometry, opposite obligation.

---

## Phase 11 — legal and identity

Untouched by this plan. `CLAUDE.md` sequences original-identity and trade-dress compliance as a
final phase, deliberately, in one pass. Nothing in Phases 0–10 blocks on it and nothing in it should
be started early.

---

## What is deliberately not in this plan

| | Why |
|---|---|
| D1 — a scouting-confidence model | **Withdrawn, and the design was wrong.** `Evaluation` retains a verdict, a scheme fit, an uncertainty stated **in words** and `citedOutliers`. `ConfidenceRange` is retired. `04` §6.4's ranged-rating rule was reversed. |
| D2 — screen transitions | Closed. Two moves: family switch `world` 0.42, sibling `value` 0.22 in place. No new duration. |
| D3 — commit propagation | Already satisfied. See above. |
| A light appearance | Refused, not missing. Dark-only by decision; half the tokens are built on lamp and glass. |
| An in-app copy of any OS accessibility setting | A second source of truth that drifts, and it would be the one the user changed while the CSS kept obeying the other. |

---

## Risks

| Risk | Mitigation |
|---|---|
| ~~The contract is on two unpushed local branches~~ | **Closed 2026-08-24 — the risk was misread, see 0.1.** The contract was already on `origin`; 8 tip commits were not, and now are. |
| **Save migration on the delegation enum** | `CollegeCareerControl`'s decoder requires every case. Default new areas to `.user` and test it. |
| **`04` conflicts on the port** | Two hunks, nine lines — small, but re-run the colour scan afterwards. It reads canon as a whitelist, so an unstated hex fails to compile, which is the scan working. |
| **Press Box's own numbers going stale** | The change flow puts Press Box first for exactly this reason. Its `checks.card.html` and `coverage.card.html` are scans, not checklists; they only stay true if the standard moves first. |
| **A phase gate that depends on a build** | A Swift toolchain **is present** here (Swift 6.3.3, `xcodebuild`), so no phase in this plan may report "unverified — never compiled". Simulator demonstration remains an owner action; hand off a walkthrough script, never claim it happened. |
| **The drawings are set in a narrower face than the system stack** | A width or a line length copied from Press Box needs re-measuring. It has bitten twice, and both times measuring caught it and looking did not. |

---

## Keeping this current

One row per phase, and a phase is done when the Swift matches the standard **and** a check proves it —
not when it looks right. Press Box's own verification is the model: six rules scanned across every
component source; a geometry sweep over every surface at once rather than the instance in front of
you; and a check that is ancestor-aware on both axes, because an element clipped inside a plate
leaves the frame measuring perfectly while the content is gone.
