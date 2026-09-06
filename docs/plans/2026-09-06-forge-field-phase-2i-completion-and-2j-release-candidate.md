# Forge Field Phase 2I — engine, read-model and gate completion; Phase 2J — the release candidate

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement each phase task-by-task. Steps use checkbox (`- [ ]`) syntax. 2I runs beside 2C–2F and is gated before 2H starts; 2J starts only after 2H exits.

**Goal:** 2I closes every item the 2026-09-06 review of the game and its documentation found outstanding that is not a drawing: the read-model and engine asks the four family plans recorded, the engine gaps canon promises and the tree does not hold, the release gates that exist as names with nothing behind them, and the canon that no longer matches the build. 2J assembles the release candidate: every machine gate green on one commit, release hygiene done, and the owner's hardware pack prepared. **At 2J's exit the game requires only human testing approval, the owner-only distribution gates in `docs/PRE-DEPLOYMENT-CHECKLIST.md` §4a, and the final legal sweep (`CLAUDE.md`, owner 2026-08-24).**

**Architecture:** 2I is engine-side and provider-side — it touches `FootballSimCore`, `CoachWorldApp` providers, `ScreenReadModels.swift` and the test suites, never a family's view file until its closing task — so it merges beside 2C–2F without conflict. Every new read-model field lands with a defaulted initialiser parameter so no family's fixtures stop compiling. Every engine change is doc-first (`CLAUDE.md`), test-first (`superpowers:test-driven-development`), and lands with the assertion that fails if it regresses. 2J is a procedure over `SuiteCatalog` and `scripts/verify.sh`, not a hand list.

**Tech Stack:** iOS 26+, Swift 5.10, SwiftUI; Xcode 26 with the iOS 26 runtime; `swift run SimTests --<lane>`; `./scripts/verify.sh`; GitNexus (`impact` before editing a symbol, `detect_changes` before committing).

**Spec:** the four family plans' ask rows (`…-2c-personnel.md` Task 7 Step 2, `…-2d-recruiting.md` Task 7 Step 2, `…-2e-pro-management.md` Task 7 Step 2, `…-2f-league-career-entry.md` the ledger task's Step 2); `docs/FRONTEND-CHANGE-LEDGER.md` Part E rows E9, E11, E12, E13, E24, E25; `docs/STATUS.md` 2026-09-06 (dead money), 2026-08-29 (calibration red), 2026-08-25 Loop 915 (week advance red); `docs/handoff/2026-08-29-wr3-route-calibration.md`; `docs/OPEN-DECISIONS.md` D7, D8, D9, D10, D13, D16; `docs/06-AUDIT-DISPOSITION.md` §2 (the two missing named tests); `docs/PRE-DEPLOYMENT-CHECKLIST.md` (all of it).

**Canon touched (doc-first, every time):** `02` §2.2, §3.2, §4.2a, §10; `03` §1.2, §5.1, §8; `03b` §4, §5; `04` §7; `PRODUCT.md`; `docs/OPEN-DECISIONS.md`.

**Out of scope, deliberately:** anything legal (blocklist, near-miss review, trade dress, counsel questions — the final phase, `CLAUDE.md`); the human observation packs themselves (2J prepares them, the owner runs them); the signed archive and export-compliance answer (§4a, owner-only).

**Entry criterion (2I):** 2S merged (the budget contract exists, so a new fact can be registered the day it lands). 2I does not wait for 2C–2F; its closing task (I18) waits for each family it draws into.

## Global Constraints

Everything in the roadmap's Global Constraints applies. Additionally:

- **Doc-first.** A gameplay fact is written in `02`/`03`/`04` before it is coded. Where the review found canon and code disagreeing, the task names the two readings and a default; the owner may choose the other, and the task then changes shape, never silently.
- **Defaulted parameters on every new read-model field.** `ScreenReadModels.swift` is read by every family; a new `public let` lands with a defaulted `init` parameter so 2C–2F fixtures keep compiling in their own worktrees. The default is removed only in I18, once every constructor site passes the real value.
- **Every engine change is TDD** and lands with a soak or contract assertion that fails if the behaviour returns to what it was. The dead-money finding is the pattern to avoid: a gate green because the thing it names never happened.
- **GitNexus.** `impact({target, direction: "upstream"})` before editing any symbol named below; report HIGH/CRITICAL to the owner before proceeding; `detect_changes()` before every commit.
- **The season cap holds.** Every new soak or validation reads `TestHorizon` (`Tests/SimTests/TestKit.swift`); no task adds a season literal.
- **At most two soaks at once**, and never two `swift run` builds against the same scratch path — run the built binary directly for a second lane.
- **No claim without the run.** Counts are recorded from the session that produced them. An adversarial review is not a build.
- **Commit, push and merge only on the owner's word.** The repository stays on `main`; a worktree per task is fine, harvested and deleted.

---

## Decisions this set depends on

Each has a default the tasks assume, so nothing blocks. Numbering continues the roadmap's FF-1…FF-8. Ask them together, before I1 amends canon.

| # | Question | Default assumed below | Affects |
|---|---|---|---|
| FF-9 | `02` §2.2 sets a game plan as tempo, aggression, a personnel emphasis, a coverage lean and two keys; `TacticalPlan` holds `runPassBias`, `tempo`, `pressure`. Build up, or amend down? | **Build the coverage lean** (`DefensiveCall` reads it); **personnel emphasis is the Depth Chart's `PersonnelPlan`** (already built — canon says so); **the two keys are cut from canon** (no read model, no sheet, no surface carries them). | I9, I13 (schema) |
| FF-10 | `02` §3.2 promises timeouts, challenges, mid-match tempo and aggression, personnel packages, a halftime full-plan edit and per-position substitution overrides; Match Day has `speed`, `pause`, `keyMoments`, `takeOver`, `tactics`. | **The plan edit already ships, and more generously than canon**: `tactics` opens Game Plan mid-match whenever no call-in is pending and submits the chosen plan to `MatchAction.setTacticalPlan` on the live session (`CoachWorldAppRootView.swift:400`, `CoachWorldMatchProvider.swift:281`), so tempo, aggression and the halftime edit are built; `02` §3.2 is amended to say the edit is available at any dead ball, not only at halftime. **Build timeouts and the per-position substitution override** as intents; **challenges and mid-match packages are cut from canon** (no review mechanic exists in the engine, no rules constant, the sheet draws neither). | I10 |
| FF-11 | The controlled team over the cap at the compliance date: `02` §4.2a says a mandatory-decision surface is "real remaining work". Its shape? | **One `MandatoryDecision` per compliance week** whose options are the `ProLegalActionProjection` releases `ProCapComplianceSystem` already projects, cheapest dead money first, recommendation = the AI's own choice; the week refuses to advance until resolved (today's behaviour, now with a surface). | I8, 2E Task 4 |
| FF-12 | `03` §1.2's kick matchup reads weather; nothing models it. | **Amend `03`**: weather is not modelled in v1; the column is removed. (Build instead: one seeded per-game draw in `CompetitionRules`, read by kicks only — an owner choice, not the default.) | I16 |
| FF-13 | `01` AS-6.4-09: five college bands are unset (completion %, pass/rush yards, sacks, INTs, points per drive). | **Non-gating, stated as such** in `03` §5.1 with the `[Q]` mark and `CalibrationBands.unimplementedMetrics` kept as the honest list; sourcing them is research the owner may commission. | I11 |
| FF-14 | If I12 cannot bring week advance under the 2.0 s ceiling on the device, D14's fallback is 64 programmes. | **134 stays until the device measurement exists** (2J, owner hardware). The fallback is exercised only on the owner's word. | I12, J4 |
| FF-15 | The registry and alias decisions the family rows ask for: 21 (`StaffMarketReadModel` or delete), 22 (cut or record scheme familiarity), 23 (17 keeps `options[]` or 23 is the plan surface), 38/39 merge, 40 promote, 45/46 and 54 and 57–60 sharing one sound, 55 (FF-6). | **Keep every id; aliases stay aliases** (the contract's 47 + 15). 21 gets no read model (staff market is "later, if it earns it", `PRODUCT.md`); 22 is cut from the registry only if the owner says so; 23 stays an alias of 17. | I1, I4 |
| FF-16 | D9's beats need engine content that does not exist: the AD's stated season target and one unprompted recruit conversation in week 0. | **Build both as typed inbox items** from existing systems (`CareerArcState.seasonExpectation`; the recruiting relationship history), not as authored copy. | I14 |
| FF-17 | FSC-010's cross-season narrative and FSC-014's five unpopulated traits (`workhorse`, `iceInVeins`, `frontRunner`, `mentor`, `adaptable`). | **Not v1.** Recorded in `docs/FUTURE-SIMULATION-CONTRACT.md` as post-release; the five traits stay unpopulated and appear in no player-facing vocabulary. | I16 |
| FF-18 | A pick a club cannot seat is passed (`02` §4.2, 2026-08-23). The alternative — seat it on the practice squad — was raised during the pro soak review. | **Keep passing.** Canon already states it and the draft can never deadlock under it. | none |

---

## Phase 2I — engine, read-model and gate completion

### File structure

- `Sources/FootballSimCore/` — the systems named per task; rules constants in the tier's rules module, never inline.
- `Sources/CoachWorldApp/CoachWorldReadModelProvider*.swift` — projections.
- `Sources/ProFootballCoachUI/ScreenReadModels.swift` — fields, defaulted.
- `Tests/SimTests/Suites/` — one suite per new gate; existing suites widened in place.
- `Tests/SimTests/SuiteCatalog.swift`, `Tests/SimTests/main.swift`, `scripts/verify.sh` — every new gate registered, dispatched, and in a lane the script runs.
- `docs/` — canon amendments, STATUS entries, ledger rows.

### Section A — the asks the family plans recorded (FF-8)

The four family plans each end with a TODO row listing what the sheet draws that the read model does not hold. Each ask has one of three dispositions, decided in Step 1 of each task and recorded in the ledger row that closes it:

- **(a) a design fact** — the root does not hold it; `02`/`04` are amended first, then the engine, then the provider;
- **(b) a projection** — the root holds it; provider and read model only;
- **(c) not a v1 fact** — the surface's honest absence stays; the ask closes with the reason.

Every (a) and (b) lands as: a failing `ReadModelProviderTests` case naming the field → the field, defaulted → the provider → green. The family view prints the fact in I18.

#### Task I1: Personnel asks (2C Task 7 Step 2; ledger rows E24-shape)

**Files:** Modify `Sources/ProFootballCoachUI/ScreenReadModels.swift` (`RosterReadModel`, `DepthChartReadModel`, `PlayerProfileReadModel`, `StaffRoomReadModel`); `Sources/CoachWorldApp/CoachWorldReadModelProvider.swift`; `Sources/FootballSimCore/People/` (staff contract); `Tests/SimTests/Suites/ReadModelProviderTests.swift`.

- [ ] **Step 1: Disposition table**, one line per ask, committed to the ledger row before any code:
  `RosterFilter { unit, positionGroup, counts }` (b); `Slot.alignment`, `Slot.isVacant` + reason (b — `DepthChart` derives both); a plan usage figure (b); `StaffNote { speaker, role, body }` for `staffSummary` (a — `02` names the staff voice; who speaks is a design fact); `enum Confidence { known, band(Int, Int), unseen }` (a — the scouting-confidence model `04` §6 calls "not late"); a recent-form window (b — the profile's recent-form entries already exist per the contract row; the window is a bound on them); `DevelopmentSummary { up, flat, down, unseen }` (b); `developmentEvidence` on `PlayerRow` (b); a recruiting `StaffRole` (a); staff contract/salary/delegation (a — `02` §5 names staff poaching; a salary is the fact that makes poaching legible; **default: seasons remaining only, no money**, because no cap or budget reads staff salary and inventing one is a new system); aliases 21/22/23 per FF-15.
- [ ] **Step 2: Failing tests** — one `ReadModelProviderTests` case per (a)/(b) field, on the deterministic roots in `TestRoots.swift`.
- [ ] **Step 3: Canon** for every (a): `02` §5 (staff), `04` §6 (confidence) — amended, not appended to.
- [ ] **Step 4: Engine and provider**, smallest change each; `impact` on every touched symbol.
- [ ] **Step 5: Commit** per field. `feat(read-model): hold <field> for the personnel family`

#### Task I2: Recruiting asks (2D Task 7 Step 2)

**Files:** `ScreenReadModels.swift` (`RecruitingBoardReadModel`, `CollegeOffseasonReadModel`); the provider; `Sources/FootballSimCore/College/`; `ReadModelProviderTests.swift`.

- [ ] **Step 1: Disposition table:** `ProspectContactEvent { week, actor, summary, effect }` (b — relationship history is recorded; project it as events); a scouted rating band on `Prospect` (a — the same confidence model as I1, one type); `RecruitingWeek { day, contactSlots, visitSlots, note }` (c — canon has no recruiting day-calendar; the pooled-resource wording stays); a separate visit counter (b — `Capacity.officialVisitsRemaining` exists); `ClassNeed { position, signed, target }` (b — `PositionNeed` renamed or aliased; **never a find-and-replace rename — `rename`**); a phase field on the board model (b — `cyclePhase` is derived from the week); `MandatoryDecisionOption` recording a price (c — E25: a decision option has no price and the absence is stated quietly); NIL label carrying its amount / `NILAllocationReadModel { budget, committed, perProspect[], onSet }` (b for the totals, which exist; **(a) for `perProspect[]`** — the NIL ledger is per player already; project it); `PortalEntry { player, position, from, window, interest }` (b — the portal pool in `CollegePortalState`, bounded by `CollegePortalPolicyV1.portalPoolLimit`, records the entrant, his programme and the window; `interest` is projected from the recruiting relationship); one `MarketReadModel` shape for 21 and 32 (c — 21 has no market, FF-15; 32 projects the portal pool through `CollegeOffseasonReadModel`); the offseason route stating the closed cycle (b — the provider states "closed" instead of an empty board, the Signing Day precedent); the sample career pointed at the provider's label functions (b); a provider fault if an offer is `isAvailable` at zero slots (b — a `WorldIntegrity`-style assertion in the provider, and a test that plants the case).
- [ ] **Step 2–5:** as I1. `feat(read-model): hold <field> for the recruiting family`

#### Task I3: Pro-management asks (2E Task 7 Step 2) — and the generator

**Files:** `ScreenReadModels.swift` (`ProManagementReadModel`, `ProOffseasonReadModel`, `FreeAgentRow`); the provider; `Sources/FootballSimCore/Generation/` (the professional bootstrap); `Sources/FootballSimCore/Rules/ProRules/`; `Tests/SimTests/Suites/ProManagementTests.swift`, `ProMarketTests.swift`, `ReadModelProviderTests.swift`.

- [ ] **Step 1: Disposition table:** `positionFloors` (b — `SharedRules.minimumPlayableRosterByPosition` is the constant and `CoachWorldProManagementProvider` already computes `activeByPosition` against it at lines 20–32; project `[{ position, signed, floor }]` from the two, FF-5); a transactions ledger from `DomainEvent.proCapComplianceRelease` (b — plus the release, waiver and claim payloads I6 adds); `round` and pick order on `ProOffseasonReadModel` (b — `ProMarketState` holds the draft order); `lastCapHit` and `age` on `FreeAgentRow` (b); provider sorts by something a coach reads (b — eight UUID-sorted lists become position-then-overall, deterministic); **generator roster headroom** (a — `initialRosterByPosition` sums to `activeRosterLimit`, so every draft, sign and claim is unavailable in the first frame: bootstrap at `activeRosterLimit - draftRounds`, the same reservation `02` §4.2a states for the AI's own signings); **generator signing bonuses** (a — `02` §4.2a's dead-money arithmetic needs a bonus to accelerate; a bootstrap contract with `signingBonus: 0` produces a league where no release ever costs anything, which is the I6 finding from the other side); a `years` bound in `ProRules` (a, only if one had to be added); registry decisions per FF-15.
- [ ] **Step 2: Failing tests first** for the two generator changes: a bootstrap root has headroom on every club; a bootstrap contract carries a bonus drawn from a `ProRules` distribution; `WorldIntegrity` still passes; every pinned fingerprint in `ArchitectureTests` moves and is re-pinned **with the count of moved pins recorded** — a pin that does not move when generation changes is the finding.
- [ ] **Step 3: Canon:** `02` §4.2a gains the bootstrap reservation and the bonus distribution (one paragraph each, numbers in `ProRules`).
- [ ] **Step 4: Engine, provider, re-pin, commit** per item. `feat(generation): bootstrap professional rosters with draft headroom and signing bonuses`

#### Task I4: League, career and entry asks (2F, the ledger task's Step 2)

**Files:** `ScreenReadModels.swift` (`WorldSearchReadModel`, `LeagueMapReadModel`, `StandingsReadModel`, `ScheduleReadModel`, `CompetitionOverviewReadModel`, `StatisticsLeadersReadModel`, `AwardsHonoursReadModel`, `NewsReadModel`, `RealignmentReadModel`, `CareerHubReadModel`, `LegacyHistoryReadModel`, Title's inputs); the provider; `Sources/FootballSimCore/Competition/`, `History/`, `Career/`; `ReadModelProviderTests.swift`, `HistoryReadModelTests.swift`.

- [ ] **Step 1: Disposition table:** `query` and `totalCount` on search (b); a region cap for the map frame (b — a `maximumRegions` bound, the D7 pattern); `group`, `rank`, `pointDifferential` on standings rows (b); `outcome` and `margin` on `GameRow`, a route from a fixture to 47 (b — `onSelectGame` is a new callback; the family view wires it in I18); `bubblePosition` on `RankingRow` (b — derived by the engine's bracket cut, never by the view); `round`, `winner`, `isControlled` on `BracketGame` (b); `unit` and `gamesPlayed` on statistics rows, a per-category cap (b); `winner` as `CoachWorldPersonReference`, `unit`, season grouping on awards (b); `subject` reference on news items (b — typed payloads carry it); references and `affectsControlledTeam`/`fixturesChanged` on `Swap` (b); `bound` and `threshold` on `SupportRow` (a — the firing threshold is a design fact `02` §6 states; project the number the engine uses); prestige/resources/expectation on `JobRow` and `OpportunityRow`, `consequences: [String]` (b for prestige/expectation; c for `consequences` unless the engine records one); a record holder and unit on `Record` (b); a meeting as a value `{ calendar, outcome, score, isHome }` (b — rivalry meetings are compact records already); record and finish on `CareerEntry` (b); references at both ends of `TreeBranch` (b); `RestoreFailure { broke, intact, lastGood, code }` (b — `CoachWorldSaveStore` owns the backup and the quarantine and the envelope error is `code`; Title's `failure` input becomes typed); a cap of three on starting jobs (b — `02` §10 says three); registry decisions per FF-15; FF-3 and FF-4 recorded as the owner confirms.
- [ ] **Step 2–5:** as I1. `feat(read-model): hold <field> for the league, career and entry families`

#### Task I5: Weekly-command asks (ledger E24, E25)

**Files:** `ScreenReadModels.swift` (`CoachingHQReadModel`); the provider; `ReadModelProviderTests.swift`.

- [ ] **Step 1:** E24's seven facts, each (b): the opponent's record and rank, form for both sides, kickoff time (a — canon has no clock-of-day; **default (c)**, stated absent), home/away, the standing badge, the ember's cost (E25 — no cost; the absence stays quiet), the delegated-done summary with its staff.
- [ ] **Step 2–5:** as I1; the 2B surface prints the six in I18. E24 and E25 close. `feat(read-model): hold the six Coaching HQ facts the sheet draws`

### Section B — engine gaps canon promises

#### Task I6: The AI cut path, and a dead-money assertion that can fail

**Files:** Modify `Sources/FootballSimCore/Pro/ProRosterAISystem.swift`, `Sources/FootballSimCore/Pro/ProMarketSystem.swift` (`placeOnWaivers` gains an engine caller), `Tests/SimTests/Suites/ProSoakTests.swift`, `ProManagementTests.swift`; `docs/02-GAME-DESIGN.md` §4.2a.

Source: `docs/STATUS.md` 2026-09-06 (OPEN). `--pro-soak` reports `deadMoneyTotal=0`, `deadMoneyMax=0`, `waivers=0` across 32 clubs and ten seasons, so `03` §6's "bounded overage from dead money only" has never run against a non-zero value.

- [ ] **Step 1: Canon.** `02` §4.2a gains the AI's cut rule in one paragraph: at the roster-build phase an AI club above `activeRosterLimit` places the lowest-value contracts on waivers (value = overall against cap hit, the same reading `enforceCapCompliance` uses), and at the compliance date releases as the existing pass does; a claimed player moves with his contract, an unclaimed one is released with dead money.
- [ ] **Step 2: Failing tests:** `ProSoakTests` asserts `waivers > 0` and `deadMoneyTotal > 0` somewhere in the run and `deadMoneyMax` not trending upward season over season (D16's falsifier); `ProManagementTests` covers one AI waiver, one claim, one expiry release, each with its `DomainEvent` payload.
- [ ] **Step 3: Engine.** `impact` on `placeOnWaivers`, `resolveExpiredWaivers`, `ProRosterAISystem.process`. The pass runs inside `advanceWeek` in the `.rosterBuild` phase, skips the controlled club (I8 owns that), and never touches a root the scheduler did not produce.
- [ ] **Step 4: Run `--pro-soak`** (ten seasons) and record the three figures in STATUS; the OPEN entry becomes RESOLVED with the numbers. `feat(pro): let AI clubs cut to the roster limit, and assert dead money is exercised`

#### Task I7: Professional turnover to canon

**Files:** `Sources/FootballSimCore/Rules/ProRules/`, the generator's contract-length distribution, `Tests/SimTests/Suites/ProSoakTests.swift`; `docs/02-GAME-DESIGN.md` §4.2a.

Source: `--pro-soak` `proContractExpired=2423` over ten seasons ≈ 242 a season against the ≈ 339 `02` §4.2a implies ("roughly a fifth of each roster reaches expiry each season").

- [ ] **Step 1: Canon.** `02` §4.2a states the contract-length distribution as a `ProRules` constant, with the fifth-per-season consequence stated as a band, not an average.
- [ ] **Step 2: Failing test:** `ProSoakTests` asserts per-season expiries inside the band across the run.
- [ ] **Step 3: Generator and rookie/free-agent contract lengths** move to the distribution; re-pin fingerprints, count recorded.
- [ ] **Step 4: Commit.** `feat(pro): generate contract lengths so a fifth of every roster expires each season`

#### Task I8: The controlled team's cap-compliance decision (FF-11)

**Files:** `Sources/FootballSimCore/Career/` (mandatory decisions), `Sources/FootballSimCore/Pro/ProCapComplianceSystem.swift`, `Sources/FootballSimCore/Intent/IntentResolver.swift`, `Tests/SimTests/Suites/CapComplianceTests.swift`, `CareerControlTests.swift`; `docs/02-GAME-DESIGN.md` §4.2a; the 2E Roster-cuts surface (36) in I18.

Source: `02` §4.2a — "A mandatory-decision surface for that case is real remaining work, not built here", and "what legitimate mechanic would ever put a team over the cap remains an open question". After I3 (signing bonuses) and I6 (a release accelerates the unamortised bonus into the season), a controlled club can be over the cap at the compliance date; the question has an answer and the surface is owed.

- [ ] **Step 1: Canon.** `02` §4.2a's paragraph is rewritten: the mechanism (the accelerated bonus a release charges, once contracts carry one) and the decision (FF-11's shape). The "open question" sentence is removed because it is answered.
- [ ] **Step 2: Failing tests:** a controlled club planted over the cap at week 21 yields exactly one `MandatoryDecision` whose options are legal releases, each with its dead money; resolving one makes the root legal; the week refuses to advance while it is pending (`CareerControlTests`); an AI club is untouched.
- [ ] **Step 3: Engine.** The decision is built from `ProLegalActionProjection`; resolution routes through `IntentResolver` to the existing release path. `impact` on `enforceCapCompliance`.
- [ ] **Step 4: Commit.** `feat(pro): put the controlled club's cap compliance in front of the coach as a mandatory decision`

#### Task I9: The game plan to canon (FF-9)

**Files:** `docs/02-GAME-DESIGN.md` §2.2/§3; `Sources/FootballSimCore/Tactical/TacticalPlan.swift`; the coordinator's defensive call site (`DriveEngine`/`Assignment` — find it with `query`); `Sources/ProFootballCoachUI/ScreenReadModels.swift` (`GamePlanReadModel.Option` "three-dimension plan"); `Tests/SimTests/Suites/TacticalStateTests.swift`, `TacticalManagementTests.swift`, `SaveDocumentTests.swift`.

- [ ] **Step 1: Canon.** `02` §2.2 row 3 and §3 restated to what ships under FF-9: run/pass bias, tempo, pressure, **coverage lean**; personnel emphasis is the Depth Chart's plan; keys are gone.
- [ ] **Step 2: Failing tests:** a `TacticalPlan` round-trips with `coverageLean`; the defensive call reads it (a plan leaning zone produces measurably more zone calls over 200 snaps, deterministic); a save without the field decodes with the default (the migration fixture in I13).
- [ ] **Step 3: Engine, read model (defaulted), provider, options text.** `impact` on `TacticalPlan` (HIGH is expected — it is persisted; say so).
- [ ] **Step 4: Commit.** `feat(tactical): add the coverage lean the game plan canon names`

#### Task I10: Match controls to canon (FF-10)

**Files:** `docs/02-GAME-DESIGN.md` §3.2; `Sources/ProFootballCoachUI/ScreenReadModels.swift` (`MatchDayControlID`), `MatchDayView.swift`, `MatchDayScoreBug.swift`; `Sources/FootballSimCore/Intent/`, `Engine/` (`Situation.timeoutsRemaining` already exists); `Sources/CoachWorldApp/CoachWorldMatchProvider.swift`; `Tests/SimTests/Suites/MatchReducerTests.swift`, `ContractTests.swift` (the optional-control guard), `ReadModelProviderTests.swift`.

- [ ] **Step 1: Verified 2026-09-06.** `tactics` navigates to Game Plan (`CoachWorldAppRootView.matchControl`, the bare four-part intent) and `GamePlanView.onSelect` appends the three dial values so the choice reaches `MatchAction.setTacticalPlan` on the live session, not the weekly plan store. Tempo, aggression and the full plan edit are built and available at any dead ball; nothing further to verify.
- [ ] **Step 2: Canon.** `02` §3.2 restated under FF-10: what the coach can change mid-match is exactly the control set that ships, each named with its intent.
- [ ] **Step 3: Failing tests:** a timeout intent decrements `Situation.timeoutsRemaining` for the calling side and stops the clock per the tier's `ClockRules`; the existing mid-match `tactics` submission is pinned by a test that the second half's calls read the new plan (it ships untested at the reducer level today); a per-position substitution override changes the eleven on the next snap and is undone by the depth chart at the next game; the `MatchDayReadModel` initialiser still requires every control present (the 2026-09-02 guard).
- [ ] **Step 4: Engine, intents, read model, view controls** (drawn from the Forge Field primitives; the 2B Match Day budget table is re-registered).
- [ ] **Step 5: Commit** per control. `feat(match): <control> as an intent the coach can send mid-match`

#### Task I11: The calibration gate, green on the holdout

**Files:** `Sources/FootballSimCore/Engine/SnapResolver.swift` (`weightedTarget`), `Sources/FootballSimCore/Rules/CompetitionRules.swift` (abstracted scoring constants), `Sources/FootballSimCore/Calibration/CalibrationBands.swift`; `docs/03-MATCH-ENGINE.md` §5.1; `docs/handoff/2026-08-29-wr3-route-calibration.md`; `scripts/verify.sh` (the `calibration` lane).

Source: STATUS 2026-08-29 — red by design since `03` §1.1a; 4 of 24 pro checks fail on the tuning ladder and 5 on the holdout; the two-tier pro fourth-quarter share fails; `runCalibrationGateTests` is in no lane `verify.sh` runs.

- [ ] **Step 1: The model change, not a constant.** Per the handoff's mechanism: target selection trades openness against depth as the progression grows (the n/(n+1) order statistic inflated help); fit on the tuning ladder, report on the holdout, per `CalibrationHarness`'s own rule. No band moves.
- [ ] **Step 2: Re-derive the abstracted scoring constants** (`collegeBaselinePoints`, `proBaselinePoints`, the yardage baselines) from the fixed detailed engine in the same pass, the way the target shares were; `--two-tier-consistency` green on every listed metric, both tiers.
- [ ] **Step 3: `--calibration-gate` green** on both tiers, the holdout ladder, twice in separate processes; `--calibration-tuning` recorded beside it.
- [ ] **Step 4: FF-13** written into `03` §5.1; `unimplementedMetrics` stays as the honest list; the `modal combined total` shape check is implemented (TVD over a binned distribution, the instrument `03` §4.1 already names) or recorded with its reason.
- [ ] **Step 5: The lane.** `verify.sh --lane calibration` runs `--calibration-gate` and `--two-tier-consistency` after the instrument suite; `SuiteCatalog.lane(for:)` for both moves from `"manual"` to `"calibration"`; `--catalog` shows it.
- [ ] **Step 6: STATUS** — the 2026-08-29 entry gains its RESOLVED paragraph with the numbers. `feat(engine): select targets by openness and depth so the calibration gate holds on the holdout`

#### Task I12: Week advance under the ceiling

**Files:** `Sources/FootballSimCore/Scheduling/WorldScheduler.swift` and the per-week steps it runs; `Sources/FootballSimCore/Integrity/WorldIntegrity.swift`; `Sources/FootballSimCore/AI/CollegeRecruitingAISystem.swift`; `Tests/SimTests/Suites/WeekAdvanceTimingProbe.swift`, `PerformanceBudgetTests.swift`; `scripts/verify.sh`.

Source: `PerformanceBudgetTests` asserts the 2.000 s hard ceiling and measured **8.019 s** on the Release host (STATUS 2026-08-25, Loop 915); the M3 soak's Debug `weekMean` is 7.45 s; recruiting AI is 1.045 s of it. `SuiteCatalog` files the gate under a `performance` lane `verify.sh` does not define.

- [ ] **Step 1: Price every step.** Extend `--week-advance-timing` to print per-scheduler-step seconds and the count of whole-root `WorldIntegrity.check` calls per week; commit the probe change first.
- [ ] **Step 2: One whole-root check per week.** Steps that validate before-and-after (`expireContracts` is named in the probe) take the delta from one check; `impact` on `WorldIntegrity.check` (CRITICAL is expected — say so).
- [ ] **Step 3: The next-largest terms**, one commit each, each with the probe's before/after in the body, until the Release host is under the 2.000 s ceiling **and** the 1.200 s D4 target. The host-to-device ratio for this workload is unmeasured — nothing in the tree states it — so a host figure just under the ceiling is not evidence the device meets it; Step 5's script is what measures the device, and until it has run the host target is the 1.200 s D4 figure, not the ceiling.
- [ ] **Step 4: The lane.** Add `performance` to `verify.sh` running `--performance-budget` and `--week-advance-timing`; `PerformanceBudgetTests` green there.
- [ ] **Step 5: Device script.** `scripts/measure-device-budgets.sh` builds Release, installs on a connected iPhone by UDID, runs the five D4 operations through a DEBUG-only `PROOF_MEASURE` route, and prints the table the checklist §1 device box needs — the owner runs it in 2J (FF-14 if it fails).
- [ ] **Step 6: Commit.** `perf(scheduler): one whole-root integrity check per week`

#### Task I13: Save migration, fixtures, and the recovery path

**Files:** `Sources/FootballSimCore/Persistence/SaveEnvelope.swift`, `Sources/CoachWorldApp/CoachWorldSaveStore.swift`, `CoachWorldSaveDocument.swift`; `Tests/SimTests/Suites/SaveEnvelopeTests.swift`, `SaveDocumentTests.swift`; `docs/03b-ARCHITECTURE.md` §4.

Source: checklist §1 "Migration fixtures pass at every schema version boundary" and §5 "Backup/restore path exercised, including a corrupted-save recovery"; `03b` §4 "Specified, not yet built" — no envelope migration table exists. I9 changes the persisted `TacticalPlan`; I3 changes generated contracts. Both land through this seam.

- [ ] **Step 1: The migration table**, forward-only, one pure function per step, with the v1→v2 step written for I9's field; a fixture save at every version committed under `Tests/SimTests/Fixtures/saves/` and a test that opens each and reaches the current version; a test that an older envelope migrates and a newer one is refused with its plain message.
- [ ] **Step 2: The document-level defaults** (the decoder's schema-version defaults) get the same fixture treatment.
- [ ] **Step 3: Recovery fixtures:** a truncated body, a corrupt header, a body that decompresses and fails to decode — each quarantined, the backup offered, and Title's `RestoreFailure` (I4) carrying the four fields.
- [ ] **Step 4: `03b` §4** rewritten from "specified, not yet built" to as-built. `feat(persistence): a forward-only migration table with a fixture at every version boundary`

#### Task I14: Onboarding as state on the real surfaces (D9)

**Files:** `docs/02-GAME-DESIGN.md` §10; `Sources/FootballSimCore/Career/` (the AD's target as an inbox item), `Sources/FootballSimCore/College/` (the unprompted contact), `Sources/FootballSimCore/Scheduling/`; `ScreenReadModels.swift` (a `firstWeek` teaching state on `CoachingHQReadModel`, `GamePlanReadModel`, `MatchDayReadModel`, `AftermathReadModel`, `InboxReadModel`); the providers; `Tests/SimTests/Suites/E2EJourneyTests.swift`.

Source: D9's beat sheet (OPEN-DECISIONS) and `02` §10; `04` §8 counts "first-week teaching" as a state beneath its owning screen; no source file mentions onboarding, teaching or a first week. `05` P15's gate is "the automated onboarding journey contracts".

- [ ] **Step 1: Canon.** `02` §10 names the five beats as engine facts: three starting jobs each with a visible expectation and constraint (exists); the AD's stated target and one unprompted recruit conversation as week-0 inbox items (FF-16); week 1's plan of three options (exists); one post-match development decision and one injury depth-chart consequence surfaced as mandatory decisions when the engine produced them; the next opponent's tendency previewed on HQ (exists via `OpponentFilm`).
- [ ] **Step 2: Failing test — the journey contract:** `E2EJourneyTests` walks a fresh career through week 1 on the app layer and asserts each beat's fact is present on the read model that carries it, and that the teaching state is set exactly during the first week and never after.
- [ ] **Step 3: Engine items and the teaching state** (defaulted `false`); providers; the family views print the teaching copy in I18 under `04`'s voice rules — no cards, no overlay.
- [ ] **Step 4: Commit.** `feat(career): the first week teaches through its own inbox, plan and aftermath`

#### Task I15: The gates that exist as names

**Files:** Create `Tests/SimTests/Suites/JeopardyTests.swift`, `CoordinatorAITests.swift`, `RosterAITests.swift`, `AdaptationTests.swift`, `GenerationDiversityTests.swift`, `DestructiveActionPlacementTests.swift`; modify `Tests/SimTests/Suites/ContractTests.swift` (the error-surface scan), `Tests/ProFootballCoachUITests/ProFootballCoachUITests.swift` (`SmallestDeviceLayoutTest`), `Tests/SimTests/SuiteCatalog.swift`, `Tests/SimTests/main.swift`, `scripts/verify.sh`; `docs/OPEN-DECISIONS.md`, `docs/06-AUDIT-DISPOSITION.md` §2.

Source: the 2026-09-06 sweep of every test name canon, the checklist and the decision register cite, against the tree — `SmallestDeviceLayoutTest` and `DestructiveActionPlacementTest` do not exist (`06` §2 already says so); `ErrorSurfaceTest` is registered and mapped to `runContractTests`, but no test in that runner names an error sink or a presented failure; D8's `JeopardyTests`, D10's three suites and D13's diversity test exist only as falsifier names. A gate that exists as a name with nothing behind it is the failure `08` warns about.

- [ ] **Step 1: `ErrorSurfaceTest`** — a by-construction scan: every `failure`, `errorMessage`, `statusMessage` and `RestoreFailure` property on a read model is read by the view that owns the family (the `04` §7.1 enumeration), and every `catch` in `CoachWorldStore` writes one of them. Plant an unread sink; watch it fail; remove it.
- [ ] **Step 2: `DestructiveActionPlacementTest`** — every irreversible action (`onCommit`, `onResign`, `onAcceptOpportunity`, release, the Match Day exit) is drawn as `ForgeFieldEmber` with a named cost or a stated "no undo", never in a leading/cancel slot; `04` §6 names the placement rule it asserts.
- [ ] **Step 3: `SmallestDeviceLayoutTest`** — in the XCUITest target, looping `--canonical-screens` (2H Task H2's flag; write it here if 2H has not) at 844 × 390 and 852 × 393: every `canonical-screen-<id>` stamp present, every committing control hittable, at default and AX5. This is the rendered limb of G-12 (`04` §7.1, `03b` §5) that the headless suite cannot see. It runs under the `app` lane (2G Task G7 puts that target under a gate).
- [ ] **Step 4: `JeopardyTests`** (D8): across 200 seeded careers under `TestHorizon`, median coach tenure inside 2.5…9 seasons, and job security never unchanged across more than 4 consecutive weeks while results move.
- [ ] **Step 5: D10's three:** `CoordinatorAITests` — the coordinator beats a random-legal caller by a stated EPA margin over 500 games and a fixed counter-strategy does not exploit it; `RosterAITests` — no AI club ends a season illegal, and AI rating-per-dollar (pro) and rating-per-scholarship (college) are not systematically below the controlled club's at equal resources across the soak; `AdaptationTests` — the counter rate rises when the same call is run ten times. Margins go in `docs/OPEN-DECISIONS.md` D10 **before** the tests are written, and a bar that cannot be met is an escalation, not a widened band.
- [ ] **Step 6: `GenerationDiversityTests`** (D13): the no-repeat check already in `GenerationTests` moves here; ≥ 90 % of programmes carry a distinguishable tradition set; news headline repeat rate under 2 % within a season.
- [ ] **Step 7: Register every one** in `ReleaseGateID` with a lane `verify.sh` defines and runs, dispatch it in `main.swift`, and re-run the `06` §2 name sweep (by regular expression over the whole document set, not by hand) — green, recorded in `06` §2's paragraph and in STATUS.
- [ ] **Step 8: Commit** per gate. `test: <gate> — the falsifier D<n> named, made to run`

#### Task I16: Canon that no longer matches the build

**Files:** `PRODUCT.md`; `docs/OPEN-DECISIONS.md` (D5, D7 falsifiers; D7's ceiling question); `docs/03-MATCH-ENGINE.md` §1.2, §8; `docs/04-UX-AND-DESIGN-SYSTEM.md` §7; `docs/FUTURE-SIMULATION-CONTRACT.md`; `docs/HANDOFF-CLAUDE.md`; `docs/05-IMPLEMENTATION-PLAN.md` (P16/P17 pointers).

One commit, docs only, after the owner has answered FF-12, FF-13 and FF-17.

- [ ] **Step 1: `PRODUCT.md`:** the twenty-season positioning stays as product direction and says so; the "20 seasons under 8 MB" row becomes the ten-season measurement (8,320,997 bytes at season 10, 0.81 % under the ceiling, growth s1→s5 +1,874,938 and s5→s10 +237,371, accepted by the owner 2026-09-02) with twenty-season runs named as optional diagnostics per the 2026-09-02 cap; the week-advance row cites the 8.019 s Release host figure and points at I12; `CommitmentCoverageTest` stays green (no commitment row changes).
- [ ] **Step 2: `docs/OPEN-DECISIONS.md`:** D5 and D7 falsifiers read "the ten-season soak" with the 2026-09-02 cap cited; D7's "whether 8 MB is the right number" paragraph closes with the owner's acceptance; D16's falsifiers point at I6's assertions.
- [ ] **Step 3: `03` §8** restated: presentation-time constants (owner protocol, 2J); recruiting-AI cost measured (1.045 s host); college clock rules confirmed against the current rule book or marked `[Q]`; recruiting/portal model-vs-model agreement recorded as non-gating with the soak's churn assertion as the proxy. `03` §1.2 per FF-12.
- [ ] **Step 4: `04` §7:** the 17e and 16e landscape insets measured on the simulator (print `safeAreaInsets` through the DEBUG proof route) and recorded, replacing "unsourced".
- [ ] **Step 5: `docs/FUTURE-SIMULATION-CONTRACT.md`:** FSC-003 closed under the cap with the measurement; FSC-010's narrative and FSC-014's five traits marked post-release (FF-17); FSC-013's true state recorded — activated if `RosterTenureTests` covers the dated participant check, otherwise still open with the trigger it names. `docs/HANDOFF-CLAUDE.md`'s "Next work" re-pointed at this plan. `05` P16 and P17 point at 2I and 2J.
- [ ] **Step 6: Commit.** `docs: reconcile canon with the ten-season cap, the measured budgets and the gates that now exist`

#### Task I17: Ledger rows E9, E11, E12, E13

**Files:** `docs/FRONTEND-CHANGE-LEDGER.md`; `docs/04-UX-AND-DESIGN-SYSTEM.md` §6.1e; `Tests/SimTests/Suites/DesignContractTests.swift`.

These are Forge Field standard rows still TODO that no family plan owns: E9 (re-measure every contrast ratio for all four clubs, both directions — a scan over the palette pairs actually used, the 2H H1 "write it if absent" item, written here), E11 (backgrounds as gradients never imagery — a scan for `Image` under a stage), E12 (the seam law and the chrome bar's fixed contents — asserted by the 2S suite; confirm and close), E13 (house voice: `unseen` as a legal value, qualified numbers, failures naming what survived — the canon amendment first, then the copy scan).

- [ ] **Step 1:** one commit per row; each closes with its test named. `test(ui): <row> — asserted, closed`

#### Task I18: Draw the facts (closing task; per family, after that family merges)

**Files:** the family's view files; `ForgeFieldBudget.facts` for each surface touched.

- [ ] **Step 1:** for each family in turn, once its 2C–2F plan has merged: replace every honest absence its plan recorded with the fact I1–I5 now holds, inside the family's own budget row (the data-point count moves; re-register the facts; the generic suite must stay green); wire the new callbacks (`onSelectGame`, the mandatory-decision route for I8, the I10 controls, the I14 teaching copy).
- [ ] **Step 2:** remove the defaulted parameters I1–I5 added, once every constructor site passes the real value.
- [ ] **Step 3:** render each touched surface at standard and AX5 on the 17e; look at it; screenshot under `docs/proofs/forge-field/<family>/`.
- [ ] **Step 4:** the family's ledger ask row closes; one commit per family. `feat(ui): print the <family> facts the read model now holds`

### Phase 2I exit

- [ ] Every I1–I5 ask has a recorded disposition and every (a)/(b) field is held and printed.
- [ ] `--pro-soak` reports non-zero waivers and dead money with `deadMoneyMax` not trending up; per-season expiries inside the canon band.
- [ ] `--calibration-gate` and `--two-tier-consistency` green on the holdout, both tiers, and inside `verify.sh --lane calibration`.
- [ ] `PerformanceBudgetTests` green on the Release host inside a `performance` lane; the device script exists.
- [ ] Every gate name canon cites resolves to a dispatched runner in a lane the script runs; the `06` §2 sweep is green.
- [ ] The migration table exists with a fixture at every boundary; the recovery fixtures pass.
- [ ] Canon amended for FF-9…FF-17 as answered; STATUS carries each task's counts.
- [ ] Adversarial review on the phase diff; confirmed findings fixed first. Not a build.
- [ ] Full `swift run SimTests` green, once, uninterrupted, ending in the `N tests, M checks` summary. **Ask the owner before any push or merge.**

---

## Phase 2J — the release candidate

**Entry criterion:** 2H exited (2G and 2I merged before it). Legal remains deferred; §4a remains the owner's.

**What 2J is:** the pre-deployment checklist, run rather than reasoned about, on one commit, with the evidence lines written where the owner will read them. **What it is not:** a place to fix anything larger than release hygiene — a red gate here is a 2I or 2H regression and goes back to its phase.

### Task J1: Every machine gate, enumerated, on one commit

**Files:** `docs/STATUS.md` (the release-candidate entry); `docs/PRE-DEPLOYMENT-CHECKLIST.md` §1 evidence lines. Nothing else is edited.

- [ ] **Step 1: The candidate commit** is named before anything runs; every command below is run against it and only it.
- [ ] **Step 2: The lanes, from the script's own list** (`sed -n '/^case "\$lane" in/,/esac/p' scripts/verify.sh`), each recorded with its exact command and its `N tests, M checks` line: `./scripts/verify.sh` (full), `--lane core`, `--lane determinism` (twice, separate processes — the cross-process box), `--lane calibration` (now carrying the engine gate and two-tier), `--lane soaks`, `--lane accessibility`, `--lane app` (XcodeGen, the iOS build, the UI-test target with `SmallestDeviceLayoutTest`), `--lane archive`, `--lane release`, `--lane performance`.
- [ ] **Step 3: The lanes the script groups as soaks, at the cap and no more than two at once:** `--m1-soak`, `--m2-soak`, `--m3-soak`, `--pro-soak`, `--e2e-h-durability` (ten seasons under `TestHorizon`), each ending in its summary line; the save-size and growth figures recorded beside the 8 MiB ceiling.
- [ ] **Step 4: The five source scans** named in `03b` §1, each asserted individually from `--core-contracts` output (the checklist says "not a chosen three").
- [ ] **Step 5: `--commitment-coverage`, `--catalog`** — every `PRODUCT.md` commitment resolves; every `ReleaseGateID` has a runner; nothing is filed under a lane the script does not run.
- [ ] **Step 6: `--legal-only`** — run and recorded, **not asserted**: the two identity tests are deferred to the final phase (`CLAUDE.md`), and their result here is information for that phase.
- [ ] **Step 7: CI.** The `tests` workflow (`.github/workflows/tests.yml`: `full`, then `release`) is green on the candidate commit, or the owner records that Actions is not in use; the STATUS entry says which.
- [ ] **Step 8: STATUS** — one entry, "release candidate `<sha>`", every command and count, and the list of §1 boxes now evidenced. `docs: release candidate <sha> — every machine gate on one commit`

### Task J2: Release hygiene (checklist §5)

**Files:** `App/project.yml` (`MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`), `Sources/FootballSimCore/Persistence/SaveEnvelope.swift` (`schemaVersion` matches the migration table's head), `Sources/ProFootballCoachUI/SettingsAccessibilityView.swift`, `Tests/SimTests/Suites/ContractTests.swift`, `docs/store/listing.md` (new), `docs/STATUS.md`.

- [ ] **Step 1: Version and build number** incremented; `schemaVersion` asserted equal to the table's current version by a test.
- [ ] **Step 2: Backup, restore and corrupted-save recovery** exercised on the simulator through Title's three states (I13's fixtures, installed as real save files), screenshots under `docs/proofs/release/`; a newer-schema save refused with its plain message, screenshot.
- [ ] **Step 3: No network, analytics, accounts or IAP — by scan, not inspection alone:** a `ContractTests` scan that no target imports `Network`, `StoreKit`, `CloudKit` or uses `URLSession`, plus `PrivacyInfo.xcprivacy` declaring no collection and no tracking (the app lane already checks the manifest); planted offender, watched fail, removed.
- [ ] **Step 4: Settings copy.** "English-only beta · landscape play · silent product" and the static commitments paragraph become release copy that states only what the app reads (the call-in rate persisted to the save; system accessibility settings honoured), per `04`'s voice rules; the 2F Task 16 drawing is unchanged.
- [ ] **Step 5: Store listing draft** — `docs/store/listing.md`: offline as a feature, no IAP/ads/subscriptions/analytics/accounts, no real identity and no wink at one. **A draft for the legal sweep to review**, not a claim that it passed one.
- [ ] **Step 6: STATUS honesty pass:** every "unverified — never compiled" entry either has a later verified entry that names it or is repeated in the release-candidate entry as still unverified; no file claims a run that did not happen (grep STATUS and the plans for "verified" beside a count and check each has a command).
- [ ] **Step 7: Commit.** `chore(release): version, schema, settings copy and the no-network scan`

### Task J3: The owner's hardware pack — prepared, never ticked

**Files:** `docs/OWNER-WALKTHROUGH.md` (revised), the ten packs under `docs/plans/2026-08-24-owner-gate-*.md` (re-pointed at the candidate commit and the Forge Field surfaces), `scripts/measure-device-budgets.sh` (I12), `docs/PRE-DEPLOYMENT-CHECKLIST.md` §1 (device box), §4, §4a.

- [ ] **Step 1: One index** at the top of `docs/OWNER-WALKTHROUGH.md`: the candidate commit, the build command, the install command by UDID, and the ordered list of what only the owner can do, each with the pack that scripts it and the box it evidences:
  1. Performance budgets on an iPhone 15/A16 (§1) — `scripts/measure-device-budgets.sh`; FF-14 if red.
  2. The D1 timing protocol (`AGENCY_BUDGET_SECONDS/HARDWARE/BUILD/DATE` into `--agency-budget`) — optional (§4).
  3. The D9 onboarding protocol, 2-of-3 — optional (§4).
  4. Packs 01–10 (simulator walkthrough, fresh install and resume, device and appearance matrix, physical iPhone 15 and e-class, the iOS Simulator skill bundle, VoiceOver week and match, Dynamic Type AX5, Reduce Motion full match) — optional (§4), and the `04` §10 proof approval of HQ, Recruiting Board and Match Day together.
  5. **§4a: the signed Release archive from the candidate commit, and the export-compliance answer at upload** — blocking, owner-only.
- [ ] **Step 2: Every pack's predictions** rewritten against the Forge Field surfaces and the 2H evidence pack, unrun and marked so.
- [ ] **Step 3: Commit.** `docs: the owner's hardware pack for release candidate <sha>`

### Task J4: The checklist, box by box

**Files:** `docs/PRE-DEPLOYMENT-CHECKLIST.md`.

- [ ] **Step 1:** every §1, §3 and §5 box gains an evidence line: the command, the count, the STATUS entry — from J1 and J2. Boxes stay unticked; ticking is the owner's.
- [ ] **Step 2:** §2's retained legal items are left exactly as written — the final phase's list.
- [ ] **Step 3:** §4a's two boxes carry "owner-only; see `docs/OWNER-WALKTHROUGH.md` §5".
- [ ] **Step 4: Commit.** `docs: evidence lines on every agent-assertable pre-deployment box`

### Task J5: Sign-off

- [ ] **Step 1:** whole-phase adversarial review of 2J's diff (small by construction); confirmed findings fixed first.
- [ ] **Step 2:** if any J2 commit touched source, J1 is re-run in full on the new head and the STATUS entry updated — the candidate is the commit the gates were green on, never "the same source".
- [ ] **Step 3:** ledger — every open Part E row closed or carrying an owner-approved `May ship only with recorded follow-up`.
- [ ] **Step 4: Push only with the owner's word.**

### Phase 2J exit — what remains, stated exactly

- [ ] Every agent-assertable box in `docs/PRE-DEPLOYMENT-CHECKLIST.md` §1, §3 and §5 carries its evidence from one recorded commit.
- [ ] What is left for a human: the §4 observation packs (optional, product evidence), the `04` §10 proof approval, the device performance measurement, the §4a signed archive and export-compliance answer.
- [ ] What is left for the final phase: `docs/PRE-DEPLOYMENT-CHECKLIST.md` §2 — the two identity tests on the default gate, the near-miss review, the trade-dress check, the store-listing review.
- [ ] Nothing else.
