import SwiftUI

/// Inbox, drawn to the Forge Field standard -- `04` sections 6.1e, 6.1f, 6.2a, 6.2a(i), 6.3a, 6.6a,
/// 6.7a and 7. Phase 2B Task 3 of
/// `docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md`.
///
/// Replaces the Press Box `CoachWorldFloodlitStage` composition this surface drew before with
/// `ForgeFieldDevice` and the Forge Field primitives (`ForgeFieldSeam`, `ForgeFieldRow`,
/// `ForgeFieldChip`) plus `ForgeFieldEmber` and `ForgeFieldType`. `ForgeFieldPanel` is deliberately
/// unused for this surface's own content -- see "One background, ground 1 only" below;
/// `ForgeFieldChip` appears only inside the fallback chrome bar's mark plate, chrome-bar-equivalent
/// furniture excluded from that same budget, matching `CoachingHQView.backgroundCount`'s identical
/// exclusion for its own fallback bar.
///
/// **Register, from the sheet's stamped spec column
/// (`ForgeFieldBudget.weeklyCommand[.inbox]`):** Desk, no flood, 3 pt club spine, MIXED (the feed,
/// one committing control). Stage 0%. Data points 58 of 80. Gold 0. Ember 1. Ghost none.
/// Backgrounds 1 of 2 -- ground 1 only.
///
/// **No sheet geometry was available for this surface in this environment** (the Figma/design-tool
/// connector this task would otherwise read `Game screens - Weekly command.dc.html` through
/// requires interactive authorisation this session does not have, and the plan's own "per-surface
/// notes" section -- which transcribes Coaching HQ's exact `x,y · w×h` geometry in prose -- has no
/// entry for Inbox). Every position below is therefore this file's own composition from
/// `ForgeFieldTokens.Space.ladder` and the family's shared chrome-bar geometry, not a sheet
/// transcription, and it uses ordinary SwiftUI flow layout (`VStack`/`HStack` with flexible frames)
/// for the body rather than `CoachingHQView`'s absolute `.position()` placement -- a deliberate
/// difference, not an oversight: `CoachingHQView`'s fixed positions are honest because they
/// transcribe a real sheet exactly; committing to invented fixed pixel offsets here would only
/// manufacture a false sense of precision, and flow layout is what keeps a variably-present
/// `statusMessage` (see below) from ever growing into the space reserved for what follows it --
/// exactly the class of "stamped position collides with content when an optional element is
/// absent" defect `CoachingHQView`'s own `fixtureStackMaxHeight` fix (`04dc0b3`) recorded. This
/// gap is recorded here rather than resolved, per the adaptation rule's own instruction to record
/// rather than silently substitute.
///
/// **Rulings this file follows (dispatch, 2026-08-31):**
/// 1. The sheet's drawn ember, "Grant the visit", is refused: granting a recruiting visit from the
///    Inbox is a composition action, and `docs/reviews/2026-08-22-all-screen-presentation-contract.md`
///    row 9 forbids one on this surface ("No recommendation, countdown, receipt, undo,
///    reply/composition action, or message evidence beyond the retained item fields"). No such
///    control is drawn and no callback for one exists.
/// 2. The ember is `onContinue`, matching the contract's own Inbox callback list. Its cost is never
///    invented: disabled, `emberCost` is `model.continueReason` verbatim; enabled, it names how
///    many of the retained items still carry a deadline (`openDeadlineItemCount`) -- ordinarily
///    zero once nothing is blocking, a legal under-spend in the same sense `CoachingHQView`'s own
///    "0 DUE" is (that file's header comment, deviation-adjacent note on `emberCost`).
/// 3. Zero gold, anywhere -- `goldElementCount` is 0 and `DesignContractTests.swift` asserts it
///    directly rather than trusting this comment. Unread and deadline states read through the four
///    fixed signals (`04` 6.1e / 6.6a's "status is a signal dot... filled for open and hollow for
///    closed"): a decision or task is open work with a stated deadline (`signal-caution`) while
///    unread, a story is the simulation's own past-tense report (`signal-good`) while unread, and a
///    read item of either kind quiets to `ink4` -- `isUnread` tracks visibility, not resolution, so
///    this screen never claims a read decision is thereby handled. Selection (the row currently
///    open in the reading pane) is an `ember`-coloured boundary stroke, drawn only on the selected
///    row, never a filled band of any colour, gold or otherwise.
/// 4. No ghost mark, no flood, anywhere in this file. The chrome bar's own 3 pt spine (shared
///    furniture on every Forge Field surface, `ForgeFieldChromeBar.swift`) is the only club colour
///    this screen carries -- nothing here draws a second one.
/// 5. Rows are `ForgeFieldRow(.touch)` (44 pt), never `.dense` (32 pt): Inbox rows route
///    (`onOpen`) and mark read (`onRead`) on tap, and `04` 6.3a licenses the dense tier only when
///    the whole row is inert. `DesignContractTests.swift` scans this file's own source for that.
///
/// **One background, ground 1 only.** The budget stamps exactly one background colour for this
/// surface. `ForgeFieldPanel` always fills `ground2` (its own doc comment), so using it anywhere
/// here -- for the message list, the reading pane, or a card around either -- would spend a second,
/// unstamped background. Every row and the reading pane instead sit directly on the one `ground1`
/// fill this file draws once, separated by `ForgeFieldSeam` hairlines rather than panel boxes.
public struct InboxView: View, CoachWorldChromedSurface {
    /// The shared management chrome. Nil renders a minimal fallback bar carrying only team
    /// identity -- in production this is always populated when `model` is (both come from the
    /// same `store.inbox`), so the fallback exists for previews and tests only.
    public var chrome: FloodlitChromeReadModel?
    public var onNavigateChrome: ((CoachWorldIntentID) -> Void)?

    public let model: InboxReadModel
    public let statusMessage: String?
    public let onClose: () -> Void
    public let onOpen: (CoachWorldScreenID) -> Void
    public let onRead: (String) -> Void
    public let onContinue: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.forgeFieldClub) private var club
    @State private var selectedID: String = ""

    public init(
        model: InboxReadModel,
        statusMessage: String? = nil,
        onClose: @escaping () -> Void,
        onOpen: @escaping (CoachWorldScreenID) -> Void,
        onRead: @escaping (String) -> Void = { _ in },
        onContinue: @escaping () -> Void
    ) {
        self.model = model
        self.statusMessage = statusMessage
        self.onClose = onClose
        self.onOpen = onOpen
        self.onRead = onRead
        self.onContinue = onContinue
    }

    public var body: some View {
        ForgeFieldDevice(club: InboxMetric.club) {
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

    // MARK: Standard composition -- `04` 6.1f (chrome) plus this file's own flow-laid body. See
    // the header comment for why the body is flow-laid rather than absolutely positioned.

    private var standardComposition: some View {
        ZStack(alignment: .topLeading) {
            chromeBarRegion
                .frame(width: InboxMetric.chromeSize.width, height: InboxMetric.chromeSize.height)
                .position(InboxMetric.center(InboxMetric.chromeOrigin, InboxMetric.chromeSize))

            bodyContent
                .padding(InboxMetric.inset)
                .frame(width: InboxMetric.bodySize.width, height: InboxMetric.bodySize.height,
                       alignment: .topLeading)
                .background(club.palette.ground1.color)
                .position(InboxMetric.center(InboxMetric.bodyOrigin, InboxMetric.bodySize))
        }
        .accessibilitySortPriority(100)
    }

    private var bodyContent: some View {
        VStack(alignment: .leading, spacing: .zero) {
            header
            if let statusMessage {
                statusBanner(statusMessage)
            }
            listAndPane
                .frame(maxHeight: .infinity, alignment: .top)
            HStack {
                Spacer(minLength: .zero)
                ember
            }
            .padding(.top, InboxMetric.gap)
        }
    }

    @ViewBuilder
    private var listAndPane: some View {
        if model.items.isEmpty {
            styledText("Inbox is clear. No decisions or current-week stories are recorded.", .prose)
                .foregroundStyle(club.palette.ink3.color)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            HStack(alignment: .top, spacing: .zero) {
                messageList
                    .frame(width: InboxMetric.listWidth)
                ForgeFieldSeam(.hair, axis: .vertical)
                    .padding(.horizontal, InboxMetric.columnGap)
                readingPane
            }
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
        HStack(spacing: InboxMetric.gap) {
            // The rail is the way back once the chrome is present; this link only exists for the
            // bare stage, where nothing else leaves this screen -- matching the Press Box surface
            // this file replaces.
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
                    .frame(width: InboxMetric.chromeSize.height, height: InboxMetric.chromeSize.height)
                    .background(club.palette.ground3.color)
            }
            styledText(model.team.name.uppercased(), .chrome)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(1)
            Spacer(minLength: .zero)
        }
        .padding(.horizontal, InboxMetric.gap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(club.palette.ground1.color)
    }

    // MARK: Header -- this surface's own identity, never repeating the chrome bar's week (`04`
    // 6.1f already states it once; the `WEEK 1 · WEEK 1` defect `CoachingHQView.swift` fixed is
    // exactly what re-stating it here would reintroduce).

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: InboxMetric.gap) {
            styledText("INBOX", .panel)
                .foregroundStyle(club.palette.ink4.color)
            Spacer(minLength: InboxMetric.gap)
            if unreadCount > 0 {
                styledText("\(unreadCount) UNREAD", .figure)
                    .foregroundStyle(ForgeFieldTokens.Fixed.signalCaution.color)
                    .accessibilityLabel("\(unreadCount) unread")
            }
        }
        .padding(.bottom, InboxMetric.gap)
    }

    private var unreadCount: Int { model.items.filter(\.isUnread).count }

    /// The save-status receipt -- it has to reach the player while they are playing, matching the
    /// priority `CoachingHQView.decisionCaption` gives the same fact. `signal-alarm`: this is the
    /// `failure` half of `CoachWorldAppRootView`'s `failure ?? store.statusMessage`, "broken now"
    /// in `04` 6.1e's own words for that signal.
    private func statusBanner(_ text: String) -> some View {
        styledText(text, .proseMin)
            .foregroundStyle(ForgeFieldTokens.Fixed.signalAlarm.color)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, InboxMetric.gap)
    }

    // MARK: Message list -- the feed. Every retained item stays reachable by scrolling; nothing is
    // capped the way `CoachingHQView`'s three obligation tiles are, because this surface's register
    // detail names it "the feed" and there is no second Inbox for an overflow caption to route to.
    // `InboxView.referenceRowCount` (assertable facts, below) is a data-point-budget accounting
    // convention over what the standard composition's viewport shows before scrolling, not a cap on
    // the rendered content.

    private var messageList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .zero) {
                ForEach(model.items) { item in
                    row(for: item, width: InboxMetric.listWidth)
                    ForgeFieldSeam(.hair, axis: .horizontal)
                }
            }
        }
    }

    /// One row, 44 pt (ruling 5), shared by the standard list (fixed width) and the AX5 stack
    /// (`width: nil`, matching `CoachingHQView.tile`'s own convention for the same reason).
    private func row(for item: InboxReadModel.Item, width: CGFloat?) -> some View {
        let isSelected = selected?.stableID == item.stableID
        let content = HStack(spacing: InboxMetric.gap) {
            styledText(tag(for: item).uppercased(), .columnHead)
                .foregroundStyle(tone(for: item))
                .lineLimit(1)
                .frame(width: InboxMetric.tagColumn, alignment: .leading)
            VStack(alignment: .leading, spacing: InboxMetric.tightGap) {
                styledText(item.title, .row)
                    .foregroundStyle(
                        item.isUnread ? club.palette.ink1.color : club.palette.ink3.color)
                    .lineLimit(InboxMetric.subjectLines)
                    .multilineTextAlignment(.leading)
                styledText(item.sourceLabel.uppercased(), .columnHead)
                    .foregroundStyle(club.palette.ink4.color)
                    .lineLimit(1)
            }
            Spacer(minLength: .zero)
        }
        .padding(.horizontal, InboxMetric.gap)
        .frame(maxWidth: width, alignment: .leading)

        return Button {
            selectedID = item.stableID
            onRead(item.stableID)
        } label: {
            ForgeFieldRow(.touch) { content }
                .overlay {
                    // Ruling 3: selection is an ember-coloured boundary, drawn only when selected --
                    // never a filled band, gold or otherwise (matching `CoachingHQView.tile`'s own
                    // selection treatment, `04` 6.3: "Selected items receive boundary, value and
                    // spoken state; never a coloured fill alone").
                    if isSelected {
                        RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
                            .strokeBorder(club.palette.ember.color,
                                          lineWidth: ForgeFieldTokens.Edge.hairlineWidth)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "\(item.title), from \(item.sourceLabel), "
                + "\(item.isUnread ? "unread" : "read") \(item.kind.rawValue)"
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// The message the reading pane shows. Selection is presentation state, so it falls back to the
    /// first message rather than carrying an empty pane -- matching the Press Box surface this file
    /// replaces.
    private var selected: InboxReadModel.Item? {
        model.items.first { $0.stableID == selectedID } ?? model.items.first
    }

    // MARK: Reading pane -- the opened message, whole, with what it is waiting on.

    @ViewBuilder
    private var readingPane: some View {
        if let item = selected {
            VStack(alignment: .leading, spacing: InboxMetric.gap) {
                HStack(spacing: InboxMetric.gap) {
                    styledText(item.sourceLabel.uppercased(), .columnHead)
                        .foregroundStyle(club.palette.ink3.color)
                    Spacer(minLength: InboxMetric.tightGap)
                    styledText(tag(for: item).uppercased(), .columnHead)
                        .foregroundStyle(tone(for: item))
                }
                styledText(item.title, .heading)
                    .foregroundStyle(club.palette.ink1.color)
                    .fixedSize(horizontal: false, vertical: true)
                styledText(item.body, .prose)
                    .foregroundStyle(club.palette.ink2.color)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: InboxMetric.sectionGap) {
                    styledText(item.received, .figure)
                        .foregroundStyle(club.palette.ink4.color)
                    if let deadline = item.deadline {
                        styledText(deadline, .figure)
                            .foregroundStyle(ForgeFieldTokens.Fixed.signalCaution.color)
                    }
                }
                if let destination = item.destination {
                    // A navigation action (`onOpen`), already in the contract's own Inbox callback
                    // list -- ruling 1 refuses a *composition* action, not the pre-existing route
                    // this button already carried before this file's conversion.
                    Button {
                        onRead(item.stableID)
                        onOpen(destination)
                    } label: {
                        buttonLabelText("Open \(destination.navigationName.uppercased())")
                            .foregroundStyle(club.palette.ink3.color)
                            .frame(minHeight: ForgeFieldTokens.Space.hitMin, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: .zero)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// The tag the row and reading pane both print at the head: what the message wants, not what
    /// kind of object it is. A decision is waiting on the coach; a task is on the staff; a story is
    /// only news. Ported unchanged from the Press Box surface this file replaces.
    private func tag(for item: InboxReadModel.Item) -> String {
        switch item.kind {
        case .decision: item.deadline == nil ? "Decide" : "Due"
        case .task: "To do"
        case .story: item.isUnread ? "New" : "Filed"
        }
    }

    /// Ruling 3: unread and deadline states read through the four fixed signals, never an invented
    /// fifth (`04` 6.1e / 6.6a). A decision or task is open work with a stated deadline --
    /// `signal-caution`, "a deadline is running" -- while unread; a story is the simulation's own
    /// past-tense report, already resolved by the time it reaches this screen -- `signal-good`,
    /// "handled" -- while unread. Read items of either kind quiet to `ink4`: `isUnread` tracks
    /// visibility, not resolution, so this screen does not claim more than the model states.
    private func tone(for item: InboxReadModel.Item) -> Color {
        guard item.isUnread else { return club.palette.ink4.color }
        switch item.kind {
        case .decision, .task: return ForgeFieldTokens.Fixed.signalCaution.color
        case .story: return ForgeFieldTokens.Fixed.signalGood.color
        }
    }

    // MARK: Ember -- the one commit, `04` 6.1e. Ruling 2: cost is `continueReason` verbatim when
    // continuing is blocked, never invented; otherwise it names the retained items' own deadline
    // count.

    private var openDeadlineItemCount: Int {
        model.items.filter { $0.deadline != nil }.count
    }

    /// `continueReason` is already sentence case from the provider
    /// (`CoachWorldInboxProvider.swift`) and stays that way here -- `04` 6.2a: "Never uppercase a
    /// sentence." The enabled branch's own count line is a short label, so it follows the label
    /// convention instead (matching `CoachingHQView.emberCost`'s identical "\\(count) DUE" shape).
    private var emberCost: String {
        model.continueReason ?? "\(openDeadlineItemCount) DUE"
    }

    private var ember: some View {
        ForgeFieldEmber(label: "ADVANCE", cost: emberCost, isEnabled: model.canContinue, action: onContinue)
    }

    // MARK: Accessible composition -- AX5 reflows to one scrollable column, `04` section 7 and the
    // Forge Field spec section 4: "cut rows, never shrink type... AX5 removes rows rather than
    // compressing them." Every item stays listed -- nothing is dropped, matching the Press Box
    // surface this file replaces, which stacked the same two sections instead of placing them side
    // by side.

    private var accessibleComposition: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: InboxMetric.sectionGap) {
                chromeBarRegion
                header
                if let statusMessage {
                    statusBanner(statusMessage)
                }
                if model.items.isEmpty {
                    styledText(
                        "Inbox is clear. No decisions or current-week stories are recorded.", .prose
                    )
                    .foregroundStyle(club.palette.ink3.color)
                } else {
                    VStack(alignment: .leading, spacing: .zero) {
                        ForEach(model.items) { item in
                            row(for: item, width: nil)
                            ForgeFieldSeam(.hair, axis: .horizontal)
                        }
                    }
                    ForgeFieldSeam(.hard, axis: .horizontal)
                    readingPane
                }
                HStack {
                    Spacer(minLength: .zero)
                    ember
                }
            }
            .padding(.horizontal, InboxMetric.inset)
            .padding(.bottom, InboxMetric.sectionGap)
        }
        .accessibilitySortPriority(100)
    }

    // MARK: Shared text helpers

    private func styledText(_ string: String, _ step: ForgeFieldType.Step) -> Text {
        Text(string)
            .font(ForgeFieldType.font(step))
            .tracking(CoachWorldTokens.DisplaySize.tracking(step.tracking, at: step.points))
    }

    /// `Step.chrome`'s default tracking is the club lockup's `.11em`, wrong for a button label
    /// (`.14em`) -- `ForgeFieldType.swift`'s own doc comment on `.chrome` names this exact split,
    /// and `CoachingHQView.secondaryLink` already makes the same correction for its own button-style
    /// links. `styledText` above intentionally does not special-case this; call sites that need the
    /// button tracking call this instead.
    private func buttonLabelText(_ string: String) -> Text {
        Text(string)
            .font(ForgeFieldType.font(.chrome))
            .tracking(CoachWorldTokens.DisplaySize.tracking(
                ForgeFieldType.Tracking.chrome.em, at: ForgeFieldType.Step.chrome.points
            ))
    }
}

// MARK: - Geometry

/// Geometry this file composes itself -- see the header comment's "no sheet geometry was available"
/// note. Only the chrome bar's position is a true shared constant; everything below it is this
/// file's own choice from `ForgeFieldTokens.Space.ladder`, named once here rather than inlined at
/// each call site, matching `HQMetric`'s own convention (`CoachingHQView.swift`).
private enum InboxMetric {
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
    static let columnGap = ForgeFieldTokens.Space.ladder[3]   // 16

    static let listWidth: CGFloat = 320
    static let tagColumn: CGFloat = 60
    static let subjectLines = 2

    /// This surface's own header block, as drawn -- estimated rather than measured, since nothing
    /// downstream depends on the estimate being exact (the body is flow-laid; see the header
    /// comment). Used only by `InboxView.referenceRowCount` below, so the data-point accounting
    /// reads from the same named quantities the view itself uses rather than a second, independent
    /// guess.
    static let headerEstimatedHeight: CGFloat = 28
    static let emberRowHeight = ForgeFieldTokens.Space.rowTouch

    static let listPaneAreaHeight =
        bodySize.height - 2 * inset - headerEstimatedHeight - gap - emberRowHeight - gap

    static func center(_ origin: CGPoint, _ size: CGSize) -> CGPoint {
        CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
}

// MARK: - Assertable budget facts

extension InboxView {
    /// Facts drawn once per surface -- the header's own unread count. Counted as one role
    /// regardless of whether it renders for a given save (zero unread items omits it), matching
    /// `CoachingHQView.floodFieldDataPoints`' own treatment of a fact that can be legitimately
    /// absent.
    public static let headerDataPointRoles: [String] = ["header.unreadCount"]

    /// Facts drawn once per visible row. Prefixed (`row.` below, `pane.` on
    /// `readingPaneDataPointRoles`) rather than bare names: the row's own tag and the reading
    /// pane's tag are two separate on-screen instances of the same fact for the selected item, both
    /// genuinely occupying the budget, not one role double-declared -- the prefix keeps that an
    /// honest count instead of a name collision the distinctness check below would flag by
    /// accident.
    public static let rowDataPointRoles: [String] = ["row.tag", "row.title", "row.sourceLabel"]

    /// Facts drawn once for the reading pane's own selected item. `pane.destinationLabel` is
    /// counted even though `item.destination` is sometimes nil (a story never routes anywhere), for
    /// the same reason as `headerDataPointRoles` above.
    public static let readingPaneDataPointRoles: [String] = [
        "pane.sourceLabel", "pane.tag", "pane.title", "pane.body", "pane.received",
        "pane.deadline", "pane.destinationLabel",
    ]

    /// How many rows the standard composition's list column shows in full before its own height
    /// requires scrolling for the rest -- `InboxMetric.listPaneAreaHeight` /
    /// `ForgeFieldTokens.Space.rowTouch`, floored. This is the data-point budget's reference count,
    /// matching a density budget's usual convention of measuring what a reader sees before
    /// interacting: scrolling further reveals more instances of the same three-field row template,
    /// not a new fact type, so it does not add to this count. **The view itself does not cap the
    /// list to this number** -- `messageList` above renders every one of `model.items` inside a
    /// `ScrollView`, because this surface's register detail names it "the feed" and every retained
    /// item must stay reachable.
    public static let referenceRowCount =
        max(0, Int(InboxMetric.listPaneAreaHeight / ForgeFieldTokens.Space.rowTouch))

    /// `ForgeFieldBudget.weeklyCommand[.inbox]`'s `dataPoints` (58, desk ceiling 80) is asserted
    /// against this total in `DesignContractTests.swift`, not restated. Without this environment's
    /// sheet access (header comment), this total cannot be shown to equal the stamped 58 exactly;
    /// it is checked as "at or under", matching this family's Task 2-10 step list's own wording.
    public static let dataPointCount =
        headerDataPointRoles.count
            + rowDataPointRoles.count * referenceRowCount
            + readingPaneDataPointRoles.count

    /// Ruling 3: zero, anywhere on this surface.
    public static let goldElementCount = 0

    /// One `ForgeFieldEmber(` call site in this file -- `ADVANCE`.
    public static let emberElementCount = 1

    /// This surface's own one background: the body's `ground1` fill. The shared chrome bar's own
    /// ground is furniture, not counted here, the same exclusion `CoachingHQView.backgroundCount`
    /// states for its own flood field.
    public static let backgroundCount = 1

    /// No flood at all -- ruling 4.
    public static let stageFraction: Double = 0.0

    /// Ruling 4: no ghost mark.
    public static let hasGhostMark = false
}
