import SwiftUI

/// Team health, drawn to the Forge Field standard -- `04` sections 6.1e, 6.1f, 6.2a, 6.2a(i), 6.3a,
/// 6.6a, 6.7a and 7. Phase 2B Task 6 of
/// `docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md`.
///
/// Replaces the Press Box `CoachWorldFloodlitStage` composition this surface drew before with
/// `ForgeFieldDevice` and the shared primitives (`ForgeFieldSeam`, `ForgeFieldRow`) plus
/// `ForgeFieldEmber` and `ForgeFieldType`. `ForgeFieldPanel` is deliberately unused for the same
/// reason `PracticePlanView` states for its own body -- see "Two backgrounds, flood and ground 1
/// only" below.
///
/// **Register, from the sheet's stamped spec column
/// (`ForgeFieldBudget.weeklyCommand[.teamHealth]`):** Desk, one flooded strip, MIXED -- the
/// committing control separated from the readiness table. Stage 16% (62 of 393). Data points 66 of
/// 80. Gold 0. Ember 1. Ghost none. Backgrounds 2 of 2 -- flood, ground 1. Largest numeral 15 (desk
/// ceiling 34).
///
/// **The sheet's ember, "Clear Sarr to play", is refused (dispatch, 2026-08-30/31).** No such
/// callback exists: the presentation contract's row 13 callback list is `onClose`, `onContinue`,
/// `onNavigateChrome`, and nothing clears one named player individually. The ember is `onContinue`,
/// costed from `continueReason` exactly as `InboxView` and `CoachingHQView` cost their own advance
/// ember: disabled, the cost line states `model.continueReason` verbatim; enabled, it names the
/// squad's own unavailable count (`unavailableCount`) -- ordinarily the legal under-spend "0 OUT"
/// once nothing keeps a player off the field, matching `InboxView.emberCost`'s identical "0 DUE"
/// case (that file's own header comment).
///
/// **Rule A-2, drawn as stated.** The sheet's own worked example for this rule: the committing
/// control is never inside a table row. It sits in the flooded strip, above the seam, beside the
/// four figures it argues with -- average condition, average fatigue, the injury count and the
/// suspension count, all four the model's own aggregate fields, never an invented fifth.
///
/// **No sheet geometry was available for this surface in this environment**, the same gap
/// `InboxView.swift` recorded for Task 3 (the Figma/design-tool connector needs interactive
/// authorisation this session does not have, and the plan's "per-surface notes" section transcribes
/// no `x,y · w×h` for Team Health). The one exception is the flood's own height: the stamped stage
/// figure, "16% (62 of 393)", is transcribed verbatim as `HealthMetric.floodHeight`, matching
/// `PracticePlanView.floodHeight`'s identical precedent. Everything else is this file's own
/// composition from `ForgeFieldTokens.Space.ladder` and the shared chrome-bar geometry, using
/// ordinary SwiftUI flow layout rather than absolute `.position()` placement -- `InboxView`'s own
/// reasoning applies unchanged: inventing fixed pixel offsets with nothing to check them against
/// would be false precision, and flow layout is what keeps a variable-length `continueReason` or an
/// empty roster from ever colliding with content placed at a stamped position.
///
/// **Two backgrounds, flood and ground 1 only.** `ForgeFieldPanel` always fills `ground2`, so it is
/// unused here. The readiness table sits directly on the one `ground1` fill this file draws once,
/// separated by `ForgeFieldSeam` hairlines -- never a panel box.
///
/// **Zero gold.** Ruling (dispatch, 2026-08-30/31): a Desk surface carries none -- `04` 6.1e,
/// "zero gold on a Desk surface" -- and this is a Desk surface.
///
/// **Row heights (ruling 3, dispatch 2026-08-30/31).** The readiness table carries no callback the
/// contract's row 13 list does not already name -- there is no per-player selection or navigation --
/// so every row is inert and `ForgeFieldRow(.dense)` (32 pt) is legal under `04` 6.3a's "legal only
/// when the whole row is inert."
///
/// **Availability reads through a fixed signal, never an invented heat gradient.** The Press Box
/// surface this file replaces coloured condition and fatigue along `CoachWorldTokens.Heat`'s
/// five-band continuous scale -- a mechanism Forge Field's four-signal closed vocabulary (`04`
/// 6.1e: "four signals, no fifth") has no equivalent for. This file reserves colour for the one
/// genuinely binary fact the model carries: whether a player's `availability` string starts with
/// "available". A player who is not prints in `signal-alarm` -- "broken now" is exactly what an
/// unavailable player is. Everything continuous -- condition, fatigue, the share bar -- prints in
/// quiet ink, monochrome, never a chart-series colour (`04` 6.1e: club colour is "illegal as
/// a... chart series").
///
/// **One deviation found on render, not by a test (adaptation rule, owner directive 2026-08-30).**
/// At AX5 the readiness table's fixed-pixel columns clipped "AVAILABLE" to "AVAI…" and the
/// condition figure to "1…" against a `lineLimit(1)` that had nowhere left to relax into --
/// invisible to every passing test. `playerRow`'s own doc comment records the fix: at an
/// accessibility size the row composes two full-width lines instead of five fixed columns.
public struct TeamHealthView: View, CoachWorldChromedSurface {
    /// The shared management chrome. Nil renders a minimal fallback bar carrying only team
    /// identity -- in production this is always populated when `model` is, so the fallback exists
    /// for previews and tests only.
    public var chrome: FloodlitChromeReadModel?
    public var onNavigateChrome: ((CoachWorldIntentID) -> Void)?

    public let model: TeamHealthReadModel
    public let statusMessage: String?
    public let onClose: () -> Void
    public let onContinue: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.forgeFieldClub) private var club

    public init(
        model: TeamHealthReadModel,
        statusMessage: String? = nil,
        onClose: @escaping () -> Void,
        onContinue: @escaping () -> Void
    ) {
        self.model = model
        self.statusMessage = statusMessage
        self.onClose = onClose
        self.onContinue = onContinue
    }

    public var body: some View {
        ForgeFieldDevice(club: HealthMetric.club) {
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
        }
    }

    // MARK: Standard composition -- `04` 6.1f (chrome) plus this file's own flow-laid body.

    private var standardComposition: some View {
        ZStack(alignment: .topLeading) {
            chromeBarRegion
                .frame(width: HealthMetric.chromeSize.width, height: HealthMetric.chromeSize.height)
                .position(HealthMetric.center(HealthMetric.chromeOrigin, HealthMetric.chromeSize))

            VStack(alignment: .leading, spacing: .zero) {
                floodContent
                    .padding(.horizontal, HealthMetric.inset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .frame(height: HealthMetric.floodHeight)
                    .background(club.palette.clubDeep.color)
                    .clipped()
                ForgeFieldSeam(.hard, axis: .horizontal)
                studiedContent
                    .padding(HealthMetric.inset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(club.palette.ground1.color)
            }
            .frame(width: HealthMetric.bodySize.width, height: HealthMetric.bodySize.height)
            .position(HealthMetric.center(HealthMetric.bodyOrigin, HealthMetric.bodySize))
        }
        .accessibilitySortPriority(100)
    }

    // MARK: Chrome bar

    @ViewBuilder
    private var chromeBarRegion: some View {
        if let chrome {
            ForgeFieldChromeBar(model: chrome, onNavigate: onNavigateChrome ?? { _ in })
        } else {
            fallbackChromeBar
        }
    }

    private var fallbackChromeBar: some View {
        HStack(spacing: HealthMetric.gap) {
            Button(action: onClose) {
                styledText("\u{2190} Back", .chrome)
                    .foregroundStyle(club.palette.ink3.color)
                    .frame(minWidth: ForgeFieldTokens.Space.hitMin,
                           minHeight: ForgeFieldTokens.Space.hitMin, alignment: .leading)
            }
            .buttonStyle(.plain)
            ForgeFieldChip {
                styledText(model.team.abbreviation.uppercased(), .chrome)
                    .foregroundStyle(club.palette.ink1.color)
                    .frame(width: HealthMetric.chromeSize.height, height: HealthMetric.chromeSize.height)
                    .background(club.palette.ground3.color)
            }
            styledText(model.team.name.uppercased(), .chrome)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(1)
            Spacer(minLength: .zero)
        }
        .padding(.horizontal, HealthMetric.gap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(club.palette.ground1.color)
    }

    // MARK: Flooded strip -- the four aggregate figures, beside the committing control (Rule A-2).

    private var floodContent: some View {
        HStack(alignment: .center, spacing: HealthMetric.sectionGap) {
            ForEach(dials) { fact in dial(fact) }
            Spacer(minLength: HealthMetric.gap)
            ember
        }
    }

    private struct DialFact: Identifiable {
        let id: String
        let label: String
        let value: String
        let tone: Color?
    }

    /// The four figures Rule A-2 argues the ember beside -- the model's own aggregate fields, never
    /// an invented fifth. Injury and suspension counts read `signal-alarm` when either is above
    /// zero, the one binary fact this surface tints; the two averages stay quiet ink, matching this
    /// file's own header comment on the heat-gradient replacement.
    private var dials: [DialFact] {
        [
            DialFact(id: "condition", label: "Condition", value: "\(model.averageCondition)%", tone: nil),
            DialFact(id: "fatigue", label: "Fatigue", value: "\(model.averageFatigue)%", tone: nil),
            DialFact(
                id: "injured", label: "Injured", value: "\(model.injuryCount)",
                tone: model.injuryCount > 0 ? ForgeFieldTokens.Fixed.signalAlarm.color : nil
            ),
            DialFact(
                id: "suspended", label: "Suspended", value: "\(model.suspensionCount)",
                tone: model.suspensionCount > 0 ? ForgeFieldTokens.Fixed.signalAlarm.color : nil
            ),
        ]
    }

    private func dial(_ fact: DialFact) -> some View {
        VStack(alignment: .leading, spacing: HealthMetric.tightGap) {
            styledText(fact.label.uppercased(), .columnHead)
                .foregroundStyle(club.palette.ink4.color)
            styledText(fact.value, .figure)
                .foregroundStyle(fact.tone ?? club.palette.ink1.color)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(fact.label), \(fact.value)")
    }

    // MARK: Ember -- the one commit, `04` 6.1e. Cost names `continueReason` when disabled, matching
    // `InboxView`'s identical ruling; otherwise the squad's own unavailable count.

    private var unavailableCount: Int {
        model.players.filter { !$0.availability.lowercased().hasPrefix("available") }.count
    }

    private var emberCost: String {
        model.continueReason ?? "\(unavailableCount) OUT"
    }

    private var ember: some View {
        ForgeFieldEmber(label: "ADVANCE", cost: emberCost, isEnabled: model.canContinue, action: onContinue)
    }

    // MARK: Studied (below the seam) -- the readiness table, worst-first, every row inert (ruling 3).

    private var studiedContent: some View {
        VStack(alignment: .leading, spacing: .zero) {
            styledText("Readiness".uppercased(), .panel)
                .foregroundStyle(club.palette.ink4.color)
                .padding(.bottom, HealthMetric.gap)
            if let statusMessage {
                statusBanner(statusMessage)
            }
            if model.players.isEmpty {
                styledText("No readiness evidence is recorded for this squad.", .prose)
                    .foregroundStyle(club.palette.ink3.color)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                tableHeader
                ScrollView {
                    VStack(alignment: .leading, spacing: .zero) {
                        ForEach(orderedPlayers) { player in
                            playerRow(player, width: nil)
                            ForgeFieldSeam(.hair, axis: .horizontal)
                        }
                    }
                }
            }
        }
    }

    /// Worst condition first, then by name so the order is stable across snapshots -- unchanged
    /// from the Press Box surface this file replaces.
    private var orderedPlayers: [TeamHealthReadModel.PlayerStatus] {
        model.players.sorted {
            $0.condition == $1.condition ? $0.name < $1.name : $0.condition < $1.condition
        }
    }

    private var tableHeader: some View {
        HStack(spacing: HealthMetric.gap) {
            styledText("Pos", .columnHead).frame(width: HealthMetric.positionColumn, alignment: .leading)
            styledText("Player", .columnHead).frame(maxWidth: .infinity, alignment: .leading)
            styledText("Status", .columnHead).frame(width: HealthMetric.statusColumn, alignment: .leading)
            styledText("Condition", .columnHead).frame(width: HealthMetric.barColumn + HealthMetric.figureColumn,
                                                          alignment: .trailing)
        }
        .foregroundStyle(club.palette.ink4.color)
        .padding(.horizontal, HealthMetric.gap)
        .frame(minHeight: ForgeFieldTokens.Space.rowDense)
        .accessibilityHidden(true)
    }

    /// One row, 32 pt dense (ruling 3: every row here is inert -- no tap, no navigation).
    ///
    /// **Deviation found on render, not by a test (adaptation rule, owner directive 2026-08-30).**
    /// At AX5 the four fixed-pixel columns (`positionColumn`, `statusColumn`, `barColumn`,
    /// `figureColumn`) do not grow with Dynamic Type, so "AVAILABLE" and the condition figure
    /// clipped to "AVAI…" and "1…" against a `lineLimit(1)` that had nothing left to relax into --
    /// invisible to every passing test, exactly the class of fault this rule exists to catch.
    /// `ForgeFieldRow(.dense)`'s own AX5 branch already uses `minHeight`, a floor rather than a
    /// fixed height, so the fix is to stop handing it a row that cannot grow: at an accessibility
    /// size this composes two short, full-width lines (position + name, then status + condition)
    /// instead of five columns fighting for a fixed budget, matching `04` section 7's "cut rows,
    /// never shrink type" by giving each fact room instead of a truncated fixed slot.
    private func playerRow(_ player: TeamHealthReadModel.PlayerStatus, width: CGFloat?) -> some View {
        let isAvailable = player.availability.lowercased().hasPrefix("available")
        let tone = isAvailable ? club.palette.ink3.color : ForgeFieldTokens.Fixed.signalAlarm.color
        let content = Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: HealthMetric.tightGap) {
                    HStack(spacing: HealthMetric.gap) {
                        styledText(player.position.uppercased(), .columnHead)
                            .foregroundStyle(club.palette.ink3.color)
                        styledText(player.name, .row)
                            .foregroundStyle(club.palette.ink1.color)
                    }
                    HStack(spacing: HealthMetric.gap) {
                        styledText(player.availability.uppercased(), .columnHead)
                            .foregroundStyle(tone)
                        styledText("\(player.condition)%", .figure)
                            .foregroundStyle(club.palette.ink1.color)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: HealthMetric.gap) {
                    styledText(player.position.uppercased(), .columnHead)
                        .foregroundStyle(club.palette.ink3.color)
                        .lineLimit(1)
                        .frame(width: HealthMetric.positionColumn, alignment: .leading)
                    styledText(player.name, .row)
                        .foregroundStyle(club.palette.ink1.color)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    styledText(player.availability.uppercased(), .columnHead)
                        .foregroundStyle(tone)
                        .lineLimit(1)
                        .frame(width: HealthMetric.statusColumn, alignment: .leading)
                    conditionBar(player.condition)
                        .frame(width: HealthMetric.barColumn)
                    styledText("\(player.condition)%", .figure)
                        .foregroundStyle(club.palette.ink1.color)
                        .lineLimit(1)
                        .frame(width: HealthMetric.figureColumn, alignment: .trailing)
                }
                .frame(maxWidth: width, alignment: .leading)
            }
        }
        .padding(.horizontal, HealthMetric.gap)

        return ForgeFieldRow(.dense) { content }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(player.position) \(player.name), \(player.availability), "
                    + "condition \(player.condition) percent, fatigue \(player.fatigue) percent. "
                    + player.statusDetail
            )
    }

    /// Ink, never club colour, gold or ember -- see this file's own header comment. A thin capsule
    /// track at `hairline`/`Edge.panel` alpha with an `ink2` fill proportional to condition,
    /// matching `PracticePlanView.shareBar`'s identical monochrome treatment.
    private func conditionBar(_ condition: Int) -> some View {
        let proportion = min(1, max(0, Double(condition) / 100))
        return GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(club.palette.hairline.color.opacity(ForgeFieldTokens.Edge.panel))
                Capsule()
                    .fill(club.palette.ink2.color)
                    .frame(width: proxy.size.width * proportion)
            }
        }
        .frame(height: HealthMetric.tightGap)
        .accessibilityHidden(true)
    }

    /// The save-status receipt -- it has to reach the player while they are playing, matching the
    /// priority `CoachingHQView`/`InboxView`/`GamePlanView` give the same fact.
    private func statusBanner(_ text: String) -> some View {
        styledText(text, .proseMin)
            .foregroundStyle(ForgeFieldTokens.Fixed.signalAlarm.color)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, HealthMetric.gap)
    }

    // MARK: Accessible composition -- AX5 reflows to one scrollable column, `04` section 7: "cut
    // rows, never shrink type." Nothing here is fixed-position or fixed-height.

    private var accessibleComposition: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HealthMetric.sectionGap) {
                chromeBarRegion
                VStack(alignment: .leading, spacing: HealthMetric.gap) {
                    ForEach(dials) { fact in dial(fact) }
                    ember
                }
                .padding(HealthMetric.inset)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(club.palette.clubDeep.color)
                ForgeFieldSeam(.hard, axis: .horizontal)
                VStack(alignment: .leading, spacing: HealthMetric.gap) {
                    styledText("Readiness".uppercased(), .panel)
                        .foregroundStyle(club.palette.ink4.color)
                    if let statusMessage {
                        statusBanner(statusMessage)
                    }
                    if model.players.isEmpty {
                        styledText("No readiness evidence is recorded for this squad.", .prose)
                            .foregroundStyle(club.palette.ink3.color)
                    } else {
                        VStack(alignment: .leading, spacing: .zero) {
                            ForEach(orderedPlayers) { player in
                                playerRow(player, width: nil)
                                ForgeFieldSeam(.hair, axis: .horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, HealthMetric.inset)
            .padding(.bottom, HealthMetric.sectionGap)
        }
        .accessibilitySortPriority(100)
    }

    // MARK: Shared text helper

    private func styledText(_ string: String, _ step: ForgeFieldType.Step) -> Text {
        Text(string)
            .font(ForgeFieldType.font(step))
            .tracking(CoachWorldTokens.DisplaySize.tracking(step.tracking, at: step.points))
    }
}

// MARK: - Geometry

/// Geometry this file composes itself -- see the header comment's "no sheet geometry was available"
/// note. Only the chrome bar's position and `floodHeight` are transcribed facts; everything else is
/// this file's own choice from `ForgeFieldTokens.Space.ladder`, matching `PracticeMetric`'s own
/// convention (`PracticePlanView.swift`).
private enum HealthMetric {
    /// `04` 6.1e's four authored clubs are not yet resolved per-team (ledger row E6); `.calumet` is
    /// the same interim default every other Forge Field surface renders every team in today.
    static let club = ForgeFieldTokens.Club.calumet

    static let columnWidth = ForgeFieldChromeBar.width
    static let chromeOrigin = ForgeFieldChromeBar.origin
    static let chromeSize = CGSize(width: columnWidth, height: ForgeFieldChromeBar.height)

    static let bodyOrigin = CGPoint(
        x: ForgeFieldTokens.Space.margin,
        y: chromeOrigin.y + ForgeFieldChromeBar.height + ForgeFieldTokens.Space.gutter
    )
    static let bodySize = CGSize(
        width: columnWidth,
        height: ForgeFieldTokens.Space.viewport.height - bodyOrigin.y - ForgeFieldTokens.Space.margin
    )

    static let tightGap = ForgeFieldTokens.Space.ladder[0]    // 4
    static let gap = ForgeFieldTokens.Space.ladder[1]         // 8
    static let inset = ForgeFieldTokens.Space.ladder[2]       // 12
    static let sectionGap = ForgeFieldTokens.Space.ladder[3]  // 16

    /// The sheet's stamped stage figure, "16% (62 of 393)" -- transcribed verbatim, not derived
    /// from the ladder, per this file's own header comment.
    static let floodHeight: CGFloat = 62

    static let positionColumn: CGFloat = 40
    static let statusColumn: CGFloat = 100
    static let barColumn: CGFloat = 56
    static let figureColumn: CGFloat = 44

    // MARK: Reference data-point accounting (estimated, not pixel-measured -- matching
    // `PracticeMetric`'s identical disclaimer).
    private static let seamEstimate = ForgeFieldTokens.Edge.hairlineWidth
    private static let studiedHeaderEstimate =
        ForgeFieldType.Step.panel.points + gap + ForgeFieldTokens.Space.rowDense
    private static let studiedAreaHeight = bodySize.height - floodHeight - seamEstimate - 2 * inset
        - studiedHeaderEstimate
    static let referenceRowCount = max(0, Int(studiedAreaHeight / ForgeFieldTokens.Space.rowDense))

    static func center(_ origin: CGPoint, _ size: CGSize) -> CGPoint {
        CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
}

// MARK: - Assertable budget facts

extension TeamHealthView {
    /// Facts drawn once in the flooded strip -- the four aggregate figures Rule A-2 puts beside the
    /// ember. The fixed slot names ("Condition", "Fatigue", "Injured", "Suspended") are furniture,
    /// matching how `GamePlanView.currentPlanDataPointRoles` excludes its own fixed dial names.
    public static let floodDataPointRoles: [String] = [
        "flood.averageCondition", "flood.averageFatigue", "flood.injuryCount", "flood.suspensionCount",
    ]

    /// Facts drawn once per visible readiness row.
    public static let rowDataPointRoles: [String] = [
        "row.position", "row.name", "row.availability", "row.condition",
    ]

    /// `ForgeFieldBudget.weeklyCommand[.teamHealth]`'s `dataPoints` (66, desk ceiling 80) is
    /// asserted against this total in `DesignContractTests.swift`, not restated -- checked as "at
    /// or under", matching `InboxView`/`GamePlanView`/`PracticePlanView`'s identical precedent.
    public static let dataPointCount =
        floodDataPointRoles.count + rowDataPointRoles.count * HealthMetric.referenceRowCount

    /// Ruling: zero gold, anywhere on this Desk surface.
    public static let goldElementCount = 0

    /// One `ForgeFieldEmber(` call site in this file -- `ADVANCE`.
    public static let emberElementCount = 1

    /// This surface's own two backgrounds: the flooded strip's `clubDeep` fill and the studied
    /// body's `ground1` fill. The shared chrome bar's own ground is furniture, not counted here,
    /// the same exclusion `CoachingHQView.backgroundCount` and `PracticePlanView.backgroundCount`
    /// state for their own fallback bars.
    public static let backgroundCount = 2

    /// The flooded strip's own stage fraction: its stamped height over the full device height,
    /// matching `PracticePlanView.stageFraction`'s identical construction.
    public static let stageFraction: Double =
        Double(HealthMetric.floodHeight / ForgeFieldTokens.Space.viewport.height)

    /// No ghost mark.
    public static let hasGhostMark = false
}
