# Forge Field Phase 2E — Pro management

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** draw the five pro-management surfaces — Cap & contracts, Contract negotiation, Roster cuts & transactions, Draft room, Pro front office — to the Forge Field sheet, on the 2A shell and the 2S contract.

**Architecture:** budget table first, then one surface per task in the sheet's order. 34 and 36 read `ProManagementReadModel` through `ProManagementView(model:title:)`; 35 is `ContractNegotiationView`; 39 and 62 read `ProOffseasonReadModel` through `ProOffseasonView(focus:)`. The three declared aliases (37 Pro scouting, 38 Draft board, 40 Free agency) are `focus` filters over 62 and keep working unchanged; the sheet's promotion of 40 to canonical is a registry decision for the owner, recorded not made. This family is where the 2S formatter earns itself: every dollar figure prints through `ForgeFieldFormat.money`, every `CalendarState` through `ForgeFieldFormat.calendar`.

**Tech Stack:** iOS 26+, Swift 5.10 language mode, SwiftUI; `FootballSimCore` for `Contract`, `CalendarState`, `ProRules`.

**Spec:** `Game screens - Pro management.dc.html` (Forge Field project `8c511c92-3337-4cfb-850c-140a659f3034`), transcribed per surface below. Batch 4 of 7 · 8 ids · 5 surfaces · drawn on Maritime, hue 140. **Where this plan and the sheet disagree on a number, the sheet is right** — except under the adaptation rule and except where the presentation contract forbids the fact.

**Canon:** `04` 6.1e, 6.1f, 6.2a, 6.2a(i), 6.2a(ii), 6.3a, 6.3a(i), 6.6a, 6.7a, 7. **Contract:** rows 34, 35, 36, 39, 62. **Ledger:** Part E; next free rows at merge.

**Entry criterion:** Phase 2S merged.

## Global Constraints

Everything in `docs/plans/2026-09-06-forge-field-remaining-roadmap.md`'s Global Constraints, carried rulings and owner-decision defaults (FF-5 in particular) applies unchanged. Specific to this family, from the sheet:

- **One club, one ledger.** Pratt's `$5.42M` is the same figure on the cap panel, in the negotiation list and on the cut list: every money figure on every surface is `ForgeFieldFormat.money(_:)` of the same `Int`.
- **No pro mark was supplied**; the club's own packaged crest (or the truthful abbreviation fallback, E44) stands where the sheet drew the Maritime plate.
- **Two structural findings are the generator's, not the views'**: a new save starts with every club at 53 of 53, so every Draft / Sign / Claim is unavailable in the first frame; and bootstrap contracts carry `signingBonus: 0`, so dead money is structurally `$0`. **The surfaces draw that truth** — disabled controls with the provider's reason, `$0` where it is `$0` — and Task 7 records both as engine asks. Never a fabricated bonus, never an enabled draft.
- **Long-form position labels** (`Defensive tackle`, not `DT`) size the position columns: 96 on the cut list, 116 on the board.
- **Lists sort by something a coach reads.** Where the provider's order is a UUID string, the view sorts by cap hit descending and says so in the head row; where the contract forbids a sort the model does not impose (none of rows 34–62 do), it does not.
- **Contract omissions bind in full**: no cap forecast, projected space, trade value, scouting grade, contract demand or probability; an unavailable action prints its `unavailableReason` rather than disappearing (34); no demanded figure, acceptance probability or agent sentiment (35); no projected cap relief beyond the contract's own dead money, no replacement suggestion, no derived ranking (36); no invented draft order, trade value chart or projected pick, no grade beyond `estimatedOverall` and its stated `confidence` (39); no market forecast, invented free agent or waiver row, bidding probability or derived cap projection (62).

---

## The per-surface procedure

1. Read the surface's transcribed spec column below.
2. Read its contract row. Every drawn fact the model does not hold is an ask: not drawn, absence stated, listed in Task 7.
3. Register its facts; `swift run SimTests --design-contracts`; watch the generic suite fail.
4. Draw it inside `ForgeFieldDevice(club:)` from the primitives, `ForgeFieldEmber`, `ForgeFieldField`/`ForgeFieldStepper`, `ForgeFieldFormat`, `ForgeFieldType.font(_:)`; numbers in a `private enum XMetric`; keep callbacks, state, alerts (the existing confirm-before-release alert stays) and accessibility identifiers; standard **and** AX5 compositions. **The ember's `cost:` argument is always a named `private var emberCost: String`** (the rulings' expressions are its body): the cost-argument scan accepts only a string literal or a bare name, and a literal must not contain a comma.
5. `swift build`; `--design-contracts`; `--core-contracts`.
6. Render with `PROOF_SCREEN_NUMBER=<id>` on a **pro** career (start one, or use the `--pro-management` proof fixture route if `RootView` gains one in this phase); standard and AX5; look.
7. Commit, one per surface; deviations in the body and a ledger row.

---

## Task 1: The pro-management budget table

**Files:** Modify `Sources/ProFootballCoachUI/ForgeFieldBudget.swift`.

| Screen | Register | Stage | Points | Gold | Ember | Ghost | Backgrounds |
|---|---|---|---|---:|---:|---|---:|
| 34 Cap & contracts | Desk, figure-led, vertical seam | 19% · 74 of 393 | 52 of 80 | 0 | 1 · Release | 0 | 2 of 2 |
| 35 Contract negotiation | Desk, card-led, the only editable surface | 0% · nothing staged | 44 of 80 | 0 | 1 · Accept offer | 0 | 2 of 2 |
| 36 Roster cuts | Desk, table-led | 16% · 62 of 393 | 61 of 80 | 0 | 1 · Release | 0 | 2 of 2 |
| 39 Draft room | Desk, clock-led, phase-gated | 16% · 62 of 393 | 58 of 80 | 0 | 1 · Draft | 0 | 2 of 2 |
| 62 Pro front office | Desk, ledger-led | 8% · 32 of 393 | 54 of 80 | 0 | 1 · Begin draft | 0 | 2 of 2 |

- [ ] **Step 1: Add the table** and `.proManagement: proManagement,` in `tables`.
```swift
extension ForgeFieldBudget {
    /// The five pro-management surfaces, `Game screens - Pro management.dc.html`. Transcribed; nothing invented.
    public static let proManagement: [CoachWorldScreenID: ForgeFieldBudget] = [
        .capContracts: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: nil, detail: "figure-led, vertical seam"),
            // The sheet stamps "19% · 74 of 393" although its seam is vertical; transcribed as stamped.
            stageFraction: 0.19...0.19, dataPoints: 52, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface, ghost: nil, backgrounds: 2),
        .contractNegotiation: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: .action, detail: "card-led, the only editable surface"),
            stageFraction: 0.0...0.0, dataPoints: 44, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface, ghost: nil, backgrounds: 2),
        .rosterCutsTransactions: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: nil, detail: "table-led"),
            stageFraction: 0.16...0.16, dataPoints: 61, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface, ghost: nil, backgrounds: 2),
        .draftRoom: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: nil, detail: "clock-led, phase-gated"),
            stageFraction: 0.16...0.16, dataPoints: 58, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface, ghost: nil, backgrounds: 2),
        .proOffseason: ForgeFieldBudget(
            register: RegisterStamp(lean: .desk, tone: nil, detail: "ledger-led"),
            stageFraction: 0.08...0.08, dataPoints: 54, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface, ghost: nil, backgrounds: 2),
    ]
}
```
- [ ] **Step 2: `--design-contracts`** — coverage names the five. Correct red.
- [ ] **Step 3: Commit.** `feat(ui): stamp the pro-management register budgets as a contract`

---

## Task 2: Cap & contracts (34)

**Files:** Rewrite `Sources/ProFootballCoachUI/ProManagementView.swift` (the shared body; `CapContractsView` and `RosterCutsTransactionsView` are thin wrappers and stay thin — 36's composition is selected by the `title`/focus the wrapper passes, see Task 4). Delete the file-local `currency(_:)` helpers in `ProManagementView.swift`, `ContractNegotiationView.swift`, `ProOffseasonView.swift` and `DraftRoomView.swift` (the four copies); every figure goes through `ForgeFieldFormat.money`. Modify `ForgeFieldBudget.swift`.

**Consumes:** `ProManagementReadModel` (`team`, `coach`, `seasonLabel`, `calendar: CalendarState`, `cap: ProOffseasonReadModel.CapSummary { capLimit, committedCap, remainingCap, deadMoney, activeRosterCount, practiceSquadCount }`, `activeRoster[]`, `practiceSquad[]` of `PlayerRow { name, person, number, position, rosterKind, capHit, contract: Contract?, action: ActionRow? }`, `negotiations[]`); `ActionRow { title, detail, action: ProManagementAction, isAvailable, unavailableReason }`; `Contract.years`, `.deadMoney(ifReleasedAtSeason:)`; `ProRules.activeRosterLimit` (53) and `ProRules.practiceSquadLimit` (16); `onAction(ProManagementAction)`, `onClose`, `onNavigateChrome`.

### Spec column (transcribed)

**Register & budget:** Desk, figure-led · stage 19% · data points 52 of 80 · largest numeral 34 · gold 0 · ember 1 of 1 (Release) · ghost 0 · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Chrome bar | 10, 8 | 832 × 30 | 1–12 |
| Cap panel | 10, 44 | 271 × 339 | 1–4 |
| Seam · hard | 285, 44 | 1 × 339 | — |
| Hits panel | 290, 44 | 552 × 339 | 5–12 |
| Row × 6 | —, 63 | 528 × 44 | — |
| Action drawer | —, 107 | 552 × 44 | — |
| Ember | 632, 107 | 198 × 44 | — |

Vertical seam at x 285: left of it the one figure the surface exists to report, right of it the contracts that made it. Table columns `288 / 44 / 88 / 78` at 10 pt gutters.

**Type:** cap room 34 → `.title` + `.monospacedDigit()`; `Under the cap` 19 → `.panel`; cap facts 13.5 mono → `.row` + `.monospacedDigit()` in 32 dense rows (the sheet's 26 is off-ladder; inert, so 32); gauge figure → `.panel`; name `.row`; position · kind `.columnHead`; ember cost `ForgeFieldEmber.costStep`.

**Data:** `cap.remainingCap` → `$38.25M`; `remainingCap >= 0` → `Under the cap` / else `Over the cap` in alarm; `cap.committedCap`; `cap.deadMoney`; `cap.capLimit`; committed percent = `committedCap * 100 / capLimit` (integer, unclamped — can read 108%); `activeRosterCount` of `ProRules.activeRosterLimit`; `practiceSquadCount` of `ProRules.practiceSquadLimit`; `PlayerRow.name.uppercased()`; `position` (a full word); `rosterKind`; `contract.years` → `4 yrs`; `capHit` → `$5.42M`; `capHit * 1000 / capLimit` → `1.9%` (derived arithmetic on two model facts, one decimal); `action.title` → `Release`; `contract.deadMoney(ifReleasedAtSeason: calendar.season)` → `adds $0`.

### Rulings for this surface

1. **The ember is Release, for the selected row**; Negotiate is not an ember (it spends nothing). `@State selectedPlayerID` (first active row by default) opens the action drawer under that row: `ActionRow.detail` in `.proseMin`, then `ForgeFieldEmber(label: "RELEASE \(surname)", cost: "adds \(ForgeFieldFormat.money(deadMoney)) dead money · final", isEnabled: action.isAvailable, action: { onAction(action.action) })`; when `!isAvailable`, the cost line is `action.unavailableReason ?? "unavailable"` — *"The active roster needs one more Cornerback."* is the house voice already. The existing confirm alert before the release stays between the tap and `onAction`.
2. **The hits panel lists `activeRoster` sorted by `capHit` descending** (the provider's order is a UUID string), head row `Largest cap hits · sorted by cap hit · n of m`; six rows fit, the rest scroll. Practice squad follows under its own inner head.
3. **Negotiate is a quiet 44 pt control** in the cap panel's foot that routes to screen 35 through the chrome's sibling intent when `chrome?.siblings` carries `.contractNegotiation`; absent a chrome, it is absent (no fallback navigation — the E37 rule).
4. **Money prints through `ForgeFieldFormat.money`** everywhere on the surface; the raw-dollar scan from 2S goes green for these four files in this task.
5. **The ranked column is flat by construction** (bootstrap salaries spread ~2×) — drawn as it is; recorded as a generator ask.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension ProManagementView {
    public static let capDataPointRoles: [String] = [
        "cap.room", "cap.status", "cap.committed", "cap.deadMoney", "cap.limit", "cap.committedPercent",
        "roster.active", "roster.activeLimit", "roster.practice", "roster.practiceLimit",
    ]
    public static let hitRowDataPointRoles: [String] = ["row.name", "row.position", "row.kind", "row.years", "row.capHit", "row.ofCap"]
    public static let drawerDataPointRoles: [String] = ["action.detail", "action.deadMoney"]
    public static let referenceVisibleHitRowCount = 6
    public static let capDataPointCount = capDataPointRoles.count + hitRowDataPointRoles.count * referenceVisibleHitRowCount
        + drawerDataPointRoles.count   // 10 + 36 + 2 = 48 of 52
    public static let capStageFraction = 0.19   // transcribed from the sheet's own stamp; the seam is vertical
    public static let goldElementCount = 0
    public static let emberElementCount = 1
    public static let backgroundCount = 2
    public static let capFacts = ForgeFieldSurfaceFacts(
        stageFraction: capStageFraction, dataPointCount: capDataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```
`ForgeFieldBudget.facts`: `.capContracts: ProManagementView.capFacts,`. (Task 4 adds `cutsFacts` for `.rosterCutsTransactions`; the file has **one** `ForgeFieldEmber(` call site per composition branch — the ember-count scan counts call sites per file, so state in the doc comment that the two branches are exclusive, and if the scan cannot tell, split 36's composition into its own file `RosterCutsView.swift` hosted by the wrapper.)

- [ ] **Step 1: Read the spec column, contract row 34, `ProManagementView.swift`, `CapContractsView.swift`, `RosterCutsTransactionsView.swift`, and `Contract.swift:95–135`.**
- [ ] **Step 2: Register the facts; red.**
- [ ] **Step 3: Draw it.** Standard: chrome · `HStack(cap panel 271, vertical hard seam, hits panel 552)`. AX5: one scroll column, cap panel first.
- [ ] **Step 4: Build and suites** (ContractTests' cap-compliance and pro-management reachability assertions still pass).
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=34`** on a pro career. Check an over-the-cap save (108%, alarm), a player with no contract (`unseen` in the term and hit columns), the release drawer when unavailable.
- [ ] **Step 6: Commit.** `feat(ui): draw Cap & contracts to the Forge Field sheet and format every dollar figure` — body: rulings 1–3.

---

## Task 3: Contract negotiation (35)

**Files:** Rewrite `Sources/ProFootballCoachUI/ContractNegotiationView.swift` (keep `init`, `onAction`, `onClose`, `NegotiationCard`'s `onChange(of: negotiation.currentOffer)` re-seed — the sheet says that bug was found and fixed; keep it). Modify `ForgeFieldBudget.swift`.

**Consumes:** `ProManagementReadModel.negotiations[]` of `NegotiationRow { playerName, person, number, position, status: ProContractNegotiationStatus, currentOffer: Contract, offerCount, deadline: CalendarState }`; `activeRoster[]` for the startable list; `ProManagementAction.beginNegotiation`, `.counterNegotiation(negotiationID:offer:)`, `.acceptNegotiation(negotiationID:)`, and the withdraw/reject cases the provider emits (read `ProManagementSystem.swift:9–24` for the exact set).

### Spec column (transcribed)

**Register & budget:** Desk, card-led · stage 0% · data points 44 of 80 · largest numeral 26 (the name) · gold 0 · ember 1 of 1 (Accept offer) · closed out 72% + hollow dot (the expired card) · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Open card | 10, 44 | 552 × 184 | 1–8 |
| Expired card | 10, 240 | 552 × 88 | 1–8 |
| Retention note | 10, 340 | 552 × 43 | 1–8 |
| Seam · hard | 566, 44 | 1 × 339 | — |
| Startable list | 571, 44 | 271 × 339 | 9–12 |
| Terms row | —, 126 | 168 / 186 / 158 | — |

Vertical seam at x 566: left of it the offers that exist, right of it the players who could have one. The open card is the only place a coach types a number: the three terms sit on one 44 row and the four verbs on the next — never eight targets in one row.

**Data:** `playerName.uppercased()`; `status.rawValue` uppercased; `offerCount` → `Offer 3`; `currentOffer.totalValue` → `$19.89M total`; `deadline` → `ForgeFieldFormat.calendar(deadline)`; `currentOffer.years` (1…7); `currentOffer.baseSalaryByYear.first`; `currentOffer.signingBonus`; `status == .expired`; startable = contracted players without an open negotiation → `51 eligible`; `PlayerRow.capHit` → `$4.88M now`.

### Rulings for this surface

1. **Inputs are `ForgeFieldStepper` (years, `in: 1...7`, `unit: "years"`) and two `ForgeFieldField(isFigure: true)` money fields** (base per year, signing bonus) — the 2S platform-chrome scan loses this file. The bound `1...7` comes from the rule that owns it (`ProRules`, or `Contract`'s own validation) — cite it in `NegotiationMetric`; if no constant exists, add one in `ProRules` (a rules constant, never inline).
2. **The ember is Accept**: `ForgeFieldEmber(label: "ACCEPT OFFER", cost: "commits \(ForgeFieldFormat.money(currentOffer.totalValue)) · final", isEnabled: status.isOpen, action: { onAction(.acceptNegotiation(negotiationID: id)) })`. Withdraw, Reject and Counter are plain 44 controls on the verbs row; Counter sends the three fields as a `Contract`.
3. **A deadline prints as `Deadline season N, week W`** through `ForgeFieldFormat.calendar`, with `two weeks out` / `passed n weeks ago` computed from `model.calendar` — arithmetic on two `CalendarState`s the model holds.
4. **The expired card is closed out**: 72% opacity (`NegotiationMetric.closedOutOpacity = 0.72`, from the standard's interaction states) and a hollow dot; nothing on it is tappable.
5. **The startable list sorts by `capHit` descending** and its head says so; tapping a row sends `beginNegotiation` for that player through `onAction`.
6. **The retention note** is the surface's own sentence: `Every offer here is retained. Nothing is committed until you accept it.`
7. **No text input on a floodlit ground uses platform styling.** `.textFieldStyle(.roundedBorder)` and `Stepper(` leave this file.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension ContractNegotiationView {
    public static let openCardDataPointRoles: [String] = [
        "card.name", "card.position", "card.status", "card.offerCount", "card.total", "card.deadline", "card.distance",
        "terms.years", "terms.base", "terms.bonus",
    ]
    public static let closedCardDataPointRoles: [String] = ["closed.name", "closed.position", "closed.status", "closed.offerCount", "closed.total", "closed.deadline"]
    public static let startableRowDataPointRoles: [String] = ["startable.name", "startable.capHit"]
    public static let referenceStartableRowCount = 6
    public static let dataPointCount = openCardDataPointRoles.count + closedCardDataPointRoles.count
        + startableRowDataPointRoles.count * referenceStartableRowCount + 1 /* eligible count */   // 10 + 6 + 12 + 1 = 29 of 44
    public static let stageFraction = 0.0
    public static let goldElementCount = 0
    public static let emberElementCount = 1
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1: Read the spec column, contract row 35, the view, `ProContractNegotiation.swift`, `ProManagementSystem.swift`.**
- [ ] **Step 2: Register the facts; red.**
- [ ] **Step 3: Draw it.** Standard: chrome · `HStack(cards column 552 scrolling, vertical hard seam, startable list 271)`. AX5: one scroll column; the terms row stacks three fields; the verbs row stacks four controls.
- [ ] **Step 4: Build and suites.**
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=35`**; open a negotiation from the startable list; counter; check the fields re-seed after the counter; AX5.
- [ ] **Step 6: Commit.** `feat(ui): draw Contract negotiation to the Forge Field sheet with the house field and stepper` — body: rulings 1–4.

---

## Task 4: Roster cuts & transactions (36)

**Files:** Modify `Sources/ProFootballCoachUI/ProManagementView.swift` (add the cuts composition, selected when the wrapper passes `.rosterCutsTransactions`) or create `RosterCutsView.swift` hosted by `RosterCutsTransactionsView` (see Task 2's note on the ember-count scan; prefer the separate file). Modify `ForgeFieldBudget.swift`.

### Spec column (transcribed)

**Register & budget:** Desk, table-led · stage 16% · 62 of 393 · data points 61 of 80 · dense rows 7 × 32 (the floor table is inert) · touch rows 4 × 44 (each opens a release) · ember 1 of 1 (Release) · gold 0 · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Limit strip | 10, 44 | 832 × 62 | 1–12 |
| Seam · hard | 10, 114 | 832 × 1 | 1–12 |
| Floor table (sheet) | 10, 122 | 341 × 261 | 1–5 |
| Cut list | 360, 122 | 482 × 261 | 6–12 |
| Ember | 632, 53 | 198 × 44 | — |

Cut list columns `165 / 96 / 56 / 52 / 48`. Position is 96 because `positionLabel()` returns `Defensive tackle`, not `DT`.

**Data:** `cap.activeRosterCount` of `ProRules.activeRosterLimit`; `cap.practiceSquadCount` of its limit; `canRelease` → `action.isAvailable`; `contract.deadMoney(ifReleasedAtSeason:)` → `$0 dead`; `action.unavailableReason` → `needs one more Kicker` verbatim.

### Rulings for this surface (FF-5)

1. **The floor table is not drawn.** `activeByPosition` and the per-position floors are provider-local and not on the model; contract row 36 forbids a derived roster ranking. **The cut list takes the full width: `10, 122` `832 × 261`**, columns `1fr / 96 / 56 / 88 / 88` (name · position · cut legal · dead money · cap hit). Recorded as an ask (`positionFloors: [{ position, signed, floor }]`) and as the FF-5 owner decision.
2. **`Saves` is not drawn** — contract row 36: *no projected cap relief beyond the contract's own dead money.* Dead money and cap hit are the two figures.
3. **`Cuts legal 27 of 53` is not drawn**; the limit strip prints the two roster counts and `n releasable · m blocked` — a tally of `action.isAvailable` over the rows, arithmetic on retained facts.
4. **`Why you are here` states only what the model holds**: `statusMessage` when present, else nothing — `Tavares is claimable on waivers` is 62's fact, not this model's.
5. **The ember is Release for the selected row** (default: the cheapest releasable, by `capHit` ascending among `isAvailable` rows — the only order a coach opening a cut screen is looking for; stated in the head row), with the Task 2 cost line and the existing confirm alert. A blocked row keeps its row, prints its `unavailableReason` (the house voice, verbatim) in caution ink, and selecting it disables the ember with that reason as the cost line.
6. **`& Transactions` has no data** — the title stays (the registry's), and the surface's foot states `Transactions · no ledger on this model` in ink 4. Recorded as an ask (project `DomainEvent.proCapComplianceRelease`).
7. **Rows are 44** (each opens a release); the head row is 19 (nothing in it is tappable).

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension RosterCutsView {
    public static let stripDataPointRoles: [String] = ["roster.active", "roster.activeLimit", "roster.practice", "roster.practiceLimit", "cuts.releasable", "cuts.blocked"]
    public static let rowDataPointRoles: [String] = ["row.name", "row.term", "row.position", "row.legal", "row.deadMoney", "row.capHit"]
    public static let referenceVisibleRowCount = 5
    public static let dataPointCount = stripDataPointRoles.count + rowDataPointRoles.count * referenceVisibleRowCount + 1 /* transactions absence */   // 6 + 30 + 1 = 37 of 61
    public static let stageFraction = Double(CutsMetric.stripHeight / ForgeFieldTokens.Space.viewport.height)   // 62 / 393
    public static let goldElementCount = 0
    public static let emberElementCount = 1
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(
        stageFraction: stageFraction, dataPointCount: dataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1: Read the spec column, contract row 36, `RosterCutsTransactionsView.swift`, the provider's `canRelease`.**
- [ ] **Step 2: Register the facts; red.**
- [ ] **Step 3: Draw it.** Standard: chrome · limit strip with the ember at its trailing edge · seam · cut list. AX5: one scroll column.
- [ ] **Step 4: Build and suites.**
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=36`.** Check a roster where nothing is releasable (ember disabled, every row blocked with its reason), and a contract with a real bonus if one exists in the fixture (dead money non-zero).
- [ ] **Step 6: Commit.** `feat(ui): draw Roster cuts to the Forge Field sheet from the facts the model holds` — body: rulings 1–4, FF-5.

---

## Task 5: Draft room (39)

**Files:** Rewrite the draft-phase composition of `Sources/ProFootballCoachUI/ProOffseasonView.swift` reached through `DraftRoomView` (`focus: .draftRoom`); keep the closed-phase branch (`Draft room is closed` in the house voice). Modify `ForgeFieldBudget.swift`.

**Consumes:** `ProOffseasonReadModel` (`team`, `phase: ProMarketPhase`, `cap`, `currentPickTeamID: UUID?`, `nextPick`, `totalPicks`, `actions[]`, `prospects[] { name, position, estimatedOverall: Int?, confidence: Int?, action: ActionRow? }`); `ProMarketAction.draft`; `onAction(ProMarketAction)`, `onClose`.

### Spec column (transcribed)

**Register & budget:** Desk, clock-led · stage 16% · 62 of 393 · data points 58 of 80 · rivals cold slate · unseen 3 of 5 rows (stated, never 0) · ember 1 of 1 (Draft) · gold 0 (the club plate only) · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Clock strip | 10, 44 | 832 × 62 | 1–12 |
| Seam · hard | 10, 114 | 832 × 1 | 1–12 |
| Board | 10, 122 | 552 × 261 | 1–8 |
| Subject panel | 571, 122 | 271 × 261 | 9–12 |
| Row × 5 | —, 141 | 528 × 44 | — |

Columns `34 / 116 / 204 / 62 / 72`; the estimate column is 62 because `unseen` is a legal value in it.

**Data:** `nextPick + 1` of `totalPicks` → `41 of 224`; `currentPickTeamID`; `prospects[].name.uppercased()`; `position` (drawn cold — a rival's asset until it is yours); `estimatedOverall` (nil → `unseen`); `confidence`; `action` → `Draft`; `action.detail` → the rookie contract sentence; `action.unavailableReason` → `The active roster is full at 53.`; `phase`.

### Rulings for this surface

1. **The clock prints the flat index only**: `Pick 41 of 224`. `Round 2, pick 9` is derived from rules the model does not carry — not drawn; recorded as an ask (round and pick order on the model).
2. **Whose pick**: `currentPickTeamID` resolved against `model.team`'s engine id if the reference carries one; when it matches, `On the clock · your pick`; when it does not, `On the clock · another club` — the UUID is never printed or spoken. If the reference cannot be compared, `unseen`.
3. **Confidence is drawn**: `est. 81 · confidence 62` in `.figure`; `estimatedOverall == nil` → `unseen` in ink 4; `confidence == nil` → `no look`. No band bar — the model states no scale.
4. **The ember is Draft for the selected prospect**: `ForgeFieldEmber(label: "DRAFT \(surname)", cost: "spends pick \(nextPick + 1) of \(totalPicks) · final", isEnabled: action.isAvailable, action: { onAction(action.action) })`; unavailable → cost line `action.unavailableReason`. In a fresh save this is disabled on every prospect, and that is the truth (Task 7 records the generator ask).
5. **The subject panel** is the selected prospect: name, position, `action.title · action.detail`, and the unavailable reason in caution ink.
6. **Rows are 44** (select); `n more in the class · k unseen` in the head row; sort is the provider's (`sorted by identifier` stated honestly) unless the provider changes.
7. **Outside the draft phase** the existing closed state stays, restyled: hollow quiet dot, `Draft room is closed · phase: \(phase)`, and what survived (`cap room`, `active count`).

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension ProOffseasonView {
    public static let clockDataPointRoles: [String] = ["clock.pick", "clock.total", "clock.whose", "clock.capRoom", "clock.active", "clock.activeLimit"]
    public static let boardRowDataPointRoles: [String] = ["row.rank", "row.position", "row.name", "row.estimate", "row.confidence"]
    public static let subjectDataPointRoles: [String] = ["subject.name", "subject.position", "subject.estimate", "subject.action", "subject.detail", "subject.reason"]
    public static let referenceBoardRowCount = 5
    public static let draftDataPointCount = clockDataPointRoles.count + boardRowDataPointRoles.count * referenceBoardRowCount
        + subjectDataPointRoles.count   // 6 + 25 + 6 = 37 of 58
    public static let draftStageFraction = Double(DraftMetric.clockHeight / ForgeFieldTokens.Space.viewport.height)   // 62 / 393
    public static let goldElementCount = 0
    public static let emberElementCount = 1
    public static let backgroundCount = 2
    public static let draftFacts = ForgeFieldSurfaceFacts(
        stageFraction: draftStageFraction, dataPointCount: draftDataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```
(Task 6 adds `officeFacts`. As in Task 2, if one file hosting two compositions confuses the per-file ember scan, split the draft composition into `DraftRoomView.swift` proper, which today is a 2 KB wrapper.)

- [ ] **Step 1: Read the spec column, contract row 39, `DraftRoomView.swift`, `ProOffseasonView.swift`, `ProOffseasonReadModels.swift`.**
- [ ] **Step 2: Register the facts; red.**
- [ ] **Step 3: Draw it.** Standard: chrome · clock strip (pick, whose, cap room, active, the ember at the trailing edge) · seam · `HStack(board 552, subject 271)`. AX5: one scroll column.
- [ ] **Step 4: Build and suites** (the `--pro-market` and reachability suites).
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=39`** in the draft phase (advance a pro career to it) and outside it.
- [ ] **Step 6: Commit.** `feat(ui): draw Draft room to the Forge Field sheet` — body: rulings 1–4.

---

## Task 6: Pro front office (62)

**Files:** Rewrite the offseason composition of `Sources/ProFootballCoachUI/ProOffseasonView.swift` (`focus: .proOffseason`; the `.freeAgency`, `.draftBoard`, `.proScoutingBoard` focuses keep their filters and phase gates). Modify `ForgeFieldBudget.swift`.

**Consumes:** `ProOffseasonReadModel.freeAgents[] { name, position, action }`, `waivers[] { name, deadline: String, action }`, `actions[] { title, detail, action, isAvailable, unavailableReason }`, `cap`, `phase`.

### Spec column (transcribed)

**Register & budget:** Desk, ledger-led · stage 8% · 32 of 393 · data points 54 of 80 · dense row 1 × 32 (the cap strip, inert) · disabled: 7 rows at 72% (the cost line said why) · ember 1 of 1 (Begin draft) · gold 0 · backgrounds 2 of 2.

**Geometry**

| Element | x,y | w×h | cols |
|---|---|---|---|
| Cap strip | 10, 44 | 832 × 32 | 1–12 |
| Seam · hard | 10, 84 | 832 × 1 | 1–12 |
| Market | 10, 92 | 481 × 291 | 1–7 |
| Waivers | 500, 92 | 342 × 291 | 8–12 |
| Ember | 281, 351 | 198 × 44 | — |

Horizontal seam at y 84, immediately under the cap strip. Market columns `96 / 1fr / 96`.

**Data:** `phase` → `Phase · free agency` (closed, freeAgency, draft, rosterBuild); `freeAgents.count` of the provider's cap → `9 of 512`; `freeAgents[].name.uppercased()`; the price from `action.detail` (the provider's own sentence about the one-year minimum); `action.unavailableReason` → `The active roster is full.`; `waivers[].deadline` verbatim (a pre-formatted string); `actions[]` → `Begin draft`, `Resolve expired waivers`.

### Rulings for this surface

1. **One ember from `actions[]`**: the first `isAvailable` league-wide action in provider order (`Begin draft` in the sheet's phase) — `ForgeFieldEmber(label: action.title.uppercased(), cost: action.detail, isEnabled: true, action: { onAction(action.action) })`; every other entry of `actions[]` is a plain 44 row with its detail. When none is available, the ember is drawn disabled with the first action's `unavailableReason` as its cost line — never removed. `action.detail` is the recorded consequence (*"Move the league to the controlled draft clock."*).
2. **Every market row keeps its price and its reason**: a free agent row prints `name · position · action.detail`, and when `!isAvailable` the row sits at 72% with `unavailableReason` — `Nine available, none signable. The active roster is full.` is the honest drawing.
3. **Waivers**: `name · Due <deadline>` from the model's string; `Deadline passed` when the provider says so via the row's `action.unavailableReason`; `n open · m expired` in the head from the rows.
4. **The cap strip is one 32 dense row** — inert — `Cap room · Committed · Dead money · Active`, all through `ForgeFieldFormat.money`.
5. **`lastCapHit` and `age` are not on `FreeAgentRow`** — not drawn; ask recorded.

### Assertable budget facts

```swift
// MARK: - Assertable budget facts

extension ProOffseasonView {
    public static let capStripDataPointRoles: [String] = ["strip.capRoom", "strip.committed", "strip.deadMoney", "strip.active", "strip.activeLimit", "strip.phase"]
    public static let marketRowDataPointRoles: [String] = ["market.position", "market.name", "market.price"]
    public static let waiverRowDataPointRoles: [String] = ["waiver.name", "waiver.deadline"]
    public static let referenceMarketRowCount = 4
    public static let referenceWaiverRowCount = 3
    public static let officeDataPointCount = capStripDataPointRoles.count + marketRowDataPointRoles.count * referenceMarketRowCount
        + waiverRowDataPointRoles.count * referenceWaiverRowCount + 3 /* market count, waiver counts, action detail */   // 6 + 12 + 6 + 3 = 27 of 54
    public static let officeStageFraction = Double(OfficeMetric.capStripHeight / ForgeFieldTokens.Space.viewport.height)   // 32 / 393
    public static let officeFacts = ForgeFieldSurfaceFacts(
        stageFraction: officeStageFraction, dataPointCount: officeDataPointCount, goldElementCount: goldElementCount,
        emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```

- [ ] **Step 1: Read the spec column, contract row 62, the view, and the three alias wrappers.**
- [ ] **Step 2: Register the facts; red.**
- [ ] **Step 3: Draw it.** Standard: chrome · cap strip · seam · `HStack(market 481, waivers 342)` with the ember at the market panel's foot. AX5: one scroll column. The `.freeAgency` focus draws the market half alone with its written gate; `.draftBoard`/`.proScoutingBoard` draw the Task 5 board.
- [ ] **Step 4: Build and suites** (`ContractTests`: "professional offseason must be reachable only through the market seam").
- [ ] **Step 5: Render `PROOF_SCREEN_NUMBER=62`** in free agency, then the three aliases via their own numbers (37, 38, 40).
- [ ] **Step 6: Commit.** `feat(ui): draw Pro front office to the Forge Field sheet` — body: rulings 1–2.

---

## Task 7: The family's ledger and STATUS rows

- [ ] **Step 1: One DONE row per surface** (Tasks 2–6).
- [ ] **Step 2: One TODO row, "Pro-management read-model and engine asks from the sheet"**: `positionFloors` on `ProManagementReadModel` (FF-5); a transactions ledger projected from `DomainEvent.proCapComplianceRelease`; `round` and pick order on `ProOffseasonReadModel`; `lastCapHit` and `age` on `FreeAgentRow`; provider sorts by something a coach reads (eight UUID-sorted lists); **generator: leave roster headroom** (`initialRosterByPosition` sums to `activeRosterLimit`, so every draft, sign and claim is unavailable in the first frame — two of five surfaces have no legal action); **generator: signing bonuses**, so dead money exists and the ranked column has a spread; a `years` bound constant in `ProRules` if one had to be added; and the registry decision on 40 (promote to canonical) and 38/39 (merge).
- [ ] **Step 2a: The row's asks close in 2I.** `docs/plans/2026-09-06-forge-field-phase-2i-completion-and-2j-release-candidate.md` Task I3 gives each ask a recorded disposition — design fact, projection, or not v1 — before anything is built; Task I18 draws the facts into this family's surfaces after this plan has merged.
- [ ] **Step 3: STATUS entry.**
- [ ] **Step 4: Commit.** `docs: record the pro-management Forge Field conversion in the ledger and STATUS`

---

## Phase 2E exit

- [ ] `swift build`; `--design-contracts` (the raw-dollar scan now green; the platform-chrome scan excludes `ContractNegotiationView.swift`); `--core-contracts` green.
- [ ] Generic budget suite green with all five pro surfaces registered.
- [ ] All five rendered at standard and AX5 on a pro career, looked at; screenshots under `docs/proofs/forge-field/pro-management/`.
- [ ] Adversarial review on the phase diff; confirmed findings fixed first. Not a build.
- [ ] Full `swift run SimTests` green — once, here.
- [ ] Ledger and STATUS rows landed. **Ask the owner before any push or merge.**
