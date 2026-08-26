import Foundation

public struct ProCapComplianceDecision: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let teamID: UUID
    public let createdAt: CalendarState

    public init(id: UUID, teamID: UUID, createdAt: CalendarState) {
        self.id = id
        self.teamID = teamID
        self.createdAt = createdAt
    }
}

public enum ProLegalActionKind: String, Codable, Sendable, Equatable, CaseIterable {
    case release
    case extendContract
    case promoteFromPracticeSquad
    case placeOnWaivers
    case restructure
}

public enum ProLegalAction: Sendable, Equatable {
    case management(ProManagementAction)
    case market(ProMarketAction)
}

public struct ProLegalActionProjection: Sendable, Equatable, Identifiable {
    public var id: String { "\(playerID.uuidString)|\(kind.rawValue)" }
    public let playerID: UUID
    public let kind: ProLegalActionKind
    public let currentCapHit: Int
    public let projectedRemainingCap: Int?
    public let projectedDeadMoney: Int?
    public let isEligible: Bool
    public let unavailableReason: String?
    public let action: ProLegalAction?
}

public struct ProCapComplianceProjection: Sendable, Equatable {
    public let cap: ProCapSnapshot
    public let decision: ProCapComplianceDecision?
    public let actions: [ProLegalActionProjection]
}

public enum ProCapComplianceSystem {
    public static func refresh(in state: GameState) -> GameState {
        var next = state
        guard let teamID = controlledTeamID(in: state),
              let cap = try? ProManagementSystem.capSnapshot(teamID: teamID, in: state),
              !cap.isWithinCap else {
            next.pending.setProfessionalCapCompliance(nil)
            return next
        }
        if state.pending.professionalCapCompliance?.teamID != teamID {
            let seasonSeed = SeededRandom.derive(
                from: SeededRandom.derive(
                    from: state.league.seed,
                    scope: .scheduler,
                    identifier: teamID
                ),
                scope: .season,
                ordinal: state.calendar.season
            )
            var rng = SeededRandom(seed: SeededRandom.derive(
                from: seasonSeed,
                scope: .week,
                ordinal: state.calendar.week
            ))
            next.pending.setProfessionalCapCompliance(ProCapComplianceDecision(
                id: rng.uuid(),
                teamID: teamID,
                createdAt: state.calendar
            ))
        }
        return next
    }

    public static func projection(
        teamID: UUID,
        in state: GameState
    ) throws -> ProCapComplianceProjection {
        guard let team = state.proTeams[teamID] else { throw ProManagementError.missingTeam }
        let cap = try ProManagementSystem.capSnapshot(teamID: teamID, in: state)
        let activeIDs = Set(team.rosterIDs)
        let rosterByPosition = Dictionary(
            grouping: team.rosterIDs.compactMap { state.players[$0] },
            by: \Player.position
        ).mapValues(\.count)
        var actions: [ProLegalActionProjection] = []
        for playerID in (team.rosterIDs + team.practiceSquadIDs)
            .sorted(by: { $0.uuidString < $1.uuidString }) {
            guard let player = state.players[playerID] else { continue }
            let currentCapHit = player.contract?.capHit(atSeason: state.calendar.season) ?? 0
            let releaseDeadMoney = player.contract?.deadMoney(
                ifReleasedAtSeason: state.calendar.season
            )
            let projectedReleaseCommitted = releaseDeadMoney.flatMap {
                projectedCommitted(cap.committedCap, replacing: currentCapHit, with: $0)
            }
            let projectedReleaseDeadMoney = releaseDeadMoney.flatMap {
                let (value, overflow) = cap.deadMoney.addingReportingOverflow($0)
                return overflow ? nil : value
            }
            let releaseReason: String?
            if player.contract == nil {
                releaseReason = "The player has no contract to release."
            } else if projectedReleaseCommitted == nil || projectedReleaseDeadMoney == nil {
                releaseReason = "Projected cap arithmetic exceeds supported bounds."
            } else if let projectedReleaseCommitted,
                      cap.isWithinCap,
                      projectedReleaseCommitted > cap.capLimit {
                releaseReason = "Release would exceed the salary cap."
            } else if let projectedReleaseCommitted,
                      !cap.isWithinCap,
                      projectedReleaseCommitted >= cap.committedCap {
                releaseReason = "Release would not reduce the salary cap overage."
            } else if activeIDs.contains(playerID),
                      rosterByPosition[player.position, default: 0]
                        <= (SharedRules.minimumPlayableRosterByPosition[player.position] ?? 0) {
                releaseReason = "Release would leave the active roster below required positional coverage."
            } else {
                releaseReason = nil
            }
            actions.append(row(
                playerID: playerID,
                kind: .release,
                currentCapHit: currentCapHit,
                projectedRemainingCap: projectedReleaseCommitted.map { cap.capLimit - $0 },
                projectedDeadMoney: projectedReleaseDeadMoney,
                reason: releaseReason,
                action: .management(.release(playerID: playerID, teamID: teamID))
            ))

            let negotiation = state.proMarket.contractNegotiations.first {
                $0.teamID == teamID && $0.playerID == playerID && $0.status.isOpen
            }
            let extensionCommitted = negotiation.flatMap {
                projectedCommitted(
                    cap.committedCap,
                    replacing: currentCapHit,
                    with: $0.currentOffer.withSignedSeason(state.calendar.season)
                        .capHit(atSeason: state.calendar.season)
                )
            }
            let extensionReason: String?
            if player.contract == nil {
                extensionReason = "The player has no contract to extend."
            } else if negotiation == nil {
                extensionReason = "No open contract offer exists."
            } else if negotiation?.isPastDeadline(at: state.calendar) == true {
                extensionReason = "The contract offer deadline has passed."
            } else if extensionCommitted == nil {
                extensionReason = "Projected cap arithmetic exceeds supported bounds."
            } else if let extensionCommitted,
                      !cap.isWithinCap,
                      extensionCommitted >= cap.committedCap {
                extensionReason = "The offer does not reduce the current cap overage."
            } else if let extensionCommitted,
                      cap.isWithinCap,
                      extensionCommitted > cap.capLimit {
                extensionReason = "The offer would exceed the salary cap."
            } else {
                extensionReason = nil
            }
            actions.append(row(
                playerID: playerID,
                kind: .extendContract,
                currentCapHit: currentCapHit,
                projectedRemainingCap: extensionCommitted.map { cap.capLimit - $0 },
                projectedDeadMoney: extensionCommitted.map { _ in cap.deadMoney },
                reason: extensionReason,
                action: negotiation.map {
                    .management(.acceptNegotiation(negotiationID: $0.id))
                }
            ))

            let promotionReason: String?
            if !team.practiceSquadIDs.contains(playerID) {
                promotionReason = "The player is not on the practice squad."
            } else if team.rosterIDs.count >= ProRules.activeRosterLimit {
                promotionReason = "The active roster is full."
            } else {
                promotionReason = nil
            }
            actions.append(row(
                playerID: playerID,
                kind: .promoteFromPracticeSquad,
                currentCapHit: currentCapHit,
                projectedRemainingCap: cap.remainingCap,
                projectedDeadMoney: cap.deadMoney,
                reason: promotionReason,
                action: .market(.promoteFromPracticeSquad(playerID: playerID, teamID: teamID))
            ))

            let waiverReason: String? = state.proMarket.waivers.contains {
                $0.playerID == playerID
            } ? "The player is already on waivers." : player.contract == nil
                ? "The player has no contract to waive." : nil
            actions.append(row(
                playerID: playerID,
                kind: .placeOnWaivers,
                currentCapHit: currentCapHit,
                projectedRemainingCap: cap.remainingCap,
                projectedDeadMoney: cap.deadMoney,
                reason: waiverReason,
                action: .market(.placeOnWaivers(playerID: playerID, teamID: teamID))
            ))
            actions.append(row(
                playerID: playerID,
                kind: .restructure,
                currentCapHit: currentCapHit,
                projectedRemainingCap: nil,
                projectedDeadMoney: nil,
                reason: "Restructuring is unavailable because salary conversion, eligibility, term-extension, and rounding rules are undefined.",
                action: nil
            ))
        }
        return ProCapComplianceProjection(
            cap: cap,
            decision: state.pending.professionalCapCompliance.flatMap {
                $0.teamID == teamID ? $0 : nil
            },
            actions: actions
        )
    }

    private static func row(
        playerID: UUID,
        kind: ProLegalActionKind,
        currentCapHit: Int,
        projectedRemainingCap: Int?,
        projectedDeadMoney: Int?,
        reason: String?,
        action: ProLegalAction?
    ) -> ProLegalActionProjection {
        ProLegalActionProjection(
            playerID: playerID,
            kind: kind,
            currentCapHit: currentCapHit,
            projectedRemainingCap: projectedRemainingCap,
            projectedDeadMoney: projectedDeadMoney,
            isEligible: reason == nil && action != nil,
            unavailableReason: reason,
            action: reason == nil ? action : nil
        )
    }

    private static func projectedCommitted(
        _ committed: Int,
        replacing current: Int,
        with replacement: Int
    ) -> Int? {
        let (withoutCurrent, underflow) = committed.subtractingReportingOverflow(current)
        guard !underflow else { return nil }
        let (projected, overflow) = withoutCurrent.addingReportingOverflow(replacement)
        return overflow ? nil : projected
    }

    private static func controlledTeamID(in state: GameState) -> UUID? {
        if let control = state.career.pro { return control.teamID }
        guard let job = state.careerArc.currentJob, job.tier == .professional else { return nil }
        return job.organisationID
    }
}
