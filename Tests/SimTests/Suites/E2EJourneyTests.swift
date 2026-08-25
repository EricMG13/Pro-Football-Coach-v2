import Foundation
import FootballSimCore
import ProFootballCoachUI
import CoachWorldApp

/// The app target is @MainActor while this hand-rolled harness blocks its caller waiting for async
/// tests. Run the journey in a child process so the main actor remains schedulable and the parent
/// can still turn a dead end into an ordinary failing check.
func runE2EJourneyTests() {
    suite("E2E-F app promotion journey") {
        test("offer, destination, pending decision, and reload stay connected") {
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
    guard let before = store.careerHub,
          let beforeOffer = before.opportunities.first(where: { $0.id == opportunity.id.uuidString })
    else { throw JourneyError("the app layer dropped the pending offer") }
    guard beforeOffer.canAccept,
          store.availableScreens.contains(.promotionDecision),
          store.presentationRoute == String(CoachWorldScreenID.promotionDecision.rawValue)
    else {
        throw JourneyError(
            "precondition offer=\(beforeOffer.canAccept) promotion=\(store.availableScreens.contains(.promotionDecision)) "
                + "route=\(store.presentationRoute) expected=\(CoachWorldScreenID.promotionDecision.rawValue)"
        )
    }

    let beforeMutation = try await store.save()
    let reloadedPending = try await CoachWorldStore.load(from: beforeMutation)
    guard reloadedPending.careerHub?.opportunities.contains(where: {
        $0.id == opportunity.id.uuidString && $0.canAccept
    }) == true else { throw JourneyError("reload lost the unapplied offer") }

    await store.acceptCareerOpportunity(opportunity.id.uuidString)
    guard let after = store.careerHub,
          after.currentJob?.tier == "Professional",
          after.currentJob?.team.stableID == team.id.uuidString,
          after.opportunities.contains(where: { $0.id == opportunity.id.uuidString }) == false,
          after.history.contains(where: {
              $0.team.stableID == programmeID.uuidString && $0.reason == "Promoted"
          }),
          store.availableScreens.contains(.promotionDecision) == false,
          store.availableScreens.contains(.careerHub)
    else { throw JourneyError("the accepted offer did not reach the professional career hub") }

    let afterMutation = try await store.save()
    let restored = try await CoachWorldStore.load(from: afterMutation)
    guard let restoredHub = restored.careerHub,
          restoredHub.currentJob?.tier == "Professional",
          restoredHub.currentJob?.team.stableID == team.id.uuidString,
          restoredHub.history.contains(where: {
              $0.team.stableID == programmeID.uuidString && $0.reason == "Promoted"
          }),
          restored.availableScreens.contains(.promotionDecision) == false,
          restored.presentationRoute == String(CoachWorldScreenID.careerHub.rawValue)
    else { throw JourneyError("reload restored an unreachable promotion destination") }
}

private struct JourneyError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}
