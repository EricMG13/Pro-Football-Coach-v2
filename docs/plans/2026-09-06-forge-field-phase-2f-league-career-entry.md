# Forge Field Phase 2F — League, career and entry

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** draw the twenty-one league, career and entry surfaces to the Forge Field sheet — eleven league (World search, Map, Team profile, Standings, Schedule, Rankings, Bracket, Statistics, Awards, News, Realignment), nine career (Opportunities, Stakeholders, Promotion, Record book, Rivalries, Career line, Coaching tree, Title, Settings) and one entry (Coach identity) — on the 2A shell and the 2S contract.

**Architecture:** three budget tables first (`league`, `career`, `entry`), then the one shared piece this file owns (a filter rail, which the career route bar, the world search tier filter and the statistics category rail all are), then one task per view file in the sheet's order. Views that host several canonical ids by `focus` (`CompetitionOverviewView` for 45/46, `CareerHubView` for 52/54/55, `LegacyHistoryView` for 57–60) are one task each with one facts entry per id. Twenty-one surfaces run on nine read models; **the sheet's own closing finding is that the read models are where the product thins out** — a string where a reference belongs, an integer where a quantity belongs — and every one of those is drawn around honestly here and recorded as an ask, never patched in a view.

**Tech Stack:** iOS 26+, Swift 5.10 language mode, SwiftUI; `FootballSimCore` for `CollegeRules.bracketTeams`, `SharedRules.callInsPerGameRange`.

**Spec:** `Game screens - League, career and entry.dc.html` (Forge Field project `8c511c92-3337-4cfb-850c-140a659f3034`), transcribed per surface below. Batches 5–7 · 26 ids · 21 surfaces · drawn on Binghamton, hue 288 (season 4, week 9, 6–2, #18). **Where this plan and the sheet disagree on a number, the sheet is right** — except under the adaptation rule and except where the presentation contract forbids the fact.

**Canon:** `04` 6.1e, 6.1e(i), 6.1e(ii), 6.1f, 6.1f(i), 6.2a, 6.2a(i), 6.2a(ii), 6.3a, 6.3a(i), 6.6a, 6.7a, 7. **Contract:** rows 1, 2, 6, 7, 41–46, 48–52, 54, 55, 57–60. **Ledger:** Part E; next free rows at merge.

**Entry criterion:** Phase 2S merged, including the `04` 6.1e(i) and 6.1e(ii) amendments (FF-2, FF-4).

**Parallel worktree:** yes — runs beside 2C, 2D, 2E and 2I. Merge surface: `ForgeFieldBudget.swift` (`Lean.entry`, three tables), `ForgeFieldPrimitives.swift` (the filter rail, Task 2), `FloodlitFamilyRouteBar.swift`, `DesignContractTests.swift` (two additions), this family's view files. Roadmap §Running phases as parallel worktree sessions.

## Global Constraints

Everything in `docs/plans/2026-09-06-forge-field-remaining-roadmap.md`'s Global Constraints, carried rulings and owner-decision defaults (FF-2, FF-3, FF-4, FF-6, FF-7) applies unchanged. Specific to these families, from the sheet:

- **A rival is cold slate, always.** The map's place plates are the one legal club-hex fill (a plate holding a mark is identity, not a chart series); a standings bar or row band in a club hex is illegal.
- **`value: Int` with no unit, five times** (statistics, awards, news weight, records, rivalry intensity) and **no bound on support** (52, 54): the figure prints as the model holds it, its head names what the model calls it, and no denominator, scale, threshold or colour is assumed. A colour coding that is guessed is worse than none.
- **A string where a reference belongs** (awards `winner`, realignment's six programme strings, coaching tree's names): no route is drawn from it, and no `isControlled` is inferred by string comparison.
- **A pre-formatted string prints verbatim** (`score`, `week`, `meetings[]`, `occurred`): nothing parses it to find a winner, a margin, a season number or a sort key. Where the existing view already renumbers a zero-based season (Career line, Rivalries), that behaviour is kept — the contract makes existing views authoritative on facts — and the ask is recorded.
- **The Entry register** (FF-4, `04` 6.1e(ii)) has no chrome bar, no seam, and the Calumet device palette; club colour is scoped by `.environment(\.forgeFieldClub, …)` to the one panel or card that has one.
- **Contract omissions bind in full** for every row named above.

---

## The per-surface procedure

1. Read the surface's transcribed spec column below.
2. Read its contract row. Every drawn fact the model does not hold is an ask: not drawn, absence stated, listed in Task 18.
3. Register its facts; `swift run SimTests --design-contracts`; watch the generic suite fail.
4. Draw it inside `ForgeFieldDevice(club:)` from the primitives, `ForgeFieldEmber`, `ForgeFieldGhostMark`, `ForgeFieldField`/`ForgeFieldStepper`, `ForgeFieldFilterRail` (Task 2), `ForgeFieldFormat`, `ForgeFieldType.font(_:)`; numbers in a `private enum XMetric`; keep callbacks, state, alerts and accessibility identifiers; standard **and** AX5 compositions. **The ember's `cost:` argument is always a named `private var emberCost: String`** (the rulings' expressions are its body): the cost-argument scan accepts only a string literal or a bare name, and a literal must not contain a comma.
5. `swift build`; `--design-contracts`; `--core-contracts`.
6. Render with `PROOF_SCREEN_NUMBER=<id>` (Title and Coach identity need none — they are what launches before a career), standard and AX5; look.
7. Commit, one per view file; deviations in the body and a ledger row.

---

## Task 1: The league, career and entry budget tables

**Files:** Modify `Sources/ProFootballCoachUI/ForgeFieldBudget.swift` (three tables; add `case entry` to `Lean`). Modify the 2S generic suite: add an `.entry` clause.

| Screen | Register | Stage | Points | Gold | Ember | Ghost | Backgrounds |
|---|---|---|---|---:|---:|---|---:|
| 7 World search | Desk, table-led, no committing control | 11% · 44 | 34 of 80 | 0 | 0 | 0 | 2 |
| 41 League map | Desk, field-led | 0% · the field is studied | 39 of 80 | 0 | 0 | 0 · the map is the picture (one club flood at 158°) | not stamped |
| 42 Team profile | Dossier, plate-led | 33% · 130 | 41 of 80 | 2 of 2 · record and rank (FF-2: only when yours) | 0 | 260 · .13 · top-right | not stamped |
| 43 Standings | Desk, table-led | 8% · 32 | 52 of 80 | 0 | 0 | 0 | not stamped |
| 44 Schedule | Desk, table-led | 11% · 44 | 48 of 80 | 0 | 0 | 0 | not stamped |
| 45 Rankings | Desk, table-led | 8% · 32 | 56 of 80 | 0 | 0 | 0 | not stamped |
| 46 Bracket | Desk, field-led | 8% · 32 | 44 of 80 | 0 (FF-3) | 0 | 0 | not stamped |
| 48 Statistics | Desk, table-led | 11% · 44 | 47 of 80 | 0 | 0 | 0 | not stamped |
| 49 Awards | Dossier, plate-led | 33% · 130 | 32 of 80 | 2 of 2 · the star and the honour line | 0 | 260 · .13 · bottom-right | not stamped |
| 50 News | Desk, list-led | 8% · 32 | 19 of 80 | 0 | 0 | 0 | not stamped |
| 51 Realignment | Desk, event-led | 16% · 62 | 24 of 80 | 0 | 0 | 0 | not stamped |
| 52 Opportunities | Desk, table-led | 16% · 62 | 44 of 80 | 0 | 1 · Accept | 0 | not stamped |
| 54 Stakeholders | Desk, table-led | 8% · 32 | 31 of 80 | 0 | 0 | 0 | not stamped |
| 55 Promotion | Dossier, plate-led | 33% · 130 | 26 of 80 | 0 · an offer is not an achievement | 1 · Accept | 260 · .13 · top-right (census) | not stamped |
| 57 Record book | Desk, table-led | 8% · 32 | 38 of 80 | 0 (FF-3; the sheet drew 2 and said so) | 0 | 0 | not stamped |
| 58 Rivalries | Desk, table-led | 16% · 62 | 33 of 80 | 0 | 0 | 0 | not stamped |
| 59 Career line | Desk, table-led | 8% · 32 | 22 of 80 | 0 | 0 | 0 | not stamped |
| 60 Coaching tree | Desk, list-led | 0% | 17 of 80 | 0 | 0 | 0 | not stamped |
| 1 Title | Entry (FF-4) | none | 11 of 20 | 0 | 1 · Use the backup | 260 · .13 · inside the save panel, bottom-right | not stamped |
| 6 Settings | Desk, declaration-led, no seam | 0% | 6 of 80 | 0 | 0 | 0 | not stamped |
| 2 Coach identity | Entry (FF-4) | none | 21 of 20 → **20** (the register's cap; cut one row, never type) | 0 | 1 · Start | 230 · .13 · top-right of each card | not stamped |

- [ ] **Step 1: Add `case entry` to `ForgeFieldBudget.Lean`** with a doc comment citing `04` 6.1e(ii), and in the 2S generic suite's register-rule test add:
```swift
                    case .entry:
                        expectEqual(budget.goldMax, 0, "\(screen.canonicalName) is Entry: zero gold")
                        expect(budget.emberCount <= 1, "\(screen.canonicalName) is Entry: at most one ember")
                        expect(budget.stageFraction == nil, "\(screen.canonicalName) is Entry: no seam, no stage")
```
- [ ] **Step 2: Add the three tables** and the three `tables` lines (`.league: league`, `.career: career`, `.entry: entry`).
```swift
extension ForgeFieldBudget {
    private static func desk(_ detail: String, stage: Double, points: Int, tone: Tone? = nil, ember: Int = 0) -> ForgeFieldBudget {
        ForgeFieldBudget(register: RegisterStamp(lean: .desk, tone: tone, detail: detail),
                         stageFraction: stage...stage, dataPoints: points, pointsAboveSeam: nil,
                         goldMax: 0, emberCount: ember, ghost: nil, backgrounds: nil)
    }

    /// The eleven league surfaces, `Game screens - League, career and entry.dc.html`. Transcribed.
    public static let league: [CoachWorldScreenID: ForgeFieldBudget] = [
        .worldSearch: desk("table-led, no committing control", stage: 0.11, points: 34, tone: .readout),
        .leagueMap: desk("field-led, one club flood at 158 degrees", stage: 0.0, points: 39, tone: .readout),
        .teamProgrammeProfile: ForgeFieldBudget(
            register: RegisterStamp(lean: .dossier, tone: .readout, detail: "plate-led, four surfaces route here"),
            stageFraction: 0.33...0.33, dataPoints: 41, pointsAboveSeam: nil,
            // 04 6.1e(i): record and rank take gold only when the profiled team is the controlled club.
            goldMax: ForgeFieldTokens.Register.goldMaxDossier, emberCount: 0,
            ghost: Ghost(size: 260, opacity: ForgeFieldTokens.Register.ghostOpacity, desaturated: false), backgrounds: nil),
        .standings: desk("table-led", stage: 0.08, points: 52, tone: .readout),
        .schedule: desk("table-led, played above, unplayed below", stage: 0.11, points: 48, tone: .readout),
        .rankingsPlayoffPicture: desk("table-led, two ranks, one row", stage: 0.08, points: 56, tone: .readout),
        // FF-3: zero gold. The champion is not a field, so the question of gold for one is moot.
        .bracketPostseason: desk("field-led, 8 teams, 3 rounds", stage: 0.08, points: 44, tone: .readout),
        .statisticsLeaders: desk("table-led, one flat array", stage: 0.11, points: 47, tone: .readout),
        .awardsHonours: ForgeFieldBudget(
            register: RegisterStamp(lean: .dossier, tone: .readout, detail: "plate-led, the only gold in the league family"),
            stageFraction: 0.33...0.33, dataPoints: 32, pointsAboveSeam: nil,
            goldMax: ForgeFieldTokens.Register.goldMaxDossier, emberCount: 0,
            ghost: Ghost(size: 260, opacity: ForgeFieldTokens.Register.ghostOpacity, desaturated: false), backgrounds: nil),
        .news: desk("list-led", stage: 0.08, points: 19, tone: .readout),
        .realignmentEvent: desk("event-led, at most two swaps", stage: 0.16, points: 24, tone: .readout),
    ]

    /// The nine career surfaces. Transcribed; FF-3 and FF-4 applied where the sheet asked for a decision.
    public static let career: [CoachWorldScreenID: ForgeFieldBudget] = [
        .careerHub: desk("table-led, six ids read this model", stage: 0.16, points: 44, ember: ForgeFieldTokens.Register.emberPerSurface),
        .stakeholders: desk("table-led, 52's support array at full width", stage: 0.08, points: 31, tone: .readout),
        .promotionDecision: ForgeFieldBudget(
            register: RegisterStamp(lean: .dossier, tone: nil, detail: "plate-led, one row of 52 at size"),
            stageFraction: 0.33...0.33, dataPoints: 26, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface,
            ghost: Ghost(size: 260, opacity: ForgeFieldTokens.Register.ghostOpacity, desaturated: false), backgrounds: nil),
        .recordBook: desk("table-led, one of four views on one history model", stage: 0.08, points: 38, tone: .readout),
        .rivalries: desk("table-led", stage: 0.16, points: 33, tone: .readout),
        .careerLine: desk("table-led, sorted by season then id", stage: 0.08, points: 22, tone: .readout),
        .coachingTree: desk("list-led, names only", stage: 0.0, points: 17, tone: .readout),
        .titleContinue: ForgeFieldBudget(
            register: RegisterStamp(lean: .entry, tone: nil, detail: "no chrome, drawn in its recovery state"),
            stageFraction: nil, dataPoints: 20, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface,
            ghost: Ghost(size: 260, opacity: ForgeFieldTokens.Register.ghostOpacity, desaturated: false), backgrounds: nil),
        .settingsAccessibility: desk("declaration-led, one control, no seam", stage: 0.0, points: 6, tone: .readout),
    ]

    /// The one entry surface (5 Appointment is an alias of 52).
    public static let entry: [CoachWorldScreenID: ForgeFieldBudget] = [
        .newCareerCoachIdentity: ForgeFieldBudget(
            register: RegisterStamp(lean: .entry, tone: nil, detail: "no chrome, three clubs, one per card"),
            stageFraction: nil, dataPoints: 20, pointsAboveSeam: nil,
            goldMax: 0, emberCount: ForgeFieldTokens.Register.emberPerSurface,
            ghost: Ghost(size: 230, opacity: ForgeFieldTokens.Register.ghostOpacity, desaturated: false), backgrounds: nil),
    ]
}
```
`CoachWorldSurfaceFamily.career.surfaces` is the nine above and `.entry.surfaces` is the one — the coverage test proves it; if the registry disagrees, the registry is right and the table follows it.
- [ ] **Step 3: `--design-contracts`** — coverage names the twenty-one. Correct red.
- [ ] **Step 4: Commit.** `feat(ui): stamp the league, career and entry register budgets as a contract`

---

## Task 2: The filter rail, and the career route bar on it

**Files:** Modify `Sources/ProFootballCoachUI/ForgeFieldPrimitives.swift` (add `ForgeFieldFilterRail`); rewrite `Sources/ProFootballCoachUI/FloodlitFamilyRouteBar.swift` on it. Test: the existing "Forge Field route bar (06.1f(i))" suite stays green; add one rail test.

**Interface produced:** `ForgeFieldFilterRail<ID: Hashable>(items: [(id: ID, title: String, accessibleTitle: String)], selected: ID?, onSelect: (ID) -> Void)` — a row of 44 pt chips; the live one on `ground3` with `Edge.raised`, the rest a bare hairline at `Edge.panel`; `.chrome` labels at `Tracking.chrome`, uppercase; at an accessibility size one chip per line; never scrolls sideways, never clips — the 6.1f(i) reflow rule.

- [ ] **Step 1: Failing test.**
```swift
    suite("Forge Field filter rail (06.3a(i), 06.1f(i))") {
        test("a rail chip is the touch height and the route bar is built on the rail") {
            expectEqual(ForgeFieldFilterRail<Int>.chipHeight, ForgeFieldTokens.Space.rowTouch)
            let source = swiftFiles(under: "Sources/ProFootballCoachUI")
                .first { $0.path.hasSuffix("/FloodlitFamilyRouteBar.swift") }?.text ?? ""
            expect(source.contains("ForgeFieldFilterRail(") && !source.contains("CoachWorldTokens"),
                   "the career route bar draws its pills as Forge Field rail chips, off the Press Box palette")
        }
    }
```
- [ ] **Step 2: Run; red.**
- [ ] **Step 3: Implement the rail; rebuild the route bar on it.** Keep `routes` (from `chrome?.siblings`, never a fallback), `selected` through `canonicalDestination`, the negative `accessibilitySortPriority`, VoiceOver reading `canonicalName`, and the "one pill is not a choice" guard. The bar's `palette` parameter goes; the club comes from the environment.
- [ ] **Step 4: Green** (`Forge Field route bar (06.1f(i))` and the new test). Render Career Hub (`PROOF_SCREEN_NUMBER=52`) — the bar re-skinned, standard and AX5 (E38's stacking measured again and noted).
- [ ] **Step 5: Commit.** `feat(ui): add the Forge Field filter rail and draw the career route bar on it`

---

## Task 3: World search (7)

**Files:** Rewrite `Sources/ProFootballCoachUI/WorldSearchView.swift` (keep `init`, `onClose`, `onSelectTeam`, the query `@State`). Modify `ForgeFieldBudget.swift`.

**Consumes:** `WorldSearchReadModel` (`seasonLabel`, `results[] { team, tier, cityName, regionName }`); `onSelectTeam(UUID)`.

**Spec column:** Desk, table-led · stage 11% · 44 of 393 · points 34 · ember 0 (a search commits nothing) · gold 0 · backgrounds 2.

| Element | x,y | w×h | cols |
|---|---|---|---|
| Search field | 10, 44 | 481 × 44 | 1–7 |
| Tier filters | 500, 44 | 342 × 44 | 8–12 |
| Seam · hard | 10, 102 | 832 × 1 | 1–12 |
| Results | 10, 110 | 832 × 273 | 1–12 |

Columns `320 / 90 / 200 / 168`. Tier is 90 because the model's two legal values are the words `College` and `Professional`, held as constants on `LeagueMapReadModel.Tier`.

**Data:** the query is view state (no field on the model); `results.count` (256 cap); `results[].team.name`, `.tier`, `.cityName`, `.regionName`; tap a row → `onSelectTeam(UUID)` → 42; the plate is `team.primaryColorHex` drawn as ground (a mark plate is identity).

**Rulings:** (1) the field is `ForgeFieldField`; the tier filters are `ForgeFieldFilterRail` with `All tiers / College / Professional` from `LeagueMapReadModel.Tier`'s constants. (2) The head reads `n results · 256 cap` — the world total is not on the model, so `14 of 198` is not drawn (recorded). (3) Rows are 44 (each opens 42); an empty result set says `No organisation matches "<query>"`.

**Facts:**
```swift
extension WorldSearchView {
    public static let stagedDataPointRoles: [String] = ["query", "tier.filter", "results.count"]
    public static let rowDataPointRoles: [String] = ["row.name", "row.tier", "row.city", "row.region"]
    public static let referenceVisibleRowCount = 5
    public static let dataPointCount = stagedDataPointRoles.count + rowDataPointRoles.count * referenceVisibleRowCount   // 3 + 20 = 23 of 34
    public static let stageFraction = Double(SearchMetric.fieldHeight / ForgeFieldTokens.Space.viewport.height)   // 44 / 393
    public static let goldElementCount = 0; public static let emberElementCount = 0; public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(stageFraction: stageFraction, dataPointCount: dataPointCount,
        goldElementCount: goldElementCount, emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```
- [ ] Steps 1–7 per the procedure; render `PROOF_SCREEN_NUMBER=7`. Commit `feat(ui): draw World search to the Forge Field sheet`.

---

## Task 4: League map (41)

**Files:** Re-skin `Sources/ProFootballCoachUI/LeagueMapView.swift` (34 KB). **Keep the projection, the letterboxing, the place selection (`selectedPlaceID`), `placeBrowserButton`, the rival hairlines and the `Open team profile` route exactly as they are** — this is a presentation change, not a re-architecture (the Match Day rule applied to the one other surface that draws a picture). Modify `ForgeFieldBudget.swift`.

**Consumes:** `LeagueMapReadModel` (`gridWidth`, `gridHeight`, `regions[] { name, talentDensity }`, `places[] { team, cityName, regionName, x, y, isControlled, rivals[] { intensity, originLabel, notableMeetings } }`, `conferenceStandings[]`, `reachRadius`); `onContinue`, `onNavigate`, `onSelectTeam`.

**Spec column:** Desk, field-led · stage 0% (the field is studied, not staged) · points 39 · flood 1 · club gradient at 158°, one field · ghost 0 · ember 0 · rivals cold slate.

| Element | x,y | w×h | cols |
|---|---|---|---|
| Map field | 10, 44 | 552 × 339 | 1–8 |
| Seam · hard | 566, 44 | 1 × 339 | — |
| Conference | 571, 44 | 271 × 339 | 9–12 |
| Grid lines | — | 46 pt · 1 pt at .05 | — |
| Place plate | — | 24 / 18 / 12 | — |

Vertical seam at x 566: left of it where the programmes are, right of it how they are doing. Three plate sizes carry three facts: 24 the controlled club, 18 a named rival, 12 everyone else. The field is 1.63:1 against a 1.43:1 grid, so the projection letterboxes.

**Data:** `gridWidth / gridHeight`; `places[].x, .y` (grid units, by design); `regions[].name`, `.talentDensity`; `places[].team.name`, `isControlled`; `rivals[].intensity`; `rivals[].originLabel`; `notableMeetings` (always empty in v1 → `unrecorded`); `conferenceStandings[]` (already en-dashed); `reachRadius` (always nil → no circle).

**Rulings:** (1) The flood is `clubDeep` → `ground1` at `MapMetric.floodAngle = 158` degrees, the sheet's own stamp for this one field (the 102° convention is for identity floods; recorded). (2) Plates: visual 24/18/12 on `ground3` + `Edge.raised`, the controlled plate `club`, rival plates `signalCold`; **hit areas stay whatever the existing view gives them** (they are `Button`s today; the 44 pt floor is met via `contentShape`, the E17 pattern) — do not shrink a target to match a plate. (3) The conference panel lists `conferenceStandings[]` in 32 dense inert rows (`name · record · diff`, the controlled row with the ember spine). (4) Two empties stay stated: `Notable meetings: unrecorded`, no reach circle. (5) `198 places, one frame, no zoom` is the model's, recorded as an ask (cap the frame by region).

**Facts:**
```swift
extension LeagueMapView {
    public static let fieldDataPointRoles: [String] = ["region.name", "region.talent", "place.name", "place.isControlled", "rival.intensity", "rival.origin", "frame.count"]
    public static let standingRowDataPointRoles: [String] = ["standing.name", "standing.record", "standing.differential"]
    public static let referenceStandingRowCount = 6
    public static let dataPointCount = fieldDataPointRoles.count + standingRowDataPointRoles.count * referenceStandingRowCount + 1 /* meetings absence */   // 7 + 18 + 1 = 26 of 39
    public static let stageFraction = 0.0
    public static let goldElementCount = 0; public static let emberElementCount = 0; public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(stageFraction: stageFraction, dataPointCount: dataPointCount,
        goldElementCount: goldElementCount, emberElementCount: emberElementCount, ghost: nil, backgroundCount: backgroundCount)
}
```
- [ ] Steps 1–7; **read the whole file before editing** and run `--design-contracts` and the league-map contract tests between each extracted sub-view; render `PROOF_SCREEN_NUMBER=41` (the existing `--league-map` proof still works). Commit `feat(ui): re-skin League map to Forge Field without touching its projection`.

---

## Task 5: Team & programme profile (42)

**Files:** Rewrite `Sources/ProFootballCoachUI/TeamProgrammeProfileView.swift` (keep `init`, `onClose`, `onSelectTeam`). Modify `ForgeFieldBudget.swift`.

**Consumes:** `TeamProgrammeProfileReadModel` (`team`, `cityName`, `regionName`, `seasonLabel`, `tier`, `conference`, `division?`, `venue`, `prestige`, `record`, `rank?`, `rosterCount`, `staffCount`, `traditions[]`, `fixtures[] { week, opponent, isHome, score?, stage }`, `rivals[] { team, origin, intensity }`).

**Spec column:** Dossier, plate-led · stage 33% · 130 of 393 · points 41 · gold 2 of 2 (record and rank) · ghost 260 · .13 · bleeds the top-right · ember 0 · rival plate cold slate.

| Element | x,y | w×h | cols |
|---|---|---|---|
| Identity plate | 10, 44 | 832 × 130 | 1–12 |
| Fixtures | 10, 182 | 481 × 201 | 1–7 |
| Rivals | 500, 182 | 342 × 201 | 8–12 |
| Mark plate | 22, 58 | 48 × 48 | — |

Seam at y 178, implied by the plate's own edge. Fixture rows are 44 because each opens the opponent (`onSelectTeam`).

**Data:** `team.name`; `team.abbreviation`; `tier`; `conference · division`; `cityName · regionName`; `venue.name`; `record`; `rank` (nil outside the counted range → `unranked`); `prestige`; `rosterCount · staffCount`; `fixtures[].week`, `.opponent`, `.isHome` → `at`, `.score` (nil → `unplayed`), `.stage`; `rivals[].team`, `.origin`, `.intensity`; `traditions[]` (8 cap).

**Rulings:** (1) **Gold per `04` 6.1e(i)**: record and rank in `gold` only when `model.team.stableID == chrome?.club.stableID`; otherwise ink 1, and the mark plate is `signalCold`. (2) The name is `.fixture` (62) with `minimumScaleFactor(ProfileMetric.nameScaleFloor)` where `nameScaleFloor = 52.0 / 62.0` — the sheet's 52 is not a type step, so it is reached by scaling the step, never by a new size (recorded). (3) `prestige` and `intensity` print bare with the head naming them (`Prestige`, `Intensity`); no `of 100`. (4) A fixture row opens the opponent's profile — the only route the callbacks carry; the box score is not reachable from here (recorded). (5) Ghost: `ForgeFieldGhostMark(team: model.team, …)` bleeding the plate's top-right, clipped by the plate.

**Facts:**
```swift
extension TeamProgrammeProfileView {
    public static let plateDataPointRoles: [String] = ["plate.abbreviation", "plate.tier", "plate.conference", "plate.name", "plate.city", "plate.venue", "plate.record", "plate.rank", "plate.prestige", "plate.roster", "plate.staff"]
    public static let fixtureRowDataPointRoles: [String] = ["fixture.week", "fixture.opponent", "fixture.stage", "fixture.score"]
    public static let rivalRowDataPointRoles: [String] = ["rival.name", "rival.origin", "rival.intensity"]
    public static let referenceFixtureRowCount = 3; public static let referenceRivalRowCount = 2
    public static let dataPointCount = plateDataPointRoles.count + fixtureRowDataPointRoles.count * referenceFixtureRowCount
        + rivalRowDataPointRoles.count * referenceRivalRowCount + 1 /* traditions */   // 11 + 12 + 6 + 1 = 30 of 41
    public static let stageFraction = Double(ProfileMetric.plateHeight / ForgeFieldTokens.Space.viewport.height)   // 130 / 393
    /// The most this view spends: record and rank, when the profile is the controlled club (04 6.1e(i)).
    public static let goldElementCount = 2
    public static let emberElementCount = 0
    public static let ghost = ForgeFieldBudget.Ghost(size: ProfileMetric.ghostSize, opacity: ForgeFieldTokens.Register.ghostOpacity, desaturated: false)
    public static let backgroundCount = 2
    public static let facts = ForgeFieldSurfaceFacts(stageFraction: stageFraction, dataPointCount: dataPointCount,
        goldElementCount: goldElementCount, emberElementCount: emberElementCount, ghost: ghost, backgroundCount: backgroundCount)
}
```
- [ ] Steps 1–7; render `PROOF_SCREEN_NUMBER=42` for the controlled club **and** for a rival opened from the map (gold present / absent). Commit `feat(ui): draw Team & programme profile to the Forge Field sheet with gold only for your own club`.

---

## Task 6: Standings (43)

**Files:** Rewrite `Sources/ProFootballCoachUI/StandingsView.swift` (keep `init`, `onClose`, `onContinue`, `onSelectTeam`).

**Consumes:** `StandingsReadModel` (`seasonLabel`, `weekLabel`, `tier`, `rows[] { team, wins, losses, ties, conferenceRecord, pointsFor, pointsAgainst, isControlled, record }`).

**Spec column:** Desk, table-led · stage 8% · 32 · points 52 · largest numeral 19 (the rank column) · signals good/alarm on the differential only · ember 0 · active row ember spine on `isControlled`.

| Element | x,y | w×h | cols |
|---|---|---|---|
| Context strip | 10, 44 | 832 × 32 | 1–12 |
| Seam · hard | 10, 84 | 832 × 1 | 1–12 |
| Table | 10, 92 | 832 × 291 | 1–12 |
| Row × 6 | —, 111 | 808 × 44 | — |

Columns `34 / 314 / 80 / 80 / 70 / 70 / 84`. Rows are 44 because a row opens 42.

**Rulings:** (1) The differential is `pointsFor - pointsAgainst`, arithmetic on two retained facts, printed signed; `signalGood` above zero, `signalAlarm` below, ink 1 at zero — the only signals on the surface. (2) The first column is the array index (no rank field) and the head says `# · provider order`; no group head (no conference on the row) — recorded. (3) `rows.count` uncapped: the head prints `n programmes · 6 shown`, the rest scroll. (4) `onContinue` is a quiet 44 control in the strip.

**Facts:** `stripDataPointRoles = ["tier", "season", "week", "sort", "count"]`, `rowDataPointRoles = ["row.index", "row.name", "row.record", "row.conference", "row.for", "row.against", "row.differential"]`, `referenceVisibleRowCount = 6` → 5 + 42 = 47 of 52; `stageFraction = 32 / 393`; gold 0, ember 0, backgrounds 2 — as a `facts` static in the Task 3 shape.
- [ ] Steps 1–7; render `PROOF_SCREEN_NUMBER=43`. Commit `feat(ui): draw Standings to the Forge Field sheet`.

---

## Task 7: Schedule (44)

**Files:** Rewrite `Sources/ProFootballCoachUI/ScheduleView.swift`.

**Consumes:** `ScheduleReadModel` (`seasonLabel`, `tier`, `games[] { week, stage, home, away, score?, isControlled }`).

**Spec column:** Desk, table-led · stage 11% · 44 · points 48 · ember 0 · `unplayed` stated, never `0–0`.

| Element | x,y | w×h | cols |
|---|---|---|---|
| Next strip | 10, 44 | 832 × 44 | 1–12 |
| Seam · hard | 10, 102 | 832 × 1 | 1–12 |
| Fixture table | 10, 110 | 832 × 273 | 1–12 |
| To-come head | —, 261 | 808 × 19 | — |

Columns `62 / 380 / 96 / 110 / 120` on the sheet; **without the Result column** (ruling 1) they are `62 / 380 / 96 / 110` with the remainder as trailing space.

**Rulings:** (1) **`Won by 25` is not drawn** — `score` is a string and the model never says which side it favours; parsing it is not shippable (contract: no result the model does not hold). The result column goes; recorded as an ask (`outcome`, `margin`). (2) The next strip is the first game with `score == nil` (`Next · Wk 9 · at Halloran Tech · regular season`, `Played · n of m`); no record (not on this model; the chrome bar carries it). (3) A second inner head `To come · n fixtures` splits played from unplayed. (4) A row opens `onSelectTeam` for the opponent — the only route (recorded: nothing links to 47).

**Facts:** strip roles `["next.week", "next.fixture", "next.stage", "played.count", "played.total"]`, row roles `["row.week", "row.fixture", "row.stage", "row.score"]`, `referenceVisibleRowCount = 5` → 5 + 20 = 25 of 48; stage 44/393; gold 0; ember 0; backgrounds 2.
- [ ] Steps 1–7; render `PROOF_SCREEN_NUMBER=44`. Commit `feat(ui): draw Schedule to the Forge Field sheet`.

---

## Task 8: Rankings (45) and Bracket (46)

**Files:** Rewrite `Sources/ProFootballCoachUI/CompetitionOverviewView.swift` (two compositions by `focus`; `RankingsPlayoffPictureView` and `BracketPostseasonView` stay thin wrappers). Two facts entries.

**Consumes:** `CompetitionOverviewReadModel` (`seasonLabel`, `tier`, `rankings[] { team, rank, record, isControlled, seed?, qualifyingSlots, isQualifying }`, `bracket[] { stage, home, away, score?, week }`); `CollegeRules.bracketTeams` / `ProRules.bracketTeams`.

**45 spec column:** Desk, table-led · stage 8% · 32 · points 56 · signals good, caution, quiet (three bracket states) · `unseeded` when `seed == nil` · ember 0. Geometry: seed strip `10,44 832×32`; seam `10,84`; table `10,92 832×291`; columns `44 / 344 / 80 / 100 / 90 / 100`. Rank and seed are separate columns because they are separate facts.

**45 rulings:** (1) Four columns from four fields: `rank`, `record`, `seed` (`unseeded` when nil), `of qualifyingSlots`, `In / Out` from `isQualifying` (good / quiet). (2) **`Last in` is not drawn** — the bubble is derived; the caution signal has no source (recorded as an ask, `bubblePosition`). (3) The seed strip is the controlled row's `Tier rank #18 of n` and `Bracket seed 6 of 8`; when no row is controlled, `unseen`.

**46 spec column:** Desk, field-led · stage 8% · 32 · points 44 · gold 0 (FF-3) · ember spine 0 (no `isControlled` on `BracketGame`) · ember 0. Geometry: outcome strip `10,44 832×32`; seam `10,84`; bracket field `10,92 832×291`; round columns 258 wide with 16 between; game plates 258 × 52 on the sheet → **44** (two names and two figures at `.row` fit 44; 52 is off-ladder; recorded).

**46 rulings:** (1) Rounds are `bracket[]` grouped by `stage` in first-encounter order (no round index on the model); three fit, a fourth would need room 852 does not have — stated in `BracketMetric` with the `trailingZeroBitCount` assumption the engine already tests. (2) **No champion, no `your run`, no ember spines** — none is a field; the outcome strip prints `n games · last stage: <stage>` and, when every game has a score, `concluded`. (3) Plates are inert (a bracket row is a game, `onSelectTeam` takes a team); no connector lines — the vertical centring carries the pairing. (4) An undecided game shows `unplayed`.

**Facts (two statics on one view):** `rankingsFacts` with strip roles `["strip.rank", "strip.rankOf", "strip.seed", "strip.seedOf", "strip.qualifying"]`, row roles `["row.rank", "row.name", "row.record", "row.seed", "row.of", "row.bracket"]` × 6 → 5 + 36 = 41 of 56, stage 32/393; `bracketFacts` with strip roles `["strip.games", "strip.lastStage", "strip.concluded"]`, plate roles `["plate.home", "plate.homeScore", "plate.away", "plate.awayScore", "plate.stage", "plate.week"]` × 7 → 3 + 42 = 45 of 44 — **over by one: drop `plate.stage` from the plate (the round column head already carries the stage)** → 3 + 35 = 38 of 44; stage 32/393; gold 0; ember 0; backgrounds 2 for both. `ForgeFieldBudget.facts`: `.rankingsPlayoffPicture: CompetitionOverviewView.rankingsFacts`, `.bracketPostseason: CompetitionOverviewView.bracketFacts`.
- [ ] Steps 1–7; render `PROOF_SCREEN_NUMBER=45` and `=46` (in season and after a concluded bracket). Commit `feat(ui): draw Rankings and Bracket to the Forge Field sheet`.

---

## Task 9: Statistics & leaders (48)

**Files:** Rewrite `Sources/ProFootballCoachUI/StatisticsLeadersView.swift`.

**Consumes:** `StatisticsLeadersReadModel` (`seasonLabel`, `weekLabel`, `rows[] { category, player, team, value, seasonLabel }`, 32-row cap across all categories).

**Spec column:** Desk, table-led · stage 11% · 44 (the category rail) · points 47 · largest numeral 19 (the compared column) · ember 0. Geometry: category rail `10,44 832×44`; seam `10,102`; table `10,110 832×273`; columns `34 / 304 / 200 / 110 / 120` on the sheet → **`34 / 304 / 200 / 110`** without the per-game column.

**Rulings:** (1) The rail is `ForgeFieldFilterRail` over the distinct `category` strings in first-encounter order — chrome, not chrome-bar tabs. (2) **No per-game column** (`gamesPlayed` is not on the model); **no unit** — the head reads `Value` and the rail names the category (recorded as an ask: `unit`, `gamesPlayed`). (3) `value` prints through `ForgeFieldFormat.thousands`. (4) The first column is the array index within the category. (5) The cap is shared across categories; the head states `n rows · 32 cap across all categories`.

**Facts:** rail roles `["rail.category", "rail.count"]`, row roles `["row.index", "row.player", "row.role", "row.team", "row.value"]` × 5 → 2 + 25 = 27 of 47; stage 44/393; gold 0; ember 0; backgrounds 2.
- [ ] Steps 1–7; render `PROOF_SCREEN_NUMBER=48`. Commit `feat(ui): draw Statistics & leaders to the Forge Field sheet`.

---

## Task 10: Awards & honours (49)

**Files:** Rewrite `Sources/ProFootballCoachUI/AwardsHonoursView.swift`.

**Consumes:** `AwardsHonoursReadModel` (`awards[] { title, winner: String, tier, value, seasonLabel }`, 64 cap).

**Spec column:** Dossier, plate-led · stage 33% · 130 · points 32 · gold 2 of 2 (the star plate and the honour line) · ghost 260 · .13 · bleeds bottom-right · ember 0. Geometry: headline honour `10,44 832×130`; honours table `10,182 832×201`; star plate `22,58 48×48`; columns `288 / 288 / 96 / 100`.

**Rulings:** (1) The headline is `awards.first` in provider order: `★` (U+2605) on a 48 plate with `Edge.gold`, `tier · title · seasonLabel` in `gold` `.columnHead`, the winner at `.fixture`. (2) The winner is a string: no route, and the plate says so in ink 4 (`A name, not a reference`) — recorded. (3) `value` prints through `thousands` under the head `Value`, with no unit (recorded). (4) Rows are 32 dense — nothing opens. (5) The ghost is the chrome's club (`chrome?.club`; the model carries none) bleeding the plate's bottom-right; with no chrome, no ghost. (6) An empty list: `No honour recorded yet` and whose job it is — the season's.

**Facts:** plate roles `["headline.tier", "headline.title", "headline.season", "headline.winner", "headline.value"]`, row roles `["row.title", "row.winner", "row.tier", "row.value"]` × 3 → 5 + 12 = 17 of 32; stage 130/393; **gold 2**; ember 0; ghost `Ghost(260, .13)`; backgrounds 2.
- [ ] Steps 1–7; render `PROOF_SCREEN_NUMBER=49`. Commit `feat(ui): draw Awards & honours to the Forge Field sheet`.

---

## Task 11: News (50)

**Files:** Rewrite `Sources/ProFootballCoachUI/NewsView.swift`.

**Consumes:** `NewsReadModel` (`weekLabel`, `items[] { occurred, headline, weight }`, 64 cap).

**Spec column:** Desk, list-led · stage 8% · 32 · points 19 (the lightest surface in the game) · headlines in 13.5 display, not prose · ember 0. Geometry: context strip `10,44 832×32`; seam `10,84`; item list `10,92 832×291`; columns `116 / 1fr`; rows 44.

**Rulings:** (1) Headlines in `.row` (display) — a broadcast line, one line at 704 pt; at AX5 unlimited. (2) **No ember spine** (no `isControlled`, no subject reference) — recorded. (3) The strip prints `Week · n items of 64 · sorted by weight, descending`; weight itself is not rendered. (4) One news authority: nothing here writes a sentence about the world.

**Facts:** strip roles `["strip.week", "strip.count", "strip.cap", "strip.sort"]`, row roles `["row.occurred", "row.headline"]` × 6 → 4 + 12 = 16 of 19; stage 32/393; gold 0; ember 0; backgrounds 2.
- [ ] Steps 1–7; render `PROOF_SCREEN_NUMBER=50`. Commit `feat(ui): draw News to the Forge Field sheet`.

---

## Task 12: Realignment event (51)

**Files:** Rewrite `Sources/ProFootballCoachUI/RealignmentEventView.swift`.

**Consumes:** `RealignmentReadModel` (`currentSeasonLabel`, `event? { seasonLabel, reason, swaps[] { firstProgramme, firstFrom, firstTo, secondProgramme, secondFrom, secondTo } }`, `swaps.prefix(2)`).

**Spec column:** Desk, event-led · stage 16% · 62 · points 24 · largest numeral 34 (the season) · ember 0 · signals caution on yours, cold on theirs. Geometry: event header `10,44 832×62`; seam `10,114`; swap 1 `10,122 411×261`; swap 2 `431,122 411×261`. Programme names at 26 with the old conference struck through.

**Rulings:** (1) Names at `.heading`; `firstFrom` with `.strikethrough()` then `→` then `firstTo` — the strike is the sheet's one decoration and the arrow is a permitted glyph. (2) **No signals**: yours-or-theirs is not on the model, so every plate is `signalCold` and no caution dot is drawn; each panel's foot reads `Effect on your schedule: unseen` (recorded as an ask: references, `affectsControlledTeam`, `fixturesChanged`). (3) `event == nil` is a first-class state: `Nothing is realigning · season <currentSeasonLabel>` with a hollow quiet dot. (4) At most two swaps by construction (`prefix(2)`), so the 6/6 split is exact.

**Facts:** header roles `["event.season", "event.reason", "event.swapCount"]`, swap roles `["swap.first", "swap.firstFrom", "swap.firstTo", "swap.second", "swap.secondFrom", "swap.secondTo", "swap.effect"]` × 2 → 3 + 14 = 17 of 24; stage 62/393; gold 0; ember 0; backgrounds 2.
- [ ] Steps 1–7; render `PROOF_SCREEN_NUMBER=51` with and without an event. Commit `feat(ui): draw Realignment event to the Forge Field sheet`.

---

## Task 13: Opportunities (52), Stakeholders (54), Promotion (55)

**Files:** Rewrite `Sources/ProFootballCoachUI/CareerHubView.swift` (25 KB; three compositions by `focus`; keep `init`, every callback — `onClose`, `onNavigate`, `onAcceptOpportunity`, `onResign`, `onContinue` — the resign confirm alert, and the Task 2 route bar first in the content column per `04` 6.1f(i)). `StakeholdersView` and `PromotionDecisionView` stay thin wrappers. Three facts entries.

**Consumes:** `CareerHubReadModel` (`coach`, `status`, `currentJob? { team, tier, started, ended?, reason?, canResign }`, `history[]`, `opportunities[] { team, tier, offered, expires, prestige, rationale, canAccept, unavailableReason? }`, `support[] { stakeholder, value, rationale? }`).

### 52 — spec column

Desk, table-led · stage 16% · 62 · points 44 · ember 1 (Accept, which ends a job) · disabled rows at 72% with the reason on the row · chrome tab none lit (the career family has no slot; the route bar carries the family).

| Element | x,y | w×h | cols |
|---|---|---|---|
| Coach header | 10, 44 | 832 × 62 | 1–12 |
| Seam · hard | 10, 114 | 832 × 1 | 1–12 |
| Opportunities | 10, 122 | 481 × 261 | 1–7 |
| Support | 500, 122 | 342 × 261 | 8–12 |

The route bar (6.1f(i)) sits first in the content column, above the header, and the header shrinks to fit: **header `10, 96` `832 × 62`, seam `10, 166`, panels `10/500, 174` `× 209`** when the bar is present (44 + 8); the sheet's geometry holds on the bare stage.

**52 rulings:** (1) The ember is Accept for the selected opportunity (`@State selectedOpportunityID`, default the first `canAccept`): `ForgeFieldEmber(label: "ACCEPT \(team.name.uppercased())", cost: currentJob.map { "ends the \($0.team.name) job · no undo" } ?? "no undo", isEnabled: canAccept, action: { onAcceptOpportunity(id) })`; `!canAccept` → cost `unavailableReason`, row at 72%. (2) Resign (`onResign`, shown only when `currentJob?.canResign == true`) is a plain 44 control with its existing confirm — one ember per surface. (3) `rationale` prints as the quote — it is the model's own house-voice sentence. (4) **Support prints `value` with no scale, no bar, no threshold colour** (none on the model): `stakeholder · value · rationale ?? "No movement recorded"` (recorded: `bound`, `threshold`). (5) The header: `coach.name`, `status`, `currentJob` (`tier · team · since started`), `history.count jobs`.

### 54 — spec column

Desk, table-led · stage 8% · 32 · points 31 · row height 64 on the sheet → **32 dense + 24 caption** per stakeholder (`04` 6.3a(i); 64 is off-ladder; recorded) · ember 0 · active spine caution → **none** (no threshold on the model).

| Element | x,y | w×h | cols |
|---|---|---|---|
| Summary strip | 10, 44 | 832 × 32 | 1–12 |
| Seam · hard | 10, 84 | 832 × 1 | 1–12 |
| Table | 10, 92 | 832 × 291 | 1–12 |

Columns `200 / 90 / 1fr` (the sheet's bar column is not drawn: no bound). The summary strip: `Average n` (arithmetic on retained values), `Lowest <stakeholder>, n`, `Moved this week k of 4` (`rationale != nil`), `Evaluated at the end of every week`. Nil rationale renders `No movement recorded` — ignorance, never a dash.

### 55 — spec column

Dossier, plate-led · stage 33% · 130 · points 26 · gold 0 · ember 1 (Accept) · `unseen` 1 (the support you would inherit) · ghost 260 · .13 · top-right (census).

| Element | x,y | w×h | cols |
|---|---|---|---|
| Offer plate | 10, 44 | 832 × 130 | 1–12 |
| Comparison | 10, 182 | 481 × 201 | 1–7 |
| Consequence | 500, 182 | 342 × 201 | 8–12 |
| Ember | 512, 296 | 318 × 44 | — |

**55 rulings:** (1) The subject is `opportunities.first` (provider order); none → `No offer on the table` and whose job it is (the market's). (2) The plate: `team.abbreviation` mark plate, `tier · offered <offered> · expires <expires>`, name at `.fixture` (scaled per Task 5 ruling 2), `rationale` as the quote, `Prestige <prestige>`. (3) **Comparison draws only the shared axes**: Tier for both; Prestige for the offer and `unseen` for the current job (no prestige on `JobRow`); Support `unseen` for the job you do not hold — recorded (promote `StartingJobReadModel`'s shape to `OpportunityRow` and `JobRow`). (4) The consequence panel: `Ends the <currentJob.team.name> job · no undo` and nothing the model cannot prove — the sheet's recruiting-class sentence is not drawn (recorded: `consequences: [String]` from the engine). (5) The ember: `ForgeFieldEmber(label: "ACCEPT THE JOB", cost: "ends the <job> · no undo", isEnabled: canAccept, …)`; **Decline and stay** is a quiet 44 label → `onClose` (the offer stays until `expires`). (6) Ghost of `opportunities.first.team` bleeding the plate's top-right.

**Facts (three statics on one view):**
- `hubFacts`: header roles `["coach.name", "coach.status", "job.tier", "job.team", "job.since", "history.count"]`, opportunity roles `["opp.team", "opp.offered", "opp.tier", "opp.prestige", "opp.expires", "opp.rationale"]` × 3, support roles `["support.stakeholder", "support.value", "support.rationale"]` × 4 → 6 + 18 + 12 = 36 of 44; stage 62/393; ember 1.
- `stakeholdersFacts`: strip roles `["strip.average", "strip.lowest", "strip.moved", "strip.cadence"]`, row roles `["row.stakeholder", "row.value", "row.rationale"]` × 4 → 4 + 12 = 16 of 31; stage 32/393; ember 0.
- `promotionFacts`: plate roles `["plate.abbreviation", "plate.tier", "plate.offered", "plate.expires", "plate.name", "plate.rationale", "plate.prestige"]`, comparison roles `["compare.tier.current", "compare.tier.offer", "compare.prestige.current", "compare.prestige.offer", "compare.support"]`, consequence roles `["consequence.ends"]` → 7 + 5 + 1 = 13 of 26; stage 130/393; ember 1; ghost `Ghost(260, .13)`.
All: gold 0; backgrounds 2.
- [ ] Steps 1–7 for each focus; render `PROOF_SCREEN_NUMBER=52`, `=54`, `=55` — including the between-appointments coach (no chrome, no route bar, `currentJob == nil`: the ember cost reads `no undo`). Commit `feat(ui): draw Opportunities, Stakeholders and Promotion to the Forge Field sheet`.

---

## Task 14: Record book (57), Rivalries (58), Career line (59), Coaching tree (60)

**Files:** Rewrite `Sources/ProFootballCoachUI/LegacyHistoryView.swift` (four compositions by `focus`; keep `init`, `onClose`, `onNavigate`, the route bar first). The four wrappers stay thin. Four facts entries.

**Consumes:** `LegacyHistoryReadModel` (`team`, `seasonLabel`, `records[] { title, value, team, opponent, gameLabel }` (8 cap), `rivalries[] { opponent, origin, intensity, meetings: [String] }` (8 cap), `careerLine[] { season, organisation, role }` (64 cap), `coachingTree[] { mentorName, disciples: [String] }` (256 cap)).

### 57 — Desk, table-led · stage 8% · 32 · points 38 · gold 0 (FF-3) · ember 0
Geometry: context strip `10,44 832×32`; seam `10,84`; records `10,92 832×291`; columns `300 / 110 / 1fr / 150`. Rows 32 dense (inert). **Rulings:** `value` under the head `Value` with no unit; the title beside it is what makes the column readable (recorded: unit, holder); no `set under you` (not on the model); the strip: `team.name · n records · 8 cap`.

### 58 — Desk, table-led · stage 16% · 62 · points 33 · rival plate cold · ember 0
Geometry: rival header `10,44 832×62`; seam `10,114`; meetings `10,122 481×261`; other rivals `500,122 342×261`. **Rulings:** the subject is `rivalries.first` (or a `@State` selection from the other-rivals panel); `intensity` prints bare, no bar (no scale); **`meetings[]` render exactly as `LegacyHistoryView` renders them today** (existing behaviour on facts is authoritative; the zero-based season inside the string is recorded as an ask, the same one 41 refuses to render); no `2–1 under you` (derived by counting strings — not drawn); the other-rivals panel lists `opponent · origin · intensity` in 44 rows (tapping selects).

### 59 — Desk, table-led · stage 8% · 32 · points 22 · ember 0
Geometry: summary strip `10,44 832×32`; seam `10,84`; table `10,92 832×291`; columns `90 / 1fr / 240`. **Rulings:** a table, not a timeline; `season` prints as the existing view prints it (it renumbers — kept; recorded); the strip tallies `seasons`, distinct organisations as `jobs`, distinct roles; no record, no finish, no reason (on `CareerHubReadModel`, not here — recorded).

### 60 — Desk, list-led · stage 0% · points 17 · ember 0 · seam implied by a 6/6 split on the sheet → **one panel**
**Rulings:** no coach reference on the model, so `who you came from` / `who came from you` cannot be told apart without a name match — **one panel, `10, 44` `832 × 339`**, `Coaching tree · names only · no ids`, each branch as `MENTORNAME` (`.row`, uppercase) over its disciples indented 12 pt behind a hairline, 32 dense rows; no node diagram (an illustration). Recorded: references at both ends.

**Facts (four statics):** `recordBookFacts` strip `["strip.team", "strip.count", "strip.cap"]` + row `["row.title", "row.value", "row.opponent", "row.game"]` × 5 → 23 of 38; `rivalriesFacts` header `["rival.name", "rival.origin", "rival.intensity", "rival.meetingCount"]` + meeting `["meeting.text"]` × 3 + other `["other.name", "other.origin", "other.intensity"]` × 2 → 13 of 33; `careerLineFacts` strip `["strip.seasons", "strip.jobs", "strip.roles"]` + row `["row.season", "row.organisation", "row.role"]` × 4 → 15 of 22; `coachingTreeFacts` branch `["branch.mentor", "branch.disciple"]` × 4 → 8 of 17. Stages 32/393, 62/393, 32/393, 0. Gold 0, ember 0, backgrounds 2.
- [ ] Steps 1–7 for each focus; render `PROOF_SCREEN_NUMBER=57`…`=60`. Commit `feat(ui): draw the four legacy-history surfaces to the Forge Field sheet`.

---

## Task 15: Title & continue (1)

**Files:** Rewrite `Sources/ProFootballCoachUI/TitleContinueView.swift` (keep `init(failure:isStarting:isRestoring:…restoredCareer:onRetry:onUseBackup:onNewCareer:onContinue:onSettings:)` and every state it serves).

**Spec column (transcribed):** register none of the four → **Entry** (FF-4) · chrome nil (the app has no club) · club colour on the save panel only (3 pt spine) · ghost 260 · .13 inside that panel · points 11 · largest numeral 62 (the product name, not a figure) · ember 1 (Use the backup) · scrim 0 (this is not an overlay, it is the app).

| Element | x,y | w×h | cols |
|---|---|---|---|
| Title block | 10, 44 | 832 × 110 | 1–12 |
| Failure panel | 10, 166 | 552 × 217 | 1–8 |
| Actions | 571, 166 | 271 × 217 | 9–12 |
| Ember | 583, 191 | 247 × 44 | — |

No chrome bar. The failure panel follows the house failure order — what broke, what is intact, the last known good point, the error code — and the ember is the recovery that loses the least. Retry is a quiet control. `PRO FOOTBALL COACH` is set in plain condensed display; no wordmark is drawn.

**Data:** `failure: String?` — one string; `recoveryRequired`; `onRetry`, `onUseBackup`; `isStarting` / `isRestoring` (spinner states); `restoredCareer: CareerHubReadModel?` (the continue path); the `no undo` copy is the view's own literal, kept verbatim.

**Rulings:** (1) `ForgeFieldDevice(club: .calumet)` — the product's own palette (`04` 6.1e(ii)); the save panel alone is `.environment(\.forgeFieldClub, ForgeFieldTokens.Club.resolved(for: restoredCareer?.currentJob?.team ?? …))` with a 3 pt `club` spine and `ForgeFieldGhostMark` of that team bleeding the panel's bottom-right; no save → no spine, no ghost. (2) **The failure panel prints the one string under `What broke`**; `What is intact`, `Last known good` and `Code` print `unseen` — the four-field format is an ask (`RestoreFailure { broke, intact, lastGood, code }`), and nothing is invented to fill it. (3) Recovery state: ember `ForgeFieldEmber(label: "USE THE BACKUP", cost: "restores the last backup · no undo", isEnabled: true, action: onUseBackup)`; Retry a quiet 44 control; `Delete and start over` a plain 44 control keeping its existing confirm and its verbatim copy. (4) Normal state (no failure): the title block, then the save panel (`restoredCareer` → coach, job, `Continue` as a plain 44 control — continuing is not irreversible, so it is not the ember; zero embers in this state), `New career` (plain, with its confirm — it deletes), `Settings` (quiet). (5) `isStarting` / `isRestoring`: the panel states `Starting…` / `Restoring…` with a hollow caution dot; no invented percentage.

**Facts:** roles `["title.product", "failure.broke", "failure.intact", "failure.lastGood", "failure.code", "save.coach", "save.job", "action.backupCost"]` → 8 of 20; stage: the facts struct needs a `Double` — use `0.0` (the budget stamps `nil`, and the generic test skips the band when the budget has no stage); gold 0; ember 1; ghost `Ghost(260, .13)`; backgrounds 2 (device ground, the panel).
- [ ] Steps 1–7; render by launching with no save (normal state), with a corrupt save (recovery — the `--save-document` fixtures show how), and while restoring. Commit `feat(ui): draw Title & continue in the Entry register`.

---

## Task 16: Settings & accessibility (6)

**Files:** Rewrite `Sources/ProFootballCoachUI/SettingsAccessibilityView.swift` (keep `init`, `onClose`, `onSetCallInsPerGame`, the two contract paragraphs verbatim).

**Spec column:** Desk, declaration-led · stage 0% · points 6 (the lightest in the run) · largest numeral 34 (the one preference) · ember 0 · no seam. Geometry: contract `10,44 481×339`; pacing `500,44 342×339`; stepper `512,155 318×44`.

**Rulings:** (1) The stepper is `ForgeFieldStepper(value:, in: SharedRules.callInsPerGameRange, label: "Call-ins a game", unit: "a game")` bound to the preference and `onSetCallInsPerGame`; when the closure is nil the control is disabled with `not available in this career` beneath. (2) Both paragraphs are literals in the view and both are accurate — kept verbatim as the beta product contract. (3) No seam — the one surface in 21 that legitimately has none. (4) Close via the chrome bar; `onClose` a quiet control when `chrome == nil`.

**Facts:** roles `["contract.headline", "contract.paragraph", "contract.accessibility", "pacing.value", "pacing.bounds", "pacing.sentence"]` → 6 of 6; stage 0; gold 0; ember 0; backgrounds 2.
- [ ] Steps 1–7; render `PROOF_SCREEN_NUMBER=6`. Commit `feat(ui): draw Settings & accessibility to the Forge Field sheet with the house stepper`.

---

## Task 17: New career & coach identity (2)

**Files:** Rewrite `Sources/ProFootballCoachUI/NewCareerSetupView.swift` (hosted by `NewCareerCoachIdentityView`; keep `init(jobs:defaultSeed:isWorking:errorMessage:onStart:onSeedChanged:onCancel:)`, the name and seed state, the validation that gates start).

**Spec column (transcribed):** Entry (FF-4) · not a chromed surface · club colour 3, scoped per card, never the device · ghost 3 × 230 at .13, each bleeding its band · points 21 → 20 · ember 1.

| Element | x,y | w×h | cols |
|---|---|---|---|
| Identity row | 10, 44 | 832 × 62 | 1–12 |
| Name field | 500, 53 | 342 × 44 | 8–12 |
| Seam · hard | 10, 114 | 832 × 1 | 1–12 |
| Job × 3 | 10, 122 | 271 × 261 | 4 + 4 + 4 |
| Club band × 3 | —, 122 | 271 × 52 | — |

The only 4/4/4 split in the run. Each card: a 52 pt flood in that programme's own colour, its mark ghosted out of the top-right at .13, the body on `ground2` so the three stay comparable. The archetype is the headline of each card, not the town.

**Data:** `jobs[].programme.name`; `.cityName`; `.archetype`; `.prestige · .resources`; `.expectation`; the coach's name — view state; `jobs.count` (uncapped).

**Rulings:** (1) Device `.calumet`; each card `.environment(\.forgeFieldClub, ForgeFieldTokens.Club.resolved(for: job.programme))` — **the programme reference carries its own colour and mark** (`primaryColorHex`, `mark`), so the cards wear the right colours; the sheet's "borrowed from the token set" no longer applies (recorded as resolved). (2) The name field and the seed field are `ForgeFieldField` (the seed stays: it is an existing input the contract keeps; `isFigure: true`). (3) **The ember is Start**: `ForgeFieldEmber(label: "START AT \(selected.programme.name.uppercased())", cost: "seed \(seed) · same seed, same world", isEnabled: isValid && !isWorking, action: …)`; the sheet's "ember = the selected card's spine" is the active state (a 2 pt ember spine on the selected card), which is not an ember instance — recorded as a deviation; `onStart` is the model's own irreversible action. (4) More than three jobs: the card row scrolls sideways **and says so** (`n jobs · scroll`) — never clips silently (recorded: cap `jobs` at three in the model). (5) `errorMessage` prints under the identity row with an alarm dot; `onCancel` is a quiet control. (6) Twenty data points, not twenty-one: the town is drawn once in the card body, not repeated in the band.

**Facts:** identity roles `["identity.name", "identity.seed", "identity.count"]`, card roles `["card.programme", "card.city", "card.archetype", "card.prestige", "card.resources", "card.expectation"]` × 3 → 3 + 18 = 21 → drop `identity.count` (the count is furniture) → 20 of 20; stage 0.0 (budget stamps nil); gold 0; ember 1; ghost `Ghost(230, .13)` (drawn once per card; one shape); backgrounds 2 (device, card body).
- [ ] Steps 1–7; render by launching with no save and choosing New career; three and five jobs; AX5 (cards stack). Commit `feat(ui): draw New career & coach identity in the Entry register`.

---

## Task 18: The families' ledger and STATUS rows

- [ ] **Step 1: One DONE row per view file** (Tasks 2–17), deviations named — including the three FF defaults applied (FF-2 on 42, FF-3 on 46/57, FF-4 on 1/2).
- [ ] **Step 2: One TODO row, "League, career and entry read-model asks from the sheet"**: `query` and `totalCount` on `WorldSearchReadModel`; a region cap for the map frame; `group` and `rank` on standings rows, `pointDifferential` on the row; `outcome` and `margin` on `GameRow`, a route from a fixture to 47; `bubblePosition` on `RankingRow`; `round`, `winner`, `isControlled` on `BracketGame`; `unit` and `gamesPlayed` on statistics rows, a per-category cap; `winner` as `CoachWorldPersonReference`, `unit`, season grouping on awards; `subject` reference on news items; references and `affectsControlledTeam`/`fixturesChanged` on `Swap`; `bound` and `threshold` on `SupportRow`; prestige/resources/expectation on `JobRow` and `OpportunityRow`, `consequences: [String]`; a record holder and unit on `Record`; a meeting as a value `{ calendar, outcome, score, isHome }` (41 and 58); record and finish on `CareerEntry`; references at both ends of `TreeBranch`; `RestoreFailure { broke, intact, lastGood, code }`; a cap of three on starting jobs; and the two registry decisions the sheet asks for (declare the sound sharing 45/46, 54, 57–60; FF-6 on 55). Gold-on-Desk (FF-3) and the fifth register (FF-4) are recorded as decided by default, with the owner's confirmation pending.
- [ ] **Step 2a: The row's asks close in 2I.** `docs/plans/2026-09-06-forge-field-phase-2i-completion-and-2j-release-candidate.md` Task I4 gives each ask a recorded disposition — design fact, projection, or not v1 — before anything is built; Task I18 draws the facts into this family's surfaces after this plan has merged.
- [ ] **Step 3: STATUS entry.**
- [ ] **Step 4: Commit.** `docs: record the league, career and entry Forge Field conversion in the ledger and STATUS`

---

## Phase 2F exit

- [ ] `swift build`; `--design-contracts` (the platform-chrome scan now green — its last three files are this family's); `--core-contracts` green.
- [ ] Generic budget suite green with all twenty-one surfaces registered.
- [ ] All twenty-one rendered at standard and AX5 (Title in three states, Coach identity with three and five jobs, Team profile as own and as rival), looked at; screenshots under `docs/proofs/forge-field/league-career-entry/`.
- [ ] Adversarial review on the phase diff; confirmed findings fixed first. Not a build.
- [ ] Full `swift run SimTests` green — once, here.
- [ ] Ledger and STATUS rows landed. **Ask the owner before any push or merge.**
