# Forge Field Phase 2D — Recruiting

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** draw the seven recruiting surfaces — Board, Prospect, Shortlist, Visits, Class, Signing day, College offseason — to the Forge Field sheet, on the 2A shell and the 2S contract.

**Architecture:** budget table first, then one surface per task in the sheet's order. Six of the seven read one model (`RecruitingBoardReadModel`); Signing day and College offseason read `CollegeOffseasonReadModel`. The four alias ids (30 Portal hub, 31 Retention, 32 Portal market, 33 NIL) are declared aliases of 61 and are not drawn; the sheet's decisions about them are recorded as asks. The board loses the dossier pane it carries today (screen 25's whole content); the board is the comparison, the prospect is the subject.

**Tech Stack:** iOS 26+, Swift 5.10 language mode, SwiftUI.

**Spec:** `Game screens - Recruiting.dc.html` (Forge Field project `8c511c92-3337-4cfb-850c-140a659f3034`), transcribed per surface below. Batch 3 of 7 · 11 ids · 7 surfaces · drawn on Zeeland, hue 192. **Where this plan and the sheet disagree on a number, the sheet is right** — except under the adaptation rule and except where the presentation contract forbids the fact.

**Canon:** `04` 6.1e, 6.1f, 6.2a, 6.2a(i), 6.2a(ii), 6.3a, 6.3a(i), 6.6a, 6.7a, 7. **Contract:** rows 24–29 and 61. **Ledger:** Part E; this phase appends rows (next free numbers at merge).

**Entry criterion:** Phase 2S merged (`ForgeFieldField`, `ForgeFieldFormat`, `ForgeFieldGhostMark`, the budget/facts contract).

**Parallel worktree:** yes — runs beside 2C, 2E, 2F and 2I. Merge surface: `ForgeFieldBudget.swift` (additive), `ScreenReadModels.swift` (one additive constant, Task 2), `ForgeFieldTokens.swift` (`lampWash`, Task 7), this family's seven view files. Roadmap §Running phases as parallel worktree sessions.

## Global Constraints

Everything in `docs/plans/2026-09-06-forge-field-remaining-roadmap.md`'s Global Constraints, carried rulings and owner-decision defaults applies unchanged. Specific to this family, from the sheet:

- **One programme, one cycle.** Harris has to be followable from the board to his dossier to the planner without a figure changing underneath him — every surface prints capacity from the same `Capacity` fields, never a derived remainder.
- **Sample and production print different words.** The sample career says `Visit ready`, `Watching`, `High`; the provider returns `Committed elsewhere`, `Locked in`, `Untracked`. **Measure every column against the provider's own label functions** (`interestLabel()`, `statusLabel()`, `componentBand()`), never the sample. Status is 150 wide because production prints `Committed elsewhere`.
- **A rival's claim is cold slate with a hollow dot.** Never the rival's colour.
- **The accent is not a label and not a series.** The rank line is ink 4; short-coverage bars are ink 3, met bars are `signalGood`; only the one irreversible control is ember.
- **The two device defects this family owns** (roadmap 2A, ledger 2026-08-29): the empty `RELATIONSHIP LOG` heading (Task 3 states the absence in words), and `SLOTS 0 open` beside an offered add at `0 contact points` (the ember follows `choice.isAvailable`/`unavailableReason` exactly; a provider that marks the offer available with no slot is a provider fault, recorded in Task 8). The third — a prospect row clipped mid-height at the panel edge — is fixed by every scrolling table's viewport being `head + n × 44`, so no row is partial at rest.
- **Contract omissions bind in full** (rows 24–29, 61): no fabricated ranking beyond `boardRank`, no scouting report, no commitment probability, no countdown, no market row, no recipient allocation, no action absent from `choices`; no re-ranking or derived priority on the shortlist; no cost the choice does not state on the planner; no class grade, national ranking or projected finish; no fabricated commitment or drama copy on signing day; no invented portal entrant, NIL recipient or retention probability on the offseason.

---

## The per-surface procedure

1. Read the surface's transcribed spec column below.
2. Read its contract row. Every drawn fact the model does not hold is an ask: not drawn, absence stated (`unseen`, `No contact recorded`), listed in Task 8.
3. Register its facts (`// MARK: - Assertable budget facts` + the `ForgeFieldBudget.facts` line); `swift run SimTests --design-contracts`; watch the generic suite fail.
4. Draw it inside `ForgeFieldDevice(club:)` from the primitives, `ForgeFieldEmber`, `ForgeFieldGhostMark`, `ForgeFieldField`, `ForgeFieldFormat`, `ForgeFieldType.font(_:)`; every number in a `private enum XMetric` with its sheet source; keep every callback, `@State` and accessibility identifier; standard **and** `isAccessibilitySize` compositions, every `lineLimit(1)` lifted at AX5. **The ember's `cost:` argument is always a named `private var emberCost: String`** (the rulings' expressions are its body): the cost-argument scan accepts only a string literal or a bare name, and a literal must not contain a comma.
5. `swift build`; `--design-contracts`; `--core-contracts`.
6. Render with `PROOF_SCREEN_NUMBER=<id>` (roadmap render loop), standard and AX5; look; check handoff §7's five fault classes.
7. Commit, one per surface; deviations in the body and a ledger row.

---

## Task 1: The recruiting budget table

**Files:** Modify `Sources/ProFootballCoachUI/ForgeFieldBudget.swift`. Test: the 2S generic suite.

| Screen | Register | Stage | Points | Gold | Ember | Ghost | Backgrounds |
|---|---|---|---|---:|---:|---|---:|
| 24 Board | Desk, table-led, one committing control | 16% · 62 of 393 | 47 of 80 | 0 | 1 · Offer scholarship | 0 | 2 of 2 |
| 25 Prospect | Dossier, plate-led, one committing control | 35% · 138 of 393 | 21 (house 80 is the ceiling) | 0 of 2 | 1 · Offer scholarship | 0 · the plate carries identity | 2 of 2 |
| 26 Shortlist | Desk, table-led, nothing commits | 11% · 44 of 393 (the filter) | 48 of 80 | 0 | 0 | 0 | 2 of 2 |
| 27 Visits | Desk, list-led, every row priced | 16% · 62 of 393 | 33 of 80 | 0 | 0 · deliberately | 0 · the hatch is an absence | 2 of 2 |
| 28 Class | Desk, figure-led, nothing commits | 19% · 74 of 393 | 61 of 80 | 0 | 0 | 0 | 2 of 2 |
| 29 Signing day | Desk, one stated absence | 0% | 4 of 80 | 0 | 0 | 300 · .13 · bleeds the right edge | 1 of 2 · ground 1 with a lamp wash |
| 61 College offseason | Desk, ledger and decisions, one committing control (disabled) | 8% · 32 of 393 (the phase row) | 44 of 80 | 0 | 1 · Advance week | 0 | 2 of 2 |

- [ ] **Step 1: Add the table** and `.recruiting: recruiting,` in `tables`.
```swift
extension ForgeFieldBudget {
    /// The seven recruiting surfaces, `Game screens - Recruiting.dc.html`. Transcribed; nothing invented.
    public static let recruiting: [CoachWorldScreenID: ForgeFieldBudget] = [
        .recruitingBoard: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: nil, detail: "table-led, one committing control"),
            stageFraction: 0.16...0.16, dataPoints: 47, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface, ghost: nil, backgrounds: 2),
        .prospectProfile: ForgeFieldBudget(
            register: RegisterStamp(lean: .dossier, tone: nil, detail: "plate-led, one committing control"),
            stageFraction: 0.35...0.35, dataPoints: ForgeFieldTokens.Register.deskPoints, pointsAboveSeam: nil,
            goldMax: ForgeFieldTokens.Register.goldMaxDossier, emberCount: ForgeFieldTokens.Register.emberPerSurface,
            ghost: nil, backgrounds: 2),
        .shortlist: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: .readout, detail: "table-led"),
            stageFraction: 0.11...0.11, dataPoints: 48, pointsAboveSeam: nil,
            goldMax: 0, emberCount: 0, ghost: nil, backgrounds: 2),
        .contactVisitPlanner: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: nil, detail: "list-led, every row priced"),
            stageFraction: 0.16...0.16, dataPoints: 33, pointsAboveSeam: nil,
            // Deliberately zero: "every row on this surface spends and none of them is final;
            // promoting one to the accent would rank the week's work, which is the one thing the
            // planner refuses to do."
            goldMax: 0, emberCount: 0, ghost: nil, backgrounds: 2),
        .classOverview: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: .readout, detail: "figure-led"),
            stageFraction: 0.19...0.19, dataPoints: 61, pointsAboveSeam: nil,
            goldMax: 0, emberCount: 0, ghost: nil, backgrounds: 2),
        .signingDay: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: .readout, detail: "one stated absence"),
            stageFraction: 0.0...0.0, dataPoints: 4, pointsAboveSeam: nil,
            goldMax: 0, emberCount: 0,
            ghost: Ghost(size: 300, opacity: ForgeFieldTokens.Register.ghostOpacity, desaturated: false),
            backgrounds: 1),
        .collegeOffseason: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: nil, detail: "ledger and decisions, one committing control"),
            stageFraction: 0.08...0.08, dataPoints: 44, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface, ghost: nil, backgrounds: 2),
    ]
}
```
- [ ] **Step 2: `swift run SimTests --design-contracts`** — the coverage test names the seven unregistered screens. Correct red.
- [ ] **Step 3: Commit.** `feat(ui): stamp the recruiting register budgets as a contract`

---

## Task 2: Board (24)

**Files:** Rewrite `Sources/ProFootballCoachUI/RecruitingBoardView.swift` (42 KB; keep `init`, `onAction`, `onContinue`, `onNavigate`, `onOpenProspect`, `onOpenShortlist`, `@State selectedProspectID`). Modify `ForgeFieldBudget.swift` (`facts[.recruitingBoard]`).

**Consumes:** `RecruitingBoardReadModel` (`team`, `capacity { scholarshipSlotsRemaining, weeklyHoursRemaining, officialVisitsRemaining }`, `positionNeeds[] { position, target, committed }`, `prospects[] { stableID, person, boardRank, position, hometown, interest, status, isCommitted, evaluation, relationshipHistory, choices[] }`, `discovery[]`, `canContinue`, `continueReason`); `CoachWorldActionChoice { intentID, title, cost, consequence, isAvailable, unavailableReason }`.

### Spec column (transcribed)

**Register & budget:** Desk, table-led · stage 16% · 62 of 393 · data points 47 of 80 · largest numeral 34 · gold 0 · ember 1 of 1 (Offer scholarship) · ghost 0 · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Chrome bar | 10, 8 | 832 × 30 | 1–12 |
| Budget strip | 10, 44 | 832 × 62 | 1–12 |
| Seam · hard | 10, 114 | 832 × 1 | 1–12 |
| Table | 10, 122 | 832 × 261 | 1–12 |
| Row × 4 | —, 141 | 808 × 44 | — |
| Discovery head | —, 317 | 808 × 19 | — |
| Ember | 632, 53 | 198 × 44 | — |

Horizontal seam at y 114: above it the week's three budgets and the one control that spends them, below it the twenty-two names they are spent on. Columns `34 / 358 / 46 / 74 / 150 / 96` at 10 pt gutters.

**Type:** budget figures 34 → `.title` + `.monospacedDigit()`; board rank 19 → `.panel` + `.monospacedDigit()` (the sorted column); name `.row`; hometown `.proseMin`; row figures `.figure`; column heads `.columnHead`; ember cost `ForgeFieldEmber.costStep`.

**Tokens:** device `ground1`; strip and table `ground2` + `Edge.panel`; row band on rows 2 and 4 (`ground3`); selected row 2 pt ember spine; a rival's claim `signalCold` hollow dot; discovery head `ground1` + `Edge.seamHair`; ember = `ForgeFieldEmber`.

**Data:** `capacity.scholarshipSlotsRemaining` → "7 open"; `capacity.weeklyHoursRemaining` → "40 pts left"; `capacity.officialVisitsRemaining` → "1 left"; `prospects.count` of `CollegeRules.recruitingBoardLimit` → "22 of 40"; `positionNeeds[].committed / .target` → "QB 0/1 · DL 1/3"; `boardRank` (0 renders `D`); `person.name`; `hometown`; `interest` (four bands); `status` (six values); `evaluation.schemeFit`; `discovery[]` (capped at 24); tap a row → selection; Offer scholarship → the selected prospect's `choices[]` offer entry.

### Rulings for this surface

1. **The dossier pane goes.** The board is table-only; a row opens screen 25 through `onOpenProspect(stableID)`. Selection (`selectedProspectID`) lights the row's ember spine and feeds the ember; the sheet's `tap a row · selectedProspectID · view state, not routed` becomes: **single tap selects; the row's trailing `→` (`04` 6.6a's permitted glyph) is a 44 pt control that opens the dossier**, so both intents the existing view serves survive without a long-press.
2. **The ember is the selected prospect's scholarship offer.** `offer = selected.choices.first { $0.intentID == CoachWorldIntentID.offerScholarship }` — no named constant exists today, so add `extension CoachWorldIntentID { public static let offerScholarship = CoachWorldIntentID(rawValue: "offerScholarship") }` in `ScreenReadModels.swift`, citing `CoachWorldRecruitingBoardProvider.swift:387` where the provider emits that exact raw value; never a bare string in the view. Then `ForgeFieldEmber(label: offer.title.uppercased(), cost: offer.isAvailable ? offer.cost : (offer.unavailableReason ?? offer.cost), isEnabled: offer.isAvailable, action: { onAction(selected.stableID, offer.intentID) })`. No offer choice on the selected prospect (committed, or committed elsewhere) → the ember is disabled with cost `no offer available`, never removed.
3. **Advance week is a quiet 44 pt control** at the strip's trailing edge beside the ember (`onContinue`, disabled on `!canContinue` with `continueReason` beneath it in ink 4). Two irreversible actions, one ember: the sheet chose the one with a price.
4. **The reorder animates on a cut.** `04` 6.7a has four transitions and a reordering table is not one; `withAnimation` is not used on rank changes.
5. **Discovery** is a second inner head row (`Discovery · n available · not on this board`) followed by discovery rows in the same table; a discovery row's rank cell prints `D`. Untracked is the provider's own word.
6. **Rows are 44; the table's viewport is head + 4 × 44 + discovery head, then scroll** — the clipped-row defect closes by construction.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension RecruitingBoardView {
    public static let stripDataPointRoles: [String] = ["slots.open", "contact.left", "visits.left", "board.count", "board.limit", "need.position"]
    public static let rowDataPointRoles: [String] = ["row.rank", "row.name", "row.hometown", "row.position", "row.interest", "row.status", "row.fit"]
    public static let referenceVisibleRowCount = 4
    public static let dataPointCount = stripDataPointRoles.count + rowDataPointRoles.count * referenceVisibleRowCount   // 6 + 28 = 34 of 47
    public static let stageFraction = Double(BoardMetric.stripHeight / ForgeFieldTokens.Space.viewport.height)   // 62 / 393
    public static let goldElementCount = 0
    public static let emberElementCount = 1
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1: Read the spec column, contract row 24, `RecruitingBoardView.swift`, and the provider's label functions.**
- [ ] **Step 2: Register the facts; red.**
- [ ] **Step 3: Draw it.** Standard: chrome · budget strip (three label-over-figure cells at `.title`, the position plan line, the ember and the quiet advance at the trailing edge) · seam · table. AX5: one scroll column; a row becomes two lines (rank + name + `→`; position · interest · status · fit).
- [ ] **Step 4: Build and suites.** `ContractTests` asserts Prospect Profile and Shortlist are reachable from the board (line ~1502): `onOpenShortlist` stays as a quiet control in the table head (`Shortlist →`).
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=24`**, standard and AX5. Check: zero slots (ember disabled, reason shown), an empty board (the table states `No one on the board` and whose job it is — the recruiting coordinator's), the longest `Committed elsewhere` status in its 150 column.
- [ ] **Step 6: Commit.** `feat(ui): draw Recruiting board to the Forge Field sheet` — body: rulings 1–3.

---

## Task 3: Prospect (25)

**Files:** Rewrite `Sources/ProFootballCoachUI/ProspectProfileView.swift` (keep `init(model:prospectID:…onAction:onClose:)`). Modify `ForgeFieldBudget.swift` (`facts[.prospectProfile]`).

**Consumes:** `RecruitingBoardReadModel.Prospect` for the given `prospectID`; `onAction(stableID, intentID)`, `onClose`, `onNavigateChrome`.

### Spec column (transcribed)

**Register & budget:** Dossier, plate-led · stage 35% · 138 of 393 · band 30–40% · data points 21 · largest numeral 62 (the name) · gold 0 of 2 · ember 1 of 1 (Offer scholarship) · ghost 0 · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Subject plate | 10, 44 | 832 × 130 | 1–12 |
| Mark plate | 22, 58 | 48 × 48 | — |
| Band rail × 4 | 566, 74 | 68 × 32 | — |
| Seam · hard | 10, 182 | 832 × 1 | 1–12 |
| Evaluation | 10, 190 | 411 × 193 | 1–6 |
| Relationship | 430, 190 | 201 × 193 | 7–9 |
| Actions | 641, 190 | 201 × 193 | 10–12 |

Seam at y 182 — 35% staged. Below it three panels on whole columns: what the system thinks, what the relationship holds, what it costs to act. The action panel is four 44 rows under a head; **the sheet's 17 pt head is off the ladder → `panelHead` 19, panel 195, and the 8 pt bottom gap absorbs it** (393 − 190 − 195 = 8, on the ladder).

**Type:** name 62 `.fixture`; position/hometown `.prose`; fit/interest `.row`; `Confidence 62%` `.row` + `.monospacedDigit()`; band rail `.figure`; action label `.chrome` at `Tracking.chrome`; cost line `ForgeFieldEmber.costStep` on the ember, `.figure` on plain rows.

**Data:** `person.name`; `boardRank` + `status` → `Board #2 · uncommitted`; initials on the mark plate (`CoachWorldBlankPhotoPlate`); `evaluation.verdict` → one of Weak / Fair / Strong / Elite lit on the band rail; `evaluation.schemeFit`; `evaluation.uncertainty` (or `No evaluation yet`); `evaluation.citedOutliers` → the two largest by magnitude, as the provider orders them; `relationshipHistory` → always `[]` in production → `No contact recorded`; `choices[]` → `Contact 20 pts`, `Evaluate 20 pts`, `Schedule visit 30 pts`, `Offer scholarship · spends 1 of 7 slots · final`.

### Rulings for this surface

1. **The verdict is four bands with one lit** — inert 32 pt chips; `evaluation.verdict` is one word and that is what is drawn. The sample's scouting sentence is not.
2. **The relationship panel states the absence and whose job it is**: `No contact recorded` in ink 4, then `The board keeps no per-prospect ledger.` — the empty `RELATIONSHIP LOG` defect closes here. When `relationshipHistory` is non-empty, rows of `dateLabel · summary · effect`, 32 dense.
3. **The actions panel lists every entry of `choices[]`** as 44 rows in provider order, each with its `cost` in `.figure` beneath the title; the scholarship offer is the one `ForgeFieldEmber` (cost as Task 2 ruling 2); every other choice is a plain 44 row (`.chrome` label, ink 2) with its `unavailableReason` in caution ink when `!isAvailable`, never removed. **Withdraw stays here** when the provider includes it — it is in `choices[]`, which is the model's own action list, and the board row has no room for a second control now the board is table-only. Deviation from the sheet, recorded. More than four choices → the panel scrolls and its head reads `n actions`.
4. **The rank line is ink 4.** The accent belongs to the offer.
5. **Zero gold; no ghost** — the plate carries identity.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension ProspectProfileView {
    public static let plateDataPointRoles: [String] = ["subject.name", "subject.rank", "subject.status", "subject.position", "subject.hometown", "subject.verdict"]
    public static let evaluationDataPointRoles: [String] = ["evaluation.schemeFit", "evaluation.uncertainty", "evaluation.interest", "evaluation.outlier"]
    public static let relationshipDataPointRoles: [String] = ["relationship.event"]
    public static let actionRowDataPointRoles: [String] = ["action.title", "action.cost"]
    public static let referenceActionRowCount = 4
    public static let dataPointCount = plateDataPointRoles.count + evaluationDataPointRoles.count
        + relationshipDataPointRoles.count + actionRowDataPointRoles.count * referenceActionRowCount   // 6 + 4 + 1 + 8 = 19 of 80
    public static let stageFraction = Double(ProspectMetric.plateHeight / ForgeFieldTokens.Space.viewport.height)   // 138 / 393
    public static let goldElementCount = 0
    public static let emberElementCount = 1
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```
(`plateHeight` is 138: the 130 plate plus the 8 gap to the seam, which is how the sheet measures its 35%.)

- [ ] **Step 1: Read the spec column, contract row 25, `ProspectProfileView.swift`.**
- [ ] **Step 2: Register the facts; red.**
- [ ] **Step 3: Draw it.** Standard: chrome · subject plate (mark plate, rank line, name at 62 with `minimumScaleFactor(ProspectMetric.nameScaleFloor)` 0.8, position · hometown, band rail at the trailing edge) · seam · three panels. AX5: one scroll column; the band rail stacks under the name; the ember last.
- [ ] **Step 4: Build and suites.**
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=25`.** Check a committed-elsewhere prospect (offer absent → ember disabled with `no offer available`), an evaluation with no outliers, a 28-character name at 62.
- [ ] **Step 6: Commit.** `feat(ui): draw Prospect to the Forge Field sheet` — body: ruling 3.

---

## Task 4: Shortlist (26)

**Files:** Rewrite `Sources/ProFootballCoachUI/ShortlistView.swift` (keep `init`, `onOpenProspect`, `onClose`, the filter `@State`). Modify `ForgeFieldBudget.swift`.

### Spec column (transcribed)

**Register & budget:** Desk, table-led · stage 11% · 44 of 393 (the filter) · data points 48 of 80 · largest numeral 13.5 · gold 0 · ember 0 · ghost 0 · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Filter field | 10, 44 | 832 × 44 | 1–12 |
| Seam · hard | 10, 96 | 832 × 1 | 1–12 |
| Board list | 10, 104 | 552 × 279 | 1–8 |
| Row × 5 | —, 123 | 528 × 44 | — |
| Coverage panel | 571, 104 | 271 × 279 | 9–12 |
| Need row × 4 | —, 123 | 247 × 32 | — |

Seam at y 96 under the field: what you typed is staged, what it narrowed is studied. The panel boundary at x 571 is a panel edge, not a second seam. Need rows are 32 dense (nothing in that panel is tappable); list rows are 44 (every one opens a dossier).

**Tokens:** field `ForgeFieldField` (`ground3`, `Edge.raised`, focused `Edge.seamHard`, placeholder ink 4); interest `signalCold` (not yours yet); bar short = ink 3 on hairline .14; bar met = `signalGood`; row band alternating.

**Data:** `countLabel` → `22 monitored` / `n of total` when filtered; filter matches name, position, status (substring, lowercased — three fields the row prints, so a query can never fail against something invisible); `boardRank`; `position · status`; `interest` uppercased; `positionNeeds[].committed / .target`; `capacity.scholarshipSlotsRemaining` → `7 scholarships left`; tap a row → `onOpenProspect(stableID)`.

### Rulings for this surface

1. **The filter is `ForgeFieldField`** (2S) with placeholder `Name, position or status`. The 2S "no platform text-field chrome" scan goes one file greener here.
2. **The coverage panel is labelled truthfully**: `Roster coverage · league minimum`, with the sentence `This is the roster, not the class` beneath — the array is whole-roster headcount against the floor, and a position held by returning seniors reads full with nobody signed.
3. **Bars:** short in ink 3, met in `signalGood`; never `actionPrimary`/ember.
4. **The `Last contact: …` accessibility label is removed** — it resolved to `No contact recorded` for every prospect in every save.
5. **A no-results state** says `No prospect matches "<query>"` in ink 4 inside the list, never an empty panel.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension ShortlistView {
    public static let stagedDataPointRoles: [String] = ["filter.query", "board.count"]
    public static let rowDataPointRoles: [String] = ["row.rank", "row.name", "row.position", "row.status", "row.interest"]
    public static let coverageDataPointRoles: [String] = ["need.position", "need.committed", "need.target"]
    public static let referenceVisibleRowCount = 5
    public static let referenceNeedRowCount = 4
    public static let dataPointCount = stagedDataPointRoles.count + rowDataPointRoles.count * referenceVisibleRowCount
        + coverageDataPointRoles.count * referenceNeedRowCount + 1 /* scholarships left */   // 2 + 25 + 12 + 1 = 40 of 48
    public static let stageFraction = Double(ShortlistMetric.fieldHeight / ForgeFieldTokens.Space.viewport.height)   // 44 / 393
    public static let goldElementCount = 0
    public static let emberElementCount = 0
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1–2:** read spec column, contract row 26, `ShortlistView.swift`; register facts; red.
- [ ] **Step 3: Draw it.** Standard: chrome · field · seam · `HStack(list 552, coverage 271)`. AX5: one scroll column, field first.
- [ ] **Step 4: Build and suites** (`ContractTests` reachability of Shortlist from the board still holds).
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=26`**; type a query that matches nothing; AX5.
- [ ] **Step 6: Commit.** `feat(ui): draw Shortlist to the Forge Field sheet`.

---

## Task 5: Visits (27)

**Files:** Rewrite `Sources/ProFootballCoachUI/ContactVisitPlannerView.swift` (keep `init(model:statusMessage:onAction:onClose:)`). Modify `ForgeFieldBudget.swift`.

### Spec column (transcribed)

**Register & budget:** Desk, list-led · stage 16% · 62 of 393 · data points 33 of 80 · largest numeral 34 · gold 0 · ember 0 (see below) · ghost 0 (hatch is an absence, not a mark) · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Budget bar | 10, 44 | 832 × 62 | 1–12 |
| Seam · hard | 10, 114 | 832 × 1 | 1–12 |
| Bookable list | 10, 122 | 552 × 261 | 1–8 |
| Person row | — | 528 × 24 | — |
| Action row | — | 528 × 44 | — |
| The week | 571, 122 | 271 × 261 | 9–12 |
| Hatch | 583, 153 | 247 × 118 | — |

A person row is 24 and inert (`04` 6.3a(i)); the action rows under it are 44 because they spend. Action titles are a fixed 132 column so the cost lines start on one axis down the whole list.

**Data:** `capacity.weeklyHoursRemaining` → 40; `capacity.officialVisitsRemaining` → 1; `capacity.scholarshipSlotsRemaining` → 7; `choices[]` → each priced by its own `cost`; `choices[].unavailableReason` → `committed elsewhere`; prospects with a bookable choice → `4 of 22`.

### Rulings for this surface

1. **No calendar; a stated absence.** The right panel is `The week · no per-day schedule` over a hatched 247 × 118 field (`signalCold` at .18, 45°), with the sentence: `Seven days and nothing to put in them. The model holds one weekly total, not a day-by-day allocation.` — the only honest third option.
2. **One pool, and the visit price beside it.** The budget bar prints `Contact points 40`, `Official visits 1`, `Scholarships 7`, then `One pool · a visit is 30 of the 40` (`CollegeRules.visitContactCost`, the rule that owns the price, never a literal).
3. **No ember, deliberately.** Every row spends and none is final. The offer choice, when present in a prospect's `choices[]`, is a plain 44 row here like the rest (the board and the prospect own its ember).
4. **The bookable set is every prospect with at least one `choices[]` entry**, and every entry is listed — the three hard-coded intent ids go. Unavailable choices keep their row and print `unavailableReason` in caution ink at the disabled opacity (`CoachWorldTokens.Motion.resolvedDisabledOpacity(for:)` — the one shared, Increase-Contrast-aware constant, per `ForgeFieldEmber`'s precedent), never disappearing.
5. **Cost lines align** on a fixed 132 pt title column (`VisitsMetric.actionTitleWidth`); at AX5 the action row stacks title over cost.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension ContactVisitPlannerView {
    public static let barDataPointRoles: [String] = ["pool.points", "pool.visits", "pool.slots", "pool.visitPrice", "bookable.count"]
    public static let personRowDataPointRoles: [String] = ["person.name", "person.position", "person.status", "person.interest"]
    public static let actionRowDataPointRoles: [String] = ["action.title", "action.cost"]
    public static let referencePersonCount = 2
    public static let referenceActionRowCount = 3
    public static let dataPointCount = barDataPointRoles.count + personRowDataPointRoles.count * referencePersonCount
        + actionRowDataPointRoles.count * referenceActionRowCount   // 5 + 8 + 6 = 19 of 33
    public static let stageFraction = Double(VisitsMetric.barHeight / ForgeFieldTokens.Space.viewport.height)   // 62 / 393
    public static let goldElementCount = 0
    public static let emberElementCount = 0
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1–2:** read spec column, contract row 27, `ContactVisitPlannerView.swift`; register facts; red.
- [ ] **Step 3: Draw it.** Standard: chrome · budget bar · seam · `HStack(list 552 scrolling, week panel 271)`. AX5: one scroll column.
- [ ] **Step 4: Build and suites.**
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=27`.** Check zero contact points (every action unavailable with its reason; the list still lists them), and no prospects at all.
- [ ] **Step 6: Commit.** `feat(ui): draw Contact & visit planner to the Forge Field sheet` — body: rulings 1, 3, 4.

---

## Task 6: Class (28)

**Files:** Rewrite `Sources/ProFootballCoachUI/ClassOverviewView.swift` (keep `init(model:statusMessage:onClose:)`). Modify `ForgeFieldBudget.swift`.

### Spec column (transcribed)

**Register & budget:** Desk, figure-led · stage 19% · 74 of 393 · data points 61 of 80 · largest numeral 34 (the class count) · gold 0 (a signed class is not a trophy) · ember 0 · ghost 0 · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Class strip | 10, 44 | 832 × 74 | 1–12 |
| Seam · hard | 10, 126 | 832 × 1 | 1–12 |
| Coverage | 10, 134 | 411 × 249 | 1–6 |
| Cell × 8 | — | 90 × 66 | — |
| Class list | 431, 134 | 411 × 249 | 7–12 |
| Row × 6 | —, 153 | 387 × 32 | — |

Two equal halves either side of column 6. Rows are 32 dense — nothing in the list opens anything; a name that needs a dossier is reached from the board.

**Data:** `prospects.filter(\.isCommitted).count` → 9; `CollegeRules.initialSigningsPerClass` → of 25; `capacity.scholarshipSlotsRemaining` of `CollegeRules.scholarshipLimit` → 7 of 85; `prospects.count` of `CollegeRules.recruitingBoardLimit` → 22 of 40; `positionNeeds[]` → the eight cells `QB 2/1`; needs where `committed < target` → `2 positions are below the league's roster minimum: DL, DB.`; `prospects[].status` → Signed · Committed; `evaluation.schemeFit`.

### Rulings for this surface

1. **`Signing period` is not drawn** — the phase lives on `CollegeOffseasonReadModel`, not this model.
2. **The coverage grid is labelled `Roster coverage · league minimum`** with the same distinction sentence as the shortlist; it is the roster, not the class.
3. **The class count is honest by construction** — `isCommitted` is the engine's commitment state, not the word `Committed` (a prospect committed to a rival carries that word too).
4. **No stars, no grade.** The fit band takes the column.
5. **Rows are 32 dense and inert**; the list head reads `n of m · the list scrolls` when it does.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension ClassOverviewView {
    public static let stripDataPointRoles: [String] = ["class.committed", "class.target", "slots.open", "slots.limit", "board.count", "board.limit"]
    public static let cellDataPointRoles: [String] = ["need.position", "need.committed", "need.target"]
    public static let rowDataPointRoles: [String] = ["row.name", "row.position", "row.fit", "row.status"]
    public static let referenceCellCount = 8
    public static let referenceVisibleRowCount = 6
    public static let dataPointCount = stripDataPointRoles.count + cellDataPointRoles.count * referenceCellCount
        + rowDataPointRoles.count * referenceVisibleRowCount + 1 /* the below-minimum sentence */   // 6 + 24 + 24 + 1 = 55 of 61
    public static let stageFraction = Double(ClassMetric.stripHeight / ForgeFieldTokens.Space.viewport.height)   // 74 / 393
    public static let goldElementCount = 0
    public static let emberElementCount = 0
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1–2:** read spec column, contract row 28, `ClassOverviewView.swift`; register facts; red.
- [ ] **Step 3: Draw it.** Standard: chrome · class strip (three figure cells at `.title`) · seam · `HStack(coverage grid 411, class list 411)`. AX5: one scroll column; the grid becomes eight `position · committed of target` lines.
- [ ] **Step 4: Build and suites.**
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=28`.** Check zero commitments (`0 of 25`, the list states `No one signed or committed`), more than eight needs (the grid wraps, never clips).
- [ ] **Step 6: Commit.** `feat(ui): draw Class overview to the Forge Field sheet`.

---

## Task 7: Signing day (29) and College offseason (61)

Two surfaces, one model, one task: Signing day's open branch renders 61 with a title, so 61 must exist first and 29 is drawn against it.

**Files:** Rewrite `Sources/ProFootballCoachUI/CollegeOffseasonView.swift` (keep `init`, `onCommit`, `onContinue`, `onClose`, its title parameter) and `Sources/ProFootballCoachUI/SigningDayView.swift` (keep its two branches on `cyclePhase`). Modify `ForgeFieldBudget.swift` (`facts[.collegeOffseason]`, `facts[.signingDay]`).

**Consumes:** `CollegeOffseasonReadModel` (`programme`, `coach`, `seasonLabel`, `recruitingSeason`, `cyclePhase`, `portalPhase`, `boardCount`, `scholarshipCount`, `contactPointsRemaining`, `nilBudget`, `nilCommitted`, `portalEntryCount`, `delegatedDecisionCount`, `decisions[] { title, deadline, evidence[], choices[] }`); `onCommit(intentID)`, `onContinue`, `onClose`.

### 61 — spec column (transcribed)

**Register & budget:** Desk, ledger-led · stage 8% · 32 of 393 (the phase row) · data points 44 of 80 · largest numeral 19 · gold 0 · ember 1 of 1 (Advance week, disabled while decisions are open) · ghost 0 · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Phase row | 10, 44 | 832 × 32 | 1–12 |
| Seam · hard | 10, 84 | 832 × 1 | 1–12 |
| Ledger | 10, 92 | 271 × 239 | 1–4 |
| Decisions | 290, 92 | 552 × 239 | 5–12 |
| Card × 2 | 290, 113 | 552 × 108 | 5–12 |
| Choice row | — | 552 × 44 | — |
| Footer | 10, 339 | 832 × 44 | 1–12 |
| Ember, disabled | 644, 339 | 198 × 44 | — |

A card is a 20 head plus two 44 rows (108). The footer is the only full-width element below the seam.

**Tokens:** ledger and cards `ground2` + `Edge.panel`; phase chips `Edge.raised`, no fill; a deadline running `signalCaution`; the portal `signalCold`; share bars ink 3 on hairline .14; ember disabled = `ForgeFieldEmber(isEnabled: false)`.

**Data:** `cyclePhase`; `portalPhase`; `boardCount / CollegeRules.recruitingBoardLimit` → 22/40; `scholarshipCount / CollegeRules.scholarshipLimit` → 78/85; NIL → `ForgeFieldFormat.money(nilBudget - nilCommitted)` of `money(nilBudget)`; `contactPointsRemaining`; `portalEntryCount`; `decisions[].title`; `.deadline`; `.choices[].title`, `.cost`; `decisions.count` of the provider's cap → `2 of 8`; Advance week enabled only when nothing is open or delegated.

### 61 — rulings

1. **`No recorded cost` is E25's ruling again**: mandatory-decision options are plain 44 rows, and the absence is stated quietly in ink 4 (`no recorded cost`) where a cost line would go — never caps, never an ember, never an invented price. Two identical `Set NIL` rows print as the provider returns them, each with its `consequence` if non-empty; the ask (a label that carries the amount, or NIL's own surface, id 33) is recorded.
2. **Evidence is drawn**: up to two `Decision.evidence[]` lines per card at `.figure` in ink 4 — the only thing on the surface that explains why the decision exists. More than two → `+n more` in the card head.
3. **The ember is Advance week**: `ForgeFieldEmber(label: "ADVANCE WEEK", cost: "\(openCount) OPEN", isEnabled: openCount == 0 && model.delegatedDecisionCount == 0, action: onContinue)`; the footer sentence beside it: `n decisions are still open.` Enabled, the cost reads `0 OPEN` — a legal under-spend, the HQ precedent.
4. **Every share states its whole** — each denominator is a rule constant, never a literal.
5. **The mid-season disappearance** (provider returns nil when the cycle is active and nothing is pending) is app-layer routing; recorded as an ask, not fixed here.

### 61 — assertable budget facts

```swift
// MARK: - Assertable budget facts

extension CollegeOffseasonView {
    public static let phaseRowDataPointRoles: [String] = ["phase.cycle", "phase.portal", "phase.season"]
    public static let ledgerDataPointRoles: [String] = ["board.count", "board.limit", "slots.count", "slots.limit", "nil.left", "nil.budget", "contact.left", "portal.count"]
    public static let cardDataPointRoles: [String] = ["decision.title", "decision.deadline", "decision.evidence", "choice.title", "choice.cost"]
    public static let referenceCardCount = 2
    public static let dataPointCount = phaseRowDataPointRoles.count + ledgerDataPointRoles.count
        + cardDataPointRoles.count * referenceCardCount + 2 /* open count, footer */   // 3 + 8 + 10 + 2 = 23 of 44
    public static let stageFraction = Double(OffseasonMetric.phaseRowHeight / ForgeFieldTokens.Space.viewport.height)   // 32 / 393
    public static let goldElementCount = 0
    public static let emberElementCount = 1
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

### 29 — spec column (transcribed)

**Register & budget:** Desk · one stated absence · stage 0% · data points 4 of 80 · largest numeral 34 (the sentence, not a figure) · gold 0 · ember 0 · ghost 1 · 300 · .13 · bleeds the right edge · flood none · backgrounds 1 of 2 — ground 1 with a lamp wash.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Field | 10, 44 | 832 × 339 | 1–12 |
| Statement | 54, 140 | 470 × auto | 1–7 |
| Ghost mark | 788, 66 | 300 × 300 | — |

No seam: a surface with one thing on it has nothing to divide. The ghost bleeds the right edge only, clear of every figure.

**Data:** the branch is `cyclePhase == .signing`; open → `CollegeOffseasonView(title: "SIGNING DAY")` (Task 7's own 61); closed → this statement.

### 29 — rulings

1. **A closed phase is not a failure**: no alarm signal, no failure ground, no red. A hollow quiet dot (`ink4`, hollow — "closed"), `Signing day · not this phase` in `.columnHead`, then the statement at `.title` (34): `Signing day is closed.` and beneath it in `.prose`: what survived, from the model — `You still have \(contactPointsRemaining) contact points. The board holds \(boardCount) of \(CollegeRules.recruitingBoardLimit). Nothing has been lost. The window opens on the cycle, not on this screen.` The sheet's `9 of 25` is not on this model and is not drawn.
2. **The lamp wash** is `04` 6.1e/spec 2.7's radial `rgb(255 235 210 / .28)` from above — add `ForgeFieldTokens.Material.lampWash = CoachWorldTokens.ColorValue(hex: 0xFFEBD2)` and `lampWashOpacity = 0.28` in this task (canon states both; the token layer lacked them because no 2B surface used one), drawn as a `RadialGradient` at the field's top centre. One background, plus the wash, is the stamped `1 of 2`.
3. **The ghost** is `ForgeFieldGhostMark(team: model.programme, ghost: budget.ghost, surface: club.palette.ground1)` positioned at 788, 66 and clipped by the device — the census entry for Signing day.

### 29 — assertable budget facts

```swift
// MARK: - Assertable budget facts

extension SigningDayView {
    public static let closedDataPointRoles: [String] = ["phase.name", "contact.left", "board.count", "board.limit"]
    public static let dataPointCount = closedDataPointRoles.count   // 4 of 4
    public static let stageFraction = 0.0
    public static let goldElementCount = 0
    public static let emberElementCount = 0
    public static let ghost = ForgeFieldBudget.Ghost(size: SigningDayMetric.ghostSize, opacity: ForgeFieldTokens.Register.ghostOpacity, desaturated: false)
    public static let backgroundCount = 1
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: ghost, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1: Read both spec columns, contract rows 29 and 61, both views, and `CoachWorldCollegeOffseasonProvider.swift` (the `No recorded cost` literal and the decision cap).**
- [ ] **Step 2: Register both facts; red.**
- [ ] **Step 3: Draw 61**: chrome · phase row (two chips + season) · seam · `HStack(ledger 271, decisions 552)` · footer with the ember. AX5: one scroll column, footer last.
- [ ] **Step 4: Draw 29**: the open branch unchanged (`CollegeOffseasonView(title:)`); the closed branch per the rulings, no chrome region change (it is a chromed surface: keep the bar).
- [ ] **Step 5: Build and suites.** `ContractTests` "settings and signing-day routes must be reachable in the active career" still passes.
- [ ] **Step 6: Render `PROOF_SCREEN_NUMBER=61` and `=29`**, standard and AX5. Check eight open decisions on 61 (cards scroll, `2 of 8` → `8 of 8`), and 29 in both phases.
- [ ] **Step 7: Commit twice.** `feat(ui): draw College offseason to the Forge Field sheet` then `feat(ui): draw Signing day's closed state to the Forge Field sheet` — bodies: 61 rulings 1–3; 29 rulings 1–2.

---

## Task 8: The family's ledger and STATUS rows

- [ ] **Step 1: One DONE row per surface** (Tasks 2–7), deviations named.
- [ ] **Step 2: One TODO row, "Recruiting read-model asks from the sheet"**: `ProspectContactEvent { week, actor, summary, effect }` (or delete the relationship column from 25 and 26); a scouted rating band on `Prospect`; `RecruitingWeek { day, contactSlots, visitSlots, note }` or a stated cut of the calendar from the reference; a separate visit counter in the engine or the pooled-resource wording kept; `ClassNeed { position, signed, target }`; a phase field on the board model; `MandatoryDecisionOption` recording a price or the cost line retired; a NIL label carrying its amount / `NILAllocationReadModel { budget, committed, perProspect[], onSet }` (id 33); `PortalEntry { player, position, from, window, interest }` (id 30); one `MarketReadModel` shape for ids 21 and 32; the offseason route stating the closed cycle instead of vanishing; the sample career pointed at the provider's label functions; and the provider fault if an offer is ever `isAvailable` at zero slots.
- [ ] **Step 2a: The row's asks close in 2I.** `docs/plans/2026-09-06-forge-field-phase-2i-completion-and-2j-release-candidate.md` Task I2 gives each ask a recorded disposition — design fact, projection, or not v1 — before anything is built; Task I18 draws the facts into this family's surfaces after this plan has merged.
- [ ] **Step 3: STATUS entry** — drawn, verified (exact counts), rendered, unpushed.
- [ ] **Step 4: Commit.** `docs: record the recruiting Forge Field conversion in the ledger and STATUS`

---

## Phase 2D exit

- [ ] `swift build`; `--design-contracts`; `--core-contracts` green (2S's platform-chrome scan now excludes `ShortlistView.swift`).
- [ ] Generic budget suite green with all seven recruiting surfaces registered.
- [ ] All seven rendered at standard and AX5, looked at; screenshots under `docs/proofs/forge-field/recruiting/`.
- [ ] Adversarial review on the phase diff; confirmed findings fixed first. Not a build.
- [ ] Full `swift run SimTests` green — once, here.
- [ ] Ledger and STATUS rows landed. **Ask the owner before any push or merge.**
