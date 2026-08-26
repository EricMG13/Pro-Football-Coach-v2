import SwiftUI

// The shared management stage: world backdrop, identity header, content, grain
// (`04` section 6.1c, `FLOODLIT-SURFACES.md` section 1).
//
// Every management surface renders inside `CoachWorldFloodlitSurface`. Match Day does not — it is
// the broadcast register and owns its whole frame (section 6.1b).
//
// Navigation lives in the identity header and nowhere else: the family on the left, the siblings
// beside it, jump-to on the right. **The 44 pt icon rail was removed on 2026-08-23** — it named
// the same places the band already reaches, which made it a second navigation rather than a
// shortcut, and it cost the content column 52 pt to say so.

// MARK: - Read model

/// What the chrome prints. Every field is a fact the provider holds; the chrome computes nothing
/// except layout, per `FLOODLIT-SURFACES.md` section 5's read-model seam.
public struct FloodlitChromeReadModel: Sendable, Equatable {
    /// Which backdrop this surface stands in. The single variable that changes per screen.
    public enum World: String, CaseIterable, Sendable, Equatable {
        case pitch
        case facility
        /// The one place the light goes cold: a projector beam, and glass without the warm sheen.
        case film
    }

    /// A sibling surface in the current family — the header's second-row links.
    public struct Sibling: Sendable, Equatable, Identifiable {
        public struct HostedAlias: Sendable, Equatable, Identifiable {
            public var id: CoachWorldScreenID { screen }
            public let screen: CoachWorldScreenID
            public let intentID: CoachWorldIntentID

            public init(screen: CoachWorldScreenID, intentID: CoachWorldIntentID) {
                self.screen = screen
                self.intentID = intentID
            }
        }

        public var id: CoachWorldScreenID { screen }
        public let screen: CoachWorldScreenID
        /// The short form the 16 pt row prints.
        public let title: String
        public let intentID: CoachWorldIntentID
        public var hostedAliases: [HostedAlias] {
            CoachWorldScreenID.allCases.compactMap { candidate in
                guard !candidate.isCanonicalTask, candidate.canonicalDestination == screen
                else { return nil }
                return .init(
                    screen: candidate,
                    intentID: .init(rawValue: "route|\(candidate.rawValue)")
                )
            }
        }

        /// What VoiceOver says. Shortening a link to fit a row must not shorten what the screen is
        /// called to someone who cannot see the row, so this stays the registry's full title.
        public var accessibleTitle: String { screen.canonicalName }

        public init(screen: CoachWorldScreenID, title: String, intentID: CoachWorldIntentID) {
            self.screen = screen
            self.title = title
            self.intentID = intentID
        }
    }

    public struct FamilyDestination: Sendable, Equatable, Identifiable {
        public var id: String { family.rawValue }
        public let family: CoachWorldSurfaceFamily
        public let taskCount: Int
        public let preview: String
        public let intentID: CoachWorldIntentID

        public init(
            family: CoachWorldSurfaceFamily,
            taskCount: Int,
            preview: String,
            intentID: CoachWorldIntentID
        ) {
            self.family = family
            self.taskCount = taskCount
            self.preview = preview
            self.intentID = intentID
        }
    }

    /// A routing fact, never a visual default.
    public enum Back: Sendable, Equatable {
        case plain(intentID: CoachWorldIntentID)
        case up(hostName: String, intentID: CoachWorldIntentID)
        case none
    }

    public let screen: CoachWorldScreenID
    public let world: World
    public let club: CoachWorldTeamReference
    /// `4-2`, already formatted with the en dash `04` section 6.1's copy rules ask for.
    public let record: String
    /// `#21`, or nil when the programme is unranked — an absent ranking is not a ranking of zero.
    public let ranking: String?
    /// Nil when the programme's conference is not retained on this route. An absent conference is
    /// not a wrong conference, so the header omits the slot rather than guessing.
    public let conference: String?
    /// The right-hand context chip: `Sat · Halloran Tech`.
    public let context: String?
    /// Authored shorter context used only after the sibling strip reaches its width floor.
    public let contextShort: String?
    public let contextOpponent: CoachWorldTeamReference?
    public let back: Back
    public let siblings: [Sibling]
    /// Canonical tasks whose read models are retained for this career. Legacy aliases are never
    /// included here; they remain decode inputs only.
    public let availableScreens: [CoachWorldScreenID]

    public var family: CoachWorldSurfaceFamily { screen.family }
    public var families: [FamilyDestination] {
        let available = Set(availableScreens)

        return CoachWorldSurfaceFamily.allCases.compactMap { family in
            guard family != .entry else { return nil }
            let surfaces = family.surfaces
            guard let destination = surfaces.first(where: available.contains) else { return nil }
            let aliasCount = family == .proManagement
                ? CoachWorldScreenID.allCases.reduce(into: 0) { count, candidate in
                    if !candidate.isCanonicalTask,
                       candidate.canonicalDestination == .proOffseason {
                        count += 1
                    }
                }
                : 0
            return .init(
                family: family,
                taskCount: surfaces.count + aliasCount,
                preview: surfaces.prefix(3).map(\.navigationName)
                    .joined(separator: ", ").lowercased(),
                intentID: .init(rawValue: "route|\(destination.rawValue)")
            )
        }
    }

    public init(
        screen: CoachWorldScreenID,
        world: World,
        club: CoachWorldTeamReference,
        record: String,
        ranking: String? = nil,
        conference: String? = nil,
        context: String? = nil,
        contextShort: String? = nil,
        contextOpponent: CoachWorldTeamReference? = nil,
        back: Back,
        siblings: [Sibling] = [],
        availableScreens: [CoachWorldScreenID] = CoachWorldScreenID.allCases
    ) {
        self.screen = screen
        self.world = world
        self.club = club
        self.record = record
        self.ranking = ranking
        self.conference = conference
        self.context = context
        self.contextShort = contextShort
        self.contextOpponent = contextOpponent
        self.back = back
        self.siblings = siblings
        self.availableScreens = availableScreens
    }
}

// MARK: - World backdrop

/// `pitch | facility | film`, drawn from gradients and transforms only — `04` section 5 and the
/// handoff both forbid photography and illustration anywhere in the product.
struct CoachWorldWorldBackdrop: View {
    let world: FloodlitChromeReadModel.World
    let palette: CoachWorldTokens.Palette
    let showsDetail: Bool

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                LinearGradient(
                    colors: ground,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                if showsDetail {
                    lamp(size)
                    Canvas(rendersAsynchronously: false) { context, canvasSize in
                        switch world {
                        case .pitch: Self.drawPitch(&context, canvasSize, palette: palette)
                        case .facility: Self.drawFacility(&context, canvasSize, palette: palette)
                        case .film: Self.drawFilm(&context, canvasSize, palette: palette)
                        }
                    }
                }
            }
            .frame(width: size.width, height: size.height)
        }
        // The world is static per screen, so it rasterises once rather than recompositing behind
        // every content change. `BUILD.md`'s transformed-plane warning applies here as much as on
        // Match Day.
        .drawingGroup()
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var ground: [Color] {
        switch world {
        case .pitch: [palette.page.color, palette.work.color, palette.page.color]
        case .facility: [palette.page.color, CoachWorldTokens.Floodlit.roomDeep.color, palette.page.color]
        // Cold: the film room's ground loses the warm middle entirely.
        case .film: [CoachWorldTokens.Floodlit.roomDeep.color, palette.page.color, CoachWorldTokens.Floodlit.roomDeep.color]
        }
    }

    /// The single upper-left-ish light the whole system is lit by. Cold and centred for film.
    private func lamp(_ size: CGSize) -> some View {
        RadialGradient(
            colors: [lampColour.opacity(lampAlpha), .clear],
            center: world == .film ? UnitPoint(x: 0.5, y: -0.1) : UnitPoint(x: 0.78, y: 0.02),
            startRadius: 0,
            endRadius: size.width * Chrome.lampRadiusRatio
        )
    }

    private var lampColour: Color {
        world == .film
            ? CoachWorldTokens.dark.stateInfo.color
            : CoachWorldTokens.Floodlit.lamp.color
    }

    private var lampAlpha: Double {
        world == .film ? Chrome.filmLampAlpha : Chrome.lampAlpha
    }

    // MARK: worlds

    private static func drawPitch(
        _ context: inout GraphicsContext, _ size: CGSize, palette: CoachWorldTokens.Palette
    ) {
        var plane = Path()
        plane.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.42))
        plane.addLine(to: CGPoint(x: size.width * 0.86, y: size.height * 0.42))
        plane.addLine(to: CGPoint(x: size.width * 1.08, y: size.height * Chrome.bleed))
        plane.addLine(to: CGPoint(x: size.width * -0.08, y: size.height * Chrome.bleed))
        plane.closeSubpath()
        context.fill(
            plane,
            with: .linearGradient(
                Gradient(colors: [
                    palette.fieldTurf.color.opacity(0.12),
                    palette.fieldTurf.color.opacity(0.34),
                ]),
                startPoint: CGPoint(x: size.width / 2, y: size.height * 0.42),
                endPoint: CGPoint(x: size.width / 2, y: size.height)
            )
        )
        for index in 0..<7 {
            let progress = CGFloat(index) / 6
            let y = size.height * (0.47 + progress * 0.48)
            let inset = size.width * (0.16 - progress * 0.19)
            var line = Path()
            line.move(to: CGPoint(x: inset, y: y))
            line.addLine(to: CGPoint(x: size.width - inset, y: y))
            context.stroke(
                line,
                with: .color(palette.fieldLine.color.opacity(0.07)),
                lineWidth: CoachWorldTokens.Shape.hairline
            )
        }
    }

    /// A floor receding to a window band — the room a coach works in, not a stadium.
    private static func drawFacility(
        _ context: inout GraphicsContext, _ size: CGSize, palette: CoachWorldTokens.Palette
    ) {
        var floor = Path()
        floor.move(to: CGPoint(x: size.width * -0.08, y: size.height * 0.58))
        floor.addLine(to: CGPoint(x: size.width * 1.08, y: size.height * 0.58))
        floor.addLine(to: CGPoint(x: size.width * 1.16, y: size.height * Chrome.bleed))
        floor.addLine(to: CGPoint(x: size.width * -0.16, y: size.height * Chrome.bleed))
        floor.closeSubpath()
        context.fill(
            floor,
            with: .linearGradient(
                Gradient(colors: [
                    CoachWorldTokens.Floodlit.roomDeep.color.opacity(0.0),
                    CoachWorldTokens.Floodlit.roomDeep.color.opacity(0.55),
                ]),
                startPoint: CGPoint(x: size.width / 2, y: size.height * 0.58),
                endPoint: CGPoint(x: size.width / 2, y: size.height)
            )
        )
        // The window band: verticals, receding.
        for index in 0..<9 {
            let x = size.width * (0.06 + CGFloat(index) * 0.11)
            var mullion = Path()
            mullion.move(to: CGPoint(x: x, y: size.height * 0.05))
            mullion.addLine(to: CGPoint(x: x, y: size.height * 0.56))
            context.stroke(
                mullion,
                with: .color(palette.contentPrimary.color.opacity(0.04)),
                lineWidth: CoachWorldTokens.Shape.hairline
            )
        }
    }

    /// The projector beam and five fixed dust motes. Fixed, because a random mote is a different
    /// screen every launch and this product's determinism rule does not stop at the simulation.
    private static func drawFilm(
        _ context: inout GraphicsContext, _ size: CGSize, palette: CoachWorldTokens.Palette
    ) {
        var beam = Path()
        beam.move(to: CGPoint(x: size.width * 0.46, y: .zero))
        beam.addLine(to: CGPoint(x: size.width * 0.54, y: .zero))
        beam.addLine(to: CGPoint(x: size.width * 1.02, y: size.height * Chrome.bleed))
        beam.addLine(to: CGPoint(x: size.width * -0.02, y: size.height * Chrome.bleed))
        beam.closeSubpath()
        context.fill(
            beam,
            with: .linearGradient(
                Gradient(colors: [
                    palette.stateInfo.color.opacity(0.10),
                    palette.stateInfo.color.opacity(0.0),
                ]),
                startPoint: CGPoint(x: size.width / 2, y: 0),
                endPoint: CGPoint(x: size.width / 2, y: size.height)
            )
        )
        for mote in Chrome.dustMotes {
            let rect = CGRect(
                x: size.width * mote.x - mote.r / 2,
                y: size.height * mote.y - mote.r / 2,
                width: mote.r,
                height: mote.r
            )
            context.fill(
                Path(ellipseIn: rect),
                with: .color(palette.contentPrimary.color.opacity(mote.alpha))
            )
        }
    }
}

// MARK: - Identity header

/// The whole management chrome in one 34 point row: back, identity, family, siblings, context.
struct FloodlitIdentityHeader: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var showingFamilies = false
    @State private var openHost: CoachWorldScreenID?

    private var bandTargetOffset: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 0 : Chrome.bandTargetOffset
    }

    let model: FloodlitChromeReadModel
    let palette: CoachWorldTokens.Palette
    let onNavigate: (CoachWorldIntentID) -> Void

    private var identity: CoachWorldTeamIdentity? {
        CoachWorldTeamIdentity(
            team: model.club,
            behind: CoachWorldTokens.Floodlit.roomDeep,
            inks: [CoachWorldTokens.Floodlit.clubInk, CoachWorldTokens.dark.contentPrimary]
        )
    }

    var body: some View {
        VStack(spacing: .zero) {
            if dynamicTypeSize.isAccessibilitySize {
                accessibleNavigator
            } else {
                navigator
                    .overlayPreferenceValue(ChromePanelAnchorKey.self) { anchors in
                        GeometryReader { proxy in
                            standardPresentedPanel(anchors: anchors, proxy: proxy)
                        }
                    }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("top-navigator")
    }

    private var navigator: some View {
        ViewThatFits(in: .horizontal) {
            navigatorRow(context: model.context)
            navigatorRow(context: model.contextShort ?? model.context)
        }
        .frame(height: CoachWorldTokens.Stage.headerHeight)
        .background(navigatorGround)
        .overlay(alignment: .leading) {
            Rectangle().fill((identity?.accent ?? CoachWorldTokens.Floodlit.clubInk).color)
                .frame(width: Chrome.headerRail)
                .accessibilityHidden(true)
        }
        .overlay {
            CoachWorldCutCorner.headerBand.stroke(
                CoachWorldTokens.Rule.row.color(
                    palette: palette,
                    contrast: contrast,
                    reduceTransparency: reduceTransparency
                ),
                lineWidth: CoachWorldTokens.Shape.hairline
            )
        }
        .clipShape(CoachWorldCutCorner.headerBand)
    }

    private var navigatorGround: some View {
        LinearGradient(
            stops: [
                .init(color: (identity?.field ?? CoachWorldTokens.Floodlit.clubField).color.opacity(0.92), location: 0),
                .init(color: (identity?.field ?? CoachWorldTokens.Floodlit.clubField).color.opacity(0.42), location: 0.52),
                .init(color: .clear, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var rowRuleColor: Color {
        CoachWorldTokens.Rule.row.color(
            palette: palette,
            contrast: contrast,
            reduceTransparency: reduceTransparency
        )
    }

    private func navigatorRow(context: String?) -> some View {
        HStack(spacing: .zero) {
            backControl
            identityBlock
            Rectangle()
                .fill(rowRuleColor)
                .frame(width: CoachWorldTokens.Shape.hairline)
                .accessibilityHidden(true)
            familyButton
            siblingStrip
                .frame(minWidth: Chrome.siblingFloor)
            Spacer(minLength: .zero)
            if let context { contextBlock(context) }
        }
    }

    @ViewBuilder
    private var backControl: some View {
        switch model.back {
        case let .plain(intentID):
            Button { onNavigate(intentID) } label: { backWedge(opacity: 0.58) }
                .buttonStyle(.plain)
                .frame(width: Chrome.backWidth, height: CoachWorldTokens.Shape.minimumTarget)
                .padding(.vertical, bandTargetOffset)
                .accessibilityLabel("Back to the previous surface")
                .overlay(alignment: .trailing) { backRule }
        case let .up(hostName, intentID):
            Button { onNavigate(intentID) } label: {
                HStack(spacing: CoachWorldTokens.Gap.xs) {
                    backWedge(opacity: 0.72)
                    Text(hostName.uppercased())
                        .coachWorldDisplay(Chrome.familySize, weight: .bold)
                        .tracking(CoachWorldTokens.DisplaySize.tracking(0.08, at: Chrome.familySize))
                        .lineLimit(1)
                }
                .padding(.horizontal, CoachWorldTokens.Gap.smPlus)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: Chrome.backUpMaxWidth, minHeight: CoachWorldTokens.Shape.minimumTarget)
            .padding(.vertical, bandTargetOffset)
            .accessibilityLabel("Back to \(hostName)")
            .accessibilityHint("This surface folds into that task")
            .overlay(alignment: .trailing) { backRule }
        case .none:
            backWedge(opacity: 1 / 6)
                .frame(width: Chrome.backWidth, height: CoachWorldTokens.Stage.headerHeight)
                .accessibilityElement()
                .accessibilityLabel("Nothing behind this surface")
                .accessibilityAddTraits(.isStaticText)
                .overlay(alignment: .trailing) { backRule }
        }
    }

    private func backWedge(opacity: Double) -> some View {
        FloodlitBackWedge()
            .fill(CoachWorldTokens.Floodlit.clubInk.color.opacity(opacity))
            .frame(width: Chrome.backWedgeWidth, height: Chrome.backWedgeHeight)
    }

    private var backRule: some View {
        Rectangle()
            .fill(rowRuleColor)
            .frame(width: CoachWorldTokens.Shape.hairline)
            .accessibilityHidden(true)
    }

    private var identityBlock: some View {
        HStack(spacing: CoachWorldTokens.Gap.sm) {
            CoachWorldTeamLogo(
                team: model.club,
                size: .desk,
                surface: CoachWorldTokens.Floodlit.roomDeep,
                palette: palette
            )
            Text(model.club.name.uppercased())
                .coachWorldDisplay(CoachWorldTokens.DisplaySize.lead, weight: .bold)
                .tracking(Chrome.clubTracking)
                .lineLimit(1)
            Text(model.ranking.map { "\(model.record) · \($0)" } ?? model.record)
                .coachWorldFigure(Chrome.recordSize, weight: .semibold)
                .foregroundStyle(CoachWorldTokens.Floodlit.clubInk.color.opacity(0.78))
                .lineLimit(1)
        }
        .foregroundStyle(CoachWorldTokens.Floodlit.clubInk.color)
        .padding(.horizontal, CoachWorldTokens.Gap.mdPlus)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(identityLabel)
    }

    private var identityLabel: String {
        var parts = [model.club.name, model.record]
        if let ranking = model.ranking { parts.append("ranked \(ranking)") }
        if let conference = model.conference { parts.append(conference) }
        return parts.joined(separator: ", ")
    }

    private var familyButton: some View {
        Button {
            openHost = nil
            showingFamilies.toggle()
        } label: {
            HStack(spacing: CoachWorldTokens.Gap.xxs) {
                Text(model.family.canonicalName.uppercased())
                    .coachWorldDisplay(Chrome.familySize, weight: .bold)
                    .tracking(CoachWorldTokens.DisplaySize.tracking(0.16, at: Chrome.familySize))
                FloodlitCaret(pointsUp: showingFamilies)
                    .fill(CoachWorldTokens.Floodlit.clubInk.color)
                    .frame(width: Chrome.caretWidth, height: Chrome.caretHeight)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, CoachWorldTokens.Gap.mdPlus)
            .frame(minHeight: CoachWorldTokens.Shape.minimumTarget)
            .background(CoachWorldTokens.Surfacing.wash(.faint, palette: palette))
            .overlay(alignment: .bottom) {
                Rectangle().fill(CoachWorldTokens.Floodlit.clubInk.color)
                    .frame(height: Chrome.siblingUnderline)
            }
        }
        .anchorPreference(key: ChromePanelAnchorKey.self, value: .bounds) {
            [.family: $0]
        }
        .buttonStyle(.plain)
        .padding(.vertical, bandTargetOffset)
        .accessibilityLabel("Switch family, \(model.family.canonicalName)")
        .accessibilityValue(showingFamilies ? "Expanded" : "Collapsed")
    }

    private var siblingStrip: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: CoachWorldTokens.Gap.md) {
                    ForEach(model.siblings) { sibling in siblingLink(sibling) }
                }
                .padding(.horizontal, CoachWorldTokens.Gap.mdPlus)
            }
            .scrollIndicators(.hidden)
            .mask {
                LinearGradient(
                    stops: [.init(color: .black, location: 0),
                            .init(color: .black, location: 0.82),
                            .init(color: .clear, location: 1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .overlay(alignment: .trailing) {
                if model.siblings.count > 1 {
                    Text("…")
                        .foregroundStyle(CoachWorldTokens.Floodlit.clubInk.color.opacity(0.72))
                        .accessibilityHidden(true)
                }
            }
            .onAppear { proxy.scrollTo(model.screen, anchor: .center) }
            .onChange(of: model.screen) { _, screen in proxy.scrollTo(screen, anchor: .center) }
        }
        .layoutPriority(-1)
    }

    private func siblingLink(_ sibling: FloodlitChromeReadModel.Sibling) -> some View {
        let current = sibling.screen == model.screen
        return Button {
            if sibling.hostedAliases.isEmpty {
                onNavigate(sibling.intentID)
            } else {
                showingFamilies = false
                openHost = openHost == sibling.screen ? nil : sibling.screen
            }
        } label: {
            HStack(spacing: CoachWorldTokens.Gap.xxs) {
                Text(sibling.title.uppercased())
                if !sibling.hostedAliases.isEmpty {
                    Text("\(sibling.hostedAliases.count)").coachWorldFigure(Chrome.hostCountSize, weight: .bold)
                    FloodlitCaret(pointsUp: openHost == sibling.screen)
                        .fill(CoachWorldTokens.Floodlit.clubInk.color.opacity(current ? 1 : 0.66))
                        .frame(width: Chrome.hostCaretWidth, height: Chrome.hostCaretHeight)
                        .accessibilityHidden(true)
                }
            }
            .coachWorldDisplay(Chrome.siblingSize, weight: .semibold)
            .tracking(CoachWorldTokens.DisplaySize.tracking(0.09, at: Chrome.siblingSize))
            .foregroundStyle(CoachWorldTokens.Floodlit.clubInk.color.opacity(current ? 1 : 0.66))
            .fixedSize()
            .frame(minHeight: CoachWorldTokens.Shape.minimumTarget)
            .overlay(alignment: .bottom) {
                if current {
                    Rectangle().fill(CoachWorldTokens.Floodlit.clubInk.color)
                        .frame(height: Chrome.siblingUnderline)
                }
            }
        }
        .id(sibling.screen)
        .anchorPreference(key: ChromePanelAnchorKey.self, value: .bounds) {
            sibling.hostedAliases.isEmpty ? [:] : [.host(sibling.screen): $0]
        }
        .buttonStyle(.plain)
        .padding(.vertical, bandTargetOffset)
        .accessibilityLabel(sibling.accessibleTitle)
        .accessibilityValue(sibling.hostedAliases.isEmpty ? "" : "\(sibling.hostedAliases.count) folded routes")
        .accessibilityAddTraits(current ? .isSelected : [])
    }

    private func contextBlock(_ context: String) -> some View {
        HStack(spacing: CoachWorldTokens.Gap.xxs) {
            if let opponent = model.contextOpponent {
                CoachWorldTeamLogo(
                    team: opponent,
                    size: .context,
                    surface: CoachWorldTokens.Floodlit.roomDeep,
                    palette: palette
                )
            }
            Text(context.uppercased())
                .coachWorldDisplay(Chrome.contextSize, weight: .bold)
                .fixedSize()
        }
        .foregroundStyle(CoachWorldTokens.Floodlit.clubInk.color)
        .padding(.horizontal, CoachWorldTokens.Gap.mdPlus)
        .frame(height: CoachWorldTokens.Stage.headerHeight)
        .background(CoachWorldTokens.Surfacing.recess(.light, palette: palette))
        .accessibilityLabel(context)
    }

    @ViewBuilder
    private func standardPresentedPanel(
        anchors: [ChromePanelAnchor: Anchor<CGRect>],
        proxy: GeometryProxy
    ) -> some View {
        if showingFamilies, let anchor = anchors[.family] {
            FloodlitFamilySwitcher(model: model, palette: palette) { destination in
                showingFamilies = false
                onNavigate(destination.intentID)
            }
            .offset(
                x: panelLeading(proxy[anchor].minX, inset: 18, width: Chrome.familyPanelWidth),
                y: CoachWorldTokens.Stage.headerHeight + CoachWorldTokens.Gap.xxs
            )
        } else if let openHost,
                  let anchor = anchors[.host(openHost)],
                  let sibling = model.siblings.first(where: { $0.screen == openHost }) {
            FloodlitHostPanel(sibling: sibling, palette: palette) { alias in
                self.openHost = nil
                onNavigate(alias.intentID)
            }
            .offset(
                x: panelLeading(proxy[anchor].minX, inset: 12, width: Chrome.hostPanelWidth),
                y: CoachWorldTokens.Stage.headerHeight + CoachWorldTokens.Gap.xxs
            )
        }
    }

    private func panelLeading(_ anchor: CGFloat, inset: CGFloat, width: CGFloat) -> CGFloat {
        min(max(anchor - inset, 0), max(CoachWorldTokens.Stage.contentWidth - width, 0))
    }

    @ViewBuilder
    private var accessiblePresentedPanel: some View {
        if showingFamilies {
            FloodlitFamilySwitcher(model: model, palette: palette) { destination in
                showingFamilies = false
                onNavigate(destination.intentID)
            }
        } else if let openHost,
                  let sibling = model.siblings.first(where: { $0.screen == openHost }) {
            FloodlitHostPanel(sibling: sibling, palette: palette) { alias in
                self.openHost = nil
                onNavigate(alias.intentID)
            }
        }
    }

    private var accessibleNavigator: some View {
        VStack(alignment: .leading, spacing: CoachWorldTokens.Gap.sm) {
            HStack(spacing: .zero) { backControl; identityBlock }
            familyButton
            ForEach(model.siblings) { sibling in siblingLink(sibling) }
            if let context = model.context { contextBlock(context) }
            accessiblePresentedPanel
        }
        .padding(CoachWorldTokens.Pad.panel.h)
        .background(navigatorGround)
        .clipShape(CoachWorldCutCorner.headerBand)
    }
}

private enum ChromePanelAnchor: Hashable {
    case family
    case host(CoachWorldScreenID)
}

private struct ChromePanelAnchorKey: PreferenceKey {
    static var defaultValue: [ChromePanelAnchor: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [ChromePanelAnchor: Anchor<CGRect>],
        nextValue: () -> [ChromePanelAnchor: Anchor<CGRect>]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { _, next in next })
    }
}

private struct FloodlitFamilySwitcher: View {
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let model: FloodlitChromeReadModel
    let palette: CoachWorldTokens.Palette
    let onSelect: (FloodlitChromeReadModel.FamilyDestination) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            panelHead("GO TO", detail: "\(model.families.reduce(0) { $0 + $1.taskCount }) TASKS")
            ForEach(model.families) { destination in
                Button { onSelect(destination) } label: {
                    HStack(spacing: CoachWorldTokens.Gap.sm) {
                        VStack(alignment: .leading, spacing: CoachWorldTokens.Gap.hair) {
                            Text(destination.family.canonicalName.uppercased())
                                .font(CoachWorldTokens.TypeRole.caption.weight(.bold))
                            Text(destination.family == model.family ? "you are here" : destination.preview)
                                .font(CoachWorldTokens.TypeRole.microLabel)
                                .foregroundStyle(palette.contentQuiet.color)
                                .lineLimit(1)
                        }
                        Spacer(minLength: .zero)
                        Text("\(destination.taskCount)")
                            .coachWorldFigure(Chrome.familyCountSize, weight: .bold)
                    }
                    .padding(.horizontal, CoachWorldTokens.Gap.lg)
                    .frame(maxWidth: .infinity, minHeight: CoachWorldTokens.Shape.minimumTarget, alignment: .leading)
                    .background(destination.family == model.family
                        ? CoachWorldTokens.Surfacing.wash(.faint, palette: palette) : .clear)
                    .overlay(alignment: .leading) {
                        if destination.family == model.family {
                            Rectangle().fill(palette.contentPrimary.color).frame(width: Chrome.headerRail)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(destination.family.canonicalName), \(destination.taskCount) tasks")
                .accessibilityAddTraits(destination.family == model.family ? .isSelected : [])
            }
        }
        .frame(width: Chrome.familyPanelWidth)
        .background(CoachWorldTokens.Floodlit.glassFlat.color)
        .overlay {
            CoachWorldCutCorner.panel.stroke(
                CoachWorldTokens.Rule.legible.color(
                    palette: palette,
                    contrast: contrast,
                    reduceTransparency: reduceTransparency
                )
            )
        }
        .clipShape(CoachWorldCutCorner.panel)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Go to family")
        .zIndex(8)
    }

    private func panelHead(_ title: String, detail: String) -> some View {
        HStack {
            Text(title).font(CoachWorldTokens.TypeRole.caption.weight(.bold))
            Spacer(minLength: .zero)
            Text(detail).coachWorldFigure(Chrome.panelDetailSize, weight: .bold)
                .foregroundStyle(palette.contentQuiet.color)
        }
        .padding(.horizontal, CoachWorldTokens.Gap.lg)
        .frame(height: Chrome.panelHeadHeight)
        .background(CoachWorldTokens.Floodlit.glassFlatDeep.color)
    }
}

private struct FloodlitHostPanel: View {
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let sibling: FloodlitChromeReadModel.Sibling
    let palette: CoachWorldTokens.Palette
    let onSelect: (FloodlitChromeReadModel.Sibling.HostedAlias) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack {
                Text("FOLDS INTO").font(CoachWorldTokens.TypeRole.caption.weight(.bold))
                Spacer(minLength: .zero)
                Text(sibling.title.uppercased())
                    .coachWorldFigure(Chrome.panelDetailSize, weight: .bold)
                    .foregroundStyle(palette.contentQuiet.color)
            }
            .padding(.horizontal, CoachWorldTokens.Gap.lg)
            .frame(height: Chrome.panelHeadHeight)
            .background(CoachWorldTokens.Floodlit.glassFlatDeep.color)

            ForEach(sibling.hostedAliases) { alias in
                Button { onSelect(alias) } label: {
                    HStack(spacing: CoachWorldTokens.Gap.sm) {
                        Text("\(alias.screen.number)")
                            .coachWorldFigure(Chrome.hostNumberSize, weight: .bold)
                            .foregroundStyle(palette.contentQuiet.color)
                            .frame(width: Chrome.hostNumberWidth, alignment: .trailing)
                        Text(alias.screen.canonicalName)
                            .font(CoachWorldTokens.TypeRole.body.weight(.semibold))
                        Spacer(minLength: .zero)
                    }
                    .padding(.horizontal, CoachWorldTokens.Gap.lg)
                    .frame(maxWidth: .infinity, minHeight: CoachWorldTokens.Shape.minimumTarget, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(alias.screen.number), \(alias.screen.canonicalName)")
            }
        }
        .frame(width: Chrome.hostPanelWidth)
        .background(CoachWorldTokens.Floodlit.glassFlat.color)
        .overlay {
            CoachWorldCutCorner.panel.stroke(
                CoachWorldTokens.Rule.legible.color(
                    palette: palette,
                    contrast: contrast,
                    reduceTransparency: reduceTransparency
                )
            )
        }
        .clipShape(CoachWorldCutCorner.panel)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Folds into \(sibling.title)")
        .zIndex(8)
    }
}

private struct FloodlitBackWedge: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct FloodlitCaret: Shape {
    let pointsUp: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: pointsUp ? rect.maxY : rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: pointsUp ? rect.minY : rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: pointsUp ? rect.maxY : rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Registered-not-built

/// The honest state for a registered surface with no design yet: what it is, and what it needs.
/// Kept deliberately, rather than a spinner or a blank — `FLOODLIT-SURFACES.md` section 1.
struct FloodlitRegisteredNotBuilt: View {
    private let screen: CoachWorldScreenID
    private let needs: String
    private let palette: CoachWorldTokens.Palette

    init(
        screen: CoachWorldScreenID,
        needs: String,
        palette: CoachWorldTokens.Palette = CoachWorldTokens.dark
    ) {
        self.screen = screen
        self.needs = needs
        self.palette = palette
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CoachWorldTokens.Gap.smPlus) {
            FloodlitLabel3(screen.canonicalName, palette: palette)
            Text(needs)
                .font(CoachWorldTokens.TypeRole.body)
                .foregroundStyle(palette.contentSecondary.color)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, Chrome.notBuiltPadH)
        .padding(.vertical, Chrome.notBuiltPadV)
        .frame(width: Chrome.notBuiltWidth, alignment: .leading)
        .coachWorldFloodlitPanel(
            fill: CoachWorldTokens.Floodlit.glassFlatDeep.color,
            border: Color.white.opacity(CoachWorldTokens.Glass.line),
            depth: .deep
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(screen.canonicalName). Registered, not built. \(needs)")
    }
}

// MARK: - Literals

/// Module-internal rather than file-private (2026-08-19, S-7) so `ContractTests` can assert on the
/// real values through `@testable import` instead of string-matching the source text for an exact
/// literal — the previous test asserted the constants had not changed at all, which the codebase
/// cannot tell apart from a genuine improvement.
enum Chrome {
    static let grainOpacity = 0.5
    static let bleed: CGFloat = 1 + CoachWorldTokens.Stage.worldBottomBleed * 0.1
    static let lampRadiusRatio: CGFloat = 0.52
    static let lampAlpha = 0.22
    static let filmLampAlpha = 0.16

    struct Mote { let x: CGFloat; let y: CGFloat; let r: CGFloat; let alpha: Double }
    /// Five, fixed. A random mote is a different screen every launch.
    static let dustMotes: [Mote] = [
        .init(x: 0.38, y: 0.22, r: 2.5, alpha: 0.10),
        .init(x: 0.56, y: 0.34, r: 1.8, alpha: 0.08),
        .init(x: 0.47, y: 0.52, r: 3.0, alpha: 0.07),
        .init(x: 0.62, y: 0.66, r: 2.0, alpha: 0.06),
        .init(x: 0.41, y: 0.78, r: 2.4, alpha: 0.05),
    ]

    static let headerRail: CGFloat = 3
    static let clubTracking: CGFloat = 0.5
    static let recordSize: CGFloat = 11
    static let contextSize: CGFloat = 11
    static let familySize: CGFloat = 9
    static let siblingSize: CGFloat = 9.5
    static let siblingUnderline: CGFloat = 2
    static let siblingFloor: CGFloat = 96
    static let bandTargetOffset: CGFloat = -5

    static let backWidth: CGFloat = 25
    static let backUpMaxWidth: CGFloat = 132
    static let backWedgeWidth: CGFloat = 5
    static let backWedgeHeight: CGFloat = 8
    static let caretWidth: CGFloat = 7
    static let caretHeight: CGFloat = 4
    static let hostCaretWidth: CGFloat = 6
    static let hostCaretHeight: CGFloat = 3.5
    static let hostCountSize: CGFloat = 9

    static let familyPanelWidth: CGFloat = 250
    static let hostPanelWidth: CGFloat = 232
    static let familyCountSize: CGFloat = 13
    static let panelDetailSize: CGFloat = 10
    static let hostNumberSize: CGFloat = 11
    static let hostNumberWidth: CGFloat = 22
    static let panelHeadHeight: CGFloat = 29

    static let pennantWidth: CGFloat = 11
    static let pennantHeight: CGFloat = 14
    static let pennantDot: CGFloat = 3

    static let notBuiltWidth: CGFloat = 330
    static let notBuiltPadH: CGFloat = 22
    static let notBuiltPadV: CGFloat = 18
}
