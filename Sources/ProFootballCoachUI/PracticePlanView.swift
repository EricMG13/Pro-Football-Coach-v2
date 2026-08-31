import SwiftUI
import FootballSimCore

/// Practice plan, drawn to the Forge Field standard -- `04` sections 6.1e, 6.1f, 6.2a, 6.2a(i),
/// 6.3a, 6.6a, 6.7a and 7. Phase 2B Task 5 of
/// `docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md`.
///
/// Replaces the Press Box `CoachWorldFloodlitStage` composition this surface drew before with
/// `ForgeFieldDevice` and the shared primitives (`ForgeFieldSeam`, `ForgeFieldRow`) plus
/// `ForgeFieldType`. **No `ForgeFieldEmber` and no `ForgeFieldChip`** in the surface's own content
/// -- see "Zero embers" below; `ForgeFieldChip` appears only inside the fallback chrome bar's mark
/// plate, chrome-bar-equivalent furniture excluded from the background budget, matching
/// `CoachingHQView`/`InboxView`'s identical exclusion for their own fallback bars. `ForgeFieldPanel`
/// is deliberately unused for the same reason `InboxView` states for its own body -- see "Two
/// backgrounds, flood and ground 1 only" below.
///
/// **Register, from the sheet's stamped spec column
/// (`ForgeFieldBudget.weeklyCommand[.practicePlan]`):** Desk, one flooded strip, ACTION. Stage 19%
/// (74 of 393). Data points 52 of 80. Gold 0. Ember 0. Ghost none. Backgrounds 2 of 2 -- flood,
/// ground 1. Largest numeral 15 (desk ceiling 34).
///
/// **Zero embers -- ruling (dispatch, 2026-08-30/31, do not relitigate).** The sheet draws an ember
/// here, "Spend the 60", but `docs/reviews/2026-08-22-all-screen-presentation-contract.md` row 12
/// omits the very thing "Spend the 60" would have to name: any "separate remaining/unallocated-
/// minutes field". `ForgeFieldBudget.weeklyCommand[.practicePlan]`'s own comment already corrected
/// the budget from the sheet's 1 to 0 for exactly this reason (commit `291d191`). Under `04` 6.1e
/// -- "if an action has no cost worth naming, it is not an ember" -- `commitControl` below is a
/// plain bordered button at the comfortable tier (Rule A-1: no control on an ACTION surface exceeds
/// 44 pt), never an ember. It carries only `onSelect` and `onClose`, matching the contract's own
/// callback list exactly.
///
/// **What was removed for ruling 4 (no remaining/unallocated-minutes field).** The Press Box
/// surface this file replaces printed the fixed weekly-minutes constant as a standalone figure
/// beside its allocator, primed and captioned as a sum of the week's practice budget -- not a
/// derived remainder, but naming the exact weekly-minutes-budget concept the contract's omission
/// targets. This file drops that figure entirely: each session's own minutes are drawn once, in
/// `sessionColumn`/`sessionRow`, and nothing on this surface sums, subtracts or restates the
/// 60-minute budget as its own displayed figure anywhere.
///
/// **Rule A-2, drawn as stated.** Unlike `GamePlanView` (no flood), this surface has the flooded
/// strip Rule A-2 describes: `commitControl` sits inside it, above the one hard seam, directly
/// beside the four session figures it argues with.
///
/// **No sheet geometry beyond the one stamped number was available for this surface in this
/// environment**, the same gap `InboxView.swift` recorded for Task 3 (the Figma/design-tool
/// connector needs interactive authorisation this session does not have, and the plan's "per-surface
/// notes" section transcribes no `x,y · w×h` for Practice Plan). The one exception is the flood's own
/// height: the sheet's stamped stage figure, "19% (74 of 393)", is transcribed verbatim as
/// `PracticeMetric.floodHeight` rather than derived from the ladder, because it is a real number this
/// task's brief states outright, not an invented one. Everything else is this file's own composition
/// from `ForgeFieldTokens.Space.ladder` and the shared chrome-bar geometry, using ordinary SwiftUI
/// flow layout rather than `CoachingHQView`'s absolute `.position()` placement, for the identical
/// reason `InboxView`'s header comment states.
///
/// **Two backgrounds, flood and ground 1 only.** `ForgeFieldPanel` always fills `ground2`, so it is
/// unused here. The flooded strip (`club.palette.clubDeep`, matching `CoachingHQView`'s own flood
/// treatment) is the first; the studied body below the seam sits on the one `ground1` fill this file
/// draws once, separated by `ForgeFieldSeam` hairlines and an ember-coloured boundary stroke on
/// selection -- never a filled tile.
///
/// **The share bars are ink, never club colour, gold or ember.** `04` 6.1e: "club colour... illegal
/// as a panel ground, row band, button or **chart series**", and separately, ember is "never a link,
/// a tab, a chart series or a status". A proportion-of-60-minutes bar is exactly a chart series, so
/// `shareBar` fills with `ink2` against a faint `hairline` track -- the same monochrome treatment
/// every other non-accent mark on this surface uses.
///
/// **Two deviations found on render, not by a test (adaptation rule, owner directive 2026-08-30):**
/// 1. The fourth session's fixed-width column clipped "Position focus" to "POSITION FO..." at
///    standard size -- invisible to every passing test, exactly the class of fault this rule
///    exists to catch. `SessionFact` now separates a short, always-safe visible `label` ("Focus")
///    from the full `accessibilityName` ("Position focus", or "Focus · Offensive line" when a
///    specific group is set) -- see that type's own doc comment.
/// 2. The same AX5 `lineLimit(1)` truncation `GamePlanView.swift` records for its option rows and
///    committing control applies here identically; `optionLineLimit` is the identical fix, on the
///    identical surfaces (option rows, `commitControl`'s label).
public struct PracticePlanView: View, CoachWorldChromedSurface {
    /// The shared management chrome. Nil renders a minimal fallback bar carrying only team
    /// identity -- in production this is always populated when `model` is, so the fallback exists
    /// for previews and tests only.
    public var chrome: FloodlitChromeReadModel?
    public var onNavigateChrome: ((CoachWorldIntentID) -> Void)?

    public let model: PracticePlanReadModel
    public let statusMessage: String?
    public let onSelect: (TacticalPracticePlan) -> Void
    public let onClose: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.forgeFieldClub) private var club
    @State private var selectedID: String

    public init(
        model: PracticePlanReadModel,
        statusMessage: String? = nil,
        onSelect: @escaping (TacticalPracticePlan) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.model = model
        self.statusMessage = statusMessage
        self.onSelect = onSelect
        self.onClose = onClose
        _selectedID = State(initialValue: model.options.first {
            $0.plan == model.currentPlan
        }?.id ?? "")
    }

    public var body: some View {
        ForgeFieldDevice(club: PracticeMetric.club) {
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
                .frame(width: PracticeMetric.chromeSize.width, height: PracticeMetric.chromeSize.height)
                .position(PracticeMetric.center(PracticeMetric.chromeOrigin, PracticeMetric.chromeSize))

            VStack(alignment: .leading, spacing: .zero) {
                floodContent
                    .padding(.horizontal, PracticeMetric.inset)
                    .padding(.top, PracticeMetric.tightGap)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .frame(height: PracticeMetric.floodHeight)
                    .background(club.palette.clubDeep.color)
                    .clipped()
                ForgeFieldSeam(.hard, axis: .horizontal)
                studiedContent
                    .padding(PracticeMetric.inset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(club.palette.ground1.color)
            }
            .frame(width: PracticeMetric.bodySize.width, height: PracticeMetric.bodySize.height)
            .position(PracticeMetric.center(PracticeMetric.bodyOrigin, PracticeMetric.bodySize))
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
        HStack(spacing: PracticeMetric.gap) {
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
                    .frame(width: PracticeMetric.chromeSize.height, height: PracticeMetric.chromeSize.height)
                    .background(club.palette.ground3.color)
            }
            styledText(model.team.name.uppercased(), .chrome)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(1)
            Spacer(minLength: .zero)
        }
        .padding(.horizontal, PracticeMetric.gap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(club.palette.ground1.color)
    }

    // MARK: Flooded strip -- staged, above the seam. No fixed height of its own: the standard
    // composition clamps it to the stamped 74 pt and clips; the accessible composition lets it grow.

    private var floodContent: some View {
        VStack(alignment: .leading, spacing: PracticeMetric.gap) {
            allocationLabelRow
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: PracticeMetric.gap) {
                    ForEach(sessionFacts) { fact in sessionRow(fact) }
                }
                commitControl
            } else {
                HStack(alignment: .top, spacing: PracticeMetric.sectionGap) {
                    ForEach(sessionFacts) { fact in sessionColumn(fact) }
                    Spacer(minLength: PracticeMetric.gap)
                    commitControl
                }
            }
        }
    }

    /// Ruling: `"Option preview"` and `"This week"` are the exact retained labels -- unchanged from
    /// the surface this file replaces. Not gold, not a signal colour: `ink3` is the same quiet ink
    /// every column head on this surface uses, differentiated by wording alone rather than by
    /// borrowing a fixed signal's established meaning for a state that is not one of the four.
    private var allocationLabel: String {
        model.currentPlan == nil ? "Option preview" : "This week"
    }

    private var allocationLabelRow: some View {
        styledText(allocationLabel.uppercased(), .columnHead)
            .foregroundStyle(club.palette.ink3.color)
    }

    /// The allocation the bars draw. Before the week is committed there is no stored plan, and the
    /// allocator is the whole point of the screen -- so it draws what the selected option *would*
    /// allocate, labelled `"Option preview"` rather than presented as the week. Unchanged from the
    /// surface this file replaces (`allocatedPlan`, ledger 2026-08-22: "the stored plan is the
    /// fallback for when no option can be selected").
    private var allocatedPlan: TacticalPracticePlan? {
        if let current = model.currentPlan { return current }
        let selected = model.options.first { $0.id == selectedID } ?? model.options.first
        return selected?.plan
    }

    /// Deviation (adaptation rule, found on render, not by a test): `label` is the short, fixed
    /// word this file always draws in the 76 pt column -- at `.columnHead`'s tracked 10 pt,
    /// "Position focus" (14 characters) clipped to "POSITION FO..." and "Focus · Offensive line"
    /// (a real `PositionGroup` case, 22 characters) would clip far worse. `accessibilityName`
    /// carries the full fact -- which position, when one is set -- so nothing is lost, only moved
    /// to where a variable-length name cannot collide with the column's fixed width.
    private struct SessionFact: Identifiable {
        let id: String
        let label: String
        let accessibilityName: String
        let minutes: Int
    }

    private var sessionFacts: [SessionFact] {
        guard let plan = allocatedPlan else { return [] }
        let focusAccessibilityName = plan.positionFocus.map { "Focus \u{00B7} \(label($0))" }
            ?? "Position focus"
        return [
            SessionFact(id: "install", label: "Install", accessibilityName: "Install",
                        minutes: plan.installMinutes),
            SessionFact(id: "conditioning", label: "Conditioning", accessibilityName: "Conditioning",
                        minutes: plan.conditioningMinutes),
            SessionFact(id: "recovery", label: "Recovery", accessibilityName: "Recovery",
                        minutes: plan.recoveryMinutes),
            SessionFact(id: "focus", label: "Focus", accessibilityName: focusAccessibilityName,
                        minutes: plan.positionFocusMinutes),
        ]
    }

    private func label(_ group: PositionGroup) -> String {
        String(describing: group).replacingOccurrences(of: "_", with: " ").capitalized
    }

    /// One session, as a narrow column: name above a share bar above its minutes figure. The
    /// standard composition's four-across layout -- `.figure` (11 pt, JetBrains Mono, tabular) is
    /// this surface's numeral step; the sheet's stamped "largest numeral 15" describes this same
    /// role at a size well under the 34 pt desk ceiling, and nothing here is promoted past it.
    private func sessionColumn(_ fact: SessionFact) -> some View {
        VStack(alignment: .leading, spacing: PracticeMetric.tightGap) {
            styledText(fact.label.uppercased(), .columnHead)
                .foregroundStyle(club.palette.ink3.color)
                .lineLimit(1)
            shareBar(minutes: fact.minutes)
            styledText("\(fact.minutes)\u{2032}", .figure)
                .foregroundStyle(club.palette.ink1.color)
        }
        .frame(width: PracticeMetric.sessionColumnWidth, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(sessionAccessibilityLabel(fact))
    }

    /// The same session fact, as a full-width row for the AX5 stack -- an HStack does not wrap at
    /// accessibility sizes, so the four-across layout reflows to one row per session instead of
    /// compressing (`04` section 7: "cut rows, never shrink type").
    private func sessionRow(_ fact: SessionFact) -> some View {
        HStack(spacing: PracticeMetric.gap) {
            styledText(fact.label.uppercased(), .columnHead)
                .foregroundStyle(club.palette.ink3.color)
                .frame(width: PracticeMetric.sessionRowLabelWidth, alignment: .leading)
            shareBar(minutes: fact.minutes)
                .frame(maxWidth: .infinity)
            styledText("\(fact.minutes)\u{2032}", .figure)
                .foregroundStyle(club.palette.ink1.color)
                .frame(width: PracticeMetric.sessionRowMinutesWidth, alignment: .trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(sessionAccessibilityLabel(fact))
    }

    private func sessionAccessibilityLabel(_ fact: SessionFact) -> String {
        "\(fact.accessibilityName), \(fact.minutes) minutes of \(TacticalPracticePlan.weeklyMinutes)"
    }

    /// Ink, never club colour, gold or ember -- see this file's own header comment. A thin capsule
    /// track at `hairline`/`Edge.panel` alpha with an `ink2` fill proportional to the session's
    /// share of the fixed 60-minute week.
    private func shareBar(minutes: Int) -> some View {
        let proportion = min(1, max(0, Double(minutes) / Double(TacticalPracticePlan.weeklyMinutes)))
        return GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(club.palette.hairline.color.opacity(ForgeFieldTokens.Edge.panel))
                Capsule()
                    .fill(club.palette.ink2.color)
                    .frame(width: proxy.size.width * proportion)
            }
        }
        .frame(height: PracticeMetric.tightGap)
        .accessibilityHidden(true)
    }

    // MARK: Commit control -- ruling: zero embers (see header comment). A plain bordered button at
    // the comfortable tier (44 pt, Rule A-1), never an ember: no gradient fill, no glow, no gold.

    private var commitLabel: String {
        selectedOption.map { "Set \($0.title)" } ?? "Set the week"
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
                .padding(.horizontal, PracticeMetric.inset)
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
        VStack(alignment: .leading, spacing: PracticeMetric.gap) {
            styledText("Choose the week".uppercased(), .panel)
                .foregroundStyle(club.palette.ink4.color)
            ScrollView {
                VStack(alignment: .leading, spacing: .zero) {
                    ForEach(model.options) { option in
                        optionRow(option, width: PracticeMetric.bodySize.width - 2 * PracticeMetric.inset)
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
    private func optionRow(_ option: PracticePlanReadModel.Option, width: CGFloat?) -> some View {
        let isSelected = selectedID == option.id
        let content = VStack(alignment: .leading, spacing: PracticeMetric.tightGap) {
            styledText(option.title.uppercased(), .row)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(optionLineLimit)
            styledText(option.consequence, .proseMin)
                .foregroundStyle(club.palette.ink3.color)
                .lineLimit(optionLineLimit)
        }
        .padding(.horizontal, PracticeMetric.gap)
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

    private var selectedOption: PracticePlanReadModel.Option? {
        model.options.first { $0.id == selectedID } ?? model.options.first
    }

    // MARK: Accessible composition -- AX5 reflows to one scrollable column, `04` section 7: "cut
    // rows, never shrink type... AX5 removes rows rather than compressing them." Nothing here is
    // fixed-position or fixed-height.

    private var accessibleComposition: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PracticeMetric.sectionGap) {
                chromeBarRegion
                floodContent
                    .padding(PracticeMetric.inset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(club.palette.clubDeep.color)
                ForgeFieldSeam(.hard, axis: .horizontal)
                VStack(alignment: .leading, spacing: PracticeMetric.gap) {
                    styledText("Choose the week".uppercased(), .panel)
                        .foregroundStyle(club.palette.ink4.color)
                    VStack(alignment: .leading, spacing: PracticeMetric.gap) {
                        ForEach(model.options) { option in
                            optionRow(option, width: nil)
                        }
                    }
                }
            }
            .padding(.bottom, PracticeMetric.sectionGap)
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

/// Geometry this file composes itself -- see the header comment's "no sheet geometry beyond the
/// one stamped number" note. Only the chrome bar's position and `floodHeight` are transcribed
/// facts; everything else is this file's own choice from `ForgeFieldTokens.Space.ladder`, matching
/// `InboxMetric`'s own convention (`InboxView.swift`).
private enum PracticeMetric {
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

    /// The sheet's stamped stage figure, "19% (74 of 393)" -- transcribed verbatim, not derived
    /// from the ladder, per this file's own header comment.
    static let floodHeight: CGFloat = 74

    static let sessionColumnWidth: CGFloat = 76
    static let sessionRowLabelWidth: CGFloat = 130
    static let sessionRowMinutesWidth: CGFloat = 40

    // MARK: Reference data-point accounting (estimated, not pixel-measured -- matching
    // `InboxMetric`'s identical disclaimer).
    private static let seamEstimate = ForgeFieldTokens.Edge.hairlineWidth
    private static let studiedHeaderEstimate = ForgeFieldType.Step.panel.points + gap
    private static let studiedAreaHeight = bodySize.height - floodHeight - seamEstimate - 2 * inset
        - studiedHeaderEstimate
    static let referenceOptionCount = max(0, Int(studiedAreaHeight / ForgeFieldTokens.Space.rowTouch))

    static func center(_ origin: CGPoint, _ size: CGSize) -> CGPoint {
        CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
}

// MARK: - Assertable budget facts

extension PracticePlanView {
    /// Facts drawn once for the current/preview allocation: the three fixed sessions' minutes, plus
    /// the fourth session's minutes and its own position-group name (which does vary -- unlike
    /// "Install"/"Conditioning"/"Recovery", themselves fixed furniture and excluded here the same
    /// way `GamePlanView.currentPlanDataPointRoles` excludes its own fixed dial slot names).
    public static let allocationDataPointRoles: [String] = [
        "allocation.installMinutes", "allocation.conditioningMinutes",
        "allocation.recoveryMinutes", "allocation.focusMinutes", "allocation.focusPositionName",
    ]

    /// Facts drawn once per visible option row.
    public static let optionDataPointRoles: [String] = ["option.title", "option.consequence"]

    /// `ForgeFieldBudget.weeklyCommand[.practicePlan]`'s `dataPoints` (52, desk ceiling 80) is
    /// asserted against this total in `DesignContractTests.swift`, not restated -- checked as "at
    /// or under", matching `InboxView`'s identical precedent.
    public static let dataPointCount =
        allocationDataPointRoles.count
            + optionDataPointRoles.count * PracticeMetric.referenceOptionCount

    /// Ruling: zero gold, anywhere on this Desk surface.
    public static let goldElementCount = 0

    /// Ruling: zero embers -- see this file's own header comment.
    public static let emberElementCount = 0

    /// This surface's own two backgrounds: the flooded strip's `clubDeep` fill and the studied
    /// body's `ground1` fill. The shared chrome bar's own ground is furniture, not counted here,
    /// the same exclusion `CoachingHQView.backgroundCount` and `InboxView.backgroundCount` state
    /// for their own fallback bars.
    public static let backgroundCount = 2

    /// The flooded strip's own stage fraction: its stamped height over the full device height,
    /// matching `CoachingHQView.stageFraction`'s identical construction.
    public static let stageFraction: Double =
        Double(PracticeMetric.floodHeight / ForgeFieldTokens.Space.viewport.height)

    /// No ghost mark.
    public static let hasGhostMark = false
}
