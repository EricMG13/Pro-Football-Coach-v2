import SwiftUI
import FootballSimCore

/// Game plan, drawn to the Forge Field standard -- `04` sections 6.1e, 6.1f, 6.2a, 6.2a(i), 6.3a,
/// 6.6a, 6.7a and 7. Phase 2B Task 4 of
/// `docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md`.
///
/// Replaces the Press Box `CoachWorldFloodlitStage` composition this surface drew before with
/// `ForgeFieldDevice` and the shared primitives (`ForgeFieldSeam`, `ForgeFieldRow`) plus
/// `ForgeFieldType`. **No `ForgeFieldEmber` and no `ForgeFieldChip`** in the surface's own content
/// -- see "Zero embers" below; `ForgeFieldChip` appears only inside the fallback chrome bar's mark
/// plate, chrome-bar-equivalent furniture excluded from the background budget, matching
/// `CoachingHQView`/`InboxView`'s identical exclusion for their own fallback bars.
///
/// **Register, from the sheet's stamped spec column
/// (`ForgeFieldBudget.weeklyCommand[.gamePlan]`):** Desk, no flood, 3 pt club spine, ACTION.
/// Stage 0%. Data points 44 of 80. Gold 0. Ember 0. Ghost none. Backgrounds 1 of 2 -- ground 1 only.
///
/// **Zero embers -- ruling (dispatch, 2026-08-30/31, do not relitigate).** The sheet draws an ember
/// here, "Lock the plan", but `docs/reviews/2026-08-22-all-screen-presentation-contract.md` row 11
/// omits "cost" outright, and `ForgeFieldBudget.weeklyCommand[.gamePlan]`'s own comment already
/// corrected the budget from the sheet's 1 to 0 for exactly this reason (commit `291d191`). Under
/// `04` 6.1e -- "if an action has no cost worth naming, it is not an ember" -- `commitControl` below
/// is a plain bordered button at the comfortable tier (Rule A-1: no control on an ACTION surface
/// exceeds 44 pt), never an ember: no gradient fill, no glow shadow, no gold. It carries only
/// `onSelect` and `onClose`, matching the contract's own callback list exactly -- no new callback is
/// added for the drawn action, because the contract does not list one.
///
/// **Rule A-2's general intent, applied to a no-flood surface.** The spec states the committing
/// control "sits in the flooded strip, above the seam, beside the figures it argues with". This
/// surface has no flood to put it in (the register says so explicitly), so `commitControl` sits
/// instead in the plain, unflooded staged zone above the one hard seam, directly beside the current
/// plan's three dial values it would replace -- the same relationship Rule A-2 describes, without
/// the club-colour treatment this register withholds.
///
/// **No sheet geometry was available for this surface in this environment**, the same gap
/// `InboxView.swift` recorded for Task 3 (the Figma/design-tool connector needs interactive
/// authorisation this session does not have, and the plan's "per-surface notes" section transcribes
/// no `x,y · w×h` for Game Plan). Every position below is this file's own composition from
/// `ForgeFieldTokens.Space.ladder` and the shared chrome-bar geometry, using ordinary SwiftUI flow
/// layout rather than `CoachingHQView`'s absolute `.position()` placement -- `InboxView`'s own
/// reasoning applies unchanged: inventing fixed pixel offsets with nothing to check them against
/// would be false precision, and flow layout is what keeps an absent `model.currentPlan` (no plan
/// committed yet) from ever colliding with the content below it.
///
/// **One background, ground 1 only**, matching `InboxView`'s identical stamp and identical
/// reasoning: `ForgeFieldPanel` always fills `ground2`, so it is unused here. Option rows sit
/// directly on the one `ground1` fill this file draws once, separated by `ForgeFieldSeam` hairlines
/// and an ember-coloured boundary stroke on selection -- never a filled tile.
///
/// **Largest numeral: none (the sheet's stamped 0).** Every value this surface draws -- tempo,
/// pressure, run/pass bias -- is a word label ("Grind it", "Aggressive", "Run heavy"), never a
/// digit. No figure is promoted to display size; none exists to promote.
///
/// **Deviation found on render, not by a test (adaptation rule, owner directive 2026-08-30):** at
/// AX5 the option rows' `lineLimit(1)` truncated a consequence sentence with an ellipsis --
/// invisible to every passing test, exactly the class of fault this rule exists to catch.
/// `optionLineLimit` lifts the limit only at an accessibility size (`dynamicTypeSize
/// .isAccessibilitySize ? nil : 1`), matching `ForgeFieldEmber.lineLimit(for:)`'s own pattern;
/// `ForgeFieldRow(.touch)`'s AX5 branch already uses `minHeight` rather than a fixed height, so the
/// row simply grows. Applied to every `lineLimit(1)` text on this surface (option rows,
/// `commitControl`'s label, the header's opponent name and its `minimumScaleFactor` net, the dial
/// values) for the same reason, even where today's data does not yet trigger it. The header's own
/// three-way `currentPlanColumns`/`currentPlanRows` split exists for the identical reason one level
/// up: an `HStack` does not wrap at accessibility sizes, so the accessible composition stacks the
/// three dials instead of placing them side by side.
public struct GamePlanView: View, CoachWorldChromedSurface {
    /// The shared management chrome. Nil renders a minimal fallback bar carrying only team
    /// identity -- in production this is always populated when `model` is, so the fallback exists
    /// for previews and tests only.
    public var chrome: FloodlitChromeReadModel?
    public var onNavigateChrome: ((CoachWorldIntentID) -> Void)?

    public let model: GamePlanReadModel
    public let title: String
    public let statusMessage: String?
    public let onSelect: (TacticalPlan) -> Void
    public let onClose: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.forgeFieldClub) private var club
    @State private var selectedID: String

    public init(
        model: GamePlanReadModel,
        title: String = "GAME PLAN",
        statusMessage: String? = nil,
        onSelect: @escaping (TacticalPlan) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.model = model
        self.title = title
        self.statusMessage = statusMessage
        self.onSelect = onSelect
        self.onClose = onClose
        _selectedID = State(initialValue: model.options.first {
            $0.plan == model.currentPlan
        }?.id ?? "")
    }

    public var body: some View {
        ForgeFieldDevice(club: GameMetric.club) {
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
                .frame(width: GameMetric.chromeSize.width, height: GameMetric.chromeSize.height)
                .position(GameMetric.center(GameMetric.chromeOrigin, GameMetric.chromeSize))

            bodyContent
                .padding(GameMetric.inset)
                .frame(width: GameMetric.bodySize.width, height: GameMetric.bodySize.height,
                       alignment: .topLeading)
                .background(club.palette.ground1.color)
                .position(GameMetric.center(GameMetric.bodyOrigin, GameMetric.bodySize))
        }
        .accessibilitySortPriority(100)
    }

    private var bodyContent: some View {
        VStack(alignment: .leading, spacing: .zero) {
            header
            if let statusMessage {
                statusBanner(statusMessage)
            }
            stagedRow
                .padding(.bottom, GameMetric.gap)
            ForgeFieldSeam(.hard, axis: .horizontal)
            studiedContent
                .padding(.top, GameMetric.gap)
                .frame(maxHeight: .infinity, alignment: .top)
        }
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
        HStack(spacing: GameMetric.gap) {
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
                    .frame(width: GameMetric.chromeSize.height, height: GameMetric.chromeSize.height)
                    .background(club.palette.ground3.color)
            }
            styledText(model.team.name.uppercased(), .chrome)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(1)
            Spacer(minLength: .zero)
        }
        .padding(.horizontal, GameMetric.gap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(club.palette.ground1.color)
    }

    // MARK: Header -- this surface's own identity, never repeating the chrome bar's week (`04`
    // 6.1f already states it once).

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: GameMetric.gap) {
            styledText(title, .panel)
                .foregroundStyle(club.palette.ink4.color)
                .lineLimit(1)
            Spacer(minLength: GameMetric.gap)
            if let opponent = model.opponent {
                styledText(opponentLine(opponent), .chrome)
                    .foregroundStyle(club.palette.ink3.color)
                    .lineLimit(optionLineLimit)
                    // AX5 never shrinks type (`04` section 7): the scale-floor net only applies at
                    // the default size, where it stays an unneeded defence -- see `nameScaleFloor`'s
                    // own comment.
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 1 : GameMetric.nameScaleFloor)
            }
        }
        .padding(.bottom, GameMetric.gap)
    }

    private func opponentLine(_ opponent: CoachWorldTeamReference) -> String {
        "VS \(opponent.name.uppercased())"
    }

    /// The save-status receipt -- it has to reach the coach while they are still choosing, matching
    /// the priority `CoachingHQView`/`InboxView` give the same fact.
    private func statusBanner(_ text: String) -> some View {
        styledText(text, .proseMin)
            .foregroundStyle(ForgeFieldTokens.Fixed.signalAlarm.color)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, GameMetric.gap)
    }

    // MARK: Staged (above the seam) -- the current plan, beside the committing control (Rule A-2).
    // `dominant reads the stored plan` (ledger, 2026-08-22): this draws only `model.currentPlan`,
    // never a preview of the selected option -- unchanged from the surface this file replaces.

    private var stagedRow: some View {
        HStack(alignment: .top, spacing: GameMetric.sectionGap) {
            currentPlanColumns
            Spacer(minLength: GameMetric.gap)
            commitControl
        }
    }

    /// Standard composition only: three dials across in one row. An `HStack` does not wrap at
    /// accessibility sizes, so `accessibleComposition` calls `currentPlanRows` instead (deviation,
    /// adaptation rule, matching the identical AX5-reflow split `PracticePlanView.sessionColumn`/
    /// `sessionRow` already uses for the same reason).
    @ViewBuilder
    private var currentPlanColumns: some View {
        if let plan = model.currentPlan {
            VStack(alignment: .leading, spacing: GameMetric.gap) {
                styledText("This week".uppercased(), .columnHead)
                    .foregroundStyle(club.palette.ink4.color)
                HStack(spacing: GameMetric.sectionGap) {
                    dial("Tempo", value: label(plan.tempo))
                    dial("Aggression", value: label(plan.pressure))
                    dial("Balance", value: label(plan.runPassBias))
                }
            }
        }
    }

    /// The AX5 reflow of `currentPlanColumns`: the same three facts, stacked rather than
    /// side by side.
    @ViewBuilder
    private var currentPlanRows: some View {
        if let plan = model.currentPlan {
            VStack(alignment: .leading, spacing: GameMetric.gap) {
                styledText("This week".uppercased(), .columnHead)
                    .foregroundStyle(club.palette.ink4.color)
                VStack(alignment: .leading, spacing: GameMetric.gap) {
                    dial("Tempo", value: label(plan.tempo))
                    dial("Aggression", value: label(plan.pressure))
                    dial("Balance", value: label(plan.runPassBias))
                }
            }
        }
    }

    /// One dimension of the current plan: a slot name (fixed furniture -- always "Tempo",
    /// "Aggression" or "Balance", never save-varying) plus its resolved word-label value. `.row`
    /// (13.5 pt), never a numeral step -- these are words, and none of this surface's values are
    /// digits (the sheet's stamped "largest numeral: 0"). `optionLineLimit`: the same AX5 deviation
    /// as `optionRow` -- these are short, closed-vocabulary words, but nothing here shrinks type at
    /// an accessibility size regardless.
    private func dial(_ slot: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: GameMetric.tightGap) {
            styledText(slot.uppercased(), .columnHead)
                .foregroundStyle(club.palette.ink4.color)
            styledText(value.uppercased(), .row)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(optionLineLimit)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(slot), \(value)")
    }

    private func label(_ tempo: TacticalTempo) -> String {
        switch tempo {
        case .deliberate: "Grind it"
        case .balanced: "Balanced"
        case .hurry: "Push the pace"
        }
    }

    private func label(_ pressure: TacticalPressure) -> String {
        switch pressure {
        case .contain: "Contain"
        case .balanced: "Balanced"
        case .attack: "Aggressive"
        }
    }

    private func label(_ bias: TacticalRunPassBias) -> String {
        switch bias {
        case .runHeavy: "Run heavy"
        case .balanced: "Balanced"
        case .passHeavy: "Pass heavy"
        }
    }

    // MARK: Commit control -- ruling: zero embers (see header comment). A plain bordered button at
    // the comfortable tier (44 pt, Rule A-1), never an ember: no gradient fill, no glow, no gold.

    private var commitLabel: String {
        selectedOption.map { "Set \($0.title)" } ?? "Set the install"
    }

    private var commitControl: some View {
        Button {
            guard let selectedOption else { return }
            onSelect(selectedOption.plan)
            onClose()
        } label: {
            styledText(commitLabel.uppercased(), .chrome)
                .tracking(CoachWorldTokens.DisplaySize.tracking(
                    ForgeFieldType.Tracking.chrome.em, at: ForgeFieldType.Step.chrome.points))
                .foregroundStyle(club.palette.ink1.color)
                .multilineTextAlignment(.leading)
                .lineLimit(optionLineLimit)
                .padding(.horizontal, GameMetric.inset)
                .frame(minWidth: ForgeFieldTokens.Space.hitMin,
                       minHeight: ForgeFieldTokens.Space.hitMin)
        }
        .buttonStyle(.plain)
        .overlay {
            RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
                .strokeBorder(club.palette.hairline.color.opacity(ForgeFieldTokens.Edge.raised),
                              lineWidth: ForgeFieldTokens.Edge.hairlineWidth)
        }
        .disabled(selectedOption == nil)
        .opacity(selectedOption == nil
                 ? CoachWorldTokens.Motion.resolvedDisabledOpacity(for: contrast) : 1)
        .accessibilityLabel(commitLabel)
    }

    // MARK: Studied (below the seam) -- the options, at the comfortable tier only (Rule A-1: no
    // 32 pt dense row anywhere on this surface, including here).

    private var studiedContent: some View {
        VStack(alignment: .leading, spacing: GameMetric.gap) {
            styledText("Choose the install".uppercased(), .panel)
                .foregroundStyle(club.palette.ink4.color)
            ScrollView {
                VStack(alignment: .leading, spacing: .zero) {
                    ForEach(model.options) { option in
                        optionRow(option, width: GameMetric.bodySize.width - 2 * GameMetric.inset)
                        ForgeFieldSeam(.hair, axis: .horizontal)
                    }
                }
            }
        }
    }

    /// Deviation (adaptation rule, found on render, not by a test): at AX5 a `lineLimit(1)`
    /// consequence sentence truncated with an ellipsis -- `04` section 7 requires AX5 to show full
    /// content, never clip it. `ForgeFieldRow(.touch)`'s own AX5 branch already switches to
    /// `minHeight` (a floor, not a fixed height), so lifting the limit only at an accessibility
    /// size is safe: the row simply grows. Matches `ForgeFieldEmber.lineLimit(for:)`'s identical
    /// pattern and rationale exactly.
    private var optionLineLimit: Int? {
        dynamicTypeSize.isAccessibilitySize ? nil : 1
    }

    /// One row, 44 pt (Rule A-1), shared by the standard list (fixed width) and the AX5 stack
    /// (`width: nil`). Selection is presentation state only, set locally -- the row itself never
    /// calls `onSelect`; only `commitControl`'s explicit action commits a plan.
    private func optionRow(_ option: GamePlanReadModel.Option, width: CGFloat?) -> some View {
        let isSelected = selectedID == option.id
        let content = VStack(alignment: .leading, spacing: GameMetric.tightGap) {
            styledText(option.title.uppercased(), .row)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(optionLineLimit)
            styledText(option.consequence, .proseMin)
                .foregroundStyle(club.palette.ink3.color)
                .lineLimit(optionLineLimit)
        }
        .padding(.horizontal, GameMetric.gap)
        .frame(maxWidth: width, alignment: .leading)

        return Button {
            selectedID = option.id
        } label: {
            ForgeFieldRow(.touch) { content }
                .overlay {
                    // `04` 6.3: "Selected items receive boundary, value and spoken state; never a
                    // coloured fill alone." -- matching `CoachingHQView.tile` and `InboxView.row`'s
                    // identical selection treatment.
                    if isSelected {
                        RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
                            .strokeBorder(club.palette.ember.color,
                                          lineWidth: ForgeFieldTokens.Edge.hairlineWidth)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(option.title). \(option.consequence)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var selectedOption: GamePlanReadModel.Option? {
        model.options.first { $0.id == selectedID } ?? model.options.first
    }

    // MARK: Accessible composition -- AX5 reflows to one scrollable column, `04` section 7: "cut
    // rows, never shrink type... AX5 removes rows rather than compressing them." Nothing here is
    // fixed-position, and the staged row's two halves stack rather than sharing one HStack, since
    // an HStack does not wrap at accessibility sizes.

    private var accessibleComposition: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GameMetric.sectionGap) {
                chromeBarRegion
                header
                if let statusMessage {
                    statusBanner(statusMessage)
                }
                currentPlanRows
                commitControl
                ForgeFieldSeam(.hard, axis: .horizontal)
                VStack(alignment: .leading, spacing: GameMetric.gap) {
                    styledText("Choose the install".uppercased(), .panel)
                        .foregroundStyle(club.palette.ink4.color)
                    VStack(alignment: .leading, spacing: GameMetric.gap) {
                        ForEach(model.options) { option in
                            optionRow(option, width: nil)
                        }
                    }
                }
            }
            .padding(.horizontal, GameMetric.inset)
            .padding(.bottom, GameMetric.sectionGap)
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

/// Geometry this file composes itself -- see the header comment's "no sheet geometry was
/// available" note. Only the chrome bar's position is a true shared constant; everything below it
/// is this file's own choice from `ForgeFieldTokens.Space.ladder`, matching `InboxMetric`'s own
/// convention (`InboxView.swift`).
private enum GameMetric {
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

    /// A defensive scale floor for a long generated opponent name at the header's small (14 pt)
    /// size -- unlike `CoachingHQView`'s 62 pt fixture card, this size has ample width headroom, so
    /// this exists as a net rather than an expected trigger (matching the `04` 6.2a(i) floor
    /// discipline: never below `Step.columnHead`'s own 10 pt).
    static let nameScaleFloor: CGFloat = 0.72

    // MARK: Reference data-point accounting (estimated, not pixel-measured -- matching
    // `InboxMetric`'s identical disclaimer: nothing downstream needs the estimate to be exact,
    // only for `referenceOptionCount` to stay a defensible lower bound on what the standard
    // composition's viewport shows before scrolling).
    private static let headerAreaEstimate = ForgeFieldType.Step.chrome.points + gap
    private static let stagedAreaEstimate = ForgeFieldTokens.Space.rowTouch + gap
    private static let seamEstimate = ForgeFieldTokens.Edge.hairlineWidth
    private static let studiedHeaderEstimate = ForgeFieldType.Step.panel.points + gap
    private static let optionsAreaHeight =
        bodySize.height - 2 * inset - headerAreaEstimate - stagedAreaEstimate - seamEstimate
            - studiedHeaderEstimate
    static let referenceOptionCount = max(0, Int(optionsAreaHeight / ForgeFieldTokens.Space.rowTouch))

    static func center(_ origin: CGPoint, _ size: CGSize) -> CGPoint {
        CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
}

// MARK: - Assertable budget facts

extension GamePlanView {
    /// Facts drawn once for the header. `header.opponentName` is counted even though `model.opponent`
    /// is sometimes nil (no game scheduled this week), matching `CoachingHQView.floodFieldDataPoints`'
    /// identical treatment of a fact that can be legitimately absent for a given save.
    public static let headerDataPointRoles: [String] = ["header.opponentName"]

    /// Facts drawn once for the current, stored plan -- the three tactical dimensions. The fixed
    /// slot names ("Tempo", "Aggression", "Balance") are furniture, matching how `CoachingHQView`'s
    /// own enumeration excludes the "v" divider and how `InboxView`'s excludes its screen title.
    public static let currentPlanDataPointRoles: [String] = [
        "current.tempo", "current.pressure", "current.bias",
    ]

    /// Facts drawn once per visible option row.
    public static let optionDataPointRoles: [String] = ["option.title", "option.consequence"]

    /// `ForgeFieldBudget.weeklyCommand[.gamePlan]`'s `dataPoints` (44, desk ceiling 80) is asserted
    /// against this total in `DesignContractTests.swift`, not restated. Without sheet access
    /// (header comment), this total cannot be shown to equal the stamped 44 exactly; it is checked
    /// as "at or under", matching this family's Task 2-10 step list's own wording and `InboxView`'s
    /// identical precedent.
    public static let dataPointCount =
        headerDataPointRoles.count + currentPlanDataPointRoles.count
            + optionDataPointRoles.count * GameMetric.referenceOptionCount

    /// Ruling: zero gold, anywhere on this Desk surface.
    public static let goldElementCount = 0

    /// Ruling: zero embers -- see this file's own header comment.
    public static let emberElementCount = 0

    /// This surface's own one background: the body's `ground1` fill. The shared chrome bar's own
    /// ground is furniture, not counted here, the same exclusion `CoachingHQView.backgroundCount`
    /// and `InboxView.backgroundCount` state for their own fallback bars.
    public static let backgroundCount = 1

    /// No flood at all -- the sheet's stamped "no flood, 3 pt spine".
    public static let stageFraction: Double = 0.0

    /// No ghost mark.
    public static let hasGhostMark = false
}
