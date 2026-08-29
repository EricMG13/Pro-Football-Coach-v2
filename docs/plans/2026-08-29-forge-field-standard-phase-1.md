# Forge Field Standard — Phase 1 (canon and token layer) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Forge Field the design standard of record — in `DOC-MANIFEST`, in `04`, and in a Swift
token layer that compiles and is machine-checked against canon — without touching a single surface view.

**Architecture:** Strangler, not rewrite. `CoachWorldTokens` keeps working and every existing view
keeps compiling; a parallel `ForgeFieldTokens` layer lands beside it, proven against canon by the
existing contract suite. Surface-by-surface migration of the 57 files that read `CoachWorldTokens` is
Phase 2 and gets its own plan. Canon lands before Swift because `DesignContractTests` machine-enforces
that order: it parses `04` §6.1 for hex values and fails any `0xRRGGBB` in the token layer that canon
does not state.

**Tech Stack:** Swift 6.3.3 (`/Users/ericguei/.swiftly/bin/swift`), SwiftUI, XcodeGen (`App/project.yml`),
hand-rolled test harness (`Tests/SimTests/TestKit.swift`) run as an executable target.

**Spec:** `docs/superpowers/specs/2026-08-29-forge-field-standard.md`

## Global Constraints

- **iOS 26+, Swift 5.10 language mode, SwiftUI. iPhone-only, landscape-only.** Offline. **Zero
  third-party app dependencies.**
- **No emoji** in code, UI copy, commits or docs.
- **Doc-first.** A design decision is written into canon before it is implemented. Never encode a
  design decision only in code.
- **Ratings are 40–99 `Int`. Money is integer dollars.** No floating-point currency.
- **A design-token literal in a view is a defect.** Every spacing, radius, colour and font size comes
  from the token layer.
- **Coverage boundary is not the quality boundary.** A test that checks a class of surfaces must
  enumerate that class **by construction**.
- **Conventional Commits.** One task = one commit.
- Full suite: `swift run SimTests`. Design contracts only: `swift run SimTests --design-contracts`.
- **Do not commit, push or merge without the owner's approval.** Prepare the commit; ask before running it.

---

### Task 1: Record the authority change in DOC-MANIFEST

**Files:**
- Modify: `docs/DOC-MANIFEST.md:118-124` (the "External design standard — added 2026-08-24" block)
- Test: `Tests/SimTests/Suites/DesignContractTests.swift:201-232` (existing "Document manifest" suite)

**Interfaces:**
- Consumes: nothing.
- Produces: the manifest row every later task cites as the source of authority. No Swift symbols.

- [ ] **Step 1: Read the section being replaced**

Run: `sed -n '116,126p' docs/DOC-MANIFEST.md`
Expected: the single-row table naming Press Box project `3e8bedda-4c56-4be1-8f3a-98f9c2e82d9d` as `RETAINED`.

- [ ] **Step 2: Replace the heading and table**

Replace the block that starts `### External design standard — added 2026-08-24` and ends at the blank
line after its table with:

```markdown
### External design standard — added 2026-08-24, superseded 2026-08-29

| Reference | Classification | Reason | Where its role lives now |
|---|---|---|---|
| **Forge Field**, Claude Design project `8c511c92-3337-4cfb-850c-140a659f3034` | `RETAINED` | Owner-approved 2026-08-29 as the design standard, replacing Press Box. Its grant is scoped exactly as the Press Box grant was: design questions only. | Forge Field decides how a frontend is drawn; `docs/04-UX-AND-DESIGN-SYSTEM.md` remains the canon a repository builder implements against, because this repository cannot open the design tool. `docs/superpowers/specs/2026-08-29-forge-field-standard.md` is the self-sufficient transcription. Changes flow Forge Field → `04` → Swift. |
| **Press Box**, Claude Design project `3e8bedda-4c56-4be1-8f3a-98f9c2e82d9d` | `SUPERSEDED` | Owner-approved 2026-08-23, superseded 2026-08-29 by Forge Field. Its `AUTHORITY.md` boundary section carries forward verbatim — Forge Field inherits the same limits and overrides no fact, no read model, no legal guardrail and no accessibility floor. | Composition reference and change history. `docs/FRONTEND-CHANGE-LEDGER.md` stays live; see its Part D. |

**What the supersession does not change.** Press Box's `AUTHORITY.md` recorded three questions the
owner settled on 2026-08-23. Two of them — the register-aware type model, and team identity resolved
once at the stage — were decided on their merits and are unaffected by which project holds the grant.
The third, refusing team-coloured primary actions, **is** reversed by Forge Field's per-club ember;
that reversal is recorded in `docs/superpowers/specs/2026-08-29-forge-field-standard.md` §2.1 with the
measured hue collision it carries, so it reads as a decision rather than as drift.
```

- [ ] **Step 3: Register the spec directory**

Confirm `docs/superpowers/specs/` is already classified in the manifest. Run:

```bash
grep -c "docs/superpowers/specs/" docs/DOC-MANIFEST.md
```

Expected: a count of at least 1. If it is 0, add a row for it in the manifest's section 8 reading
`| \`docs/superpowers/specs/\` | Design and feature specs produced by the brainstorming skill. Inputs to canon, never canon themselves. | none |` — the "Document manifest" test enumerates directories from disk and fails on any the manifest does not name.

- [ ] **Step 4: Run the design contracts**

Run: `swift run SimTests --design-contracts`
Expected: PASS, including "every docs directory holding markdown is classified in DOC-MANIFEST".

- [ ] **Step 5: Prepare the commit and ask before running it**

```bash
git add docs/DOC-MANIFEST.md docs/superpowers/specs/2026-08-29-forge-field-standard.md
git commit -m "docs: make Forge Field the design standard of record"
```

---

### Task 2: Amend `04` with the Forge Field foundations

**Files:**
- Modify: `docs/04-UX-AND-DESIGN-SYSTEM.md` — insert a new `### 6.1e` immediately before `### 6.2 Typography` (line 798), and new `### 6.2a`, `### 6.3a`, `### 6.6a`, `### 6.7a` after their parent sections
- Test: `Tests/SimTests/Suites/DesignContractTests.swift:272-295` (existing "Design token sync" suite)

**Interfaces:**
- Consumes: Task 1's manifest row.
- Produces: every hex, size, radius, gap and duration Task 4 and Task 5 are allowed to ship. `canonHexValues()` parses this section; a value absent here cannot appear in Swift.

- [ ] **Step 1: Confirm what the canon parser reads**

Run: `sed -n '23,50p' Tests/SimTests/Suites/DesignContractTests.swift`
Expected: `canonText()` and `canonHexValues()` — note the section bounds they parse, so §6.1e is written inside them.

- [ ] **Step 2: Write §6.1e — the Forge Field palette**

Insert before line 798. Transcribe **verbatim** the two tables in
`docs/superpowers/specs/2026-08-29-forge-field-standard.md` §2.1 — the four-club grounds/inks/hairline/
ember/club table, and the fixed gold/signals/failure/turf/leather table — under this heading and preamble:

```markdown
### 6.1e Forge Field palette (2026-08-29 amendment, dark-only, club-derived)

Approved 2026-08-29 (`docs/superpowers/specs/2026-08-29-forge-field-standard.md`). This section
replaces §6.1a's fixed grounds and inks. **Forge Field derives ground and ink from the club hue**:
one variable re-derives the four grounds, the four inks, the hairline, the ember and the mark.
Saturation carries identity; lightness is pinned, so the measured contrast column holds for every
club and one pick re-themes the product without re-review. Dark-only is unchanged from §6.1a.

`rival` is a declared alias of `signal-cold`, not a repeated literal — §6.1a(ii) and the
`DesignContractTests` repeated-literal scan both require this.
```

Then append the two rules blocks from spec §2.1: the ember/gold/signals/club-colour rules, and the
recorded Maritime-ember hue collision.

- [ ] **Step 3: Write §6.2a, §6.3a and §6.7a**

After §6.2 insert `### 6.2a Forge Field type (2026-08-29 amendment)` carrying spec §2.2 verbatim —
the three families, the eleven steps, the line heights, the tracking and the three floors — and this
sentence, which is the thing §6.2 currently forbids:

```markdown
**This supersedes §6.2's "use the system family in production" for the Forge Field register.** §6.2
gated a bundled face on licence, full Dynamic Type range, numerals, localisation and VoiceOver
behaviour being verified. The licence is settled in Task 3; the Dynamic Type range is settled in
Task 4; neither is waived.
```

After §6.3 insert `### 6.3a Forge Field space and shape (2026-08-29 amendment)` carrying spec §2.3
verbatim — the 4/8/12/16/24/32/44 ladder, the single 3 px radius, the 12-column grid at 9 px gutters
and 10 px margins, the row table and the elevation table.

After §6.6 insert `### 6.6a Forge Field has no icon set (2026-08-29 amendment)` carrying spec §2.6
verbatim, and open it with the contradiction stated plainly rather than left for a reader to find:

```markdown
**This reverses §6.3's "Icons use SF Symbols as one coherent line family."** Forge Field ships no icon
set, and states it as a deliberate choice rather than a gap: status is a signal dot, identity is a
mark plate, and the only permitted glyphs are `★` U+2605 and the arrows `←` `→`. A glyph beside every
row reads as a data point whether or not it carries information, which is what would break §2.5's
data-point budget. §6.6's symbol register is therefore retired for Forge Field surfaces, not amended.

**If an icon is ever needed, the class is specified first, with a per-class cap.** Adding a symbol
family without one is the failure this section exists to prevent.
```

After §6.7 insert `### 6.7a Forge Field motion (2026-08-29 amendment)` carrying spec §2.4 verbatim —
the four transitions with their durations and curves, the 1200 ms ceremony exception, the travel
values, and the reduced-motion collapse to 90 ms with the flood wipe becoming a cut.

- [ ] **Step 4: Run the design contracts**

Run: `swift run SimTests --design-contracts`
Expected: PASS. The colour-sync test parses at least 30 hex values and finds no undeclared literal;
nothing in Swift has changed yet, so this proves only that the new section did not break the parser.

- [ ] **Step 5: Prepare the commit and ask before running it**

```bash
git add docs/04-UX-AND-DESIGN-SYSTEM.md
git commit -m "docs: amend 04 with Forge Field palette, type, space and motion"
```

---

### Task 3: Bundle the three type families

**Files:**
- Create: `Sources/ProFootballCoachUI/Resources/Fonts/SairaCondensed-{Regular,Medium,SemiBold,Bold}.ttf`
- Create: `Sources/ProFootballCoachUI/Resources/Fonts/Figtree-{Regular,Medium,SemiBold}.ttf`
- Create: `Sources/ProFootballCoachUI/Resources/Fonts/JetBrainsMono-{Regular,Medium,Bold}.ttf`
- Create: `Sources/ProFootballCoachUI/Resources/Fonts/OFL-{SairaCondensed,Figtree,JetBrainsMono}.txt`
- Modify: `App/project.yml:24` (inside `settings.base`)
- Test: `Tests/SimTests/Suites/DesignContractTests.swift` (new suite)

**Interfaces:**
- Consumes: §6.2a from Task 2, which names the three families.
- Produces: the PostScript family names `"Saira Condensed"`, `"Figtree"`, `"JetBrains Mono"` that Task 4's `Font.custom(_:size:)` calls use.

- [ ] **Step 1: Write the failing test**

Append to `Tests/SimTests/Suites/DesignContractTests.swift`, inside `runDesignContractTests()`:

```swift
    suite("Forge Field fonts (06.2a)") {
        // 04 6.2 gates a bundled face on its licence being verified, and the app is offline with
        // zero third-party dependencies -- a webfont @import is not an option. So the binaries ship,
        // and each one ships beside its licence. Enumerated from project.yml rather than hand-listed:
        // a family added to the declaration is covered the day it is added.
        test("every family declared in UIAppFonts ships a binary and a licence") {
            let root = packageRoot()
            let ymlURL = root.appendingPathComponent("App/project.yml")
            guard let yml = try? String(contentsOf: ymlURL, encoding: .utf8) else {
                expect(false, "App/project.yml is unavailable")
                return
            }
            let declared = matches(of: "Fonts/([A-Za-z]+-[A-Za-z]+\\.ttf)", in: yml)
            expect(declared.count >= 10,
                   "parsed only \(declared.count) font files from project.yml — the parser, not the "
                       + "bundle, is what failed")

            let fontDir = root.appendingPathComponent("Sources/ProFootballCoachUI/Resources/Fonts")
            let missing = declared.filter {
                !FileManager.default.fileExists(atPath: fontDir.appendingPathComponent($0).path)
            }
            expect(missing.isEmpty,
                   "UIAppFonts declares \(missing.count) file(s) that do not ship: "
                       + "\(missing.sorted().joined(separator: ", "))")

            let families = Set(declared.compactMap { $0.split(separator: "-").first.map(String.init) })
            let unlicensed = families.filter {
                !FileManager.default.fileExists(
                    atPath: fontDir.appendingPathComponent("OFL-\($0).txt").path)
            }
            expect(unlicensed.isEmpty,
                   "\(unlicensed.count) family(ies) ship without a licence file: "
                       + "\(unlicensed.sorted().joined(separator: ", ")). 04 6.2 gates a bundled "
                       + "face on its licence being verified, so the licence ships with the binary.")
        }
    }
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `swift run SimTests --design-contracts 2>&1 | grep -A3 "Forge Field fonts"`
Expected: FAIL — "parsed only 0 font files from project.yml".

- [ ] **Step 3: Download the binaries and licences**

Fetch the static TTFs and each repository's `OFL.txt` from the upstream font projects, place them at
the paths above, and rename each licence to `OFL-SairaCondensed.txt`, `OFL-Figtree.txt`,
`OFL-JetBrainsMono.txt`. **Open each licence and confirm it is SIL Open Font License 1.1 before
committing it** — the spec asserts this from the source project's own claim, and the file that ships
is the thing that settles it. If any family is not OFL, stop and escalate rather than substituting a
different face.

- [ ] **Step 4: Declare them in project.yml**

Add to `App/project.yml` under `targets.ProFootballCoach.settings.base`:

```yaml
        # Forge Field ships three families (04 6.2a). The app is offline, so the binaries are
        # bundled rather than fetched; each ships beside its OFL licence, and the Forge Field
        # font contract test reads this list rather than a hand-maintained copy of it.
        INFOPLIST_KEY_UIAppFonts: "Fonts/SairaCondensed-Regular.ttf Fonts/SairaCondensed-Medium.ttf Fonts/SairaCondensed-SemiBold.ttf Fonts/SairaCondensed-Bold.ttf Fonts/Figtree-Regular.ttf Fonts/Figtree-Medium.ttf Fonts/Figtree-SemiBold.ttf Fonts/JetBrainsMono-Regular.ttf Fonts/JetBrainsMono-Medium.ttf Fonts/JetBrainsMono-Bold.ttf"
```

`Package.swift` already declares `resources: [.process("Resources")]` for `ProFootballCoachUI`, so
the new `Resources/Fonts/` directory needs no manifest change.

- [ ] **Step 5: Run the test to verify it passes**

Run: `swift run SimTests --design-contracts 2>&1 | grep -A3 "Forge Field fonts"`
Expected: PASS.

- [ ] **Step 6: Prepare the commit and ask before running it**

```bash
git add Sources/ProFootballCoachUI/Resources/Fonts App/project.yml Tests/SimTests/Suites/DesignContractTests.swift
git commit -m "feat: bundle the three Forge Field type families with their licences"
```

---

### Task 4: Map the eleven type steps onto Dynamic Type

**Files:**
- Create: `Sources/ProFootballCoachUI/ForgeFieldType.swift`
- Modify: `Tests/SimTests/Suites/AccessibilityReflowTests.swift`

**Interfaces:**
- Consumes: §6.2a from Task 2; the family names from Task 3.
- Produces: `ForgeFieldType.Step` (a `CaseIterable` enum with `points: CGFloat`, `family: ForgeFieldType.Family`, `tracking: CGFloat`, `lineHeight: CGFloat`) and `ForgeFieldType.font(_:)`. Task 5 does not depend on these; Phase 2 views do.

- [ ] **Step 1: Write the failing test**

Append to `Tests/SimTests/Suites/AccessibilityReflowTests.swift`, inside its run function:

```swift
    suite("Forge Field type floors (06.2a, 04 section 7)") {
        // The source states the scale in fixed pixels and ships no accessibility token file. That
        // is a gap in the source, not a decision against Dynamic Type: 04 section 7's contract is a
        // floor. Enumerated over every case by construction, so a step added later is covered the
        // day it is added rather than the day someone remembers it.
        test("every step's default equals the 04 section 6.2a value") {
            expectEqual(ForgeFieldType.Step.allCases.count, 11,
                        "04 section 6.2a states eleven steps; the enum must hold all of them")
            expectEqual(ForgeFieldType.Step.ceremony.points, 120)
            expectEqual(ForgeFieldType.Step.fixture.points, 62)
            expectEqual(ForgeFieldType.Step.title.points, 34)
            expectEqual(ForgeFieldType.Step.heading.points, 26)
            expectEqual(ForgeFieldType.Step.panel.points, 19)
            expectEqual(ForgeFieldType.Step.chrome.points, 14)
            expectEqual(ForgeFieldType.Step.row.points, 13.5)
            expectEqual(ForgeFieldType.Step.prose.points, 12.5)
            expectEqual(ForgeFieldType.Step.proseMin.points, 11.5)
            expectEqual(ForgeFieldType.Step.figure.points, 11)
            expectEqual(ForgeFieldType.Step.columnHead.points, 9)
        }

        test("no step sits below its stated floor") {
            for step in ForgeFieldType.Step.allCases {
                expect(step.points >= 9,
                       "\(step) is \(step.points) pt — 04 section 6.2a's absolute floor is 9")
                if step.family == .prose {
                    expect(step.points >= 11.5,
                           "\(step) is prose at \(step.points) pt — the prose floor is 11.5")
                }
                if step.family == .record {
                    expect(step.points >= 11,
                           "\(step) is mono at \(step.points) pt — below 11 it is data, not prose")
                }
            }
        }

        // `textStyle` is non-optional, so "every step scales" is a compile-time guarantee rather
        // than a test that could never fail. What a test CAN catch is a step inserted at the wrong
        // size: the enum is declared largest-first and the ladder must descend with it.
        test("the steps descend in declaration order") {
            let sizes = ForgeFieldType.Step.allCases.map(\.points)
            expectEqual(sizes, sizes.sorted(by: >),
                        "04 section 6.2a's steps are declared largest-first: \(sizes) is out of "
                            + "order, so a step has been inserted at the wrong size")
        }
    }
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `swift run SimTests --design-contracts 2>&1 | grep -A3 "Forge Field type floors"`
Expected: FAIL — `cannot find 'ForgeFieldType' in scope`.

- [ ] **Step 3: Write the minimal implementation**

Create `Sources/ProFootballCoachUI/ForgeFieldType.swift`:

```swift
import SwiftUI

/// The Forge Field type scale, `04` section 6.2a.
///
/// The source states eleven fixed pixel sizes and ships no accessibility token file. `04` section 7's
/// Dynamic Type and AX5 contract is a floor, not a preference, so each step carries the text style it
/// scales against as well as its default size. The default is the source's value at the standard
/// content size; AX5 grows from there and the composition drops rows rather than shrinking type,
/// which is the source's own rule pointed at the accessibility case.
public enum ForgeFieldType {
    /// Three families, each with one job and no overlap.
    public enum Family: Sendable {
        /// Saira Condensed. Club names, scorelines, numerals, headings, row labels, buttons.
        case display
        /// Figtree. Staff quotes, scout prose, press questions, explanatory copy.
        case prose
        /// JetBrains Mono. Anything compared down a column, plus clock, week, cost, ratio and rank.
        case record

        public var postScriptName: String {
            switch self {
            case .display: "Saira Condensed"
            case .prose: "Figtree"
            case .record: "JetBrains Mono"
            }
        }
    }

    public enum Step: String, CaseIterable, Sendable {
        case ceremony, fixture, title, heading, panel, chrome
        case row, prose, proseMin, figure, columnHead

        /// The `04` section 6.2a value at the standard content size.
        public var points: CGFloat {
            switch self {
            case .ceremony: 120
            case .fixture: 62
            case .title: 34
            case .heading: 26
            case .panel: 19
            case .chrome: 14
            case .row: 13.5
            case .prose: 12.5
            case .proseMin: 11.5
            case .figure: 11
            case .columnHead: 9
            }
        }

        public var family: Family {
            switch self {
            case .ceremony, .fixture, .title, .heading, .panel, .chrome, .row, .columnHead: .display
            case .prose, .proseMin: .prose
            case .figure: .record
            }
        }

        /// What the step scales against. Non-optional on purpose: a pinned pixel size cannot
        /// answer AX5, and making it non-optional is what stops a future step shipping without one.
        public var textStyle: Font.TextStyle {
            switch self {
            case .ceremony, .fixture: .largeTitle
            case .title: .title
            case .heading: .title2
            case .panel: .headline
            case .chrome: .subheadline
            case .row: .body
            case .prose, .proseMin: .callout
            case .figure: .footnote
            case .columnHead: .caption2
            }
        }

        /// `04` section 6.2a line heights, as a multiple of the size.
        public var lineHeight: CGFloat {
            switch self {
            case .ceremony, .fixture: 0.82
            case .title, .heading: 1.04
            case .prose, .proseMin: 1.5
            case .row, .panel, .chrome, .figure, .columnHead: 1.4
            }
        }

        /// `04` section 6.2a tracking, in em.
        public var tracking: CGFloat {
            switch self {
            case .ceremony: 0.34
            case .fixture, .title, .heading: -0.02
            case .chrome, .panel: 0.14
            case .columnHead: 0.19
            case .row, .prose, .proseMin, .figure: 0
            }
        }
    }

    /// The scaling font for a step. `relativeTo` is what makes AX5 grow it.
    public static func font(_ step: Step) -> Font {
        .custom(step.family.postScriptName, size: step.points, relativeTo: step.textStyle)
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `swift run SimTests --design-contracts 2>&1 | grep -A6 "Forge Field type floors"`
Expected: PASS on all three tests.

- [ ] **Step 5: Verify the module still builds**

Run: `swift build`
Expected: `Build complete.` with no warnings introduced by the new file.

- [ ] **Step 6: Prepare the commit and ask before running it**

```bash
git add Sources/ProFootballCoachUI/ForgeFieldType.swift Tests/SimTests/Suites/AccessibilityReflowTests.swift
git commit -m "feat: map the Forge Field type scale onto Dynamic Type"
```

---

### Task 5: Land the Forge Field token layer beside the existing one

**Files:**
- Create: `Sources/ProFootballCoachUI/ForgeFieldTokens.swift`
- Modify: `Tests/SimTests/Suites/DesignContractTests.swift:272-295` (widen the two scans)

**Interfaces:**
- Consumes: §6.1e, §6.3a and §6.7a from Task 2.
- Produces: `ForgeFieldTokens.Club` (`CaseIterable`, with `.calumet/.maritime/.zeeland/.binghamton`), `ForgeFieldTokens.ClubPalette` (fields `ground0…ground3`, `ink1…ink4`, `hairline`, `emberLift`, `ember`, `emberPress`, `emberInk`, `club`, `clubDeep`), `ForgeFieldTokens.Fixed`, `ForgeFieldTokens.Space`, `ForgeFieldTokens.Motion`, `ForgeFieldTokens.Register`. `CoachWorldTokens` is untouched and every existing view keeps compiling.

- [ ] **Step 1: Widen the token scans before adding a file they would not see**

The two scans in the "Design token sync" suite filter on `$0.path.hasSuffix("DesignTokens.swift")`.
A new token file would escape both — the coverage boundary becoming the quality boundary, which
`CLAUDE.md` names as a defect. Replace that filter in **both** tests with an enumeration by construction:

```swift
                .filter { $0.path.hasSuffix("Tokens.swift") }
```

and change both `expect(!tokenFiles.isEmpty, ...)` messages to read
`"no *Tokens.swift found under Sources/ProFootballCoachUI"`.

- [ ] **Step 2: Run the widened scans against the tree as it stands**

Run: `swift run SimTests --design-contracts 2>&1 | grep -A3 "Design token sync"`
Expected: PASS. This proves the widening did not break on existing files before anything new lands.

- [ ] **Step 3: Write the failing test**

Append to `Tests/SimTests/Suites/DesignContractTests.swift`, inside `runDesignContractTests()`:

```swift
    suite("Forge Field tokens (06.1e, 06.3a, 06.7a)") {
        test("all four clubs derive a full palette") {
            expectEqual(ForgeFieldTokens.Club.allCases.count, 4)
            for club in ForgeFieldTokens.Club.allCases {
                let p = club.palette
                expect(p.ground0 != p.ground1, "\(club) ground 0 and 1 must differ")
                expect(p.ink1 != p.ink4, "\(club) ink 1 and 4 must differ")
            }
        }

        test("the single radius is 3 and the device frame is the only exception") {
            expectEqual(ForgeFieldTokens.Space.radius, 3)
            expectEqual(ForgeFieldTokens.Space.radiusDevice, 14)
        }

        test("the ladder holds seven steps and nothing off-ladder") {
            expectEqual(ForgeFieldTokens.Space.ladder, [4, 8, 12, 16, 24, 32, 44])
        }

        test("the four transitions carry 04 section 6.7a's durations") {
            expectEqual(ForgeFieldTokens.Motion.scrim, 0.160)
            expectEqual(ForgeFieldTokens.Motion.seam, 0.180)
            expectEqual(ForgeFieldTokens.Motion.plate, 0.240)
            expectEqual(ForgeFieldTokens.Motion.flood, 0.320)
            expectEqual(ForgeFieldTokens.Motion.ceremony, 1.200)
            expectEqual(ForgeFieldTokens.Motion.reduced, 0.090)
        }

        test("the two elevation levels keep their stated alphas") {
            expectEqual(ForgeFieldTokens.Edge.panel, 0.12)
            expectEqual(ForgeFieldTokens.Edge.raised, 0.22)
            expectEqual(ForgeFieldTokens.Edge.seamHard, 0.30)
            expectEqual(ForgeFieldTokens.Material.glass, 0.60)
            expectEqual(ForgeFieldTokens.Material.glassBlur, 14)
        }

        test("rival is an alias of the cold signal, not a second literal") {
            expectEqual(ForgeFieldTokens.Fixed.rival, ForgeFieldTokens.Fixed.signalCold)
        }
    }
```

- [ ] **Step 4: Run it to make sure it fails**

Run: `swift run SimTests --design-contracts 2>&1 | grep -A6 "Forge Field tokens"`
Expected: FAIL — `cannot find 'ForgeFieldTokens' in scope`.

- [ ] **Step 5: Write the implementation**

Create `Sources/ProFootballCoachUI/ForgeFieldTokens.swift`. Transcribe every hex from `04` §6.1e —
a value not in canon fails the colour-sync scan, which is the point.

```swift
import SwiftUI

/// The Forge Field token layer, `04` sections 6.1e, 6.3a and 6.7a.
///
/// This lands beside `CoachWorldTokens` rather than replacing it. Fifty-seven files read the older
/// layer; migrating them is Phase 2, and a token swap that breaks the build is not a migration.
public enum ForgeFieldTokens {
    /// Ground and ink are DERIVED from the club hue, never picked. One variable re-derives the four
    /// grounds, the four inks, the hairline, the ember and the mark. Saturation carries the
    /// identity; lightness is pinned, so the measured contrast column holds for every club.
    public struct ClubPalette: Sendable, Equatable {
        public let ground0, ground1, ground2, ground3: CoachWorldTokens.ColorValue
        public let ink1, ink2, ink3, ink4: CoachWorldTokens.ColorValue
        public let hairline: CoachWorldTokens.ColorValue
        public let emberLift, ember, emberPress, emberInk: CoachWorldTokens.ColorValue
        public let club, clubDeep: CoachWorldTokens.ColorValue
    }

    public enum Club: String, CaseIterable, Sendable {
        case calumet, maritime, zeeland, binghamton

        public var palette: ClubPalette {
            switch self {
            case .calumet:
                ClubPalette(
                    ground0: .init(hex: 0x0D0804), ground1: .init(hex: 0x140C05),
                    ground2: .init(hex: 0x1C1109), ground3: .init(hex: 0x24170D),
                    ink1: .init(hex: 0xF9F5F2), ink2: .init(hex: 0xEBE0D8),
                    ink3: .init(hex: 0xC1AE9F), ink4: .init(hex: 0x938376),
                    hairline: .init(hex: 0xD4B7A0),
                    emberLift: .init(hex: 0xFFA36B), ember: .init(hex: 0xFF7A2F),
                    emberPress: .init(hex: 0xD95A17), emberInk: .init(hex: 0x140A04),
                    club: .init(hex: 0x7A1F2B), clubDeep: .init(hex: 0x2E1015))
            case .maritime:
                ClubPalette(
                    ground0: .init(hex: 0x040D07), ground1: .init(hex: 0x05140A),
                    ground2: .init(hex: 0x091C10), ground3: .init(hex: 0x0D2415),
                    ink1: .init(hex: 0xF2F9F4), ink2: .init(hex: 0xD8EBDE),
                    ink3: .init(hex: 0x9FC1AA), ink4: .init(hex: 0x769380),
                    hairline: .init(hex: 0xA0D4B1),
                    emberLift: .init(hex: 0xFFC873), ember: .init(hex: 0xFFB13B),
                    emberPress: .init(hex: 0xDE8D0E), emberInk: .init(hex: 0x1C1204),
                    club: .init(hex: 0x1E5426), clubDeep: .init(hex: 0x0B2413))
            case .zeeland:
                ClubPalette(
                    ground0: .init(hex: 0x040B0D), ground1: .init(hex: 0x051114),
                    ground2: .init(hex: 0x09181C), ground3: .init(hex: 0x0D2024),
                    ink1: .init(hex: 0xF2F7F9), ink2: .init(hex: 0xD8E7EB),
                    ink3: .init(hex: 0x9FBAC1), ink4: .init(hex: 0x768D93),
                    hairline: .init(hex: 0xA0CAD4),
                    emberLift: .init(hex: 0xFFA9CB), ember: .init(hex: 0xFF7FB0),
                    emberPress: .init(hex: 0xDA5A8C), emberInk: .init(hex: 0x200812),
                    club: .init(hex: 0x0E4A50), clubDeep: .init(hex: 0x06242A))
            case .binghamton:
                ClubPalette(
                    ground0: .init(hex: 0x0B040D), ground1: .init(hex: 0x110514),
                    ground2: .init(hex: 0x18091C), ground3: .init(hex: 0x200D24),
                    ink1: .init(hex: 0xF7F2F9), ink2: .init(hex: 0xE7D8EB),
                    ink3: .init(hex: 0xBA9FC1), ink4: .init(hex: 0x8D7693),
                    hairline: .init(hex: 0xCAA0D4),
                    emberLift: .init(hex: 0xEDBAFF), ember: .init(hex: 0xDE8FFF),
                    emberPress: .init(hex: 0xB961E3), emberInk: .init(hex: 0x1D0826),
                    club: .init(hex: 0x571F70), clubDeep: .init(hex: 0x260E33))
            }
        }
    }

    /// Fixed for every club.
    public enum Fixed {
        /// Earned standing only: records, trophies, the lit chrome of match day.
        public static let gold = CoachWorldTokens.ColorValue(hex: 0xE8C36A)
        public static let signalAlarm = CoachWorldTokens.ColorValue(hex: 0xE9524A)
        public static let signalCaution = CoachWorldTokens.ColorValue(hex: 0xE7C13C)
        public static let signalGood = CoachWorldTokens.ColorValue(hex: 0x46C083)
        public static let signalCold = CoachWorldTokens.ColorValue(hex: 0xA8C4E0)
        /// A rival is always cold slate, never their own club colour. Declared as an alias rather
        /// than repeated, per 04 section 6.1a(ii): diverging the pair later must be a deliberate edit.
        public static let rival = signalCold
        public static let failureGround = CoachWorldTokens.ColorValue(hex: 0x241110)
        public static let leather = CoachWorldTokens.ColorValue(hex: 0x7A3E1C)
    }

    /// `04` section 6.3a. One ladder, one radius, one grid. Nothing off-ladder.
    public enum Space {
        public static let ladder: [CGFloat] = [4, 8, 12, 16, 24, 32, 44]
        /// Every panel, button, plate, chip and mark. There is no second radius.
        public static let radius: CGFloat = 3
        /// The outer device frame, and nothing else.
        public static let radiusDevice: CGFloat = 14
        public static let gridColumns = 12
        public static let gutter: CGFloat = 9
        public static let margin: CGFloat = 10
        /// Legal only when the whole row is inert.
        public static let rowDense: CGFloat = 32
        /// Anything tappable, on its short edge.
        public static let rowTouch: CGFloat = 44
        public static let chromeHeight: CGFloat = 30
        public static let panelHead: CGFloat = 19
        public static let overlayMax: CGFloat = 420
        public static let viewport = CGSize(width: 852, height: 393)
    }

    /// `04` section 6.3a. Two levels. Panels sit flat with an inset hairline and cast nothing;
    /// only a flooded field and an ember control cast a shadow. Overlays get one scrim, never a
    /// stack. Alphas are stated here rather than at the call site so the .12 / .22 / .30 / .34
    /// distinctions cannot drift.
    public enum Edge {
        public static let panel = 0.12
        public static let raised = 0.22
        public static let seamHair = 0.12
        public static let seamHard = 0.30
        public static let gold = 0.34
        public static let goldStrong = 0.40
        public static let ember = 0.40
        public static let alarm = 0.44
        public static let hairlineWidth: CGFloat = 1
    }

    /// `04` section 6.3a. Glass is used in exactly one place: plates that sit on top of the live
    /// field. A panel on a Desk surface is opaque.
    public enum Material {
        public static let scrim = 0.78
        public static let glass = 0.60
        public static let glassBlur: CGFloat = 14
        public static let glassSaturation = 1.06
        /// Fixed furniture on every surface: a 1-in-3 px overlay blend at 50%.
        public static let scanlineOpacity = 0.02
        public static let scanlinePeriod: CGFloat = 3
    }

    /// `04` section 6.7a. Four transitions, one duration each, and nothing else moves.
    public enum Motion {
        public static let scrim: Double = 0.160
        public static let seam: Double = 0.180
        public static let plate: Double = 0.240
        public static let flood: Double = 0.320
        /// Once a season at most.
        public static let ceremony: Double = 1.200
        /// Reduce-motion collapses all four to this crossfade; the flood wipe becomes a cut.
        public static let reduced: Double = 0.090
        public static let travelSeam: CGFloat = 12
        public static let travelOverlay: CGFloat = 8
    }

    /// Register budgets. Every number is a review failure, not a guideline.
    public enum Register {
        public static let deskStageMax = 0.25
        public static let deskPoints = 80
        public static let broadcastStage = 0.55...0.65
        public static let broadcastPointsAbove = 14
        public static let dossierStage = 0.30...0.40
        public static let ceremonyStageMin = 0.85
        public static let ceremonyPoints = 8
        public static let goldMaxBroadcast = 3
        public static let goldMaxDossier = 2
        public static let goldMaxCeremony = 5
        public static let emberPerSurface = 1
        public static let ghostOpacity = 0.13
        public static let ghostOpacityRange = 0.10...0.20
        public static let ghostSize: ClosedRange<CGFloat> = 230...330
        public static let ghostSaturate = 0.75
    }
}
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `swift run SimTests --design-contracts`
Expected: PASS on the new suite **and** on "Design token sync" — the widened colour-sync scan now
reads `ForgeFieldTokens.swift` too, so any hex missing from §6.1e fails here. If it does, the fix is
to write the value into §6.1e, never to delete it from the scan.

- [ ] **Step 7: Run the full suite**

Run: `swift run SimTests`
Expected: PASS. Nothing that reads `CoachWorldTokens` has changed, so the Press Box geometry, chrome
and Floodlit suites must all still be green.

- [ ] **Step 8: Prepare the commit and ask before running it**

```bash
git add Sources/ProFootballCoachUI/ForgeFieldTokens.swift Tests/SimTests/Suites/DesignContractTests.swift
git commit -m "feat: add the Forge Field token layer beside CoachWorldTokens"
```

---

### Task 6: Re-target the change ledger

**Files:**
- Modify: `docs/FRONTEND-CHANGE-LEDGER.md:1-20` (header) and the Part A4 / Part B / Part C row headings
- Modify: `docs/STATUS.md` (prepend a dated entry)

**Interfaces:**
- Consumes: Tasks 1–5. Cites the commits they produce.
- Produces: Part D, the row list Phase 2's plan is written from. No Swift symbols.

- [ ] **Step 1: Rewrite the ledger header**

Replace the `**Standard:**` line and the `**What has landed, and what has not.**` paragraph with:

```markdown
**Standard:** Forge Field, Claude Design project `8c511c92-3337-4cfb-850c-140a659f3034`, owner-approved
2026-08-29, replacing Press Box. `docs/superpowers/specs/2026-08-29-forge-field-standard.md` is the
self-sufficient transcription; `docs/DOC-MANIFEST.md` section 4b records the supersession, and
`04` sections 6.1e / 6.2a / 6.3a / 6.6a / 6.7a are the canon a builder implements against.

**What has landed, and what has not.** Parts A1, A2 and A3 are **built and verified** against the
Press Box standard (`3bd44a58`) and **stay in the tree** — owner decision 2026-08-29. They are adapted
to Forge Field values in Part D rather than reverted; no verified code is thrown away to make a
migration look tidy. **A4 and the whole of Parts B and C are closed as obsolete**: they were never
written, and they specify plate widths and chrome geometry that Forge Field replaces outright.
Part D is the live list.
```

- [ ] **Step 2: Close the obsolete parts**

Under each of the A4, Part B and Part C headings, insert a single line and leave the existing content
below it untouched as history:

```markdown
> **CLOSED 2026-08-29 — obsolete.** Written against Press Box geometry that Forge Field replaces.
> Nothing below this line is to be implemented. Superseded by Part D.
```

- [ ] **Step 3: Open Part D**

Append, using the file's existing status legend (**CHANGE** / and whatever the legend defines):

```markdown
---

## Part D — Forge Field

Opened 2026-08-29. Phase 1 (canon and token layer) is
`docs/plans/2026-08-29-forge-field-standard-phase-1.md` and is complete when Task 5 is green.

| # | Status | What | Where |
|---|---|---|---|
| D1 | **DONE** | Authority recorded; Press Box marked superseded | `docs/DOC-MANIFEST.md` section 4b |
| D2 | **DONE** | Palette, type, space, symbols and motion written into canon | `04` sections 6.1e, 6.2a, 6.3a, 6.6a, 6.7a |
| D3 | **DONE** | Three families bundled with their OFL licences | `Sources/ProFootballCoachUI/Resources/Fonts/`, `App/project.yml` |
| D4 | **DONE** | Eleven type steps mapped onto Dynamic Type | `Sources/ProFootballCoachUI/ForgeFieldType.swift` |
| D5 | **DONE** | Token layer landed beside `CoachWorldTokens` | `Sources/ProFootballCoachUI/ForgeFieldTokens.swift` |
| D6 | **TODO** | Migrate the 57 files reading `CoachWorldTokens` onto `ForgeFieldTokens`, surface by surface | Phase 2 — needs its own plan |
| D7 | **TODO** | Retire `CoachWorldCutCorner` and its 4/22/4/22 presets once D6 lands; the single 3 px radius replaces them | `Sources/ProFootballCoachUI/`, `DesignContractTests` "Floodlit geometry (06.1a)" |
| D8 | **TODO** | Re-target the "Press Box shared chrome" suite at the 30 px Forge Field chrome bar | `Tests/SimTests/Suites/DesignContractTests.swift:862` |
| D9 | **TODO** | Re-measure and restate every contrast ratio for all four clubs, both ink-on-ground directions | `04` section 6.1e |
| D10 | **TODO** | Retire the symbol register for Forge Field surfaces per `04` section 6.6a; re-target or remove the "Symbol register" and "Retired symbols (06.1c)" suites | `Tests/SimTests/Suites/DesignContractTests.swift:559,1000` |
| D11 | **TODO** | Backgrounds: floods at 102 degrees, lamp washes, the oversized ghost mark and the scanline, drawn with gradients and no imagery | spec section 2.7; Phase 2 |
| D12 | **TODO** | The seam law — one per surface, staged above/left and studied below/right — and the 30 px chrome bar's fixed contents and order | spec sections 2.3, 3; Phase 2 |
| D13 | **TODO** | House voice: cost sub-labels on every ember, `unseen` as a legal value, qualified numbers, failures naming what survived | spec section 2.8; needs a `04` section 8 amendment before implementation |
| D14 | **TODO** | Delete `CoachWorldTokens` once nothing reads it | `Sources/ProFootballCoachUI/DesignTokens.swift` |
```

- [ ] **Step 4: Record the honest state in STATUS.md**

Prepend to `docs/STATUS.md`, after the `**Read this first…**` line:

```markdown
> **2026-08-29 — Forge Field is the design standard, and Phase 1 is canon plus tokens only.** The
> owner replaced Press Box with Forge Field (Claude Design project `8c511c92-…`). What is verified:
> the manifest and `04` amendments, the three bundled families with their licences, the Dynamic Type
> mapping, and the `ForgeFieldTokens` layer — all with the suite green under a real Swift 6.3.3
> toolchain. **What is not done: no surface has been migrated.** Fifty-seven files still read
> `CoachWorldTokens` and still draw Press Box geometry, so the running app does not yet look like
> Forge Field. `docs/FRONTEND-CHANGE-LEDGER.md` Part D rows D6–D10 are that gap.
```

- [ ] **Step 5: Run the full suite**

Run: `swift run SimTests`
Expected: PASS, including the manifest directory-classification test.

- [ ] **Step 6: Prepare the commit and ask before running it**

```bash
git add docs/FRONTEND-CHANGE-LEDGER.md docs/STATUS.md
git commit -m "docs: re-target the change ledger at Forge Field and open Part D"
```

---

## Phase exit

Before declaring Phase 1 done, per `CLAUDE.md`:

- [ ] `swift build` green.
- [ ] `swift run SimTests` green.
- [ ] Run `adversarial-reviewer` (or `/code-review`) on the phase diff. Fix confirmed findings first.
      An adversarial review is not a build and must never be reported as one.
- [ ] Run `superpowers:verification-before-completion` and assert the machine gates.
- [ ] Ask the owner before committing, pushing or merging anything.

**Out of scope, deliberately.** No surface view is touched. `CoachWorldTokens`, `CoachWorldCutCorner`
and the Press Box chrome all still ship and still pass their own contracts. Phase 2 migrates them.
