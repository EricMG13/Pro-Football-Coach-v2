import SwiftUI

/// Opponent report / film room, drawn to the Forge Field standard -- `04` sections 6.1e, 6.1f,
/// 6.2a, 6.2a(i), 6.3a, 6.6a, 6.7a and 7. Phase 2B Task 7 of
/// `docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md`.
///
/// Replaces the Press Box `CoachWorldFloodlitStage` composition this surface drew before with
/// `ForgeFieldDevice` and the shared primitives (`ForgeFieldSeam`) plus `ForgeFieldType`. No
/// `ForgeFieldEmber` -- see "Zero embers" below. `ForgeFieldPanel` is deliberately unused for the
/// same reason `InboxView` states for its own body -- see "Two backgrounds" below.
///
/// **Register, from the sheet's stamped spec column
/// (`ForgeFieldBudget.weeklyCommand[.opponentReportFilmRoom]`):** Dossier, MIXED. Stage 33% (130 of
/// 393). Data points 34. Gold 0 of 2. Ember 0 (corrected, see ruling 1). Ghost 230 pt, .13,
/// desaturated to zero. Backgrounds 2 of 2 -- a cold flood, and ground 1.
///
/// **Ruling 1: zero embers, and the budget is corrected (dispatch, 2026-08-30/31, do not
/// relitigate).** `04` 6.1e: an ember exists only where the read model records a nameable cost.
/// `OpponentFilmReadModel` carries no `canContinue`/`continueReason` pair the way
/// `TeamHealthReadModel` and `InboxReadModel` do -- nothing on this model can name a price for
/// leaving. The sheet's drawn ember, "Install the counter", is refused for the identical reason:
/// no callback exists for it, and the contract's row 10 list is `onClose`, `onContinue`,
/// `onNavigateChrome` -- one continue, gated only on `model.isCurrent`, the same gate the Press Box
/// surface this file replaces already used. `continueControl` below is therefore a quiet, plain
/// control -- ink, no gradient fill, no glow, no gold -- matching the shape ruling this family's
/// other zero-ember surfaces already use. `ForgeFieldBudget.weeklyCommand[.opponentReportFilmRoom]`
/// is corrected from the sheet's 1 to 0 for exactly this reason, with the same style of comment
/// `.gamePlan` and `.practicePlan` already carry; `DesignContractTests.swift`'s `noEmber` set now
/// includes this screen.
///
/// **The one place a flood is not club colour (dispatch, 2026-08-30/31).** *"Club colour on this
/// screen would say the opponent belongs to us."* The flooded strip above the seam fills with
/// `ForgeFieldTokens.Fixed.signalCold` -- `04` 6.1e's own fixed row for this exact case, "not
/// yours: rivals, the league" -- rather than any of the four authored `ClubPalette`s, blended over
/// the device's own `ground0` at `Edge.raised`'s alpha (.22) so the result stays within this dark-
/// only palette's own lightness range rather than painting a bright plate: every other flood in
/// this family (`clubDeep`, itself already dark) sets that precedent, and no "cold-deep" token
/// exists to reach for instead. `coldFlood` below composes only already-declared tokens -- no new
/// hex, no new alpha. The ghost mark goes one step further, past the standard's own .75 default
/// desaturation to fully achromatic (`Color.white`, the same bare literal `EmberButtonStyle`'s own
/// inset highlight already uses for an identical fully-desaturated mark).
///
/// **No sheet geometry was available for this surface in this environment**, the same gap
/// `InboxView.swift` recorded for Task 3 (the Figma/design-tool connector needs interactive
/// authorisation this session does not have, and the plan's "per-surface notes" section transcribes
/// no `x,y · w×h` for this screen). The one exception is the flood's own height: the stamped stage
/// figure, "33% (130 of 393)", is transcribed verbatim as `FilmMetric.floodHeight`, matching
/// `PracticePlanView.floodHeight`'s identical precedent. Everything else is this file's own
/// composition from `ForgeFieldTokens.Space.ladder`, using ordinary SwiftUI flow layout rather than
/// absolute `.position()` placement -- `InboxView`'s own reasoning applies unchanged.
///
/// **Two backgrounds, cold flood and ground 1 only.** `ForgeFieldPanel` always fills `ground2`, so
/// it is unused here. The studied content (tendencies, the source panel) sits directly on the one
/// `ground1` fill this file draws once.
///
/// **Two tendencies only, source figures, and an honest unavailable reason -- contract row 10.**
/// No down-and-distance splits, no player film, no hidden league totals: `tendencies` draws exactly
/// the two rates the model holds (pass rate, turnover rate), and `sourcePanel` draws exactly the
/// three source figures it holds (confidence, source games, retained fixtures). `04` section 4.4:
/// an unavailable state stays drawn beside its reason rather than removed in silence --
/// `model.unavailableReason`, when present, replaces the tendencies/source content with the honest
/// sentence, never a blank pane.
///
/// **Zero gold (0 of the Dossier ceiling of 2) -- "none of this standing is ours."** Nothing on
/// this surface is the coach's own earned record; the opponent's evidence does not spend the
/// coach's gold.
public struct OpponentFilmView: View, CoachWorldChromedSurface {
    /// The shared management chrome. Nil renders a minimal fallback bar carrying only team
    /// identity -- in production this is always populated when `model` is, so the fallback exists
    /// for previews and tests only.
    public var chrome: FloodlitChromeReadModel?
    public var onNavigateChrome: ((CoachWorldIntentID) -> Void)?

    public let model: OpponentFilmReadModel
    public let statusMessage: String?
    public let onClose: () -> Void
    public let onContinue: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var contrast

    private var club: ForgeFieldTokens.Club {
        .resolved(for: chrome?.club ?? model.team)
    }

    public init(
        model: OpponentFilmReadModel,
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
        }
    }

    // MARK: Standard composition -- `04` 6.1f (chrome) plus this file's own flow-laid body.

    private var standardComposition: some View {
        ZStack(alignment: .topLeading) {
            chromeBarRegion
                .frame(width: FilmMetric.chromeSize.width, height: FilmMetric.chromeSize.height)
                .position(FilmMetric.center(FilmMetric.chromeOrigin, FilmMetric.chromeSize))

            VStack(alignment: .leading, spacing: .zero) {
                ZStack(alignment: .topTrailing) {
                    coldFlood
                    ghostMark
                    floodContent
                        .padding(FilmMetric.inset)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                .frame(height: FilmMetric.floodHeight)
                .clipped()
                ForgeFieldSeam(.hard, axis: .horizontal)
                studiedContent
                    .padding(FilmMetric.inset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(club.palette.ground1.color)
            }
            .frame(width: FilmMetric.bodySize.width, height: FilmMetric.bodySize.height)
            .position(FilmMetric.center(FilmMetric.bodyOrigin, FilmMetric.bodySize))
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
        HStack(spacing: FilmMetric.gap) {
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
                    .frame(width: FilmMetric.chromeSize.height, height: FilmMetric.chromeSize.height)
                    .background(club.palette.ground3.color)
            }
            styledText(model.team.name.uppercased(), .chrome)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(1)
            Spacer(minLength: .zero)
        }
        .padding(.horizontal, FilmMetric.gap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(club.palette.ground1.color)
    }

    // MARK: Flooded strip -- staged, above the seam. Cold, never club colour (see header comment).

    /// `04` 6.1e's fixed `signal-cold` blended over the device's own `ground0` at `Edge.raised`'s
    /// alpha -- see this file's own header comment for why this composition, not a flat fill.
    private var coldFlood: some View {
        ForgeFieldTokens.Fixed.signalCold.color
            .opacity(ForgeFieldTokens.Edge.raised)
    }

    /// The oversized ghost mark, standard section 2.7 (via `ForgeFieldBudget`): 230 pt, the
    /// standard's own default .13 opacity, bleeding the flood's top-right corner -- the same
    /// corner `CoachingHQView.ghostMark` bleeds, no corner of its own being stamped for this
    /// surface. Fully desaturated (`Color.white`), not the standard's .75 default: see this file's
    /// own header comment.
    @ViewBuilder
    private var ghostMark: some View {
        if let opponent = model.opponent {
            CoachWorldTeamLogo(
                team: opponent,
                dimension: FilmMetric.ghostSize,
                surface: ForgeFieldTokens.Fixed.rival
            )
                .saturation(0)
                .brightness(FilmMetric.ghostBrightness)
                .opacity(FilmMetric.ghostOpacity)
                .offset(x: FilmMetric.ghostOffsetX, y: FilmMetric.ghostOffsetY)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    private var floodContent: some View {
        HStack(spacing: FilmMetric.sectionGap) {
            if let opponent = model.opponent {
                ForgeFieldChip {
                    CoachWorldTeamLogo(
                        team: opponent,
                        dimension: FilmMetric.fixtureMarkImageSize,
                        surface: ForgeFieldTokens.Fixed.rival
                    )
                    .saturation(0)
                    .frame(
                        width: FilmMetric.fixtureMarkPlateSize,
                        height: FilmMetric.fixtureMarkPlateSize
                    )
                    .background(
                        ForgeFieldTokens.Fixed.rival.color.opacity(ForgeFieldTokens.Edge.raised)
                    )
                }
                .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: FilmMetric.tightGap) {
                if let statusMessage {
                    statusBanner(statusMessage)
                }
                HStack(alignment: .firstTextBaseline, spacing: FilmMetric.gap) {
                    styledText(headlineText, .heading)
                        .foregroundStyle(club.palette.ink1.color)
                        .lineLimit(filmLineLimit)
                    if !model.isCurrent {
                        styledText("STALE", .columnHead)
                            .foregroundStyle(ForgeFieldTokens.Fixed.signalCaution.color)
                    }
                }
                styledText(filmCoverageLine, .prose)
                    .foregroundStyle(club.palette.ink3.color)
                    .lineLimit(filmLineLimit)
            }
        }
    }

    private var headlineText: String {
        model.opponent?.name.uppercased() ?? "NO SCHEDULED OPPONENT"
    }

    private var filmCoverageLine: String {
        let games = model.sourceGameCount
        return games == 1 ? "What one game of film holds" : "What \(games) games of film hold"
    }

    /// Deviation-proofing, applied from the start rather than found on render (the same class of
    /// fault `TeamHealthView.playerRow`'s own header comment records): at an accessibility size the
    /// limit lifts, matching `ForgeFieldEmber.lineLimit(for:)`'s identical rule.
    private var filmLineLimit: Int? {
        dynamicTypeSize.isAccessibilitySize ? nil : 1
    }

    /// The save-status receipt -- it has to reach the player while they are playing, matching the
    /// priority `CoachingHQView`/`InboxView`/`GamePlanView`/`TeamHealthView` give the same fact.
    private func statusBanner(_ text: String) -> some View {
        styledText(text, .proseMin)
            .foregroundStyle(ForgeFieldTokens.Fixed.signalAlarm.color)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Studied (below the seam) -- the evidence, or its honest absence (`04` 4.4).

    private var studiedContent: some View {
        VStack(alignment: .leading, spacing: FilmMetric.sectionGap) {
            evidenceContent
                .frame(maxHeight: .infinity, alignment: .top)
            HStack {
                Spacer(minLength: .zero)
                continueControl
            }
        }
    }

    @ViewBuilder
    private var evidenceContent: some View {
        if let reason = model.unavailableReason {
            styledText("Opponent film unavailable. " + reason, .prose)
                .foregroundStyle(club.palette.ink3.color)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: FilmMetric.sectionGap) {
                tendencies
                sourcePanel
            }
        } else {
            HStack(alignment: .top, spacing: FilmMetric.sectionGap) {
                tendencies
                sourcePanel
                    .frame(width: FilmMetric.panelWidth)
            }
        }
    }

    /// The two retained tendencies, contract row 10 -- pass rate and turnover rate, nothing else.
    private var tendencies: some View {
        VStack(alignment: .leading, spacing: FilmMetric.gap) {
            styledText("What the film says".uppercased(), .columnHead)
                .foregroundStyle(club.palette.ink4.color)
            tendencyRow(
                "Pass rate", proportion: Double(model.passRate) / 100,
                split: "\(model.passRate)% pass \u{00B7} \(100 - model.passRate)% run"
            )
            tendencyRow(
                "Turnovers", proportion: Double(model.turnoverRate) / 100,
                split: "\(model.turnoverRate)% of drives"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// AX5-safe from the start (matching `TeamHealthView.playerRow`'s render-found fix, applied
    /// here pre-emptively): a fixed-width situation/split pair only at the standard size; an
    /// accessibility size stacks the three facts instead of cramming them into a column budget
    /// that cannot grow.
    private func tendencyRow(_ situation: String, proportion: Double, split: String) -> some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: FilmMetric.tightGap) {
                    styledText(situation.uppercased(), .row)
                        .foregroundStyle(club.palette.ink1.color)
                    tendencyBar(proportion)
                    styledText(split, .figure)
                        .foregroundStyle(club.palette.ink2.color)
                }
            } else {
                HStack(spacing: FilmMetric.gap) {
                    styledText(situation.uppercased(), .row)
                        .foregroundStyle(club.palette.ink1.color)
                        .lineLimit(1)
                        .frame(width: FilmMetric.situationColumn, alignment: .leading)
                    tendencyBar(proportion)
                    styledText(split, .figure)
                        .foregroundStyle(club.palette.ink2.color)
                        .lineLimit(1)
                        .frame(width: FilmMetric.splitColumn, alignment: .trailing)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(situation), \(split)")
    }

    /// Ink, never club colour, gold or ember -- `04` 6.1e: club colour is "illegal as... a chart
    /// series", the exact role this bar would otherwise play. Matches `PracticePlanView.shareBar`'s
    /// identical monochrome treatment.
    private func tendencyBar(_ proportion: Double) -> some View {
        let clamped = min(1, max(0, proportion))
        return GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(club.palette.hairline.color.opacity(ForgeFieldTokens.Edge.panel))
                Capsule()
                    .fill(club.palette.ink2.color)
                    .frame(width: proxy.size.width * clamped)
            }
        }
        .frame(height: FilmMetric.tightGap)
        .accessibilityHidden(true)
    }

    /// The three retained source figures, contract row 10 -- confidence, source games, retained
    /// fixtures, nothing else, plus the fixed disclaimer sentence unchanged from the Press Box
    /// surface this file replaces.
    private var sourcePanel: some View {
        VStack(alignment: .leading, spacing: FilmMetric.gap) {
            styledText("How far this goes".uppercased(), .columnHead)
                .foregroundStyle(club.palette.ink4.color)
            figureRow("Confidence", "\(model.confidence)%")
            figureRow("Source games", "\(model.sourceGameCount)")
            figureRow("Retained fixtures", "\(model.sourceFixtureCount)")
            styledText(
                "Everything here comes off film the staff has watched. "
                    + "The league's own totals are not shown.", .proseMin
            )
            .foregroundStyle(club.palette.ink4.color)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// A plain label/spacer/value row -- no fixed-width column on either side, so nothing here can
    /// repeat `TeamHealthView.playerRow`'s render-found AX5 clip: the row simply grows.
    private func figureRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: FilmMetric.gap) {
            styledText(label, .prose)
                .foregroundStyle(club.palette.ink3.color)
            Spacer(minLength: FilmMetric.gap)
            styledText(value, .figure)
                .foregroundStyle(club.palette.ink1.color)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)")
    }

    // MARK: Continue -- ruling 1: a quiet, plain control, never an ember. Gated on `isCurrent`,
    // unchanged from the Press Box surface this file replaces.

    private var continueControl: some View {
        Button(action: onContinue) {
            styledText("Into the game plan \u{2192}".uppercased(), .chrome)
                .tracking(CoachWorldTokens.DisplaySize.tracking(
                    ForgeFieldType.Tracking.chrome.em, at: ForgeFieldType.Step.chrome.points))
                .foregroundStyle(club.palette.ink3.color)
                .frame(minWidth: ForgeFieldTokens.Space.hitMin,
                       minHeight: ForgeFieldTokens.Space.hitMin, alignment: .trailing)
        }
        .buttonStyle(.plain)
        .disabled(!model.isCurrent)
        .opacity(model.isCurrent ? 1 : CoachWorldTokens.Motion.resolvedDisabledOpacity(for: contrast))
    }

    // MARK: Accessible composition -- AX5 reflows to one scrollable column, `04` section 7: "cut
    // rows, never shrink type." Nothing here is fixed-position or fixed-height.

    private var accessibleComposition: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FilmMetric.sectionGap) {
                chromeBarRegion
                ZStack(alignment: .topTrailing) {
                    coldFlood
                    ghostMark
                    floodContent
                        .padding(FilmMetric.inset)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                ForgeFieldSeam(.hard, axis: .horizontal)
                evidenceContent
                HStack {
                    Spacer(minLength: .zero)
                    continueControl
                }
            }
            .padding(.horizontal, FilmMetric.inset)
            .padding(.bottom, FilmMetric.sectionGap)
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
/// available" note. Only the chrome bar's position and `floodHeight` are transcribed facts;
/// everything else is this file's own choice from `ForgeFieldTokens.Space.ladder`, matching
/// `InboxMetric`'s own convention (`InboxView.swift`).
private enum FilmMetric {
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

    /// The sheet's stamped stage figure, "33% (130 of 393)" -- transcribed verbatim, not derived
    /// from the ladder, per this file's own header comment.
    static let floodHeight: CGFloat = 130

    /// `ForgeFieldBudget.weeklyCommand[.opponentReportFilmRoom]`'s `ghost`.
    static let ghostSize: CGFloat = 230
    static let ghostOpacity: Double = ForgeFieldTokens.Register.ghostOpacity
    static let ghostBrightness = 0.5
    static let ghostOffsetX: CGFloat = 42
    static let ghostOffsetY: CGFloat = -48
    static let fixtureMarkPlateSize: CGFloat = 48
    static let fixtureMarkImageSize: CGFloat = 34

    static let situationColumn: CGFloat = 110
    static let splitColumn: CGFloat = 150
    static let panelWidth: CGFloat = 240

    static func center(_ origin: CGPoint, _ size: CGSize) -> CGPoint {
        CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
}

// MARK: - Assertable budget facts

extension OpponentFilmView {
    /// Facts drawn once above the seam.
    public static let floodDataPointRoles: [String] = [
        "flood.opponentName", "flood.isCurrent", "flood.sourceGameCount",
    ]

    /// Facts drawn once below the seam -- the two retained tendencies and the three source
    /// figures, contract row 10's own ceiling on what this surface may hold.
    public static let evidenceDataPointRoles: [String] = [
        "tendency.passRate", "tendency.turnoverRate",
        "source.confidence", "source.sourceGameCount", "source.sourceFixtureCount",
    ]

    /// `ForgeFieldBudget.weeklyCommand[.opponentReportFilmRoom]`'s `dataPoints` (34) is asserted
    /// against this total in `DesignContractTests.swift`, not restated -- checked as "at or under",
    /// matching this family's own precedent. Unlike `InboxView`/`GamePlanView`, this total is a
    /// flat, fixed count rather than a reference-row estimate: nothing on this surface repeats per
    /// row, so there is nothing to multiply by a viewport-fitted count.
    public static let dataPointCount = floodDataPointRoles.count + evidenceDataPointRoles.count

    /// Ruling 2: zero, anywhere on this surface -- "none of this standing is ours."
    public static let goldElementCount = 0

    /// Ruling 1: zero, corrected from the sheet's drawn ember. See this file's own header comment.
    public static let emberElementCount = 0

    /// This surface's own two backgrounds: the cold flood and the studied body's `ground1` fill.
    /// The shared chrome bar's own ground is furniture, not counted here, the same exclusion every
    /// other surface in this family states for its own fallback bar.
    public static let backgroundCount = 2

    /// The flooded strip's own stage fraction: its stamped height over the full device height,
    /// matching `PracticePlanView.stageFraction`'s identical construction.
    public static let stageFraction: Double =
        Double(FilmMetric.floodHeight / ForgeFieldTokens.Space.viewport.height)

    /// The ghost mark's size and opacity, `ForgeFieldBudget.weeklyCommand[.opponentReportFilmRoom]`'s
    /// `ghost` -- desaturated to zero, not the standard's .75 default (see this file's own header
    /// comment).
    public static let ghostSize = FilmMetric.ghostSize
    public static let ghostOpacity = FilmMetric.ghostOpacity
    public static let ghostDesaturated = true
}
