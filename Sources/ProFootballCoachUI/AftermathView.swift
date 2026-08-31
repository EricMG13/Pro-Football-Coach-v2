import SwiftUI

/// Aftermath, drawn to the Forge Field standard -- `04` sections 6.1e, 6.1f, 6.2a, 6.2a(i), 6.3a,
/// 6.6a, 6.7a and 7. Phase 2B Task 8 of
/// `docs/plans/2026-08-30-forge-field-phase-2b-weekly-command.md`.
///
/// Replaces the Press Box `CoachWorldFloodlitStage` composition this surface drew before with
/// `ForgeFieldDevice` and the shared primitives (`ForgeFieldSeam`, `ForgeFieldRow`) plus
/// `ForgeFieldType`. **No `ForgeFieldEmber`** -- see "Zero embers" below. `ForgeFieldPanel` is
/// deliberately unused for the same reason `InboxView`/`TeamHealthView` state for their own bodies
/// -- see "Two backgrounds" below.
///
/// **Register, from the sheet's stamped spec column (`ForgeFieldBudget.weeklyCommand[.aftermath]`):**
/// Broadcast, READOUT -- no committing control. Stage 56% (218 of 393), band 55-65. Points above
/// seam 11 of 14. Gold 3 of 3 -- FINAL, the record, the milestone. Ember 0. Ghost 250 pt, .11,
/// top-right. Backgrounds 2 of 2. Ceremony none -- a regular week gets zero.
///
/// **Zero embers, deliberately.** The sheet: *"nothing here is irreversible... an ember here would
/// claim the result is a decision you made."* Leaving costs one quiet control, drawn as the sheet's
/// own `Week 11 →` -- this file cannot print a literal week number (`AftermathReadModel` carries no
/// week label; inventing one would be exactly the fabrication `04` 4.4 forbids), so `continueControl`
/// reads `CONTINUE \u{2192}` instead: the same quiet, ink, non-gold, non-ember control -- no gradient
/// fill, no glow, no gold -- built from `onContinue` alone.
///
/// **This is the only surface in the family that spends gold, and it spends all three.** `04` 6.1e:
/// gold is earned standing, max three per surface. `FINAL` (fixed furniture, not a model fact, but
/// gold because a final result is exactly the earned standing this token exists for), `resultLabel`
/// (“the record”) and `headline` (“the milestone”) are the three spends. **The grades panel below
/// the seam carries none**: three is the ceiling and this surface has already used it there.
///
/// **Row heights (ruling 3, dispatch 2026-08-30/31).** The grade rows carry no callback this
/// surface's own callback list does not already name -- there is no per-player selection or
/// navigation, only `onContinue`, optional `onOpenBoxScore` and `onNavigateChrome` -- so every row
/// is inert and `ForgeFieldRow(.dense)` (32 pt) is legal under `04` 6.3a's "legal only when the
/// whole row is inert", matching `TeamHealthView`'s identical reasoning for its own table.
///
/// **No sheet geometry was available for this surface in this environment**, the same gap
/// `InboxView.swift` recorded for Task 3 (the Figma/design-tool connector needs interactive
/// authorisation this session does not have, and the plan's "per-surface notes" section transcribes
/// no `x,y · w×h` for Aftermath). The one exception is the flood's own height: the stamped stage
/// figure, "56% (218 of 393)", is transcribed verbatim as `AftermathMetric.floodHeight`, matching
/// `PracticePlanView.floodHeight`'s identical precedent. Everything else is this file's own
/// composition from `ForgeFieldTokens.Space.ladder`, using ordinary SwiftUI flow layout rather than
/// absolute `.position()` placement -- `InboxView`'s own reasoning applies unchanged.
///
/// **Two backgrounds, flood and ground 1 only.** `ForgeFieldPanel` always fills `ground2`, so using
/// it for the "what the plan did" side panel would spend an unstamped third background. Both the
/// grades table and that panel instead sit directly on the one `ground1` fill this file draws once,
/// separated by a `ForgeFieldSeam` -- the same construction `InboxView`'s list/reading-pane split
/// already uses for an identical two-region studied zone.
///
/// **No ceremony.** `04` 6.7's earned ceremony is five a season and this is not one of them --
/// nothing here runs `ForgeFieldTokens.Motion.ceremony`; a regular week's result renders exactly
/// like every other, once.
///
/// **One deviation found on render, not by a test (adaptation rule, owner directive 2026-08-30).**
/// A real recorded outcome's "Called in" and "Injuries" lines, at up to 16 lines each plus the
/// evidence group, are far taller than the studied zone's own ~117 pt once the 218 pt flood is
/// subtracted -- `.frame(maxHeight: .infinity)` proposes a height, it does not clip a plain
/// VStack's natural content size to it, so `planSection` silently overflowed and starved the flood
/// down to a sliver on a real four-quarter game with a full call-in log. Invisible to every
/// passing test (the design-contract suite checks stamped facts, not pixel overflow), and only
/// found by simulating an actual game to completion on device. `planSection`'s own doc comment
/// records the fix: a `ScrollView`, the same shape `gradesSection` already used for its own
/// unbounded list.
public struct AftermathView: View, CoachWorldChromedSurface {
    /// The shared management chrome. Nil renders a minimal fallback bar carrying only team
    /// identity -- in production this is always populated when `model` is, so the fallback exists
    /// for previews and tests only.
    public var chrome: FloodlitChromeReadModel?
    public var onNavigateChrome: ((CoachWorldIntentID) -> Void)?

    public let model: AftermathReadModel
    public let statusMessage: String?
    public let onContinue: () -> Void
    public let onOpenBoxScore: (() -> Void)?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.forgeFieldClub) private var club

    public init(
        model: AftermathReadModel,
        statusMessage: String? = nil,
        onContinue: @escaping () -> Void,
        onOpenBoxScore: (() -> Void)? = nil
    ) {
        self.model = model
        self.statusMessage = statusMessage
        self.onContinue = onContinue
        self.onOpenBoxScore = onOpenBoxScore
    }

    public var body: some View {
        ForgeFieldDevice(club: AftermathMetric.club) {
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
                .accessibilitySortPriority(3)
                .frame(width: AftermathMetric.chromeSize.width, height: AftermathMetric.chromeSize.height)
                .position(AftermathMetric.center(AftermathMetric.chromeOrigin, AftermathMetric.chromeSize))

            VStack(alignment: .leading, spacing: .zero) {
                ZStack(alignment: .topTrailing) {
                    club.palette.clubDeep.color
                    ghostMark
                    outcomeHeader
                        .padding(AftermathMetric.inset)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .zIndex(1)
                    floodContent
                        .padding(AftermathMetric.inset)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .accessibilitySortPriority(1)
                }
                .frame(height: AftermathMetric.floodHeight)
                .clipped()
                .accessibilityRepresentation {
                    VStack(alignment: .leading, spacing: AftermathMetric.gap) {
                        outcomeHeader
                        floodContent
                    }
                }
                ForgeFieldSeam(.hard, axis: .horizontal)
                studiedContent
                    .padding(AftermathMetric.inset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(club.palette.ground1.color)
                    // Defensive backstop, matching the flood's own `.clipped()` two lines above:
                    // `.frame(maxHeight: .infinity)` only proposes a height, it does not clip a
                    // child's natural content size to it (see `planSection`'s own doc comment for
                    // the render-found overflow this caught). Clipping here means a future
                    // over-height addition to either studied column degrades to a hard edge
                    // instead of silently starving the flood above it again.
                    .clipped()
            }
            .frame(width: AftermathMetric.bodySize.width, height: AftermathMetric.bodySize.height)
            .position(AftermathMetric.center(AftermathMetric.bodyOrigin, AftermathMetric.bodySize))
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

    /// No `onClose` on this surface (the contract's own callback list: `onContinue`, optional
    /// `onOpenBoxScore`, `onNavigateChrome` -- no close route), so the fallback bar carries only
    /// identity, matching the shape every other fallback bar in this family uses minus the back
    /// link neither model nor contract gives it a callback for.
    private var fallbackChromeBar: some View {
        HStack(spacing: AftermathMetric.gap) {
            ForgeFieldChip {
                styledText(model.home.team.abbreviation.uppercased(), .chrome)
                    .foregroundStyle(club.palette.ink1.color)
                    .frame(width: AftermathMetric.chromeSize.height, height: AftermathMetric.chromeSize.height)
                    .background(club.palette.ground3.color)
            }
            styledText("Aftermath".uppercased(), .chrome)
                .foregroundStyle(club.palette.ink1.color)
                .lineLimit(1)
            Spacer(minLength: .zero)
        }
        .padding(.horizontal, AftermathMetric.gap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(club.palette.ground1.color)
    }

    // MARK: Flooded strip -- staged, above the seam. Broadcast, club colour, three gold spends.

    /// The oversized ghost mark, standard section 2.7 (via `ForgeFieldBudget`): 250 pt, .11
    /// opacity, bleeding the flood's top-right corner -- the same corner `CoachingHQView.ghostMark`
    /// bleeds. Not desaturated further (unlike the film room's cold ghost): this result belongs to
    /// the coach's own club, so the standard .75 default stands.
    private var ghostMark: some View {
        RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
            .fill(club.palette.hairline.color)
            .frame(width: AftermathMetric.ghostSize, height: AftermathMetric.ghostSize)
            .opacity(AftermathMetric.ghostOpacity)
            .offset(x: AftermathMetric.ghostSize / 2, y: -AftermathMetric.ghostSize / 2)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private var floodContent: some View {
        VStack(alignment: .leading, spacing: AftermathMetric.gap) {
            if let statusMessage {
                statusBanner(statusMessage)
            }
            VStack(alignment: .leading, spacing: AftermathMetric.tightGap) {
                ForEach(Array(scoreSides.enumerated()), id: \.offset) { index, side in
                    scoreLine(side, isLead: isDraw || index == 0)
                }
            }
            styledText(model.headline, .prose)
                .foregroundStyle(ForgeFieldTokens.Fixed.gold.color)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: .zero)
            HStack(spacing: AftermathMetric.sectionGap) {
                Spacer(minLength: .zero)
                if let onOpenBoxScore {
                    boxScoreLink(onOpenBoxScore)
                }
                continueControl
            }
        }
    }

    private var outcomeHeader: some View {
        HStack(spacing: AftermathMetric.gap) {
            styledText("FINAL", .columnHead)
                .foregroundStyle(ForgeFieldTokens.Fixed.gold.color)
            styledText(model.venue.name.uppercased(), .columnHead)
                .foregroundStyle(club.palette.ink3.color)
                .lineLimit(1)
            styledText(model.resultLabel.uppercased(), .columnHead)
                .foregroundStyle(ForgeFieldTokens.Fixed.gold.color)
                .lineLimit(1)
        }
        .fixedSize(horizontal: false, vertical: true)
        .layoutPriority(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("FINAL. \(model.venue.name.uppercased()). \(model.resultLabel.uppercased()).")
        .accessibilitySortPriority(2)
    }

    /// The result, read the way a result is read: the side that won first and largest. A draw has
    /// no winner to lead with, so both sides take the winner's weight -- unchanged from the Press
    /// Box surface this file replaces.
    private var scoreSides: [MatchDayReadModel.TeamScore] {
        model.home.score >= model.away.score ? [model.home, model.away] : [model.away, model.home]
    }

    private var isDraw: Bool { model.home.score == model.away.score }

    /// `fs-fixture` (62 pt) is canon's own named use for "final score" (`04` 6.2a's token table).
    /// The lead side takes it; the trailing side reads smaller, never larger than the lead.
    private func scoreLine(_ side: MatchDayReadModel.TeamScore, isLead: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AftermathMetric.gap) {
            styledText(side.team.name.uppercased(), isLead ? .heading : .row)
                .foregroundStyle(isLead ? club.palette.ink1.color : club.palette.ink3.color)
                .lineLimit(scoreLineLimit)
                .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 1 : AftermathMetric.nameScaleFloor)
            styledText("\(side.score)", isLead ? .fixture : .heading)
                .foregroundStyle(isLead ? club.palette.ink1.color : club.palette.ink3.color)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(side.team.name), \(side.score)")
    }

    /// Deviation-proofing, applied from the start (the same class of fault
    /// `TeamHealthView.playerRow`'s own header comment records was found on render): lifted at an
    /// accessibility size, matching `ForgeFieldEmber.lineLimit(for:)`'s identical rule.
    private var scoreLineLimit: Int? {
        dynamicTypeSize.isAccessibilitySize ? nil : 1
    }

    /// The save-status receipt -- it has to reach the player while they are playing, matching the
    /// priority every other surface in this family gives the same fact.
    private func statusBanner(_ text: String) -> some View {
        styledText(text, .proseMin)
            .foregroundStyle(ForgeFieldTokens.Fixed.signalAlarm.color)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Continue -- zero embers (see header comment). Quiet, ink, never gold.

    private var continueControl: some View {
        Button(action: onContinue) {
            styledText("Continue \u{2192}".uppercased(), .chrome)
                .tracking(CoachWorldTokens.DisplaySize.tracking(
                    ForgeFieldType.Tracking.chrome.em, at: ForgeFieldType.Step.chrome.points))
                .foregroundStyle(club.palette.ink1.color)
                .frame(minWidth: ForgeFieldTokens.Space.hitMin,
                       minHeight: ForgeFieldTokens.Space.hitMin, alignment: .trailing)
        }
        .buttonStyle(.plain)
    }

    private func boxScoreLink(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            styledText("Box score".uppercased(), .chrome)
                .tracking(CoachWorldTokens.DisplaySize.tracking(
                    ForgeFieldType.Tracking.chrome.em, at: ForgeFieldType.Step.chrome.points))
                .foregroundStyle(club.palette.ink3.color)
                .frame(minWidth: ForgeFieldTokens.Space.hitMin,
                       minHeight: ForgeFieldTokens.Space.hitMin, alignment: .trailing)
        }
        .buttonStyle(.plain)
    }

    // MARK: Studied (below the seam) -- the grades, and what the plan did. No gold here (see
    // header comment); every grade row is inert (ruling 3), so ForgeFieldRow(.dense) is legal.

    @ViewBuilder
    private var studiedContent: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: AftermathMetric.sectionGap) {
                gradesSection
                ForgeFieldSeam(.hair, axis: .horizontal)
                planSection
            }
        } else {
            HStack(alignment: .top, spacing: .zero) {
                gradesSection
                ForgeFieldSeam(.hair, axis: .vertical)
                    .padding(.horizontal, AftermathMetric.columnGap)
                planSection
                    .frame(width: AftermathMetric.panelWidth)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    @ViewBuilder
    private var gradesSection: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack(spacing: AftermathMetric.gap) {
                styledText("Grades".uppercased(), .panel)
                    .foregroundStyle(club.palette.ink4.color)
                Spacer(minLength: AftermathMetric.gap)
                styledText(
                    model.grades.count == 1 ? "1 player graded" : "\(model.grades.count) players graded",
                    .columnHead
                )
                .foregroundStyle(club.palette.ink4.color)
            }
            .padding(.bottom, AftermathMetric.gap)
            if model.grades.isEmpty {
                styledText("No player grades are recorded for this game.", .prose)
                    .foregroundStyle(club.palette.ink3.color)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: .zero) {
                        ForEach(model.grades) { grade in
                            gradeRow(grade)
                            ForgeFieldSeam(.hair, axis: .horizontal)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// One row, 32 pt dense (ruling 3: every row here is inert -- no tap, no navigation). Position
    /// and share bar are fixed-width only at the standard size, matching
    /// `TeamHealthView.playerRow`'s AX5-safe shape: an accessibility size stacks the facts instead
    /// of cramming them into a column budget that cannot grow.
    private func gradeRow(_ grade: AftermathReadModel.Grade) -> some View {
        let tint = tone(for: grade.rating)
        let content = Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: AftermathMetric.tightGap) {
                    styledText(grade.player.name, .row)
                        .foregroundStyle(club.palette.ink1.color)
                    HStack(spacing: AftermathMetric.gap) {
                        styledText(grade.position.uppercased(), .columnHead)
                            .foregroundStyle(club.palette.ink3.color)
                        styledText("\(grade.rating)", .figure)
                            .foregroundStyle(tint)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: AftermathMetric.gap) {
                    styledText(grade.position.uppercased(), .columnHead)
                        .foregroundStyle(club.palette.ink3.color)
                        .lineLimit(1)
                        .frame(width: AftermathMetric.positionColumn, alignment: .leading)
                    styledText(grade.player.name, .row)
                        .foregroundStyle(club.palette.ink1.color)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    gradeBar(grade.rating)
                        .frame(width: AftermathMetric.barColumn)
                    styledText("\(grade.rating)", .figure)
                        .foregroundStyle(tint)
                        .lineLimit(1)
                        .frame(width: AftermathMetric.figureColumn, alignment: .trailing)
                }
            }
        }
        .padding(.horizontal, AftermathMetric.gap)

        return ForgeFieldRow(.dense) { content }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(grade.position) \(grade.player.name), graded \(grade.rating). \(grade.evidence)"
            )
    }

    /// A rating is Personnel-Room evidence, not earned standing -- and the gold ceiling is already
    /// spent above the seam (header comment). Quiet ink only: `ink1` for an average-and-above
    /// grade, `ink3` for a below-average one -- a restrained, two-step distinction rather than an
    /// invented banded colour scale (Forge Field carries four fixed signals, not a rating gradient).
    private func tone(for rating: Int) -> Color {
        rating >= 70 ? club.palette.ink1.color : club.palette.ink3.color
    }

    /// Ink, never club colour, gold or ember -- `04` 6.1e forbids club colour as a chart series;
    /// gold is spent above the seam. Matches `PracticePlanView.shareBar`'s identical monochrome
    /// treatment, positioned on the rules' own 40-99 scale rather than 0-99 (a 45 is a bad grade,
    /// not a bar nearly half full) -- unchanged from the Press Box surface this file replaces.
    private func gradeBar(_ rating: Int) -> some View {
        let floor = 40.0, ceiling = 99.0
        let clamped = min(max(Double(rating), floor), ceiling)
        let proportion = (clamped - floor) / (ceiling - floor)
        return GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(club.palette.hairline.color.opacity(ForgeFieldTokens.Edge.panel))
                Capsule()
                    .fill(club.palette.ink2.color)
                    .frame(width: proxy.size.width * proportion)
            }
        }
        .frame(height: AftermathMetric.tightGap)
        .accessibilityHidden(true)
    }

    /// "What the plan did": retained evidence, call-ins and injuries, contract row 15's own
    /// ceiling. Fallback sentences ("Nothing was called in.", "Nobody came off hurt.") are
    /// unchanged from the Press Box surface this file replaces -- `04` 6.1e's voice rule,
    /// "ignorance is stated, not hidden".
    ///
    /// **Deviation found on render, not by a test (adaptation rule, owner directive 2026-08-30).**
    /// `evidence`, `callIns` and `injuries` are each bounded to 16 lines by the model (`prefix(16)`
    /// in `AftermathReadModel.init`), but 3 + up to 16 + up to 16 lines of wrapped prose is still
    /// far taller than the roughly 117 pt the studied zone has once the 218 pt flood is subtracted
    /// from the device height -- `.frame(maxHeight: .infinity)` on `studiedContent`'s call site
    /// only proposes that height, it does not clip a VStack's own natural content height to it, so
    /// the panel silently overflowed the flood down to a sliver -- invisible to every passing test,
    /// exactly the class of fault this rule exists to catch. The fix is the same shape
    /// `gradesSection` already uses for its own unbounded list: a fixed head outside a `ScrollView`
    /// that owns the actual growth, so the panel scrolls internally instead of pushing its
    /// container past the device frame.
    private var planSection: some View {
        VStack(alignment: .leading, spacing: .zero) {
            styledText("What the plan did".uppercased(), .panel)
                .foregroundStyle(club.palette.ink4.color)
                .padding(.bottom, AftermathMetric.gap)
            if dynamicTypeSize.isAccessibilitySize {
                planScrollContent
            } else {
                styledText("Scroll for call-ins and injuries", .proseMin)
                    .foregroundStyle(club.palette.ink3.color)
                    .padding(.bottom, AftermathMetric.tightGap)
                ScrollView {
                    planScrollContent
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var planScrollContent: some View {
        VStack(alignment: .leading, spacing: AftermathMetric.sectionGap) {
            planGroup("What the game turned on", model.evidence)
            planGroup("Called in", model.callIns.isEmpty ? ["Nothing was called in."] : model.callIns)
            planGroup("Injuries", model.injuries.isEmpty ? ["Nobody came off hurt."] : model.injuries)
        }
    }

    @ViewBuilder
    private func planGroup(_ title: String, _ lines: [String]) -> some View {
        if !lines.isEmpty {
            VStack(alignment: .leading, spacing: AftermathMetric.tightGap) {
                styledText(title.uppercased(), .columnHead)
                    .foregroundStyle(club.palette.ink4.color)
                ForEach(lines, id: \.self) { line in
                    styledText(line, .proseMin)
                        .foregroundStyle(club.palette.ink3.color)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: Accessible composition -- AX5 reflows to one scrollable column, `04` section 7: "cut
    // rows, never shrink type." Nothing here is fixed-position or fixed-height.

    private var accessibleComposition: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AftermathMetric.sectionGap) {
                chromeBarRegion
                    .accessibilitySortPriority(3)
                outcomeHeader
                    .padding(.horizontal, AftermathMetric.inset)
                floodContent
                    .padding(AftermathMetric.inset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(club.palette.clubDeep.color)
                ForgeFieldSeam(.hard, axis: .horizontal)
                studiedContent
            }
            .padding(.horizontal, AftermathMetric.inset)
            .padding(.bottom, AftermathMetric.sectionGap)
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
/// `HQMetric`'s own convention (`CoachingHQView.swift`).
private enum AftermathMetric {
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

    /// The sheet's stamped stage figure, "56% (218 of 393)" -- transcribed verbatim, not derived
    /// from the ladder, per this file's own header comment.
    static let floodHeight: CGFloat = 218

    /// `ForgeFieldBudget.weeklyCommand[.aftermath]`'s `ghost`.
    static let ghostSize: CGFloat = 250
    static let ghostOpacity: Double = 0.11

    /// A defensive scale floor for a long generated team name at the lead score line's large
    /// (`fs-heading`, 26 pt) size, matching `CoachingHQView.nameScaleFloor`'s identical role and
    /// reasoning -- 0.75 keeps even a long generated name on one line while staying well clear of
    /// `04` 6.2a(i)'s floors (26 * 0.75 = 19.5 pt, above `Step.panel`).
    static let nameScaleFloor: CGFloat = 0.75

    static let positionColumn: CGFloat = 40
    static let barColumn: CGFloat = 56
    static let figureColumn: CGFloat = 44
    static let panelWidth: CGFloat = 240

    static func center(_ origin: CGPoint, _ size: CGSize) -> CGPoint {
        CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
}

// MARK: - Assertable budget facts

extension AftermathView {
    /// The flood's own authored facts, above the hard seam --
    /// `ForgeFieldBudget.weeklyCommand[.aftermath]`'s `pointsAboveSeam` (11). `FINAL` is fixed
    /// furniture, not a model fact (excluded here the same way `CoachingHQView.floodFieldDataPoints`
    /// excludes its own "v" divider), even though it is one of the three gold spends.
    public static let floodFieldDataPoints: [String] = [
        "venue", "resultLabel", "homeTeamName", "homeScore", "awayTeamName", "awayScore", "headline",
    ]

    /// This surface's own gold spends: `FINAL`, `resultLabel` ("the record") and `headline` ("the
    /// milestone") -- `ForgeFieldBudget.weeklyCommand[.aftermath]`'s `goldMax` is 3; this draws all
    /// three, the ceiling for the whole surface (the grades panel below the seam spends none).
    public static let goldElementCount = 3

    /// Zero embers, deliberately. See this file's own header comment.
    public static let emberElementCount = 0

    /// This surface's own two backgrounds: the flood field's club-deep flood and the studied
    /// zone's `ground1` fill -- the shared chrome bar's own ground is furniture, not counted here,
    /// the same exclusion every other surface in this family states for its own fallback bar.
    public static let backgroundCount = 2

    /// The flood field's own stage fraction: its stamped height over the full device height,
    /// matching `CoachingHQView.stageFraction`'s identical construction.
    public static let stageFraction: Double =
        Double(AftermathMetric.floodHeight / ForgeFieldTokens.Space.viewport.height)

    /// The ghost mark's size and opacity, `ForgeFieldBudget.weeklyCommand[.aftermath]`'s `ghost`.
    public static let ghostSize = AftermathMetric.ghostSize
    public static let ghostOpacity = AftermathMetric.ghostOpacity
}
