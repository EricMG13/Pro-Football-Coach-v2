import Foundation
import ProFootballCoachUI

/// G-12, the last M8 entry-gate instrument. `04` §7.1 states exactly what it does and does not
/// assert; this file implements that and nothing wider.
///
/// The point of it is the enumeration. A spot-check over the five views that happen to exist today
/// would pass forever and cover nothing new, which is the defect `CLAUDE.md` names: a test's
/// coverage boundary becoming the quality boundary. Families come from `CoachWorldScreenID`, so the
/// sixth view is inside this contract the day its file appears.

/// The view file a family lands as. `coachingHQ` → `CoachingHQView.swift`.
///
/// Derived from the case name rather than mapped by hand, for the same reason the enumeration is:
/// a hand map is a second list to forget to update.
private func viewFileName(for screen: CoachWorldScreenID) -> String {
    let name = String(describing: screen)
    return name.prefix(1).uppercased() + name.dropFirst() + "View.swift"
}

struct FamilyView {
    let screen: CoachWorldScreenID
    let path: String
    let text: String
    /// The union of this family's own source and every file its rendering chain wholly delegates
    /// into, resolved to a fixpoint by `renderingClosures()`.
    ///
    /// S-1, 2026-08-19 adversarial review: a wrapper's own generic chrome modifiers can happen to
    /// contain an accessibility marker while the substantive composition -- and any AX5 or
    /// VoiceOver defect in it -- lives entirely in a delegate the wrapper's own text says nothing
    /// about. `LegacyHistoryView` renders four families (`recordBook`, `rivalries`, `careerLine`,
    /// `coachingTree`) and held zero of either marker while each of its four ~28-line wrappers
    /// wrote both, so scanning `text` alone was scanning the wrong file for all four.
    let renderedText: String
}

/// The view types that draw the Floodlit world, directly or by wholly delegating to one that does.
///
/// Roughly a quarter of the registry is a thin wrapper — `NewCareerCoachIdentityView` passes
/// straight to `NewCareerSetupView`, `JobBoardView`/`OfferView`/`AppointmentView` all pass a
/// `focus:` to `CareerHubView`. A wrapper has no ground of its own to paint, so it is converted
/// exactly when the view it delegates to is. Resolved to a fixpoint rather than one hop, because
/// wrappers chain.
private func floodlitConvertedTypes() -> Set<String> {
    let sources = swiftFilesImportingUIFramework()
    func typeName(of path: String) -> String {
        String(path.split(separator: "/").last ?? "").replacingOccurrences(of: ".swift", with: "")
    }

    var converted = Set(
        sources.filter { $0.text.contains("CoachWorldFloodlitStage") }.map { typeName(of: $0.path) }
    )
    var changed = true
    while changed {
        changed = false
        for file in sources {
            let name = typeName(of: file.path)
            guard !converted.contains(name) else { continue }
            // A wrapper delegates by naming the converted type's initialiser. Naming it is not
            // sufficient: `SigningDayView` delegates on one branch and draws its own state on the
            // other, so the mention alone would have called it converted while that branch still
            // rendered on bare ground. A file that draws an unconverted composition of its own is
            // not a wrapper, whatever else it delegates to.
            let drawsItsOwnUnconvertedState = file.text.contains("ContentUnavailableView(")
            if !drawsItsOwnUnconvertedState,
               converted.contains(where: { file.text.contains($0 + "(") }) {
                converted.insert(name)
                changed = true
            }
        }
    }
    return converted
}

private func isFloodlitConverted(_ family: FamilyView) -> Bool {
    let name = String(family.path.split(separator: "/").last ?? "")
        .replacingOccurrences(of: ".swift", with: "")
    return floodlitConvertedTypes().contains(name)
}

/// For every UI type, the full text of every file its own body renders through: itself, plus
/// everything it wholly delegates to, resolved to a fixpoint because wrappers chain -- the same
/// reason `floodlitConvertedTypes()` above resolves to a fixpoint rather than one hop, and the same
/// delegation rule: a file delegates to `Target` by naming `Target`'s initialiser, unless it also
/// draws a composition of its own (`ContentUnavailableView(` is the tell both functions use, for
/// the same reason -- `SigningDayView` delegates on one branch and draws its own state on the
/// other, so a mention alone is not delegation).
private func renderingClosures() -> [String: String] {
    let sources = swiftFilesImportingUIFramework()
    func typeName(of path: String) -> String {
        String(path.split(separator: "/").last ?? "").replacingOccurrences(of: ".swift", with: "")
    }

    var closureFiles: [String: Set<String>] = Dictionary(
        uniqueKeysWithValues: sources.map { (typeName(of: $0.path), Set([$0.path])) }
    )
    var changed = true
    while changed {
        changed = false
        for file in sources {
            let name = typeName(of: file.path)
            let drawsItsOwnUnconvertedState = file.text.contains("ContentUnavailableView(")
            guard !drawsItsOwnUnconvertedState else { continue }
            for other in sources where other.path != file.path {
                let otherName = typeName(of: other.path)
                guard file.text.contains(otherName + "(") else { continue }
                let addition = closureFiles[otherName] ?? []
                let before = closureFiles[name] ?? []
                let after = before.union(addition)
                if after.count != before.count {
                    closureFiles[name] = after
                    changed = true
                }
            }
        }
    }

    let textByPath = Dictionary(uniqueKeysWithValues: sources.map { ($0.path, $0.text) })
    return closureFiles.mapValues { paths in
        paths.sorted().compactMap { textByPath[$0] }.joined(separator: "\n")
    }
}

/// The three-way split every screen family falls into, by construction:
/// - `landed` — a canonical, player-visible task with a view file. This is what the AX5 and
///   VoiceOver clauses below check.
/// - `pending` — no view file resolves by the naming convention yet.
/// - `aliased` — a view file exists, but the screen is a retired route
///   (`CoachWorldScreenID.routeDisposition == .alias`), not a visible task
///   (`isCanonicalTask == false`). S-6, 2026-08-19 review: fifteen families are aliases whose
///   root-switch branches cannot execute in production (`CoachWorldAppRootView` switches on
///   `canonicalDestination`, which an alias never equals), so certifying their dead file as
///   "landed" -- as this function did before -- certified accessibility for a file nobody renders.
///   `ContractTests.swift`'s "the 62 legacy route numbers migrate through one canonical task table"
///   already asserts the alias table and the 47-visible-task count by construction; this partition
///   now agrees with it instead of silently recounting all 62.
///
/// Reused by `ReduceMotionContractTests` — the same partition, not a second one, so the two
/// contracts cannot silently cover different sets of families.
func landedFamilies() -> (landed: [FamilyView], pending: [CoachWorldScreenID], aliased: [FamilyView]) {
    let sources = swiftFilesImportingUIFramework()
    let renderedTextByType = renderingClosures()
    func typeName(of path: String) -> String {
        String(path.split(separator: "/").last ?? "").replacingOccurrences(of: ".swift", with: "")
    }
    var landed: [FamilyView] = []
    var pending: [CoachWorldScreenID] = []
    var aliased: [FamilyView] = []
    for screen in CoachWorldScreenID.allCases {
        let fileName = viewFileName(for: screen)
        guard let file = sources.first(where: { $0.path.hasSuffix("/" + fileName) }) else {
            pending.append(screen)
            continue
        }
        let type = typeName(of: file.path)
        let family = FamilyView(
            screen: screen,
            path: file.path,
            text: file.text,
            renderedText: renderedTextByType[type] ?? file.text
        )
        if screen.isCanonicalTask {
            landed.append(family)
        } else {
            aliased.append(family)
        }
    }
    return (landed, pending, aliased)
}

func runAccessibilityReflowTests() {
    suite("AX5 reflow contract") {
        test("every screen family is landed, pending, or aliased, and the split is total") {
            let (landed, pending, aliased) = landedFamilies()
            expectEqual(
                landed.count + pending.count + aliased.count,
                CoachWorldScreenID.allCases.count,
                "the partition lost a family, so some family is checked by nothing"
            )
            expectEqual(CoachWorldScreenID.allCases.count, 62)
            expect(!landed.isEmpty,
                   "no family view was found — the scan would pass vacuously")
            // Reported rather than asserted at a number: production views land family by family
            // through P11–P15, and a count here would have to be edited by every one of them.
            print("AX5 contract: \(landed.count) landed, \(pending.count) pending, "
                + "\(aliased.count) aliased")
        }

        test("every landed family declares an accessibility-size composition") {
            // `04` §7.1 clause 1. A screen with no AX5 branch has not had AX5 considered.
            // Checked against `renderedText`, not `text` — see FamilyView's doc comment (S-1).
            for family in landedFamilies().landed {
                expect(family.renderedText.contains("dynamicTypeSize.isAccessibilitySize"),
                       "\(family.path) (\(family.screen.canonicalName)) has no accessibility-size "
                           + "composition, so AX5 reflow was never decided for it (04 section 7.1)")
            }
        }

        test("Depth Chart's position-group selector is reachable in the accessible "
            + "composition, not only the standard layout") {
            // 3.1, 2026-08-20 remediation: `groupSelector` replaced `openGroup`'s dependence on
            // `fieldDiagram`'s token taps, which are `.accessibilityHidden(true)` at every type
            // size and aren't constructed at all once `dynamicTypeSize.isAccessibilitySize` — so
            // before this fix, an AX5 or VoiceOver coach could reach only the first group of
            // whichever unit the pills last selected, never the other fourteen. A whole-file scan
            // would pass whether `groupSelector` sits inside the accessible branch or only the
            // standard one, so this isolates that branch's own text and checks it specifically —
            // the same tautology risk the 2026-08-19 review named for other gates.
            guard let depthChart = landedFamilies().landed.first(where: { $0.screen == .depthChart })
            else {
                expect(false, "Depth Chart did not resolve to a landed family")
                return
            }
            guard let start = depthChart.renderedText.range(
                of: "if dynamicTypeSize.isAccessibilitySize {"
            ), let end = depthChart.renderedText.range(
                of: "} else {",
                range: start.upperBound..<depthChart.renderedText.endIndex
            ) else {
                expect(false, "could not locate the AX5/default composition split to scan it")
                return
            }
            let accessibleBranch = String(depthChart.renderedText[start.upperBound..<end.lowerBound])
            expect(accessibleBranch.contains("groupSelector"),
                   "the accessible composition no longer calls groupSelector, so AX5 and "
                       + "VoiceOver coaches are back to reaching only the first position group "
                       + "of each unit (04 section 7.1)")
        }

        test("every landed family declares deterministic VoiceOver order") {
            // `04` §7.1 clause 2: world context, dominant object, evidence, actions, navigation.
            // Checked against `renderedText`, not `text` — see FamilyView's doc comment (S-1).
            for family in landedFamilies().landed {
                expect(family.renderedText.contains("accessibilitySortPriority"),
                       "\(family.path) (\(family.screen.canonicalName)) leaves VoiceOver order to "
                           + "layout accident (04 section 7)")
            }
        }

        test("a family that wholly delegates is checked through the file that renders it") {
            // The regression this guards: RecordBookView, RivalriesView, CareerLineView and
            // CoachingTreeView are each a ~28-line wrapper around LegacyHistoryView, which is
            // where all four families' actual compositions -- and any AX5/VoiceOver defect in
            // them -- live. Before this fix, `family.text` was the wrapper alone, so
            // LegacyHistoryView was never scanned by the two clauses above.
            //
            // The marker checked is "No team records recorded." — LegacyHistoryView's own empty
            // state for the records section, not the wrapper's mere mention of the delegate's
            // name. RecordBookView.swift's own text already contains the substring
            // "LegacyHistoryView" (it names the initialiser it calls), so asserting on that alone
            // would pass whether or not the union actually happened; this marker only appears
            // inside LegacyHistoryView's own body.
            guard let recordBook = landedFamilies().landed.first(where: { $0.screen == .recordBook })
            else {
                expect(false, "Record Book did not resolve to a landed family")
                return
            }
            expect(!recordBook.text.contains("No team records recorded."),
                   "the wrapper's own text unexpectedly contains LegacyHistoryView's internals — "
                       + "this test's premise (the wrapper alone does not carry it) no longer holds")
            expect(recordBook.renderedText.contains("No team records recorded."),
                   "Record Book's rendering closure did not pull in LegacyHistoryView.swift, so a "
                       + "shared-host defect there would still go unseen")
        }

        test("the family-to-file convention resolves the views that exist") {
            // The guard against the enumeration silently finding nothing: if the naming convention
            // drifts, every family becomes "pending" and the two clauses above pass over an empty
            // set. These five are the production screens `05` records as built.
            let landed = Set(landedFamilies().landed.map(\.screen))
            for screen in [
                CoachWorldScreenID.coachingHQ,
                .matchDay,
                .roster,
                .playerProfile,
                .recruitingBoard,
            ] {
                expect(landed.contains(screen),
                       "\(screen.canonicalName) did not resolve to \(viewFileName(for: screen))")
            }
        }

        test("the convention keeps the draft room family landed") {
            let (_, pending, _) = landedFamilies()
            expect(!pending.contains(.draftRoom),
                   "Draft Room has a production wrapper and must not remain pending")
            expect(!pending.contains(.prospectProfile),
                   "Prospect Profile has a production dossier and must not remain pending")
            expect(!pending.contains(.shortlist),
                   "Shortlist has a production bounded list and must not remain pending")
            expect(!pending.contains(.contractNegotiation),
                   "Contract Negotiation has a production wrapper and must not remain pending")
            expectEqual(viewFileName(for: .draftRoom), "DraftRoomView.swift")
            expectEqual(viewFileName(for: .rankingsPlayoffPicture),
                        "RankingsPlayoffPictureView.swift")
        }

        test("the clauses would notice a view that declares neither") {
            // The self-test half: the predicates are run against a synthetic view rather than
            // against a copy of the rule, so a fix to one cannot leave the other asserting the old
            // rule.
            let bare = "import SwiftUI\nstruct BareView: View { var body: some View { Text(\"x\") } }"
            expect(!bare.contains("dynamicTypeSize.isAccessibilitySize"),
                   "a view with no accessibility branch was reported as having one")
            expect(!bare.contains("accessibilitySortPriority"),
                   "a view with no VoiceOver order was reported as having one")
        }
    }

    suite("Floodlit surface conversion") {
        // The cutover converts 62 families over several phases, so this enumerates by construction
        // and reports the split rather than asserting a count every later phase would have to edit
        // — the same shape as the AX5 contract above, for the same reason.
        //
        // What it *does* assert is the invariant that makes a conversion real. `CoachWorldFloodlitStage`
        // already paints the committed dark world: the page ground, the backdrop, and the fixed-seed
        // grain. A root that wraps itself in the stage and *also* keeps its own
        // `.background(palette.page.color.ignoresSafeArea())` paints flat ground straight over the
        // backdrop it just asked for — the screen compiles, looks nearly right, and silently has no
        // Floodlit world at all. That is the defect worth a test.
        // Conversion status is a question about a *file* — has it been reskinned onto
        // CoachWorldFloodlitStage — not about whether the screen is currently a canonical,
        // player-visible task. An aliased screen's file still exists and the codebase's own
        // phase-completion claims below name several of them, so this suite runs over
        // `landed + aliased` (everything with a file), not `landed` alone. The AX5/VoiceOver
        // suite above is scoped to `landed` on purpose, for the opposite reason: accessibility
        // is a question about what a player can reach, and an alias's own file is dead code no
        // player ever sees (S-6).
        test("every family is either converted to the Floodlit stage or pending, and the split is total") {
            let (landed, _, aliased) = landedFamilies()
            let renderable = landed + aliased
            let converted = renderable.filter(isFloodlitConverted)
            let pending = renderable.filter { !isFloodlitConverted($0) }
            expectEqual(converted.count + pending.count, renderable.count,
                        "the conversion partition lost a family, so some family is checked by nothing")
            print("Floodlit conversion: \(converted.count) converted, \(pending.count) pending")
        }

        test("no converted root paints its own ground under the stage backdrop") {
            let (landed, _, aliased) = landedFamilies()
            let converted = (landed + aliased).filter(isFloodlitConverted)
            for family in converted {
                expect(!family.text.contains("palette.page.color.ignoresSafeArea()"),
                       "\(family.path) (\(family.screen.canonicalName)) wraps itself in "
                           + "CoachWorldFloodlitStage and then paints palette.page over the "
                           + "backdrop the stage draws, so the Floodlit world never renders")
            }
        }

        test("every surface each landed cutover phase claims is converted") {
            // Each phase's own completion gate. The enumeration above stays general and reports a
            // count; this pins the specific claim each commit made, so a later phase cannot quietly
            // un-convert an earlier one. A phase adds its range here when it lands — a phase that
            // forgets asserts nothing, which is how Phases 4 to 6 originally slipped through.
            let (landed, _, aliased) = landedFamilies()
            let converted = Set((landed + aliased).filter(isFloodlitConverted).map(\.screen))
            let claimed: [(phase: String, screens: [CoachWorldScreenID])] = [
                ("3 (entry, registry 1-7)",
                 [.titleContinue, .newCareerCoachIdentity, .jobBoard, .offer, .appointment,
                  .settingsAccessibility, .worldSearch]),
                ("4 (command, registry 8-15)",
                 [.coachingHQ, .inbox, .opponentReportFilmRoom, .gamePlan, .practicePlan,
                  .teamHealth, .matchDay, .aftermath]),
                ("5 (personnel, registry 16-23)",
                 [.roster, .depthChart, .playerProfile, .developmentPlan, .staffRoom,
                  .staffMarketProfile, .schemeBook, .personnelPackages]),
                ("6 (college, registry 24-33, 61)",
                 [.recruitingBoard, .prospectProfile, .shortlist, .contactVisitPlanner,
                  .classOverview, .signingDay, .portalHub, .retentionDecisions, .portalMarket,
                  .collegeOffseason, .nilAllocation]),
                ("career hub family landed with phase 3",
                 [.careerHub, .jobSecurity, .stakeholders, .promotionDecision, .coachingCarousel]),
            ]
            for (phase, screens) in claimed {
                for screen in screens {
                    expect(converted.contains(screen),
                           "\(screen.canonicalName) is claimed converted by phase \(phase), but its "
                               + "view does not resolve to CoachWorldFloodlitStage")
                }
            }
        }

        test("the ground-paint scan would notice a double-painted root") {
            let planted = """
            CoachWorldFloodlitStage { content }
                .background(palette.page.color.ignoresSafeArea())
            """
            expect(planted.contains("CoachWorldFloodlitStage")
                       && planted.contains("palette.page.color.ignoresSafeArea()"),
                   "the predicate the real assertion uses must catch a planted double paint")
        }
    }

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
            expectEqual(ForgeFieldType.Step.proseMin.points, 12)
            expectEqual(ForgeFieldType.Step.figure.points, 11)
            expectEqual(ForgeFieldType.Step.columnHead.points, 10)
        }

        test("no step sits below its stated floor") {
            for step in ForgeFieldType.Step.allCases {
                expect(step.points >= 10,
                       "\(step) is \(step.points) pt — 04 section 6.2a's absolute floor is 10. "
                           + "The sheets say 9; section 6.2a(i) raised it, because 6.2's Caption "
                           + "role has been 10 to 11 pt since before Forge Field and had already "
                           + "passed the accessibility matrix at that floor.")
                if step.family == .prose {
                    expect(step.points >= 12,
                           "\(step) is prose at \(step.points) pt — the prose floor is 12, per "
                               + "04 section 6.2's 'working prose stays at 12 pt'")
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

        // The by-construction half for faces: `ForgeFieldFonts.registerAll` is what Task 3 built
        // to make the ten bundled binaries resolvable through CoreText, so the shipping set below
        // comes from asking it what it actually resolved -- never a hand-typed list of ten names,
        // which would be a second place to update and could drift from what is really bundled. A
        // step naming a face that is absent, misspelled, or never registered fails here.
        test("every step's face is a face that actually ships") {
            let shipped = ForgeFieldFonts.registerAll.resolvedPostScriptNames
            for step in ForgeFieldType.Step.allCases {
                expect(shipped.contains(step.faceName),
                       "\(step) names face \"\(step.faceName)\", which is not among the faces "
                           + "ForgeFieldFonts actually registered: \(shipped.sorted())")
            }
        }

        // 04 section 6.2a names five tracking values, not one per size step: "numeral -.02em,
        // lockup .11em, chrome .14em, colhead .19em, ceremony .34em." Round 1 review found the
        // code only ever produced four of them -- `.11` was unreachable -- because `Step.tracking`
        // held the values as literals instead of naming this enum. Asserted by construction over
        // `Tracking.allCases` so a sixth value added to one side without the other is caught here.
        test("the five named tracking values match 04 section 6.2a") {
            expectEqual(ForgeFieldType.Tracking.allCases.count, 5,
                        "04 section 6.2a names five tracking values; the enum must hold exactly them")
            expectEqual(ForgeFieldType.Tracking.numeral.em, -0.02, "numeral")
            expectEqual(ForgeFieldType.Tracking.lockup.em, 0.11, "lockup")
            expectEqual(ForgeFieldType.Tracking.chrome.em, 0.14, "chrome")
            expectEqual(ForgeFieldType.Tracking.columnHead.em, 0.19, "columnHead")
            expectEqual(ForgeFieldType.Tracking.ceremony.em, 0.34, "ceremony")
        }

        // Every step's tracking default and line height, all eleven of each -- until this test,
        // only `points` was checked, so a wrong tracking or line height (Task 3/4's own `.14`
        // mix-up on `chrome` being the example) would have shipped silently into Phase 2.
        //
        // Tracking: each default traces to a named `Tracking` case -- either directly from 04
        // section 6.2a's sentence, or from the `chrome`/`panel` dual-role ruling on `Step.tracking`
        // above. `row`, `prose`, `proseMin` and `figure` carry no tracking in canon at all, so
        // their default is the bare literal 0, not a sixth `Tracking` case.
        test("every step's tracking matches its 04 section 6.2a source") {
            expectEqual(ForgeFieldType.Step.ceremony.tracking, ForgeFieldType.Tracking.ceremony.em,
                        "ceremony")
            expectEqual(ForgeFieldType.Step.fixture.tracking, ForgeFieldType.Tracking.numeral.em,
                        "fixture")
            expectEqual(ForgeFieldType.Step.title.tracking, ForgeFieldType.Tracking.numeral.em,
                        "title")
            expectEqual(ForgeFieldType.Step.heading.tracking, ForgeFieldType.Tracking.numeral.em,
                        "heading")
            expectEqual(ForgeFieldType.Step.panel.tracking, ForgeFieldType.Tracking.chrome.em,
                        "panel")
            expectEqual(ForgeFieldType.Step.chrome.tracking, ForgeFieldType.Tracking.lockup.em,
                        "chrome — the club-lockup role, .04 section 6.2a's fs-chrome row lists it "
                            + "first; a button label passes Tracking.chrome.em explicitly")
            expectEqual(ForgeFieldType.Step.row.tracking, 0, "row")
            expectEqual(ForgeFieldType.Step.prose.tracking, 0, "prose")
            expectEqual(ForgeFieldType.Step.proseMin.tracking, 0, "proseMin")
            expectEqual(ForgeFieldType.Step.figure.tracking, 0, "figure")
            expectEqual(ForgeFieldType.Step.columnHead.tracking, ForgeFieldType.Tracking.columnHead.em,
                        "columnHead")
        }

        // Line height: 04 section 6.2a names exactly four values by name -- "numeral .82, title
        // 1.04, prose 1.5, row 1.4" -- covering ceremony/fixture (numeral), title/heading (title),
        // prose/proseMin (prose) and row itself. The other four steps (panel, chrome, figure,
        // columnHead) are not named individually anywhere in canon; each takes the "row" value,
        // read as canon's own description of row -- "the densest thing in the system" -- naming
        // the default register for compact UI text that is neither a display numeral, a title,
        // nor prose. That reading is this codebase's inference, marked here as such, not a fifth
        // canon-stated value.
        test("every step's line height matches its 04 section 6.2a source") {
            expectEqual(ForgeFieldType.Step.ceremony.lineHeight, 0.82, "ceremony — canon: numeral")
            expectEqual(ForgeFieldType.Step.fixture.lineHeight, 0.82, "fixture — canon: numeral")
            expectEqual(ForgeFieldType.Step.title.lineHeight, 1.04, "title — canon: title")
            expectEqual(ForgeFieldType.Step.heading.lineHeight, 1.04, "heading — canon: title")
            expectEqual(ForgeFieldType.Step.panel.lineHeight, 1.4, "panel — inferred: row's register")
            expectEqual(ForgeFieldType.Step.chrome.lineHeight, 1.4, "chrome — inferred: row's register")
            expectEqual(ForgeFieldType.Step.row.lineHeight, 1.4, "row — canon: row")
            expectEqual(ForgeFieldType.Step.prose.lineHeight, 1.5, "prose — canon: prose")
            expectEqual(ForgeFieldType.Step.proseMin.lineHeight, 1.5, "proseMin — canon: prose")
            expectEqual(ForgeFieldType.Step.figure.lineHeight, 1.4, "figure — inferred: row's register")
            expectEqual(ForgeFieldType.Step.columnHead.lineHeight, 1.4,
                        "columnHead — inferred: row's register")
        }
    }
}
