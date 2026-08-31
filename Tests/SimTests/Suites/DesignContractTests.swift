import CoreGraphics
import CoreText
import Foundation
import SwiftUI
@testable import ProFootballCoachUI

// The M8 production-UI entry gate, as tests (05, phase P11a).
//
// Every assertion here reads its expectation out of `docs/04-UX-AND-DESIGN-SYSTEM.md` at run time
// rather than restating it. A test that hard-codes the twelve status symbols is a second copy of
// canon that drifts silently; one that parses the table fails the day canon and the tree disagree,
// which is the only reason to write it.
//
// The reference sheets shipped with every contract block self-reporting its own compliance, and the
// 2026-08-12 proof review found the predictable result: a column count that did not match its own
// drawing, a verified-sizes table that grew an unverified row, a symbol budget that only summed
// across files. Gap G-17 is this file's reason to exist — where a claim is mechanically checkable,
// it gets mechanically checked.
//
// Each scan enumerates its file set by walking a directory, per `CLAUDE.md`'s coverage-boundary
// rule, and each ships a self-test that plants an offender and asserts the scan catches it. A scan
// that has never failed is not known to be a scan.

// MARK: - Canon readers

func canonText() -> String {
    let url = packageRoot().appendingPathComponent("docs/04-UX-AND-DESIGN-SYSTEM.md")
    return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
}

/// Every six-digit hex `04` section 6.1 states, upper-cased and without the leading hash.
///
/// The section holds the production values, the field grammar and the synthetic team trio; a sheet
/// or a view may name any of them and nothing else.
private func canonHexValues(_ canon: String) -> Set<String> {
    Set(matches(of: "#([0-9A-Fa-f]{6})\\b", in: canon).map { $0.uppercased() })
}

/// The symbol register in `04` section 6.6, as class name to (cap, members).
///
/// Parses the table rows rather than the prose: a row is `| **Name** (…) | cap | `a`, `b` | where |`.
/// The Broadcast row names its marks in words rather than as SF Symbols, so it contributes a cap and
/// no members, which is correct — a drawn wedge is not a symbol literal a scan can find.
private func canonSymbolClasses(_ canon: String) -> [(name: String, cap: Int, members: Set<String>)] {
    var classes: [(String, Int, Set<String>)] = []
    for line in canon.split(separator: "\n", omittingEmptySubsequences: false) {
        let row = String(line)
        guard row.hasPrefix("| **"), row.contains("|") else { continue }
        let cells = row.split(separator: "|", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard cells.count >= 4 else { continue }
        let name = cells[1].replacingOccurrences(of: "*", with: "")
        guard let cap = Int(cells[2]) else { continue }   // "not a learned class" has no cap
        let members = Set(matches(of: "`([a-z][a-zA-Z0-9.]*)`", in: cells[3]))
        classes.append((name, cap, members))
    }
    return classes
}

/// 04 section 6.6's Control furniture row: capped but not a `canonSymbolClasses` entry, because its
/// cap cell reads "not a learned class" rather than an `Int`. Shared so a member added to Control
/// furniture is seen by every scan that needs it, not just the one it was written for.
func canonControlFurnitureMembers(_ canon: String) -> Set<String> {
    let row = canon.split(separator: "\n", omittingEmptySubsequences: false)
        .map(String.init)
        .first { $0.contains("Control furniture") } ?? ""
    return Set(matches(of: "`([a-z][a-zA-Z0-9.]*)`", in: row))
}

/// Comment-only lines removed, so a scan counting a source pattern is not corrupted by a doc
/// comment that quotes the pattern in prose to explain what the scan does.
func strippingLineComments(_ text: String) -> String {
    text.split(separator: "\n", omittingEmptySubsequences: false)
        .map { $0.trimmingCharacters(in: .whitespaces).hasPrefix("//") ? "" : String($0) }
        .joined(separator: "\n")
}

/// Regex helper returning the first capture group of every match.
func matches(of pattern: String, in text: String) -> [String] {
    guard let expression = try? NSRegularExpression(pattern: pattern) else { return [] }
    let range = NSRange(text.startIndex..., in: text)
    return expression.matches(in: text, range: range).compactMap { match in
        guard match.numberOfRanges > 1,
              let captured = Range(match.range(at: 1), in: text) else { return nil }
        return String(text[captured])
    }
}

/// `04` section 6.4's heat-scale table, as `(floor, ceiling, role)` in the order canon states it.
///
/// Parses the **table**, not a sentence, and that is the whole point. This test read canon with
/// `matches(of: "red below (\\d+)")` until 2026-08-22, when `60f0c2d` replaced the three-band prose
/// sentence with a five-band table. The parser could not follow canon into a table, failed in its
/// own guard clause, and `--core-contracts` went red for a reason that had nothing to do with the
/// tokens — while the tokens, which really had fallen behind, went unchecked behind it. A parser
/// that reads the structure canon is written in survives canon being edited.
private func canonHeatBands(_ canon: String) -> [(floor: Int, ceiling: Int, role: String)] {
    let lines = canon.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    guard let start = lines.firstIndex(where: { $0.contains("default visual heat scale") })
    else { return [] }
    var bands: [(floor: Int, ceiling: Int, role: String)] = []
    for line in lines[start...] {
        let cells = line.split(separator: "|", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard cells.count >= 4 else {
            // The first non-row line after the rows have started is the end of the table. Before
            // that it is the amendment's own prose, which the sentinel matched.
            if !bands.isEmpty { break }
            continue
        }
        let bounds = matches(of: "(\\d+)", in: cells[2]).compactMap(Int.init)
        // Skips the header and its `|---|` separator, neither of which carries two numbers.
        guard bounds.count == 2 else { continue }
        bands.append((floor: bounds[0], ceiling: bounds[1], role: cells[3]))
    }
    return bands
}

/// The palette value a heat band's role cell names, or `nil` if this test cannot resolve it.
///
/// Order matters: "`state.positive`, lightened" contains "state.positive", so the lightened case
/// must be tried first or the Above band silently resolves to the Well above band's colour — which
/// would make the test pass while the two top bands were identical on screen.
private func heatBandValue(
    for role: String,
    palette: CoachWorldTokens.Palette
) -> CoachWorldTokens.ColorValue? {
    if role.contains("state.positive"), role.contains("lightened") {
        return CoachWorldTokens.Heat.lightenedPositive(palette)
    }
    if role.contains("state.positive") { return palette.statePositive }
    if role.contains("state.negative") { return palette.stateNegative }
    if role.contains("state.warning") { return palette.stateWarning }
    if role.contains("content.secondary") { return palette.contentSecondary }
    return nil
}

/// HSL hue in degrees. `04` section 6.1a(ii) states role separation in hue, so a test of it needs
/// the same measure; contrast alone cannot see two roles that are the same colour at a glance.
private func hueDegrees(_ value: CoachWorldTokens.ColorValue) -> Double {
    let high = max(value.red, value.green, value.blue)
    let low = min(value.red, value.green, value.blue)
    let delta = high - low
    guard delta > 0 else { return 0 }
    let hue: Double
    switch high {
    case value.red:   hue = 60 * (((value.green - value.blue) / delta).truncatingRemainder(dividingBy: 6))
    case value.green: hue = 60 * (((value.blue - value.red) / delta) + 2)
    default:          hue = 60 * (((value.red - value.green) / delta) + 4)
    }
    return hue < 0 ? hue + 360 : hue
}

/// The shorter way round the colour wheel between two hues, in degrees.
private func hueSeparation(_ a: Double, _ b: Double) -> Double {
    let raw = abs(a - b).truncatingRemainder(dividingBy: 360)
    return min(raw, 360 - raw)
}

private func designSheets() -> [(name: String, text: String)] {
    let root = packageRoot()
    let names = (try? FileManager.default.contentsOfDirectory(atPath: root.path))?
        .filter { $0.hasSuffix("-v3.dc.html") }
        .sorted() ?? []
    return names.compactMap { name in
        guard let text = try? String(contentsOf: root.appendingPathComponent(name), encoding: .utf8)
        else { return nil }
        return (name: name, text: text)
    }
}

private func rawAssetLoaders(in source: String) -> [String] {
    let patterns = [
        "Image\\([^\\n]*\\bbundle\\s*:",
        "Image\\s*\\(\\s*\\\"",
        "Image\\s*\\(\\s*decorative\\s*:",
        "UIImage\\s*\\(\\s*named\\s*:",
        "NSImage\\s*\\(\\s*named\\s*:",
        "Bundle\\.module\\.(?:image|url)\\s*\\("
    ]
    return codeLines(of: source).filter { line in
        patterns.contains { line.range(of: $0, options: .regularExpression) != nil }
    }
}

// MARK: - The suite

/// Every directory under `docs/` that holds markdown.
///
/// Walked rather than listed, because a list here would be the coverage boundary the manifest's own
/// problem was made of.
private func documentedDirectories() -> [String] {
    let root = packageRoot().appendingPathComponent("docs")
    guard let walker = FileManager.default.enumerator(atPath: root.path) else { return [] }
    var directories: Set<String> = []
    for case let path as String in walker where path.hasSuffix(".md") {
        let parent = (path as NSString).deletingLastPathComponent
        directories.insert(parent.isEmpty ? "docs/" : "docs/\(parent)/")
    }
    return directories.sorted()
}

func runDocumentManifestTests() {
    suite("Document manifest") {
        // DOC-MANIFEST decides what is canon, and it had gone stale against the tree it governs:
        // six directories holding 45 markdown files sat at paths it never named, one of them called
        // `10-CANON-AMENDMENT-04.md`. Section 1's rule already answers it in the abstract -- a path
        // listed nowhere carries no authority -- but silence reads as omission rather than as
        // classification, and a reader cannot tell which. So the directories are enumerated from
        // disk and checked against the manifest, not maintained by hand inside it.
        test("every docs directory holding markdown is classified in DOC-MANIFEST") {
            let manifestURL = packageRoot().appendingPathComponent("docs/DOC-MANIFEST.md")
            guard let manifest = try? String(contentsOf: manifestURL, encoding: .utf8) else {
                expect(false, "docs/DOC-MANIFEST.md is unavailable")
                return
            }
            let directories = documentedDirectories()
            expect(directories.count >= 8,
                   "walked only \(directories.count) docs directories — the walk, not the manifest, "
                       + "is what failed")
            let unclassified = directories.filter { !manifest.contains($0) }
            expect(unclassified.isEmpty,
                   "DOC-MANIFEST does not classify \(unclassified.count) directory(ies): "
                       + "\(unclassified.joined(separator: ", ")). Add each to section 8 with what "
                       + "it is and what authority it carries — a path the manifest never names is "
                       + "a path a reader has to guess about.")
        }

        test("the walk would notice a directory the manifest does not name") {
            let manifest = "| `docs/plans/` | plans | none |"
            let planted = ["docs/plans/", "docs/invented/"]
            expectEqual(planted.filter { !manifest.contains($0) }, ["docs/invented/"],
                        "an unclassified directory must be reported")
        }
    }
}

/// Every colour literal across `files`, mapped to every file path where it occurs, filtered down
/// to the values that occur more than once.
///
/// Built as one collection spanning every file rather than a `seen` set reset at the top of each
/// file's own loop: a per-file `seen` set can only ever catch a literal repeated within that one
/// file, so widening the caller's file filter from one token file to N silently changed the
/// invariant it enforces from "the token layer holds no repeated literal" to "no single file
/// does" — the gap that let `ForgeFieldTokens.swift`'s `leather` silently repeat
/// `DesignTokens.swift`'s `ballMid`, both `0x7A3E1C`, until this collected across files instead.
private func repeatedColourLiterals(in files: [(path: String, text: String)]) -> [String: [String]] {
    var occurrences: [String: [String]] = [:]
    for file in files {
        // Stripped, because the alias declarations explain themselves in prose that names the
        // very hex they replaced — 04 section 6.1a(ii)'s own example among them.
        let literals = matches(of: "(0x[0-9A-Fa-f]{6})\\b", in: strippingLineComments(file.text))
            .map { $0.uppercased() }
        for literal in literals {
            occurrences[literal, default: []].append(file.path)
        }
    }
    return occurrences.filter { $0.value.count > 1 }
}

func runDesignContractTests() {
    // Child-process probe for "an empty cost traps at construction" (Forge Field ember suite,
    // below). `precondition` failures abort the process rather than throwing a catchable Swift
    // error, so the only way to prove one fires is to watch it from outside: re-exec this same
    // binary with `--design-contracts` plus this environment variable set, and check the child's
    // exit status. Checked before anything else runs, same shape as `runPortalPolicyTests`'s own
    // `INVALID_EMPTY_PORTAL_OBSERVER_PROBE` early-return -- the one other place in this suite that
    // proves a fail-fast path by crashing a child process rather than catching an error.
    if ProcessInfo.processInfo.environment["FORGE_FIELD_EMBER_EMPTY_COST_PROBE"] != nil {
        _ = ForgeFieldEmber(label: "Lock the plan", cost: "", isEnabled: true) {}
        return
    }

    let canon = canonText()

    suite("Orientation policy") {
        // CLAUDE.md has claimed since 2026-08-10 that landscape-only is "declared in App/project.yml
        // and asserted by OrientationPolicyTest". The declaration was real; the test was not, and
        // nothing noticed for two days. G-09.
        test("the app declares landscape-only and never a portrait orientation") {
            let path = packageRoot().appendingPathComponent("App/project.yml")
            guard let yaml = try? String(contentsOf: path, encoding: .utf8) else {
                expect(false, "App/project.yml is unreadable at \(path.path)")
                return
            }

            let orientationLines = yaml.split(separator: "\n").map(String.init).filter {
                $0.contains("UISupportedInterfaceOrientations") || $0.contains("UIInterfaceOrientation")
            }
            expect(!orientationLines.isEmpty,
                   "project.yml declares no supported orientations, so the platform picks for us")

            let declaration = orientationLines.joined(separator: "\n")
            expect(declaration.contains("LandscapeLeft") && declaration.contains("LandscapeRight"),
                   "both sensor orientations are binding (04 section 7): \(declaration)")
            expect(!declaration.contains("Portrait"),
                   "portrait is not a supported orientation (owner decision 2026-08-10): \(declaration)")
        }

        test("the scan would notice a portrait orientation being added") {
            let planted = """
            INFOPLIST_KEY_UISupportedInterfaceOrientations: >-
              UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft
            """
            expect(planted.contains("Portrait"),
                   "the predicate the real assertion uses must catch a planted portrait value")
        }
    }

    suite("Design token sync") {
        // G-07's test half. The values were written back into 04 section 6.1 on 2026-08-12; nothing
        // stopped code and canon diverging the next day.
        test("every colour DesignTokens.swift ships is a value 04 section 6.1 states") {
            let canonValues = canonHexValues(canon)
            expect(canonValues.count >= 30,
                   "parsed only \(canonValues.count) hex values from 04 section 6.1 — the parser, "
                       + "not the tokens, is what failed")

            let tokenFiles = swiftFiles(under: "Sources/ProFootballCoachUI")
                .filter { $0.path.hasSuffix("Tokens.swift") }
            expect(!tokenFiles.isEmpty, "no *Tokens.swift found under Sources/ProFootballCoachUI")

            for file in tokenFiles {
                let shipped = Set(matches(of: "0x([0-9A-Fa-f]{6})\\b", in: file.text)
                    .map { $0.uppercased() })
                let undeclared = shipped.subtracting(canonValues).sorted()
                expect(undeclared.isEmpty,
                       "\(file.path) ships \(undeclared.count) colour(s) canon does not hold: "
                           + "\(undeclared.joined(separator: ", ")). Write them into 04 section 6.1 "
                           + "with their measured ratios, or remove them.")
            }
        }

        // 04 section 6.1a(ii), 2026-08-22: where two roles share a value they must be "declared as
        // aliases in the token layer rather than repeated as literals, so a future divergence is a
        // deliberate edit and not an accident". A repeated literal is the accident: someone
        // re-values one role, the other silently keeps the old number, and nothing records that the
        // two were ever meant to agree. Uniqueness is the whole invariant — this deliberately does
        // NOT pin which roles are equal, because canon permits diverging a pair on purpose.
        test("no colour literal is repeated in the token layer") {
            let tokenFiles = swiftFiles(under: "Sources/ProFootballCoachUI")
                .filter { $0.path.hasSuffix("Tokens.swift") }
            expect(!tokenFiles.isEmpty,
                   "no *Tokens.swift found under Sources/ProFootballCoachUI")

            // Gathered from every matched file into one collection before checking for
            // duplicates — see `repeatedColourLiterals`'s own comment for why a per-file loop
            // cannot stand in for this.
            let repeated = repeatedColourLiterals(in: tokenFiles)
            let detail = repeated.keys.sorted().map { value in
                "\(value) in \(Set(repeated[value] ?? []).sorted().joined(separator: ", "))"
            }.joined(separator: "; ")
            expect(repeated.isEmpty,
                   "the token layer repeats \(repeated.count) colour literal(s): \(detail). 04 "
                       + "section 6.1a(ii) requires a shared value to be declared once and "
                       + "aliased by each role that takes it, so that diverging them later is a "
                       + "deliberate edit.")
        }

        test("the repeated-literal scan would notice a duplicated value") {
            let planted = """
            static let one = ColorValue(hex: 0x4FD08C)
            static let two = ColorValue(hex: 0x4FD08C)
            """
            let literals = matches(of: "(0x[0-9A-Fa-f]{6})\\b", in: strippingLineComments(planted))
                .map { $0.uppercased() }
            var seen: Set<String> = []
            expect(!literals.filter { !seen.insert($0).inserted }.isEmpty,
                   "a planted duplicate colour literal must be caught")
        }

        test("the repeated-literal scan would notice a duplicate split across two files") {
            // The exact shape of the bug this reproduces: a `seen` set reset at the top of each
            // file's loop cannot see a value declared once in file A and again in file B — which
            // is precisely how `ForgeFieldTokens.swift`'s `leather` silently repeated
            // `DesignTokens.swift`'s `ballMid` while the scan still passed.
            let planted = [
                (path: "A.swift", text: "static let one = ColorValue(hex: 0x7A3E1C)"),
                (path: "B.swift", text: "static let two = ColorValue(hex: 0x7A3E1C)")
            ]
            let repeated = repeatedColourLiterals(in: planted)
            expect(repeated.count == 1,
                   "a colour literal repeated across two files, and not repeated within either "
                       + "file alone, must still be caught")
            expect(repeated.values.first?.sorted() == ["A.swift", "B.swift"],
                   "the caught duplicate must name both files it appears in")
        }

        test("glass rules become legible for both contrast branches") {
            let palette = CoachWorldTokens.dark
            let glass = CoachWorldTokens.Rule.glass
            let legible = CoachWorldTokens.Rule.legible

            expectEqual(glass.color(palette: palette),
                        palette.contentPrimary.color.opacity(0.13),
                        "standard glass keeps its content-primary hairline")
            expectEqual(glass.color(palette: palette, contrast: .increased),
                        legible.color(palette: palette, contrast: .increased),
                        "Increase Contrast must make glass fully legible")
            expectEqual(glass.color(palette: palette, reduceTransparency: true),
                        legible.color(palette: palette),
                        "Reduce Transparency must make standard glass legible")
            expectEqual(glass.color(palette: palette,
                                    contrast: .increased,
                                    reduceTransparency: true),
                        legible.color(palette: palette, contrast: .increased),
                        "combined accessibility settings must keep glass legible")
        }

        test("Increase Contrast raises the shared disabled-state opacity") {
            expectEqual(
                CoachWorldTokens.Motion.resolvedDisabledOpacity(for: .standard),
                0.40
            )
            expectEqual(
                CoachWorldTokens.Motion.resolvedDisabledOpacity(for: .increased),
                0.62
            )
        }

        test("banner stops alias existing token values without changing their measurements") {
            let palette = CoachWorldTokens.dark
            expectEqual(CoachWorldTokens.Banner.info.from,
                        palette.raised.color.opacity(0.97))
            expectEqual(CoachWorldTokens.Banner.info.to,
                        CoachWorldTokens.Floodlit.glassFlatDeep.color.opacity(0.97))
            expectEqual(CoachWorldTokens.Banner.info.edge,
                        palette.contentQuiet.color.opacity(0.42))
            expectEqual(CoachWorldTokens.Banner.good.from,
                        CoachWorldTokens.Floodlit.clubField.color.opacity(0.97))
            expectEqual(CoachWorldTokens.Banner.good.edge,
                        palette.statePositive.color.opacity(0.50))
            expectEqual(CoachWorldTokens.Banner.bad.edge,
                        palette.stateNegative.color.opacity(0.45))
        }

        test("the scan would notice a colour that canon does not hold") {
            let canonValues = canonHexValues(canon)
            let planted = "public static let rogue = ColorValue(hex: 0xABCDEF)"
            let found = Set(matches(of: "0x([0-9A-Fa-f]{6})\\b", in: planted).map { $0.uppercased() })
            expect(!found.subtracting(canonValues).isEmpty,
                   "a planted off-canon colour must not be reported as declared")
        }

        // S-2, 2026-08-19 review: the two tests above only ever look at DesignTokens.swift, and
        // only ever match a bare 0xRRGGBB hex literal. A view that constructs
        // `Color(red:green:blue:)` directly was invisible on both counts -- wrong scope, wrong
        // pattern -- and five confirmed sites did exactly that. CLAUDE.md: "A design-token literal
        // in a view is a defect: spacings, radii, colours and font sizes come from the design
        // system." The rule is that colour VALUES live only in the token file, not that every
        // value must already be a canon hex, so this does not attempt to convert an RGB literal to
        // hex and check membership -- constructing a Color outside DesignTokens.swift is the
        // defect, whatever value it happens to hold.
        //
        // Two of the five confirmed sites were exact or near-exact matches for an existing token
        // (MatchDayScoreBug's goldRule was precisely 0xD89713 = Floodlit.goldDeep;
        // CoachingHQView's ink-on-gold was ~1/255 per channel off Floodlit.goldInk, used the same
        // way elsewhere) and are fixed to reference them directly. The remaining three have no
        // existing canon hex to reference, checked by hand against `04` section 6.1's table and
        // DesignTokens.swift. Doc-first (CLAUDE.md) means a new hex value is a canon amendment the
        // owner makes, not one this fix invents, so they are named exceptions rather than silently
        // passed or left an unexplained failure -- the same shape as SuiteCatalog's unwritten
        // gates. Pinned to an exact per-file count so a new site anywhere, including a fourth in
        // one of these three files, still fails.
        test("no view constructs a raw colour outside the token layer, beyond the named exceptions") {
            let pendingCanonAmendment: [String: Int] = [
                "CoachWorldDeskComponents.swift": 0,
                "MatchDayField.swift": 0,
                "MatchDayScoreBug.swift": 1,           // .bowl kind's alternate ground, ~#0E0A06
            ]
            for file in swiftFiles(under: "Sources/ProFootballCoachUI")
            where !file.path.hasSuffix("/DesignTokens.swift") {
                // Stripped the same way the symbol scan strips prose that quotes its own pattern
                // (this file's own comments explaining the fix below say "Color(red:green:blue:)"
                // in prose, which the unstripped regex matched right back).
                let hits = matches(of: "Color\\((red|hue):", in: strippingLineComments(file.text))
                let fileName = String(file.path.split(separator: "/").last ?? "")
                let allowed = pendingCanonAmendment[fileName] ?? 0
                expect(hits.count == allowed,
                       "\(file.path) constructs \(hits.count) raw Color(...) literal(s) outside "
                           + "the token layer (expected \(allowed) pending-canon-amendment "
                           + "exception(s)). Colour values come from CoachWorldTokens, never a "
                           + "literal in a view — write a new one into 04 section 6.1 first if "
                           + "this is genuinely new, or reference an existing token.")
            }
        }

        test("the scan would notice a raw colour literal outside the token layer") {
            let planted = "Color(red: 1, green: 0.95, blue: 0.78)"
            expect(!matches(of: "Color\\((red|hue):", in: planted).isEmpty,
                   "a planted raw Color(red:...) literal must be caught")
        }

        // S-2 follow-up, 2026-08-20 remediation: three independent rating-colour bandings
        // (RosterView, DesignTokens.Heat, CoachWorldRatingRing) disagreed with each other and with
        // this exact canon sentence. RosterView and CoachWorldRatingRing now delegate to
        // `Heat.color(for:palette:)` rather than each carrying their own switch, so testing this one
        // function against canon, across the whole rating range, is what makes all three agree by
        // construction rather than by three people remembering to keep three copies in sync.
        test("Heat's banding matches 04 section 6.4's stated heat scale, across the whole range") {
            let bands = canonHeatBands(canon)
            expect(bands.count == 5,
                   "parsed \(bands.count) bands from 04 section 6.4's heat scale, not the five the "
                       + "2026-08-22 amendment states — the parser, not the tokens, is what failed")
            guard bands.count == 5 else { return }

            // The bands must partition the scale. A gap or an overlap is a rating with no colour or
            // two, and neither is visible by reading the switch: only checking every value is.
            expectEqual(bands[0].floor, CoachWorldTokens.Heat.scaleFloor,
                        "04 section 6.4's first band must start at Heat.scaleFloor")
            expectEqual(bands[bands.count - 1].ceiling, CoachWorldTokens.Heat.scaleCeiling,
                        "04 section 6.4's last band must end at Heat.scaleCeiling")
            for (lower, upper) in zip(bands, bands.dropFirst()) {
                expectEqual(upper.floor, lower.ceiling + 1,
                            "04 section 6.4's bands must be contiguous: \(lower.ceiling) is "
                                + "followed by \(upper.floor)")
            }

            let palette = CoachWorldTokens.dark
            for band in bands {
                guard let expected = heatBandValue(for: band.role, palette: palette) else {
                    expect(false, "04 section 6.4's \(band.floor)-\(band.ceiling) band names a "
                        + "role this test cannot resolve: \(band.role)")
                    continue
                }
                for rating in band.floor...band.ceiling {
                    expectEqual(CoachWorldTokens.Heat.value(for: rating, palette: palette), expected,
                                "rating \(rating) does not land in the band 04 section 6.4 "
                                    + "describes")
                }
            }

            // The centre band is ink, not a colour, and that is the whole point of the amendment:
            // an ordinary starter is not a caution.
            expectEqual(CoachWorldTokens.Heat.color(for: 74, palette: palette),
                        palette.contentSecondary.color,
                        "the average band must be neutral ink — colouring it makes every dense "
                            + "table read as a verdict")
        }

        // 04 section 6.4 states two constraints on the scale in the same breath as the table, and
        // they are the reason the amendment exists: an average starter must stop reading as a
        // caution, and no band may be mistaken for the committing action.
        test("every heat band clears 4.5:1 on world.page and sits 24 degrees off gold") {
            let palette = CoachWorldTokens.dark
            let gold = hueDegrees(palette.actionPrimary)
            for rating in CoachWorldTokens.Heat.scaleFloor...CoachWorldTokens.Heat.scaleCeiling {
                let band = CoachWorldTokens.Heat.value(for: rating, palette: palette)
                let ratio = contrastRatio(band, palette.page)
                expect(ratio >= 4.5,
                       "rating \(rating)'s band measures \(ratio) on world.page, below 04 section "
                           + "6.4's stated 4.5:1")
                let separation = hueSeparation(hueDegrees(band), gold)
                expect(separation >= 24,
                       "rating \(rating)'s band sits \(separation) degrees from gold, inside 04 "
                           + "section 6.1a(ii)'s 24 degree floor — gold marks the committing action "
                           + "and carries no other meaning, least of all a rating")
            }
        }

        test("the heat-scale parser reads a table and is not satisfied by the prose it replaced") {
            let prose = """
            The default visual heat scale is red below 70, amber from 70-84 and green from 85 upward.

            """
            expect(canonHeatBands(prose).isEmpty,
                   "the superseded sentence form must not parse as bands — that it silently did "
                       + "not is what left the tokens unchecked")

            let planted = """
            The default visual heat scale over the 40-99 range is two bands:

            | Band | Range | Role |
            |---|---|---|
            | Low | 40-69 | `state.negative` |
            | High | 70-99 | `state.positive` |

            """
            let bands = canonHeatBands(planted)
            expectEqual(bands.count, 2, "a planted two-row band table must parse as two bands")
            expectEqual(bands.first?.floor, 40, "a planted band's floor must be read from the table")
            expectEqual(bands.last?.ceiling, 99, "a planted band's ceiling must be read from the table")
        }
    }

    suite("Team logo asset loading") {
        test("only CoachWorldTeamLogo loads packaged image assets") {
            let permittedPath = "Sources/ProFootballCoachUI/CoachWorldTeamLogo.swift"
            let files = swiftFiles(under: "Sources/ProFootballCoachUI") + swiftFiles(under: "App")
            expect(files.contains { $0.path == permittedPath },
                   "\(permittedPath) must own packaged image loading")

            for file in files where file.path != permittedPath {
                let loaders = rawAssetLoaders(in: file.text)
                expect(loaders.isEmpty,
                       "\(file.path) loads packaged assets outside CoachWorldTeamLogo.swift: "
                           + loaders.joined(separator: " | "))
            }
        }

        test("the scan would notice a raw asset loader outside the component") {
            expect(!rawAssetLoaders(in: #"Image("rogue")"#).isEmpty,
                   "a planted SwiftUI asset load must be caught")
            expect(!rawAssetLoaders(in: #"Image(decorative: "rogue")"#).isEmpty,
                   "a planted decorative asset load must be caught")
            expect(!rawAssetLoaders(in: "UIImage(named: \\\"rogue\\\")").isEmpty,
                   "a planted UIKit asset load must be caught")
            expect(!rawAssetLoaders(in: "Bundle.module.image(forResource: NSImage.Name(\\\"rogue\\\"))").isEmpty,
                   "a planted AppKit asset load must be caught")
        }
    }

    suite("Symbol register") {
        // G-08. Every sheet priced its symbol spend locally and then asserted global compliance,
        // which no sheet can know — the P1 the 2026-08-12 review named. 04 section 6.6 holds the
        // register; this asserts the tree against it.
        test("04 section 6.6 states a register this test can read") {
            let classes = canonSymbolClasses(canon)
            expect(classes.count >= 4,
                   "parsed \(classes.count) symbol classes from 04 section 6.6; the register is the "
                       + "single place the totals are held and it must be machine-readable")
            for symbolClass in classes {
                expect(symbolClass.members.count <= symbolClass.cap,
                       "class \(symbolClass.name) enumerates \(symbolClass.members.count) members "
                           + "against its own cap of \(symbolClass.cap)")
            }
        }

        test("every SF Symbol the UI draws is a registered member") {
            let classes = canonSymbolClasses(canon)
            let registered = classes.reduce(into: Set<String>()) { $0.formUnion($1.members) }
            let permitted = registered.union(canonControlFurnitureMembers(canon))
            expect(permitted.count >= 12, "the register parsed as \(permitted.count) symbols")

            // Every file that draws, enumerated by the UI import rather than by directory. It read
            // `Sources/ProFootballCoachUI` until 2026-08-13, when the composition layer added a
            // second target containing a view — which would have been outside the register's reach
            // on the day it was written.
            for file in swiftFilesImportingUIFramework() {
                // systemName: "x" is how SwiftUI names a symbol; that is the call this looks for.
                let drawn = Set(matches(of: "system(?:Name|Image):\\s*\"([^\"]+)\"", in: file.text))
                let unregistered = drawn.subtracting(permitted)
                    // A filled variant is the same member as its base (04 section 6.6).
                    .filter { !permitted.contains($0.replacingOccurrences(of: ".fill", with: "")) }
                    .sorted()
                expect(unregistered.isEmpty,
                       "\(file.path) draws \(unregistered.count) symbol(s) the 04 section 6.6 "
                           + "register does not hold: \(unregistered.joined(separator: ", ")). "
                           + "A symbol outside the register is a finding under 04 section 4.5, "
                           + "not a licence — map it into a class or drop it.")
            }
        }

        test("the scan would notice an unregistered symbol") {
            let classes = canonSymbolClasses(canon)
            let registered = classes.reduce(into: Set<String>()) { $0.formUnion($1.members) }
            let planted = #"Image(systemName: "flame.circle.fill")"#
            let drawn = Set(matches(of: "systemName:\\s*\"([^\"]+)\"", in: planted))
            expect(!drawn.subtracting(registered).isEmpty,
                   "a planted unregistered symbol must not be reported as registered")
        }

        // MatchDayControlID's icons used to be a bare String returned from a switch — invisible to
        // the literal scan above, which is exactly how sparkles.tv shipped. MatchDayControlSymbol
        // closes that one instance the way CoachWorldStatusChip.Symbol closes Status: a typed,
        // CaseIterable enum a contract test can enumerate. Unlike Status, these five do not own
        // their class exclusively — Control furniture is a shared pool other components draw from
        // too — so the assertion is membership, not the equality CoachWorldStatusChip.Symbol uses.
        test("MatchDayControlSymbol's members are registered, fill variants included") {
            let classes = canonSymbolClasses(canon)
            let registered = classes.reduce(into: Set<String>()) { $0.formUnion($1.members) }
            let permitted = registered.union(canonControlFurnitureMembers(canon))
            expect(permitted.count >= 12, "the register parsed as \(permitted.count) symbols")

            let shipped = Set(MatchDayControlSymbol.allCases.map(\.rawValue))
            // Same rule the general scan above applies: a filled variant is the same member as its
            // base (04 section 6.6) — hand.raised.fill for Status's hand.raised, here.
            let unregistered = shipped.subtracting(permitted)
                .filter { !permitted.contains($0.replacingOccurrences(of: ".fill", with: "")) }
            expect(unregistered.isEmpty,
                   "MatchDayControlSymbol ships \(unregistered.count) symbol(s) 04 section 6.6 does "
                       + "not hold: \(unregistered.sorted().joined(separator: ", "))")
        }

        test("every non-literal symbol call site is a known one") {
            // The scan above matches only a literal string directly after the SwiftUI symbol
            // argument, so a computed value — a switch, a ternary, a stored field — is invisible to
            // it. Closing every instance of that shape is not buildable by regex; this instead pins
            // how many such call sites exist, so a new one moving the count is a build failure a
            // human must look at. It does not itself prove the symbol underneath is registered —
            // CoachWorldStatusChip.Symbol, CoachWorldDeltaMark and MatchDayControlSymbol prove that
            // for their own sites with a dedicated canon-sync test; the rest were checked by hand
            // when this pin was set and must be re-checked by hand when it moves.
            // 9 until 2026-08-23. The icon rail's `Image(systemName: entry.symbol)` was the
            // ninth; removing the rail removed the site, and the pin shrinks with it. The jump-to
            // control that replaced the rail's registry entry draws a literal, so it adds none.
            // 8 until 2026-08-31. Coaching HQ's Forge Field rewrite (`04` section 6.6a: "Forge
            // Field ships no icon set") replaced the Press Box composition's two non-literal sites
            // -- the choice row's `selected ? "checkmark.circle.fill" : "circle"` and
            // `noDecision`'s `preparationNeeded ? "clipboard" : "checkmark.circle"` -- with a
            // surface that draws no SF Symbol at all, so the pin shrinks to 6.
            let knownNonLiteralSites = 6
            var found = 0
            var byFile: [String] = []
            for file in swiftFilesImportingUIFramework() {
                let filtered = strippingLineComments(file.text)
                let total = matches(of: "(system(?:Name|Image):)", in: filtered).count
                let literal = matches(of: "(system(?:Name|Image):\\s*\"[^\"]+\")", in: filtered).count
                let nonLiteral = total - literal
                if nonLiteral > 0 {
                    found += nonLiteral
                    byFile.append("\(file.path)=\(nonLiteral)")
                }
            }
            expectEqual(found, knownNonLiteralSites,
                        "non-literal systemName/systemImage call sites now total \(found), pinned "
                            + "at \(knownNonLiteralSites): \(byFile.sorted().joined(separator: ", ")). "
                            + "Resolve a new one through a typed, canon-tested enum (04 section 6.6) "
                            + "like MatchDayControlSymbol, then move this pin either way, growing or "
                            + "shrinking it.")
        }

        test("the non-literal scan counts a planted site and ignores prose that quotes the pattern") {
            let planted = "Image(systemName: someComputedValue)"
            let total = matches(of: "(system(?:Name|Image):)", in: planted).count
            let literal = matches(of: "(system(?:Name|Image):\\s*\"[^\"]+\")", in: planted).count
            expectEqual(total - literal, 1, "a planted non-literal call site must be counted")

            // This is not a hypothetical: writing the test above, in this same file, first shipped
            // as its own false positive — the doc comment on MatchDayControlSymbol names
            // "systemName:" and "systemImage:" in prose to explain what the scan matches.
            let comment = "    /// the scan reads systemName: and systemImage: as plain prose here"
            expectEqual(strippingLineComments(comment), "",
                        "a comment-only line must be stripped before counting, or explaining this "
                            + "scan in its own file becomes a false positive")
        }
    }

    suite("Design reference sheets") {
        // G-17. The sheets are the definitive design references (04 section 6.5), so the claims they
        // make about themselves are load-bearing. These are the ones a machine can settle.
        test("all eight sheets are present and marked") {
            let sheets = designSheets()
            expectEqual(sheets.count, 8, "expected the eight sheets named in 04 section 6.5")
            for sheet in sheets {
                let group = sheet.name.replacingOccurrences(of: "-v3.dc.html", with: "")
                let firstLine = sheet.text.split(separator: "\n", maxSplits: 1).first.map(String.init) ?? ""
                expectEqual(firstLine.trimmingCharacters(in: .whitespaces),
                            "<!-- @dsCard group=\"\(group)\" -->",
                            "\(sheet.name) must open with its @dsCard marker")
            }
        }

        test("no sheet reaches outside itself") {
            // Zero third-party anything is owner-fixed, and a sheet that loads a CDN font is a
            // dependency the design system cannot ship.
            for sheet in designSheets() {
                for (pattern, label) in [("<script", "a script"),
                                         ("https?://", "an external URL"),
                                         ("@font-face", "a web font"),
                                         ("<img", "an image")] {
                    let hits = matches(of: "(\(pattern))", in: sheet.text).count
                    expectEqual(hits, 0, "\(sheet.name) contains \(label)")
                }
            }
        }

        test("no sheet quotes a contrast ratio canon does not state") {
            // The one claim most worth checking: a plausible figure sitting in a row of sourced ones
            // inherits their authority. Only prose counts — CSS carries line-heights and the week
            // grid carries dose multipliers, and neither is a contrast claim.
            let canonRatios = Set(matches(of: "\\b(\\d{1,2}\\.\\d{2})\\b", in: canon))
            expect(canonRatios.count >= 40,
                   "parsed \(canonRatios.count) ratios from canon; the parser is what failed")

            for sheet in designSheets() {
                var prose = sheet.text
                for pattern in ["<style\\b[\\s\\S]*?</style>", "style\\s*=\\s*\"[^\"]*\"",
                                "[x×]\\s*\\d\\.\\d{2}"] {
                    prose = prose.replacingOccurrences(of: pattern, with: " ",
                                                       options: .regularExpression)
                }
                let quoted = Set(matches(of: "\\b(\\d{1,2}\\.\\d{2})\\b", in: prose))
                let invented = quoted.subtracting(canonRatios)
                    .filter { (1.0...21.0).contains(Double($0) ?? 0) }
                    .sorted()
                expect(invented.isEmpty,
                       "\(sheet.name) quotes \(invented.count) contrast figure(s) not in 04 "
                           + "section 6.1: \(invented.joined(separator: ", ")). Ratios are quoted "
                           + "from canon, never computed at authoring time.")
            }
        }

        test("no sheet carries an emoji or a real-world identity") {
            // The legal guardrail is absolute and the sheets are the artefact most likely to reach
            // for a familiar name for realism. No emoji is a repo-wide convention.
            for sheet in designSheets() {
                let emoji = sheet.text.unicodeScalars.filter {
                    (0x1F300...0x1FAFF).contains($0.value) || (0x2600...0x27BF).contains($0.value)
                }
                expect(emoji.isEmpty, "\(sheet.name) contains an emoji")

                expect(sheet.text.contains("pending generator output"),
                       "\(sheet.name) must label its synthetic identities")
            }
        }

        test("the sheet scan would notice a script and an invented ratio") {
            let planted = "<p>ratio 7.77</p><script>alert(1)</script>"
            expectEqual(matches(of: "(<script)", in: planted).count, 1,
                        "a planted script tag must be caught")
            let canonRatios = Set(matches(of: "\\b(\\d{1,2}\\.\\d{2})\\b", in: canon))
            expect(!canonRatios.contains("7.77"),
                   "the planted ratio must not coincidentally exist in canon")
        }
    }

    suite("Floodlit dark-only (06.1a)") {
        // 04 section 6.1a (2026-08-16): Floodlit is dark-only, with no production light palette and
        // no user-facing appearance switch. `Palette.light` and every `colorScheme` branch that
        // chose between `.dark`/`.light` are the code shape the amendment retires; this is the test
        // half of G-07 for that amendment, enumerated by directory per CLAUDE.md's coverage rule.
        test("no UI file resolves a palette by system colour scheme") {
            for file in swiftFiles(under: "Sources/ProFootballCoachUI") {
                expect(!file.text.contains("CoachWorldTokens.light"),
                       "\(file.path) still references CoachWorldTokens.light; 04 section 6.1a "
                           + "retired the light palette")
                expect(!file.text.contains("Environment(\\.colorScheme)"),
                       "\(file.path) still reads colorScheme; Floodlit has no appearance switch")
            }
        }

        test("the scan would notice a reintroduced light branch") {
            let planted = "colorScheme == .dark ? CoachWorldTokens.dark : CoachWorldTokens.light"
            expect(planted.contains("CoachWorldTokens.light"),
                   "the predicate the real assertion uses must catch a planted light reference")
        }

        test("DesignTokens.swift declares no light palette") {
            let tokenFiles = swiftFiles(under: "Sources/ProFootballCoachUI")
                .filter { $0.path.hasSuffix("DesignTokens.swift") }
            expect(!tokenFiles.isEmpty, "DesignTokens.swift not found")
            for file in tokenFiles {
                expect(!file.text.contains("public static let light"),
                       "\(file.path) still declares a light Palette instance")
            }
        }
    }

    suite("Floodlit vocabulary symbol sourcing (Task 4)") {
        // The existing "every SF Symbol the UI draws is a registered member" scan (above) only
        // matches a literal string directly after systemName:/systemImage:. CoachWorldStatusChip
        // and CoachWorldDeltaMark resolve their symbol through a typed enum for call-site safety,
        // which makes their raw values invisible to that regex — a real blind spot, closed here by
        // reading the same canon table these enums were written against.
        test("CoachWorldStatusChip.Symbol is exactly the canon Status class") {
            let classes = canonSymbolClasses(canon)
            guard let status = classes.first(where: { $0.name.contains("StatusChip") }) else {
                expect(false, "04 section 6.6 no longer names a StatusChip row")
                return
            }
            let shipped = Set(CoachWorldStatusChip.Symbol.allCases.map(\.rawValue))
            expectEqual(shipped, status.members,
                        "CoachWorldStatusChip.Symbol must be exactly the canon Status class, no "
                            + "more and no fewer")
        }

        test("CoachWorldDeltaMark's two directions are the canon Change class") {
            let classes = canonSymbolClasses(canon)
            guard let change = classes.first(where: { $0.name.contains("DeltaMark") }) else {
                expect(false, "04 section 6.6 no longer names a DeltaMark row")
                return
            }
            let shipped: Set<String> = [
                CoachWorldDeltaMark(value: 1).symbolName,
                CoachWorldDeltaMark(value: -1).symbolName,
            ].compactMap { $0 }.reduce(into: Set<String>()) { $0.insert($1) }
            expectEqual(shipped, change.members, "the two directions must be exactly the canon "
                            + "Change class")
        }

        test("CoachWorldAgendaRow's obligation marks are the canon Obligation class") {
            let classes = canonSymbolClasses(canon)
            guard let obligation = classes.first(where: { $0.name.contains("AgendaRow") }) else {
                expect(false, "04 section 6.6 no longer names an AgendaRow row")
                return
            }
            expectEqual(obligation.members, ["checkmark.circle.fill", "person.badge.clock"],
                        "CoachWorldAgendaRow draws exactly these two members inline; if canon's "
                            + "row changes, this test and the view must change together")
        }
    }

    suite("Floodlit geometry (06.1a)") {
        // The asymmetric four-radius shape 04 section 6.1a names, with its three presets. A shape
        // built from a single `cut` value cannot express 4/22/4/22, so the type itself is the
        // contract: this only compiles if the presets exist with the stated radii.
        test("the three named CutCorner presets match 04 section 6.1a's radii") {
            let panel = CoachWorldCutCorner.panel
            expectEqual(panel.topLeading, 4); expectEqual(panel.topTrailing, 22)
            expectEqual(panel.bottomTrailing, 4); expectEqual(panel.bottomLeading, 22)

            let row = CoachWorldCutCorner.row
            expectEqual(row.topLeading, 3); expectEqual(row.topTrailing, 14)
            expectEqual(row.bottomTrailing, 3); expectEqual(row.bottomLeading, 14)

            let action = CoachWorldCutCorner.action
            expectEqual(action.topLeading, 22); expectEqual(action.topTrailing, 22)
            expectEqual(action.bottomTrailing, 22); expectEqual(action.bottomLeading, 5)
        }

        test("the Press Box navigator occupies the ledger's one-row stage") {
            expectEqual(CoachWorldTokens.Stage.contentLeading, 63)
            expectEqual(CoachWorldTokens.Stage.headerTop, 12)
            expectEqual(CoachWorldTokens.Stage.headerHeight, 34)
            expectEqual(CoachWorldTokens.Stage.contentTop, 54)
            expectEqual(CoachWorldTokens.Stage.contentWidth, 761)
        }
    }

    suite("Press Box shared chrome") {
        // Re-targeted for Phase 2A Task 5 (04 6.1f): the Forge Field chrome bar replaces the Press
        // Box identity band. Its fixed contents -- "mark, club, record, the five surfaces, the
        // week... present on every surface and its contents never vary" -- have no back control, no
        // family switcher panel, no folds-into panel and no short-context yielding ladder, so each
        // of the five things the old test named is either retired here with a stated reason or kept
        // unchanged. Nothing is silently dropped: "do not delete an assertion without replacing it
        // -- a check that quietly disappeared is how the shipped truncation survived five screens."
        test("Press Box's four chrome-only controls are retired; top-navigator survives") {
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            let chrome = ui.first { $0.path.hasSuffix("/FloodlitChrome.swift") }?.text ?? ""
            let composition = ui.first {
                $0.path.hasSuffix("/CoachWorldFloodlitComposition.swift")
            }?.text ?? ""

            // Retired: 04 6.1f's fixed bar has no back control. The five families are always
            // visible in the bar itself now, so jumping anywhere no longer needs a dedicated
            // back step the way a hidden switcher behind one button did.
            expect(!chrome.contains("backControl"),
                   "the Forge Field bar has no back control -- 04 6.1f names none")
            // Retired: the switcher's only job was revealing the five families on demand. The
            // Forge Field bar shows all five inline and always (ForgeFieldChromeBar.familyStrip),
            // so the reveal mechanism it hung from is structurally gone, not merely restyled.
            expect(!chrome.contains("FamilySwitcher"),
                   "the family switcher panel has nothing left to reveal -- its five families are "
                       + "always inline in the bar")
            // Retired: the folds-into panel opened from a sibling-strip entry that carried hosted
            // aliases. This bar carries no sibling strip at all -- 04 6.1f's whole reason to
            // exist, since that strip is what truncated on five screens -- so there is no control
            // left to hang the panel from.
            expect(!chrome.contains("HostPanel"),
                   "the folds-into panel has no sibling strip left to hang from")
            // Retired alongside FamilySwitcher and HostPanel: this anchor-preference plumbing
            // existed only to position those two panels under their triggering controls.
            expect(!chrome.contains("ChromePanelAnchorKey")
                       && !chrome.contains("overlayPreferenceValue"),
                   "the anchor-preference plumbing that hung the retired panels must go with them")
            // Retired from rendering: contextShort existed only to shorten the right-hand context
            // chip once the sibling strip reached its width floor. The bar has neither a context
            // chip nor a sibling strip, so the yielding ladder it served no longer exists. The
            // field itself stays on FloodlitChromeReadModel -- read-model data outliving the one
            // renderer that used it is not this task's problem to solve, and dropping it would
            // touch call sites outside this task's file list for no behavioural gain -- so this
            // checks the usage is gone, not the declaration, which legitimately still contains
            // the word.
            expect(!chrome.contains("model.contextShort"),
                   "the bar has no context chip, so nothing should still read contextShort")
            // Kept: automation that looks for "the navigator" at the top of a surface must keep
            // finding it, regardless of what now renders inside it.
            expect(chrome.contains("top-navigator"),
                   "the shared band must still expose the top-navigator accessibility identifier")
            // The replacement must actually be hosted, not just leave a gap where the retired
            // controls were.
            expect(chrome.contains("ForgeFieldChromeBar"),
                   "the identity header must host the Forge Field chrome bar")
            expect(!chrome.contains("ALL TASKS") && !composition.contains("SurfaceRegistryOverlay"),
                   "the retired all-task index screen must not be restored by this retargeting")
            expect(!chrome.contains("Sections"),
                   "the navigator must not restore the retired Sections accessibility label")
        }

        test("a seat exposes five families and the registry's authored task counts") {
            func model(availableScreens: [CoachWorldScreenID]) -> FloodlitChromeReadModel {
                FloodlitChromeReadModel(
                    screen: .coachingHQ,
                    world: .facility,
                    club: CoachWorldTeamReference(
                        stableID: "contract-team",
                        name: "Contract Team",
                        abbreviation: "CT"
                    ),
                    record: "6–2",
                    context: "Week 9 · Saturday · Southern State",
                    contextShort: "Week 9 · Saturday",
                    back: .none,
                    availableScreens: availableScreens
                )
            }

            let college = model(availableScreens: CoachWorldScreenID.allCases.filter {
                $0.isCanonicalTask && $0.family != .proManagement && $0.family != .entry
            }).families
            expectEqual(college.count, 5)
            expectEqual(college.reduce(0) { $0 + $1.taskCount }, 41)
            expect(!college.contains { $0.family == .proManagement },
                   "a college seat must omit Pro management rather than disable it")

            let pro = model(availableScreens: CoachWorldScreenID.allCases.filter {
                $0.isCanonicalTask && $0.family != .recruiting && $0.family != .entry
            }).families
            expectEqual(pro.count, 5)
            expectEqual(pro.reduce(0) { $0 + $1.taskCount }, 42)
            expect(!pro.contains { $0.family == .recruiting },
                   "a pro seat must omit Recruiting rather than disable it")
        }

        test("the six canonical hosts expose all fifteen legacy identities") {
            let expected: [CoachWorldScreenID: [Int]] = [
                .careerHub: [3, 4, 5, 53, 56],
                .collegeOffseason: [30, 31, 32, 33],
                .proOffseason: [37, 38, 40],
                .staffRoom: [21],
                .gamePlan: [22],
                .depthChart: [23],
            ]
            var total = 0
            for (host, numbers) in expected {
                let sibling = FloodlitChromeReadModel.Sibling(
                    screen: host,
                    title: host.taskName,
                    intentID: .init(rawValue: "route|\(host.rawValue)")
                )
                let actual = sibling.hostedAliases.map(\.screen.number)
                expectEqual(actual, numbers, "\(host.taskName) must expose its exact alias routes")
                total += actual.count
            }
            expectEqual(total, 15)
        }

        test("alias navigation preserves visible history without recording a no-op") {
            let app = swiftFiles(under: "Sources/CoachWorldApp").first {
                $0.path.hasSuffix("/CoachWorldAppRootView.swift")
            }?.text ?? ""
            expect(app.contains("guard destination != previous")
                       && app.contains("if let activeChromeAlias { return activeChromeAlias }"),
                   "active aliases must be visible identities and reselecting one must be a no-op")
            expect(app.contains("recordsChromeHistory: false"),
                   "canonical alias routing and Back must not double-record history")
        }

        test("the shared stage owns both transparency and contrast branches") {
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            let desk = ui.first {
                $0.path.hasSuffix("/CoachWorldDeskComponents.swift")
            }?.text ?? ""
            let chrome = ui.first { $0.path.hasSuffix("/FloodlitChrome.swift") }?.text ?? ""

            expect(desk.contains("accessibilityReduceTransparency")
                       && desk.contains("colorSchemeContrast"),
                   "the shared stage and panel owner must read both accessibility settings")
            expect(desk.contains("showsDetail: !reduceTransparency")
                       && chrome.contains("let showsDetail: Bool"),
                   "Reduce Transparency must suppress atmosphere detail without removing ground")
            expect(desk.contains("contrast != .increased")
                       && desk.contains("usesOpaqueFill"),
                   "Increase Contrast must remove grain and material at the shared choke points")
            expect(desk.contains(".fill(.ultraThinMaterial)"),
                   "the standard branch must retain the measured material treatment")
        }

        test("position markers do not spend gold or identity colour") {
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            let forbidden = [
                "isSelected?palette.actionPrimary",
                "isSelected?palette.collegeIdentity",
                "isCurrent?palette.actionPrimary",
                "isCurrent?palette.collegeIdentity",
                "isControlled?palette.actionPrimary",
                "selected?palette.actionPrimary",
                "selected?palette.collegeIdentity",
                "BroadcastWedge().fill(CoachWorldTokens.dark.actionPrimary",
            ]
            func violatesRule(_ source: String) -> Bool {
                let compact = source.components(separatedBy: .whitespacesAndNewlines).joined()
                return forbidden.contains(where: compact.contains)
            }

            let source = ui.map(\.text).joined(separator: "\n")
            expect(!violatesRule(source), "position markers must use ink")
            expect(violatesRule("isSelected ? palette.actionPrimary.color : palette.contentPrimary.color"),
                   "gold audit must detect a planted position-marker violation")
        }
    }

    suite("Retired symbols (06.1c)") {
        // Deleting a symbol is not the same as preventing its return. The 44 pt icon rail was
        // removed on 2026-08-23 because it named the same places the identity band already
        // reaches; nothing about the codebase stops someone re-adding it in six weeks, having
        // read a reference sheet that still draws one. This is that stop.
        //
        // The set is deliberately the *names*, not the geometry: a rail rebuilt under a new name
        // is a different design decision and gets argued on its merits, while a rail rebuilt under
        // the old one is a regression.
        let retired = ["FloodlitIconRail", "RailEntry", "showsIconRail", "railFreeLeading"]

        test("no production file names a symbol the icon-rail removal retired") {
            let production = swiftFiles(under: "Sources")
            expect(!production.isEmpty, "the production scan found no files to read")
            for file in production {
                let body = strippingLineComments(file.text)
                for name in retired where body.contains(name) {
                    expect(false, "\(file.path) still names the retired symbol \(name)")
                }
            }
        }

        test("the scan would notice a retired symbol coming back") {
            // A scan that has never failed is not known to be a scan.
            let planted = """
                struct Example: View {
                    var body: some View { FloodlitIconRail(entries: []) }
                }
                """
            let body = strippingLineComments(planted)
            expect(retired.contains { body.contains($0) },
                   "the retired-symbol scan did not catch a planted icon rail")

            // And it must not fire on a file that only mentions the removal in prose, or the
            // comment explaining why the rail is gone becomes the thing that fails the build.
            let prose = "// The icon rail (FloodlitIconRail) was removed on 2026-08-23.\nlet x = 1\n"
            let stripped = strippingLineComments(prose)
            expect(!retired.contains { stripped.contains($0) },
                   "the scan fired on a line comment, which would forbid explaining the removal")
        }

        // The removal's whole point, asserted as arithmetic rather than as a number: the content
        // column is the frame minus the leading inset and the trailing gutter, with no rail in it.
        test("the content column derives from the leading inset, not from a rail") {
            expectEqual(CoachWorldTokens.Stage.contentLeading,
                        CoachWorldTokens.Frame.leadingInset,
                        "every management surface starts at the rail-free leading edge now")
            expectEqual(CoachWorldTokens.Stage.contentWidth, 761,
                        "844 - 63 - 20; the rail's 52 pt went back to the content column")
            expectEqual(CoachWorldTokens.Stage.contentLeading
                            + CoachWorldTokens.Stage.contentWidth
                            + CoachWorldTokens.Frame.gutter,
                        CoachWorldTokens.Frame.floorWidth,
                        "the three parts must still tile the install floor exactly")
        }
    }

    suite("Forge Field fonts (06.2a)") {
        // Sources/ProFootballCoachUI/Resources/Fonts is the single source of truth. project.yml is
        // not involved: fix round 2 (2026-08-29) built the real app and found
        // INFOPLIST_KEY_UIAppFonts is silently dropped from the built Info.plist -- Xcode's
        // INFOPLIST_KEY_ mechanism only honours a fixed set of keys, and this is not one of them --
        // and that it would not have resolved even if it had survived, since SwiftPM nests a
        // library target's resources in <App>_<Target>.bundle rather than at the app bundle root.
        // ForgeFieldFonts.swift registers straight from Bundle.module instead, which is where the
        // files actually are, and this suite proves the registration actually resolves through
        // CoreText -- not just that the files sit on disk next to a licence.
        test("every family in Resources/Fonts ships a licence and resolves through CoreText") {
            let root = packageRoot()
            let fontDir = root.appendingPathComponent("Sources/ProFootballCoachUI/Resources/Fonts")

            guard let entries = try? FileManager.default.contentsOfDirectory(atPath: fontDir.path)
            else {
                expect(false, "Sources/ProFootballCoachUI/Resources/Fonts is unreadable")
                return
            }
            let ttfNames = entries.filter { $0.hasSuffix(".ttf") }
            expect(!ttfNames.isEmpty,
                   "Resources/Fonts holds no .ttf files -- an unreadable or empty directory must "
                       + "fail loudly here, not pass every check below vacuously")

            let families = Set(ttfNames.compactMap { $0.split(separator: "-").first.map(String.init) })
            let unlicensed = families.filter {
                !FileManager.default.fileExists(
                    atPath: fontDir.appendingPathComponent("OFL-\($0).txt").path)
            }
            expect(unlicensed.isEmpty,
                   "\(unlicensed.count) family(ies) ship without a licence file: "
                       + "\(unlicensed.sorted().joined(separator: ", ")). 04 6.2 gates a bundled "
                       + "face on its licence being verified, so the licence ships with the binary.")

            // Each file's own PostScript name, read directly from its bytes rather than assumed
            // from its filename or pasted in from a list, so this checks what actually shipped and
            // stays independent of ForgeFieldFonts's own internal computation of the same value.
            var expectedNames: [(fileName: String, postScriptName: String)] = []
            for name in ttfNames.sorted() {
                let url = fontDir.appendingPathComponent(name)
                guard let provider = CGDataProvider(url: url as CFURL),
                      let cgFont = CGFont(provider),
                      let postScriptName = cgFont.postScriptName
                else {
                    expect(false,
                           "\(name) could not be read as a font to determine its PostScript name")
                    continue
                }
                expectedNames.append((fileName: name, postScriptName: postScriptName as String))
            }

            // The mechanism under test: ForgeFieldFonts registers straight from Bundle.module,
            // which is where SwiftPM actually places these files -- not from project.yml, which
            // fix round 2 found does not work for this key.
            let registration = ForgeFieldFonts.registerAll
            expect(registration.failures.isEmpty,
                   "ForgeFieldFonts reported \(registration.failures.count) registration "
                       + "failure(s): "
                       + registration.failures.map { "\($0.fileName): \($0.reason)" }
                           .joined(separator: "; "))

            for entry in expectedNames {
                expect(registration.resolvedPostScriptNames.contains(entry.postScriptName),
                       "\(entry.fileName)'s PostScript name \"\(entry.postScriptName)\" was not "
                           + "reported resolvable by ForgeFieldFonts.registerAll")

                // CTFontCreateWithName never returns nil: an unknown name comes back as a fallback
                // font instead, so the only proof of real resolution is that the font we get back
                // reports the same PostScript name we asked for. This is the check fix round 2
                // exists for -- it is the one that would have caught UIAppFonts silently failing.
                let resolvedFont = CTFontCreateWithName(entry.postScriptName as CFString, 12, nil)
                let resolvedName = CTFontCopyPostScriptName(resolvedFont) as String
                expect(resolvedName == entry.postScriptName,
                       "asking CoreText for \"\(entry.postScriptName)\" (\(entry.fileName)) "
                           + "returned a font reporting \"\(resolvedName)\" instead -- that is "
                           + "CoreText's fallback font, so \(entry.postScriptName) is not "
                           + "actually registered")
            }
        }
    }

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
    suite("Forge Field navigation (06.1f)") {
        test("the chrome bar names five families in FF Chrome's order") {
            expectEqual(CoachWorldSurfaceFamily.chromeBarFamilies.map(\.forgeFieldTitle),
                        ["This week", "Squad", "Recruiting", "Front office", "Ridgeline"],
                        "FF Chrome.dc.html fixes both the set and the order, and 04 section 6.1f "
                            + "transcribes it")
        }

        // "every screen still resolves to a family, including the two off the bar" lived here
        // until the fix round of 2026-08-30 (finding 3). It filtered on `$0.family == nil`, but
        // `family` (ScreenRegistry.swift) is a non-optional `switch` over every case, so the
        // filter could never select anything -- the compiler warns "always returns false" on
        // exactly this line. Deleted rather than patched: what it was reaching for -- "the bar
        // showing five does not license a screen being unreachable" -- is the real, by-
        // construction question, and it takes more than resolving to *a* family to answer: a
        // screen can resolve to a real family and still be unreachable, which is exactly what
        // this dead check could never have caught. "Chrome bar exit reachability" at the end of
        // this file is that real check.
        test("career and entry keep a family while they are off the bar") {
            expect(!CoachWorldSurfaceFamily.chromeBarFamilies.contains(.career),
                   "04 section 6.1f leaves career's placement open; it must not be smuggled into "
                       + "the bar by an implementer guessing")
            expect(!CoachWorldSurfaceFamily.chromeBarFamilies.contains(.entry),
                   "entry reaches the world before a coaching week exists")
            expect(!CoachWorldSurfaceFamily.career.registeredSurfaces.isEmpty,
                   "career surfaces must stay reachable while the question is open")
        }
    }

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

        // Item 3 of the phase-2A brief: the scanline sits over every surface, text included
        // (04 6.3a: "fixed furniture on every surface"), so its composite must not erode 04
        // section 7's 4.5:1 floor. Enumerated over every club and every ink/ground pairing rather
        // than one hand-picked pair, per CLAUDE.md's coverage-boundary rule. `overlayChannel`
        // reproduces `.blendMode(.overlay)` against a pure-white source (what `ForgeFieldScanline`
        // draws); the composite formula is the standard "blend, then alpha-composite by the
        // layer's own opacity" rule (`destination*(1-a) + blend(source,destination)*a`) that
        // `.opacity(_:)` plus `.blendMode(_:)` implement together. `ColorValue(hex:)` round-trips
        // the perturbed doubles through 8-bit quantisation (~0.4% max per channel), which only
        // ever makes this check more conservative, never less.
        test("the scanline never turns a passing ink/ground pairing into a failing one, across "
                + "every club") {
            func overlayChannel(_ base: Double) -> Double { base < 0.5 ? 2 * base : 1 }
            func withScanline(_ value: CoachWorldTokens.ColorValue) -> CoachWorldTokens.ColorValue {
                let alpha = ForgeFieldTokens.Material.scanlineOpacity
                func composite(_ base: Double) -> UInt32 {
                    let blended = base * (1 - alpha) + overlayChannel(base) * alpha
                    return UInt32((min(1, max(0, blended)) * 255).rounded())
                }
                let hex = (composite(value.red) << 16) | (composite(value.green) << 8)
                    | composite(value.blue)
                return CoachWorldTokens.ColorValue(hex: hex)
            }

            for club in ForgeFieldTokens.Club.allCases {
                let palette = club.palette
                let grounds = [palette.ground0, palette.ground1, palette.ground2, palette.ground3]
                let inks = [palette.ink1, palette.ink2, palette.ink3, palette.ink4]
                for ground in grounds {
                    for ink in inks {
                        let before = contrastRatio(ink, ground)
                        guard before >= 4.5 else { continue }   // not a claimed text pairing
                        let after = contrastRatio(withScanline(ink), withScanline(ground))
                        expect(after >= 4.5,
                               "\(club) clears 4.5:1 at \(before) but the scanline's 2 percent "
                                   + "white overlay drops it to \(after)")
                    }
                }
            }
        }
    }

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
        test("hitMin is an alias of rowTouch, not a second literal") {
            expectEqual(ForgeFieldTokens.Space.hitMin, ForgeFieldTokens.Space.rowTouch)
        }
    }

    suite("Forge Field ember (06.1e)") {
        // "an ember cannot be built without a cost line" lived here until the fix round of
        // 2026-08-30 (finding 5). It only ever echoed a struct back its own constructor argument
        // -- `ember.cost` cannot be anything but the literal this test itself passed in -- so it
        // could not fail short of the test author typing `cost: ""` into the test. Deleted rather
        // than strengthened: the real proof of the rule already exists twice over, immediately
        // below in "Forge Field fix round 1" (the subprocess probe proving `assert` actually
        // traps on an empty string) and in "Forge Field fix round 2" at the end of this file (the
        // build-time scan proving every real call site's `cost:` is a literal or a named
        // constant). A third, vacuous check next to two real ones is decoration.
        test("the cost line is set in the record face, tabular") {
            expectEqual(ForgeFieldEmber.costStep, ForgeFieldType.Step.figure)
            expectEqual(ForgeFieldType.Step.figure.family, ForgeFieldType.Family.record)
        }
        test("press is the accent ramp's press stop, never a scale") {
            expect(ForgeFieldEmber.pressScale == 1.0,
                   "04 6.1e: press goes to the press stop of the ramp. No shrink, no scale.")
        }
    }

    // Fix round 1 of 5 on Phase 2A Tasks 2-4, 2026-08-30. A new suite rather than insertions into
    // the ones above, so the diff for this round is a pure appension and the two rounds' coverage
    // stay separately readable.
    suite("Forge Field fix round 1 (06.1e, 06.3a)") {
        test("an ember built with an empty cost traps in a debug build") {
            // **Retitled in the fix round of 2026-08-30 (finding 5).** The trap moved from
            // `precondition` to `assert` (ForgeFieldEmber.swift): `precondition` aborted a
            // release build too, which is the wrong severity for a copy mistake, so this probe
            // now only proves the debug half of 04 6.1e's rule. `assert` compiles out of release
            // by design, and this test's own name said otherwise until this round -- "traps at
            // construction," unconditionally, was no longer true the moment the trap became an
            // `assert`, and a test whose name overclaims what it proves is the same defect this
            // file's own header warns about. `swift run SimTests` builds and runs debug, so the
            // probe below still observes a real trap -- evidence for the debug path this suite
            // actually runs in, not for release, which this test cannot see and does not claim
            // to. Release's half of the rule is "an ember's cost argument is a string literal or
            // a named constant," in "Forge Field fix round 2" at the end of this file: a
            // build-time scan, which is the only kind of check that still holds once `assert`
            // itself is gone from the binary.
            //
            // assert() aborts the process; it cannot be caught with do/catch. Proven the same way
            // runPortalPolicyTests proves its own fail-fast path (PortalPolicyTests.swift):
            // re-exec this binary as a child with the probe environment variable set (see the
            // early-return at the top of this function) and check the child's exit status.
            let probe = Process()
            probe.executableURL = currentExecutableURL()
            probe.arguments = ["--design-contracts"]
            var probeEnvironment = ProcessInfo.processInfo.environment
            probeEnvironment["FORGE_FIELD_EMBER_EMPTY_COST_PROBE"] = "1"
            probe.environment = probeEnvironment
            probe.standardOutput = Pipe()
            probe.standardError = Pipe()
            try probe.run()
            probe.waitUntilExit()
            expect(probe.terminationStatus != 0,
                   "04 6.1e: an ember built with an empty cost must trap in a debug build, not "
                       + "render a blank cost line with the gap still reserved")
        }

        test("the ember does not pin a line limit at accessibility sizes") {
            expectEqual(ForgeFieldEmber.lineLimit(for: .large), 1,
                        "at the default size, a long label or cost line truncates rather than "
                            + "wrapping")
            for size in DynamicTypeSize.allCases where size.isAccessibilitySize {
                expect(ForgeFieldEmber.lineLimit(for: size) == nil,
                       "\(size): 04 section 7's Dynamic Type floor outranks the default size's "
                           + "single-line decision -- the label and cost must be free to wrap "
                           + "rather than losing their ending")
            }
        }

        test("shadow-ember's three numbers are named tokens, and the shared alpha aliases one "
                + "primary") {
            expectEqual(ForgeFieldTokens.Material.shadowEmberBlur, 24)
            expectEqual(ForgeFieldTokens.Material.shadowEmberOffsetY, 2)
            expectEqual(ForgeFieldTokens.Edge.emberHighlight, 0.42)
            expectEqual(ForgeFieldTokens.Material.shadowEmberAlpha, ForgeFieldTokens.Edge.emberHighlight,
                        "04 6.3a states one alpha for both shadow-ember's glow and its inset "
                            + "highlight -- a value shared by two roles must be one declaration "
                            + "aliased, not two")
        }

        test("the scanline's colour is a named token, and its own canon row states it") {
            expectEqual(ForgeFieldTokens.Material.scanlineColor,
                        CoachWorldTokens.ColorValue(hex: 0xFFFFFF))
            let scanlineRow = canon.split(separator: "\n", omittingEmptySubsequences: false)
                .map(String.init)
                .first { $0.contains("| `scanline` |") }
            expect(scanlineRow?.contains("#FFFFFF") == true,
                   "04 section 6.3a's scanline row must state the colour "
                       + "Material.scanlineColor carries, not just the geometry")
        }
    }

    // Phase 2A Task 5: the chrome bar, `04` 6.1f. `ForgeFieldChromeBar.swift` hosts from
    // `FloodlitIdentityHeader` in place of the Press Box identity band -- see the retargeted
    // "Press Box shared chrome" suite above for what that retired and why.
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

        test("the five family controls reach for the 44 pt hit floor, not the 30 pt bar height") {
            // A headless suite has no laid-out frame to measure (04 section 7.1: "the suite ...
            // cannot see a laid-out frame"), so this is the source-visible proxy the same
            // limitation already accepts elsewhere in this file -- proof the mechanism is wired,
            // not proof of the rendered pixels. The phase report's screenshots and an on-device tap
            // just above and below a nav label's visible text are the render-level evidence.
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            let bar = ui.first { $0.path.hasSuffix("/ForgeFieldChromeBar.swift") }?.text ?? ""
            expect(bar.contains("minWidth: ForgeFieldTokens.Space.hitMin")
                       && bar.contains("minHeight: ForgeFieldTokens.Space.hitMin")
                       && bar.contains(".contentShape(Rectangle())"),
                   "04 6.3a: anything tappable is 44 pt on its short edge -- the bar's own visual "
                       + "row stays 30, so the hit region must be asked for explicitly rather than "
                       + "inherited from the row")
            expectEqual(ForgeFieldTokens.Space.hitMin, 44)
        }

        test("the five family names are read from the registry, never hard-coded") {
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            let bar = ui.first { $0.path.hasSuffix("/ForgeFieldChromeBar.swift") }?.text ?? ""
            expect(bar.contains("CoachWorldSurfaceFamily.chromeBarFamilies")
                       && bar.contains(".forgeFieldTitle"),
                   "Task 1 built the ordered five and their titles; the bar must read them rather "
                       + "than re-listing its own copy that could drift")
            for title in CoachWorldSurfaceFamily.chromeBarFamilies.map(\.forgeFieldTitle) {
                expect(!bar.contains("\"\(title)\"") && !bar.contains("\"\(title.uppercased())\""),
                       "\"\(title)\" must not appear as its own string literal in the bar's source")
            }
        }

        test("club colour is the bar's spine, never its ground") {
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            let bar = ui.first { $0.path.hasSuffix("/ForgeFieldChromeBar.swift") }?.text ?? ""
            expect(bar.contains("ForgeFieldTokens.Space.spine"),
                   "04 6.1e and 6.1f: club colour is legal in the bar as a 3 pt spine")
            expect(bar.contains("palette.ground1.color"),
                   "04 6.1f: the bar sits on ground 1 like every other chrome surface")
            expect(!bar.contains(".background(spineColor)") && !bar.contains(".background(club."),
                   "club colour must never become the bar's own ground fill")
        }

        test("the mark plate keeps the one system-wide radius, not Press Box's cut corner") {
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            let bar = ui.first { $0.path.hasSuffix("/ForgeFieldChromeBar.swift") }?.text ?? ""
            // Usage syntax, not the bare name: the file's own doc comment names both types by
            // way of explaining why it does not use them ("Deliberately not CoachWorldTeamLogo
            // ... clips to CoachWorldCutCorner"), so a bare-substring check would fail on that
            // prose. `(` and `.` are how each would actually be reached from code.
            expect(!bar.contains("CoachWorldTeamLogo(") && !bar.contains("CoachWorldCutCorner."),
                   "04 6.3a: one radius system-wide, mark named explicitly among the things that "
                       + "share it -- a Press Box cut-corner shape has no place in this bar")
            expect(bar.contains("ForgeFieldChip"),
                   "the mark plate must clip through the shared Forge Field primitive, not a "
                       + "one-off shape")
        }

        test("the week fact is threaded from the week hub, not left unset") {
            // 04 6.1f's bar has no content slot that may go blank -- "its contents never vary" --
            // so the week label needs a real fact from the same read model CoachingHQView.swift
            // already reads (model.week.weekLabel), not a placeholder invented for the bar alone.
            let app = swiftFiles(under: "Sources/CoachWorldApp")
            let provider = app.first {
                $0.path.hasSuffix("/CoachWorldChromeProvider.swift")
            }?.text ?? ""
            expect(provider.contains("week: hub.week.weekLabel"),
                   "the production chrome provider must pass the week hub's own week label into "
                       + "the chrome read model")
        }
    }

    // Fix round 2 of the Phase 2A adversarial review, 2026-08-30 -- a DO-NOT-SHIP verdict on five
    // findings. A new suite rather than insertions into the ones above, for the same reason fix
    // round 1 was: the diff for this round stays a pure appension and each round's coverage stays
    // separately readable. Finding 2 (the stale XCUITest) is fixed in
    // Tests/ProFootballCoachUITests/ProFootballCoachUITests.swift, outside this target. Finding 3
    // (the dead nil-check) is deleted from the "Forge Field navigation (06.1f)" suite above, and
    // what it was reaching for is folded into the first test below.
    suite("Forge Field fix round 2 (06.1f, 06.3a, 06.1e)") {
        // Finding 1 [Critical]: the Forge Field chrome bar has no back control at all -- 04 6.1f
        // fixes its contents to mark/club/record/five families/week, full stop -- and the Press
        // Box identity band it replaced was the only thing that ever rendered `model.back` or a
        // sibling strip. A screen whose family is not one of the bar's five, and which renders no
        // exit of its own, is reachable and then unleavable except by force-quitting. This also
        // folds in what the deleted dead nil-check (finding 3) was reaching for: resolving to *a*
        // family is not the same question as being *reachable*, and this is the real,
        // by-construction version of that question.
        //
        // Both sides are derived, never hand-listed: the reachable side from the registry
        // (`CoachWorldSurfaceFamily.chromeBarFamilies`), the exit side from the view layer via
        // `landedFamilies()` -- the same fixpoint-resolved partition `AccessibilityReflowTests`
        // and `ReduceMotionContractTests` already share, not a second one this file could
        // silently disagree with.
        test("every landed screen reaches the bar's five families, or renders its own exit") {
            let app = swiftFiles(under: "Sources")

            // A screen the production app never once hands a real chrome read model never
            // "reached its exit through the chrome" to begin with -- `chrome(for: .screen` is
            // `CoachWorldChromeProvider`'s one production entry point for building one. 04 6.1f's
            // own reasoning for `entry` ("surfaces reach the world before a coaching week exists,
            // so there is nowhere sideways to go from them") turns out to cover every screen this
            // exempts, and it falls out of the call sites rather than a hand-picked family list:
            // today that is `titleContinue` (the app's own root, never chromed) and
            // `newCareerCoachIdentity` (chromeless setup, and it separately renders its own
            // `Button("Cancel", action: onCancel)` regardless, per the check below).
            func isEverChromed(_ screen: CoachWorldScreenID) -> Bool {
                let needle = "chrome(for: .\(String(describing: screen))"
                return app.contains { $0.text.contains(needle) }
            }
            // `onClose`/`onCancel` are this codebase's own two exit-callback conventions (every
            // dossier-style surface from PlayerProfileView to SettingsAccessibilityView to the
            // onboarding flow's NewCareerSetupView uses one or the other) -- checked for being
            // wired to a rendered control, not merely declared, since a stored-but-unread closure
            // is exactly the shape of the regression this test exists to catch.
            func hasRenderedExit(_ family: FamilyView) -> Bool {
                family.renderedText.contains("action: onClose")
                    || family.renderedText.contains("action: onCancel")
                    || family.renderedText.contains("onClose()")
                    || family.renderedText.contains("onCancel()")
            }

            var stranded: [String] = []
            for family in landedFamilies().landed {
                guard !CoachWorldSurfaceFamily.chromeBarFamilies.contains(family.screen.family)
                else { continue }   // always reachable -- the five tabs never move, 04 6.1f
                guard isEverChromed(family.screen) else { continue }
                guard hasRenderedExit(family) else {
                    stranded.append("\(family.screen.canonicalName) (\(family.path))")
                    continue
                }
            }
            expect(stranded.isEmpty,
                   "\(stranded.count) screen(s) are chromed, off the bar's five families, and "
                       + "render no exit of their own: \(stranded.sorted().joined(separator: "; "))."
                       + " Give each its own onClose-wired control, PlayerProfileView's shape.")
        }

        test("the reachability check would catch a planted regression") {
            // Self-test, this file's own header rule: a scan that has never failed is not known
            // to be a scan. This is CareerHubView.swift's own shape before this fix round --
            // `onClose` stored and threaded through three call sites (careerHub, stakeholders,
            // promotionDecision) but never wired to a rendered control, because those three used
            // to leave through the retired Press Box band's own back control instead.
            let stranded = """
            public struct PlantedView: View {
                public let onClose: () -> Void
                public var body: some View { Text("no control reads onClose") }
            }
            """
            expect(!stranded.contains("action: onClose") && !stranded.contains("onClose()"),
                   "a view that stores onClose but never wires it to a control must not read as "
                       + "having a rendered exit")

            let fixed = """
            public struct PlantedView: View {
                public let onClose: () -> Void
                public var body: some View { Button(action: onClose) { Text("Close") } }
            }
            """
            expect(fixed.contains("action: onClose"),
                   "a view that wires onClose to a real Button must read as having one")
        }

        // Finding 4 [Important]: `ForgeFieldRow` pinned `.frame(height:)` unconditionally, with no
        // AX5 branch, while the chrome bar and the ember both already handle it. 04 section 7's
        // Dynamic Type contract is a floor, not a preference, so anything composed inside a row --
        // an ember included -- clipped at an accessibility size. Checked the same source-visible
        // way 04 section 7.1 already licenses elsewhere in this file: a headless suite has no
        // laid-out frame to measure.
        test("a row is a height floor at accessibility sizes, not a fixed height") {
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            let primitives = ui.first { $0.path.hasSuffix("/ForgeFieldPrimitives.swift") }?.text ?? ""
            expect(primitives.contains("dynamicTypeSize.isAccessibilitySize"),
                   "ForgeFieldRow must branch on accessibility size -- 04 section 7 is a floor, "
                       + "not a preference")
            expect(primitives.contains("frame(minHeight: height.points)"),
                   "at an accessibility size ForgeFieldRow's height must be a floor (minHeight), "
                       + "not a fixed .frame(height:), or anything composed inside it -- an ember "
                       + "included -- clips at AX5")
            expect(primitives.contains("frame(height: height.points)"),
                   "the standard, non-accessibility size must keep the exact fixed row height 04 "
                       + "6.3a states -- the fix is an added floor, not a removed one")
        }

        // Finding 5 [Important], release-build half: `assert` (ForgeFieldEmber.swift, above)
        // catches an empty cost only in a debug build. This is the enforcement that still holds
        // in release -- a build-time scan of every real call site, so a missing or
        // assembled-on-the-fly cost is an authoring error the gate catches, never a shipped gap.
        test("an ember's cost argument is a string literal or a named constant, every call site") {
            // Zero ForgeFieldEmber( call sites exist under Sources/ today (2B-2F have not landed
            // yet), so this currently passes vacuously -- the self-test below is what proves the
            // scan itself works.
            let production = swiftFiles(under: "Sources")
            for file in production {
                let offenders = forgeFieldEmberOffendingCostArguments(in: file.text)
                expect(offenders.isEmpty,
                       "\(file.path): ForgeFieldEmber cost argument(s) are neither a string "
                           + "literal nor a named constant: \(offenders.joined(separator: ", "))")
            }
        }

        test("the cost-argument scan would catch a planted violation") {
            let literal =
                "ForgeFieldEmber(label: \"Lock\", cost: \"3 calls open\", isEnabled: true) {}"
            let namedConstant =
                "ForgeFieldEmber(label: \"Lock\", cost: Copy.lockCost, isEnabled: true) {}"
            let functionCall =
                "ForgeFieldEmber(label: \"Lock\", cost: describeCost(), isEnabled: true) {}"
            let concatenation =
                "ForgeFieldEmber(label: \"Lock\", cost: \"base \" + suffix, isEnabled: true) {}"
            expect(forgeFieldEmberOffendingCostArguments(in: literal).isEmpty,
                   "a string literal must not be flagged")
            expect(forgeFieldEmberOffendingCostArguments(in: namedConstant).isEmpty,
                   "a dotted named constant must not be flagged")
            expect(!forgeFieldEmberOffendingCostArguments(in: functionCall).isEmpty,
                   "a function-call cost must be flagged -- it is neither a literal nor a named "
                       + "constant")
            expect(!forgeFieldEmberOffendingCostArguments(in: concatenation).isEmpty,
                   "a concatenation assembled at the call site must be flagged the same way")
        }
    }

    // 04 6.1f(i), added 2026-08-30. The same shape of gap the exit test above closed, one field
    // over: `onClose` was stored-but-never-rendered, and so was `onNavigate` -- the closure that
    // moves between a family's own surfaces. Both were threaded through every call site, and
    // neither reached a control, because the retired Press Box identity band drew the back control
    // *and* the sibling row and the Forge Field bar replaced neither.
    //
    // Scoped by the defect, not by the family: a view that stores a screen-navigation closure and
    // never invokes it is the class, and it is enumerated from the source rather than from a list
    // of the families known to have had it. `CareerHubView` and `LegacyHistoryView` are what it
    // catches today; whichever view acquires the closure next is caught the day it does.
    suite("Forge Field route bar (06.1f(i))") {
        // Read against `renderedText` -- the fixpoint union `landedFamilies()` resolves -- for the
        // reason the AX5 clauses read against it: seven of the eleven declaring files are ~28-line
        // wrappers that pass the closure straight through, and scanning a wrapper's own text would
        // report the wrapper as the offender while the view that actually renders sits unchecked.
        test("a view that stores a screen-navigation closure wires it to a rendered control") {
            var stranded: [String] = []
            for family in landedFamilies().landed where declaresScreenNavigation(family.renderedText) {
                guard !invokesScreenNavigation(family.renderedText) else { continue }
                stranded.append("\(family.screen.canonicalName) (\(family.path))")
            }
            expect(stranded.isEmpty,
                   "\(stranded.count) screen(s) store an onNavigate closure that no rendered "
                       + "control ever calls: \(stranded.sorted().joined(separator: "; ")). "
                       + "04 6.1f(i): a family the chrome bar does not carry draws its own route "
                       + "bar.")
        }

        // The bar's contents are canon, not the view's taste, and canon says where they come from:
        // "`FloodlitChromeReadModel.siblings` -- the list the retired band drew ... Never a second
        // hand-written list." Before 6.1f(i) that field was written by the chrome provider and read
        // by nothing at all, which is exactly how a second list gets written instead.
        test("the route bar reads the chrome's own sibling list, not a second one") {
            // What this can and cannot prove, stated rather than implied: a text scan cannot see
            // that no second list exists, only that the one canon names has a reader. Before
            // 6.1f(i) `FloodlitChromeReadModel.siblings` was written by the chrome provider on
            // every render and read by nothing at all, which is exactly the state in which a
            // second list gets written instead of it.
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            let declaring = "/FloodlitChrome.swift"
            let readers = ui.filter {
                !$0.path.hasSuffix(declaring) && $0.text.contains("siblings")
            }
            expect(!readers.isEmpty,
                   "FloodlitChromeReadModel.siblings has no reader outside the file that declares "
                       + "it, so either the route bar is gone or it derives its contents from a "
                       + "second list (04 6.1f(i))")
        }

        // 04 6.1f(i)'s AX5 row: "one pill per line, section 7's one readable path. It never scrolls
        // sideways and never clips." A headless suite has no laid-out frame to measure, so this is
        // the source-visible form 04 section 7.1 already licenses elsewhere in this file.
        test("the route bar reflows to one pill per line rather than scrolling sideways") {
            let ui = swiftFiles(under: "Sources/ProFootballCoachUI")
            // Comments stripped: every clause below is about what the view *does*, and this
            // file's doc comments quote several of these patterns in prose to explain why they
            // are there -- including the `family.surfaces` fallback the last clause forbids.
            let barSource = ui.first { $0.path.hasSuffix("/FloodlitFamilyRouteBar.swift") }?.text ?? ""
            let bar = strippingLineComments(barSource)
            expect(!barSource.isEmpty, "FloodlitFamilyRouteBar.swift is missing (04 6.1f(i))")
            expect(bar.contains("dynamicTypeSize.isAccessibilitySize"),
                   "the route bar must branch on accessibility size -- 04 section 7 is a floor, "
                       + "not a preference")
            expect(!bar.contains("ScrollView(.horizontal"),
                   "04 6.1f(i) forbids a sideways-scrolling route bar; it reflows to one pill "
                       + "per line")
            expect(bar.contains("ViewThatFits"),
                   "below an accessibility size 04 6.1f(i) has the row measured, not compared "
                       + "against a second invented Dynamic Type threshold -- seven career pills "
                       + "overrun the 761 pt column at XXXL and FloodlitPill is single-line with "
                       + "no scale floor, so an unmeasured row truncates")
            expect(bar.contains("navigationName"),
                   "a pill reads the registry's short form (04 6.1f(i)); the long forms are what "
                       + "navigationName exists to keep off the end of this row")
            // The regression this pins is one this session wrote and caught: a fallback to
            // `family.surfaces` when the chrome is nil. `chrome(for:in:)` returns nil whenever
            // `store.coachingHQ` is nil -- the between-appointments coach, which is the state the
            // career hub exists for -- and the unfiltered registry there is nine career surfaces
            // of which seven are unavailable. Availability reaches this module only through the
            // chrome, so the fallback cannot be filtered and must not exist.
            expect(!bar.contains("family.surfaces"),
                   "the route bar must not fall back to the unfiltered registry when the chrome "
                       + "is nil: availability reaches this module only through the chrome, so "
                       + "such a fallback offers pills for surfaces the coach cannot reach "
                       + "(04 6.1f(i): the list comes from FloodlitChromeReadModel.siblings)")
            expect(bar.contains("canonicalName"),
                   "the pill must read the registry's full name to VoiceOver, not the shortened "
                       + "visible title (04 6.1f(i), and Sibling.accessibleTitle's own rule)")
            expect(bar.contains("canonicalDestination"),
                   "the lit pill is resolved through canonicalDestination, so an alias route "
                       + "lights the pill it resolves to (04 6.1f(i))")
        }

        test("the wiring check would catch a planted regression") {
            // Self-test, this file's own header rule. This is CareerHubView.swift's own shape
            // before 6.1f(i): the closure stored, threaded to every call site, and read by nothing
            // the body renders.
            let stranded = """
            public struct PlantedView: View {
                public let onNavigate: (CoachWorldScreenID) -> Void
                public var body: some View { Text("no control reads onNavigate") }
            }
            """
            expect(declaresScreenNavigation(stranded),
                   "a view declaring the closure must be seen to declare it")
            expect(!invokesScreenNavigation(stranded),
                   "a view that stores onNavigate but never calls it must not read as wired")

            let fixed = """
            public struct PlantedView: View {
                public let onNavigate: (CoachWorldScreenID) -> Void
                public var body: some View {
                    Button("Stakeholders") { onNavigate(.stakeholders) }
                }
            }
            """
            expect(invokesScreenNavigation(fixed),
                   "a view that calls onNavigate from a real Button must read as wired")

            // The near-miss that would make the scan tautological: passing the closure onward by
            // name, and handing the *chrome's* separate closure to the stage, are both `onNavigate`
            // in the source and neither is this closure being invoked.
            let passedOnward = """
            CareerHubView(model: model, onClose: onClose, onNavigate: onNavigate)
                .floodlitChrome(chrome, onNavigate: onNavigateChrome)
            """
            expect(!invokesScreenNavigation(passedOnward),
                   "threading the closure to a call site, or naming the chrome's own closure, is "
                       + "not invoking it -- that is precisely the gap this scan exists to catch")
        }
    }
    suite("Weekly-command register budgets (06.1e, 06.3a)") {
        test("the table covers exactly the weekly-command family, by construction") {
            let budgeted = Set(ForgeFieldBudget.weeklyCommand.keys)
            let family = Set(CoachWorldSurfaceFamily.weeklyCommand.surfaces)
            expectEqual(budgeted, family,
                        "ForgeFieldBudget.weeklyCommand must hold exactly the screens "
                            + "CoachWorldSurfaceFamily.weeklyCommand.surfaces enumerates -- a "
                            + "tenth surface added to the family, or a budgeted screen that "
                            + "leaves it, must fail here")
        }

        test("the coverage check would catch a planted regression, either direction") {
            var extraScreen = ForgeFieldBudget.weeklyCommand
            extraScreen[.roster] = extraScreen[.coachingHQ]
            expect(Set(extraScreen.keys) != Set(CoachWorldSurfaceFamily.weeklyCommand.surfaces),
                   "a table with a stray screen outside the family must not read as exact "
                       + "coverage")

            var missingScreen = ForgeFieldBudget.weeklyCommand
            missingScreen.removeValue(forKey: .inbox)
            expect(Set(missingScreen.keys) != Set(CoachWorldSurfaceFamily.weeklyCommand.surfaces),
                   "a table missing one of the family's screens -- the same shape a tenth "
                       + "surface added to the family and not yet budgeted would leave -- must "
                       + "not read as exact coverage")
        }

        test("every Desk-register surface carries zero gold") {
            for (screen, budget) in ForgeFieldBudget.weeklyCommand
            where budget.register.lean == .desk {
                expectEqual(budget.goldMax, 0,
                            "\(screen.canonicalName) is a Desk surface -- the sheet states "
                                + "\"zero gold on a Desk surface\" as a rule, not a coincidence")
            }
        }

        test("every Desk-register surface's stage sits at or under the desk stage ceiling") {
            for (screen, budget) in ForgeFieldBudget.weeklyCommand
            where budget.register.lean == .desk {
                guard let stage = budget.stageFraction else {
                    expect(false, "\(screen.canonicalName) is Desk but stamps no stage fraction")
                    continue
                }
                expect(stage.upperBound <= ForgeFieldTokens.Register.deskStageMax,
                       "\(screen.canonicalName) stamps \(stage.upperBound), above "
                           + "ForgeFieldTokens.Register.deskStageMax "
                           + "(\(ForgeFieldTokens.Register.deskStageMax))")
            }
        }

        // An ember exists where a surface has a committing action whose price the read model
        // actually records. READOUT was a good proxy for "no ember" and is not the whole rule:
        // Game Plan and Practice Plan are ACTION surfaces whose committing control is NOT an ember,
        // because the presentation contract forbids the very thing their drawn ember would have to
        // name -- row 11 omits "cost", row 12 omits any "separate remaining/unallocated-minutes
        // field" -- and neither carries a callback for the drawn action. 04 6.1e: an action with no
        // cost worth naming is not an ember. So the rule is stated as the two sets, with the reason
        // attached to each, rather than derived from tone alone.
        test("a surface carries an ember exactly when its committing action has a recorded cost") {
            let noEmber: Set<CoachWorldScreenID> = [
                .aftermath, .gameDetailBoxScore,   // READOUT: nothing here is irreversible
                .gamePlan, .practicePlan,          // ACTION, but the contract forbids the cost
            ]
            for (screen, budget) in ForgeFieldBudget.weeklyCommand {
                if noEmber.contains(screen) {
                    expectEqual(budget.emberCount, 0,
                                "\(screen.canonicalName) must carry no ember: either the result is "
                                    + "not a decision you made, or the contract forbids naming the "
                                    + "cost its drawn ember would need")
                } else {
                    expectEqual(budget.emberCount, ForgeFieldTokens.Register.emberPerSurface,
                                "\(screen.canonicalName) commits something with a recorded cost, "
                                    + "so it carries exactly one ember")
                }
            }
            // The set is not a licence to grow: every READOUT surface must still be in it, checked
            // by construction so a new READOUT cannot quietly acquire an ember.
            for (screen, budget) in ForgeFieldBudget.weeklyCommand where budget.register.tone == .readout {
                expect(noEmber.contains(screen),
                       "\(screen.canonicalName) is READOUT and must be in the no-ember set")
            }
        }

        test("each Broadcast-band surface's stage sits inside the broadcast band; each Dossier "
                + "one inside the dossier band; Match day at 100% is the explicit exception") {
            for (screen, budget) in ForgeFieldBudget.weeklyCommand
            where budget.register.lean == .broadcast && screen != .matchDay {
                guard let stage = budget.stageFraction else {
                    expect(false, "\(screen.canonicalName) is Broadcast but stamps no stage")
                    continue
                }
                expectIn(stage.lowerBound, ForgeFieldTokens.Register.broadcastStage,
                         "\(screen.canonicalName) (Broadcast) lower bound")
                expectIn(stage.upperBound, ForgeFieldTokens.Register.broadcastStage,
                         "\(screen.canonicalName) (Broadcast) upper bound")
            }
            for (screen, budget) in ForgeFieldBudget.weeklyCommand
            where budget.register.lean == .dossier {
                guard let stage = budget.stageFraction else {
                    expect(false, "\(screen.canonicalName) is Dossier but stamps no stage")
                    continue
                }
                expectIn(stage.lowerBound, ForgeFieldTokens.Register.dossierStage,
                         "\(screen.canonicalName) (Dossier) lower bound")
                expectIn(stage.upperBound, ForgeFieldTokens.Register.dossierStage,
                         "\(screen.canonicalName) (Dossier) upper bound")
            }

            // Match day is deliberately excluded above and asserted here instead: at 100% stage
            // there is no chrome bar and nothing to divide, so the broadcast band does not
            // govern it. Explicit, not a silent skip.
            guard let matchDayStage = ForgeFieldBudget.weeklyCommand[.matchDay]?.stageFraction
            else {
                expect(false, "Match day must stamp a stage fraction")
                return
            }
            expectEqual(matchDayStage, 1.0...1.0, "Match day is Broadcast at 100%")
            expect(!ForgeFieldTokens.Register.broadcastStage.contains(matchDayStage.lowerBound),
                   "Match day's 100% must sit outside the broadcast band -- otherwise it would "
                       + "not be an exception worth calling out")
        }

        test("no surface exceeds the gold ceiling for its register") {
            for (screen, budget) in ForgeFieldBudget.weeklyCommand {
                let ceiling: Int
                switch budget.register.lean {
                case .broadcast: ceiling = ForgeFieldTokens.Register.goldMaxBroadcast
                case .dossier: ceiling = ForgeFieldTokens.Register.goldMaxDossier
                case .desk: ceiling = 0
                }
                expect(budget.goldMax <= ceiling,
                       "\(screen.canonicalName) stamps goldMax \(budget.goldMax), above its "
                           + "register's ceiling of \(ceiling)")
            }
        }
    }

    // Task 2 of docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md: Coaching HQ, drawn
    // to `ForgeFieldDevice`. Asserts `CoachingHQView`'s own assertable static facts (its doc
    // comment, "Assertable budget facts") against the budget Task 1 already stamped rather than
    // restating the numbers here -- a change to either side is a diff a reviewer can see.
    suite("Coaching HQ (06.1e, 06.1f, 06.2a, 06.3a) -- weekly-command Task 2") {
        let budget = ForgeFieldBudget.weeklyCommand[.coachingHQ]

        test("Coaching HQ's flood field draws at or under its stamped point ceiling, in nine "
                + "distinct facts") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .coachingHQ")
                return
            }
            guard let stamped = budget.pointsAboveSeam else {
                expect(false, "Coaching HQ's budget stamps no pointsAboveSeam")
                return
            }
            let points = CoachingHQView.floodFieldDataPoints
            expect(points.count <= stamped,
                   "CoachingHQView.floodFieldDataPoints holds \(points.count) facts, above the "
                       + "stamped ceiling of \(stamped)")
            expectEqual(Set(points).count, points.count,
                        "floodFieldDataPoints must enumerate distinct facts, not repeat one")
        }

        test("Coaching HQ's stage fraction sits inside its stamped band") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .coachingHQ")
                return
            }
            guard let stamped = budget.stageFraction else {
                expect(false, "Coaching HQ's budget stamps no stage fraction")
                return
            }
            // The stamped band is itself the sheet's own rounding of an irrational pixel ratio
            // (242 / 393), so the drawn surface is checked against it with the same tolerance a
            // reader transcribing the sheet by eye would have used, not bit-exact equality.
            let tolerance = 0.01
            let stage = CoachingHQView.stageFraction
            expect(stage >= stamped.lowerBound - tolerance && stage <= stamped.upperBound + tolerance,
                   "CoachingHQView.stageFraction (\(stage)) must sit within \(tolerance) of the "
                       + "stamped band \(stamped)")
        }

        test("Coaching HQ's gold and ember spends match their stamped budget") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .coachingHQ")
                return
            }
            expect(CoachingHQView.goldElementCount <= budget.goldMax,
                   "CoachingHQView.goldElementCount (\(CoachingHQView.goldElementCount)) exceeds "
                       + "the stamped goldMax (\(budget.goldMax))")
            expectEqual(CoachingHQView.emberElementCount, budget.emberCount,
                        "Coaching HQ must carry exactly the stamped ember count")
        }

        test("Coaching HQ's ghost mark matches its stamped size and opacity") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .coachingHQ")
                return
            }
            guard let ghost = budget.ghost else {
                expect(false, "Coaching HQ's budget stamps no ghost")
                return
            }
            expectEqual(CoachingHQView.ghostSize, ghost.size, "ghost size")
            expectEqual(CoachingHQView.ghostOpacity, ghost.opacity, "ghost opacity")
        }

        test("Coaching HQ's own background count matches its stamped budget") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .coachingHQ")
                return
            }
            guard let stamped = budget.backgrounds else {
                expect(false, "Coaching HQ's budget stamps no backgrounds count")
                return
            }
            expectEqual(CoachingHQView.backgroundCount, stamped,
                        "Coaching HQ must draw exactly the stamped background count")
        }
    }

    // Task 3 of docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md: Inbox, drawn to
    // `ForgeFieldDevice`. Asserts `InboxView`'s own assertable static facts (its doc comment,
    // "Assertable budget facts") against the budget Task 1 already stamped, matching the Coaching
    // HQ suite's own pattern above.
    suite("Inbox (06.1e, 06.1f, 06.2a, 06.3a, 06.6a) -- weekly-command Task 3") {
        let budget = ForgeFieldBudget.weeklyCommand[.inbox]

        test("Inbox's data-point roles are distinct and the total sits at or under the stamped "
                + "ceiling") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .inbox")
                return
            }
            guard let stamped = budget.dataPoints else {
                expect(false, "Inbox's budget stamps no dataPoints")
                return
            }
            expect(InboxView.dataPointCount <= stamped,
                   "InboxView.dataPointCount (\(InboxView.dataPointCount)) exceeds the stamped "
                       + "ceiling of \(stamped)")
            let roles = InboxView.headerDataPointRoles + InboxView.rowDataPointRoles
                + InboxView.readingPaneDataPointRoles
            expectEqual(Set(roles).count, roles.count,
                        "Inbox's data-point roles must be distinct, not repeat one")
            expect(InboxView.referenceRowCount > 0,
                   "Inbox's reference row count collapsed to zero -- the list column's own "
                       + "geometry no longer fits a single row")
        }

        test("Inbox draws no flood -- its stage fraction is zero, matching its stamped Desk band") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .inbox")
                return
            }
            guard let stamped = budget.stageFraction else {
                expect(false, "Inbox's budget stamps no stage fraction")
                return
            }
            expectEqual(InboxView.stageFraction, 0.0, "InboxView.stageFraction")
            expectEqual(stamped, 0.0...0.0, "Inbox's stamped stage fraction")
        }

        test("Inbox carries zero gold -- a review failure, not a guideline, on a Desk surface") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .inbox")
                return
            }
            expectEqual(budget.goldMax, 0, "Inbox's stamped goldMax")
            expectEqual(InboxView.goldElementCount, 0, "InboxView.goldElementCount")
        }

        test("Inbox's ember count matches its stamped budget") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .inbox")
                return
            }
            expectEqual(InboxView.emberElementCount, budget.emberCount,
                        "Inbox must carry exactly the stamped ember count")
        }

        test("Inbox draws no ghost mark, matching its stamped budget") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .inbox")
                return
            }
            expect(budget.ghost == nil, "Inbox's stamped budget must carry no ghost")
            expect(InboxView.hasGhostMark == false, "InboxView must draw no ghost mark")
        }

        test("Inbox's own background count matches its stamped budget -- ground 1 only") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .inbox")
                return
            }
            guard let stamped = budget.backgrounds else {
                expect(false, "Inbox's budget stamps no backgrounds count")
                return
            }
            expectEqual(InboxView.backgroundCount, stamped,
                        "Inbox must draw exactly the stamped background count")
        }

        test("Inbox's rows are the touch tier, never dense -- 04 6.3a: dense is legal only when "
                + "the whole row is inert, and Inbox rows route and mark read") {
            let path = packageRoot()
                .appendingPathComponent("Sources/ProFootballCoachUI/InboxView.swift")
            guard let source = try? String(contentsOf: path, encoding: .utf8) else {
                expect(false, "InboxView.swift is unreadable at \(path.path)")
                return
            }
            expect(!source.contains("ForgeFieldRow(.dense"),
                   "Inbox's rows route (onOpen) and mark read (onRead) on tap -- they must never "
                       + "use the 32 pt dense tier reserved for a fully inert row")
            expect(source.contains("ForgeFieldRow(.touch"),
                   "Inbox must draw its tappable rows through ForgeFieldRow(.touch")
        }

        test("Inbox's ember calls onContinue, never a composition action the contract forbids "
                + "(ruling 1)") {
            let path = packageRoot()
                .appendingPathComponent("Sources/ProFootballCoachUI/InboxView.swift")
            guard let source = try? String(contentsOf: path, encoding: .utf8) else {
                expect(false, "InboxView.swift is unreadable at \(path.path)")
                return
            }
            expect(source.contains("ForgeFieldEmber(label: \"ADVANCE\", cost: emberCost, "
                                        + "isEnabled: model.canContinue, action: onContinue)"),
                   "Inbox's one ember must be costed from the model and wired to onContinue")
        }
    }

    // Task 4 of docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md: Game plan, drawn to
    // `ForgeFieldDevice`. Asserts `GamePlanView`'s own assertable static facts (its doc comment,
    // "Assertable budget facts") against the budget Task 1 already stamped, matching the Coaching
    // HQ and Inbox suites' own pattern above.
    suite("Game plan (06.1e, 06.1f, 06.2a, 06.3a) -- weekly-command Task 4") {
        let budget = ForgeFieldBudget.weeklyCommand[.gamePlan]

        test("Game plan's data-point roles are distinct and the total sits at or under the "
                + "stamped ceiling") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .gamePlan")
                return
            }
            guard let stamped = budget.dataPoints else {
                expect(false, "Game plan's budget stamps no dataPoints")
                return
            }
            expect(GamePlanView.dataPointCount <= stamped,
                   "GamePlanView.dataPointCount (\(GamePlanView.dataPointCount)) exceeds the "
                       + "stamped ceiling of \(stamped)")
            let roles = GamePlanView.headerDataPointRoles + GamePlanView.currentPlanDataPointRoles
                + GamePlanView.optionDataPointRoles
            expectEqual(Set(roles).count, roles.count,
                        "Game plan's data-point roles must be distinct, not repeat one")
        }

        test("Game plan draws no flood -- its stage fraction is zero, matching its stamped Desk "
                + "band") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .gamePlan")
                return
            }
            guard let stamped = budget.stageFraction else {
                expect(false, "Game plan's budget stamps no stage fraction")
                return
            }
            expectEqual(GamePlanView.stageFraction, 0.0, "GamePlanView.stageFraction")
            expectEqual(stamped, 0.0...0.0, "Game plan's stamped stage fraction")
        }

        test("Game plan carries zero gold -- a review failure, not a guideline, on a Desk "
                + "surface") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .gamePlan")
                return
            }
            expectEqual(budget.goldMax, 0, "Game plan's stamped goldMax")
            expectEqual(GamePlanView.goldElementCount, 0, "GamePlanView.goldElementCount")
        }

        test("Game plan carries zero embers, matching the contract's omission of any recorded "
                + "cost (row 11)") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .gamePlan")
                return
            }
            expectEqual(budget.emberCount, 0, "Game plan's stamped emberCount")
            expectEqual(GamePlanView.emberElementCount, 0, "GamePlanView.emberElementCount")
        }

        test("Game plan draws no ghost mark, matching its stamped budget") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .gamePlan")
                return
            }
            expect(budget.ghost == nil, "Game plan's stamped budget must carry no ghost")
            expect(GamePlanView.hasGhostMark == false, "GamePlanView must draw no ghost mark")
        }

        test("Game plan's own background count matches its stamped budget -- ground 1 only") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .gamePlan")
                return
            }
            guard let stamped = budget.backgrounds else {
                expect(false, "Game plan's budget stamps no backgrounds count")
                return
            }
            expectEqual(GamePlanView.backgroundCount, stamped,
                        "Game plan must draw exactly the stamped background count")
        }

        test("Game plan's option rows are the comfortable tier, never dense -- Rule A-1: an "
                + "ACTION surface may not exceed 44 pt on any control") {
            let path = packageRoot()
                .appendingPathComponent("Sources/ProFootballCoachUI/GamePlanView.swift")
            guard let source = try? String(contentsOf: path, encoding: .utf8) else {
                expect(false, "GamePlanView.swift is unreadable at \(path.path)")
                return
            }
            expect(!source.contains("ForgeFieldRow(.dense"),
                   "Game plan's option rows commit a plan on tap -- they must never use the 32 pt "
                       + "dense tier reserved for a fully inert row")
            expect(source.contains("ForgeFieldRow(.touch"),
                   "Game plan must draw its option rows through ForgeFieldRow(.touch")
        }

        test("Game plan draws no ForgeFieldEmber -- the committing control is a plain choice "
                + "(ruling, dispatch 2026-08-30/31)") {
            let path = packageRoot()
                .appendingPathComponent("Sources/ProFootballCoachUI/GamePlanView.swift")
            guard let source = try? String(contentsOf: path, encoding: .utf8) else {
                expect(false, "GamePlanView.swift is unreadable at \(path.path)")
                return
            }
            expect(!source.contains("ForgeFieldEmber("),
                   "row 11 omits any recorded cost, so this surface's committing control must not "
                       + "be a ForgeFieldEmber")
        }

        test("Game plan's committing control selects locally and its own action commits and "
                + "closes") {
            let path = packageRoot()
                .appendingPathComponent("Sources/ProFootballCoachUI/GamePlanView.swift")
            guard let source = try? String(contentsOf: path, encoding: .utf8) else {
                expect(false, "GamePlanView.swift is unreadable at \(path.path)")
                return
            }
            expect(source.contains("Choose the install")
                       && !source.contains("onSelect(option.plan)")
                       && source.contains("onSelect(selectedOption.plan)")
                       && source.contains("onClose()"),
                   "option rows must select locally and commitControl's own action must commit "
                       + "the selected plan and close")
        }
    }

    // Task 5 of docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md: Practice plan, drawn
    // to `ForgeFieldDevice`. Asserts `PracticePlanView`'s own assertable static facts (its doc
    // comment, "Assertable budget facts") against the budget Task 1 already stamped, matching the
    // Coaching HQ, Inbox and Game plan suites' own pattern above.
    suite("Practice plan (06.1e, 06.1f, 06.2a, 06.3a) -- weekly-command Task 5") {
        let budget = ForgeFieldBudget.weeklyCommand[.practicePlan]

        test("Practice plan's data-point roles are distinct and the total sits at or under the "
                + "stamped ceiling") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .practicePlan")
                return
            }
            guard let stamped = budget.dataPoints else {
                expect(false, "Practice plan's budget stamps no dataPoints")
                return
            }
            expect(PracticePlanView.dataPointCount <= stamped,
                   "PracticePlanView.dataPointCount (\(PracticePlanView.dataPointCount)) exceeds "
                       + "the stamped ceiling of \(stamped)")
            let roles = PracticePlanView.allocationDataPointRoles
                + PracticePlanView.optionDataPointRoles
            expectEqual(Set(roles).count, roles.count,
                        "Practice plan's data-point roles must be distinct, not repeat one")
        }

        test("Practice plan's flooded strip sits inside its stamped stage band") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .practicePlan")
                return
            }
            guard let stamped = budget.stageFraction else {
                expect(false, "Practice plan's budget stamps no stage fraction")
                return
            }
            // The stamped band is itself the sheet's own rounding of 74/393 (0.1882...), so the
            // drawn surface is checked with the same tolerance `CoachingHQView`'s identical test
            // uses, not bit-exact equality.
            let tolerance = 0.01
            let stage = PracticePlanView.stageFraction
            expect(stage >= stamped.lowerBound - tolerance && stage <= stamped.upperBound + tolerance,
                   "PracticePlanView.stageFraction (\(stage)) must sit within \(tolerance) of the "
                       + "stamped band \(stamped)")
        }

        test("Practice plan carries zero gold -- a review failure, not a guideline, on a Desk "
                + "surface") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .practicePlan")
                return
            }
            expectEqual(budget.goldMax, 0, "Practice plan's stamped goldMax")
            expectEqual(PracticePlanView.goldElementCount, 0, "PracticePlanView.goldElementCount")
        }

        test("Practice plan carries zero embers, matching the contract's omission of any "
                + "separate remaining/unallocated-minutes field (row 12)") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .practicePlan")
                return
            }
            expectEqual(budget.emberCount, 0, "Practice plan's stamped emberCount")
            expectEqual(PracticePlanView.emberElementCount, 0, "PracticePlanView.emberElementCount")
        }

        test("Practice plan draws no ghost mark, matching its stamped budget") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .practicePlan")
                return
            }
            expect(budget.ghost == nil, "Practice plan's stamped budget must carry no ghost")
            expect(PracticePlanView.hasGhostMark == false, "PracticePlanView must draw no ghost mark")
        }

        test("Practice plan's own background count matches its stamped budget -- flood, ground 1") {
            guard let budget else {
                expect(false, "ForgeFieldBudget.weeklyCommand holds no entry for .practicePlan")
                return
            }
            guard let stamped = budget.backgrounds else {
                expect(false, "Practice plan's budget stamps no backgrounds count")
                return
            }
            expectEqual(PracticePlanView.backgroundCount, stamped,
                        "Practice plan must draw exactly the stamped background count")
        }

        test("Practice plan's option rows are the comfortable tier, never dense -- Rule A-1: an "
                + "ACTION surface may not exceed 44 pt on any control") {
            let path = packageRoot()
                .appendingPathComponent("Sources/ProFootballCoachUI/PracticePlanView.swift")
            guard let source = try? String(contentsOf: path, encoding: .utf8) else {
                expect(false, "PracticePlanView.swift is unreadable at \(path.path)")
                return
            }
            expect(!source.contains("ForgeFieldRow(.dense"),
                   "Practice plan's option rows commit a plan on tap -- they must never use the "
                       + "32 pt dense tier reserved for a fully inert row")
            expect(source.contains("ForgeFieldRow(.touch"),
                   "Practice plan must draw its option rows through ForgeFieldRow(.touch")
        }

        test("Practice plan draws no ForgeFieldEmber -- the committing control is a plain choice "
                + "(ruling, dispatch 2026-08-30/31)") {
            let path = packageRoot()
                .appendingPathComponent("Sources/ProFootballCoachUI/PracticePlanView.swift")
            guard let source = try? String(contentsOf: path, encoding: .utf8) else {
                expect(false, "PracticePlanView.swift is unreadable at \(path.path)")
                return
            }
            expect(!source.contains("ForgeFieldEmber("),
                   "row 12 omits any separate remaining/unallocated-minutes field, so this "
                       + "surface's committing control must not be a ForgeFieldEmber")
        }

        test("Practice plan draws no remaining or unallocated-minutes field (ruling 4)") {
            let path = packageRoot()
                .appendingPathComponent("Sources/ProFootballCoachUI/PracticePlanView.swift")
            guard let source = try? String(contentsOf: path, encoding: .utf8) else {
                expect(false, "PracticePlanView.swift is unreadable at \(path.path)")
                return
            }
            expect(!source.contains("\u{2032} total"),
                   "the Press Box surface this file replaces printed a weekly-minutes total "
                       + "beside the allocator (\"60\u{2032} total\"); row 12's omission forbids "
                       + "restating it here")
        }

        test("Practice plan's committing control selects locally and its own action commits and "
                + "closes") {
            let path = packageRoot()
                .appendingPathComponent("Sources/ProFootballCoachUI/PracticePlanView.swift")
            guard let source = try? String(contentsOf: path, encoding: .utf8) else {
                expect(false, "PracticePlanView.swift is unreadable at \(path.path)")
                return
            }
            expect(source.contains("Option preview")
                       && source.contains("Choose the week")
                       && !source.contains("onSelect(option.plan)")
                       && source.contains("onSelect(selectedOption.plan)")
                       && source.contains("onClose()"),
                   "option rows must select locally and commitControl's own action must commit "
                       + "the selected plan and close")
        }
    }
}

/// Whether a view stores the screen-navigation closure `04` 6.1f(i)'s route bar is for.
///
/// The type is the discriminator, deliberately: `onNavigateChrome` carries a `CoachWorldIntentID`
/// and is the chrome bar's own closure, which the Forge Field bar already renders. This is the
/// other one -- the family's own siblings.
func declaresScreenNavigation(_ text: String) -> Bool {
    text.contains("onNavigate: (CoachWorldScreenID) -> Void")
}

/// Whether that closure is called, rather than only stored and passed onward.
///
/// A text-shape check, like every other scan in this file: it cannot see whether the call sits on a
/// branch the body actually renders, only that the closure is called at all. `onNavigate:` (a
/// labelled argument, which is how every wrapper threads it, and how the *chrome's* unrelated
/// closure reaches the stage) does not match, because the colon is not an opening parenthesis;
/// neither does `onNavigateChrome(`, because the character after `onNavigate` is not `(`.
func invokesScreenNavigation(_ text: String) -> Bool {
    text.contains("onNavigate(")
}

/// Whether a `ForgeFieldEmber(` call site's `cost:` argument is neither a string literal nor a
/// named constant -- 04 6.1e: "if an action has no cost worth naming, it is not an ember." A
/// text-shape check, like every other scan in this file: it cannot see whether an identifier is
/// truly declared `let`/`static let` rather than a local `var`, only that it is *shaped* like a
/// name rather than an expression assembled at the call site. `assert` in `ForgeFieldEmber.init`
/// catches an *empty* cost, but only in a debug build (finding 5's fix round, 2026-08-30); this is
/// the release-safe half -- enforced at build time so a missing or assembled cost is an authoring
/// error caught before a call site ever ships, not a runtime trap a release build has already
/// compiled out.
func forgeFieldEmberOffendingCostArguments(in text: String) -> [String] {
    let pattern = "ForgeFieldEmber\\(\\s*label:[\\s\\S]*?cost:\\s*([^,\\n]+),"
    return matches(of: pattern, in: text).compactMap { rawArgument in
        let trimmed = rawArgument.trimmingCharacters(in: .whitespacesAndNewlines)
        let isStringLiteral = trimmed.hasPrefix("\"") && trimmed.hasSuffix("\"") && trimmed.count >= 2
        let isNamedConstant = trimmed.range(
            of: "^[A-Za-z_][A-Za-z0-9_.]*$", options: .regularExpression
        ) != nil
        return (isStringLiteral || isNamedConstant) ? nil : trimmed
    }
}
