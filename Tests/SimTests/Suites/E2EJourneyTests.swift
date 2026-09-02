import Foundation
import FootballSimCore
import ProFootballCoachUI
import CoachWorldApp

/// `CoachWorldStore` is main-actor isolated while the hand-rolled harness blocks its caller.
/// Exercise the app journey in a child process so the main actor remains schedulable.
func runE2EJourneyTests() {
    suite("E2E-F app promotion journey") {
        test("accepting an offer persists a reachable career destination") {
            let child = Process()
            let output = Pipe()
            child.executableURL = currentExecutableURL()
            child.arguments = ["--e2e-journey-child"]
            child.standardOutput = output
            child.standardError = output
            try child.run()
            child.waitUntilExit()
            let transcript = String(
                data: output.fileHandleForReading.readDataToEndOfFile(),
                encoding: .utf8
            ) ?? ""
            expectEqual(child.terminationStatus, 0, transcript)
            expect(transcript.contains("E2E-F PASS"), transcript)
        }
    }
}

func runE2EJourneyChild() {
    Task { @MainActor in
        do {
            try await exercisePromotionJourney()
            print("E2E-F PASS")
            exit(0)
        } catch {
            print("E2E-F FAIL: \(error)")
            exit(1)
        }
    }
    dispatchMain()
}

/// Parent-side dispatcher for the long E2E-H walk. The app store is @MainActor and the harness
/// blocks its caller, so the durability journey runs in a child process just like E2E-F.
func runE2EHDurabilityTests() {
    suite("E2E-H app durability journey") {
        test("ten seasons survive app-layer save and reload checkpoints") {
            let child = Process()
            let output = Pipe()
            child.executableURL = currentExecutableURL()
            child.arguments = ["--e2e-h-durability-child"]
            child.standardOutput = output
            child.standardError = output
            try child.run()
            child.waitUntilExit()
            let transcript = String(
                data: output.fileHandleForReading.readDataToEndOfFile(),
                encoding: .utf8
            ) ?? ""
            expectEqual(child.terminationStatus, 0, transcript)
            expect(transcript.contains("E2E-H PASS"), transcript)
        }
    }
}

func runE2EHDurabilityChild() {
    Task { @MainActor in
        do {
            try await exerciseDurabilityJourney()
            print("E2E-H PASS")
            exit(0)
        } catch {
            print("E2E-H FAIL: \(error)")
            exit(1)
        }
    }
    dispatchMain()
}

@MainActor
private func exerciseDurabilityJourney() async throws {
    // Already ten before the 2026-09-02 cap; it now reads the shared ceiling rather than its own
    // literal, so this lane cannot drift away from the others.
    let horizon = TestHorizon.clamped(
        ProcessInfo.processInfo.environment["E2E_HORIZON"].flatMap(Int.init)
            ?? TestHorizon.maximumSeasons
    )
    let promotionSeason = max(1, horizon / 2)
    let start = GameState.bootstrap(seed: 92_020)
    let programmeID = start.programmes.values.max { lhs, rhs in
        lhs.prestige.value == rhs.prestige.value
            ? lhs.id.uuidString < rhs.id.uuidString
            : lhs.prestige.value < rhs.prestige.value
    }!.id
    var store = try await CoachWorldStore.newCareer(seed: 92_020, programmeID: programmeID)
    var expected = try await store.saveDocument().gameState.calendar
    var promoted = false

    for step in 1...(horizon * SharedRules.inSeasonWeeks) {
        // `02` section 7: the carousel never dead-ends, and a durability journey has to walk it
        // rather than assume the first job lasts ten seasons. A coach sacked on merit is offered
        // the rebuild at the season boundary, and taking it is what keeps the remaining seasons
        // exercising a coach with an organisation instead of an empty career.
        try await takeAnyOfferIfUnemployed(in: store)
        var advanced = false
        for attempt in 0..<4 {
            await store.prepareWeek()
            await store.delegateCurrentDecision()
            await store.advanceWeek()
            try await finishControlledMatch(in: store)
            let snapshot = try await store.saveDocument()
            if snapshot.gameState.calendar == expected.advancedWeek() {
                expected = snapshot.gameState.calendar
                advanced = true
                break
            }
            if attempt == 3 {
                let stalled = try await store.saveDocument().gameState
                // The pre-advance root cannot answer why the portal refused: the postseason window
                // reads a recruiting season the college cycle opens part-way through the boundary
                // step. So replay the week under the transaction observer, catch the root the
                // scheduler itself hands the portal, and ask the two snapshots on that.
                let capture = JourneyBoundaryCapture()
                WorldScheduler.transactionObserver = { label, observed in
                    guard label == "collegeCycle.closeAndOpen" else { return }
                    capture.first(observed)
                }
                _ = try? WorldScheduler.advanceWeek(stalled)
                WorldScheduler.transactionObserver = nil
                let boundaryReport: String
                if let boundary = capture.state {
                    let target = boundary.calendar.season + 1
                    let policy = CollegePortalPolicyV1.makeSnapshot(
                        targetSeason: target, window: .postseason, in: boundary
                    )
                    let market = CollegePortalPolicyV1.makeMarketSnapshot(
                        targetSeason: target, window: .postseason, in: boundary
                    )
                    boundaryReport = " | boundary target \(target)"
                        + ", recruiting \(boundary.college.recruitingSeason)"
                        + ", phase \(boundary.college.portal.phase)"
                        + ", snapshot \(policy == nil ? "nil" : "ok")"
                        + ", market \(market == nil ? "nil" : "ok")"
                        + ", intents \(policy?.intents.count ?? -1)"
                } else {
                    boundaryReport = " | boundary never reached the college cycle"
                }
                throw JourneyError(
                    "app-layer advance stalled at \(expected): "
                        + "\(store.statusMessage ?? "no refusal")"
                        + " | portal \(stalled.college.portal.phase)"
                        + " target \(stalled.college.portal.targetSeason)"
                        + ", recruiting season \(stalled.college.recruitingSeason)"
                        + ", control \(stalled.career.college.map { "\($0.programmeID)" } ?? "none")"
                        + ", portal owner \(stalled.career.college?.responsibilityOwners[.portalAndRetention].map { "\($0)" } ?? "none")"
                        + ", job \(stalled.careerArc.currentJob.map { "\($0.tier)" } ?? "none")"
                        + ", pending \(stalled.pending.mandatoryDecisions.count)"
                        + " | arc \(stalled.careerArc.status)"
                        + ", support \(stalled.careerArc.stakeholderSupport.sorted { $0.key.rawValue < $1.key.rawValue }.map { "\($0.key.rawValue)=\($0.value)" }.joined(separator: ","))"
                        + ", pro seat \(stalled.career.pro == nil ? "none" : "seated")"
                        + ", jobs \(stalled.careerArc.jobHistory.map { "\($0.job.tier)@\($0.endedAt.season):\($0.reason)" }.joined(separator: " "))"
                        + ", offers \(stalled.careerArc.opportunities.count)"
                        + boundaryReport
                )
            }
        }
        guard advanced else { throw JourneyError("app-layer advance produced no calendar step") }

        // Before the checkpoint, not only at the top of the next step: a coach is sacked by the
        // season-end evaluation inside the advance that just ran, so the carousel's offer is
        // waiting now and the checkpoint would otherwise assert an unemployed shape one week early.
        try await takeAnyOfferIfUnemployed(in: store)
        if step % SharedRules.inSeasonWeeks == 0 {
            try await assertDurabilityCheckpoint(
                store: store,
                season: expected.season,
                promoted: promoted
            )
            if !promoted && expected.season >= promotionSeason {
                store = try await injectAndAcceptPromotion(in: store)
                promoted = true
            }
        }
    }

    guard promoted else { throw JourneyError("durability horizon never exercised promotion") }
}

/// Takes the carousel's offer through the same control the Career Hub uses, when the coach is out
/// of work. Silent when they are employed.
@MainActor
private func takeAnyOfferIfUnemployed(in store: CoachWorldStore) async throws {
    let arc = try await store.saveDocument().gameState.careerArc
    guard arc.currentJob == nil, let offer = arc.opportunities.first else { return }
    await store.acceptCareerOpportunity(offer.id.uuidString)
    let after = try await store.saveDocument().gameState.careerArc
    guard after.currentJob != nil else {
        throw JourneyError(
            "an unemployed coach could not take the offer it was given: "
                + "\(store.statusMessage ?? "no refusal")"
        )
    }
}

/// Durability advances use the public match controls to hand the game back to the coordinator
/// and record each snap; a controlled fixture intentionally cannot be skipped by week advance.
@MainActor
private func finishControlledMatch(in store: CoachWorldStore) async throws {
    let document = try await store.saveDocument()
    guard let initial = document.gameState.matchSession else { return }
    guard let fixtureID = initial.fixtureID else {
        throw JourneyError("controlled match has no fixture identity")
    }
    var revision = initial.revision
    if initial.isTakeover, initial.pendingCallIn == nil {
        await store.matchControl(.init(rawValue: "match|\(fixtureID.uuidString)|\(revision)|takeover"))
        revision += 1
    }
    var lastSyncedRevision = revision
    for snap in 1...MatchupRules.maximumDrivesPerGame * MatchupRules.maximumPlaysPerDrive {
        await store.matchControl(.init(rawValue: "match|\(fixtureID.uuidString)|\(revision)|advance"))
        revision += 1
        guard snap.isMultiple(of: 16) else { continue }
        let document = try await store.saveDocument()
        guard let match = document.gameState.matchSession else { return }
        guard match.fixtureID == fixtureID else {
            throw JourneyError("controlled match has no fixture identity")
        }
        revision = match.revision
        // A refused advance leaves the persisted checkpoint where it was, and the driver's local
        // revision then runs ahead until this resync -- so every later refusal reads as a stale
        // checkpoint and overwrites the real one. Fail on the first frozen window, against a
        // freshly synced revision, so the message is the refusal that actually stopped the match.
        guard snap == 16 || match.revision != lastSyncedRevision else {
            await store.matchControl(
                .init(rawValue: "match|\(fixtureID.uuidString)|\(revision)|advance")
            )
            throw JourneyError(
                "controlled match stopped advancing at \(document.gameState.calendar) "
                    + "revision \(match.revision): \(store.statusMessage ?? "no refusal")"
            )
        }
        lastSyncedRevision = match.revision
    }
    let stalled = try await store.saveDocument().gameState
    throw JourneyError(
        "controlled match exceeded its bounded snap budget at \(stalled.calendar): "
            + "completed \(stalled.matchSession?.completed.description ?? "no session"), "
            + "paused \(stalled.matchSession?.isPaused.description ?? "-"), "
            + "takeover \(stalled.matchSession?.isTakeover.description ?? "-"), "
            + "callIn \(stalled.matchSession?.pendingCallIn == nil ? "none" : "pending"), "
            + "revision \(stalled.matchSession?.revision.description ?? "-"), "
            + "status \(store.statusMessage ?? "no refusal")"
    )
}

@MainActor
private func assertDurabilityCheckpoint(
    store: CoachWorldStore,
    season: Int,
    promoted: Bool
) async throws {
    let clock = ContinuousClock()
    let writeStarted = clock.now
    let data = try await store.save()
    let writeSeconds = seconds(writeStarted.duration(to: clock.now))
    let loadStarted = clock.now
    let restored = try await CoachWorldStore.load(from: data)
    let loadSeconds = seconds(loadStarted.duration(to: clock.now))
    let restoredDocument = try await restored.saveDocument()
    let state = restoredDocument.gameState
    let deterministicData = try await restored.save()
    let deterministic = try await CoachWorldStore.load(from: deterministicData)
    let deterministicState = try await deterministic.saveDocument().gameState
    guard state == deterministicState else {
        throw JourneyError("season \(season) reload changed the authoritative game state")
    }
    guard WorldIntegrity.check(state).isValid else {
        throw JourneyError("season \(season) reload failed world integrity")
    }
    guard state.people.playerCareers.values.allSatisfy({
        $0.seasons.count <= PeopleRules.careerSeasonHistoryLimit
            && $0.portalWindows.count <= PeopleRules.portalWindowHistoryLimit
    }), state.people.playerLifecycle.values.allSatisfy({
        $0.recentChanges.count <= PeopleRules.recentChangeHistoryLimit
    }), state.history.recent.count <= state.history.retentionLimit,
    state.history.archive.count <= DomainEventLedger.maximumArchivedSeasons,
    state.competition.archives.count <= CompetitionState.archiveLimit,
    state.careerArc.jobHistory.count <= CareerArcState.maximumJobHistory,
    state.careerArc.opportunities.count <= CareerArcState.maximumOpportunities else {
        throw JourneyError("season \(season) exceeded a bounded collection")
    }

    // Read off the job the coach actually holds, not a latch set when a promotion was accepted.
    // `promoted` only ever said "a promotion happened at some point", so once the carousel could
    // return a sacked coach to college it started demanding professional screens of a college job.
    let requiredFamilies: Set<CoachWorldSurfaceFamily> = [
        .weeklyCommand, .personnel, .league, .career,
        state.careerArc.currentJob?.tier == .professional ? .proManagement : .recruiting,
    ]
    let missingFamilies = requiredFamilies.filter { family in
        !restored.availableScreens.contains { $0.family == family && $0.isCanonicalTask }
    }
    guard missingFamilies.isEmpty else {
        // Names the career state, not just the absent routes. Every family here is gated on the
        // coach holding an organisation, so "missing" and "no longer employed" look identical from
        // the outside -- and one is a product defect while the other is this fixture assuming a
        // job it never checked the coach still had.
        let job = state.careerArc.currentJob
        throw JourneyError(
            "season \(season) missing operable screen families: "
                + missingFamilies.map(\.canonicalName).sorted().joined(separator: ", ")
                + " | arc status \(state.careerArc.status)"
                + ", job \(job.map { "\($0.tier) \($0.organisationID)" } ?? "none")"
                + ", college control \(state.career.college == nil ? "none" : "seated")"
                + ", pro control \(state.career.pro == nil ? "none" : "seated")"
                + ", coach \(state.career.coachID.map { state.staff[$0] == nil ? "missing" : "present" } ?? "unset")"
                + " | support \(state.careerArc.stakeholderSupport.sorted { $0.key.rawValue < $1.key.rawValue }.map { "\($0.key.rawValue)=\($0.value)" }.joined(separator: ","))"
                + ", expectation \(state.careerArc.seasonExpectation.map { "season \($0.season) target \($0.target)" } ?? "none")"
                + ", jobs \(state.careerArc.jobHistory.map { "\($0.job.tier)@\($0.endedAt.season):\($0.reason)" }.joined(separator: " "))"
        )
    }
    print(String(
        format: "E2E-H checkpoint season %d: save %d B, write %.3f s, load %.3f s, "
            + "reload equal, bounded collections, screen families %@",
        season,
        data.count,
        writeSeconds,
        loadSeconds,
        requiredFamilies.map(\.canonicalName).sorted().joined(separator: "/")
    ))
}

@MainActor
private func injectAndAcceptPromotion(in store: CoachWorldStore) async throws -> CoachWorldStore {
    let document = try await store.saveDocument()
    guard let currentJob = document.gameState.careerArc.currentJob,
          let team = document.gameState.proTeams.values.sorted(by: {
              $0.id.uuidString < $1.id.uuidString
          }).first else {
        throw JourneyError("promotion fixture has no college job or professional destination")
    }
    let opportunity = CareerOpportunity(
        id: UUID(uuidString: "00000000-0000-4000-8000-000000000E21")!,
        organisationID: team.id,
        tier: .professional,
        offeredAt: document.gameState.calendar,
        expiresAt: document.gameState.calendar.advancedWeek(),
        prestige: team.prestige,
        rationale: .staffRecommendation
    )
    var state = document.gameState
    guard currentJob.tier == .college, state.careerArc.addOpportunity(opportunity) else {
        throw JourneyError("promotion fixture could not add a unique professional opportunity")
    }
    let pending = CoachWorldSaveDocument(
        gameState: state,
        presentation: CareerPresentationState(
            route: String(CoachWorldScreenID.promotionDecision.rawValue)
        ),
        metadata: document.metadata
    )
    let pendingStore = try await CoachWorldStore.load(document: pending)
    guard pendingStore.availableScreens.contains(.promotionDecision) else {
        throw JourneyError("promotion opportunity was not reachable from the app layer")
    }
    let pendingData = try await pendingStore.save()
    let reloadedPending = try await CoachWorldStore.load(from: pendingData)
    guard reloadedPending.availableScreens.contains(.promotionDecision) else {
        throw JourneyError("unapplied promotion decision did not survive reload")
    }
    await pendingStore.acceptCareerOpportunity(opportunity.id.uuidString)
    let acceptedData = try await pendingStore.save()
    let accepted = try await CoachWorldStore.load(from: acceptedData)
    guard accepted.careerHub?.currentJob?.tier == "Professional",
          accepted.availableScreens.contains(.proOffseason),
          !accepted.availableScreens.contains(.promotionDecision) else {
        throw JourneyError("promotion did not reach a durable professional app state")
    }
    return accepted
}

@MainActor
private func exercisePromotionJourney() async throws {
    let source = GameState.bootstrap(seed: 92_001)
    let programmeID = source.programmes.ids[0]
    let controlled = try CareerControlSystem.startCollegeCareer(
        at: programmeID,
        in: source
    ).state
    var pendingOffer = controlled
    pendingOffer.calendar = CalendarState(season: 0, week: 3)
    pendingOffer.league.week = 3
    let team = pendingOffer.proTeams.values.sorted { $0.id.uuidString < $1.id.uuidString }[0]
    let opportunity = CareerOpportunity(
        id: UUID(uuidString: "00000000-0000-4000-8000-000000000E20")!,
        organisationID: team.id,
        tier: .professional,
        offeredAt: pendingOffer.calendar,
        expiresAt: pendingOffer.calendar.advancedWeek(),
        prestige: team.prestige,
        rationale: .staffRecommendation
    )
    pendingOffer.pending = PendingQueues()
    pendingOffer.careerArc = CareerArcState(
        currentJob: CareerJob(
            organisationID: programmeID,
            tier: .college,
            startedAt: pendingOffer.calendar
        ),
        opportunities: [opportunity],
        status: .employed
    )
    let document = CoachWorldSaveDocument(
        gameState: pendingOffer,
        presentation: CareerPresentationState(
            route: String(CoachWorldScreenID.promotionDecision.rawValue)
        ),
        metadata: CareerSaveMetadata(createdFromSeed: 92_001)
    )

    let store = try await CoachWorldStore.load(document: document)
    guard let beforeOffer = store.careerHub?.opportunities.first(where: {
        $0.id == opportunity.id.uuidString
    }),
    beforeOffer.canAccept,
    store.availableScreens.contains(.promotionDecision),
    store.presentationRoute == String(CoachWorldScreenID.promotionDecision.rawValue) else {
        throw JourneyError("the app layer dropped the pending offer or its destination")
    }

    let beforeMutation = try await store.save()
    let reloadedPending = try await CoachWorldStore.load(from: beforeMutation)
    guard reloadedPending.careerHub?.opportunities.contains(where: {
        $0.id == opportunity.id.uuidString && $0.canAccept
    }) == true else {
        throw JourneyError("reload lost the unapplied offer")
    }

    await store.acceptCareerOpportunity(opportunity.id.uuidString)
    guard let after = store.careerHub,
          after.currentJob?.tier == "Professional",
          after.currentJob?.team.stableID == team.id.uuidString,
          !after.opportunities.contains(where: { $0.id == opportunity.id.uuidString }),
          after.history.contains(where: {
              $0.team.stableID == programmeID.uuidString && $0.reason == "Promoted"
          }),
          !store.availableScreens.contains(.promotionDecision),
          store.availableScreens.contains(.careerHub) else {
        throw JourneyError("the accepted offer did not reach the professional career hub")
    }

    let afterMutation = try await store.save()
    let restored = try await CoachWorldStore.load(from: afterMutation)
    guard let restoredHub = restored.careerHub,
          restoredHub.currentJob?.tier == "Professional",
          restoredHub.currentJob?.team.stableID == team.id.uuidString,
          restoredHub.history.contains(where: {
              $0.team.stableID == programmeID.uuidString && $0.reason == "Promoted"
          }),
          !restored.availableScreens.contains(.promotionDecision),
          restored.presentationRoute == String(CoachWorldScreenID.careerHub.rawValue) else {
        throw JourneyError("reload restored an unreachable promotion destination")
    }
}

private struct JourneyError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}

/// The weekly transaction observer is a `@Sendable` closure, so the boundary root it hands back
/// needs somewhere reference-shaped to land.
private final class JourneyBoundaryCapture: @unchecked Sendable {
    private(set) var state: GameState?

    func first(_ observed: GameState) {
        guard state == nil else { return }
        state = observed
    }
}
