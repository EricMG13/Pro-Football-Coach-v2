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
    let horizon = 10
    let promotionSeason = max(1, horizon / 2)
    var store = try await CoachWorldStore.newCareer(seed: 92_020)
    var expected = try await store.saveDocument().gameState.calendar
    var promoted = false

    for step in 1...(horizon * SharedRules.inSeasonWeeks) {
        var advanced = false
        for attempt in 0..<4 {
            await store.prepareWeek()
            await store.delegateCurrentDecision()
            await store.advanceWeek()
            let snapshot = try await store.saveDocument()
            if snapshot.gameState.calendar == expected.advancedWeek() {
                expected = snapshot.gameState.calendar
                advanced = true
                break
            }
            if attempt == 3 {
                throw JourneyError(
                    "app-layer advance stalled at \(expected): "
                        + "\(store.statusMessage ?? "no refusal")"
                )
            }
        }
        guard advanced else { throw JourneyError("app-layer advance produced no calendar step") }

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

    let requiredFamilies: Set<CoachWorldSurfaceFamily> = [
        .weeklyCommand, .personnel, .league, .career,
        promoted ? .proManagement : .recruiting,
    ]
    let missingFamilies = requiredFamilies.filter { family in
        !restored.availableScreens.contains { $0.family == family && $0.isCanonicalTask }
    }
    guard missingFamilies.isEmpty else {
        throw JourneyError(
            "season \(season) missing operable screen families: "
                + missingFamilies.map(\.canonicalName).sorted().joined(separator: ", ")
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
