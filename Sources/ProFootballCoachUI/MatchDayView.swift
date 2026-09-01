import FootballSimCore
import SwiftUI

public struct MatchDayView: View {
    /// Assertable Forge Field sheet facts. "Figures" are the qualified read-model values printed
    /// on the apron, not the twenty-two actors on the field and not the five intent controls.
    public static let apronDataPointRoles = [
        "score.homeTeam", "score.homeScore", "score.awayTeam", "score.awayScore",
        "situation.quarter", "situation.clock", "situation.down", "situation.yardsToGo",
        "situation.possession", "callIns.used", "callIns.total", "callIns.marks",
        "callIns.rateNote", "controlDepth",
    ]
    public static let stageFraction = 1.0
    public static let glassPlateCount = 4
    public static let goldElementCount = 3
    public static let emberElementCount = 1
    public static let ghostElementCount = 1
    public static let ghostSize = CoachWorldTeamLogoSize.field.rawValue
    public static let ghostOpacity = ForgeFieldTokens.Register.ghostOpacity
    public static let primaryControlCount = MatchDayControlID.allCases.count

    public let model: MatchDayReadModel
    public let statusMessage: String?
    public let onControl: (CoachWorldIntentID) -> Void
    public let onInterruption: (CoachWorldIntentID) -> Void
    /// Leaves Match Day — the handoff's "← WEEK" link in the lower third. Optional, and drawn only
    /// when supplied, so a caller with nowhere to go does not get a dead control.
    public let onExit: (() -> Void)?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsEvidence = false
    @State private var playbackStart: Date?
    /// Stops the timeline once the snap has finished. Without it `TimelineView(.animation)` keeps
    /// redrawing for as long as Match Day is on screen, which is most of a game.
    @State private var playbackComplete = false
    @State private var speedIndex = 0
    /// Total wall-clock time spent paused so far during the current snap, across however many
    /// pause/resume cycles happened. Without this, resuming after any real pause duration jumps the
    /// animation forward by that same duration — elapsed time keeps passing in the world regardless
    /// of whether the coach is watching it.
    @State private var pausedAccumulated: TimeInterval = 0
    /// Set while an in-progress pause has not yet been folded into `pausedAccumulated`.
    @State private var pausedSince: Date?

    public init(
        model: MatchDayReadModel,
        statusMessage: String? = nil,
        onControl: @escaping (CoachWorldIntentID) -> Void,
        onInterruption: @escaping (CoachWorldIntentID) -> Void,
        onExit: (() -> Void)? = nil
    ) {
        self.model = model
        self.statusMessage = statusMessage
        self.onControl = onControl
        self.onInterruption = onInterruption
        self.onExit = onExit
    }

    private var palette: CoachWorldTokens.Palette {
        CoachWorldTokens.dark
    }

    private var speedMultiplier: Double {
        MatchMetric.speedMultipliers[speedIndex % MatchMetric.speedMultipliers.count]
    }

    /// Whether the animated snap, rather than the upcoming one, is what the field is drawing.
    private var isAnimatingSnap: Bool {
        model.playback != nil && !reduceMotion
    }

    /// The lines to draw, from whichever snap the dots belong to.
    ///
    /// The model's pair describes the *upcoming* snap. That is right when nothing has been played
    /// and right under Reduce Motion, where the static pre-snap dots are what is on screen. It is
    /// wrong over a replay of the last snap: after a turnover the markers and the play sat at
    /// opposite ends of the field. Everything on the field comes from one snap.
    private var drawnLines: (lineOfScrimmage: Double, firstDown: Double) {
        guard isAnimatingSnap, let playback = model.playback else {
            return (model.lineOfScrimmage, model.firstDownLine)
        }
        return (playback.lineOfScrimmageX, playback.firstDownLineX)
    }

    /// How far through the recorded snap we are, 0 to 1.
    ///
    /// Reaching 1 leaves every dot at its end position, which is the pre-snap state for the next
    /// play — so the animation settles rather than snapping back.
    ///
    /// Subtracts every pause: `pausedAccumulated` for spans already finished, plus whatever of the
    /// current one — if `pausedSince` is set — has elapsed by `date`. Without the second term,
    /// checking progress *while still paused* would keep advancing with real time regardless, which
    /// is exactly the freeze this whole calculation exists to produce.
    /// The value it returns is **path** progress, not elapsed progress: elapsed time goes through
    /// `AnchorRules.pathFraction`, the `03` §9.6 stride profile, so a dot leaves its stance and is
    /// stopped rather than sliding at one speed from whistle to whistle. This is the only place
    /// that warp is applied, and every consumer below — the actor tracks, the ball's legs, and the
    /// loop that decides the snap is over — reads it from here, which is what makes it impossible
    /// for a man and the ball he is carrying to come apart. The profile is monotonic and fixes 1,
    /// so the completion loop still terminates on exactly the same frame it used to.
    private func progress(at date: Date, duration: Double) -> Double {
        guard let playbackStart, duration > 0 else { return 1 }
        let ongoingPause = pausedSince.map { date.timeIntervalSince($0) } ?? 0
        let elapsed = (date.timeIntervalSince(playbackStart) - pausedAccumulated - ongoingPause)
            * speedMultiplier
        return AnchorRules.pathFraction(atPlayback: elapsed / duration)
    }

    /// PRE-SNAP / SNAP / RESULT, `04` section 9's three frames — derived from presentation state
    /// only (whether a snap has been recorded, and whether its animation has settled), exactly
    /// like `isAnimatingSnap` already is. Drives the lower third's phase label and the committing
    /// action's cycling copy.
    private var phase: (label: String, isLive: Bool) {
        guard model.playback != nil else { return ("Pre-snap", false) }
        if isAnimatingSnap, !playbackComplete { return ("Snap", true) }
        return ("Result", false)
    }

    public var body: some View {
        ForgeFieldDevice(club: club) {
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    accessibleLayout
                } else {
                    standardLayout
                }
            }
            .frame(
                width: ForgeFieldTokens.Space.viewport.width,
                height: ForgeFieldTokens.Space.viewport.height
            )
        }
        .sheet(isPresented: $showsEvidence) { evidenceSheet }
    }

    // MARK: - Standard layout
    //
    // `04` section 6.1b: the field fills the frame edge to edge, and every other element is glass
    // furniture floating above it, positioned from the 844 x 390 frame's own edges rather than
    // stacked in rows beside the field. `CoachWorldTokens.Frame` carries the re-derived offsets.

    private var standardLayout: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack(alignment: .topLeading) {
                field(bandedVertical: true)
                    .frame(width: size.width, height: size.height)

                scoreBug
                    .padding(.leading, MatchMetric.apronLeading)
                    .padding(.top, MatchMetric.apronTop)

                playCallerPlate
                    .frame(width: MatchMetric.playCallerWidth)
                    .padding(.trailing, MatchMetric.apronTrailing)
                    .padding(.top, MatchMetric.apronTop)
                    .frame(maxWidth: size.width, alignment: .trailing)

                MatchLowerThird(
                    model: model, phase: phase.label, isLive: phase.isLive,
                    headline: model.playback?.sentence, onExit: onExit
                )
                .frame(width: MatchMetric.lowerThirdWidth)
                .padding(.leading, MatchMetric.apronLeading)
                .padding(.bottom, MatchMetric.apronBottom)
                .frame(maxHeight: size.height, alignment: .bottom)

                if model.staffInterruption == nil {
                    bottomRightCluster
                        .padding(.trailing, MatchMetric.apronTrailing)
                        .padding(.bottom, MatchMetric.apronBottom)
                        .frame(width: size.width, height: size.height, alignment: .bottomTrailing)
                }

                if let interruption = model.staffInterruption {
                    staffCallInPanel(interruption)
                        .frame(width: MatchMetric.callInWidth)
                        .frame(maxHeight: MatchMetric.callInHeight)
                        .padding(.trailing, MatchMetric.apronTrailing)
                        .padding(.top, MatchMetric.callInTop)
                        .frame(width: size.width, height: size.height, alignment: .topTrailing)
                        .transition(
                            .move(edge: .trailing).combined(with: .opacity)
                        )
                }

                if let statusMessage {
                    Text(statusMessage)
                        .font(CoachWorldTokens.TypeRole.caption)
                        .foregroundStyle(club.palette.ink2.color)
                        .padding(.horizontal, CoachWorldTokens.Space.sm)
                        .padding(.vertical, CoachWorldTokens.Space.xxs)
                        .background(club.palette.ground2.color)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous
                            )
                        )
                        .padding(.top, MatchMetric.apronTop)
                        .frame(width: size.width, alignment: .top)
                }
            }
            .coachWorldAnimation(
                CoachWorldTokens.Motion.panelEnter, value: model.staffInterruption != nil
            )
        }
        .accessibilityIdentifier("match-day-standard")
    }

    private var scoreBug: some View {
        ScoreBug(
            model: model,
            quarterLabel: quarterLabel,
            clockLabel: clockLabel,
            downDistance: "\(ordinal(model.situation.down)) & \(model.situation.yardsToGo)",
            spot: "\(possessionTeam.abbreviation) BALL"
        )
        .accessibilitySortPriority(100)
    }

    /// The authoritative 196-point play-caller plate. Budget and depth are retained read-model
    /// facts; no coordinator name is reconstructed when the model does not hold one.
    private var playCallerPlate: some View {
        VStack(alignment: .trailing, spacing: .zero) {
            if let budget = model.callInBudget {
                CallInBudgetBug(budget: budget)
            }
            ControlDepthSelector(depth: model.controlDepth) {
                onControl(model.controlDepthIntentID)
            }
        }
        .background(club.palette.ground0.color.opacity(ForgeFieldTokens.Material.glass))
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
                .strokeBorder(
                    club.palette.hairline.color.opacity(ForgeFieldTokens.Edge.panel),
                    lineWidth: ForgeFieldTokens.Edge.hairlineWidth
                )
        }
        .shadow(
            color: .black.opacity(MatchMetric.plateShadowAlpha),
            radius: MatchMetric.plateShadowRadius,
            y: MatchMetric.plateShadowY
        )
        .accessibilitySortPriority(85)
    }

    private var bottomRightCluster: some View {
        HStack(spacing: MatchMetric.controlGap) {
            compactControlButton(.speed, label: "Speed")
            compactControlButton(.pause, label: "Pause")
            compactControlButton(.keyMoments, label: "Key Moments")
            compactControlButton(.tactics, label: "Tactics")
            committingAction
        }
        .padding(.leading, MatchMetric.controlPadding)
        .background(club.palette.ground0.color.opacity(ForgeFieldTokens.Material.glass))
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
                .strokeBorder(
                    club.palette.hairline.color.opacity(ForgeFieldTokens.Edge.panel),
                    lineWidth: ForgeFieldTokens.Edge.hairlineWidth
                )
        }
        .shadow(
            color: .black.opacity(MatchMetric.plateShadowAlpha),
            radius: MatchMetric.plateShadowRadius,
            y: MatchMetric.plateShadowY
        )
        .accessibilitySortPriority(95)
    }

    private var committingAction: some View {
        let control = model.controls.first { $0.id == .takeOver }
        return ForgeFieldEmber(
            label: "Take the calls",
            cost: takeoverContext,
            isEnabled: control?.isEnabled != false
        ) {
            if let control { onControl(control.intentID) }
        }
        .frame(width: MatchMetric.emberWidth)
        .accessibilityLabel("Take Over. Take the calls. \(takeoverContext)")
    }

    private var takeoverContext: String {
        "\(clockLabel) left · \(ordinal(model.situation.down)) down"
    }

    private func compactControlButton(_ id: MatchDayControlID, label: String) -> some View {
        let control = model.controls.first { $0.id == id }
        return Button {
            if id == .speed {
                speedIndex = (speedIndex + 1) % MatchMetric.speedMultipliers.count
            }
            if let control { onControl(control.intentID) }
        } label: {
            VStack(spacing: .zero) {
                Text(label.uppercased())
                    .font(ForgeFieldType.font(.columnHead))
                    .lineLimit(1)
                    .minimumScaleFactor(MatchMetric.controlScaleFloor)
                if id == .speed {
                    Text("\(Int(speedMultiplier))×")
                        .font(ForgeFieldType.font(.figure))
                }
            }
            .foregroundStyle(club.palette.ink1.color)
            .frame(minWidth: MatchMetric.controlWidth(id),
                   minHeight: ForgeFieldTokens.Space.hitMin)
        }
        .buttonStyle(.plain)
        .disabled(control?.isEnabled == false)
        .opacity(control?.isEnabled == false ? MatchMetric.disabledOpacity : 1)
        .accessibilityLabel(id == .speed ? "Speed, \(Int(speedMultiplier)) times" : label)
        .accessibilityAddTraits(control?.isSelected == true ? .isSelected : [])
    }

    // MARK: - Accessible layout
    //
    // AX5 keeps the field whole and moves supporting text into a scrollable stack instead of
    // floating chrome, per the render-recorded-match contract. It reuses the same field and score
    // pieces at a fixed, generous size rather than the standard layout's frame-relative overlay
    // positions.

    private var accessibleLayout: some View {
        ScrollView {
            VStack(spacing: .zero) {
                accessibleScoreStrip
                field(bandedVertical: false)
                    .aspectRatio(MatchMetric.fieldAspect, contentMode: .fit)
                    .frame(height: MatchMetric.accessibleFieldHeight)
                MatchLowerThird(
                    model: model, phase: phase.label, isLive: phase.isLive,
                    headline: model.playback?.sentence, onExit: onExit
                )
                .padding(.horizontal, CoachWorldTokens.Space.sm)
                .padding(.top, CoachWorldTokens.Space.sm)
                if let interruption = model.staffInterruption {
                    interruptionRail(interruption)
                }
                if let statusMessage {
                    Text(statusMessage)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(CoachWorldTokens.Space.md)
                        .foregroundStyle(club.palette.ink2.color)
                        .background(club.palette.ground2.color)
                        .accessibilitySortPriority(65)
                }
                VStack(spacing: .zero) {
                    ForEach(orderedControls, id: \.id) { control in
                        controlButton(control)
                            .frame(maxWidth: .infinity)
                    }
                }
                .accessibilitySortPriority(60)
            }
        }
    }

    private var accessibleScoreStrip: some View {
        VStack(alignment: .leading, spacing: CoachWorldTokens.Space.xxs) {
            HStack(alignment: .firstTextBaseline, spacing: CoachWorldTokens.Space.md) {
                Text("\(model.away.team.abbreviation) \(model.away.score)  ·  "
                    + "\(model.home.team.abbreviation) \(model.home.score)")
                Spacer(minLength: .zero)
                Text("\(quarterLabel) · \(clockLabel)")
                    .monospacedDigit()
            }
            .font(ForgeFieldType.font(.chrome))
            Text("\(ordinal(model.situation.down)) & \(model.situation.yardsToGo)"
                + " · \(possessionTeam.abbreviation) BALL · LIVE CHECKPOINT")
                .font(ForgeFieldType.font(.prose))
        }
        .lineLimit(1)
        .minimumScaleFactor(MatchMetric.accessibleScoreScale)
        .padding(CoachWorldTokens.Space.sm)
        .frame(
            maxWidth: .infinity,
            minHeight: MatchMetric.accessibleScoreHeight,
            alignment: .leading
        )
        .foregroundStyle(club.palette.ink1.color)
        .background(club.palette.ground2.color)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(model.away.team.name) \(model.away.score), "
                + "\(model.home.team.name) \(model.home.score), "
                + "\(quarterLabel), \(clockLabel), \(ordinal(model.situation.down)) and "
                + "\(model.situation.yardsToGo), \(possessionTeam.name) ball, live checkpoint"
        )
        .accessibilitySortPriority(100)
    }

    // MARK: - The field
    //
    // Shared by both layouts. `bandedVertical` selects the vertical mapping: the standard layout's
    // full-bleed field keeps tokens inside the 10-90% band `04` section 6.1b states, clear of the
    // scorebug and lower third; the accessible layout's field sits in its own dedicated frame with
    // no chrome overlaid on it, so its tokens use the field's plain 0-1 span.

    private func field(bandedVertical: Bool) -> some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack(alignment: .topLeading) {
                FieldPlane(
                    tier: model.tier,
                    leftIdentity: identity(for: leftEndZoneTeam),
                    rightIdentity: identity(for: rightEndZoneTeam),
                    leftLabel: leftEndZoneTeam.abbreviation,
                    rightLabel: rightEndZoneTeam.abbreviation,
                    mark: fieldMarkContent
                )
                .equatable()

                fieldMarker(
                    x: size.width * CGFloat(drawnLines.lineOfScrimmage / 120),
                    height: size.height,
                    color: palette.fieldLine.color,
                    glow: false,
                    label: "Line of scrimmage"
                )
                fieldMarker(
                    x: size.width * CGFloat(drawnLines.firstDown / 120),
                    height: size.height,
                    color: ForgeFieldTokens.Fixed.gold.color,
                    glow: true,
                    label: "First-down line"
                )

                if let playback = model.playback, !reduceMotion {
                    let trackedIDs = Set(playback.actors.map(\.stableID))
                    let staticActors = model.actors.filter {
                        !trackedIDs.contains($0.stableID)
                    }

                    ForEach(staticActors, id: \.stableID) { actor in
                        actorMark(
                            actor,
                            size: size,
                            banded: bandedVertical,
                            foregroundIDs: playback.foregroundIDs
                        )
                    }

                    TimelineView(
                        .animation(minimumInterval: MatchMetric.playbackTick,
                                   paused: playbackComplete || playback.isPaused)
                    ) { timeline in
                        let t = progress(at: timeline.date, duration: playback.durationSeconds)
                        ZStack(alignment: .topLeading) {
                            ForEach(playback.actors, id: \.stableID) { track in
                                animatedMark(
                                    track,
                                    at: t,
                                    isForeground: playback.foregroundIDs.contains(track.stableID),
                                    size: size,
                                    banded: bandedVertical
                                )
                            }
                            ballMark(playback, at: t, size: size, banded: bandedVertical)
                        }
                        // Pinned to the reader's size. `.position` resolves against its container's
                        // bounds, and this ZStack sits a level deeper than `actorMark` does, so
                        // leaving it to size itself would put every dot in the wrong place.
                        .frame(width: size.width, height: size.height)
                    }
                } else {
                    // Reduce Motion, and the state before the first snap of a game. `04` §7 asks for
                    // discrete state changes rather than fast travel, so this is a separate path and
                    // not an animation with its duration set to zero.
                    ForEach(model.actors, id: \.stableID) { actor in
                        actorMark(actor, size: size, banded: bandedVertical)
                    }
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .accessibilitySortPriority(80)
        // Keyed on the playback's own identity, which changes every snap. `recordedOutcomeID` is
        // built from the drive index and is constant across a drive, so keying on it froze every
        // snap after the first at its end positions.
        // Speed is part of the key so that changing it re-runs this: progress is measured against
        // wall time, so a multiplier that changed mid-play would jump the dots and leave the
        // completion sleep waiting on the old duration.
        .task(id: "\(model.playback?.stableID ?? model.recordedOutcomeID)|\(speedIndex)") {
            guard let playback = model.playback, !reduceMotion else {
                playbackComplete = true
                await autoAdvanceIfEligible()
                return
            }
            playbackStart = Date()
            pausedAccumulated = 0
            // A new snap cannot begin while paused — the engine's own guard blocks advancing — so
            // starting unpaused here is a structural guarantee, not an assumption.
            pausedSince = nil
            playbackComplete = false
            // Polled rather than a single fixed sleep, so completion naturally respects a pause:
            // the same progress(at:duration:) the view renders from is what this loop is waiting
            // on, so a pause that freezes the drawing also freezes this loop's notion of "done".
            while !Task.isCancelled, progress(at: Date(), duration: playback.durationSeconds) < 1 {
                try? await Task.sleep(for: .seconds(MatchMetric.playbackTick))
            }
            guard !Task.isCancelled else { return }
            playbackComplete = true
            await autoAdvanceIfEligible()
        }
        .onChange(of: model.playback?.isPaused ?? false) { _, isPaused in
            if isPaused {
                pausedSince = Date()
            } else if let since = pausedSince {
                pausedAccumulated += Date().timeIntervalSince(since)
                pausedSince = nil
            }
        }
    }

    /// Continuous drive playback: once a snap has finished, hold on the result briefly, then submit
    /// the same intent Key Moments' own tap already sends — this only ever emits an intent the
    /// coach could have tapped themselves, never anything the read model did not already offer.
    /// Cancelled the instant a new snap's `.task(id:)` identity fires, exactly like the completion
    /// loop above; nothing here can advance a snap this view is no longer showing.
    private func autoAdvanceIfEligible() async {
        // model is this task's own captured snapshot, frozen for as long as its id (keyed on the
        // current snap) does not change — safe to read staffInterruption and controls from it once,
        // since neither can change without the id changing too, but not safe to trust for a live
        // pause read across the sleep below. pausedSince is the same @State the onChange handler
        // above keeps current regardless of what this task captured, which is why pause is checked
        // through it instead.
        guard model.staffInterruption == nil, pausedSince == nil,
              let advance = model.controls.first(where: { $0.id == .keyMoments })
        else { return }
        try? await Task.sleep(for: .seconds(MatchMetric.autoAdvanceDwellSeconds / speedMultiplier))
        guard !Task.isCancelled, pausedSince == nil else { return }
        onControl(advance.intentID)
    }

    private func screenY(_ fraction: Double, height: CGFloat, banded: Bool) -> CGFloat {
        banded
            ? MatchFieldGeometry.y(fraction: fraction, in: height)
            : height * CGFloat(fraction)
    }

    /// One dot, between where it started and where the record says it finished.
    ///
    /// The foreground flag comes from the playback rather than from `model.foregroundActorIDs`.
    /// Those two lists mean different things: the model's describes the pre-snap state, while the
    /// playback's names the deciding matchup's two players and the carrier. Reading the model's here
    /// would highlight the wrong players and lose D2's whole point — the sack drawn as the
    /// protection duel that lost.
    private func animatedMark(
        _ track: MatchDayReadModel.Playback.ActorTrack,
        at fraction: Double,
        isForeground: Bool,
        size: CGSize,
        banded: Bool
    ) -> some View {
        let spot = Self.position(of: track, at: fraction)
        return actorToken(
            // The track's role, not its number — same rule the static field follows below.
            label: track.role,
            isOurs: track.side == model.perspective,
            isForeground: isForeground
        )
        .position(
            x: size.width * CGFloat(spot.x / 120),
            y: screenY(spot.y, height: size.height, banded: banded)
        )
        .accessibilityHidden(true)
    }

    /// Where a dot is at a point of the playback.
    ///
    /// Walks start, then each waypoint in order, then end, and interpolates within whichever pair
    /// brackets the fraction — the same rule `SnapAnchors.position(of:at:)` applies engine-side, so
    /// a man and the ball he is carrying cannot end up drawn in different places. A straight
    /// start-to-end interpolation is what let a receiver glide to the end spot while the ball went
    /// via the catch.
    static func position(
        of track: MatchDayReadModel.Playback.ActorTrack,
        at fraction: Double
    ) -> (x: Double, y: Double) {
        let t = Swift.min(1, Swift.max(0, fraction))
        var legs: [(x: Double, y: Double, fraction: Double)] = [(track.startX, track.startY, 0)]
        legs.append(contentsOf: track.waypoints.map { ($0.x, $0.y, $0.fraction) })
        legs.append((track.endX, track.endY, 1))

        for index in 1..<legs.count {
            let previous = legs[index - 1]
            let next = legs[index]
            guard t <= next.fraction else { continue }
            let span = next.fraction - previous.fraction
            guard span > 0 else { return (next.x, next.y) }
            let local = (t - previous.fraction) / span
            return (
                previous.x + (next.x - previous.x) * local,
                previous.y + (next.y - previous.y) * local
            )
        }
        return (track.endX, track.endY)
    }

    /// One actor's mark: a 15 pt token carrying its **position shorthand**, for all twenty-two.
    ///
    /// The handoff (MATCH-DAY.md section 4) is explicit on both counts — "labels are position
    /// shorthand, not numbers: `LT LG C RG RT QB RB X H Z TE` and `RE NT DT LE W M N RC LC FS SS`"
    /// — and the reference prototype labels every one of the twenty-two. `04` section 6.5 #18
    /// agrees: the diagram's marks are role tokens, which is what a position shorthand is and what
    /// a jersey number is not.
    ///
    /// An earlier pass here labelled only the three foregrounded actors, and did so with their
    /// jersey numbers, reasoning from section 6.2's 12 pt authored floor that a legible disc cannot
    /// go below about 20 pt. That reasoning does not survive contact with what actually shipped:
    /// this view already draws a 9 pt label on those three, so the floor was already being spent —
    /// it just bought three labels instead of twenty-two. Section 6.2 exempts tracked uppercase
    /// micro-labels from the floor, and a position shorthand is exactly that. Two-letter shorthands
    /// at 9 pt in a 15 pt token also fit where two-digit numbers did not, which is why the design
    /// specifies shorthands rather than numbers in the first place.
    ///
    /// Foreground still reads differently — `04` section 9 caps it at three and the deciding
    /// matchup has to be findable — but it now does so with a ring, not by being the only mark
    /// that carries any text at all.
    private func actorToken(label: String, isOurs: Bool, isForeground: Bool) -> some View {
        PlayerToken(label: label, isOurs: isOurs)
            .overlay {
                if isForeground {
                    Circle().stroke(
                        palette.fieldLive.color, lineWidth: MatchMetric.foregroundRing
                    )
                }
            }
    }

    /// The ball, on whichever leg of its journey is current. Height comes straight off the leg's
    /// own `apexHeight` — the model drives lift, scale, tilt and shadow separation, not the view.
    private func ballMark(
        _ playback: MatchDayReadModel.Playback,
        at fraction: Double,
        size: CGSize,
        banded: Bool
    ) -> some View {
        let leg = playback.ball.last { $0.startFraction <= fraction } ?? playback.ball.first
        return Group {
            if let leg {
                let span = Swift.max(MatchMetric.minimumLegSpan, leg.endFraction - leg.startFraction)
                let local = Swift.min(1, Swift.max(0, (fraction - leg.startFraction) / span))
                let x = leg.fromX + (leg.toX - leg.fromX) * local
                let y = leg.fromY + (leg.toY - leg.fromY) * local
                BallToken(ballHeight: leg.height(at: local))
                    .position(
                        x: size.width * CGFloat(x / 120),
                        y: screenY(y, height: size.height, banded: banded)
                    )
            }
        }
        .accessibilityHidden(true)
    }

    private func fieldMarker(
        x: CGFloat,
        height: CGFloat,
        color: Color,
        glow: Bool,
        label: String
    ) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: glow ? MatchMetric.firstDownWidth : MatchMetric.losWidth, height: height)
            .shadow(
                color: glow ? color.opacity(0.7) : .clear,
                radius: glow ? MatchMetric.firstDownGlow : .zero
            )
            .offset(x: x - (glow ? MatchMetric.firstDownWidth : MatchMetric.losWidth) / 2)
            .accessibilityLabel(label)
    }

    private func actorMark(
        _ actor: MatchDayReadModel.Actor,
        size: CGSize,
        banded: Bool,
        foregroundIDs: [String]? = nil
    ) -> some View {
        let foreground = (foregroundIDs ?? model.foregroundActorIDs).contains(actor.stableID)
        let offense = actor.side == model.situation.possession
        // The same mark the animated path uses, so the pre-snap field and the animated one cannot
        // drift apart in how they read. The accessible sentence is unchanged either way: the mark's
        // printed label getting shorter must not shorten what VoiceOver says about it, which is why
        // the label below still names the number as well as the position.
        return actorToken(
            label: actor.shorthand, isOurs: actor.side == model.perspective, isForeground: foreground
        )
            .position(
                x: size.width * CGFloat(actor.xYardsFromLeftGoalLine / 120),
                y: screenY(actor.yFraction, height: size.height, banded: banded)
            )
            // Explicit, because a background mark is a `Circle` and a shape is not an accessibility
            // element on its own. Without this the label would attach for the three foregrounded
            // actors, whose mark is built from a `Text`, and silently detach for the other
            // nineteen — the mark getting smaller must never make the actor quieter.
            .accessibilityElement()
            .accessibilityLabel(
                "\(offense ? "Offense" : "Defense"), \(actor.position) "
                    + "number \(actor.uniformNumber), at yard \(Int(actor.xYardsFromLeftGoalLine))"
            )
    }

    // MARK: - Staff call-in

    /// A retained interruption rail, opaque rather than a fifth glass plate. The standard frame
    /// gives it a finite scroll region so cost and consequence stay reachable at the install floor.
    private func staffCallInPanel(_ interruption: MatchDayReadModel.StaffInterruption) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CoachWorldTokens.Space.sm) {
                Text("STAFF CALL-IN")
                    .font(ForgeFieldType.font(.columnHead))
                    .tracking(
                        CoachWorldTokens.DisplaySize.tracking(
                            ForgeFieldType.Tracking.columnHead.em,
                            at: ForgeFieldType.Step.columnHead.points
                        )
                    )
                    .foregroundStyle(ForgeFieldTokens.Fixed.signalCaution.color)
                VStack(alignment: .leading, spacing: CoachWorldTokens.Space.xxs) {
                    Text(interruption.staff.name)
                        .font(ForgeFieldType.font(.chrome))
                    Text(interruption.staff.role)
                        .font(ForgeFieldType.font(.proseMin))
                        .foregroundStyle(club.palette.ink3.color)
                }
                Text(interruption.message)
                    .font(ForgeFieldType.font(.proseMin))
                    .fixedSize(horizontal: false, vertical: true)
                VStack(spacing: CoachWorldTokens.Space.sm) {
                    ForEach(interruption.actions, id: \.path) { action in
                        interruptionButton(action)
                    }
                }
                Text("CALL-IN \(callInFooterCount) · RATE SET BY CONTROL DEPTH")
                    .font(ForgeFieldType.font(.columnHead))
                    .foregroundStyle(club.palette.ink4.color)
            }
            .padding(CoachWorldTokens.Space.md)
        }
        .foregroundStyle(club.palette.ink1.color)
        .background(club.palette.ground1.color)
        .clipShape(
            RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
                .strokeBorder(
                    club.palette.hairline.color.opacity(ForgeFieldTokens.Edge.panel),
                    lineWidth: ForgeFieldTokens.Edge.hairlineWidth
                )
        }
        .accessibilitySortPriority(90)
    }

    private var callInFooterCount: String {
        guard let budget = model.callInBudget else { return "" }
        return "\(budget.used) OF \(budget.total)"
    }

    private func interruptionButton(
        _ action: MatchDayReadModel.StaffInterruption.Action
    ) -> some View {
        Button {
            onInterruption(action.intentID)
            if action.path == .inspectEvidence { showsEvidence = true }
        } label: {
            VStack(alignment: .leading, spacing: CoachWorldTokens.Gap.hair) {
                Text(action.title)
                    .font(ForgeFieldType.font(.row))
                Text("Cost: \(action.cost)")
                    .font(ForgeFieldType.font(.proseMin))
                    .foregroundStyle(club.palette.ink3.color)
                Text("Consequence: \(action.consequence)")
                    .font(ForgeFieldType.font(.proseMin))
                    .foregroundStyle(club.palette.ink3.color)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: ForgeFieldTokens.Space.hitMin,
                alignment: .leading
            )
            .padding(.horizontal, CoachWorldTokens.Space.sm)
        }
        .buttonStyle(.plain)
        .disabled(!action.isEnabled)
        .background(
            action.path == .accept
                ? club.palette.ground3.color
                : club.palette.ground2.color
        )
        .clipShape(
            RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
        )
        .opacity(action.isEnabled ? 1 : MatchMetric.disabledOpacity)
        .accessibilityLabel(
            "\(action.title). Cost: \(action.cost). Consequence: \(action.consequence)"
        )
    }

    // MARK: - AX5 controls and interruption rail (unchanged structure, restyled)

    @ViewBuilder
    private func controlButton(_ control: MatchDayReadModel.ControlState) -> some View {
        if control.id == .takeOver {
            ForgeFieldEmber(
                label: "Take the calls",
                cost: takeoverContext,
                isEnabled: control.isEnabled
            ) {
                onControl(control.intentID)
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Take Over. Take the calls. \(takeoverContext)")
        } else {
            let presentation = controlPresentation(control.id)
            let displayedValue = control.id == .speed ? "\(Int(speedMultiplier))x" : control.value
            let accessibilityLabel = displayedValue.map {
                "\(presentation.title), \($0)"
            } ?? presentation.title

            Button {
                if control.id == .speed {
                    speedIndex = (speedIndex + 1) % MatchMetric.speedMultipliers.count
                }
                onControl(control.intentID)
            } label: {
                VStack(spacing: CoachWorldTokens.Space.xxs) {
                    Text(presentation.title.uppercased())
                        .font(ForgeFieldType.font(.chrome))
                    if let displayedValue {
                        Text(displayedValue)
                            .font(ForgeFieldType.font(.figure))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: ForgeFieldTokens.Space.hitMin)
            }
            .buttonStyle(
                MatchControlButtonStyle(
                    selected: control.isSelected,
                    palette: club.palette
                )
            )
            .disabled(!control.isEnabled)
            .accessibilityLabel(Text(accessibilityLabel))
            .accessibilityAddTraits(control.isSelected ? .isSelected : [])
        }
    }

    private func interruptionRail(
        _ interruption: MatchDayReadModel.StaffInterruption
    ) -> some View {
        VStack(alignment: .leading, spacing: CoachWorldTokens.Space.xs) {
            Text("STAFF CALL-IN")
                .font(ForgeFieldType.font(.columnHead))
                .foregroundStyle(ForgeFieldTokens.Fixed.signalCaution.color)
            Text(interruption.staff.name)
                .font(ForgeFieldType.font(.chrome))
            Text(interruption.staff.role)
                .font(ForgeFieldType.font(.proseMin))
                .foregroundStyle(club.palette.ink3.color)
            Text(interruption.message)
                .font(ForgeFieldType.font(.prose))
                .fixedSize(horizontal: false, vertical: true)
            Text(interruption.actions.map(\.title).joined(separator: " · "))
                .font(ForgeFieldType.font(.proseMin))
                .foregroundStyle(club.palette.ink3.color)
            ForEach(interruption.actions, id: \.path) { action in
                interruptionButton(action)
            }
        }
        .padding(CoachWorldTokens.Space.sm)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .foregroundStyle(club.palette.ink1.color)
        .background(club.palette.ground1.color)
        .accessibilitySortPriority(90)
    }

    private var evidenceSheet: some View {
        NavigationStack {
            List(model.staffInterruption?.evidence ?? [], id: \.self, rowContent: Text.init)
                .navigationTitle("Call-in evidence")
                .toolbar { Button("Done") { showsEvidence = false } }
        }
    }

    // MARK: - Derived facts

    private var orderedControls: [MatchDayReadModel.ControlState] {
        MatchDayControlID.allCases.compactMap { id in model.controls.first { $0.id == id } }
    }

    private var possessionTeam: CoachWorldTeamReference {
        model.situation.possession == .home ? model.home.team : model.away.team
    }

    private var defendingTeam: CoachWorldTeamReference {
        model.situation.possession == .home ? model.away.team : model.home.team
    }

    private var leftEndZoneTeam: CoachWorldTeamReference {
        model.offenseDirection == .leftToRight ? possessionTeam : defendingTeam
    }

    private var rightEndZoneTeam: CoachWorldTeamReference {
        model.offenseDirection == .leftToRight ? defendingTeam : possessionTeam
    }

    /// The coach's own team. `home`/`away` is which side owns the venue, not who the coach
    /// works for — an away game is still "ours" — so this reads `model.perspective`, never
    /// `home` outright.
    private var ourTeam: CoachWorldTeamReference {
        model.perspective == .home ? model.home.team : model.away.team
    }

    private var club: ForgeFieldTokens.Club {
        .resolved(for: ourTeam)
    }

    /// Whichever end zone belongs to `ourTeam` carries identity styling; the other is always the
    /// neutral opponent ground, whatever the opponent's real colours are.
    private func identity(for team: CoachWorldTeamReference) -> CoachWorldTeamIdentity? {
        guard team.stableID == ourTeam.stableID else { return nil }
        return CoachWorldTeamIdentity(
            team: ourTeam,
            behind: CoachWorldTokens.Floodlit.roomDeep,
            inks: [CoachWorldTokens.dark.contentPrimary, CoachWorldTokens.Floodlit.goldInk]
        )
    }

    private var fieldMarkContent: FieldMarkContent {
        guard let event = model.event else {
            return FieldMarkContent(
                kind: .regular, team: ourTeam,
                glyph: ourTeam.abbreviation, lead: nil, trail: nil
            )
        }
        return FieldMarkContent(
            kind: model.kind, team: nil,
            glyph: event.mark, lead: event.markLead, trail: event.markTrail
        )
    }

    private var quarterLabel: String { "Q\(model.situation.quarter)" }

    private var clockLabel: String {
        String(
            format: "%d:%02d",
            model.situation.clockSecondsRemaining / 60,
            model.situation.clockSecondsRemaining % 60
        )
    }

    private func ordinal(_ value: Int) -> String {
        switch value {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "4th"
        }
    }

    private func controlPresentation(
        _ id: MatchDayControlID
    ) -> (title: String, symbol: MatchDayControlSymbol) {
        switch id {
        case .speed: ("Speed", .speed)
        case .pause: ("Pause", .pause)
        // forward.end.fill, not sparkles.tv: already a Control-furniture member (04 section 6.6),
        // and growing the vocabulary for a symbol that also read wrong for "advance to the next key
        // moment" was two defects, not one.
        case .keyMoments: ("Key Moments", .keyMoments)
        case .takeOver: ("Take Over", .takeOver)
        case .tactics: ("Tactics", .tactics)
        }
    }
}

/// `controlPresentation`'s symbol half, typed for the same reason `CoachWorldStatusChip.Symbol` is:
/// a `String` return is invisible to the "every SF Symbol the UI draws is a registered member" scan
/// (`DesignContractTests.swift`), which matches only a literal directly after `systemName:`/
/// `systemImage:`. `sparkles.tv` shipped through exactly this hole. These five are 04 section 6.6's
/// Control furniture row, a shared pool other components also draw from — so the contract test
/// asserts membership, not exclusive ownership the way `CoachWorldStatusChip.Symbol` owns Status.
enum MatchDayControlSymbol: String, CaseIterable {
    case speed = "speedometer"
    case pause = "pause.fill"
    case keyMoments = "forward.end.fill"
    case takeOver = "hand.raised.fill"
    case tactics = "rectangle.3.group"
}

private struct MatchControlButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let selected: Bool
    let palette: ForgeFieldTokens.ClubPalette

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, CoachWorldTokens.Space.sm)
            .foregroundStyle(palette.ink1.color)
            .background(selected ? palette.ground3.color : palette.ground2.color)
            .overlay {
                RoundedRectangle(
                    cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous
                )
                .strokeBorder(
                    palette.hairline.color.opacity(ForgeFieldTokens.Edge.panel),
                    lineWidth: ForgeFieldTokens.Edge.hairlineWidth
                )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: ForgeFieldTokens.Space.radius, style: .continuous)
            )
            .opacity(isEnabled ? 1 : MatchMetric.disabledOpacity)
            .brightness(configuration.isPressed ? -0.08 : 0)
    }
}

private enum MatchMetric {
    static let fieldAspect: CGFloat = 120 / 53.3
    static let apronLeading: CGFloat = 64
    static let apronTrailing: CGFloat = 16
    static let apronTop: CGFloat = 12
    static let apronBottom: CGFloat = 16
    static let playCallerWidth: CGFloat = 196
    static let lowerThirdWidth: CGFloat = 322
    static let emberWidth: CGFloat = 184
    static let callInWidth: CGFloat = 244
    static let callInHeight: CGFloat = 218
    static let callInTop: CGFloat = 120
    static let controlGap: CGFloat = 4
    static let controlPadding: CGFloat = 8
    static let controlScaleFloor: CGFloat = 0.72
    static let disabledOpacity = 0.38
    static let plateShadowAlpha = 0.60
    static let plateShadowRadius: CGFloat = 24
    static let plateShadowY: CGFloat = 10
    static let losWidth: CGFloat = 2
    static let firstDownWidth: CGFloat = 2
    static let firstDownGlow: CGFloat = 8
    static let accessibleScoreHeight: CGFloat = 64
    static let accessibleFieldHeight: CGFloat = 250
    static let accessibleScoreScale: CGFloat = 0.5

    static func controlWidth(_ id: MatchDayControlID) -> CGFloat {
        switch id {
        case .speed, .pause: ForgeFieldTokens.Space.hitMin
        case .keyMoments: 72
        case .tactics: 56
        case .takeOver: emberWidth
        }
    }
    /// The ring that marks one of `04` section 9's at-most-three foreground actors. All twenty-two
    /// tokens are the same size and all carry a label, so foreground is a ring rather than being
    /// the only mark with any text on it.
    static let foregroundRing: CGFloat = 2
    static let speedMultipliers: [Double] = [1, 2, 4]
    /// 60 Hz. D4's frame ceiling is 16.7 ms, and asking the timeline for more than that is asking
    /// for frames the budget does not have.
    static let playbackTick: Double = 1.0 / 60.0
    /// Guards the division that maps playback progress onto one ball leg. A zero-length leg is
    /// legal in the contract, and dividing by it would produce a position of nan.
    static let minimumLegSpan: Double = 0.0001
    /// How long a finished snap holds before the next one begins on its own. `02` section 3.1:
    /// "Between call-ins the match plays at drive granularity: the field animates, the drive
    /// summarises, the player watches" — watching, not tapping Key Moments after every play. Real
    /// time at 1x, scaled the same way the snap's own duration is, so a coach watching at 4x is not
    /// held on a dwell four times longer than the play that just finished.
    static let autoAdvanceDwellSeconds: Double = 1.2
}
