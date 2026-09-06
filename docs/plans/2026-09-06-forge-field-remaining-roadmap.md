# Forge Field — the remaining phases: 2S, 2C, 2D, 2E, 2F, 2G and the 2H audit

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement each phase task-by-task. Steps use checkbox (`- [ ]`) syntax. **One phase at a time** (`CLAUDE.md` Process 1): finish a phase's exit list, stop, and get the owner's word before the next.

**Goal:** finish putting Forge Field on screen — the 38 canonical surfaces the weekly-command batch did not draw (47 canonical destinations, 9 drawn in 2B) — retire the Press Box layer, and audit the whole product against `docs/04b-AUDIT-RUBRIC.md` with machine gates and an evidence pack.

**Architecture:** one shared phase first (2S: canon amendments, the budget/facts contract generalised to every family, the two input primitives and the number formatter every later family needs), then one family per phase (2C personnel, 2D recruiting, 2E pro management, 2F league/career/entry — independent, any order, parallel worktrees allowed), then 2G (delete `CoachWorldTokens` and the Press Box chrome once nothing reads them), then 2H (the audit). Each family plan is written against its own sheet and lives in its own file beside this one.

**Tech Stack:** iOS 26+, Swift 5.10 language mode, SwiftUI. Swift 6.3.3 toolchain present locally; `swift build`, `swift run SimTests --design-contracts`, `--core-contracts` and the full `swift run SimTests` all run. Xcode present; renders on a booted simulator.

**Spec:** the five `Game screens - *.dc.html` sheets and `FF Chrome.dc.html` in Forge Field project `8c511c92-3337-4cfb-850c-140a659f3034` (transcribed excerpts are inside each family plan, so a builder never needs the design tool), plus `docs/superpowers/specs/2026-08-29-forge-field-standard.md`. **Where a plan and a sheet disagree on a number, the sheet is right — except where the adaptation rule applies, and except where the presentation contract forbids the fact.**

**Canon:** `04` sections 6.1e, 6.1f, 6.1f(i), 6.2a, 6.2a(i), 6.3a, 6.6a, 6.7a, 7. **Contract:** `docs/reviews/2026-08-22-all-screen-presentation-contract.md`. **Ledger:** `docs/FRONTEND-CHANGE-LEDGER.md` Part E, rows E1–E44 as of 2026-09-06; every phase below appends rows from **E45**.

**Prior plans this continues:** `docs/plans/2026-08-30-forge-field-phase-2-roadmap-and-2a-shell.md` (the roadmap and the adaptation rule), `docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md` (the family-plan shape), `docs/plans/2026-08-31-forge-field-handoff.md` (the rulings; read its §5 and §7 before any surface).

## Global Constraints

Copied from the 2A roadmap; they apply to every task in every file of this set.

- iOS 26+, Swift 5.10 language mode, SwiftUI. **iPhone-only, landscape-only.** Offline. **Zero third-party app dependencies.**
- **Device is 852 x 393.** Margins 10, so the content column is 832. Grid is 12 columns, 9 px gutters.
- **One radius: 3 pt** on every panel, button, plate, chip and mark. The only 14 pt is the outer device frame.
- **Ladder: 4 / 8 / 12 / 16 / 24 / 32 / 44.** Nothing off-ladder.
- **Rows: 32 dense — legal only when the whole row is inert — or 44 touch.** Anything tappable is 44 on its short edge.
- **Gold means earned standing only.** Max three per surface, zero on a Desk surface.
- **Ember is the commit.** One per surface, only on something irreversible, and it carries a mono cost sub-label. **If an action has no cost worth naming, it is not an ember.** `ForgeFieldEmber.cost` is non-optional and asserts non-empty.
- **Club colour is legal as a flood or a 3 pt spine and illegal as a panel ground, row band, button or chart series.**
- **Four signals, no fifth:** alarm `#E9524A`, caution `#E7C13C`, good `#46C083`, cold `#A8C4E0`. A rival is always cold slate.
- **No icon set.** Status is a signal dot; identity is a mark plate. The only glyphs are `★` U+2605 and the arrows. **No emoji anywhere.**
- **No photographs, no illustrations.** Backgrounds are floods, lamp washes, the oversized ghost mark, and the scanline.
- **Nothing loops.** `prefers-reduced-motion` collapses the four transitions to a 90 ms crossfade and makes the flood wipe a cut.
- **A design-token literal in a view is a defect.** Every value comes from `ForgeFieldTokens`, `ForgeFieldType`, or a named `private enum XMetric` constant transcribed from the sheet with its source in a comment (the `HQMetric` / `BoxScoreMetric` pattern).
- **The AX5 and Dynamic Type contract in `04` section 7 is a floor.** Every surface has an `isAccessibilitySize` composition that reflows to one column, preserves order, drops nothing, and lifts every `lineLimit(1)` (`ForgeFieldEmber.lineLimit(for:)`'s pattern).
- **Forge Field does not override a fact.** The presentation contract says what each surface holds and must omit. A sheet that draws a fact the read model does not hold is an ask, not a licence.
- **A test that checks a class must enumerate that class by construction.**
- Conventional Commits. One task = one commit. **Ask the owner before any push or merge.** The repository stays on `main`; a worktree branch is harvested onto `main` and deleted.

---

## Where it stands (2026-09-06)

| Phase | State |
|---|---|
| 2A shell | Done, gated (E20). |
| 2B weekly command | Done: ten surfaces drawn and rendered; full suite 1,282 tests / 933,191 checks green on 2026-09-01 (E43); owner-reference follow-up closed (E44). |
| 2C–2F | **Not started.** Zero of the 38 remaining canonical views reference `ForgeField*`; 62 files still read `CoachWorldTokens`. (The 2A roadmap counted 2F as 14 surfaces; the sheet and the registry make it 21 — the four legacy-history surfaces, Title, Settings and Coach identity are canonical and undrawn.) |
| 2G | Blocked on 2C–2F. |
| 2H audit | Not started; no rubric scoring exists for any Forge Field surface. |
| 2I engine, read-model and gate completion | **Not started.** Runs beside 2C–2F (engine, providers, read models, suites — never a family's view file until its closing task); an entry criterion for 2H. `docs/plans/2026-09-06-forge-field-phase-2i-completion-and-2j-release-candidate.md`. |
| 2J release candidate | Blocked on 2H. Same file. At its exit only human testing approval, the §4a owner-only distribution gates and the final legal sweep remain. |

Open rows carried in: **E18** (chrome bar at AX5, owner decision), **E22** (`Tests/ProFootballCoachUITests/` runs under no gate), **E24/E25** (Coaching HQ read-model asks; resolved presentationally in 2B), **E38** (route bar at AX5), **E42** (the ghost census, applied family by family below).

---

## The rulings that carry over — do not relitigate

1. **The ember rule** (handoff §5.1). Check the contract row before the sheet. If the drawn ember names a cost the model does not record, the surface has zero embers and its budget row says so with the reason. A cost line may be a recorded figure (`"\(count) DUE"`), a recorded reason (`continueReason`), a recorded consequence (`Option.consequence`, `ActionRow.detail`, `CoachWorldActionChoice.cost`), or the action's own irreversibility stated in words already present in the view (`"no undo"`) — never a number invented to fit the sheet. **Pass it as a named `private var emberCost: String`** (the 2B shape), never an inline expression: `DesignContractTests`' "an ember's cost argument is a string literal or a named constant" scan reads every `ForgeFieldEmber(` call site.
2. **Type floors** (E15): column heads ship at 10, prose floor at 12. Every sheet below stamps `9 · --fs-colhead`; it ships as `ForgeFieldType.Step.columnHead`. Every sheet's `ember cost 9 · mono` ships as `ForgeFieldEmber.costStep` (`.figure`, 11) — `ForgeFieldEmber` owns that step and a surface does not restate it.
3. **Faces** (E3/E4): `ForgeFieldType.font(_:)` only. No `Font.custom` in a surface.
4. **Navigation** (E16–E19, E36–E37): the chrome bar's contents are fixed; career draws its own route bar (`FloodlitFamilyRouteBar`), re-skinned in 2F.
5. **The ghost census** (E42) is a list, not a licence. Personnel: Player profile 260/.13 bottom-left. Recruiting: Signing day 300/.13 bleeding the right edge. League/career/entry: Team profile 260/.13 top-right; Awards 260/.13 bottom-right; Promotion 260/.13 top-right; Title/Continue recovery panel 260/.13 bottom-right; three Coach Identity programme bands 230/.13 top-right each. **Every other surface in 2C–2F draws no ghost**, and the budget table says so.
6. **Every surface ends on a render.** Standard and AX5, on a booted iPhone 17e, looked at against the drawing. A surface is not done because its tests pass.
7. **Existing views are authoritative on facts and behaviour** (contract §Authority). A Forge Field redraw changes how a thing is drawn; it keeps every callback, every state transition and every accessibility identifier the contracts assert, or amends the contract in the same commit and says why.

---

## Owner decisions this set depends on

Each has a **default the plans assume**, so nothing blocks; each is also a question the owner can answer differently, in which case the affected task changes. Ask them together, before 2S Task 1 amends canon.

| # | Question | Default assumed below | Affects |
|---|---|---|---|
| FF-1 | E18: what does the chrome bar do at AX5? | Unchanged — degraded, not broken. | Every surface's AX5 render |
| FF-2 | Gold on another club's dossier (Team profile draws record and rank of a rival)? | **Gold is your standing, not the tier's.** Gold only when the profiled team is the controlled club; a rival's figures are ink 1. Canon `04` 6.1e(i). | 2F Team profile |
| FF-3 | Gold on a Desk surface for a champion (Bracket) and records set under you (Record book)? | **Zero.** Neither fact is on its model (no winner field, no record holder), so the question is moot until it is; the surfaces draw zero gold and the ask is recorded. | 2F Bracket, Record book |
| FF-4 | The fifth register for Title and Coach identity? | **Named `Entry` in canon** `04` 6.1e(ii): no chrome, no seam, no club hue on the device (the product's own palette is Calumet, hue 26 — sodium and floodlight); budgets: 20 data points, 1 ember, 0 gold, ghosts per the census. | 2F Title, Coach identity |
| FF-5 | Screen 36 (Roster cuts) is 34 with a title string: alias it, or build the drawn surface? | **Stays canonical**, drawn from what the model holds (limit strip + cut list); the position-floor table needs `positionFloors` on the model and is recorded as an ask. | 2E Task 4 |
| FF-6 | Screen 55 (Promotion) is 52's first row at size: alias it, or keep the Dossier? | **Keep the Dossier** — it is the row 52 opens into, the 24→25 pattern. | 2F Promotion |
| FF-7 | Where is `career` reached from (6.1f's open question)? | **Unchanged**: off the bar, reachable through model-owned destinations, moved between via the route bar (6.1f(i)). | 2F |
| FF-8 | The sheets' fifteen-item findings ledger (money formatter, calendar label, units on `value: Int`, references not strings, generator headroom, signing bonuses, markets, undeclared aliases…)? | **Items 1, 2 and 7 are done in 2S** (they are presentation). **Everything else is a read-model or engine ask**, recorded as one ledger row per family, drawn around honestly, and not built in these phases — **built in 2I** (`docs/plans/2026-09-06-forge-field-phase-2i-completion-and-2j-release-candidate.md` Tasks I1–I5; I18 draws them once each family has merged). | Every family |

---

## Phase 2S — shared: canon, the budget contract for every family, inputs, formatting

**Entry criterion:** 2B merged (it is). **Deliverable:** nothing on screen changes; four things every family plan consumes exist and are tested.

### File structure

| File | Responsibility |
|---|---|
| `docs/04-UX-AND-DESIGN-SYSTEM.md` | **Modify.** Four amendments: 6.1e(i) gold on another club's dossier; 6.1e(ii) the Entry register; 6.2a(ii) figure formatting (money, thousands, calendar); 6.3a(i) input controls and the 24 pt inert caption line. |
| `Sources/ProFootballCoachUI/ForgeFieldBudget.swift` | **Modify.** `tables` keyed by family; `ForgeFieldSurfaceFacts`; the `facts` registry. |
| `Sources/ProFootballCoachUI/ForgeFieldInputs.swift` | **Create.** `ForgeFieldField` (text/number, 44 pt) and `ForgeFieldStepper` (−/+ with bounds). |
| `Sources/ProFootballCoachUI/ForgeFieldFormat.swift` | **Create.** `money(_:)`, `thousands(_:)`, `calendar(_:)`. |
| `Sources/ProFootballCoachUI/ForgeFieldPrimitives.swift` | **Modify.** Add `ForgeFieldGhostMark`. |
| `Tests/SimTests/Suites/DesignContractTests.swift` | **Modify.** One generic budget suite over every family table; input, format and ghost suites. |

### Task S1: Canon first — four amendments

**Files:** Modify `docs/04-UX-AND-DESIGN-SYSTEM.md`. Test: `Tests/SimTests/Suites/DesignContractTests.swift` "Document manifest" / canon-text scans already read `canonText()`; the new S2–S4 tests below cite these section names.

- [ ] **Step 1: Add `### 6.1e(i) Gold on another club's dossier (2026-09-06 amendment)`** after 6.1e, stating: *"Gold is the coach's own earned standing. A dossier of another club (Team / Programme profile opened from the map, standings, schedule or search) draws that club's record and rank in ink 1. The same figures take gold only when the profiled team is the controlled club. A rival's plate is cold slate, per the four-signal rule."* Cite FF-2.
- [ ] **Step 2: Add `### 6.1e(ii) The Entry register (2026-09-06 amendment)`**, stating: *"Title / Continue and New career & coach identity are neither Desk, Broadcast, Dossier nor Ceremony: they are the app before there is a world. The Entry register has no chrome bar, no seam and no club hue on the device — the device palette is Calumet (hue 26), the product's own. Club colour appears only scoped to the thing that has one: the save being recovered (a 3 pt spine and a 260 pt ghost inside that panel), or a starting-job card (a 52 pt flood band in the programme's own colour with its mark ghosted at 230/.13). Budgets: 20 data points, one ember, zero gold. Three hues on the coach-identity surface is the one place the two-background rule bends, because the choice is between three identities."* Cite FF-4.
- [ ] **Step 3: Add `#### 6.2a(ii) Figures carry their form (2026-09-06 amendment)`** under 6.2a: *"Money is integer dollars and prints abbreviated at scale in the record face: `$291.95M`, `$5.42M`, `$0` — two decimals above one million, `$795K` between one thousand and one million, `$800` below — never `$291949500`. Any integer that can exceed 999 prints with thousands separators (`2,418`). A `CalendarState` prints as `season N, week W`, one-based, everywhere; a pre-formatted string in a read model prints verbatim and is an ask for a value. The voice rule stands: a number carries its denominator when the model states one."*
- [ ] **Step 4: Add `#### 6.3a(i) Inputs, and the caption line (2026-09-06 amendment)`** under 6.3a: *"The product has three text inputs (world search, shortlist filter, the coach's own name), two money fields and two steppers (contract years, call-ins a game). A field is a 44 pt row on ground 3 with a 1 pt hairline at .22 (`edge-raised`) that steps to .30 (`seam-hard`) when focused; placeholder in ink 4; the record face for figures, the display face for words; no platform chrome. A stepper is a field with a `−` and a `+` at its ends, each a 44 pt target, the bounds printed under it from the rule that owns them, in ink 4. An inert single-line caption — a person row above priced actions, a footer count, a rating bar's row — may be 24 pt, which is on the ladder; it carries no figure compared down a column and is never a tap target."*
- [ ] **Step 5: Run `swift run SimTests --design-contracts`.** Green (canon scans still parse).
- [ ] **Step 6: Commit.**
```bash
git add docs/04-UX-AND-DESIGN-SYSTEM.md
git commit -m "docs(04): amend canon for the remaining Forge Field families -- gold on a rival, the Entry register, figure formatting, inputs"
```

### Task S2: The budget contract for every family, and what each drawn surface reports of itself

**Files:** Modify `Sources/ProFootballCoachUI/ForgeFieldBudget.swift`; modify `Sources/ProFootballCoachUI/PracticePlanView.swift`, `TeamHealthView.swift` (expose `ghostSize`/`ghostOpacity` statics where only `hasGhostMark` exists). Test: `Tests/SimTests/Suites/DesignContractTests.swift`.

**Interfaces produced:**
- `ForgeFieldSurfaceFacts` — `init(stageFraction: Double, dataPointCount: Int, goldElementCount: Int, emberElementCount: Int, ghost: ForgeFieldBudget.Ghost?, backgroundCount: Int)`.
- `ForgeFieldBudget.tables: [CoachWorldSurfaceFamily: [CoachWorldScreenID: ForgeFieldBudget]]` — 2C–2F each add one line.
- `ForgeFieldBudget.facts: [CoachWorldScreenID: ForgeFieldSurfaceFacts]` — every drawn surface adds one line, built from its own `// MARK: - Assertable budget facts` statics.

- [ ] **Step 1: Write the failing suite.**
```swift
    suite("Forge Field budgets, every family (06.1e, 06.3a)") {
        test("every family table covers exactly that family's canonical surfaces, by construction") {
            for (family, table) in ForgeFieldBudget.tables {
                expectEqual(Set(table.keys), Set(family.surfaces),
                            "\(family.canonicalName): the table must hold exactly "
                                + "CoachWorldSurfaceFamily.\(family.rawValue).surfaces")
            }
        }
        test("every budgeted surface reports facts, and no facts exist without a budget") {
            let budgeted = Set(ForgeFieldBudget.tables.values.flatMap(\.keys))
            expectEqual(Set(ForgeFieldBudget.facts.keys), budgeted,
                        "a drawn surface registers ForgeFieldSurfaceFacts beside its budget; a "
                            + "budgeted surface with no facts has not been drawn, and must fail here "
                            + "until it is")
        }
        test("every surface's facts sit inside its stamped budget") {
            let tolerance = 0.01   // the sheets round irrational pixel ratios; 2B's precedent
            for (screen, facts) in ForgeFieldBudget.facts {
                guard let budget = ForgeFieldBudget.tables.values.compactMap({ $0[screen] }).first else {
                    expect(false, "\(screen.canonicalName) has facts but no budget"); continue
                }
                if let stage = budget.stageFraction {
                    expect(facts.stageFraction >= stage.lowerBound - tolerance
                               && facts.stageFraction <= stage.upperBound + tolerance,
                           "\(screen.canonicalName) stage \(facts.stageFraction) outside \(stage)")
                }
                if let cap = budget.dataPoints ?? budget.pointsAboveSeam {
                    expect(facts.dataPointCount <= cap,
                           "\(screen.canonicalName) draws \(facts.dataPointCount) points over \(cap)")
                }
                expect(facts.goldElementCount <= budget.goldMax,
                       "\(screen.canonicalName) spends \(facts.goldElementCount) gold over \(budget.goldMax)")
                expectEqual(facts.emberElementCount, budget.emberCount,
                            "\(screen.canonicalName) ember count")
                expectEqual(facts.ghost, budget.ghost, "\(screen.canonicalName) ghost")
                if let backgrounds = budget.backgrounds {
                    expectEqual(facts.backgroundCount, backgrounds, "\(screen.canonicalName) backgrounds")
                }
            }
        }
        test("register rules hold in every table: Desk is zero gold and under the desk stage cap; "
                + "READOUT is zero ember; Broadcast and Dossier sit in their bands") {
            for table in ForgeFieldBudget.tables.values {
                for (screen, budget) in table {
                    switch budget.register.lean {
                    case .desk:
                        expectEqual(budget.goldMax, 0, "\(screen.canonicalName) is Desk: zero gold")
                        if let stage = budget.stageFraction {
                            expect(stage.upperBound <= ForgeFieldTokens.Register.deskStageMax,
                                   "\(screen.canonicalName) stage over the desk cap")
                        }
                    case .broadcast where screen != .matchDay:
                        if let stage = budget.stageFraction {
                            expectIn(stage.lowerBound, ForgeFieldTokens.Register.broadcastStage, "\(screen.canonicalName)")
                            expectIn(stage.upperBound, ForgeFieldTokens.Register.broadcastStage, "\(screen.canonicalName)")
                        }
                    case .dossier:
                        if let stage = budget.stageFraction {
                            expectIn(stage.lowerBound, ForgeFieldTokens.Register.dossierStage, "\(screen.canonicalName)")
                            expectIn(stage.upperBound, ForgeFieldTokens.Register.dossierStage, "\(screen.canonicalName)")
                        }
                    default: break
                    }
                    if budget.register.tone == .readout {
                        expectEqual(budget.emberCount, 0, "\(screen.canonicalName) is READOUT: zero ember")
                    }
                }
            }
        }
    }
```
- [ ] **Step 2: Run `swift run SimTests --design-contracts`.** Expect: `cannot find 'tables'` / `'facts'`.
- [ ] **Step 3: Implement.** In `ForgeFieldBudget.swift`:
```swift
/// What a drawn surface reports of itself, from its own `// MARK: - Assertable budget facts`
/// statics. One entry per drawn surface in `ForgeFieldBudget.facts`, beside its budget, so a
/// single test compares every pair by construction rather than one hand-written suite per view.
public struct ForgeFieldSurfaceFacts: Sendable, Equatable {
    public let stageFraction: Double
    public let dataPointCount: Int
    public let goldElementCount: Int
    public let emberElementCount: Int
    public let ghost: ForgeFieldBudget.Ghost?
    public let backgroundCount: Int

    public init(stageFraction: Double, dataPointCount: Int, goldElementCount: Int,
                emberElementCount: Int, ghost: ForgeFieldBudget.Ghost?, backgroundCount: Int) {
        self.stageFraction = stageFraction
        self.dataPointCount = dataPointCount
        self.goldElementCount = goldElementCount
        self.emberElementCount = emberElementCount
        self.ghost = ghost
        self.backgroundCount = backgroundCount
    }
}

extension ForgeFieldBudget {
    /// Every family's stamped table. A family absent here has no budget yet, and the coverage
    /// test above fails the day a surface of it registers facts.
    public static let tables: [CoachWorldSurfaceFamily: [CoachWorldScreenID: ForgeFieldBudget]] = [
        .weeklyCommand: weeklyCommand,
        // 2C adds `.personnel: personnel`, 2D `.recruiting: recruiting`, 2E `.proManagement:
        // proManagement`, 2F `.league: league`, `.career: career`, `.entry: entry`.
    ]

    /// Every drawn surface's own facts. Weekly command is registered here from the statics each
    /// of its nine views already exposes; 2C to 2F add one line per surface as it lands.
    public static let facts: [CoachWorldScreenID: ForgeFieldSurfaceFacts] = [
        .coachingHQ: ForgeFieldSurfaceFacts(
            stageFraction: CoachingHQView.stageFraction,
            dataPointCount: CoachingHQView.floodFieldDataPoints.count,
            goldElementCount: CoachingHQView.goldElementCount,
            emberElementCount: CoachingHQView.emberElementCount,
            ghost: Ghost(size: CoachingHQView.ghostSize, opacity: CoachingHQView.ghostOpacity, desaturated: false),
            backgroundCount: CoachingHQView.backgroundCount),
        // ... one entry each for .inbox, .opponentReportFilmRoom, .gamePlan, .practicePlan,
        // .teamHealth, .matchDay, .aftermath, .gameDetailBoxScore, reading each view's own
        // statics. Where a view exposes only `hasGhostMark: Bool`, add `ghostSize` and
        // `ghostOpacity` statics to it (from its `XMetric` enum) in this task rather than copying
        // the budget's numbers into the facts.
    ]
}
```
Fill the nine weekly-command entries by reading each view's `Assertable budget facts` extension; do not invent a value — where a view has no `stageFraction` static, add one from its metric enum the way `GameDetailBoxScoreView.stageFraction` is derived.
- [ ] **Step 4: Run the suite green**, then the existing per-surface weekly-command suites (they stay; they are the family's own evidence and are not rewritten in this task).
- [ ] **Step 5: Commit.** `feat(ui): stamp Forge Field budgets and facts for every family, by construction`

### Task S3: The two input primitives

**Files:** Create `Sources/ProFootballCoachUI/ForgeFieldInputs.swift`. Test: `DesignContractTests.swift`.

**Interfaces produced:**
- `ForgeFieldField(text: Binding<String>, placeholder: String, label: String, isFigure: Bool = false)` — 44 pt, ground 3, `Edge.raised` hairline, `Edge.seamHard` when focused, ink 4 placeholder, `.figure` face when `isFigure` else `.row`; `label` is the accessibility label. Assertable statics: `ForgeFieldField.height` (= `Space.rowTouch`), `restingEdge` (= `Edge.raised`), `focusedEdge` (= `Edge.seamHard`).
- `ForgeFieldStepper(value: Binding<Int>, in bounds: ClosedRange<Int>, label: String, unit: String)` — the field shape with `−`/`+` 44 pt targets at the ends and `"\(bounds.lowerBound) to \(bounds.upperBound) \(unit)"` in ink 4 beneath; clamps to `bounds`; the `−` (U+2212) and `+` are text glyphs `04` 6.3a(i) names, not an icon set. Assertable statics: `ForgeFieldStepper.height` (= `Space.rowTouch`), `controlWidth` (= `Space.hitMin`).

- [ ] **Step 1: Write the failing tests.**
```swift
    suite("Forge Field inputs (06.3a(i))") {
        test("a field and a stepper are the touch height and nothing smaller") {
            expectEqual(ForgeFieldField.height, ForgeFieldTokens.Space.rowTouch)
            expectEqual(ForgeFieldStepper.height, ForgeFieldTokens.Space.rowTouch)
            expectEqual(ForgeFieldStepper.controlWidth, ForgeFieldTokens.Space.hitMin)
        }
        test("focus steps the hairline from raised to hard and nowhere else") {
            expectEqual(ForgeFieldField.restingEdge, ForgeFieldTokens.Edge.raised)
            expectEqual(ForgeFieldField.focusedEdge, ForgeFieldTokens.Edge.seamHard)
        }
        test("no surface uses platform text-field or stepper chrome") {
            let offenders = swiftFiles(under: "Sources/ProFootballCoachUI").filter {
                !$0.path.hasSuffix("/ForgeFieldInputs.swift")
                    && ($0.text.contains(".textFieldStyle(") || $0.text.contains("Stepper("))
            }
            expect(offenders.isEmpty,
                   "platform chrome on a floodlit ground: \(offenders.map(\.path).sorted())")
        }
    }
```
The third test fails until 2D (Shortlist), 2E (Negotiation) and 2F (World search, Settings, Coach identity) convert their inputs. **It stays red across 2S; that is the point** — record it in STATUS as red-by-design with the list of files, and it goes green as the families land.
- [ ] **Step 2: Run and watch them fail.**
- [ ] **Step 3: Implement** with `@FocusState`, `TextField` (the platform control is fine; its **style** is not) drawn `.plain`, every colour from the club palette, every size from `ForgeFieldTokens`/`ForgeFieldType`. The stepper's bounds line is `ForgeFieldType.Step.figure` in ink 4.
- [ ] **Step 4: Run `swift build` and the first two tests green.**
- [ ] **Step 5: Commit.** `feat(ui): add the Forge Field field and stepper`

### Task S4: One formatter for money, thousands and the calendar

**Files:** Create `Sources/ProFootballCoachUI/ForgeFieldFormat.swift`. Test: `DesignContractTests.swift`.

**Interfaces produced:** `enum ForgeFieldFormat { static func money(_ dollars: Int) -> String; static func thousands(_ value: Int) -> String; static func calendar(_ state: CalendarState) -> String }`.

- [ ] **Step 1: Write the failing tests.**
```swift
    suite("Forge Field figure formatting (06.2a(ii))") {
        test("money abbreviates at scale and never prints digit soup") {
            expectEqual(ForgeFieldFormat.money(291_949_500), "$291.95M")
            expectEqual(ForgeFieldFormat.money(5_418_000), "$5.42M")
            expectEqual(ForgeFieldFormat.money(795_000), "$795K")
            expectEqual(ForgeFieldFormat.money(4_800), "$4,800")
            expectEqual(ForgeFieldFormat.money(800), "$800")
            expectEqual(ForgeFieldFormat.money(0), "$0")
            expectEqual(ForgeFieldFormat.money(-1_500_000), "-$1.50M")
        }
        test("thousands separate") {
            expectEqual(ForgeFieldFormat.thousands(2418), "2,418")
            expectEqual(ForgeFieldFormat.thousands(999), "999")
        }
        test("a calendar prints one-based, with both units") {
            expectEqual(ForgeFieldFormat.calendar(CalendarState(season: 1, week: 13)), "season 2, week 14")
        }
        test("no view interpolates a raw dollar figure") {
            let offenders = swiftFiles(under: "Sources/ProFootballCoachUI").filter {
                !$0.path.hasSuffix("/ForgeFieldFormat.swift") && $0.text.contains("\"$\\(")
            }
            expect(offenders.isEmpty, "raw \"$\\(value)\" in: \(offenders.map(\.path).sorted())")
        }
    }
```
The fourth test is red until 2E converts the four `currency(_:)` copies; record it with S3's red test.
- [ ] **Step 2: Run and watch them fail.**
- [ ] **Step 3: Implement** with integer arithmetic (money is `Int` dollars; no `Double` currency): divide by 1_000_000 / 1_000 with two-decimal rounding done on integers, `NumberFormatter` with `groupingSeparator` for thousands (locale fixed to `en_US_POSIX` — the beta is English-only, `04` §6 Settings states it). `calendar` is `"season \(state.season + 1), week \(state.week + 1)"` — check `CalendarState`'s own doc comment for whether `week` is zero-based before hard-coding the `+ 1`; if it is one-based, drop it and fix the test's expectation, and say so in the commit body.
- [ ] **Step 4: Run green.**
- [ ] **Step 5: Commit.** `feat(ui): add the Forge Field money, thousands and calendar formatter`

### Task S5: The ghost mark, once

**Files:** Modify `Sources/ProFootballCoachUI/ForgeFieldPrimitives.swift`. Test: `DesignContractTests.swift`.

Seven surfaces in 2C–2F carry a ghost and Coaching HQ, Aftermath, Practice plan, Team health and Opponent report each draw the same six modifiers inline. One helper, so the desaturation, hit-testing and accessibility rules cannot drift.

**Interface produced:** `ForgeFieldGhostMark(team: CoachWorldTeamReference, ghost: ForgeFieldBudget.Ghost, surface: CoachWorldTokens.ColorValue)` — `CoachWorldTeamLogo(team:dimension:surface:)` at `ghost.size`, `.saturation(ghost.desaturated ? 0 : ForgeFieldTokens.Register.ghostSaturate)`, `.opacity(ghost.opacity)`, `.allowsHitTesting(false)`, `.accessibilityHidden(true)`. The caller positions it (which edge or corner it bleeds is the sheet's per-surface stamp).

- [ ] **Step 1: Failing test.**
```swift
    suite("Forge Field ghost mark (06.1e, spec 2.7)") {
        test("every ghost in the product is drawn by the one helper") {
            let offenders = swiftFiles(under: "Sources/ProFootballCoachUI").filter {
                !$0.path.hasSuffix("/ForgeFieldPrimitives.swift")
                    && $0.text.contains("Register.ghostSaturate")
            }
            expect(offenders.isEmpty, "inline ghost in: \(offenders.map(\.path).sorted())")
        }
        test("a ghost is never a tap target and never spoken") {
            let source = swiftFiles(under: "Sources/ProFootballCoachUI")
                .first { $0.path.hasSuffix("/ForgeFieldPrimitives.swift") }?.text ?? ""
            expect(source.contains("allowsHitTesting(false)") && source.contains("accessibilityHidden(true)"))
        }
    }
```
- [ ] **Step 2: Run; fails on the five inline ghosts.**
- [ ] **Step 3: Implement the helper; convert the five 2B call sites to it** (same values, no visual change — confirm by rendering Coaching HQ before and after).
- [ ] **Step 4: Green. Commit.** `refactor(ui): draw every Forge Field ghost mark through one helper`

### Phase 2S exit

- [ ] `swift build` green; `--design-contracts` green except the two red-by-design scans (S3 step 1 test 3, S4 step 1 test 4), listed by file in `docs/STATUS.md`.
- [ ] `--core-contracts` green.
- [ ] Coaching HQ re-rendered after S5 and looked at; unchanged.
- [ ] Ledger rows **E45** (canon amendments), **E46** (budget contract generalised), **E47** (inputs), **E48** (formatter), **E49** (ghost helper). **Ask the owner before any push.**

---

## Phases 2C to 2F — the families

Each is its own file, written against its sheet:

| Phase | Plan | Surfaces | Sheet |
|---|---|---|---|
| 2C | `docs/plans/2026-09-06-forge-field-phase-2c-personnel.md` | Roster, Depth chart, Player profile, Development, Staff room (+ aliases 21, 22, 23) | `Game screens - Personnel.dc.html` |
| 2D | `docs/plans/2026-09-06-forge-field-phase-2d-recruiting.md` | Board, Prospect, Shortlist, Visits, Class, Signing day, College offseason (+ aliases 30–33) | `Game screens - Recruiting.dc.html` |
| 2E | `docs/plans/2026-09-06-forge-field-phase-2e-pro-management.md` | Cap & contracts, Negotiation, Roster cuts, Draft room, Pro front office (+ aliases 37, 38, 40) | `Game screens - Pro management.dc.html` |
| 2F | `docs/plans/2026-09-06-forge-field-phase-2f-league-career-entry.md` | World search, Map, Team profile, Standings, Schedule, Rankings, Bracket, Statistics, Awards, News, Realignment; Opportunities, Stakeholders, Promotion, Record book, Rivalries, Career line, Coaching tree, Title, Settings; Coach identity | `Game screens - League, career and entry.dc.html` |

**They are independent.** Run them in any order, or in parallel worktrees (`superpowers:using-git-worktrees`), harvested onto `main` and deleted. **Each family plan's Task 1 stamps its budget table**, and each surface task registers its facts; the 2S generic suite then holds the family to its sheet from the first commit.

### The per-surface procedure every family plan uses

Written once here; each family plan restates it in full at its top so a task can be executed without this file open.

1. Read the surface's spec column in its family plan (transcribed from the sheet): register, budgets, geometry as `name · x,y · w×h · cols`, type, tokens, data bindings, and "what has to be written".
2. Read the surface's row in `docs/reviews/2026-08-22-all-screen-presentation-contract.md`. **Every fact the sheet draws that the row's model does not hold is an ask**: it is not drawn, its absence is stated where the voice rule wants one (`unseen`, "No contact recorded"), and it is listed in the family's ledger ask row.
3. Register the surface's facts in `ForgeFieldBudget.facts` from a new `// MARK: - Assertable budget facts` extension; run `--design-contracts` and watch the generic suite fail on the unregistered or unbudgeted surface.
4. Draw the surface inside `ForgeFieldDevice(club:)` from the primitives, `ForgeFieldChromeBar` (where the register has one), `ForgeFieldEmber`, `ForgeFieldGhostMark`, `ForgeFieldField`/`ForgeFieldStepper`, `ForgeFieldFormat` and `ForgeFieldType.font(_:)`; every number in a `private enum XMetric` with its sheet source in a comment. Keep every callback and accessibility identifier the view already has. Standard composition **and** `isAccessibilitySize` composition.
5. `swift build`; `--design-contracts`; `--core-contracts`. Green (except the two red-by-design scans until their families land).
6. Render: `PROOF_SCREEN_NUMBER=<id>` on a booted iPhone 17e at standard size and at `accessibility-extra-extra-extra-large`; screenshot; **look at it against the drawing**. Check the five recurring fault classes (handoff §7): collision when an optional element is absent; long generated names; `lineLimit(1)` at AX5; a short column clipping a long label at standard size; a fixed width against the real hosting width (761 pt, not 832).
7. Commit, one per surface; every adaptation-rule deviation in the commit body **and** a ledger Part E row.

### The render loop

```bash
cd App && xcodegen generate
xcodebuild -project ProFootballCoach.xcodeproj -scheme ProFootballCoach \
  -destination 'platform=iOS Simulator,id=7082DFE5-3BFB-4073-859B-83E95B35531B' \
  -configuration Debug -derivedDataPath /private/tmp/pfc-dd build
xcrun simctl install 7082DFE5-3BFB-4073-859B-83E95B35531B /private/tmp/pfc-dd/Build/Products/Debug-iphonesimulator/ProFootballCoach.app
SIMCTL_CHILD_PROOF_SCREEN_NUMBER=16 xcrun simctl launch --terminate-running-process 7082DFE5-3BFB-4073-859B-83E95B35531B com.ericmg.ProFootballCoach
xcrun simctl io 7082DFE5-3BFB-4073-859B-83E95B35531B screenshot /private/tmp/raw.png && sips -r -90 /private/tmp/raw.png --out /private/tmp/view.png
xcrun simctl ui 7082DFE5-3BFB-4073-859B-83E95B35531B content_size accessibility-extra-extra-extra-large   # then screenshot again
xcrun simctl ui 7082DFE5-3BFB-4073-859B-83E95B35531B content_size medium                                   # reset
```
`PROOF_SCREEN_NUMBER` is read by `CoachWorldAppRootView` (`#if DEBUG`) after a new career starts; `simctl launch` forwards any shell variable prefixed `SIMCTL_CHILD_` to the app's environment, which is how the override reaches it. Screens 1 and 2 (Entry) need no override — they are what launches before a career exists.

---

## Phase 2G and Phase 2H

`docs/plans/2026-09-06-forge-field-phase-2g-retirement-and-2h-audit.md`. **Entry criterion for 2G: 2C, 2D, 2E and 2F all merged.** 2H follows 2G.

## Phase 2I and Phase 2J

`docs/plans/2026-09-06-forge-field-phase-2i-completion-and-2j-release-candidate.md`. **2I runs in parallel with 2C–2F** — it owns the engine, the providers, the read models and the suites, and touches a family's view file only in its closing task, after that family has merged — and it is an **entry criterion for 2H alongside 2G**, because the audit must score surfaces whose recorded asks have become facts. It carries everything the 2026-09-06 review of the game and its documentation found outstanding that is not a drawing: the four families' ask rows and E24/E25, the AI cut path and dead money, professional turnover, the controlled club's cap decision, the game plan and match controls canon promises, the calibration gate, the week-advance ceiling, save migration fixtures, D9 onboarding, the release gates that exist only as names, and the canon that no longer matches the build. Its decisions continue this file's table as FF-9…FF-18, each with a default.

**2J follows 2H** and is the release candidate: every machine gate on one recorded commit, release hygiene, and the owner's hardware pack prepared. **At 2J's exit the game requires only human testing approval, the `docs/PRE-DEPLOYMENT-CHECKLIST.md` §4a owner-only distribution gates, and the final legal sweep.**

---

## Verification, every phase

```
swift build
swift run SimTests --design-contracts     # fast
swift run SimTests --core-contracts       # minutes
swift run SimTests                        # FULL: phase exit only, roughly 3.5 hours, ~1,300 tests
```
Never say "build green" or "verified" about anything a compiler has not seen (`CLAUDE.md`). Never report an adversarial review as a build.
