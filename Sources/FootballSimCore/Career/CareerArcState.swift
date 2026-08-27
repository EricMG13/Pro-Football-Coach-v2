import Foundation

public enum CareerStakeholder: String, Codable, Sendable, CaseIterable, Hashable {
    case administration
    case boosters
    case fanbase
    case lockerRoom
}

extension CareerStakeholder: CodingKeyRepresentable {}

public enum CareerJobTier: String, Codable, Sendable, CaseIterable {
    case college
    case professional
}

public enum CareerEmploymentStatus: String, Codable, Sendable, CaseIterable {
    case employed
    case fired
    case seeking
}

public struct CareerJob: Codable, Sendable, Equatable {
    public let organisationID: UUID
    public let tier: CareerJobTier
    public let startedAt: CalendarState

    public init(organisationID: UUID, tier: CareerJobTier, startedAt: CalendarState) {
        self.organisationID = organisationID
        self.tier = tier
        self.startedAt = startedAt
    }
}

public struct CareerJobHistoryEntry: Codable, Sendable, Equatable {
    public let job: CareerJob
    public let endedAt: CalendarState
    public let reason: CareerExitReason

    public init(job: CareerJob, endedAt: CalendarState, reason: CareerExitReason) {
        precondition(!CareerArcState.occurs(endedAt, before: job.startedAt))
        self.job = job
        self.endedAt = endedAt
        self.reason = reason
    }
}

public enum CareerExitReason: String, Codable, Sendable, CaseIterable {
    case fired
    case promoted
    case resigned
}

public struct CareerSeasonExpectation: Codable, Sendable, Equatable {
    public let season: Int
    public let organisationID: UUID
    public let tier: CareerJobTier
    public let target: Int
    public let signedAt: CalendarState

    public init(
        season: Int,
        organisationID: UUID,
        tier: CareerJobTier,
        target: Int,
        signedAt: CalendarState
    ) {
        precondition(
            season >= 0
                && season == signedAt.season
                && (0...100).contains(target),
            "A season expectation must be signed for its own season on the performance scale."
        )
        self.season = season
        self.organisationID = organisationID
        self.tier = tier
        self.target = target
        self.signedAt = signedAt
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let season = try container.decode(Int.self, forKey: .season)
        let target = try container.decode(Int.self, forKey: .target)
        let signedAt = try container.decode(CalendarState.self, forKey: .signedAt)
        guard season >= 0, season == signedAt.season, (0...100).contains(target) else {
            throw DecodingError.dataCorruptedError(
                forKey: .target,
                in: container,
                debugDescription: "A season expectation is outside its signed season or scale."
            )
        }
        self.season = season
        organisationID = try container.decode(UUID.self, forKey: .organisationID)
        tier = try container.decode(CareerJobTier.self, forKey: .tier)
        self.target = target
        self.signedAt = signedAt
    }

    static func target(for prestige: Rating) -> Int {
        min(95, max(40, prestige.value + 10))
    }
}

public enum CareerConferenceFinish: String, Codable, Sendable, CaseIterable {
    case didNotQualify
    case finalist
    case champion
}

public enum CareerPostseasonFinish: String, Codable, Sendable, CaseIterable {
    case didNotQualify
    case quarterfinalist
    case semifinalist
    case finalist
    case champion
}

public enum CareerSeasonMilestone: String, Codable, Sendable, CaseIterable {
    case winningSeason
    case doubleDigitWins
    case conferenceFinalist
    case conferenceChampion
    case postseasonQualified
    case championshipFinalist
    case champion
}

public enum CareerNextPhase: String, Codable, Sendable, CaseIterable {
    case collegeOffseason
    case professionalOffseason
}

public enum CareerMilestoneKind: String, Codable, Sendable, CaseIterable {
    case seasonReview
}

public struct CareerMilestoneDeadline: Codable, Sendable, Equatable {
    public let kind: CareerMilestoneKind
    public let at: CalendarState

    public init(kind: CareerMilestoneKind, at: CalendarState) {
        self.kind = kind
        self.at = at
    }
}

public struct CareerChampionshipResult: Codable, Sendable, Equatable {
    public static let maximumPlayerEvidence = 3

    public let fixtureID: UUID
    public let season: Int
    public let tier: Tier
    public let stage: CompetitionStage
    public let homeID: UUID
    public let awayID: UUID
    public let homeScore: Int
    public let awayScore: Int
    public let playerEvidence: [PlayerGameStatistics]
    public let nextMilestone: CareerMilestoneDeadline

    public init(
        fixtureID: UUID,
        season: Int,
        tier: Tier,
        stage: CompetitionStage,
        homeID: UUID,
        awayID: UUID,
        homeScore: Int,
        awayScore: Int,
        playerEvidence: [PlayerGameStatistics],
        nextMilestone: CareerMilestoneDeadline
    ) {
        precondition(Self.isValid(
            season: season,
            stage: stage,
            homeID: homeID,
            awayID: awayID,
            homeScore: homeScore,
            awayScore: awayScore,
            playerEvidence: playerEvidence,
            nextMilestone: nextMilestone
        ), "A championship result must describe one decisive tier-title fixture.")
        self.fixtureID = fixtureID
        self.season = season
        self.tier = tier
        self.stage = stage
        self.homeID = homeID
        self.awayID = awayID
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.playerEvidence = playerEvidence
        self.nextMilestone = nextMilestone
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let season = try container.decode(Int.self, forKey: .season)
        let stage = try container.decode(CompetitionStage.self, forKey: .stage)
        let homeID = try container.decode(UUID.self, forKey: .homeID)
        let awayID = try container.decode(UUID.self, forKey: .awayID)
        let homeScore = try container.decode(Int.self, forKey: .homeScore)
        let awayScore = try container.decode(Int.self, forKey: .awayScore)
        let playerEvidence = try container.decode(
            [PlayerGameStatistics].self,
            forKey: .playerEvidence
        )
        let nextMilestone = try container.decode(
            CareerMilestoneDeadline.self,
            forKey: .nextMilestone
        )
        guard Self.isValid(
            season: season,
            stage: stage,
            homeID: homeID,
            awayID: awayID,
            homeScore: homeScore,
            awayScore: awayScore,
            playerEvidence: playerEvidence,
            nextMilestone: nextMilestone
        ) else {
            throw DecodingError.dataCorruptedError(
                forKey: .stage,
                in: container,
                debugDescription: "A championship result is not a bounded decisive title fixture."
            )
        }
        fixtureID = try container.decode(UUID.self, forKey: .fixtureID)
        self.season = season
        tier = try container.decode(Tier.self, forKey: .tier)
        self.stage = stage
        self.homeID = homeID
        self.awayID = awayID
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.playerEvidence = playerEvidence
        self.nextMilestone = nextMilestone
    }

    private static func isValid(
        season: Int,
        stage: CompetitionStage,
        homeID: UUID,
        awayID: UUID,
        homeScore: Int,
        awayScore: Int,
        playerEvidence: [PlayerGameStatistics],
        nextMilestone: CareerMilestoneDeadline
    ) -> Bool {
        let maximumScore = max(
            CompetitionRules.maximumFinalTeamScore,
            MatchupRules.maximumDrivesPerGame
                * (MatchupRules.touchdownPoints + MatchupRules.extraPointPoints)
        )
        return season >= 0
            && stage == .championship
            && homeID != awayID
            && (0...maximumScore).contains(homeScore)
            && (0...maximumScore).contains(awayScore)
            && homeScore != awayScore
            && playerEvidence.count <= maximumPlayerEvidence
            && Set(playerEvidence.map(\.playerID)).count == playerEvidence.count
            && nextMilestone.kind == .seasonReview
            && nextMilestone.at.season == season
    }
}

public struct CareerOpportunity: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let organisationID: UUID
    public let tier: CareerJobTier
    public let offeredAt: CalendarState
    public let expiresAt: CalendarState
    public let prestige: Rating
    public let rationale: CareerOpportunityRationale

    public init(
        id: UUID,
        organisationID: UUID,
        tier: CareerJobTier,
        offeredAt: CalendarState,
        expiresAt: CalendarState,
        prestige: Rating,
        rationale: CareerOpportunityRationale
    ) {
        precondition(!CareerArcState.occurs(expiresAt, before: offeredAt))
        self.id = id
        self.organisationID = organisationID
        self.tier = tier
        self.offeredAt = offeredAt
        self.expiresAt = expiresAt
        self.prestige = prestige
        self.rationale = rationale
    }
}

public enum CareerOpportunityRationale: String, Codable, Sendable, CaseIterable {
    case sustainedCollegeSuccess
    case rivalryWin
    case staffRecommendation
}

public enum CareerArcAction: Codable, Sendable, Equatable {
    case acceptOpportunity(opportunityID: UUID)
    case resign
}

public struct CareerArcState: Codable, Sendable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case currentJob
        case jobHistory
        case stakeholderSupport
        case stakeholderLastMovement
        case opportunities
        case status
        case seasonExpectation
        case currentChampionshipResult
    }

    public static let maximumJobHistory = 64
    public static let maximumOpportunities = 32
    public static let supportRange: ClosedRange<Int> = 0...100
    /// What every stakeholder thinks of a coach who has just walked in: neutral, and the same at
    /// every club. `02` section 7 -- what a new employer knows of a reputation is a separate
    /// question, and until it is answered this is the answer.
    public static let openingSupport = 60

    public private(set) var currentJob: CareerJob?
    public private(set) var jobHistory: [CareerJobHistoryEntry]
    public private(set) var stakeholderSupport: [CareerStakeholder: Int]
    /// The signed delta `applySupport` last applied per stakeholder -- computed by
    /// `evaluateWeek`/`evaluateSeasonEnd` and previously discarded the moment it was folded into
    /// `stakeholderSupport`. Kept so a surface can say *why* support moved, not only where it
    /// stands. Absent for a stakeholder that has never been evaluated (a fresh arc, or a save from
    /// before this field existed).
    public private(set) var stakeholderLastMovement: [CareerStakeholder: Int]
    public private(set) var opportunities: [CareerOpportunity]
    public private(set) var status: CareerEmploymentStatus
    public private(set) var seasonExpectation: CareerSeasonExpectation?
    public private(set) var currentChampionshipResult: CareerChampionshipResult?

    public init(
        currentJob: CareerJob? = nil,
        jobHistory: [CareerJobHistoryEntry] = [],
        stakeholderSupport: [CareerStakeholder: Int] = Dictionary(
            uniqueKeysWithValues: CareerStakeholder.allCases.map { ($0, CareerArcState.openingSupport) }
        ),
        stakeholderLastMovement: [CareerStakeholder: Int] = [:],
        opportunities: [CareerOpportunity] = [],
        status: CareerEmploymentStatus = .seeking,
        seasonExpectation: CareerSeasonExpectation? = nil,
        currentChampionshipResult: CareerChampionshipResult? = nil
    ) {
        precondition(Self.isValid(
            currentJob: currentJob,
            jobHistory: jobHistory,
            stakeholderSupport: stakeholderSupport,
            opportunities: opportunities,
            status: status,
            seasonExpectation: seasonExpectation,
            currentChampionshipResult: currentChampionshipResult
        ), "Career arc state is invalid.")
        self.currentJob = currentJob
        self.jobHistory = jobHistory
        self.stakeholderSupport = stakeholderSupport
        self.stakeholderLastMovement = stakeholderLastMovement
        self.opportunities = Self.sorted(opportunities)
        self.status = status
        self.seasonExpectation = seasonExpectation
        self.currentChampionshipResult = currentChampionshipResult
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let currentJob = try container.decodeIfPresent(CareerJob.self, forKey: .currentJob)
        let history = try container.decode([CareerJobHistoryEntry].self, forKey: .jobHistory)
        let support = try container.decode(
            [CareerStakeholder: Int].self,
            forKey: .stakeholderSupport
        )
        // Absent on every save written before this field existed -- decodes to empty rather than
        // failing, matching this initialiser's other tolerance for legacy saves.
        let lastMovement = try container.decodeIfPresent(
            [CareerStakeholder: Int].self,
            forKey: .stakeholderLastMovement
        ) ?? [:]
        let opportunities = try container.decode(
            [CareerOpportunity].self,
            forKey: .opportunities
        )
        let status = try container.decode(CareerEmploymentStatus.self, forKey: .status)
        let seasonExpectation = try container.decodeIfPresent(
            CareerSeasonExpectation.self,
            forKey: .seasonExpectation
        )
        let currentChampionshipResult = try container.decodeIfPresent(
            CareerChampionshipResult.self,
            forKey: .currentChampionshipResult
        )
        guard Self.isValid(
            currentJob: currentJob,
            jobHistory: history,
            stakeholderSupport: support,
            opportunities: opportunities,
            status: status,
            seasonExpectation: seasonExpectation,
            currentChampionshipResult: currentChampionshipResult
        ) else {
            throw DecodingError.dataCorruptedError(
                forKey: .status,
                in: container,
                debugDescription: "Career arc state is malformed or exceeds its history bounds."
            )
        }
        self.currentJob = currentJob
        self.jobHistory = history
        self.stakeholderSupport = support
        self.stakeholderLastMovement = lastMovement
        self.opportunities = Self.sorted(opportunities)
        self.status = status
        self.seasonExpectation = seasonExpectation
        self.currentChampionshipResult = currentChampionshipResult
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(currentJob, forKey: .currentJob)
        try container.encode(jobHistory, forKey: .jobHistory)
        try container.encode(stakeholderSupport, forKey: .stakeholderSupport)
        try container.encode(stakeholderLastMovement, forKey: .stakeholderLastMovement)
        try container.encode(opportunities, forKey: .opportunities)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(seasonExpectation, forKey: .seasonExpectation)
        try container.encodeIfPresent(
            currentChampionshipResult,
            forKey: .currentChampionshipResult
        )
    }

    public var averageSupport: Int {
        guard !stakeholderSupport.isEmpty else { return 0 }
        return stakeholderSupport.values.reduce(0, +) / stakeholderSupport.count
    }

    @discardableResult
    public mutating func establishCollegeJob(
        organisationID: UUID,
        at calendar: CalendarState
    ) -> Bool {
        guard currentJob == nil else { return currentJob?.organisationID == organisationID }
        currentJob = CareerJob(organisationID: organisationID, tier: .college, startedAt: calendar)
        status = .employed
        return true
    }

    @discardableResult
    public mutating func signSeasonExpectation(
        for organisationID: UUID,
        tier: CareerJobTier,
        target: Int,
        at calendar: CalendarState
    ) -> Bool {
        guard let currentJob,
              currentJob.organisationID == organisationID,
              currentJob.tier == tier,
              (0...100).contains(target) else { return false }
        if let seasonExpectation,
           seasonExpectation.season == calendar.season,
           seasonExpectation.organisationID == organisationID,
           seasonExpectation.tier == tier {
            return true
        }
        seasonExpectation = CareerSeasonExpectation(
            season: calendar.season,
            organisationID: organisationID,
            tier: tier,
            target: target,
            signedAt: calendar
        )
        if currentChampionshipResult?.season != calendar.season {
            currentChampionshipResult = nil
        }
        return true
    }

    mutating func recordChampionshipResult(_ result: CareerChampionshipResult) {
        guard currentChampionshipResult == nil
                || currentChampionshipResult?.fixtureID == result.fixtureID else { return }
        currentChampionshipResult = result
    }

    mutating func beginSeason(_ season: Int) {
        if currentChampionshipResult.map({ $0.season < season }) == true {
            currentChampionshipResult = nil
        }
        if seasonExpectation.map({ $0.season < season }) == true {
            seasonExpectation = nil
        }
    }

    @discardableResult
    public mutating func applySupport(
        deltas: [CareerStakeholder: Int]
    ) -> Bool {
        guard Set(deltas.keys).isSubset(of: Set(CareerStakeholder.allCases)),
              deltas.values.allSatisfy({ (-100...100).contains($0) }) else { return false }
        for stakeholder in CareerStakeholder.allCases {
            let delta = deltas[stakeholder, default: 0]
            stakeholderSupport[stakeholder] = min(
                Self.supportRange.upperBound,
                max(
                    Self.supportRange.lowerBound,
                    stakeholderSupport[stakeholder, default: 60] + delta
                )
            )
            stakeholderLastMovement[stakeholder] = delta
        }
        return true
    }

    @discardableResult
    public mutating func addOpportunity(_ opportunity: CareerOpportunity) -> Bool {
        guard opportunities.count < Self.maximumOpportunities,
              !opportunities.contains(where: { $0.id == opportunity.id }),
              !opportunities.contains(where: {
                  $0.organisationID == opportunity.organisationID
                      && $0.offeredAt == opportunity.offeredAt
              }) else { return false }
        opportunities.append(opportunity)
        opportunities = Self.sorted(opportunities)
        return true
    }

    @discardableResult
    public mutating func markFired(at calendar: CalendarState) -> Bool {
        guard status == .employed, let currentJob else { return false }
        guard jobHistory.count < Self.maximumJobHistory else { return false }
        jobHistory.append(CareerJobHistoryEntry(job: currentJob, endedAt: calendar, reason: .fired))
        self.currentJob = nil
        seasonExpectation = nil
        status = .fired
        return true
    }

    @discardableResult
    public mutating func acceptOpportunity(
        id: UUID,
        at calendar: CalendarState
    ) -> Bool {
        guard let index = opportunities.firstIndex(where: { $0.id == id }) else { return false }
        let opportunity = opportunities[index]
        guard opportunity.tier == .professional,
              !Self.occurs(calendar, before: opportunity.offeredAt),
              !Self.occurs(opportunity.expiresAt, before: calendar),
              jobHistory.count < Self.maximumJobHistory else { return false }
        if let currentJob {
            jobHistory.append(CareerJobHistoryEntry(
                job: currentJob,
                endedAt: calendar,
                reason: .promoted
            ))
        }
        self.currentJob = CareerJob(
            organisationID: opportunity.organisationID,
            tier: .professional,
            startedAt: calendar
        )
        seasonExpectation = CareerSeasonExpectation(
            season: calendar.season,
            organisationID: opportunity.organisationID,
            tier: .professional,
            target: CareerSeasonExpectation.target(for: opportunity.prestige),
            signedAt: calendar
        )
        currentChampionshipResult = nil
        // `02` section 7: support is a relationship with one organisation and does not travel. The
        // four dispositions belong to the club, not to the coach -- none of them has met the
        // arriving coach, and none of them holds the last club's grievance. Carrying it made an
        // earned promotion close to unsurvivable: a coach who left under pressure arrived already
        // near the firing threshold, on the strength of a relationship with a club they had left.
        //
        // The last movement goes with it. It exists to say *why* support moved, and a reason that
        // belongs to a previous employer explains nothing about this one.
        stakeholderSupport = Dictionary(
            uniqueKeysWithValues: CareerStakeholder.allCases.map { ($0, Self.openingSupport) }
        )
        stakeholderLastMovement = [:]
        opportunities.remove(at: index)
        status = .employed
        return true
    }

    @discardableResult
    public mutating func resign(at calendar: CalendarState) -> Bool {
        guard status == .employed,
              let currentJob,
              jobHistory.count < Self.maximumJobHistory else { return false }
        jobHistory.append(CareerJobHistoryEntry(
            job: currentJob,
            endedAt: calendar,
            reason: .resigned
        ))
        self.currentJob = nil
        seasonExpectation = nil
        currentChampionshipResult = nil
        status = .seeking
        return true
    }

    private static func isValid(
        currentJob: CareerJob?,
        jobHistory: [CareerJobHistoryEntry],
        stakeholderSupport: [CareerStakeholder: Int],
        opportunities: [CareerOpportunity],
        status: CareerEmploymentStatus,
        seasonExpectation: CareerSeasonExpectation?,
        currentChampionshipResult: CareerChampionshipResult?
    ) -> Bool {
        let expectedStakeholders = Set(CareerStakeholder.allCases)
        let historyJobs = jobHistory.map { $0.job }
        let championshipMatches = currentChampionshipResult.map { result in
            (currentJob ?? jobHistory.last?.job).map { job in
                result.tier == (job.tier == .college ? .college : .pro)
                    && (result.homeID == job.organisationID
                        || result.awayID == job.organisationID)
                    && result.season >= job.startedAt.season
                    && (currentJob != nil
                        || jobHistory.last.map { result.season <= $0.endedAt.season } == true)
                    && (seasonExpectation.map { $0.season == result.season } ?? true)
            } ?? false
        } ?? true
        return jobHistory.count <= maximumJobHistory
            && opportunities.count <= maximumOpportunities
            && Set(opportunities.map(\.id)).count == opportunities.count
            && Set(historyJobs.map { "\($0.organisationID.uuidString)|\($0.startedAt.season)|\($0.startedAt.week)" }).count
                == historyJobs.count
            && Set(stakeholderSupport.keys) == expectedStakeholders
            && stakeholderSupport.values.allSatisfy(supportRange.contains)
            && (status == .employed ? currentJob != nil : currentJob == nil)
            && (seasonExpectation.map { expectation in
                currentJob.map {
                    $0.organisationID == expectation.organisationID
                        && $0.tier == expectation.tier
                        && expectation.season >= $0.startedAt.season
                } ?? false
            } ?? true)
            && championshipMatches
            && opportunities.allSatisfy {
                !occurs($0.expiresAt, before: $0.offeredAt)
            }
    }

    private static func sorted(_ opportunities: [CareerOpportunity]) -> [CareerOpportunity] {
        opportunities.sorted {
            if $0.offeredAt != $1.offeredAt {
                return occurs($0.offeredAt, before: $1.offeredAt)
            }
            return $0.id.uuidString < $1.id.uuidString
        }
    }

    fileprivate static func occurs(_ lhs: CalendarState, before rhs: CalendarState) -> Bool {
        lhs.season < rhs.season || (lhs.season == rhs.season && lhs.week < rhs.week)
    }
}

public enum CareerArcSystem {
    public static func prepareSeasonExpectation(
        in state: GameState,
        arc: inout CareerArcState
    ) {
        if arc.currentJob == nil,
           let control = state.career.college,
           state.programmes[control.programmeID] != nil {
            _ = arc.establishCollegeJob(
                organisationID: control.programmeID,
                at: control.startedAt
            )
        }
        guard let job = arc.currentJob else { return }
        let prestige: Rating?
        switch job.tier {
        case .college: prestige = state.programmes[job.organisationID]?.prestige
        case .professional: prestige = state.proTeams[job.organisationID]?.prestige
        }
        guard let prestige else { return }
        _ = arc.signSeasonExpectation(
            for: job.organisationID,
            tier: job.tier,
            target: CareerSeasonExpectation.target(for: prestige),
            at: state.calendar
        )
    }

    public static func evaluateWeek(
        after calendar: CalendarState,
        in state: GameState,
        arc: inout CareerArcState
    ) {
        guard calendar.week <= SharedRules.inSeasonWeeks, arc.status != .fired else { return }
        prepareSeasonExpectation(in: state, arc: &arc)
        guard arc.status == .employed,
              let job = arc.currentJob,
              let expectation = arc.seasonExpectation,
              expectation.season == calendar.season,
              expectation.organisationID == job.organisationID,
              let game = state.competition.currentSchedule.games.first(where: {
                  $0.season == calendar.season
                      && $0.week == calendar.week
                      && $0.result != nil
                      && $0.tier == tier(for: job.tier)
                      && ($0.homeID == job.organisationID || $0.awayID == job.organisationID)
              }),
              let result = game.result else { return }

        let organisationScore: Int
        let opponentScore: Int
        if game.homeID == job.organisationID {
            organisationScore = result.homeScore
            opponentScore = result.awayScore
        } else {
            organisationScore = result.awayScore
            opponentScore = result.homeScore
        }
        let margin = organisationScore - opponentScore
        // `02` section 7: the target is a season standing, so the weight of the movement is where
        // the club stands, measured the same way the season end measures it. It used to be
        // `50 + margin x 2` -- a single game held against a season target, which silently read
        // "finish in the top thirty per cent" as "win this game by ten points", and rose with
        // prestige, so the better the job the faster it burned.
        //
        // The result still colours the reaction below: winning, and keeping it close, are what the
        // boosters, the fanbase and the locker room answer to on their own.
        let performance = seasonPerformance(
            organisationID: job.organisationID,
            ranking: ranking(for: job, in: state)
        )
        let delta = min(4, max(-4, (performance - expectation.target) / 10))
        let won = organisationScore > opponentScore
        let closeGame = abs(margin) <= 7
        _ = arc.applySupport(deltas: Dictionary(uniqueKeysWithValues: CareerStakeholder.allCases.map {
            let bias: Int
            switch $0 {
            case .administration: bias = delta
            case .boosters: bias = delta + (won ? 1 : -1)
            case .fanbase: bias = delta + (won ? 2 : -2)
            case .lockerRoom: bias = delta + (closeGame ? 1 : 0)
            }
            return ($0, bias)
        }))
        if arc.averageSupport < 12 {
            _ = arc.markFired(at: calendar)
        }
    }

    public static func evaluateSeasonEnd(
        after calendar: CalendarState,
        in state: GameState,
        arc: inout CareerArcState
    ) {
        guard calendar.week == SharedRules.inSeasonWeeks, arc.status != .fired else { return }
        prepareSeasonExpectation(in: state, arc: &arc)
        guard arc.status == .employed,
              let job = arc.currentJob,
              let expectation = arc.seasonExpectation,
              expectation.season == calendar.season,
              expectation.organisationID == job.organisationID else { return }

        let ranking = ranking(for: job, in: state)
        let performance = seasonPerformance(
            organisationID: job.organisationID,
            ranking: ranking
        )
        let delta = min(12, max(-12, (performance - expectation.target) / 5))
        _ = arc.applySupport(deltas: Dictionary(uniqueKeysWithValues: CareerStakeholder.allCases.map {
            let bias: Int
            switch $0 {
            case .administration: bias = delta
            case .boosters: bias = delta + (performance >= 70 ? 2 : 0)
            case .fanbase: bias = delta + (performance >= expectation.target ? 2 : -1)
            case .lockerRoom: bias = delta / 2
            }
            return ($0, bias)
        }))

        if arc.averageSupport < 20 {
            _ = arc.markFired(at: calendar)
            return
        }
        guard job.tier == .college,
              performance >= 75, arc.averageSupport >= 70,
              let team = state.proTeams.values
                .sorted(by: { $0.prestige == $1.prestige
                    ? $0.id.uuidString < $1.id.uuidString
                    : $0.prestige > $1.prestige
                })
                .first else { return }
        let opportunityID = SeededRandom.derive(
            from: state.league.seed,
            scope: .personnel,
            identifier: team.id
        ) ^ UInt64(calendar.season)
        var rng = SeededRandom(seed: opportunityID)
        _ = arc.addOpportunity(CareerOpportunity(
            id: rng.uuid(),
            organisationID: team.id,
            tier: .professional,
            offeredAt: calendar,
            expiresAt: CalendarState(season: calendar.season + 1, week: 2),
            prestige: team.prestige,
            rationale: .sustainedCollegeSuccess
        ))
    }

    public static func captureChampionshipResult(
        in state: GameState,
        arc: inout CareerArcState
    ) {
        prepareSeasonExpectation(in: state, arc: &arc)
        guard let job = arc.currentJob,
              let game = state.competition.currentSchedule.games.first(where: {
                  $0.season == state.calendar.season
                      && $0.tier == tier(for: job.tier)
                      && $0.stage == .championship
                      && $0.result != nil
                      && ($0.homeID == job.organisationID || $0.awayID == job.organisationID)
              }),
              let result = game.result else { return }
        let evidence = result.playerStatistics.sorted(by: playerEvidenceOrder)
            .prefix(CareerChampionshipResult.maximumPlayerEvidence)
        arc.recordChampionshipResult(CareerChampionshipResult(
            fixtureID: game.id,
            season: game.season,
            tier: game.tier,
            stage: game.stage,
            homeID: game.homeID,
            awayID: game.awayID,
            homeScore: result.homeScore,
            awayScore: result.awayScore,
            playerEvidence: Array(evidence),
            nextMilestone: CareerMilestoneDeadline(
                kind: .seasonReview,
                at: CalendarState(season: game.season, week: SharedRules.inSeasonWeeks)
            )
        ))
    }

    fileprivate static func tier(for jobTier: CareerJobTier) -> Tier {
        jobTier == .college ? .college : .pro
    }

    fileprivate static func seasonPerformance(
        organisationID: UUID,
        ranking: [UUID]
    ) -> Int {
        let rank = ranking.firstIndex(of: organisationID) ?? max(0, ranking.count - 1)
        return ranking.count <= 1 ? 100 : 100 - rank * 100 / max(1, ranking.count - 1)
    }

    fileprivate static func ranking(for job: CareerJob, in state: GameState) -> [UUID] {
        state.competition.rankings[tier(for: job.tier)]
            ?? (job.tier == .college ? state.programmes.ids : state.proTeams.ids)
    }

    private static func playerEvidenceOrder(
        _ lhs: PlayerGameStatistics,
        _ rhs: PlayerGameStatistics
    ) -> Bool {
        if lhs.touchdowns != rhs.touchdowns { return lhs.touchdowns > rhs.touchdowns }
        if lhs.passingYards != rhs.passingYards { return lhs.passingYards > rhs.passingYards }
        if lhs.rushingYards != rhs.rushingYards { return lhs.rushingYards > rhs.rushingYards }
        if lhs.receivingYards != rhs.receivingYards {
            return lhs.receivingYards > rhs.receivingYards
        }
        return lhs.playerID.uuidString < rhs.playerID.uuidString
    }
}

public enum CareerSeasonOutcomeSystem {
    public static func snapshot(
        after calendar: CalendarState,
        in state: GameState
    ) -> CoachSeasonRecord? {
        guard calendar == state.calendar,
              calendar.week == SharedRules.inSeasonWeeks,
              let job = state.careerArc.currentJob,
              let row = state.competition.standings[CareerArcSystem.tier(for: job.tier)]?
                .first(where: { $0.id == job.organisationID }) else { return nil }
        let ranking = CareerArcSystem.ranking(for: job, in: state)
        let performance = CareerArcSystem.seasonPerformance(
            organisationID: job.organisationID,
            ranking: ranking
        )
        let expectation = state.careerArc.seasonExpectation.flatMap {
            $0.season == calendar.season
                && $0.organisationID == job.organisationID
                && $0.tier == job.tier ? $0 : nil
        }
        let conferenceFinish = conferenceFinish(for: job, in: state)
        let postseasonFinish = postseasonFinish(for: job, in: state)
        let milestones = milestones(
            wins: row.wins,
            losses: row.losses,
            conferenceFinish: conferenceFinish,
            postseasonFinish: postseasonFinish
        )
        let championship = state.careerArc.currentChampionshipResult.flatMap {
            $0.season == calendar.season
                && $0.tier == CareerArcSystem.tier(for: job.tier)
                && ($0.homeID == job.organisationID || $0.awayID == job.organisationID)
                ? $0 : nil
        }
        return CoachSeasonRecord(
            season: calendar.season,
            organisationID: job.organisationID,
            wins: row.wins,
            losses: row.losses,
            ties: row.ties,
            tier: job.tier,
            finalRank: ranking.firstIndex(of: job.organisationID).map { $0 + 1 },
            conferenceFinish: conferenceFinish,
            postseasonFinish: postseasonFinish,
            recruitingClassRank: job.tier == .college
                ? recruitingClassRank(for: job.organisationID, in: state)
                : nil,
            contractYear: max(1, calendar.season - job.startedAt.season + 1),
            finalPerformance: performance,
            expectationTarget: expectation?.target,
            expectationDelta: expectation.map { performance - $0.target },
            milestones: milestones,
            nextPhase: job.tier == .college ? .collegeOffseason : .professionalOffseason,
            decisionDeadline: nextDecisionDeadline(for: job.organisationID, in: state),
            championshipResult: championship
        )
    }

    private static func conferenceFinish(
        for job: CareerJob,
        in state: GameState
    ) -> CareerConferenceFinish {
        let stage: CompetitionStage = job.tier == .college ? .conferenceChampionship : .semifinal
        guard let game = completedGame(stage: stage, for: job, in: state),
              let result = game.result else { return .didNotQualify }
        return won(job.organisationID, game: game, result: result) ? .champion : .finalist
    }

    private static func postseasonFinish(
        for job: CareerJob,
        in state: GameState
    ) -> CareerPostseasonFinish {
        if let game = completedGame(stage: .championship, for: job, in: state),
           let result = game.result {
            return won(job.organisationID, game: game, result: result) ? .champion : .finalist
        }
        if completedGame(stage: .semifinal, for: job, in: state) != nil { return .semifinalist }
        if completedGame(stage: .quarterfinal, for: job, in: state) != nil {
            return .quarterfinalist
        }
        return .didNotQualify
    }

    private static func completedGame(
        stage: CompetitionStage,
        for job: CareerJob,
        in state: GameState
    ) -> ScheduledGame? {
        state.competition.currentSchedule.games.first {
            $0.season == state.calendar.season
                && $0.tier == CareerArcSystem.tier(for: job.tier)
                && $0.stage == stage
                && $0.result != nil
                && ($0.homeID == job.organisationID || $0.awayID == job.organisationID)
        }
    }

    private static func won(
        _ organisationID: UUID,
        game: ScheduledGame,
        result: GameSummary
    ) -> Bool {
        game.homeID == organisationID
            ? result.homeScore > result.awayScore
            : result.awayScore > result.homeScore
    }

    private static func recruitingClassRank(
        for programmeID: UUID,
        in state: GameState
    ) -> Int? {
        let classes = state.programmes.ids.map { candidateID in
            let prospects = state.college.prospectRecruitment.values.filter {
                ($0.phase == .committed || $0.phase == .signed)
                    && $0.programmeID == candidateID
            }
            return (
                id: candidateID,
                count: prospects.count,
                score: prospects.reduce(0) {
                    $0 + (state.prospects[$1.prospectID]?.overall.value ?? 0)
                }
            )
        }
        guard classes.contains(where: { $0.count > 0 }) else { return nil }
        let ordered = classes.sorted {
            if $0.score != $1.score { return $0.score > $1.score }
            if $0.count != $1.count { return $0.count > $1.count }
            return $0.id.uuidString < $1.id.uuidString
        }
        return ordered.firstIndex(where: { $0.id == programmeID }).map { $0 + 1 }
    }

    private static func milestones(
        wins: Int,
        losses: Int,
        conferenceFinish: CareerConferenceFinish,
        postseasonFinish: CareerPostseasonFinish
    ) -> [CareerSeasonMilestone] {
        var values: Set<CareerSeasonMilestone> = []
        if wins > losses { values.insert(.winningSeason) }
        if wins >= 10 { values.insert(.doubleDigitWins) }
        if conferenceFinish != .didNotQualify { values.insert(.conferenceFinalist) }
        if conferenceFinish == .champion { values.insert(.conferenceChampion) }
        if postseasonFinish != .didNotQualify { values.insert(.postseasonQualified) }
        if postseasonFinish == .finalist { values.insert(.championshipFinalist) }
        if postseasonFinish == .champion { values.insert(.champion) }
        return CareerSeasonMilestone.allCases.filter(values.contains)
    }

    private static func nextDecisionDeadline(
        for organisationID: UUID,
        in state: GameState
    ) -> CalendarState? {
        state.pending.mandatoryDecisions
            .filter { $0.programmeID == organisationID }
            .map(\.deadline)
            .min { CareerArcState.occurs($0, before: $1) }
    }
}

public struct CareerOutcomeProjection: Sendable, Equatable {
    public let seasonExpectation: CareerSeasonExpectation?
    public let seasonReview: CoachSeasonRecord?
    public let championshipResult: CareerChampionshipResult?

    public static func make(from state: GameState) -> CareerOutcomeProjection {
        let review = state.career.coachID.flatMap {
            state.people.staffCareers[$0]?.seasonRecords.last
        }
        return CareerOutcomeProjection(
            seasonExpectation: state.careerArc.seasonExpectation,
            seasonReview: review,
            championshipResult: state.careerArc.currentChampionshipResult
                ?? review?.championshipResult
        )
    }
}
