# Forge Field Phase 2 — Roadmap, and Phase 2A (the shell) in full

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement Phase 2A task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** put Forge Field on screen. Phase 1 landed canon and a token layer that nothing draws with; Phase 2 makes the running app look like the drawings.

**Architecture:** the shell first, then one screen family per batch, then delete the old layer. Phase 2A rebuilds what every surface sits on — the chrome bar, the device frame, the seam, and the four core primitives — because a surface drawn before the shell exists is drawn twice. 2B to 2F follow the design's own batching, one family each. 2G removes `CoachWorldTokens` once nothing reads it.

**Tech Stack:** iOS 26+, Swift 5.10 language mode, SwiftUI. Swift 6.3.3 toolchain present; `swift build`, `swift run SimTests --design-contracts`, and the full `swift run SimTests` all run locally.

**Spec:** `docs/superpowers/specs/2026-08-29-forge-field-standard.md`, plus the five `Game screens - *.dc.html` sheets and `FF Chrome.dc.html` in the Forge Field project (`8c511c92-3337-4cfb-850c-140a659f3034`). **The sheets are the handoff and they are unusually complete**: every screen carries a stamped spec column giving its register, its budgets, its geometry as `name · x,y · w×h · cols` in px against the device origin, its type per element, its token list, and its data bindings. Where this plan and a sheet disagree on a number, the sheet is right.

**Canon:** `04` sections 6.1e, 6.2a, 6.3a, 6.6a, 6.7a. **Ledger:** `docs/FRONTEND-CHANGE-LEDGER.md` Part E, rows E6 to E14.

## Global Constraints

- iOS 26+, Swift 5.10 language mode, SwiftUI. **iPhone-only, landscape-only.** Offline. **Zero third-party app dependencies.**
- **Device is 852 x 393.** Margins 10, so the content column is 832. Grid is 12 columns, 9 px gutters.
- **One radius: 3 pt** on every panel, button, plate, chip and mark. The only 14 pt is the outer device frame. There is no second radius.
- **Ladder: 4 / 8 / 12 / 16 / 24 / 32 / 44.** Nothing off-ladder.
- **Rows: 32 dense — legal only when the whole row is inert — or 44 touch.** Anything tappable is 44 on its short edge.
- **Gold means earned standing only.** Max three per surface, zero on a Desk surface.
- **Ember is the commit.** One per surface, only on something irreversible, and it carries a mono cost sub-label. **If an action has no cost worth naming, it is not an ember.**
- **Club colour is legal as a flood or a 3 pt spine and illegal as a panel ground, row band, button or chart series.**
- **Four signals, no fifth:** alarm `#E9524A`, caution `#E7C13C`, good `#46C083`, cold `#A8C4E0`. A rival is always cold slate.
- **No icon set.** Status is a signal dot; identity is a mark plate. The only glyphs are `★` U+2605 and the arrows. **No emoji anywhere.**
- **No photographs, no illustrations.** Backgrounds are floods, lamp washes, the oversized ghost mark, and the scanline.
- **Nothing loops.** The only continuously animated element is a live match clock. `prefers-reduced-motion` collapses the four transitions to a 90 ms crossfade and makes the flood wipe a cut.
- **A design-token literal in a view is a defect.** Every value comes from `ForgeFieldTokens` or `ForgeFieldType`.
- **The AX5 and Dynamic Type contract in `04` section 7 is a floor, not a preference.** A composition that needs the floor lowered is the composition that is wrong.
- **Forge Field does not override a fact.** `docs/reviews/2026-08-22-all-screen-presentation-contract.md` still says what each surface holds and must omit. Drawing what the simulation does not hold is the failure this system names most often.
- **A test that checks a class must enumerate that class by construction.**
- Conventional Commits. One task = one commit. **Ask the owner before any push or merge.**

---

## The adaptation rule — owner directive, 2026-08-30

**The sheets are mock-ups. They do not account for visibility, measurement or legibility faults on a
real device.** Where a stamped value would produce one, the implementer deviates, and records the
deviation rather than the drawing.

This is a standing licence, granted by the owner, and it is narrow on purpose:

| Deviate when | Do not deviate for |
|---|---|
| Text would be illegible at the shipping size, or fails the `04` section 7 contrast floor | A gap, a colour or a proportion you merely prefer |
| A tappable thing would land under 44 pt on its short edge | A layout you find unbalanced |
| Content would truncate, clip, or sit off-screen at 852 x 393 | A count you think should be higher |
| A composition cannot reflow at AX5 without dropping content | A register budget you find restrictive |
| A drawing hides content with no affordance saying so | Anything the presentation contract governs |

**Three faults already identified in the drawings**, to be resolved rather than transcribed:

1. **`04` section 6.2a's 9 pt column-head floor is a mock-up value.** 9 pt is below every legibility
   floor that matters on a phone held at arm's length, and the sheets set it in a condensed face with
   .19em tracking, which is worse. Raise it. The Dynamic Type mapping from Phase 1 already scales it,
   but the *default* must be legible unaided. Record the new floor in `04` section 6.2a as an
   amendment, with the reason, before any surface ships it.
2. **The depth chart hides content behind "C 58 Odom, RT 77 Brill below the fold".** A drawing that
   admits it is hiding two of five linemen with no scroll affordance is an unfinished drawing. Either
   the panel scrolls and says so, or the list is complete. Decide and state it.
3. **Coaching HQ budgets exactly three obligation tiles into 87 pt.** The sheets do not say what a
   week with eight obligations does. Answer it before drawing the screen: an overflow row that states
   the count and routes to the full list is the cheapest honest answer.

**How to record a deviation.** In the same commit: a comment at the code naming the sheet value, the
deviation, and the fault it avoids; and a row in `docs/FRONTEND-CHANGE-LEDGER.md` Part E. If the
deviation changes a value `04` states, `04` is amended first — doc-first is not suspended by this
rule, and `DesignContractTests` enforces it regardless.

**What this rule is not.** It is not licence to redesign. The register, the seam, the budgets, the
single radius, the gold and ember rules and the colour system stand. This rule fixes faults; it does
not reopen decisions.

---

## The roadmap

The design ships in **seven batches** and names them on the sheets. Phase 2 follows that decomposition, with one addition at the front.

| Sub-phase | Covers | Surfaces | Entry criterion |
|---|---|---|---|
| **2A** | **The shell** — chrome bar, device frame, seam, and the core primitives | — | Phase 1 complete. **This plan.** |
| 2B | Weekly command — Coaching HQ, Inbox, Opponent report and film room, Game plan, Practice plan, Team health, Match day, Aftermath, Game detail and box score | 9 | 2A merged |
| 2C | Personnel — Roster, Depth chart, Player profile, Development, Staff room | 5 + 3 aliases | 2A merged |
| 2D | Recruiting — Board, Prospect, Shortlist, Visits, Class, Signing day, Offseason | 7 + 4 aliases | 2A merged |
| 2E | Pro management — Cap and contracts, Contract negotiation, Roster cuts and transactions, Draft room, Pro front office | 5 + 3 aliases | 2A merged |
| 2F | League, career and entry — World search, League map, Team and programme profile, Standings, Schedule, Rankings, Bracket, Statistics, Awards, News, Realignment, Opportunities, Stakeholders, Promotion decision | 14 | 2A merged |
| 2G | Retire `CoachWorldTokens` and `CoachWorldCutCorner`; re-target the contract suites | — | 2B to 2F merged |

**2B to 2F are independent of each other** and each produces a shippable result, so they can run in any order or in parallel across worktrees. Each needs its own plan, written against its sheet.

**Why 2A is not optional and not mergeable with a family batch.** `Sources/ProFootballCoachUI/FloodlitChrome.swift` is 41 KB and read by every surface. The Press Box migration learned the same thing and put its shared layer in Part A for the same reason. A family batch drawn before the shell lands is drawn against geometry that then moves.

**What Phase 2 does NOT do.** It does not change what any screen holds. The presentation contract is untouched, and an entry that needs a fact the read model does not carry is an ask, not a drawing.

---

## Phase 2A — the shell

**Deliverable:** every existing surface still renders, still passes its contracts, and now sits inside the Forge Field device frame with the Forge Field chrome bar, drawn entirely from `ForgeFieldTokens` and `ForgeFieldType`. No screen body is redrawn in 2A.

### File structure

| File | Responsibility |
|---|---|
| `Sources/ProFootballCoachUI/ForgeFieldDevice.swift` | **Create.** The 852 x 393 frame, the only 14 pt radius, and the scanline. |
| `Sources/ProFootballCoachUI/ForgeFieldPrimitives.swift` | **Create.** `Panel`, `Seam`, `Row`, `Chip` — the four things every surface composes. |
| `Sources/ProFootballCoachUI/ForgeFieldEmber.swift` | **Create.** The one committing control, with its mandatory cost sub-label. |
| `Sources/ProFootballCoachUI/ForgeFieldChromeBar.swift` | **Create.** The 30 pt bar: mark, club, record, five surfaces, week. |
| `Sources/ProFootballCoachUI/ScreenRegistry.swift` | **Modify.** Re-map the five families to Forge Field's set. |
| `Sources/ProFootballCoachUI/FloodlitChrome.swift` | **Modify.** Host the new bar; retire the Press Box identity band. |
| `Tests/SimTests/Suites/DesignContractTests.swift` | **Modify.** Re-target "Press Box shared chrome"; add the shell contracts. |

### Task 1: Re-map the five families

The chrome names five surfaces and they are not the five that ship. `FF Chrome.dc.html` gives, in order: **This week, Squad, Recruiting, Front office, Ridgeline**. `ScreenRegistry.swift:8-12` currently has `personnel`, `recruiting`, `league`, `career` plus `thisWeek`.

The mapping, which is a ruling and belongs in canon before code:
`thisWeek` stays; `personnel` becomes **Squad**; `recruiting` stays; `career` becomes **Front office**; `league` becomes **Ridgeline**.

**Files:** Modify `docs/04-UX-AND-DESIGN-SYSTEM.md` (a new 6.1f), `Sources/ProFootballCoachUI/ScreenRegistry.swift`. Test: `Tests/SimTests/Suites/DesignContractTests.swift`.

- [ ] **Step 1: Write the canon amendment first.** Add `### 6.1f Forge Field navigation (2026-08-30 amendment)` to `04`, stating the five family names in order, that the bar is 30 pt at `10, 8`, `832 x 30`, spanning columns 1 to 12, and that its contents are fixed: mark, club, record, the five surfaces, the week. Doc-first is not optional and `DesignContractTests` enforces it.
- [ ] **Step 2: Write the failing test.**
```swift
    suite("Forge Field navigation (06.1f)") {
        test("the five families are Forge Field's, in the chrome bar's order") {
            expectEqual(CoachWorldFamily.allCases.map(\.forgeFieldTitle),
                        ["This week", "Squad", "Recruiting", "Front office", "Ridgeline"],
                        "FF Chrome.dc.html fixes both the set and the order")
        }
        test("every screen still resolves to a family") {
            for screen in CoachWorldScreenID.allCases {
                expect(screen.family != nil,
                       "\(screen) has no family — a screen reachable by saved route and by nothing "
                           + "on screen is the alias-host defect the reference package named")
            }
        }
    }
```
- [ ] **Step 3: Run it and watch it fail.** `swift run SimTests --design-contracts` — expect `cannot find 'forgeFieldTitle'`.
- [ ] **Step 4: Add `forgeFieldTitle` to the family enum** returning exactly those five strings. Rename nothing else — the case names `personnel`, `career`, `league` stay, because renaming 58 files' worth of references is Phase 2G's job, not this task's. The title is what the player reads; the case name is what the code reads.
- [ ] **Step 5: Run the tests.** Both must pass.
- [ ] **Step 6: Commit.**
```bash
git add docs/04-UX-AND-DESIGN-SYSTEM.md Sources/ProFootballCoachUI/ScreenRegistry.swift Tests/SimTests/Suites/DesignContractTests.swift
git commit -m "feat: name the five Forge Field families in the chrome bar's order"
```

### Task 2: The device frame and the scanline

**Files:** Create `Sources/ProFootballCoachUI/ForgeFieldDevice.swift`. Test: `Tests/SimTests/Suites/DesignContractTests.swift`.

**Interfaces produced:** `ForgeFieldDevice<Content: View>` with `init(club: ForgeFieldTokens.Club, @ViewBuilder content: () -> Content)`. Tasks 3 to 5 render inside it.

- [ ] **Step 1: Write the failing test.**
```swift
    suite("Forge Field device (06.3a)") {
        test("the device frame is the only 14 pt radius in the system") {
            expectEqual(ForgeFieldTokens.Space.radiusDevice, 14)
            expectEqual(ForgeFieldTokens.Space.radius, 3)
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            let offenders = ui.filter {
                !$0.path.hasSuffix("/ForgeFieldDevice.swift")
                    && !$0.path.hasSuffix("Tokens.swift")
                    && $0.text.contains("radiusDevice")
            }
            expect(offenders.isEmpty,
                   "\(offenders.count) file(s) outside ForgeFieldDevice reach for the device "
                       + "radius: \(offenders.map(\.path).sorted().joined(separator: ", ")). "
                       + "04 6.3a states there is no second radius, so the 14 pt exception lives "
                       + "in exactly one place.")
        }
        test("the scanline is fixed furniture, present on every surface") {
            expectEqual(ForgeFieldTokens.Material.scanlinePeriod, 3)
            expectEqual(ForgeFieldTokens.Material.scanlineOpacity, 0.02)
        }
    }
```
- [ ] **Step 2: Run it and watch it fail.**
- [ ] **Step 3: Write `ForgeFieldDevice`.** An 852 x 393 frame at `ForgeFieldTokens.Space.radiusDevice`, ground 0 behind, the club's flood where a surface asks for one, and the scanline as a fixed overlay at `Material.scanlineOpacity` on a `Material.scanlinePeriod` px period, `.blendMode(.overlay)`, `.allowsHitTesting(false)`. Read the club palette through `ForgeFieldTokens.Club.palette`. **No literal may appear in this file that `ForgeFieldTokens` does not supply.**
- [ ] **Step 4: Run the tests.**
- [ ] **Step 5: Commit.** `feat: add the Forge Field device frame and scanline`

### Task 3: The four core primitives

**Files:** Create `Sources/ProFootballCoachUI/ForgeFieldPrimitives.swift`.

**Interfaces produced:** `ForgeFieldPanel` (optional 19 pt tracked head, ground 2, radius 3, `Edge.panel` inset hairline, no outer shadow), `ForgeFieldSeam` (`.hair` / `.hard`, horizontal or vertical), `ForgeFieldRow` (`.dense` 32 or `.touch` 44), `ForgeFieldChip`. 2B to 2F compose these.

- [ ] **Step 1: Write the failing tests.**
```swift
    suite("Forge Field primitives (06.3a)") {
        test("a dense row is legal only when the whole row is inert") {
            expectEqual(ForgeFieldRow.Height.dense.points, 32)
            expectEqual(ForgeFieldRow.Height.touch.points, 44)
            expect(ForgeFieldRow.Height.touch.points >= ForgeFieldTokens.Space.hitMin,
                   "a tappable row must clear the 44 pt hit floor on its short edge")
        }
        test("the seam carries both alphas and they do not drift") {
            expectEqual(ForgeFieldSeam.Weight.hair.alpha, ForgeFieldTokens.Edge.seamHair)
            expectEqual(ForgeFieldSeam.Weight.hard.alpha, ForgeFieldTokens.Edge.seamHard)
        }
        test("panels cast nothing") {
            expect(!ForgeFieldPanel.castsShadow,
                   "04 6.3a: panels sit flat with an inset hairline. Only a flooded field and an "
                       + "ember control cast a shadow.")
        }
    }
```
- [ ] **Step 2: Run and watch them fail.**
- [ ] **Step 3: Implement the four.** Every value from `ForgeFieldTokens`; every font from `ForgeFieldType.font(_:)`. A panel head is `ForgeFieldType.Step.panel` at `Tracking.chrome`, uppercase, in ink 4.
- [ ] **Step 4: Run the tests.**
- [ ] **Step 5: Commit.** `feat: add the Forge Field panel, seam, row and chip`

### Task 4: The ember, and its cost line

The rule this task exists to enforce: **an ember carries a mono sub-label naming its price, and an action with no cost worth naming is not an ember.** The live app currently offers two options that both read `NO RECORDED COST`, which is what that rule forbids.

**Files:** Create `Sources/ProFootballCoachUI/ForgeFieldEmber.swift`.

**Interfaces produced:** `ForgeFieldEmber` with `init(label: String, cost: String, isEnabled: Bool, action: () -> Void)`. **`cost` is not optional.** The type is the enforcement.

- [ ] **Step 1: Write the failing tests.**
```swift
    suite("Forge Field ember (06.1e)") {
        test("an ember cannot be built without a cost line") {
            // A non-optional `cost` makes this a compile-time guarantee. The test records the
            // rule so a later change to an optional is a deliberate, visible edit.
            let ember = ForgeFieldEmber(label: "Lock the plan",
                                        cost: "3 calls open · costs 9 freshness",
                                        isEnabled: true) {}
            expect(!ember.cost.isEmpty,
                   "04 6.1e: if an action has no cost worth naming, it is not an ember")
        }
        test("the cost line is set in the record face, tabular") {
            expectEqual(ForgeFieldEmber.costStep, ForgeFieldType.Step.figure)
            expectEqual(ForgeFieldType.Step.figure.family, ForgeFieldType.Family.record)
        }
        test("press is the accent ramp's press stop, never a scale") {
            expect(ForgeFieldEmber.pressScale == 1.0,
                   "04 6.1e: press goes to the press stop of the ramp. No shrink, no scale.")
        }
    }
```
- [ ] **Step 2: Run and watch them fail.**
- [ ] **Step 3: Implement.** Fill `ember-lift → ember → ember-press` at 135 degrees, ink `emberInk`, radius 3, `Edge.ember` inset, `shadow-ember`. Label in `ForgeFieldType.Step.chrome`; cost in `.figure`. Disabled is ink 4 at 38 percent **with no tooltip** — the cost line already said why.
- [ ] **Step 4: Run the tests.**
- [ ] **Step 5: Commit.** `feat: add the Forge Field ember with its mandatory cost line`

### Task 5: The chrome bar, and the truncation defect

The bar is `10, 8`, `832 x 30`, columns 1 to 12, contents fixed in order: **mark, club, record, the five surfaces, the week.**

**This task also fixes a defect observed on device**: sibling labels truncate against the right-hand chip on every screen — `PLAYER PROFILE...`, `OPPONENT REPORT...`, `PROSPECT PROFILE...`. Forge Field's bar has no sibling strip at all, so the fix is structural rather than a width tweak.

**Files:** Create `Sources/ProFootballCoachUI/ForgeFieldChromeBar.swift`. Modify `Sources/ProFootballCoachUI/FloodlitChrome.swift`.

- [ ] **Step 1: Read `FloodlitChrome.swift` in full before editing.** It is 41 KB and every surface reads it. Note what `FloodlitChromeReadModel` carries, what `FloodlitIdentityHeader` draws, and which accessibility identifiers the existing contracts assert — `top-navigator` among them.
- [ ] **Step 2: Write the failing test.**
```swift
    suite("Forge Field chrome bar (06.1f)") {
        test("the bar is 30 pt at the stated origin and spans the content column") {
            expectEqual(ForgeFieldChromeBar.height, ForgeFieldTokens.Space.chromeHeight)
            expectEqual(ForgeFieldChromeBar.origin.x, ForgeFieldTokens.Space.margin)
            expectEqual(ForgeFieldChromeBar.origin.y, 8)
            expectEqual(ForgeFieldChromeBar.width,
                        ForgeFieldTokens.Space.viewport.width - 2 * ForgeFieldTokens.Space.margin)
        }
        test("nothing in the bar truncates at the install floor") {
            // The defect this replaces: PLAYER PROFILE, OPPONENT REPORT and PROSPECT PROFILE all
            // clipped against the right-hand chip on the shipped build. Forge Field's bar carries
            // no sibling strip, so the class is removed rather than the instances widened.
            expect(!ForgeFieldChromeBar.carriesSiblingStrip,
                   "FF Chrome fixes the bar's contents: mark, club, record, five surfaces, week")
        }
    }
```
- [ ] **Step 3: Run and watch it fail.**
- [ ] **Step 4: Implement the bar**, then host it from `FloodlitChrome` in place of the Press Box identity band. Club colour is legal here as a 3 pt spine, **not** as the band ground it currently is. Keep every accessibility identifier the existing contracts assert, or change the contract in the same commit and say why.
- [ ] **Step 5: Re-target the "Press Box shared chrome" suite** at `DesignContractTests.swift`. It asserts `backControl`, `FamilySwitcher`, `HostPanel`, `contextShort` and `top-navigator`. Each either survives into the Forge Field bar or is retired with a stated reason. **Do not delete an assertion without replacing it** — a check that quietly disappears is how the shipped truncation survived five screens.
- [ ] **Step 6: Run `swift run SimTests --design-contracts` and `swift build`.** Both green.
- [ ] **Step 7: Run the app.** `xcodegen generate` in `App/`, build for a booted iPhone 17e, launch, and screenshot three surfaces. The bar must render at 30 pt with nothing clipped. **Attach the screenshots to the report** — this is the first task in the whole migration whose result is visible, and a render is the evidence.
- [ ] **Step 8: Commit.** `feat: replace the Press Box identity band with the Forge Field chrome bar`

### Phase 2A exit

- [ ] `swift build` green.
- [ ] `swift run SimTests --design-contracts` green.
- [ ] **Full `swift run SimTests` green.** It takes roughly 3.5 hours and 1,169 tests; run it once, here, not per task.
- [ ] Adversarial review on the phase diff; fix confirmed findings first.
- [ ] App builds, launches, and is screenshotted on a booted device.
- [ ] Ledger row E6 updated with what landed. **Ask the owner before any push or merge.**

---

## What 2B to 2F each need in their own plan

Written once here so five plans do not each re-derive it.

1. **Read the family's sheet first**, and take its geometry as `name · x,y · w×h · cols` verbatim. Do not round to the ladder — the ladder governs gaps you choose, not positions the sheet fixes.
2. **Stamp the budgets as tests.** Every screen's spec column gives its stage percentage and band, points above the seam, gold count, ember count, ghost opacity and size, and background count. Those are review failures, so they are assertions, not prose. Coaching HQ's, as the worked example: stage 62 percent of 393 in a 55 to 65 band, 9 points of 14 above the seam, 2 gold of 3, 1 ember of 1, ghost 244 px at opacity .10 top-right, 2 backgrounds of 2.
3. **Check the presentation contract before drawing.** `docs/reviews/2026-08-22-all-screen-presentation-contract.md` lists what each surface must omit. A sheet that draws a fact the read model does not hold is an ask for Part D, not a licence.
4. **Carry the device-observed defects for that family.** Ledger Part E lists seven. Weekly command owns four of them: the duplicated `WEEK 1 · WEEK 1`, both decision options reading `NO RECORDED COST`, and the empty `WHY IT IS HERE` heading. Recruiting owns two: the empty `RELATIONSHIP LOG` heading, and `SLOTS 0 open` alongside an offered add at `0 contact points` under a header reading `CONTACT 100 left`.
5. **Each surface ends on a render.** A screen is not done because its tests pass; it is done when it has been looked at on a booted device against its drawing.
