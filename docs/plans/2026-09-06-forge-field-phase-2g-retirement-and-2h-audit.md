# Forge Field Phase 2G — retire the Press Box layer; Phase 2H — the audit

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement each phase task-by-task. Steps use checkbox (`- [ ]`) syntax. 2G ends and is gated before 2H starts.

**Goal:** 2G deletes everything the Press Box era left that Forge Field no longer reads — `CoachWorldTokens`, the cut-corner shape, the identity band, the Press Box patterns and their test suites — and re-targets canon and the manifest, so a cold builder finds one design system in the tree. 2H audits every canonical surface against `docs/04b-AUDIT-RUBRIC.md` with the machine gates green on one commit, an evidence pack per family, an independent rubric score, and P0/P1 remediation before the owner's sign-off.

**Architecture:** 2G is a by-construction migration: a test enumerates every reader of the retired layer, the tasks drain that list to zero, and only then is the layer deleted — so nothing is deleted while something still compiles against it. 2H is a procedure over the registry: every surface is captured by a script that reads `CoachWorldScreenID` rather than a hand list, scored by a reviewer who did not draw it, and every P0/P1 is fixed before the phase exits.

**Tech Stack:** iOS 26+, Swift 5.10, SwiftUI; Xcode with the iOS 26 runtime; `xcrun simctl`; `scripts/verify.sh`.

**Spec:** `docs/plans/2026-09-06-forge-field-remaining-roadmap.md` (the roadmap; 2G's entry criterion), `docs/04b-AUDIT-RUBRIC.md` (the rubric), `docs/PRE-DEPLOYMENT-CHECKLIST.md` §1 (the machine gates), `docs/roadmap/06-BUILD-ROADMAP-AND-GATES.md` G3/G8 (audit gates are automated; `04b` scoring is advisory).

**Canon:** `04` (whole), `docs/DOC-MANIFEST.md`, `docs/03b-ARCHITECTURE.md` §5 (the rendered limb of G-12). **Ledger:** Part E rows E6, E7, E8, E10, E14, E22 close here.

**Entry criterion (2G):** 2C, 2D, 2E and 2F all merged onto `main`; every family's budget table and facts registered; the 2S platform-chrome and raw-dollar scans green.

## Global Constraints

Everything in the roadmap's Global Constraints applies. Additionally:

- **Do not delete an assertion without replacing it or retiring it with a stated reason** (2A Task 5's rule). A check that quietly disappears is how the shipped truncation survived five screens.
- **Nothing is deleted while a file still reads it.** The tracker test (Task G1) is the gate for every deletion.
- **No verified code is thrown away to make a migration look tidy** (spec §6): what Forge Field still reads is re-homed, not rewritten.
- **The audit scores nothing the machine gates have not passed.** A red gate is a P0 by definition.
- **No subagent is the sole verifier of its own work** (`CLAUDE.md` Process 9): the 2H scorer did not draw the surfaces.

---

## Phase 2G — retire the Press Box layer

### File structure

| File | Disposition |
|---|---|
| `Sources/ProFootballCoachUI/DesignTokens.swift` (`CoachWorldTokens`, 32 KB) | **Delete** (E14), after Tasks G2–G4 drain its readers to zero. |
| `Sources/ProFootballCoachUI/ForgeFieldTokens.swift`, `ForgeFieldType.swift` | **Modify.** Re-home `ColorValue`, `tracking(_:at:)`, `disabledOpacity(for:)`, the turf/leather/lamp colours, the `Club.resolved(for:)` inputs. |
| `Sources/ProFootballCoachUI/FloodlitChrome.swift` | **Modify.** Keep `FloodlitChromeReadModel` (the app–UI chrome contract); delete the Press Box identity-band code the Forge Field bar replaced. |
| `Sources/ProFootballCoachUI/CoachWorldFloodlitComposition.swift` | **Modify.** Keep `CoachWorldChromedSurface` and `floodlitChrome(_:onNavigate:)` (the hosting contract every root call site uses); delete `CoachWorldFloodlitStage` and `accessibleLayout` once no view composes through them. |
| `Sources/ProFootballCoachUI/FloodlitPatterns.swift` (25 KB), `CoachWorldDeskComponents.swift` (17 KB), `CoachWorldScaledType.swift`, `CoachWorldCutCorner` (wherever it lives after 2F) | **Delete** once unread (E7). |
| `Sources/ProFootballCoachUI/CoachWorldVocabulary.swift` (16 KB) | **Modify.** Keep `CoachWorldSystemState` (the empty/closed/error state every surface still uses), re-skinned on Forge Field tokens; delete the Press Box chips, route buttons and action styles once unread. |
| `Sources/ProFootballCoachUI/CoachWorldMotion.swift` | **Modify.** Keep the Reduce Motion choke point `04` 6.7 and `ReduceMotionContractTests` rely on; move `resolvedDisabledOpacity` to `ForgeFieldTokens.Material`; retarget the durations at `ForgeFieldTokens.Motion`. |
| `Sources/ProFootballCoachUI/RedesignedJobBoardProofView.swift`, `RootView.swift` proof entries `--redesigned-job-board`, `--floodlit-chrome` | **Delete** (a Press Box-era redesign proof and the eight-pattern chrome proof). |
| `*-v3.dc.html` (8 root sheets), `docs/proofs/design-references/`, `docs/proofs/screen-mockups/` | **Delete**; manifest rows say what they were (the `*-v2` precedent). |
| `docs/04-UX-AND-DESIGN-SYSTEM.md` §§6.1a–6.1d, 6.4, 6.5, 6.6, 6.7 | **Modify.** A superseded banner on each, naming the Forge Field section that replaces it; the text stays as amendment history. |
| `docs/DOC-MANIFEST.md`, `CLAUDE.md` (the doc-map row for the v3 sheets), `docs/FRONTEND-CHANGE-LEDGER.md`, `docs/STATUS.md` | **Modify.** |
| `Tests/SimTests/Suites/DesignContractTests.swift` | **Modify.** Retarget or retire eight suites with reasons (Task G6). |
| `Tests/ProFootballCoachUITests/ProFootballCoachUITests.swift`, `scripts/verify.sh` | **Modify.** Retire `testRedesignedJobBoardProofFlow`; put the UI-test target under a gate (Task G7, E22). |

### Task G1: The tracker — every reader of the retired layer, by construction

**Files:** Modify `Tests/SimTests/Suites/DesignContractTests.swift`.

- [ ] **Step 1: Write the test.**
```swift
    suite("Press Box retirement tracker (Phase 2G)") {
        // The retired names. A file that reads any of them is not migrated. This list is the
        // definition of "the Press Box layer"; it shrinks only when a name is deleted from the tree.
        let retired = ["CoachWorldTokens", "CoachWorldCutCorner", "CoachWorldFloodlitStage",
                       "FloodlitIdentityHeader", "CoachWorldStatusChip", "CoachWorldRouteButton",
                       "CoachWorldActionButtonStyle", "CoachWorldGrainOverlay", "FloodlitPatterns"]
        test("no file outside the layer's own definition files reads a retired name") {
            let definitionFiles = ["/DesignTokens.swift", "/FloodlitPatterns.swift",
                                   "/CoachWorldDeskComponents.swift", "/CoachWorldVocabulary.swift",
                                   "/CoachWorldFloodlitComposition.swift", "/FloodlitChrome.swift"]
            let files = swiftFiles(under: "Sources/ProFootballCoachUI") + swiftFiles(under: "Sources/CoachWorldApp")
            let readers = files.filter { file in
                !definitionFiles.contains { file.path.hasSuffix($0) }
                    && retired.contains { strippingLineComments(file.text).contains($0) }
            }
            expect(readers.isEmpty,
                   "\(readers.count) file(s) still read the Press Box layer: "
                       + readers.map { $0.path.split(separator: "/").last.map(String.init) ?? $0.path }.sorted().joined(separator: ", "))
        }
        test("the layer's definition files are gone") {
            let present = swiftFiles(under: "Sources/ProFootballCoachUI").filter {
                $0.path.hasSuffix("/DesignTokens.swift") || $0.path.hasSuffix("/FloodlitPatterns.swift")
                    || $0.path.hasSuffix("/CoachWorldDeskComponents.swift") || $0.path.hasSuffix("/CoachWorldScaledType.swift")
            }
            expect(present.isEmpty, "still present: \(present.map(\.path).sorted())")
        }
    }
```
- [ ] **Step 2: Run it.** The first test prints the reader list (expect the 2B views' residual `CoachWorldTokens.Space/Gap/Pad/Shape/DisplaySize` reads, `ForgeFieldTokens.swift` itself, `CoachWorldTeamLogo.swift`, `TeamIdentity.swift`, `MatchDayField.swift`, and the app module). The second fails. **Both stay red until G5.** Commit the tracker red: `test(ui): add the Press Box retirement tracker` — its failure message is the phase's work list.

### Task G2: Re-home what Forge Field still reads

**Files:** Modify `ForgeFieldTokens.swift`, `ForgeFieldType.swift`, `CoachWorldMotion.swift`, `CoachWorldTeamLogo.swift`, `TeamIdentity.swift`, `MatchDayField.swift`, `MatchDayScoreBug.swift`, `MatchDayView.swift`, and every 2B–2F view still naming `CoachWorldTokens`.

**Interfaces produced:**
- `ForgeFieldColor` — the former `CoachWorldTokens.ColorValue` (`init(hex:)`, `red/green/blue`, `.color`), moved whole into `ForgeFieldTokens.swift` with `public typealias ColorValue = ForgeFieldColor` inside `ForgeFieldTokens` so existing `ForgeFieldTokens.ClubPalette` declarations do not change.
- `ForgeFieldType.tracking(_ em: CGFloat, at points: CGFloat) -> CGFloat` — the former `CoachWorldTokens.DisplaySize.tracking(_:at:)`, same arithmetic.
- `ForgeFieldTokens.Material.disabledOpacity(for contrast: ColorSchemeContrast) -> Double` — the former `CoachWorldTokens.Motion.resolvedDisabledOpacity(for:)` (0.40 standard, 0.62 increased), same values.
- `ForgeFieldTokens.Fixed.turfLit`, `.turfDeep`, `.leather` — `#2A8850`, `#05150D`, `#7A3E1C` from `04` 6.1e (the repeated-literal hazard the token file cited goes with the deleted file); `Material.lampWash` if 2D did not already add it.
- `ForgeFieldTokens.Club.resolved(for:)` no longer reads `CoachWorldTokens.dark`: it resolves the team's `primaryColorHex`/`secondaryColorHex` hue directly (the `CoachWorldTeamIdentity` boundary check it relied on — a contrast test against the Press Box page — is replaced by the same hue-only rule: chromatic primary wins, else secondary, else Calumet). Write the test first: the four authored clubs resolve to themselves from their own hex; an achromatic primary yields to the secondary.

- [ ] **Step 1: Failing tests** — one per moved name, asserting the value is unchanged (`ForgeFieldTokens.Material.disabledOpacity(for: .standard) == 0.40`, `.increased == 0.62`; `ForgeFieldType.tracking(0.14, at: 14)` equals the old function's result on the same inputs, computed once from the old file before it is deleted and pinned as a literal in the test; the three fixed colours' hex digits against `04` 6.1e via `canonHexValues`).
- [ ] **Step 2: Move; retarget every reader** in the ten weekly-command files and the Match Day field (turf, lamp, ball, gold ink, opponent accent — each to its Forge Field name; `fieldLine` and `opponentAccent` are Match Day register values `04` 6.1b states — re-home them as `ForgeFieldTokens.Broadcast` with the section cited). Replace residual `CoachWorldTokens.Space.sm`/`Gap.hair`/`Pad.card` reads with the `ForgeFieldTokens.Space.ladder` entry of the same value; where the values differ, the Forge Field ladder wins and the commit body says which view moved by how much (a rendered before/after of that view is attached).
- [ ] **Step 3: Build; `--design-contracts`; `--core-contracts`; render Coaching HQ and Match Day** (the two most token-dense surfaces) and compare against the 2B captures — unchanged.
- [ ] **Step 4: Commit.** `refactor(ui): re-home the colour type, tracking, disabled opacity and fixed colours under Forge Field`

### Task G3: Delete the cut corner (E7)

- [ ] **Step 1:** `grep -rn CoachWorldCutCorner Sources/` — after 2C–2F every view is on the 3 pt radius; the remaining readers are `CoachWorldVocabulary.swift`, `MatchDayScoreBug.swift`, `FloodlitPatterns.swift`. Convert the first two to `RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)`.
- [ ] **Step 2: Retarget the "Floodlit geometry (06.1a)" suite**: its cut-corner assertions become one — no `CoachWorldCutCorner` and no `cornerRadius:` literal other than `ForgeFieldTokens.Space.radius` / `.radiusDevice` anywhere under `Sources/ProFootballCoachUI` (the "device frame is the only 14 pt" test already covers the second half; fold them).
- [ ] **Step 3: Delete the type. Build; suites; commit.** `refactor(ui): retire the Press Box cut corner for the one Forge Field radius`

### Task G4: Delete the Press Box chrome, stage, patterns and desk components

- [ ] **Step 1: `FloodlitChrome.swift`** — delete `FloodlitIdentityHeader`, the band, the sibling strip and the Press Box back control; keep `FloodlitChromeReadModel` and the `ForgeFieldChromeBar` host. The UI test `testForgeFieldChromeBarReplacesThePressBoxNavigator` stays as the proof.
- [ ] **Step 2: `CoachWorldFloodlitComposition.swift`** — delete `CoachWorldFloodlitStage` and `accessibleLayout` (every view now composes its own AX5 branch inside `ForgeFieldDevice`); keep the protocol and `floodlitChrome(_:onNavigate:)`.
- [ ] **Step 3: `CoachWorldVocabulary.swift`** — re-skin `CoachWorldSystemState` on `ForgeFieldPanel` + `ForgeFieldType` (it is the empty/closed/error state Signing day, Draft room and Realignment use); delete `CoachWorldStatusChip`, `CoachWorldRouteButton`, `CoachWorldActionButtonStyle` (readers: the two 2B views that still name them — convert to `ForgeFieldChip` / plain 44 pt controls first).
- [ ] **Step 4: Delete `FloodlitPatterns.swift`, `CoachWorldDeskComponents.swift`, `CoachWorldScaledType.swift`, `RedesignedJobBoardProofView.swift`**; delete the `--redesigned-job-board` and `--floodlit-chrome` entries in `RootView.swift` and `testRedesignedJobBoardProofFlow`; delete `BlankPhotoPlate.swift` only if 2C/2D replaced its initials logic (the monogram plates) — otherwise re-home it as `ForgeFieldMonogramPlate` in `ForgeFieldPrimitives.swift`.
- [ ] **Step 5: Build; suites; the tracker's first test now lists only `DesignTokens.swift`'s own readers, if any. Commit.** `refactor(ui): delete the Press Box chrome, stage, patterns and desk components`

### Task G5: Delete `CoachWorldTokens` (E14)

- [ ] **Step 1:** the tracker's first test must pass with `DesignTokens.swift` still present (zero readers). If it does not, the reader list is the work.
- [ ] **Step 2: Delete `Sources/ProFootballCoachUI/DesignTokens.swift`.** Build. Both tracker tests green.
- [ ] **Step 3: Retarget "Design token sync"**: it compared `04` §6.1's hex values with `CoachWorldTokens`; it now compares `04` 6.1e's 72 values with `ForgeFieldTokens` (the "Forge Field tokens (06.1e, 06.3a, 06.7a)" suite already does the per-club palettes — fold, do not duplicate) and asserts no hex literal exists under `Sources/ProFootballCoachUI` outside `ForgeFieldTokens.swift` (the repeated-literal scan's successor).
- [ ] **Step 4: Commit.** `refactor(ui): delete CoachWorldTokens -- Forge Field is the only token layer`

### Task G6: Retarget or retire the Press Box suites (E8, E10)

For each, the reason goes in the commit body and in a comment where the suite was:

| Suite | Disposition |
|---|---|
| `Press Box shared chrome` | **Retired.** Its `backControl`, `FamilySwitcher`, `HostPanel`, `contextShort`, `top-navigator` assertions were each carried into `Forge Field chrome bar (06.1f)` / `Forge Field fix round 2` in 2A Task 5 or retired there with reasons; state the mapping row by row. |
| `Floodlit dark-only (06.1a)` | **Retargeted** to 6.1e: no light palette exists (`ForgeFieldTokens` has no light case; no `colorScheme == .light` branch under `Sources/ProFootballCoachUI`). |
| `Floodlit geometry (06.1a)` | **Retargeted** in G3 to the single radius. |
| `Symbol register`, `Retired symbols (06.1c)`, `Floodlit vocabulary symbol sourcing (Task 4)` | **Replaced** by one suite, `Forge Field has no icon set (06.6a)`: no `Image(systemName:` and no `Label(_:systemImage:)` under `Sources/ProFootballCoachUI`; the only non-alphanumeric glyphs in string literals are `★`, `←`, `→`, `−`, `+`, `·`, `′`, `″` (enumerate the allowed set from `04` 6.6a and 6.3a(i); a new glyph fails until canon names its class and cap). |
| `Design reference sheets` | **Retired** with the v3 sheets' deletion (Task G7); its role — "the sheets exist and are named as canon says" — has no successor because the Forge Field sheets live outside the tree and the transcription is the spec. |
| `Design token sync` | **Retargeted** in G5. |
| `Floodlit route bar`/`Forge Field route bar (06.1f(i))` | **Kept**; 2F Task 2 already re-skinned the bar under it. |

- [ ] **Step 1: Make each change; `--design-contracts` green; the suite count in STATUS is restated.**
- [ ] **Step 2: Commit.** `test(ui): retire the Press Box suites and replace the symbol register with the no-icon-set scan`

### Task G7: Canon, manifest, the sheets, and the UI-test gate (E22)

- [ ] **Step 1: `04`** — above each of §§6.1a, 6.1b, 6.1c, 6.1d, 6.4, 6.5, 6.6, 6.7 add one line: `> **Superseded 2026-09-xx by §6.1e / 6.1f / 6.3a / 6.6a / 6.7a (Forge Field).** Kept as amendment history; nothing in this section is implemented.` (6.1b's Match Day register values that Forge Field kept — turf, lamp, ball, gold ink — are cited from 6.1e/`ForgeFieldTokens.Broadcast` instead; say so in the banner.)
- [ ] **Step 2: Delete the eight `*-v3.dc.html`, `docs/proofs/design-references/` and `docs/proofs/screen-mockups/`.** In `docs/DOC-MANIFEST.md` §4a: one `DELETED` row per file group in the `*-v2` row's format (what it was, why, `git show` recovers it); §4b already records the supersession. In `CLAUDE.md`'s document table, replace the `*-v3.dc.html` row with one for the Forge Field sheets (external, transcribed in `docs/superpowers/specs/2026-08-29-forge-field-standard.md` and the six 2026-09-06 plans).
- [ ] **Step 3: E22 — put `Tests/ProFootballCoachUITests/` under a gate.** In `scripts/verify.sh`'s `app` lane, after the build, run `xcodebuild test -project App/ProFootballCoach.xcodeproj -scheme ProFootballCoach -destination 'platform=iOS Simulator,id=<the lane's booted UDID>' -only-testing:ProFootballCoachUITests` when a simulator is booted, and fail the lane when it is not (a lane that silently skips is the E22 defect). **Owner decision FF-9:** if the lane's cost is refused, the target is retired instead — never left ungated.
- [ ] **Step 4: Build; `--design-contracts` (the manifest suite reads the new rows); `scripts/verify.sh --lane app`.**
- [ ] **Step 5: Commit** (two: `docs: supersede the Press Box sections of 04 and delete the v3 sheets`; `ci: gate the UI-test target in the app lane`).

### Task G8: Ledger and STATUS

- [ ] Rows E6, E7, E8, E10, E14, E22 → DONE with what landed; one dated STATUS entry with the suite counts before and after.
- [ ] Commit. `docs: record the Press Box retirement in the ledger and STATUS`

### Phase 2G exit

- [ ] `swift build` green; the tracker suite green; `--design-contracts` and `--core-contracts` green.
- [ ] `grep -rn "CoachWorldTokens\|CoachWorldCutCorner\|FloodlitPatterns" Sources/ Tests/` returns nothing but the tracker's own list.
- [ ] Coaching HQ, Match Day, Roster, Recruiting board, Cap & contracts and Career hub re-rendered and compared with their family captures — unchanged.
- [ ] Adversarial review on the phase diff; confirmed findings fixed first. Not a build.
- [ ] Full `swift run SimTests` green — once, here.
- [ ] `docs/DOC-MANIFEST.md` counts in its §5 table restated. **Ask the owner before any push or merge.**

---

## Phase 2H — the audit

**Entry criterion:** 2G merged; **2I merged** (`docs/plans/2026-09-06-forge-field-phase-2i-completion-and-2j-release-candidate.md`) — the audit scores surfaces whose recorded asks have become facts, and H1's lanes include the calibration and performance gates 2I makes green; **FF-1 (E18/E38, the chrome bar and route bar at AX5) decided by the owner and implemented** — dimension 6 cannot be scored honestly while the product's AX5 navigation is an open question.

### What the audit is, and is not

`docs/04b-AUDIT-RUBRIC.md` §1: the score is advisory product feedback; **release approval uses the automated source, accessibility, reachability and P0/P1 contracts**. So 2H has two halves that must not be confused: **H1** makes every machine gate green on one commit (blocking); **H2–H4** score, find and fix (P0/P1 blocking, P2 revise, P3 recorded). A high score cannot offset a red gate; a beautiful still cannot offset an inoperable surface.

### Task H1: Every machine gate, on one commit

**Files:** Modify `Tests/SimTests/Suites/DesignContractTests.swift` (one closing assertion); `scripts/verify.sh` is run, not edited.

- [ ] **Step 1: Close the budget contract.** Add to the 2S generic suite:
```swift
        test("every family has a budget table -- the migration is complete") {
            expectEqual(Set(ForgeFieldBudget.tables.keys), Set(CoachWorldSurfaceFamily.allCases),
                        "a family with no table has surfaces drawn to no contract")
        }
```
It passes only when 2C–2F all landed; run and confirm.
- [ ] **Step 2: Run the lanes**, recording exact commands and counts in the audit document (Task H3) as they finish:
```bash
swift build
swift run SimTests --design-contracts
swift run SimTests --core-contracts
swift run SimTests --legal-only          # runnable on demand; deferred as a gate (CLAUDE.md), recorded not asserted
./scripts/verify.sh --lane accessibility
./scripts/verify.sh --lane app           # XcodeGen + iOS build + the UI-test target (G7)
./scripts/verify.sh --lane determinism
./scripts/verify.sh                      # full package lane: build + the complete SimTests run
```
- [ ] **Step 3: Assert the `04b` §8 machine checks by name**, each to the suite that owns it, and list any that has no owner as a finding: every canonical family registered exactly once (`AccessibilityReflowTests` partition); every displayed field maps to a read model (the per-surface `*DataPointRoles` and the contract rows); no authored type below 12 pt (`ForgeFieldType` floors: `.columnHead` 10 is the one exception canon states for tracked labels, cite 6.2a(i)); 44 × 44 targets (`ForgeFieldRow.touch`, the chrome-bar hit test, `ForgeFieldField`/`Stepper` heights, the filter rail); no horizontal overflow at the exact frames (H2's captures); contrast in the shipped appearance (`04` 6.1e's measured column; a scan over the palette pairs actually used — write it if absent); Increase Contrast raises hairlines and moves no ink (`Edge` alphas branch on `colorSchemeContrast`); gold count per surface (`ForgeFieldSurfaceFacts.goldElementCount` ≤ budget, and zero on Desk); every unavailable control beside its reason (the `unavailableReason` rulings in every family plan — scan for `isEnabled: false` without a reason string nearby is not machine-checkable; record as reviewed); Reduce Motion forms (`ReduceMotionContractTests`); no screen imports engine internals (`ArchitectureTests`); every feed bounded (`maximumRows`/`prefix` on every read model — `ContractTests`' bound scan); deterministic accessibility order (`accessibilitySortPriority` clause).
- [ ] **Step 4: Commit** the closing assertion. `test(ui): assert every family carries a Forge Field budget table`

### Task H2: The evidence pack, generated from the registry

**Files:** Create `scripts/capture-forge-field.sh`; modify `Tests/SimTests/main.swift` (a `--canonical-screens` flag that prints `number<TAB>slug` for every `CoachWorldScreenID` with `isCanonicalTask`, so the script never hand-lists screens — the coverage-boundary rule); output under `docs/proofs/forge-field/<family-slug>/`.

**The matrix, from `04b` §6 and `04` §7:** three frames — 844 × 390 (iPhone 17e, the install floor), 852 × 393 (an iPhone 15 Pro-class simulator, the promise floor), 956 × 440 (iPhone 17 Pro Max, the ceiling); dark only (`04` 6.1a/7 retired light); default and AX5 type; sensor-left and sensor-right (`simctl` device orientation `landscapeLeft`/`landscapeRight`); Reduce Motion on, for the surfaces the AX5 contract flags as animated (Match Day); Increase Contrast on, one frame per family; every applicable loading, empty, error, delegated and interrupted state where a fixture exists (`PROOF_SCREEN` variants: `aftermath-minimum`, `aftermath-overflow`, `game-detail-overflow`, Title's three states, Signing day's two phases, Draft room in and out of phase).

- [ ] **Step 1: `--canonical-screens`** in `main.swift`, printing from the registry. Test: its output has 47 lines (the contract's canonical count) — assert `count == CoachWorldScreenID.allCases.filter(\.isCanonicalTask).count`, not 47.
- [ ] **Step 2: The script.** For each UDID in the three-device list (resolved by name with `xcrun simctl list devices available --json`, never a pasted UDID), boot, install the Debug build, and for each registry line launch with `PROOF_SCREEN_NUMBER=<n>` at `content_size medium` and `accessibility-extra-extra-extra-large`, in both orientations, screenshot to `<family>/<n>-<slug>-<w>x<h>-<size>-<orientation>.png`, rotate with `sips -r` for review; reset the content size after. Title and Coach identity are captured without the override (they are what launches). Record every launch that fails to reach its screen as a finding, not a skipped capture.
- [ ] **Step 3: Run it; look at every capture.** Two people-hours minimum per family; the reviewer notes, per surface, any clipping, overlap, truncation, off-screen control, unreadable text, missing state, or fact that does not match the read model — with the capture's file name. Notes go in Task H3's document under the surface.
- [ ] **Step 4: Commit the script and the flag** (not the captures — they are review evidence; keep them out of the repository unless the owner wants them in, as `docs/proofs/` precedent suggests they are in; follow the precedent: commit them, they are the evidence). `feat(test): capture every canonical surface across the device, type and orientation matrix`

### Task H3: The rubric score, by someone who did not draw it

**Files:** Create `docs/reviews/2026-xx-xx-forge-field-04b-audit.md`.

- [ ] **Step 1: Dispatch the scorer.** Use `adversarial-reviewer` (or a fresh reviewer subagent under the delegation cap) with: the rubric, the seven family plans' spec columns, the evidence pack, the contract, and read access to `Sources/ProFootballCoachUI`. The scorer did not write any 2C–2F commit. Instruction: score each of the seven families (`CoachWorldSurfaceFamily.allCases`) on the eight dimensions with the §3 anchors, in its real career context, one surface at a time; run the ten §4 automatic-rejection checks on every surface; classify every finding P0–P3 by §5 with `file:line` and the capture name; borderline findings classify upward.
- [ ] **Step 2: The document's shape:** one section per family: the eight scores and the total; the automatic-rejection table (10 × surfaces, pass/fail); the findings table (severity, surface, evidence, file:line, the rubric dimension); and the family's verdict (Strong ≥ 31 with no P0/P1/rejection; Revise 24–30 or any P2 that weakens the dominant task; Weak below 24 or any P0/P1/rejection). Then a product section: the `04b` §7 five advisory questions answered for Coaching HQ, Recruiting board and Match day together; the §8 machine-check table from H1 with each check's owning suite; the exact commands and counts from H1; and the list of `04b` §6 evidence items **not** produced (physical device, VoiceOver, Voice Control, Switch Control, sound/haptic equivalents — the owner-executed gates in `docs/PRE-DEPLOYMENT-CHECKLIST.md` and the owner-gate packs 03–10) stated as not produced.
- [ ] **Step 3: An adversarial pass on the score itself** — a second reviewer refutes findings (the `docs/AUDIT.md` precedent: 84 raised, 6 refuted, kept in an appendix). Refuted findings stay in the appendix with the refutation.
- [ ] **Step 4: Commit the document.** `docs(review): score every Forge Field family against 04b`

### Task H4: Remediation

- [ ] **Step 1: P0 and P1 — fix, in the family's own file, one commit per finding**, each with the finding's id in the commit body; re-capture the surface; the scorer re-scores that dimension. A P0/P1 that needs a read-model change is an escalation to the owner (it is the E24 shape), not a drawing — the surface stays reject until it is decided.
- [ ] **Step 2: P2 — fix where it is presentation; where it is not, an owner-approved ledger row** (`Revise before production`).
- [ ] **Step 3: P3 — a ledger row each** (`May ship only with recorded follow-up`).
- [ ] **Step 4: Confidence review and rewrite tournament** on every remediation commit (the session hooks require it; it is also where the second reviewer earns their keep).
- [ ] **Step 5: Re-run H1's lanes on the remediated commit.** Green on one commit, recorded.

### Task H5: Sign-off

- [ ] **Step 1: The whole-phase adversarial review** — the diff from the 2S entry commit to HEAD, one pass, findings fixed first. Not a build; never reported as one.
- [ ] **Step 2: Full `swift run SimTests`** on HEAD, uninterrupted, counts recorded.
- [ ] **Step 3: STATUS** — the honest state: what is drawn (47 of 47), what is verified (exact suites and counts, the lanes), what is rendered (the pack), what the score is per family, what is not verified (the owner-executed gates), and the ledger's open rows.
- [ ] **Step 4: Ledger** — the audit's rows; every open FF decision with its state.
- [ ] **Step 5: The owner's gates.** Hand over `docs/PRE-DEPLOYMENT-CHECKLIST.md` §1 with every box's evidence line, and the owner-gate packs 03–10 for the owner to run on hardware. Their observations are product evidence and do not block machine-verifiable completion (`CLAUDE.md` Process 6), but the audit document says which were run and what they saw.
- [ ] **Step 6: Push and merge only with the owner's word.** The repository stays on `main`.

### Phase 2H exit

- [ ] Every H1 lane green on one recorded commit.
- [ ] The evidence pack complete for every canonical surface (the script's line count equals the registry's).
- [ ] The audit document landed with seven family scores, zero open P0/P1, every P2 fixed or owner-approved, every P3 recorded.
- [ ] STATUS and ledger current. **Owner sign-off recorded before any push.**

---

## After 2H — Phase 2J

`docs/plans/2026-09-06-forge-field-phase-2i-completion-and-2j-release-candidate.md` — the release candidate: every machine gate enumerated from `SuiteCatalog` and `scripts/verify.sh` on one commit, release hygiene, and the owner's hardware pack prepared. At its exit only human testing approval, the §4a owner-only distribution gates and the final legal sweep remain.
