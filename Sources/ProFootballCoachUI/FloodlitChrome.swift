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
    /// The week label the Forge Field chrome bar's fixed last slot reads, `04` 6.1f: "mark, club,
    /// record, the five surfaces, the week." Nil only for a caller that predates this field (a
    /// hand-built read model in a test that does not exercise the week slot) — every real chrome
    /// provider supplies it. The fact already exists one level up
    /// (`CoachingHQReadModel.WeekContext.weekLabel`); this only threads it into the chrome's own
    /// read model, which never carried a raw week fact before Task 5 because Press Box's chrome
    /// baked everything into `context`/`contextShort` instead.
    public let week: String?
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
        week: String? = nil,
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
        self.week = week
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

/// Hosts the Forge Field chrome bar (`ForgeFieldChromeBar.swift`, `04` section 6.1f) in place of
/// the retired Press Box identity band -- the club-coloured band ground, the back control, the
/// family switcher panel, the sibling strip and its folds-into panel, and the short-context yielding
/// ladder. `04` 6.1f's bar has none of those: fixed contents, fixed order, mark, club, record, the
/// five surfaces, the week, "present on every surface and its contents never vary." See
/// `Tests/SimTests/Suites/DesignContractTests.swift`'s retargeted "Press Box shared chrome" suite
/// for which of the retired controls that is and why, one by one.
///
/// Kept as a thin wrapper rather than inlining `ForgeFieldChromeBar` at
/// `CoachWorldFloodlitComposition`'s two call sites, so both keep compiling unchanged against this
/// same three-parameter shape, and so `top-navigator` -- the one identifier the retargeted contract
/// keeps -- stays owned by one type regardless of what renders inside it. `palette` is accepted and
/// stored, not read: the caller passes the Press Box palette both call sites already resolve, and
/// removing the parameter would touch `CoachWorldFloodlitComposition.swift`, a file this task's
/// brief does not list.
struct FloodlitIdentityHeader: View {
    let model: FloodlitChromeReadModel
    let palette: CoachWorldTokens.Palette
    let onNavigate: (CoachWorldIntentID) -> Void

    var body: some View {
        ForgeFieldChromeBar(model: model, onNavigate: onNavigate)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("top-navigator")
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
