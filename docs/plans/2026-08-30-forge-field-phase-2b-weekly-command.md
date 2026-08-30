# Forge Field Phase 2B — Weekly command

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** draw the nine weekly-command surfaces to the Forge Field sheets, on the shell Phase 2A built.

**Architecture:** the budgets first, then the surfaces. Every screen in this family carries a stamped register and a set of budgets that are **review failures, not guidelines** — stage percentage, data points, gold count, ember count, ghost size and opacity, background count. Task 1 turns all nine into a single data table with a contract that reads it, so each surface task afterwards is verifiable the moment it is drawn rather than by eye at the end.

**Tech Stack:** iOS 26+, Swift 5.10 language mode, SwiftUI. Swift 6.3.3 toolchain present.

**Spec:** `Game screens - Weekly command.dc.html` in Forge Field project `8c511c92-3337-4cfb-850c-140a659f3034`, plus `docs/superpowers/specs/2026-08-29-forge-field-standard.md`. **Where this plan and the sheet disagree on a number, the sheet is right** — except where the adaptation rule applies.

**Canon:** `04` sections 6.1e, 6.1f, 6.2a, 6.2a(i), 6.3a, 6.6a, 6.7a, and 7. **Ledger:** `docs/FRONTEND-CHANGE-LEDGER.md` Part E.

**Entry criterion:** Phase 2A merged. **Do not start before it is.**

## Global Constraints

Everything in `docs/plans/2026-08-30-forge-field-phase-2-roadmap-and-2a-shell.md`'s Global Constraints section applies unchanged, including **the adaptation rule**: the sheets are mock-ups and do not account for visibility, measurement or legibility faults on a real device. Deviate for illegibility, a contrast breach, a sub-44 pt tap target, truncation at 852 x 393, or a composition that cannot reflow at AX5 — and record every deviation. Do not deviate for taste.

Additionally, and specific to this family:

- **Forge Field does not override a fact.** `docs/reviews/2026-08-22-all-screen-presentation-contract.md` governs what each surface holds and must omit. Its omission lists bind in full: no reply or composition action on Inbox and no undo; no by-situation tendency table in the film room, only two rates, a confidence and an unavailable reason; no editable sliders, no remaining-minutes field and no cost on either weekly plan; no diagnosis, return date or treatment on team health; no trend or prior-grade delta on aftermath; no opposed team totals, quarter scoring or play-by-play on the box score. **A sheet that draws one of these is an ask, not a licence** — stop and escalate.
- **Rule A-1, from the sheet:** an ACTION surface may not exceed the comfortable tier. Every control on it is 44 tall. *"A decision taken at dense density is a decision taken by mistake."*
- **Rule A-2, from the sheet:** the committing control is never inside a table row. It sits in the flooded strip, above the seam, beside the figures it argues with.
- **Zero gold on a Desk surface.** Gold is earned standing; a desk is where work happens.

---

## The four defects this family owns

Observed on device, recorded in ledger Part E. Fix each as part of the surface that carries it, not separately.

| Defect | Surface | What ships today |
|---|---|---|
| `WEEK 1 · WEEK 1` | Coaching HQ | The week is printed twice in the same line |
| Both options read `NO RECORDED COST` | Coaching HQ | Two decision options, neither naming a price. `04` 6.1e: if an action has no cost worth naming, it is not an ember. `ForgeFieldEmber` now makes the cost non-optional, so drawing these as embers is impossible until the read model carries a cost — that is the ask |
| `WHY IT IS HERE` renders empty | Coaching HQ | A heading with no body |
| `ADVANCE` is gold | Coaching HQ | Gold is standing only. The commit is the ember |

---

## Task 1: The register and budget contract

**Files:** Create `Sources/ProFootballCoachUI/ForgeFieldBudget.swift`. Test: `Tests/SimTests/Suites/DesignContractTests.swift`.

**Interfaces produced:** `ForgeFieldBudget` with `static let weeklyCommand: [CoachWorldScreenID: ForgeFieldBudget]`, each carrying `register`, `stageFraction: ClosedRange<Double>?`, `dataPoints: Int?`, `pointsAboveSeam: Int?`, `goldMax: Int`, `emberCount: Int`, `ghost: Ghost?`, `backgrounds: Int`. Tasks 2 to 10 each assert their own surface against it.

The nine, transcribed from the sheet's stamped spec columns:

| Screen | Register | Stage | Points | Gold | Ember | Ghost | Backgrounds |
|---|---|---|---|---:|---:|---|---:|
| Coaching HQ | Broadcast, pageantry-led, MIXED | 62%, band 55–65 | 9 of 14 above seam | 2 of 3 | 1 | 244 px, .10, top-right | 2 of 2 |
| Inbox | Desk, no flood, 3 pt club spine, MIXED | 0%, desk max 25 | 58 of 80 | **0** | 1 | none | 1 of 2 |
| Opponent report · film room | Dossier, MIXED | 33%, band 30–40 | 34 | 0 of 2 | 1 | 230 px, .13, **desaturated to 0** | 2 of 2 |
| Game plan | Desk, no flood, 3 pt spine, ACTION | 0%, desk max 25 | 44 of 80 | **0** | 1 | none | 1 of 2 |
| Practice plan | Desk, one flooded strip, ACTION | 19%, desk max 25 | 52 of 80 | **0** | 1 | none | 2 of 2 |
| Team health | Desk, one flooded strip, MIXED | 16%, desk max 25 | 66 of 80 | **0** | 1 | none | 2 of 2 |
| Match day | Broadcast at 100% | 100%, no chrome bar, no seam | 14 figures on the apron | 3 of 3 | 1 | none | — |
| Aftermath | Broadcast, READOUT | 56%, band 55–65 | 11 of 14 above seam | 3 of 3 | **0** | 250 px, .11, top-right | 2 of 2 |
| Game detail · box score | Dossier, vertical seam, READOUT | 32% across the seam axis | 72 | 0 of 2 | **0** | none | 1 of 2 |

- [ ] **Step 1: Write the failing test.** Assert `ForgeFieldBudget.weeklyCommand` holds exactly the nine screens of `CoachWorldSurfaceFamily.weeklyCommand.surfaces`, enumerated BY CONSTRUCTION from the registry rather than a literal list, so a tenth surface added to the family fails until it is budgeted. Assert the three zero-gold Desk surfaces are zero, the two zero-ember readouts are zero, and that no surface exceeds `ForgeFieldTokens.Register.deskStageMax` while declaring a Desk register.
- [ ] **Step 2: Run it and watch it fail.**
- [ ] **Step 3: Implement `ForgeFieldBudget`** from the table above. Every number from the sheet; nothing invented. A screen the sheet does not stamp gets `nil`, never a guess.
- [ ] **Step 4: Run the test green.**
- [ ] **Step 5: Commit.** `feat: stamp the weekly-command register budgets as a contract`

---

## Tasks 2 to 10: one surface each

Each surface is the same shape. Do them in this order — Coaching HQ first because it carries all four defects and is the family's hardest composition; Match day last because it is the only surface with no chrome bar and no seam.

**Order:** Coaching HQ, Inbox, Game plan, Practice plan, Team health, Opponent report · film room, Aftermath, Game detail · box score, Match day.

**For each surface, every task follows these steps:**

- [ ] **Step 1: Read that surface's spec column on the sheet in full**, and take its geometry as `name · x,y · w×h · cols` verbatim. Do not round positions to the ladder — the ladder governs gaps you choose, not positions the sheet fixes.
- [ ] **Step 2: Read the surface's row in `docs/reviews/2026-08-22-all-screen-presentation-contract.md`.** If the drawing shows a fact the read model does not hold, STOP and escalate. Do not draw it and do not invent a source for it.
- [ ] **Step 3: Write the failing budget test** — assert the drawn surface against its `ForgeFieldBudget` entry: stage fraction inside its band, data points at or under the cap, gold count, ember count, ghost size and opacity, background count.
- [ ] **Step 4: Run it and watch it fail.**
- [ ] **Step 5: Draw the surface** from `ForgeFieldDevice`, the four primitives, `ForgeFieldEmber` and `ForgeFieldType`. **No design-token literal.** Compose; do not re-implement a primitive because a surface wants it slightly different — if a primitive genuinely cannot express the drawing, that is a finding for Phase 2A's files, not a local copy.
- [ ] **Step 6: Run the budget test green, plus `swift build`, `--design-contracts` and `--core-contracts`.**
- [ ] **Step 7: Render it.** Build for a booted iPhone 17e, launch, navigate to the surface, screenshot it, **and look at it against the drawing.** A surface is not done because its tests pass. Screenshot both the standard size and AX5.
- [ ] **Step 8: Commit**, one per surface, and record any adaptation-rule deviation in the commit body and in ledger Part E.

### Per-surface notes that are not obvious from the table

**Coaching HQ.** Geometry from the sheet: chrome bar `10, 8` `832 x 30`; flood field `10, 44` `832 x 242`; hard seam `10, 286` `832 x 1`; obligations `10, 294` `832 x 87`; three tiles `20, 306` `265 x 44`; ember `327, 224` `198 x 44`. Flood stack gap 13, tile gap 9, panel head 19, panel padding 0/10. Type: club names 62 `--fs-fixture` at `.82` and `-.02em`; the fixture "v" at 26; records at 12 mono tabular; the kickoff line at 10 display `.2em`; the standing badge at 9 — **which is below the 10 pt floor `04` 6.2a(i) set, so it ships at 10; record the deviation.** Fixes all four defects above.
**The obligation overflow is unanswered by the sheet** and must be answered here: three tiles fit in 87 pt, and the sheet says nothing about a week with eight obligations. An overflow row stating the count and routing to the full list is the cheapest honest answer. Whatever you choose, nothing may be hidden with no affordance saying so.

**Opponent report · film room.** The one place a flood is **not** club colour: it runs cold slate at 102 degrees and the ghost mark is desaturated to zero, because *"club colour on this screen would say the opponent belongs to us."* Gold is 0 of 2 — *"none of this standing is ours."*

**Team health.** Rule A-2's worked example: the committing control sits in the flooded strip above the seam, beside the four figures it argues with, never inside a table row.

**Aftermath.** Zero ember, deliberately: *"nothing here is irreversible"* and *"an ember here would claim the result is a decision you made."* Leaving costs one quiet control, `Week 11 →`. Three gold is the ceiling and this surface spends all of it, which is why the grades panel below the seam has none.

**Game detail · box score.** The only surface in the family where 32 pt dense rows are legal, and it earns them the only way allowed: **every row is inert.** If any row on it becomes tappable, the rows go to 44.

**Match day.** The only surface with no chrome bar and no seam — at 100% stage there is nothing to divide. The studied half is four glass plates on the apron, and they are the only `backdrop-filter` in the product. The sheet says its status is **unchanged from the shipped surface**, so this task is a re-skin, not a re-architecture; the 2D field, its animation and its recorded-outcome contract are untouched. Read `docs/03-MATCH-ENGINE.md` before starting and change nothing that resolves a play.

---

## Phase 2B exit

- [ ] `swift build` green.
- [ ] `--design-contracts` and `--core-contracts` green.
- [ ] Full `swift run SimTests` green — roughly 3.5 hours, 1194 tests. Run once, here.
- [ ] Adversarial review on the phase diff; fix confirmed findings first.
- [ ] All nine surfaces rendered on a booted device and looked at, at standard size and AX5.
- [ ] Every deviation recorded in ledger Part E. **Ask the owner before any push or merge.**
