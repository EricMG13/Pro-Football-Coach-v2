import SwiftUI

/// Coaching HQ, drawn to the Forge Field standard -- `04` sections 6.1e, 6.1f, 6.2a, 6.2a(i),
/// 6.3a, 6.6a, 6.7a and 7. Phase 2B Task 2 of
/// `docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md`.
///
/// Replaces the Press Box `CoachWorldFloodlitStage` composition this surface drew before with
/// `ForgeFieldDevice` and the four Forge Field primitives (`ForgeFieldPanel`, `ForgeFieldSeam`,
/// `ForgeFieldRow`, `ForgeFieldChip`) plus `ForgeFieldEmber` and `ForgeFieldType`. Fixes the three
/// defects ledger Part E records against this surface:
///
/// - `WEEK 1 · WEEK 1` -- the old `weekAgendaColumn` concatenated `week.weekLabel` and
///   `week.currentDay`, which the provider sets to the identical string (the calendar's finest
///   grain is a week, so "current day" has nothing finer to say). This file never concatenates
///   the two; the chrome bar states the week once, and nothing on this surface repeats it.
/// - `WHY IT IS HERE` rendering as a heading with nothing under it -- the old view always drew the
///   label and only conditionally drew `decision.evidence.first` after it. This file never draws
///   a label it cannot pair with real content: the caption row is decision evidence, an honest
///   overflow count, or the save-status receipt -- never a label alone.
/// - `ADVANCE` rendered gold -- gold is earned standing only (`04` 6.1e); the commit is the ember.
///   `ember` below is the single `ForgeFieldEmber` this surface carries, styled from the club's
///   ember ramp, never gold.
///
/// **Read-model backing added alongside this surface** (`ScreenReadModels.swift`,
/// `CoachWorldReadModelProvider.swift`): `opponentRecordLabel`, `opponentRankLabel`, `isHomeGame`
/// and `currentStreak`. Every one is computed from state the engine already holds --
/// `recordLabel`/`rankLabel` are generic over the organisation, `ScheduledGame` already carries
/// `homeID`/`awayID`, and the streak walks the same schedule `recordLabel` already reads. No
/// change to `FootballSimCore`.
///
/// **Deviations from the sheet, adaptation rule (owner directive 2026-08-30):**
/// 1. The kickoff line has no clock: `WeekContext` carries no kickoff time, so inventing one is
///    prohibited. It also states the week rather than a day of the week -- the calendar's finest
///    grain is a week (see the `WEEK 1 · WEEK 1` note above), so a literal "SATURDAY" would be an
///    invented fact. Recorded, not silently substituted.
/// 2. The standing badge ships at `Step.columnHead` (10 pt), not the sheet's 9 -- `04` 6.2a(i)
///    already raised this floor for every surface, not just this one.
/// 3. The badge draws the coach's own plain streak (`model.currentStreak`, "WON 4"), never
///    "longest active streak in the league" -- that superlative needs the identical walk repeated
///    for every team in the tier, which this pass does not spend. One gold is still spent on the
///    record line regardless of whether the badge itself renders (2 of the 3 gold ceiling), so a
///    week with no finished games yet spends only 1 -- legal under-spend, not an omission of the
///    surface's earned standing.
/// 4. The ember's cost line names `mandatoryCount` -- the open-obligation count that is *also* why
///    it is disabled, matching `ForgeFieldEmber`'s own documented rule that the cost line carries
///    the disable reason. There is no freshness system to cost against.
/// 5. The two mandatory-decision options are drawn as plain tiles, never embers -- `04` 6.1e: an
///    action with no cost worth naming is not an ember. Their honest absence
///    (`"No recorded cost"`, `CoachWorldReadModelProvider.swift`) prints in the same quiet ink and
///    weight the tile would use for a real cost, not shouted in caps.
/// 6. The obligation/decision overflow the sheet never answers: a week with more open work than
///    the three tiles hold states the remaining count and routes to Inbox (which already lists
///    every one of them -- `CoachWorldInboxProvider.swift`) rather than dropping it silently.
/// 7. Long generated club/opponent names scale down (`minimumScaleFactor`) rather than truncating
///    illegibly at 62 pt across an 832 pt column.
/// 8. `onInspect` (film) and `onDelegate`/`onPrepare` have no stamped position on the sheet, which
///    draws only the ember at this geometry -- they render as a small quiet link row, each control
///    still clearing the 44 pt hit floor. The overflow/evidence caption row (item 6) does not
///    independently clear 44 pt when it is the rare tappable case; the same destination (Inbox) is
///    always separately reachable, so missing this specific link is recoverable, not a dead end.
public struct CoachingHQView: View, CoachWorldChromedSurface {
    /// The shared management chrome. Nil renders a minimal fallback bar carrying only team
    /// identity -- in production this is always populated when `model` is (both come from the
    /// same `store.coachingHQ`), so the fallback exists for previews and tests only.
    public var chrome: FloodlitChromeReadModel?
    public var onNavigateChrome: ((CoachWorldIntentID) -> Void)?

    public let model: CoachingHQReadModel
    public let statusMessage: String?
    public let onCommit: (CoachWorldIntentID) -> Void
    public let onInspect: () -> Void
    public let onDelegate: () -> Void
    public let onPrepare: () -> Void
    public let onContinue: () -> Void
    public let onOpenCorrespondence: (String) -> Void
    public let onNavigate: (CoachWorldScreenID) -> Void
    public let showsProOffseason: Bool
    public let showsDraftRoom: Bool
    public let showsSigningDay: Bool
    public let showsCollegeOffseason: Bool
    public let showsProManagement: Bool
    public let showsContractNegotiation: Bool
    public let showsRecruitingBoard: Bool
    public let showsRealignmentEvent: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.forgeFieldClub) private var club
    @State private var selectedChoiceID: CoachWorldIntentID?

    public init(
        model: CoachingHQReadModel,
        statusMessage: String? = nil,
        onCommit: @escaping (CoachWorldIntentID) -> Void,
        onInspect: @escaping () -> Void,
        onDelegate: @escaping () -> Void,
        onPrepare: @escaping () -> Void,
        onContinue: @escaping () -> Void,
        onOpenCorrespondence: @escaping (String) -> Void,
        onNavigate: @escaping (CoachWorldScreenID) -> Void,
        showsProOffseason: Bool = false,
        showsDraftRoom: Bool = false,
        showsSigningDay: Bool = false,
        showsCollegeOffseason: Bool = false,
        showsProManagement: Bool = false,
        showsContractNegotiation: Bool = false,
        showsRecruitingBoard: Bool = false,
        showsRealignmentEvent: Bool = false
    ) {
        self.model = model
        self.statusMessage = statusMessage
        self.onCommit = onCommit
        self.onInspect = onInspect
        self.onDelegate = onDelegate
        self.onPrepare = onPrepare
        self.onContinue = onContinue
        self.onOpenCorrespondence = onOpenCorrespondence
        self.onNavigate = onNavigate
        self.showsProOffseason = showsProOffseason
        self.showsDraftRoom = showsDraftRoom
        self.showsSigningDay = showsSigningDay
        self.showsCollegeOffseason = showsCollegeOffseason
        self.showsProManagement = showsProManagement
        self.showsContractNegotiation = showsContractNegotiation
        self.showsRecruitingBoard = showsRecruitingBoard
        self.showsRealignmentEvent = showsRealignmentEvent
    }

    public var body: some View {
        ForgeFieldDevice(club: HQMetric.club) {
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

    // MARK: Standard composition -- fixed positions, `04` 6.1f and the Task 2 spec column.

    private var standardComposition: some View {
        ZStack(alignment: .topLeading) {
            chromeBarRegion
                .frame(width: HQMetric.chromeSize.width, height: HQMetric.chromeSize.height)
                .position(HQMetric.center(HQMetric.chromeOrigin, HQMetric.chromeSize))

            ZStack(alignment: .topTrailing) {
                club.palette.clubDeep.color
                ghostMark
                fixtureCard
            }
            .frame(width: HQMetric.floodSize.width, height: HQMetric.floodSize.height)
            .clipped()
            .position(HQMetric.center(HQMetric.floodOrigin, HQMetric.floodSize))

            ember
                .frame(width: HQMetric.emberSize.width)
                .position(HQMetric.center(HQMetric.emberOrigin, HQMetric.emberSize))

            ForgeFieldSeam(.hard, axis: .horizontal)
                .frame(width: HQMetric.columnWidth)
                .position(x: HQMetric.floodOrigin.x + HQMetric.columnWidth / 2, y: HQMetric.seamOriginY)

            obligationsPanel
                .frame(width: HQMetric.obligationsSize.width, height: HQMetric.obligationsSize.height)
                .position(HQMetric.center(HQMetric.obligationsOrigin, HQMetric.obligationsSize))
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
        HStack(spacing: HQMetric.gap) {
            ForgeFieldChip {
                Text(model.team.abbreviation.uppercased())
                    .font(ForgeFieldType.font(.chrome))
                    .foregroundStyle(club.palette.ink1.color)
                    .frame(width: HQMetric.chromeSize.height, height: HQMetric.chromeSize.height)
                    .background(club.palette.ground3.color)
            }
            styledText(model.team.name.uppercased(), .chrome)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(1)
            Spacer(minLength: .zero)
        }
        .padding(.horizontal, HQMetric.gap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(club.palette.ground1.color)
    }

    // MARK: Flood field -- the fixture card. `04` 6.1e/2.1: Broadcast, club colour flooded.

    /// The nine authored facts above the hard seam, `ForgeFieldBudget.weeklyCommand[.coachingHQ]`'s
    /// `pointsAboveSeam`. See the static `floodFieldDataPoints` list below for the enumerated,
    /// testable form of this same claim.
    @ViewBuilder
    private var fixtureCard: some View {
        if let opponent = model.opponent {
            VStack(spacing: HQMetric.floodStackGap) {
                if hasSecondaryLinks {
                    HStack(spacing: HQMetric.gap) { secondaryLinks }
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                styledText(kickoffLine, .columnHead)
                    .foregroundStyle(club.palette.ink3.color)
                    .lineLimit(1)

                HStack(alignment: .top, spacing: HQMetric.sectionGap) {
                    fixtureHalf(
                        name: displayName(for: model.team), standing: ourStandingLine,
                        standingInk: nil
                    )
                    styledText("v", .heading)
                        .foregroundStyle(club.palette.ink4.color)
                    fixtureHalf(
                        name: displayName(for: opponent), standing: opponentStandingLine,
                        standingInk: club.palette.ink3.color
                    )
                }

                if let streak = model.currentStreak {
                    styledText("\u{2605} \(streak.uppercased())", .columnHead)
                        .foregroundStyle(ForgeFieldTokens.Fixed.gold.color)
                }
            }
            .padding(.top, HQMetric.inset)
        } else {
            VStack(spacing: HQMetric.gap) {
                styledText(displayName(for: model.team).uppercased(), .fixture)
                    .foregroundStyle(club.palette.ink1.color)
                    .lineLimit(1)
                    .minimumScaleFactor(HQMetric.nameScaleFloor)
                styledText("NO GAME SCHEDULED THIS WEEK", .heading)
                    .foregroundStyle(club.palette.ink2.color)
            }
        }
    }

    /// The name a fixture-size (62 pt) column can hold without truncating, deviation 7 (revised).
    /// Scaling text to fit is a defect at the same severity as truncating it once the scale passes
    /// a point a reader can no longer call comfortable -- `04` 6.2a(i)'s type floors bind before a
    /// name shrinks arbitrarily far, and 62 pt scaled to illegibility is not meaningfully different
    /// from an ellipsis. So this is a layout choice, not a smaller number: a name over
    /// `nameCharacterCeiling` prints its nickname instead of its full institution-plus-nickname or
    /// city-plus-nickname form -- `Programme.nickname` / `ProTeam.nickname`, a real structured
    /// field the generator already carries, never a guess split off the joined name. "Claremont
    /// State Basalt Ferrymen" (32 characters) becomes "Basalt Ferrymen": shorter, still the club's
    /// own identity, and it clears the column at full fixture size on every generated name
    /// measured. `minimumScaleFactor(nameScaleFloor)` stays as a narrow safety net under that --
    /// 0.75 (46.5 pt, still above `Step.title`) -- for the rare nickname that alone still runs
    /// long (the adjective/noun pools top out around "Meridian Wheelwrights").
    private func displayName(for team: CoachWorldTeamReference) -> String {
        guard team.name.count > HQMetric.nameCharacterCeiling, let nickname = team.nickname
        else { return team.name }
        return nickname
    }

    /// The oversized ghost mark, standard section 2.7 (via `ForgeFieldBudget`): 244 pt, .10
    /// opacity, bleeding the flood field's top-right corner. No club logo asset exists to ghost --
    /// `04` section 6.6a's mark vocabulary is an abstract plate, never an image -- so this is that
    /// same plate shape, oversized and faint, rather than an invented crest.
    private var ghostMark: some View {
        RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
            .fill(club.palette.hairline.color)
            .frame(width: HQMetric.ghostSize, height: HQMetric.ghostSize)
            .opacity(HQMetric.ghostOpacity)
            .offset(x: HQMetric.ghostSize / 2, y: -HQMetric.ghostSize / 2)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private func fixtureHalf(name: String, standing: String, standingInk: Color?) -> some View {
        VStack(alignment: .leading, spacing: HQMetric.tightGap) {
            styledText(name.uppercased(), .fixture)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(1)
                .minimumScaleFactor(HQMetric.nameScaleFloor)
            styledText(standing, .figure)
                .foregroundStyle(standingInk ?? ForgeFieldTokens.Fixed.gold.color)
                .lineLimit(1)
        }
    }

    /// Our record and rank folded into one gold line -- earned standing, `04` 6.1e. Two of the
    /// nine authored facts (`ourRecord`, `ourRank`), one gold spend.
    private var ourStandingLine: String {
        guard let rank = model.rankLabel else { return model.recordLabel }
        return "\(model.recordLabel) \u{00B7} \(rank)"
    }

    /// The opponent's mirror of `ourStandingLine`, never gold -- "none of this standing is ours."
    private var opponentStandingLine: String {
        let record = model.opponentRecordLabel ?? "Record unavailable"
        guard let rank = model.opponentRankLabel else { return record }
        return "\(record) \u{00B7} \(rank)"
    }

    /// Home/away and venue, folded into one printed line -- two of the nine authored facts
    /// (`homeOrAway`, `venue`), no invented kickoff time (deviation 1).
    private var kickoffLine: String {
        var parts: [String] = []
        if let isHome = model.isHomeGame { parts.append(isHome ? "HOME" : "AWAY") }
        if let venue = model.venue { parts.append(venue.name.uppercased()) }
        return parts.joined(separator: " \u{00B7} ")
    }

    private var hasSecondaryLinks: Bool {
        model.opponent != nil || model.decision != nil || preparationNeeded
    }

    @ViewBuilder
    private var secondaryLinks: some View {
        if model.opponent != nil {
            secondaryLink("FILM", action: onInspect)
        }
        if model.decision != nil {
            secondaryLink("DELEGATE", action: onDelegate)
        } else if preparationNeeded {
            secondaryLink("DELEGATE", action: onPrepare)
        }
    }

    private func secondaryLink(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(ForgeFieldType.font(.chrome))
                .tracking(CoachWorldTokens.DisplaySize.tracking(
                    ForgeFieldType.Tracking.chrome.em, at: ForgeFieldType.Step.chrome.points
                ))
                .foregroundStyle(club.palette.ink3.color)
                .frame(minWidth: ForgeFieldTokens.Space.hitMin, minHeight: ForgeFieldTokens.Space.hitMin)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }

    // MARK: Ember -- the one commit, `04` 6.1e. Deviation 4: cost names the open-obligation count.

    private var emberCost: String { "\(mandatoryCount) DUE" }

    private var ember: some View {
        ForgeFieldEmber(label: "ADVANCE", cost: emberCost, isEnabled: canAdvance, action: onContinue)
    }

    // MARK: Obligations panel -- decision choices when one is pending, else the week's obligations.

    private var obligationsPanel: some View {
        ForgeFieldPanel {
            VStack(alignment: .leading, spacing: HQMetric.gap) {
                obligationsPanelContent
            }
            .padding(.horizontal, ForgeFieldTokens.Space.margin)
            .padding(.top, HQMetric.inset)
        }
    }

    @ViewBuilder
    private var obligationsPanelContent: some View {
        if let decision = model.decision {
            HStack(spacing: HQMetric.tileGap) {
                ForEach(decision.choices, id: \.intentID) { choice in
                    tile(
                        title: choice.title, secondary: choice.cost,
                        isSelected: selectedChoiceID == choice.intentID
                    ) {
                        selectedChoiceID = choice.intentID
                        onCommit(choice.intentID)
                    }
                }
            }
            if let caption = decisionCaption(decision) {
                captionRow(caption)
            }
        } else if !model.obligations.isEmpty {
            HStack(spacing: HQMetric.tileGap) {
                ForEach(model.obligations.prefix(3), id: \.stableID) { obligation in
                    tile(title: obligation.title, secondary: "Due \(obligation.due)", action: nil)
                }
            }
            if let caption = obligationsCaption {
                captionRow(caption)
            }
        } else {
            tile(title: "No mandatory work", secondary: "Nothing open this week", action: nil)
        }
    }

    /// Caption priority when a decision is dominant: the save-status receipt outranks everything
    /// (it has to reach the player while they are playing), then the honest overflow count when
    /// other obligations exist beyond this one, then the decision's own evidence -- deviation 6 and
    /// the `WHY IT IS HERE` fix: this label never renders without one of these three real strings.
    private func decisionCaption(_ decision: CoachingHQReadModel.Decision) -> Caption? {
        if let statusMessage { return Caption(text: statusMessage, action: nil) }
        if model.obligations.count > 1 {
            let more = model.obligations.count - 1
            return Caption(text: "+\(more) more this week \u{00B7} see Inbox") { onNavigate(.inbox) }
        }
        if let evidence = decision.evidence.first {
            return Caption(text: evidence, action: nil)
        }
        return nil
    }

    private var obligationsCaption: Caption? {
        if let statusMessage { return Caption(text: statusMessage, action: nil) }
        let overflow = model.obligations.count - 3
        guard overflow > 0 else { return nil }
        return Caption(text: "+\(overflow) more this week \u{00B7} see Inbox") { onNavigate(.inbox) }
    }

    private struct Caption {
        let text: String
        let action: (() -> Void)?

        init(text: String, action: (() -> Void)? = nil) {
            self.text = text
            self.action = action
        }
    }

    private func captionRow(_ caption: Caption) -> some View {
        let text = styledText(caption.text, .proseMin).foregroundStyle(club.palette.ink3.color)
        return Group {
            if let action = caption.action {
                // Deviation 8: this specific link does not independently clear the 44 pt floor --
                // Inbox, its destination, is always separately reachable, so missing it here is
                // recoverable rather than a dead end.
                Button(action: action) { text }
                    .buttonStyle(.plain)
            } else {
                text
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// One tile, 265 x 44, `ForgeFieldChip`-clipped -- shared by both the decision-choice and the
    /// plain-obligation rendering so the two modes cannot drift in style. `width: nil` (used only
    /// by the AX5 reflow) lets the tile take the full row width instead of the sheet's fixed 265.
    /// `isSelected` marks the most recently tapped decision choice -- `selectedChoiceID` -- with
    /// the ember colour boundary rather than a filled selection state, `04` section 6.3: "Selected
    /// items receive boundary, value and spoken state; never a coloured fill alone."
    private func tile(
        title: String, secondary: String, width: CGFloat? = HQMetric.tileWidth,
        isSelected: Bool = false,
        action: (() -> Void)?
    ) -> some View {
        let content = VStack(alignment: .leading, spacing: HQMetric.tightGap) {
            styledText(title.uppercased(), .row)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(1)
            // Deviation 5: `secondary` prints exactly as the read model states it, including the
            // honest `"No recorded cost"` sentinel, at this same quiet weight -- never uppercased
            // or otherwise styled to shout where a real cost would sit.
            styledText(secondary, .proseMin)
                .foregroundStyle(club.palette.ink3.color)
                .lineLimit(1)
        }
        .padding(.horizontal, HQMetric.gap)
        .frame(width: width, height: HQMetric.tileHeight, alignment: .leading)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .background(club.palette.ground3.color)
        .overlay {
            RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
                .strokeBorder(
                    isSelected
                        ? club.palette.ember.color
                        : club.palette.hairline.color.opacity(ForgeFieldTokens.Edge.panel),
                    lineWidth: ForgeFieldTokens.Edge.hairlineWidth
                )
        }

        return Group {
            if let action {
                Button(action: action) { ForgeFieldChip { content } }
                    .buttonStyle(.plain)
            } else {
                ForgeFieldChip { content }
            }
        }
    }

    // MARK: Accessible composition -- AX5 reflows to one scrollable column, `04` section 7 and the
    // Forge Field spec section 4: "cut rows, never shrink type." Nothing here is fixed-position.

    private var accessibleComposition: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HQMetric.sectionGap) {
                chromeBarRegion
                fixtureCard
                    .background(club.palette.clubDeep.color)
                ember
                ForgeFieldSeam(.hard, axis: .horizontal)
                VStack(alignment: .leading, spacing: HQMetric.gap) {
                    accessibleObligationsContent
                }
                ForgeFieldSeam(.hard, axis: .horizontal)
                legacyNavigation
            }
            .padding(.bottom, HQMetric.sectionGap)
        }
        .accessibilitySortPriority(100)
    }

    @ViewBuilder
    private var accessibleObligationsContent: some View {
        if let decision = model.decision {
            VStack(spacing: HQMetric.gap) {
                ForEach(decision.choices, id: \.intentID) { choice in
                    tile(
                        title: choice.title, secondary: choice.cost, width: nil,
                        isSelected: selectedChoiceID == choice.intentID
                    ) {
                        selectedChoiceID = choice.intentID
                        onCommit(choice.intentID)
                    }
                }
            }
            if let caption = decisionCaption(decision) {
                captionRow(caption)
            }
        } else if !model.obligations.isEmpty {
            VStack(spacing: HQMetric.gap) {
                ForEach(model.obligations, id: \.stableID) { obligation in
                    tile(title: obligation.title, secondary: "Due \(obligation.due)", width: nil, action: nil)
                }
            }
        } else {
            tile(
                title: "No mandatory work", secondary: "Nothing open this week", width: nil, action: nil
            )
        }
    }

    // MARK: Legacy full-reachability navigation, AX5 only.
    //
    // `04` 6.1f's chrome bar carries only the five families, by design -- the Broadcast
    // composition above has no room for more, and does not need it: FILM and DELEGATE in
    // `secondaryLinks` already cover this week's own actions. But most of the game's 62 screens
    // live in families Forge Field has not migrated yet (ledger row E6), and Coaching HQ is where
    // every one of their routes has lived since before Forge Field existed. Dropping that
    // reachability here would strand every one of those screens, so it is kept -- deliberately
    // only in the accessible composition, where `04` section 4.5's "AX5 reflows... preserving
    // order and dropping nothing" already licenses exactly this: full reachability, not the tight
    // broadcast card. It reads Press Box's own `CoachWorldActionButtonStyle` and
    // `CoachWorldRouteButton` (`CoachWorldDeskComponents.swift`) rather than a Forge Field
    // primitive, because those 56 other files have not moved either -- a transitional seam, not a
    // second design language competing with the one above it.
    private var legacyPalette: CoachWorldTokens.Palette { CoachWorldTokens.dark }

    private var legacyNavigation: some View {
        VStack(alignment: .leading, spacing: HQMetric.gap) {
            HStack(spacing: HQMetric.gap) {
                route("Health", screen: .teamHealth)
                route("Inbox", screen: .inbox)
                worldMenu
            }
            noDecision
        }
    }

    private func route(
        _ title: String, screen: CoachWorldScreenID, current: Bool = false
    ) -> some View {
        CoachWorldRouteButton(title: title, isCurrent: current, palette: legacyPalette) {
            onNavigate(screen)
        }
    }

    private var worldMenu: some View {
        Menu("More") {
            Button("Settings & accessibility") { onNavigate(.settingsAccessibility) }
            Button("Team health") { onNavigate(.teamHealth) }
            Button("Staff room") { onNavigate(.staffRoom) }
            if showsProOffseason {
                Button("Pro offseason") { onNavigate(.proOffseason) }
            }
            if showsProManagement {
                Button("Cap & contracts") { onNavigate(.capContracts) }
                if showsContractNegotiation {
                    Button("Contract negotiation") { onNavigate(.contractNegotiation) }
                }
                Button("Roster cuts & transactions") { onNavigate(.rosterCutsTransactions) }
            }
            if showsCollegeOffseason {
                Button("College offseason") { onNavigate(.collegeOffseason) }
            }
            if showsRecruitingBoard {
                if showsSigningDay {
                    Button("Signing day") { onNavigate(.signingDay) }
                }
                Button("Class overview") { onNavigate(.classOverview) }
                Button("Contact & visit planner") { onNavigate(.contactVisitPlanner) }
            }
        }
        .frame(minWidth: ForgeFieldTokens.Space.hitMin, minHeight: ForgeFieldTokens.Space.hitMin)
    }

    /// The calm empty state's remaining film reachability: `onInspect` has no stamped position on
    /// the sheet (deviation 8) and stays reachable even with no mandatory decision open, matching
    /// every other week state's own FILM link in `secondaryLinks`.
    private var noDecision: some View {
        Group {
            if model.decision == nil && model.obligations.isEmpty && model.opponent != nil {
                filmButton.frame(maxWidth: .infinity)
            }
        }
    }

    private var filmButton: some View {
        Button(action: onInspect) {
            Text("Open film room")
                .frame(minHeight: ForgeFieldTokens.Space.hitMin)
        }
        .accessibilityLabel("Inspect film")
        .buttonStyle(CoachWorldActionButtonStyle(role: .secondary, palette: legacyPalette))
    }

    // MARK: Shared state

    private var mandatoryCount: Int {
        model.obligations.filter(\.isMandatory).count
    }

    private var canAdvance: Bool {
        mandatoryCount == 0 && model.decision == nil && !preparationNeeded
    }

    private var preparationNeeded: Bool {
        model.weekPlan.contains { plan in
            plan.isCurrent && (plan.dayLabel == "Game plan" || plan.dayLabel == "Practice")
        }
    }

    private func styledText(_ string: String, _ step: ForgeFieldType.Step) -> Text {
        Text(string)
            .font(ForgeFieldType.font(step))
            .tracking(CoachWorldTokens.DisplaySize.tracking(step.tracking, at: step.points))
    }
}

// MARK: - Geometry

/// Stamped geometry from the Coaching HQ spec column, in points against the device origin --
/// `04` 6.1f (chrome) and this file's own header comment. Positions are transcribed verbatim, not
/// rounded to the spacing ladder; only the internal gaps this file chooses (tile gap, flood stack
/// gap) come from the ladder or a named token.
private enum HQMetric {
    /// `04` 6.1e's four authored clubs are not yet resolved per-team (ledger row E6, "Phase 2 --
    /// needs its own plan"); `.calumet` is the same interim default `ForgeFieldChromeBar` already
    /// renders every team in today.
    static let club = ForgeFieldTokens.Club.calumet

    /// Shared with the chrome bar rather than re-declared, so this surface's own 832 pt column
    /// cannot drift from the chrome bar's.
    static let columnWidth = ForgeFieldChromeBar.width
    static let chromeOrigin = ForgeFieldChromeBar.origin
    static let chromeSize = CGSize(width: columnWidth, height: ForgeFieldChromeBar.height)

    static let floodOrigin = CGPoint(x: ForgeFieldTokens.Space.margin, y: 44)
    static let floodSize = CGSize(width: columnWidth, height: 242)
    static let floodStackGap: CGFloat = 13

    static let seamOriginY: CGFloat = 286

    static let obligationsOrigin = CGPoint(x: ForgeFieldTokens.Space.margin, y: 294)
    static let obligationsSize = CGSize(width: columnWidth, height: 87)

    static let tileWidth: CGFloat = 265
    static let tileHeight = ForgeFieldTokens.Space.rowTouch
    static let tileGap = ForgeFieldTokens.Space.gutter

    /// Named ladder points, matching `ForgeFieldEmber`'s and `ForgeFieldChromeBar`'s own
    /// convention: `04` 6.3a states no gap of its own for this surface's internal composition, so
    /// these are chosen from the ladder ("nothing off-ladder") and named once here rather than
    /// subscripted at each call site -- a bare `ladder[1]` inside a scanned modifier call reads as
    /// a magic number to the literal scan the same way an untokenised `8` would.
    static let tightGap = ForgeFieldTokens.Space.ladder[0]    // 4
    static let gap = ForgeFieldTokens.Space.ladder[1]         // 8
    static let inset = ForgeFieldTokens.Space.ladder[2]       // 12
    static let sectionGap = ForgeFieldTokens.Space.ladder[3]  // 16

    static let emberOrigin = CGPoint(x: 327, y: 224)
    static let emberSize = CGSize(width: 198, height: ForgeFieldTokens.Space.rowTouch)

    /// The ghost mark -- `ForgeFieldBudget.weeklyCommand[.coachingHQ]`'s `ghost`.
    static let ghostSize: CGFloat = 244
    static let ghostOpacity: Double = 0.10

    /// The character length above which `displayName(for:)` switches a fixture name to its
    /// nickname. Calibrated from a booted-device measurement: "Claremont State" (16 characters,
    /// the institution half alone) rendered comfortably at full 62 pt fixture size in the ~385 pt
    /// column a two-team card leaves each side; the full 32-character joined name truncated even
    /// at a 0.6 scale floor. 18 gives a couple of characters of headroom above the measured-safe
    /// 16 without discarding a short full name unnecessarily.
    static let nameCharacterCeiling = 18
    /// The narrow safety net under `displayName(for:)`, not the primary defence against overflow
    /// -- see that function's own comment. 0.75 keeps even the longest observed nickname
    /// ("Meridian Wheelwrights") on one line while staying well clear of `04` section 6.2a(i)'s
    /// floors: 62 * 0.75 = 46.5 pt, above `Step.title`'s own 34 pt.
    static let nameScaleFloor: CGFloat = 0.75

    /// SwiftUI's `.position()` takes a centre, not the sheet's own origin+size convention -- this
    /// converts once so no call site repeats `origin + size / 2`.
    static func center(_ origin: CGPoint, _ size: CGSize) -> CGPoint {
        CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
}

// MARK: - Assertable budget facts

extension CoachingHQView {
    /// The flood field's own authored facts, above the hard seam --
    /// `ForgeFieldBudget.weeklyCommand[.coachingHQ]`'s `pointsAboveSeam` (9). Enumerated by name,
    /// not just a count, so `DesignContractTests`' budget assertion checks the same list a reader
    /// of `fixtureCard` above can check by eye. The shared chrome bar's own fixed furniture (mark,
    /// club, record, the five families, the week -- `04` 6.1f) is deliberately excluded: it is
    /// unvarying furniture present on every weekly-command surface, not this surface's own
    /// content. A fact genuinely absent at runtime (an unranked opponent, no completed game yet,
    /// no scheduled game at all) is honestly omitted rather than invented, which only ever reduces
    /// how many of these nine actually render for a given save -- never replaces one.
    public static let floodFieldDataPoints: [String] = [
        "ourClubName", "opponentClubName",
        "ourRecord", "ourRank",
        "opponentRecord", "opponentRank",
        "homeOrAway", "venue",
        "standingStreak",
    ]

    /// This surface's own gold spends: the earned-standing record line and the streak badge --
    /// `ForgeFieldBudget.weeklyCommand[.coachingHQ]`'s `goldMax` is 3; this draws 2.
    public static let goldElementCount = 2

    /// One `ForgeFieldEmber(` call site in this file -- `ADVANCE`.
    public static let emberElementCount = 1

    /// This surface's own two backgrounds: the flood field's club-deep flood and the obligations
    /// panel's `ForgeFieldPanel` ground -- the shared chrome bar's ground is furniture, not counted
    /// here, the same exclusion `floodFieldDataPoints` states for data.
    public static let backgroundCount = 2

    /// The flood field's own stage fraction: its stamped height over the full device height --
    /// `04` section 2.1's Broadcast lean is measured this way, and `ForgeFieldBudget`'s own
    /// `pointsAboveSeam`/`stageFraction` pairing for this surface is transcribed from the same
    /// sheet geometry this reads.
    public static let stageFraction: Double = Double(HQMetric.floodSize.height / ForgeFieldTokens.Space.viewport.height)

    /// The ghost mark's size and opacity, `ForgeFieldBudget.weeklyCommand[.coachingHQ]`'s `ghost`.
    public static let ghostSize = HQMetric.ghostSize
    public static let ghostOpacity = HQMetric.ghostOpacity
}
