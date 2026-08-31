import SwiftUI

/// Game detail / box score, drawn to the Forge Field sheet.
///
/// **Register: Dossier, READOUT, with a VERTICAL seam.** The one surface in the weekly-command
/// family whose seam runs down rather than across: the staged half is the result, on the left, and
/// the studied half is the evidence for it, on the right. The sheet stamps the stage at 32 percent
/// measured across the seam axis -- 271 of 852 -- so the staged column is 271 pt wide and the
/// hairline falls at its trailing edge.
///
/// **Zero embers, and no committing control of any kind.** The presentation contract's row 47 gives
/// this surface `onClose` and `onNavigateChrome` and nothing else -- there is no `onContinue` here,
/// unlike Aftermath. Under `04` 6.1e an action with no cost worth naming is not an ember, and here
/// there is no action at all. `ForgeFieldBudget.weeklyCommand[.gameDetailBoxScore]` records
/// `emberCount: 0` and a test enforces it.
///
/// **Zero gold, against a ceiling of two.** The sheet is explicit: *"gold 0 of 2 -- a record is not
/// a standing."* `goldMax` in the budget is the Dossier ceiling, not a target. Nothing on this
/// screen is earned standing: a final score is a fact, and facts are ink.
///
/// **32 pt dense rows are legal here, and only here in this family.** The sheet: *"The one surface
/// in the family where 32px rows are legal, and it earns them the only way allowed: every row is
/// inert. Nothing on this screen opens anything, so the dense tier costs nothing."* That is a
/// standing condition, not a one-off permission -- **if any row on this surface ever becomes
/// tappable, every row on it goes to 44** (`04` 6.3a).
///
/// **One background, ground 1.** No flood and no ghost mark: the sheet stamps `backgrounds 1 of 2`
/// and `ghost mark: none -- never behind tabular figures`, and this screen is almost entirely
/// tabular figures. `ForgeFieldPanel` fills `ground2`, so this one-background composition
/// intentionally omits panels.
///
/// **What it must not draw**, from contract row 47: no recommendation, countdown, receipt, undo,
/// quarter scoring, opposed team totals, play-by-play, reconstructed stat line, or any evidence
/// beyond the retained aftermath projection. `AftermathReadModel` records a final score and no
/// per-quarter breakdown, so the quarter columns the reference sheets once drew are absent by
/// construction rather than by omission.
public struct GameDetailBoxScoreView: View, CoachWorldChromedSurface {
    /// The shared Forge Field chrome (`04` 6.1f). Nil renders on the bare stage.
    public var chrome: FloodlitChromeReadModel?
    public var onNavigateChrome: ((CoachWorldIntentID) -> Void)?

    public let model: AftermathReadModel
    public let onClose: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.forgeFieldClub) private var club

    public init(model: AftermathReadModel, onClose: @escaping () -> Void) {
        self.model = model
        self.onClose = onClose
    }

    public var body: some View {
        ForgeFieldDevice(club: club) {
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    accessibleComposition
                } else {
                    standardComposition
                }
            }
            .frame(
                width: ForgeFieldTokens.Space.viewport.width,
                height: ForgeFieldTokens.Space.viewport.height
            )
            .background(club.palette.ground1.color)
        }
        .accessibilitySortPriority(100)
    }

    // MARK: Standard composition -- vertical seam, staged left, studied right

    private var standardComposition: some View {
        VStack(alignment: .leading, spacing: .zero) {
            chromeBarRegion
                .frame(width: ForgeFieldChromeBar.width, height: ForgeFieldChromeBar.height)
                .padding(.leading, ForgeFieldTokens.Space.margin)
                .padding(.top, ForgeFieldTokens.Space.chromeTop)
            HStack(alignment: .top, spacing: .zero) {
                stagedColumn
                    .frame(width: BoxScoreMetric.stagedWidth, alignment: .leading)
                ForgeFieldSeam(.hard, axis: .vertical)
                    .padding(.horizontal, BoxScoreMetric.seamGutter)
                ScrollView {
                    studiedColumn
                }
                .frame(height: BoxScoreMetric.standardStudiedHeight)
                .accessibilityIdentifier("GameDetailStudiedScroller")
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, ForgeFieldTokens.Space.margin)
            .padding(.top, ForgeFieldTokens.Space.gutter)
            Spacer(minLength: .zero)
        }
    }

    /// AX5 drops the seam and stacks the two halves in reading order, staged before studied.
    /// `04` section 7: the composition reflows to one column preserving order and dropping nothing.
    private var accessibleComposition: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BoxScoreMetric.gap) {
                chromeBarRegion
                stagedColumn
                ForgeFieldSeam(.hard, axis: .horizontal)
                studiedColumn
            }
            .padding(.horizontal, ForgeFieldTokens.Space.margin)
        }
    }

    @ViewBuilder
    private var chromeBarRegion: some View {
        if let chrome {
            ForgeFieldChromeBar(model: chrome, onNavigate: onNavigateChrome ?? { _ in })
        }
    }

    // MARK: Staged half -- the result

    private var stagedColumn: some View {
        VStack(alignment: .leading, spacing: BoxScoreMetric.gap) {
            styledText(model.resultLabel.uppercased(), .columnHead)
                .foregroundStyle(club.palette.ink4.color)

            ForEach(scoreSides, id: \.team.stableID) { side in
                scoreLine(side)
            }

            styledText(model.headline, .prose)
                .foregroundStyle(club.palette.ink3.color)
                .fixedSize(horizontal: false, vertical: true)

            styledText(model.venue.name.uppercased(), .columnHead)
                .foregroundStyle(club.palette.ink4.color)

            Button(action: onClose) {
                styledText("\u{2190} Aftermath".uppercased(), .chrome)
                    .foregroundStyle(club.palette.ink3.color)
                    .frame(
                        minWidth: ForgeFieldTokens.Space.hitMin,
                        minHeight: ForgeFieldTokens.Space.hitMin,
                        alignment: .leading
                    )
            }
            .buttonStyle(.plain)
        }
    }

    /// A score line is inert: a name, and the figure. No opposed totals -- contract row 47 forbids
    /// them -- so each side states only its own.
    private func scoreLine(_ side: MatchDayReadModel.TeamScore) -> some View {
        ForgeFieldRow(.dense) {
            HStack(alignment: .firstTextBaseline, spacing: BoxScoreMetric.gap) {
                styledText(side.team.name.uppercased(), .chrome)
                    .foregroundStyle(club.palette.ink1.color)
                    .lineLimit(BoxScoreMetric.lineLimit(for: dynamicTypeSize))
                    .minimumScaleFactor(BoxScoreMetric.nameScaleFloor)
                Spacer(minLength: BoxScoreMetric.gap)
                styledText("\(side.score)", .heading)
                    .foregroundStyle(club.palette.ink1.color)
                    .monospacedDigit()
            }
        }
    }

    private var scoreSides: [MatchDayReadModel.TeamScore] { [model.home, model.away] }

    // MARK: Studied half -- the evidence

    private var studiedColumn: some View {
        VStack(alignment: .leading, spacing: BoxScoreMetric.gap) {
            gradesPanel
            evidencePanel
        }
    }

    private var gradesPanel: some View {
        VStack(alignment: .leading, spacing: .zero) {
            styledText("WHO DID IT", .panel)
                .foregroundStyle(club.palette.ink4.color)
                .frame(height: ForgeFieldTokens.Space.panelHead, alignment: .leading)
            ForEach(model.grades) { grade in
                gradeRow(grade)
            }
        }
    }

    /// Inert, which is what earns the dense tier. Nothing here opens anything.
    private func gradeRow(_ grade: AftermathReadModel.Grade) -> some View {
        ForgeFieldRow(.dense) {
            HStack(alignment: .firstTextBaseline, spacing: BoxScoreMetric.gap) {
                styledText(grade.position.uppercased(), .columnHead)
                    .foregroundStyle(club.palette.ink4.color)
                    .frame(width: BoxScoreMetric.positionColumn, alignment: .leading)
                VStack(alignment: .leading, spacing: .zero) {
                    styledText(grade.player.name.uppercased(), .row)
                        .foregroundStyle(club.palette.ink2.color)
                        .lineLimit(BoxScoreMetric.lineLimit(for: dynamicTypeSize))
                    styledText(grade.evidence, .prose)
                        .foregroundStyle(club.palette.ink4.color)
                        .lineLimit(BoxScoreMetric.lineLimit(for: dynamicTypeSize))
                }
                Spacer(minLength: BoxScoreMetric.gap)
                styledText("\(grade.rating)", .figure)
                    .foregroundStyle(club.palette.ink1.color)
                    .monospacedDigit()
            }
        }
    }

    private var evidencePanel: some View {
        VStack(alignment: .leading, spacing: BoxScoreMetric.gap) {
            styledText("WHAT THE GAME RECORDED", .panel)
                .foregroundStyle(club.palette.ink4.color)
                .frame(height: ForgeFieldTokens.Space.panelHead, alignment: .leading)
            evidenceGroup("EVIDENCE", model.evidence, empty: "No evidence recorded.")
            evidenceGroup("CALL-INS", model.callIns, empty: "No call-ins recorded.")
            evidenceGroup("INJURIES", model.injuries, empty: "No injuries recorded.")
        }
    }

    /// `04` 4.4: an absent group states its absence rather than disappearing, and Forge Field's
    /// voice rule agrees -- ignorance is stated, not hidden.
    private func evidenceGroup(_ title: String, _ rows: [String], empty: String) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            styledText(title, .columnHead)
                .foregroundStyle(club.palette.ink4.color)
            ForEach(Array((rows.isEmpty ? [empty] : rows).enumerated()), id: \.offset) { _, row in
                ForgeFieldRow(.dense) {
                    styledText(row, .prose)
                        .foregroundStyle(rows.isEmpty ? club.palette.ink4.color : club.palette.ink2.color)
                        .lineLimit(BoxScoreMetric.lineLimit(for: dynamicTypeSize))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    // MARK: Shared text helper

    private func styledText(_ string: String, _ step: ForgeFieldType.Step) -> Text {
        Text(string)
            .font(ForgeFieldType.font(step))
            .tracking(CoachWorldTokens.DisplaySize.tracking(step.tracking, at: step.points))
    }
}

// MARK: - Geometry

private enum BoxScoreMetric {
    /// The sheet stamps the stage at 32 percent across the seam axis: 271 of 852. That is the
    /// staged column's width, and the vertical seam falls at its trailing edge.
    static let stagedWidth: CGFloat = 271

    static let seamGutter = ForgeFieldTokens.Space.gutter
    static let gap = ForgeFieldTokens.Space.ladder[1]          // 8
    static let positionColumn: CGFloat = 44
    static let standardBodyOriginY =
        ForgeFieldTokens.Space.chromeTop + ForgeFieldChromeBar.height
            + ForgeFieldTokens.Space.gutter
    static let standardStudiedHeight =
        ForgeFieldTokens.Space.viewport.height - standardBodyOriginY
            - ForgeFieldTokens.Space.margin

    /// Density-budget reference only: the standard studied scroll renders every retained row, but
    /// this is how many full dense row templates its finite viewport can expose before scrolling.
    static let referenceStudiedRowCount =
        max(0, Int(standardStudiedHeight / ForgeFieldTokens.Space.rowDense))

    /// Deviation, adaptation rule: a generated player or club name that will not fit scales only
    /// this far. Below it the name stops being readable, which is the same defect as truncating,
    /// so the row wraps at accessibility sizes instead -- see `lineLimit(for:)`.
    static let nameScaleFloor = 0.8

    /// `lineLimit(1)` clips at AX5, which is the fault class Coaching HQ, Game plan and Practice
    /// plan each hit. Lifting the limit at accessibility sizes lets the row grow instead.
    static func lineLimit(for dynamicTypeSize: DynamicTypeSize) -> Int? {
        dynamicTypeSize.isAccessibilitySize ? nil : 1
    }
}

// MARK: - Assertable budget facts

extension GameDetailBoxScoreView {
    /// Retained facts drawn once in the staged result column.
    public static let stagedDataPointRoles: [String] = [
        "staged.resultLabel", "staged.headline", "staged.venue", "staged.homeTeam",
        "staged.homeScore", "staged.awayTeam", "staged.awayScore",
    ]

    /// Retained facts drawn once per visible grade row.
    public static let gradeRowDataPointRoles: [String] = [
        "grade.position", "grade.player", "grade.rating", "grade.evidence",
    ]

    /// One retained text fact per visible evidence, call-in, or injury row.
    public static let evidenceRowDataPointRoles: [String] = ["evidence.text"]

    /// The reference count measures the standard studied viewport, never caps the model. Scrolling
    /// reveals further instances of the same row templates without inventing a second budget rule.
    public static let referenceStudiedRowCount = BoxScoreMetric.referenceStudiedRowCount

    /// Conservatively price every visible studied row as the larger (grade) row template.
    public static let dataPointCount = stagedDataPointRoles.count
        + max(gradeRowDataPointRoles.count, evidenceRowDataPointRoles.count)
            * referenceStudiedRowCount

    public static let stagedColumnWidth = BoxScoreMetric.stagedWidth
    public static let stageFraction = Double(
        BoxScoreMetric.stagedWidth / ForgeFieldTokens.Space.viewport.width
    )
    public static let goldElementCount = 0
    public static let emberElementCount = 0
    public static let hasGhostMark = false
    public static let backgroundCount = 1
}
