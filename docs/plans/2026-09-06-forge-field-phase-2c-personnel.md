# Forge Field Phase 2C — Personnel

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** draw the five personnel surfaces — Roster, Depth chart, Player profile, Development, Staff room — to the Forge Field sheet, on the 2A shell and the 2S contract.

**Architecture:** the family's budget table first (one commit, enumerated by construction from `CoachWorldSurfaceFamily.personnel.surfaces`), then one surface per task in the sheet's order. Every surface is a `ForgeFieldDevice` composition built from the primitives, registers its own `ForgeFieldSurfaceFacts`, and ends on a render. The three alias ids (21 Staff market, 22 Scheme book, 23 Personnel packages) are not drawn: `routeDisposition` already resolves them, and the sheet's product decisions about them are recorded, not made.

**Tech Stack:** iOS 26+, Swift 5.10 language mode, SwiftUI.

**Spec:** `Game screens - Personnel.dc.html` (Forge Field project `8c511c92-3337-4cfb-850c-140a659f3034`), transcribed per surface below. Batch 2 of 7 · 8 ids · 5 surfaces · drawn on Binghamton, hue 288. **Where this plan and the sheet disagree on a number, the sheet is right** — except under the adaptation rule and except where the presentation contract forbids the fact.

**Canon:** `04` 6.1e, 6.1e(i), 6.1f, 6.2a, 6.2a(i), 6.2a(ii), 6.3a, 6.3a(i), 6.6a, 6.7a, 7. **Contract:** rows 16–20 of `docs/reviews/2026-08-22-all-screen-presentation-contract.md`. **Ledger:** Part E; this phase appends rows (take the next free numbers at merge; 2C–2F land in parallel).

**Entry criterion:** Phase 2S merged (`ForgeFieldBudget.tables`/`.facts`, `ForgeFieldGhostMark`, `ForgeFieldFormat`).

**Parallel worktree:** yes — runs beside 2D, 2E, 2F and 2I. Merge surface: `ForgeFieldBudget.swift` (additive), this family's five view files, ledger and STATUS. Roadmap §Running phases as parallel worktree sessions.

## Global Constraints

Everything in `docs/plans/2026-09-06-forge-field-remaining-roadmap.md`'s Global Constraints, its carried rulings and its owner-decision defaults applies unchanged. Specific to this family, from the sheet:

- **One club, one squad.** Bishop has to be followable from the table to his dossier to his development line without the grounds moving under him: every surface resolves the same club (`ForgeFieldTokens.Club.resolved(for: chrome?.club ?? model.team)`).
- **Columns are fixed for the family**: the roster's `34 / 256 / 46 / 30 / 128 / 40 / 40 / 46 / 108` at 10 pt gutters, and the development ledger's `30 / 150 / 44 / 74 / 36 / 40 / 374`, so a row does not reflow between roster, depth chart and development.
- **The 200 pt staged rail** (depth chart's unit rail, staff room's person column) is one measurement for the family, not one per surface.
- **A delta is not a status.** `+1` and `−1` stay in ink 1; tinting them would spend two of the four signals on a figure that carries its own sign.
- **Contract omissions bind in full** (rows 16–20): no roster search, filtering, derived ranking or position-specific analysis; no invented role or vacancy on the depth chart, no recommendation, no ranking of occupants; no projection, comparison or derived grade on the profile; no editable allocation or projected trajectory on development; no delegation chip, hire, fire or negotiation on the staff room.

---

## The per-surface procedure

Every surface task (Tasks 2–6) follows these steps. They are restated here so a task can be run with only this file open.

1. **Read the surface's transcribed spec column below** — register, budgets, geometry as `name · x,y · w×h · cols`, type, tokens, data bindings, and the sheet's "what has to be written".
2. **Read the surface's contract row.** Every fact the sheet draws that the model does not hold is an ask: not drawn, its absence stated where the voice rule wants one (`unseen`), and listed in Task 7's ledger row.
3. **Register the surface's facts.** Add its `// MARK: - Assertable budget facts` extension (given per task) and the `ForgeFieldBudget.facts` line; run `swift run SimTests --design-contracts` and watch "every budgeted surface reports facts" or "facts sit inside its stamped budget" fail.
4. **Draw it** inside `ForgeFieldDevice(club:)` from `ForgeFieldChromeBar`, `ForgeFieldPanel`, `ForgeFieldSeam`, `ForgeFieldRow`, `ForgeFieldChip`, `ForgeFieldEmber`, `ForgeFieldGhostMark`, `ForgeFieldField`/`ForgeFieldStepper`, `ForgeFieldFormat` and `ForgeFieldType.font(_:)`. Every number lives in a `private enum XMetric` with its sheet source in a comment. Keep every callback, `@State`, sheet presentation and accessibility identifier the existing view has. **The ember's `cost:` argument is always a named `private var emberCost: String`** — the expressions given in each task's rulings are that var's body — because `DesignContractTests`' cost-argument scan accepts only a string literal or a bare name (and a literal must not contain a comma). Write the standard composition **and** the `dynamicTypeSize.isAccessibilitySize` composition (one scroll column: chrome → staged → seam → studied; every `lineLimit(1)` lifted via a `lineLimit(for:)` helper).
5. **`swift build`, `--design-contracts`, `--core-contracts`.** Green (the two 2S red-by-design scans excepted until their families land).
6. **Render** with the roadmap's render loop, `PROOF_SCREEN_NUMBER=<id>`, at standard size and at `accessibility-extra-extra-extra-large`. Look at it against the drawing. Check handoff §7's five fault classes.
7. **Commit**, one per surface; deviations in the commit body and as a ledger row.

---

## Task 1: The personnel budget table

**Files:** Modify `Sources/ProFootballCoachUI/ForgeFieldBudget.swift`. Test: the 2S generic suite (`Forge Field budgets, every family`).

**Interfaces produced:** `ForgeFieldBudget.personnel: [CoachWorldScreenID: ForgeFieldBudget]`, registered in `ForgeFieldBudget.tables[.personnel]`.

The five, transcribed from the sheet's "Register & budget" columns:

| Screen | Register | Stage | Points | Gold | Ember | Ghost | Backgrounds |
|---|---|---|---|---:|---:|---|---:|
| 16 Roster | Desk, table-led, one committing control | 22% · 88 of 393 | 64 of 80 | 0 | 1 · Advance week | 0 · no field free of figures | 2 of 2 |
| 17 Depth chart | Desk, diagram-led, one committing control | 23% · 200 of 852 wide (vertical seam) | 71 of 80 | 0 | 1 · the plan switch | 0 · the field is the graphic | 2 of 2 |
| 18 Player profile | Dossier, identity-led, readout only | 35% · 300 of 852 wide | 41 (Dossier has no cap) | 0 of 2 | 0 · a dossier commits nothing | 260 · .13 · bottom-left | 2 of 2 |
| 19 Development | Desk, ledger, readout only | 15% · 60 of 393 | 58 of 80 | 0 | 0 · nothing here writes | 0 · tabular figures across the panel | 2 of 2 |
| 20 Staff room | Desk, people-led, readout only | 23% · 200 of 852 wide | 47 of 80 | 0 | 0 · there is nothing to commit | 0 · 200 pt column, ghost floor is 230 | 2 of 2 |

- [ ] **Step 1: Add the table** (the generic suite is the failing test: `tables[.personnel]` is absent, and after this step `facts` lacks the five, which is the red state Tasks 2–6 each turn green one at a time):
```swift
extension ForgeFieldBudget {
    /// The five personnel surfaces' stamped budgets, `Game screens - Personnel.dc.html`. Every
    /// number transcribed; nothing invented.
    public static let personnel: [CoachWorldScreenID: ForgeFieldBudget] = [
        .roster: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: nil, detail: "table-led, one committing control"),
            stageFraction: 0.22...0.22, dataPoints: 64, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface, ghost: nil, backgrounds: 2),
        .depthChart: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: nil, detail: "diagram-led, one committing control, vertical seam"),
            stageFraction: 0.23...0.23, dataPoints: 71, pointsAboveSeam: nil,
            // The sheet's ember is "Heavy 12": the option that is not the current plan. Row 17
            // gives this surface `onSelect(PersonnelPlan)` and `Option.consequence`, which is a
            // recorded cost in the coordinator's voice, so the ember is real -- generalised in
            // Task 3 to one SWITCH control for whichever non-current option is selected.
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface, ghost: nil, backgrounds: 2),
        .playerProfile: ForgeFieldBudget(
            register: RegisterStamp(lean: .dossier, tone: .readout, detail: "identity-led"),
            stageFraction: 0.35...0.35, dataPoints: 41, pointsAboveSeam: nil,
            goldMax: ForgeFieldTokens.Register.goldMaxDossier, emberCount: 0,
            ghost: Ghost(size: 260, opacity: ForgeFieldTokens.Register.ghostOpacity, desaturated: false),
            backgrounds: 2),
        .developmentPlan: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: .readout, detail: "ledger"),
            stageFraction: 0.15...0.15, dataPoints: 58, pointsAboveSeam: nil,
            goldMax: 0, emberCount: 0, ghost: nil, backgrounds: 2),
        .staffRoom: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: .readout, detail: "people-led, vertical seam"),
            stageFraction: 0.23...0.23, dataPoints: 47, pointsAboveSeam: nil,
            goldMax: 0, emberCount: 0, ghost: nil, backgrounds: 2),
    ]
}
```
and in `tables`, the line `.personnel: personnel,`.
- [ ] **Step 2: Run `swift run SimTests --design-contracts`.** Expect "every budgeted surface reports facts" to fail naming the five personnel screens. That is the correct red state.
- [ ] **Step 3: Commit.**
```bash
git add Sources/ProFootballCoachUI/ForgeFieldBudget.swift
git commit -m "feat(ui): stamp the personnel register budgets as a contract"
```

---

## Task 2: Roster (16)

**Files:** Rewrite `Sources/ProFootballCoachUI/RosterView.swift` (36 KB today; keep its `init`, `@State selectedPlayerID`, `sort`, `presentedProfile`, `showsRecruitingBoard`, `showsAcademicYear`, the `.sheet(item:)` to `PlayerProfileView`, and the `onChange` that re-seeds selection). Modify `ForgeFieldBudget.swift` (`facts[.roster]`).

**Consumes:** `RosterReadModel` (`team`, `coach`, `seasonLabel`, `weekLabel`, `recordLabel`, `rankLabel`, `rosterLimit`, `injuryCount`, `openNeedCount`, `players[]`, `canContinue`, `continueReason`); `RosterSortDescriptor`; callbacks `onContinue`, `onNavigate`, `onInspectDevelopment`, `onOpenProfile`, `onNavigateChrome`.

### Spec column (transcribed)

**Register & budget:** Desk, table-led · stage 22% · 88 of 393 · cap 25% · data points 64 of 80 · largest numeral 34 · gold 0 · ember 1 of 1 (Advance week) · ghost 0 · backgrounds 2 of 2 (ground 1, ground 2).

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Chrome bar | 10, 8 | 832 × 30 | 1–12 |
| Subject strip | 10, 44 | 832 × 88 | 1–12 |
| Seam · hard | 10, 140 | 832 × 1 | 1–12 |
| Group rail (sheet) | 10, 148 | 832 × 32 | 1–12 |
| Table | 10, 188 | 832 × 195 | 1–12 |
| Row × 4 | —, 207 | 808 × 44 | — |
| Ember | 632, 66 | 198 × 44 | — |

Horizontal seam at y 140: above it the one player this surface is about, below it the eighty-five it lists. Every gap is 8. Columns `34 / 256 / 46 / 30 / 128 / 40 / 40 / 46 / 108` at 10 pt gutters (= 808).

**Type:** subject name 26 `.heading` (-.01em → `.heading`'s own tracking); overall 34 mono → `.title` face is display; the sheet wants mono, so draw it in `.figure`'s family at 34 — **there is no 34 mono step**: `04` 6.2a's steps are the list; use `.title` (34, display, tabular via `.monospacedDigit()`), and record the substitution; condition 19 mono → `.panel` with `.monospacedDigit()`; row label 13.5 `.row`; row figures 11 `.figure`; overall-in-row 13.5 mono → `.row` + `.monospacedDigit()`; role 11.5 → `.proseMin` (12); column heads → `.columnHead` (10); ember cost → `ForgeFieldEmber.costStep`.

**Tokens:** device ground `ground1`; strip and table `ground2` with `Edge.panel`; row band alternating on rows 2 and 4 (`ground3` at the panel's own alpha is the house `--band-row`; there is no band token yet — draw rows 2 and 4 on `ground3`, and note it in `04` 6.3a if it survives review); active row `inset 2px 0 0 ember` (a 2 pt ember spine on the leading edge — `ForgeFieldTokens.Space.ladder[0]` is 4; the sheet's 2 is off-ladder → ship at the hairline width ×2 = 2 via `Edge.hairlineWidth * 2`, named `RosterMetric.activeSpine`); number plate `club` fill (identity, legal); seam `.hard`.

**Data:** `players.count / rosterLimit` → "78 of 85"; `injuryCount` → "2 injured"; `openNeedCount` → "3 open needs"; row: `number`, `person.name`, `position`, `academicYear`, `rosterRole`, `overall`, `developmentDelta` (nil renders `unseen`), `condition`, `availability`, `schemeFit`; tap a row → `onOpenProfile(stableID)` (screen 18, plate lift 240 ms) or, when `onOpenProfile` is nil, the existing `presentedProfile` sheet; Advance week → `onContinue()`, disabled on `!canContinue`.

### Rulings for this surface

1. **The group rail is not drawn.** Contract row 16: *no filtering, no position-specific analysis*. The rail's `All · Offence · Defence · Special` counts are a unit classification the model does not hold and a filter the contract forbids. Its 32 + 8 pt go to the table: **table `10, 148` `832 × 235`**. Recorded as an ask (`RosterFilter`).
2. **Sorting stays, on a 44 pt head row.** `RosterSortDescriptor` has six fields and the existing view sorts; the sheet says the sorted column is stated in words and its head lifts to ink 2. Column heads are tappable to change the sort field (re-tap flips direction), so the head row is 44, not 19 — adaptation rule, tap target. Table: head 44 + 4 × 44 = 220 ≤ 235; the fifth row onward scrolls, and the head row's trailing cell reads `sorted by overall, high first` (words, from `sort.field`/`isAscending`; no caret — the glyph budget has none).
3. **The ember is Advance week**: `ForgeFieldEmber(label: "ADVANCE WEEK", cost: emberCost, isEnabled: model.canContinue, action: onContinue)` with `emberCost = model.continueReason ?? "\(model.openNeedCount) OPEN NEEDS"` — the Inbox/HQ `"\(count) DUE"` shape: a recorded figure naming what advancing leaves undone. Not the sheet's `closes personnel · final`, which names nothing the model records.
4. **The subject strip is the selected player** (`selectedPlayer`, first by default): number plate 44 (`club` fill, `.chrome` numeral in `ink1`), name `.heading`, `position · academicYear · rosterRole` in `.proseMin`, then Overall / Condition / Scheme fit / Availability as label-over-figure pairs, then the three squad counts. Long generated names: `.lineLimit(1)` + `.minimumScaleFactor(RosterMetric.nameScaleFloor)` (0.8, the box-score precedent) at standard size; unlimited at AX5.
5. **Rows are 44** — every row opens a dossier. `developmentDelta` prints `+1` / `0` / `−1` (U+2212) in ink 1, `unseen` in ink 4 when nil.
6. **`worldStrip` and `personnelRoutes` (drawn today only when `chrome == nil`) stay**, drawn only when `chrome == nil`, re-skinned to `.row`/`.columnHead` on `ground2` — the bare stage still needs a way sideways.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension RosterView {
    /// Facts drawn once in the subject strip. The chrome bar's furniture is excluded (2B convention).
    public static let subjectDataPointRoles: [String] = [
        "subject.number", "subject.name", "subject.position", "subject.year", "subject.role",
        "subject.overall", "subject.condition", "subject.schemeFit", "subject.availability",
        "squad.count", "squad.limit", "squad.injured", "squad.openNeeds",
    ]
    /// Facts drawn once per visible row; the standard table exposes four before scrolling.
    public static let rowDataPointRoles: [String] = [
        "row.number", "row.name", "row.position", "row.year", "row.role",
        "row.overall", "row.developmentDelta", "row.condition", "row.availability",
    ]
    public static let referenceVisibleRowCount = 4
    public static let dataPointCount = subjectDataPointRoles.count + rowDataPointRoles.count * referenceVisibleRowCount   // 13 + 36 = 49 of 64
    public static let stageFraction = Double(RosterMetric.subjectStripHeight / ForgeFieldTokens.Space.viewport.height)   // 88 / 393
    public static let goldElementCount = 0
    /// One `ForgeFieldEmber(` call site -- ADVANCE WEEK.
    public static let emberElementCount = 1
    /// The device's `ground1` and the strip/table `ground2`.
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```
and `ForgeFieldBudget.facts`: `.roster: RosterView.facts,`.

### Composition skeleton (the family's shape; Tasks 3–6 follow it)

```swift
public var body: some View {
    ForgeFieldDevice(club: club) {
        Group {
            if dynamicTypeSize.isAccessibilitySize { accessibleComposition } else { standardComposition }
        }
        .frame(width: ForgeFieldTokens.Space.viewport.width, height: ForgeFieldTokens.Space.viewport.height)
        .background(club.palette.ground1.color)
    }
    .accessibilitySortPriority(100)
    .onChange(of: model.players.map(\.stableID), initial: true) { _, ids in
        if !ids.contains(selectedPlayerID) { selectedPlayerID = ids.first ?? "" }
    }
    .sheet(item: $presentedProfile) { profile in
        PlayerProfileView(model: profile, team: model.team, onClose: { presentedProfile = nil },
                          onInspectDevelopment: onInspectDevelopment)
    }
}

private var standardComposition: some View {
    VStack(alignment: .leading, spacing: .zero) {
        chromeBarRegion            // 10,8 · 832×30 -- the GameDetailBoxScoreView pattern
        subjectStrip               // 10,44 · 832×88, ember at its trailing edge (632,66 · 198×44)
            .frame(height: RosterMetric.subjectStripHeight)
        ForgeFieldSeam(.hard, axis: .horizontal).padding(.vertical, RosterMetric.gap)   // y 140
        rosterTable                // 10,148 · 832×235: 44 head + 4×44 rows, then scroll
        Spacer(minLength: .zero)
    }
    .padding(.horizontal, ForgeFieldTokens.Space.margin)
}

private var accessibleComposition: some View {
    ScrollView {
        VStack(alignment: .leading, spacing: RosterMetric.gap) {
            chromeBarRegion; subjectStrip; ForgeFieldSeam(.hard, axis: .horizontal); rosterTable
        }
        .padding(.horizontal, ForgeFieldTokens.Space.margin)
    }
}

private enum RosterMetric {
    static let subjectStripHeight: CGFloat = 88          // sheet: subject strip 832 × 88
    static let gap = ForgeFieldTokens.Space.ladder[1]     // 8 -- "every gap is 8"
    static let columns: [CGFloat] = [34, 256, 46, 30, 128, 40, 40, 46, 108]   // sheet, fixed for the family
    static let emberWidth: CGFloat = 198                  // sheet: ember 198 × 44
    static let activeSpine = ForgeFieldTokens.Edge.hairlineWidth * 2
    static let nameScaleFloor = 0.8                       // adaptation rule; GameDetailBoxScoreView precedent
    static func lineLimit(for size: DynamicTypeSize) -> Int? { size.isAccessibilitySize ? nil : 1 }
}
```

- [ ] **Step 1: Read the spec column, the contract row 16, and today's `RosterView.swift` in full.**
- [ ] **Step 2: Register the facts (code above); run `--design-contracts`; watch the generic suite fail** ("facts sit inside its stamped budget" cannot yet find `RosterMetric`, or the coverage test names `.roster` — either is the red).
- [ ] **Step 3: Draw the surface** per the rulings and skeleton. Delete every `CoachWorldTokens` read from the file (71 today); the design-token-literal scan holds.
- [ ] **Step 4: `swift build`; `--design-contracts`; `--core-contracts`.** The ContractTests that assert Roster's accessibility identifiers and reachability must still pass; if one names a retired element, amend it in this commit and say why.
- [ ] **Step 5: Render** `PROOF_SCREEN_NUMBER=16`, standard and AX5. Check: a week-one save with `openNeedCount == 0` (`0 OPEN NEEDS` is a legal under-spend); a roster under four players (the table shows what exists, no empty rows); the longest generated name in the subject strip.
- [ ] **Step 6: Commit.** `feat(ui): draw Roster to the Forge Field sheet` — body lists rulings 1–3 as deviations.

---

## Task 3: Depth chart (17)

**Files:** Rewrite `Sources/ProFootballCoachUI/DepthChartView.swift` (keep `init`, `onSelect`, `onClose`, any `@State` selection). Modify `ForgeFieldBudget.swift` (`facts[.depthChart]`).

**Consumes:** `DepthChartReadModel` (`team`, `weekLabel`, `currentPlan: PersonnelPlan?`, `positions[]` of `PositionGroup { title, slots[] }`, `Slot { id, playerID, playerName, person, number, availability, isStarter, isUnavailable, isOverride }`, `options[] { title, plan, consequence }`); `onSelect(PersonnelPlan)`, `onClose`, `onNavigateChrome`. Alias 23 (Personnel packages) renders this view with a title, unchanged.

### Spec column (transcribed)

**Register & budget:** Desk, diagram-led · stage 23% · 200 of 852 wide · cap 25% · data points 71 of 80 · largest numeral 26 (the plan name) · gold 0 · ember 1 of 1 · ghost 0 (the field is the graphic) · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Unit rail | 10, 44 | 200 × 151 | 1–3 |
| Current plan | 10, 203 | 200 × 100 | 1–3 |
| Vacancy | 10, 311 | 200 × 72 | 1–3 |
| Seam · vertical | 218, 44 | 1 × 339 | — |
| Field | 227, 44 | 615 × 148 | 4–12 |
| Slot list | 227, 200 | 300 × 183 | 4–7 |
| Plan list | 536, 200 | 306 × 183 | 8–12 |
| Plate × 11 | —, 108/140 | 26 × 26 | — |

Vertical seam at x 218: left of it what you have chosen, right of it what it does to the field. The reference's separate vacancy strip along the bottom is not drawn (a second horizontal band under a vertical seam); the vacancy is stated three times instead — chrome meta, left panel, and an alarm spine on the unfilled row.

**Type:** plan name 26 `.heading`; unit and slot names 13.5 `.row`; plate numerals 11 `.figure`; consequence → `.proseMin`; slot label → `.columnHead`; ember label 14 `.chrome` at `Tracking.chrome`; field caption 10 mono → `.figure` (11; data, not prose).

**Tokens:** panels `ground2` + `Edge.panel`; vacancy panel `Edge.alarm` (0.44); plates `ground3` + `Edge.raised`; the QB plate `club` fill — the only club fill; hatch: 45° repeating lines in `signalAlarm` at .18 for a vacancy; yard lines hairline at .05, scrimmage at .22; seam `.hard` vertical; the ember row `ember` fill + `shadow-ember` (that is `ForgeFieldEmber`).

**Data:** `positions[].title` → group; `slots[].id` → LT, LG, RG…; `slots[].number`, `.playerName`; `.availability` + `.isUnavailable` → "Limited"; `currentPlan` → the current plan; `options[].title`, `.plan`, `.consequence`; tap the ember → `onSelect(PersonnelPlan)`; `slots.count` filtered on `isUnavailable` → "11 of 11 · 5 of 6".

### Rulings for this surface

1. **The unit rail lists the model's position groups**, not three units. "Offence / Defence / Special" is a classification `DepthChartReadModel` does not hold (contract row 17: *no invented role*). One 32 pt inert dense row per `positions[]` group — `TITLE` in `.row`, `filled of total · n unfilled` in `.figure` — inside the 151 pt panel; if the groups outrun it the panel scrolls and its head says `n groups · scroll`. Nothing is hidden with no affordance saying so.
2. **The field plots the slots the model lists**, at a conventional alignment keyed by `Slot.id` (a static template `[String: CGPoint]` in `DepthChartMetric` for LT, LG, C, RG, RT, QB, RB, FB, TE, WR/X/Z/slot, and the defensive/special ids the provider emits — read `CoachWorldReadModelProvider.swift:291` for the exact id vocabulary before writing the template). A slot id with no template entry is listed in the slot list and not plotted; the field caption says `n of m plotted` when that happens. Plates are 26 × 26, `.figure` numeral, `ground3`; the QB plate `club`; an unfilled slot is a hatched plate. Plates are not tap targets (the slot list is).
3. **Snap share is not drawn.** `71% of snaps` has no field. The current-plan panel states the plan and its consequence line only.
4. **A vacancy is `playerName.isEmpty || isUnavailable`**, and its reason is the `availability` string the model already carries (`Limited`, `Out`), never `Sarr, 2 weeks`. The vacancy panel lists each such slot as `RG · Unfilled` / `LT · Alvarez · Limited`; when none, it states `No vacancy · every slot is filled` in ink 4.
5. **One ember, generalised.** Options are 44 pt rows in the plan list (the current plan marked `current` with a hollow good dot, per 6.6a's "hollow for closed"); tapping a non-current option selects it (`@State selectedOptionID`); one `ForgeFieldEmber(label: selected.title.uppercased(), cost: selected.consequence, isEnabled: selected.plan != model.currentPlan, action: { onSelect(selected.plan) })` sits at the foot of the plan list. With two options this is exactly the sheet's `Heavy 12` ember; with more it is still one. `Option.consequence` is the recorded cost — the sheet's own words: *"already states the cost of a plan in the coordinator's voice."*
6. **Current plan title** = `options.first { $0.plan == model.currentPlan }?.title`, else `unseen` — the model carries the plan value, not its name.
7. **Close** (`onClose`) is a quiet 44 pt control in the chrome region's trailing slot when `chrome == nil`, else the chrome bar carries the way out.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension DepthChartView {
    public static let leftColumnDataPointRoles: [String] = [
        "group.title", "group.filled", "group.total", "plan.title", "plan.consequence", "vacancy.slot", "vacancy.reason",
    ]
    public static let fieldDataPointRoles: [String] = ["plate.number"]
    public static let slotRowDataPointRoles: [String] = ["slot.id", "slot.number", "slot.name", "slot.availability"]
    public static let optionRowDataPointRoles: [String] = ["option.title", "option.consequence"]
    public static let referencePlateCount = 11
    public static let referenceSlotRowCount = 4
    public static let referenceOptionRowCount = 2
    public static let dataPointCount = leftColumnDataPointRoles.count
        + fieldDataPointRoles.count * referencePlateCount
        + slotRowDataPointRoles.count * referenceSlotRowCount
        + optionRowDataPointRoles.count * referenceOptionRowCount              // 7 + 11 + 16 + 4 = 38 of 71
    public static let stageFraction = Double(DepthChartMetric.railWidth / ForgeFieldTokens.Space.viewport.width)   // 200 / 852
    public static let goldElementCount = 0
    public static let emberElementCount = 1
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1: Read the spec column, contract row 17, `DepthChartView.swift` and `CoachWorldReadModelProvider.swift:270–330` (the slot id vocabulary).**
- [ ] **Step 2: Register the facts; run `--design-contracts`; red.**
- [ ] **Step 3: Draw it.** Standard: `HStack` of the 200 pt left column (three panels) · vertical hard seam · right column (`field` over `HStack(slotList, planList)`). AX5: one scroll column — chrome, unit rail, current plan, vacancy, seam, field (fixed 615 × 148 is wider than an AX5 column allows at 761 pt? It is not: 615 < 761 — but it may not scale; the field keeps its size and the column scrolls), slot list, plan list with the ember last.
- [ ] **Step 4: Build and the three suites.**
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=17`.** Check: a plan set whose options number one (the ember is disabled, cost line reads the current plan's consequence); a group with every slot unavailable; AX5 reaches the ember.
- [ ] **Step 6: Commit.** `feat(ui): draw Depth chart to the Forge Field sheet` — body: rulings 1–5.

---

## Task 4: Player profile (18)

**Files:** Rewrite `Sources/ProFootballCoachUI/PlayerProfileView.swift` (keep `init(model:team:onClose:onInspectDevelopment:)`, `ProfileRoute` and its `@State`). Modify `ForgeFieldBudget.swift` (`facts[.playerProfile]`).

**Consumes:** `PlayerProfileReadModel` (`person`, `number`, `position`, `overall`, `academicYear`, `hometown`, `rosterRole`, `availability`, `condition`, `schemeFit`, `staffSummary`, `strengths[]`, `concern`, `attributeGroups[] { title, attributes[] { label, value, confidence } }`, `recentForm[] { opponent, rating }`, `developmentEvidence`, `historyEvidence`); `team: CoachWorldTeamReference`; `onClose`, `onInspectDevelopment(stableID)`, `onNavigateChrome`.

### Spec column (transcribed)

**Register & budget:** Dossier, identity-led · stage 35% · 300 of 852 wide · band 30–40% · data points 41 · gold 0 of 2 (nothing on the model is earned) · ember 0 of 1 (a dossier commits nothing) · ghost 260 · .13 · bottom-left, one corner · backgrounds 2 of 2 · entry: plate lift 240 ms (`ForgeFieldTokens.Motion.plate`; Reduce Motion → 90 ms crossfade).

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Identity plate | 10, 44 | 300 × 339 | 1–4 |
| Dial | 22, 128 | 120 × 120 | — |
| Seam · vertical | 318, 44 | 1 × 339 | — |
| Route bar (sheet) | 327, 44 | 515 × 32 | 5–12 |
| Attributes | 327, 84 | 515 × 147 | 5–12 |
| Attr row × 4 | — | 491 × 32 | — |
| Recent form | 327, 239 | 251 × 144 | 5–8 |
| Staff read | 587, 239 | 255 × 144 | 9–12 |

Vertical seam at x 318: left of it the person, right of it the record of him. The handoff's 340 pt identity column and 150 pt dial were cut to 300 and 120 by the designer. Attribute rows are 32 dense — legal, the whole row is inert.

**Type:** name 34 `.title` (the sheet's `.9` line height → `.title`'s own 1.04; recorded); dial figure 34 → `.title` + `.monospacedDigit()`; attribute label 13.5 `.row`; attribute value → `.row` + `.monospacedDigit()`; staff summary 12.5 `.prose`; concern → `.proseMin`; confidence 10 mono → `.figure` (11; the 10 mono step does not exist); route labels → `.columnHead`.

**Tokens:** identity plate `ground2` + `shadow-plate` — there is no `shadow-plate` token in `04` 6.3a; a Dossier plate that lifts is the panel with `Edge.raised`; recorded; dial arc hairline at .5 over hairline at .1 — never ember; bars hairline; ghost `.saturation(.75)` `.opacity(.13)`; number plate `club`; strength chips `Edge.panel`, no fill; selected route `Edge.ember`.

**Data:** `number`, `person.name`; `position`, `academicYear`; `rosterRole`; `overall` (clamped 0–99 in `init`); `availability`, `condition`; `schemeFit`; `hometown`; `strengths[]`; `staffSummary`; `concern`; `attributeGroups[].attributes[].value`, `.confidence`; `recentForm[].opponent`, `.rating`; Development route → `onInspectDevelopment(stableID)` (screen 19).

### Rulings for this surface

1. **The route bar is 44, not 32** — its four routes are tap targets (adaptation rule). Route labels `.columnHead` uppercase in a 44 row; the selected route carries `Edge.ember` as a bottom hairline, never a fill.
2. **Four routes, one panel each:** Overview = the sheet's composition; Attributes = the same attributes panel with every group and row, scrolling; Development = calls `onInspectDevelopment(model.stableID)` on selection (it is a navigation, so it is drawn as the route, not a fourth panel); History = `historyEvidence` as prose, or `unseen · no history recorded` in ink 4 when empty. Confidence prints `attribute.confidence` verbatim (`Known`); no range is invented.
3. **`unseen before week 7` is not drawn** — `recentForm` has no window. The recent-form head reads `Recent form · n of n`.
4. **The staff read is unattributed and says so**: panel head `STAFF READ · UNATTRIBUTED`; `staffSummary` in `.prose`, then `Concern.` in ink 4 and `concern` in `.proseMin`.
5. **The ghost is inside the identity plate**, `ForgeFieldGhostMark(team: team, ghost: budget.ghost, surface: club.palette.ground2)` offset to bleed the plate's bottom-left corner and clipped by the plate — never across the seam.
6. **Zero gold.** `overall` is a rating, not a standing.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension PlayerProfileView {
    public static let identityDataPointRoles: [String] = [
        "identity.number", "identity.name", "identity.position", "identity.year", "identity.role",
        "identity.overall", "identity.availability", "identity.condition", "identity.schemeFit",
        "identity.hometown", "identity.strength",
    ]
    public static let attributeRowDataPointRoles: [String] = ["attribute.label", "attribute.value", "attribute.confidence"]
    public static let formRowDataPointRoles: [String] = ["form.opponent", "form.rating"]
    public static let staffReadDataPointRoles: [String] = ["staff.summary", "staff.concern"]
    public static let referenceAttributeRowCount = 4
    public static let referenceFormRowCount = 3
    public static let dataPointCount = identityDataPointRoles.count
        + attributeRowDataPointRoles.count * referenceAttributeRowCount
        + formRowDataPointRoles.count * referenceFormRowCount
        + staffReadDataPointRoles.count                                       // 11 + 12 + 6 + 2 = 31 of 41
    public static let stageFraction = Double(ProfileMetric.identityWidth / ForgeFieldTokens.Space.viewport.width)   // 300 / 852
    public static let goldElementCount = 0
    public static let emberElementCount = 0
    public static let ghost = ForgeFieldBudget.Ghost(size: ProfileMetric.ghostSize, opacity: ProfileMetric.ghostOpacity, desaturated: false)
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: ghost, backgroundCount: backgroundCount)
}
```
with `ProfileMetric.ghostSize: CGFloat = 260` and `ghostOpacity = ForgeFieldTokens.Register.ghostOpacity` (the .13 default is the token, not a literal).

- [ ] **Step 1: Read the spec column, contract row 18, `PlayerProfileView.swift`.** It is presented both as a route (`CoachWorldAppRootView.swift:470`) and as a sheet from `RosterView`; both hosts keep working.
- [ ] **Step 2: Register the facts; red.**
- [ ] **Step 3: Draw it.** Standard: `HStack` identity plate (300) · vertical hard seam · right column (route bar 44, then the route's panels). AX5: one scroll column, identity plate first (the ghost stays inside it), route bar, panels.
- [ ] **Step 4: Build and suites.** `AccessibilityReflowTests` already asserts this view declares both clauses; keep `accessibilitySortPriority`.
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=18`** (lands on the roster's first player), standard and AX5. Check an empty `strengths`, an empty `historyEvidence`, a 30-character hometown.
- [ ] **Step 6: Commit.** `feat(ui): draw Player profile to the Forge Field sheet` — body: rulings 1–3.

---

## Task 5: Development (19)

**Files:** Rewrite `Sources/ProFootballCoachUI/DevelopmentPlanView.swift` (keep `init(model:statusMessage:onClose:)`). Modify `ForgeFieldBudget.swift` (`facts[.developmentPlan]`).

**Consumes:** `RosterReadModel` — the roster's own model, read for `players[].developmentDelta`, `.overall`, `.condition`, `.profile.developmentEvidence`, `seasonLabel`, `weekLabel`; `onClose`, `onNavigateChrome`.

### Spec column (transcribed)

**Register & budget:** Desk, ledger · stage 15% · 60 of 393 · cap 25% · data points 58 of 80 · largest numeral 26 (the four counts) · gold 0 · ember 0 (nothing here writes) · ghost 0 · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Movement band | 10, 44 | 832 × 60 | 1–12 |
| Seam · hard | 10, 112 | 832 × 1 | 1–12 |
| Ledger | 10, 120 | 832 × 263 | 1–12 |
| Row × 5 | —, 139 | 808 × 44 | — |
| Footer band | —, 359 | 808 × 24 | — |

Same horizontal seam as 16, at y 112. Columns `30 / 150 / 44 / 74 / 36 / 40 / 374`: the evidence column is the widest thing on the screen because the evidence is the point.

**Type:** movement counts 26 → `.heading` + `.monospacedDigit()`; player name `.row`; delta `.row` + `.monospacedDigit()`, signed, never tinted; evidence `.proseMin` (the sheet's 1.3 line height → canon's 1.5; recorded); band prose `.proseMin`; footer 10 mono → `.figure`.

**Data:** `players[].developmentDelta` → `+1 · −1`; `.overall`; `.condition`; `.profile.developmentEvidence` → evidence prose; `players.count` → "5 of 85"; `seasonLabel + weekLabel` → "since …".

### Rulings for this surface

1. **The four counts are a tally of retained deltas** — up (`> 0`), flat (`== 0`), down (`< 0`), unseen (`nil`) — arithmetic on facts the model holds, the same standing as the standings differential. Recorded as an ask (`DevelopmentSummary`) so two surfaces cannot disagree later.
2. **Sort is `RosterSortDescriptor(field: .development, isAscending: false)`** — the model's own sort, ties by `stableID`; the footer says `sorted by movement`. No second sort key is invented.
3. **The band's second sentence is the surface's own nature**, not a fact about the world: `Recorded movement only. Nothing here is a projection.` (`Costa tagged the film` names a person the model does not hold and is not drawn.)
4. **Evidence empty → `unseen`** in ink 4; the footer counts them: `n players have no recorded evidence · unseen`.
5. **Rows are 44 and inert**, as drawn; two lines of `.proseMin` at 1.5 (36 pt) fit.
6. **`statusMessage`**, when present, is a caution-dot line under the band, not a panel.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension DevelopmentPlanView {
    public static let bandDataPointRoles: [String] = ["moved.up", "moved.flat", "moved.down", "moved.unseen", "since"]
    public static let rowDataPointRoles: [String] = ["row.number", "row.name", "row.position", "row.delta", "row.overall", "row.condition", "row.evidence"]
    public static let referenceVisibleRowCount = 5
    public static let dataPointCount = bandDataPointRoles.count + rowDataPointRoles.count * referenceVisibleRowCount   // 5 + 35 = 40 of 58
    public static let stageFraction = Double(DevelopmentMetric.bandHeight / ForgeFieldTokens.Space.viewport.height)   // 60 / 393
    public static let goldElementCount = 0
    public static let emberElementCount = 0
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1: Read the spec column, contract row 19, `DevelopmentPlanView.swift`.**
- [ ] **Step 2: Register the facts; red.**
- [ ] **Step 3: Draw it.** Standard: band (four label-over-count cells + the sentence) · seam · ledger (19 head + 5 × 44, scroll) · 24 footer caption. AX5: one scroll column; the seven columns collapse to two lines per player (identity line, evidence line).
- [ ] **Step 4: Build and suites.**
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=19`.** Check a week-one save where every delta is nil (`unseen` count equals the squad; the ledger still lists players with `unseen` in the delta column).
- [ ] **Step 6: Commit.** `feat(ui): draw Development to the Forge Field sheet`.

---

## Task 6: Staff room (20)

**Files:** Rewrite `Sources/ProFootballCoachUI/StaffRoomView.swift` (keep `init`, `onClose`, its title parameter used by alias 21). Modify `ForgeFieldBudget.swift` (`facts[.staffRoom]`).

**Consumes:** `StaffRoomReadModel` (`team`, `coach`, `seasonLabel`, `rows[] { name, role, age, reputation, development, recruiting, gamePlanning, schemeAffinity, seasonsWithProgramme }`, `maximumRows = 32`); `onClose`, `onNavigateChrome`. Alias 21 (Staff market) renders this view with its title, unchanged.

### Spec column (transcribed)

**Register & budget:** Desk, people-led · stage 23% · 200 of 852 wide · cap 25% · data points 47 of 80 · largest numeral 26 (the reputation dial) · gold 0 · ember 0 · ghost 0 (200 pt column, ghost floor is 230) · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Person column | 10, 44 | 200 × 339 | 1–3 |
| Reputation dial | 66, 152 | 88 × 88 | — |
| Seam · vertical | 218, 44 | 1 × 339 | — |
| Staff table | 227, 44 | 615 × 195 | 4–12 |
| Row × 4 | —, 63 | 591 × 44 | — |
| Ratings | 227, 247 | 615 × 136 | 4–12 |
| Bar × 4 | — | 591 × 24 | — |

Vertical seam at x 218: left of it the person you are looking at, right of it the room and the four numbers that place him in it. Rating bars are 24 rows — on the ladder, inert, not tap targets (`04` 6.3a(i)).

**Tokens & type:** surname `.heading`; reputation `.heading` + `.monospacedDigit()`; row name `.row`; role `.proseMin`; monogram plate 48 and 26 on `ground3`; dial arc hairline .5 on .1; active row 2 pt ember spine; `unseen` in ink 4, never 0 or a dash.

**Data:** `rows[].name`; `.role`; `.reputation`; `.seasonsWithProgramme`; `.age`; `gamePlanning`, `schemeAffinity`, `development`, `recruiting`; `rows.count` → "12 on staff"; contract → no field → `unseen`.

### Rulings for this surface

1. **Rows are 44** — tapping selects the person for the left column (`@State selectedStaffID`, first row by default; the view already does this or adds it).
2. **Contract, salary, delegation: `unseen`**, stated in ink 4 on the person column, never a dash.
3. **Rating bars state their bound**: `of 99` under the four bars (`CLAUDE.md`: ratings are 40–99); bars are ink 3 on hairline at .14, never club colour or ember.
4. **Monogram plates** are initials on `ground3` (`CoachWorldBlankPhotoPlate`'s initials logic if it survives; otherwise two letters from `name`) — no faces, ever.
5. **The head row's count** reads `n on staff · of 32` from `rows.count` and `StaffRoomReadModel.maximumRows`.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension StaffRoomView {
    public static let personDataPointRoles: [String] = ["person.name", "person.role", "person.reputation", "person.age", "person.tenure", "person.contract"]
    public static let rowDataPointRoles: [String] = ["row.name", "row.role", "row.reputation", "row.tenure"]
    public static let ratingDataPointRoles: [String] = ["rating.gamePlanning", "rating.schemeAffinity", "rating.development", "rating.recruiting"]
    public static let referenceVisibleRowCount = 4
    public static let dataPointCount = personDataPointRoles.count + rowDataPointRoles.count * referenceVisibleRowCount + ratingDataPointRoles.count   // 6 + 16 + 4 = 26 of 47
    public static let stageFraction = Double(StaffMetric.personColumnWidth / ForgeFieldTokens.Space.viewport.width)   // 200 / 852
    public static let goldElementCount = 0
    public static let emberElementCount = 0
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1: Read the spec column, contract row 20, `StaffRoomView.swift`.**
- [ ] **Step 2: Register the facts; red.**
- [ ] **Step 3: Draw it.** Standard: `HStack` person column (200) · vertical hard seam · right column (`staffTable` 195 over `ratings` 136). AX5: one scroll column; the four bars become four `label · value of 99` lines.
- [ ] **Step 4: Build and suites.**
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=20`.** Check an empty `rows` (the person column states `No staff recorded` and whose job it is — the athletic director's; the table states the same absence).
- [ ] **Step 6: Commit.** `feat(ui): draw Staff room to the Forge Field sheet`.

---

## Task 7: The family's ledger and STATUS rows

**Files:** Modify `docs/FRONTEND-CHANGE-LEDGER.md` (Part E), `docs/STATUS.md`.

- [ ] **Step 1: Append one DONE row per surface** (2–6), each naming its deviations, in the ledger's existing row format.
- [ ] **Step 2: Append one TODO row, "Personnel read-model asks from the sheet"**, listing verbatim: `RosterFilter { unit, positionGroup, counts }`; `Slot.alignment`, `Slot.isVacant` + reason; a plan usage figure; `StaffNote { speaker, role, body }` for `staffSummary`; `enum Confidence { known, band(Int, Int), unseen }`; a recent-form window; `DevelopmentSummary { up, flat, down, unseen }`; `developmentEvidence` lifted onto `PlayerRow`; a recruiting `StaffRole`; staff contract/salary/delegation; and the three alias product decisions (21: write `StaffMarketReadModel` or delete the id; 22: cut the id or record install/familiarity per scheme; 23: either 17 keeps `options[]` or 23 becomes the plan surface). Each is an engine or provider question for the owner, not a drawing decision.
- [ ] **Step 2a: The row's asks close in 2I.** `docs/plans/2026-09-06-forge-field-phase-2i-completion-and-2j-release-candidate.md` Task I1 gives each ask a recorded disposition — design fact, projection, or not v1 — before anything is built; Task I18 draws the facts into this family's surfaces after this plan has merged.
- [ ] **Step 3: STATUS.md** — one dated entry: what was drawn, what was verified (exact suite counts), what was rendered, and that nothing is pushed.
- [ ] **Step 4: Commit.** `docs: record the personnel Forge Field conversion in the ledger and STATUS`

---

## Phase 2C exit

- [ ] `swift build` green.
- [ ] `--design-contracts` and `--core-contracts` green (2S's two red-by-design scans excepted; Shortlist/Negotiation/World search/Settings/Coach identity are other families' files).
- [ ] The generic budget suite green with all five personnel surfaces registered.
- [ ] All five rendered on a booted device at standard and AX5, looked at, screenshots kept under `docs/proofs/forge-field/personnel/` named `<id>-<slug>-{standard,ax5}.png`.
- [ ] Adversarial review (`adversarial-reviewer` or `/code-review`) on the phase diff; confirmed findings fixed first. **Not a build; never reported as one.**
- [ ] Full `swift run SimTests` green — once, here.
- [ ] Ledger and STATUS rows landed. **Ask the owner before any push or merge.**
