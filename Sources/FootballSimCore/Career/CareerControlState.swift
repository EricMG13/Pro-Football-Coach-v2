import Foundation

public enum CollegeCareerResponsibility: String, Codable, Sendable, CaseIterable, Hashable {
    case recruiting
    case portalAndRetention
    case nilAllocation
    case redshirts
    case practicePlan
    case depthChart
}

public enum CareerResponsibilityOwner: Codable, Sendable, Equatable {
    case user
    case delegated(staffID: UUID)
}

public enum ProCareerResponsibility: String, Codable, Sendable, CaseIterable, Hashable {
    case scouting
    case rosterManagement
    case contractNegotiations
    case gamePlan
    case practicePlan
    case depthChart
}

public struct CollegeCareerControl: Codable, Sendable, Equatable {
    private static let currentResponsibilitySchemaVersion = 2
    private static let currentResponsibilityCount = CollegeCareerResponsibility.allCases.count
    private static let legacyResponsibilities: Set<CollegeCareerResponsibility> = [
        .recruiting,
        .portalAndRetention,
        .nilAllocation,
        .redshirts,
    ]

    public let coachID: UUID
    public let programmeID: UUID
    public let startedAt: CalendarState
    public private(set) var responsibilityOwners: [
        CollegeCareerResponsibility: CareerResponsibilityOwner
    ]
    private let responsibilitySchemaVersion: Int

    public init(
        coachID: UUID,
        programmeID: UUID,
        startedAt: CalendarState,
        responsibilityOwners: [
            CollegeCareerResponsibility: CareerResponsibilityOwner
        ] = Dictionary(uniqueKeysWithValues: CollegeCareerResponsibility.allCases.map {
            ($0, .user)
        })
    ) {
        precondition(
            Set(responsibilityOwners.keys) == Set(CollegeCareerResponsibility.allCases),
            "A college career requires one owner for every management responsibility."
        )
        self.coachID = coachID
        self.programmeID = programmeID
        self.startedAt = startedAt
        self.responsibilityOwners = responsibilityOwners
        responsibilitySchemaVersion = Self.currentResponsibilitySchemaVersion
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var owners = try container.decode(
            [CollegeCareerResponsibility: CareerResponsibilityOwner].self,
            forKey: .responsibilityOwners
        )
        let schemaVersion = try container.decodeIfPresent(
            Int.self,
            forKey: .responsibilitySchemaVersion
        )
        if schemaVersion == nil,
           owners.count == Self.legacyResponsibilities.count,
           owners.keys.allSatisfy(Self.legacyResponsibilities.contains) {
            owners[.practicePlan] = .user
            owners[.depthChart] = .user
        }
        guard schemaVersion == nil || schemaVersion == Self.currentResponsibilitySchemaVersion,
              owners.count == Self.currentResponsibilityCount else {
            throw DecodingError.dataCorruptedError(
                forKey: .responsibilityOwners,
                in: container,
                debugDescription: "A college career has missing or unknown responsibilities."
            )
        }
        coachID = try container.decode(UUID.self, forKey: .coachID)
        programmeID = try container.decode(UUID.self, forKey: .programmeID)
        startedAt = try container.decode(CalendarState.self, forKey: .startedAt)
        responsibilityOwners = owners
        responsibilitySchemaVersion = Self.currentResponsibilitySchemaVersion
    }

    mutating func setOwner(
        _ owner: CareerResponsibilityOwner,
        for responsibility: CollegeCareerResponsibility
    ) {
        responsibilityOwners[responsibility] = owner
    }
}

public struct ProCareerControl: Codable, Sendable, Equatable {
    public let coachID: UUID
    public let teamID: UUID
    public let startedAt: CalendarState
    public private(set) var responsibilityOwners: [
        ProCareerResponsibility: CareerResponsibilityOwner
    ]

    public init(
        coachID: UUID,
        teamID: UUID,
        startedAt: CalendarState,
        responsibilityOwners: [
            ProCareerResponsibility: CareerResponsibilityOwner
        ] = Dictionary(uniqueKeysWithValues: ProCareerResponsibility.allCases.map {
            ($0, .user)
        })
    ) {
        precondition(
            Set(responsibilityOwners.keys) == Set(ProCareerResponsibility.allCases),
            "A professional career requires one owner for every management responsibility."
        )
        self.coachID = coachID
        self.teamID = teamID
        self.startedAt = startedAt
        self.responsibilityOwners = responsibilityOwners
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let owners = try container.decode(
            [ProCareerResponsibility: CareerResponsibilityOwner].self,
            forKey: .responsibilityOwners
        )
        guard Set(owners.keys) == Set(ProCareerResponsibility.allCases) else {
            throw DecodingError.dataCorruptedError(
                forKey: .responsibilityOwners,
                in: container,
                debugDescription: "A professional career has missing responsibilities."
            )
        }
        coachID = try container.decode(UUID.self, forKey: .coachID)
        teamID = try container.decode(UUID.self, forKey: .teamID)
        startedAt = try container.decode(CalendarState.self, forKey: .startedAt)
        responsibilityOwners = owners
    }

    mutating func setOwner(
        _ owner: CareerResponsibilityOwner,
        for responsibility: ProCareerResponsibility
    ) {
        responsibilityOwners[responsibility] = owner
    }
}

public enum CareerDelegatedAction: String, Codable, Sendable, Equatable {
    case responsibilityAssigned
    case decisionApplied
    case recruiting
    case portalAndRetention
    case nilAllocation
    case gamePlan
    case practicePlan
    case depthChart
    case scouting
    case rosterManagement
    case contractNegotiation
}

public enum CareerDelegatedEffect: Codable, Sendable, Equatable {
    case ownershipChanged
    case recommendationApplied(optionID: UUID)
    case actionsCommitted(count: Int)

    fileprivate var isValid: Bool {
        switch self {
        case .ownershipChanged, .recommendationApplied:
            return true
        case let .actionsCommitted(count):
            return (1...10_000).contains(count)
        }
    }
}

public enum CareerDelegationTrigger: String, Codable, Sendable, Equatable {
    case userRequest
    case scheduledWeek
    case mandatoryDecision
    case cruise
}

public struct CareerDelegatedActivity: Codable, Sendable, Equatable, Identifiable {
    private enum CodingKeys: String, CodingKey {
        case id
        case calendar
        case area
        case actorID
        case action
        case effect
        case trigger
    }

    public let id: String
    public let calendar: CalendarState
    public let area: CareerResponsibilityArea
    public let actorID: UUID
    public let action: CareerDelegatedAction
    public let effect: CareerDelegatedEffect
    public let trigger: CareerDelegationTrigger

    public init(
        id: String,
        calendar: CalendarState,
        area: CareerResponsibilityArea,
        actorID: UUID,
        action: CareerDelegatedAction,
        effect: CareerDelegatedEffect,
        trigger: CareerDelegationTrigger
    ) {
        precondition(
            !id.isEmpty && id.count <= 256 && effect.isValid,
            "A delegated activity is invalid."
        )
        self.id = id
        self.calendar = calendar
        self.area = area
        self.actorID = actorID
        self.action = action
        self.effect = effect
        self.trigger = trigger
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let effect = try container.decode(CareerDelegatedEffect.self, forKey: .effect)
        guard effect.isValid else {
            throw DecodingError.dataCorruptedError(
                forKey: .effect,
                in: container,
                debugDescription: "A delegated activity effect is invalid."
            )
        }
        let id = try container.decode(String.self, forKey: .id)
        guard !id.isEmpty, id.count <= 256 else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "A delegated activity identity is invalid."
            )
        }
        self.id = id
        calendar = try container.decode(CalendarState.self, forKey: .calendar)
        area = try container.decode(CareerResponsibilityArea.self, forKey: .area)
        actorID = try container.decode(UUID.self, forKey: .actorID)
        action = try container.decode(CareerDelegatedAction.self, forKey: .action)
        self.effect = effect
        trigger = try container.decode(CareerDelegationTrigger.self, forKey: .trigger)
    }
}

public enum CareerCruiseStatus: String, Codable, Sendable, Equatable {
    case active
    case stopped
    case completed
}

public enum CareerCruiseStopReason: String, Codable, Sendable, Equatable {
    case mandatoryDecision
    case capIllegal
    case injuryAvailabilityChanged
    case matchRequiresControl
    case userRequested
    case requestedEnd
    case careerComplete
}

public struct CareerCruiseState: Codable, Sendable, Equatable {
    public static let maximumWeeks = 52

    public let startedAt: CalendarState
    public private(set) var current: CalendarState
    public let requestedEnd: CalendarState
    public private(set) var status: CareerCruiseStatus
    public private(set) var stopReason: CareerCruiseStopReason?

    public init(startedAt: CalendarState, requestedEnd: CalendarState) {
        precondition(Self.isValidRangeForControl(from: startedAt, through: requestedEnd))
        self.startedAt = startedAt
        current = startedAt
        self.requestedEnd = requestedEnd
        status = .active
        stopReason = nil
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let startedAt = try container.decode(CalendarState.self, forKey: .startedAt)
        let current = try container.decode(CalendarState.self, forKey: .current)
        let requestedEnd = try container.decode(CalendarState.self, forKey: .requestedEnd)
        let status = try container.decode(CareerCruiseStatus.self, forKey: .status)
        let reason = try container.decodeIfPresent(
            CareerCruiseStopReason.self,
            forKey: .stopReason
        )
        guard Self.isValidRangeForControl(from: startedAt, through: requestedEnd),
              Self.isOnOrAfter(current, startedAt),
              Self.isOnOrAfter(requestedEnd, current),
              (status == .active ? reason == nil : reason != nil),
              (status != .completed || reason == .requestedEnd || reason == .careerComplete)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .status,
                in: container,
                debugDescription: "A career cruise checkpoint is invalid."
            )
        }
        self.startedAt = startedAt
        self.current = current
        self.requestedEnd = requestedEnd
        self.status = status
        stopReason = reason
    }

    mutating func resume() -> Bool {
        guard status == .stopped, current != requestedEnd else { return false }
        status = .active
        stopReason = nil
        return true
    }

    mutating func advance(to calendar: CalendarState) -> Bool {
        guard status == .active,
              Self.isOnOrAfter(calendar, current),
              Self.isOnOrAfter(requestedEnd, calendar) else { return false }
        current = calendar
        if current == requestedEnd {
            status = .completed
            stopReason = .requestedEnd
        }
        return true
    }

    mutating func stop(_ reason: CareerCruiseStopReason) {
        guard status == .active else { return }
        status = reason == .requestedEnd || reason == .careerComplete ? .completed : .stopped
        stopReason = reason
    }

    static func isValidRangeForControl(
        from start: CalendarState,
        through end: CalendarState
    ) -> Bool {
        guard isOnOrAfter(end, start) else { return false }
        let seasonDelta = end.season - start.season
        guard seasonDelta <= maximumWeeks / SharedRules.inSeasonWeeks + 1 else { return false }
        let weeks = seasonDelta * SharedRules.inSeasonWeeks + end.week - start.week
        return (1...maximumWeeks).contains(weeks)
    }

    private static func isOnOrAfter(_ lhs: CalendarState, _ rhs: CalendarState) -> Bool {
        lhs.season > rhs.season || (lhs.season == rhs.season && lhs.week >= rhs.week)
    }
}

public struct CareerControlState: Codable, Sendable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case college
        case pro
        case coachID
        case mandatoryDecisionResolutions
        case delegatedActivities
        case cruise
    }

    public static let maximumMandatoryDecisionResolutions = 10_000
    public static let maximumDelegatedActivities = 512
    public private(set) var college: CollegeCareerControl?
    public private(set) var pro: ProCareerControl?
    /// The coach identity survives tier transitions and separation from a programme.
    /// Optional decoding keeps schema-11 saves readable; new careers always set it.
    public private(set) var coachID: UUID?
    public private(set) var mandatoryDecisionResolutions: [MandatoryDecisionResolution]
    public private(set) var delegatedActivities: [CareerDelegatedActivity]
    public private(set) var cruise: CareerCruiseState?

    public init(
        college: CollegeCareerControl? = nil,
        pro: ProCareerControl? = nil,
        coachID: UUID? = nil,
        mandatoryDecisionResolutions: [MandatoryDecisionResolution] = [],
        delegatedActivities: [CareerDelegatedActivity] = [],
        cruise: CareerCruiseState? = nil
    ) {
        precondition(college == nil || pro == nil, "A career cannot control both tiers at once.")
        precondition(
            mandatoryDecisionResolutions.count <= Self.maximumMandatoryDecisionResolutions
                && Set(mandatoryDecisionResolutions.map(\.decisionID)).count
                    == mandatoryDecisionResolutions.count,
            "Career decision history is invalid."
        )
        precondition(
            Self.activitiesAreValid(delegatedActivities),
            "Delegated career activity is invalid."
        )
        self.college = college
        self.pro = pro
        self.coachID = coachID ?? college?.coachID ?? pro?.coachID
        self.mandatoryDecisionResolutions = mandatoryDecisionResolutions
        self.delegatedActivities = delegatedActivities
        self.cruise = cruise
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decoded = try container.decode(
            [MandatoryDecisionResolution].self,
            forKey: .mandatoryDecisionResolutions
        )
        guard decoded.count <= Self.maximumMandatoryDecisionResolutions,
              Set(decoded.map(\.decisionID)).count == decoded.count else {
            throw DecodingError.dataCorruptedError(
                forKey: .mandatoryDecisionResolutions,
                in: container,
                debugDescription: "Career decision history is invalid."
            )
        }
        college = try container.decodeIfPresent(CollegeCareerControl.self, forKey: .college)
        pro = try container.decodeIfPresent(ProCareerControl.self, forKey: .pro)
        guard college == nil || pro == nil else {
            throw DecodingError.dataCorruptedError(
                forKey: .pro,
                in: container,
                debugDescription: "A career cannot control both tiers at once."
            )
        }
        coachID = try container.decodeIfPresent(UUID.self, forKey: .coachID)
            ?? college?.coachID
            ?? pro?.coachID
        mandatoryDecisionResolutions = decoded
        let activities = try container.decodeIfPresent(
            [CareerDelegatedActivity].self,
            forKey: .delegatedActivities
        ) ?? []
        guard Self.activitiesAreValid(activities) else {
            throw DecodingError.dataCorruptedError(
                forKey: .delegatedActivities,
                in: container,
                debugDescription: "Delegated career activity is invalid."
            )
        }
        delegatedActivities = activities
        cruise = try container.decodeIfPresent(CareerCruiseState.self, forKey: .cruise)
    }

    mutating func setCollege(_ control: CollegeCareerControl) {
        college = control
        pro = nil
        coachID = control.coachID
    }

    mutating func setPro(_ control: ProCareerControl) {
        pro = control
        college = nil
        coachID = control.coachID
    }

    mutating func clearCollege() {
        college = nil
    }

    mutating func clearPro() {
        pro = nil
    }

    /// Evicts oldest-first at the bound rather than refusing, the way `recordDelegatedActivity`
    /// below does.
    ///
    /// Refusing was the wrong overflow policy for this collection specifically: every caller reads
    /// `false` as fatal -- `CareerSession.resolveDecision` throws on it, and
    /// `CareerMandatoryDecisionSystem.refresh` silently skips a delegation -- so a full list stops
    /// decisions resolving, and a week cannot advance while one is pending. That is a save that
    /// locks rather than one that forgets. Appends are chronological, and the only reader that
    /// looks a resolution up (`CollegePortalPolicyV1.makeMarketSnapshot`) wants the current
    /// window's, so dropping from the front costs nothing it can see.
    @discardableResult
    mutating func recordResolution(_ resolution: MandatoryDecisionResolution) -> Bool {
        guard !mandatoryDecisionResolutions.contains(where: {
            $0.decisionID == resolution.decisionID
        }) else { return false }
        mandatoryDecisionResolutions.append(resolution)
        if mandatoryDecisionResolutions.count > Self.maximumMandatoryDecisionResolutions {
            mandatoryDecisionResolutions.removeFirst(
                mandatoryDecisionResolutions.count - Self.maximumMandatoryDecisionResolutions
            )
        }
        return true
    }

    @discardableResult
    mutating func recordDelegatedActivity(_ activity: CareerDelegatedActivity) -> Bool {
        guard !delegatedActivities.contains(where: { $0.id == activity.id }),
              delegatedActivities.last.map({ !Self.occurs(activity.calendar, before: $0.calendar) })
                ?? true else { return false }
        delegatedActivities.append(activity)
        if delegatedActivities.count > Self.maximumDelegatedActivities {
            delegatedActivities.removeFirst(
                delegatedActivities.count - Self.maximumDelegatedActivities
            )
        }
        return true
    }

    mutating func startCruise(requestedEnd: CalendarState, at calendar: CalendarState) -> Bool {
        guard cruise?.status != .active,
              CareerCruiseState.isValidRangeForControl(from: calendar, through: requestedEnd)
        else { return false }
        cruise = CareerCruiseState(startedAt: calendar, requestedEnd: requestedEnd)
        return true
    }

    mutating func resumeCruise() -> Bool {
        cruise?.resume() ?? false
    }

    mutating func advanceCruise(to calendar: CalendarState) -> Bool {
        cruise?.advance(to: calendar) ?? false
    }

    mutating func stopCruise(_ reason: CareerCruiseStopReason) {
        cruise?.stop(reason)
    }

    private static func activitiesAreValid(_ activities: [CareerDelegatedActivity]) -> Bool {
        guard activities.count <= maximumDelegatedActivities,
              Set(activities.map(\.id)).count == activities.count else { return false }
        return zip(activities, activities.dropFirst()).allSatisfy {
            !occurs($1.calendar, before: $0.calendar)
        }
    }

    private static func occurs(_ lhs: CalendarState, before rhs: CalendarState) -> Bool {
        lhs.season < rhs.season || (lhs.season == rhs.season && lhs.week < rhs.week)
    }
}

public enum CareerControlError: Error, Equatable {
    case careerAlreadyStarted
    case missingProgramme
    case missingHeadCoach
}

public struct CareerControlTransition: Sendable, Equatable {
    public let state: GameState
    public let control: CollegeCareerControl

    public init(state: GameState, control: CollegeCareerControl) {
        self.state = state
        self.control = control
    }
}

public enum CareerControlSystem {
    public static let maximumResponsibilitiesPerDelegate = 2

    public static func startCollegeCareer(
        at programmeID: UUID,
        in state: GameState
    ) throws -> CareerControlTransition {
        guard state.career.college == nil,
              state.career.pro == nil,
              state.careerArc.currentJob == nil else {
            throw CareerControlError.careerAlreadyStarted
        }
        guard let programme = state.programmes[programmeID] else {
            throw CareerControlError.missingProgramme
        }
        let headCoachIDs = programme.staffIDs.filter {
            state.staff[$0]?.role == .headCoach
        }
        guard headCoachIDs.count == 1 else {
            throw CareerControlError.missingHeadCoach
        }
        var coach: Staff
        if let existingCoachID = state.career.coachID,
           let existingCoach = state.staff[existingCoachID] {
            coach = existingCoach
        } else {
            var ordinal = 10_000
            repeat {
                coach = StaffPopulationGenerator.replacement(
                    rootSeed: state.league.seed,
                    season: state.calendar.season,
                    organisationID: programmeID,
                    prestige: programme.prestige,
                    role: .headCoach,
                    positionGroup: nil,
                    ordinal: ordinal
                )
                ordinal += 1
            } while state.staff[coach.id] != nil
        }
        let control = CollegeCareerControl(
            coachID: coach.id,
            programmeID: programmeID,
            startedAt: state.calendar
        )
        var next = state
        next.staff.insert(coach)
        for organisationID in next.programmes.ids where organisationID != programmeID {
            _ = next.programmes.update(organisationID) { programme in
                programme.staffIDs.removeAll { $0 == coach.id }
            }
        }
        for teamID in next.proTeams.ids {
            _ = next.proTeams.update(teamID) { team in
                team.staffIDs.removeAll { $0 == coach.id }
            }
        }
        _ = next.programmes.update(programmeID) { programme in
            programme.staffIDs = programme.staffIDs
                .filter { $0 != headCoachIDs[0] && $0 != coach.id }
                + [coach.id]
        }
        // Appended, not inserted-if-absent: a coach who resigned and was hired again already has
        // a career record, and leaving its last assignment pointing at the former programme is the
        // stale seat root integrity refuses.
        next.people.recordStaffAssignment(
            StaffCareerAssignment(
                season: state.calendar.season,
                organisationID: programmeID,
                role: .headCoach
            ),
            for: coach
        )
        next.career.setCollege(control)
        _ = next.careerArc.establishCollegeJob(
            organisationID: programmeID,
            at: state.calendar
        )
        // The appointment itself, so `02` section 7's reset happens here rather than inside
        // `establishCollegeJob` -- which is also the weekly recovery path and must not wipe support.
        next.careerArc.arriveAtNewOrganisation()
        CareerArcSystem.prepareSeasonExpectation(in: next, arc: &next.careerArc)
        guard WorldIntegrity.check(next).isValid else {
            throw CareerControlError.missingHeadCoach
        }
        return CareerControlTransition(state: next, control: control)
    }

    /// Moves the controlled coach, and the coordinators who carry their scheme identity, to the
    /// professional team they were promoted to.
    ///
    /// The career arc records the job; the world records the chair. Leaving the chair behind is
    /// what let a promoted coach stay listed as their old programme's head coach, and kept the
    /// professional seat out of `people.staffCareers` — the one authority the coaching tree and
    /// the season history archive both read, so the promotion vanished from every history surface.
    ///
    /// `02` section 9 names the four coordinators as the subset of staff the promotion carries, and
    /// position coaches as staying put: what travels is the staff that holds scheme identity, which
    /// is the line above it in the same list. Owner decision 2026-08-20.
    static func seatProfessionalPromotion(
        teamID: UUID,
        in state: inout GameState
    ) {
        guard let coachID = state.career.coachID,
              state.staff[coachID] != nil,
              state.proTeams[teamID] != nil else { return }
        let season = state.calendar.season
        let arriving = [coachID] + coordinatorsServingWith(coachID, in: state)

        vacate(staffIDs: arriving, in: &state)

        // The incumbents of every seat the arriving group fills are displaced together, for the
        // same reason the head coach is: an organisation holds one coach per role, so a seat that
        // is being taken cannot also still be held.
        //
        // Derived from who actually arrived, never from the roles a promotion usually carries. A
        // promotion accepted while seeking brings the coach alone, and clearing the coordinator
        // seats then would empty four chairs nobody is walking into.
        let replacedRoles = Set(arriving.compactMap { state.staff[$0]?.role })
        let displaced = Set((state.proTeams[teamID]?.staffIDs ?? []).filter { staffID in
            state.staff[staffID].map { replacedRoles.contains($0.role) } ?? false
        })
        _ = state.proTeams.update(teamID) { team in
            team.staffIDs = team.staffIDs.filter {
                !arriving.contains($0) && !displaced.contains($0)
            } + arriving
        }
        for staffID in arriving {
            guard let member = state.staff[staffID] else { continue }
            state.people.recordStaffAssignment(
                StaffCareerAssignment(
                    season: season,
                    organisationID: teamID,
                    role: member.role
                ),
                for: member
            )
        }
        state.career.setPro(ProCareerControl(
            coachID: coachID,
            teamID: teamID,
            startedAt: state.calendar
        ))
    }

    /// The coordinators employed by whichever organisation currently seats the coach, in role
    /// order so the same promotion moves the same people on every run.
    private static func coordinatorsServingWith(
        _ coachID: UUID,
        in state: GameState
    ) -> [UUID] {
        let staffIDs = state.programmes.values.first {
            $0.staffIDs.contains(coachID)
        }?.staffIDs ?? state.proTeams.values.first {
            $0.staffIDs.contains(coachID)
        }?.staffIDs ?? []
        return StaffRole.coordinators.compactMap { role in
            staffIDs.first { state.staff[$0]?.role == role }
        }
    }

    /// What to write onto the played coach's career for the season that just ended, computed
    /// without mutating anything.
    ///
    /// `02` section 9: one line per season, for the played coach only, taken from the standings of
    /// the tier they were employed in. Recorded rather than computed on demand, because standings
    /// hold only the current season and a `SeasonArchive` keeps no per-organisation win-loss, so
    /// once the season is archived there is nothing left to compute it from.
    ///
    /// Split from the write on purpose: this reads `careerArc.currentJob`, and
    /// `CareerArcSystem.evaluateSeasonEnd` can fire the coach and clear that job in the very same
    /// transaction, immediately afterward. Computing here, before that runs, is what keeps the
    /// season someone was sacked at the end of on their record. The write is deferred separately
    /// because `WorldScheduler`'s season-end step reassigns `state.people` wholesale, later in the
    /// same transaction, from a snapshot taken before any of this runs — an in-place write here
    /// would be silently discarded by that reassignment. The caller applies the result with
    /// `PeopleState.recordCoachSeason` after that reassignment, not before it.
    static func pendingCoachSeason(
        after calendar: CalendarState,
        in state: GameState
    ) -> (coachID: UUID, record: CoachSeasonRecord)? {
        guard let coachID = state.career.coachID,
              let job = state.careerArc.currentJob else { return nil }
        if let outcome = CareerSeasonOutcomeSystem.snapshot(after: calendar, in: state) {
            return (coachID, outcome)
        }
        let tier: Tier = job.tier == .college ? .college : .pro
        guard let row = state.competition.standings[tier]?.first(where: {
            $0.id == job.organisationID
        }) else { return nil }
        return (coachID, CoachSeasonRecord(
            season: calendar.season,
            organisationID: job.organisationID,
            wins: row.wins,
            losses: row.losses,
            ties: row.ties
        ))
    }

    /// Takes the controlled coach off whatever staff still lists them, appointing a successor to
    /// the seat they leave.
    ///
    /// Separation has to reach the world, not just the career state. Clearing `career.college`
    /// alone left a resigned or promoted coach standing in their old organisation's staff list as
    /// its head coach, which every staff surface then reported as current employment.
    ///
    /// Only the coach: `02` section 9 makes the staff that follows a promotion rule, not a
    /// separation rule. A coach who resigns or is fired goes nowhere and takes nobody.
    static func vacateCurrentSeat(in state: inout GameState) {
        guard let coachID = state.career.coachID else { return }
        vacate(staffIDs: [coachID], in: &state)
    }

    /// Removes each of these people from whichever organisation employs them, filling the seat
    /// each one leaves with a generated coach of the same role.
    ///
    /// The seat is found in the world rather than in `career.college`, because a promotion can
    /// also be accepted while seeking, after a resignation has already cleared that control.
    /// Career records are left alone: they are employment history, and a move is not an erasure.
    private static func vacate(staffIDs: [UUID], in state: inout GameState) {
        let season = state.calendar.season
        for staffID in staffIDs {
            guard let member = state.staff[staffID] else { continue }
            for programmeID in state.programmes.ids {
                guard state.programmes[programmeID]?.staffIDs.contains(staffID) == true,
                      let prestige = state.programmes[programmeID]?.prestige else { continue }
                let successorID = appointReplacement(
                    organisationID: programmeID,
                    prestige: prestige,
                    season: season,
                    for: member,
                    in: &state
                )
                _ = state.programmes.update(programmeID) { programme in
                    programme.staffIDs = programme.staffIDs.filter {
                        $0 != staffID
                    } + [successorID]
                }
            }
            for teamID in state.proTeams.ids {
                guard state.proTeams[teamID]?.staffIDs.contains(staffID) == true,
                      let prestige = state.proTeams[teamID]?.prestige else { continue }
                let successorID = appointReplacement(
                    organisationID: teamID,
                    prestige: prestige,
                    season: season,
                    for: member,
                    in: &state
                )
                _ = state.proTeams.update(teamID) { team in
                    team.staffIDs = team.staffIDs.filter { $0 != staffID } + [successorID]
                }
            }
        }
    }

    /// Generates and inserts a coach for a seat that is about to be vacated.
    /// `WorldIntegrity` holds every organisation to exactly one coach per role, so a vacancy is not
    /// a state the world is allowed to be in even for one intent.
    private static func appointReplacement(
        organisationID: UUID,
        prestige: Rating,
        season: Int,
        for departing: Staff,
        in state: inout GameState
    ) -> UUID {
        var ordinal = 20_000
        var successor: Staff
        repeat {
            successor = StaffPopulationGenerator.replacement(
                rootSeed: state.league.seed,
                season: season,
                organisationID: organisationID,
                prestige: prestige,
                role: departing.role,
                positionGroup: departing.positionGroup,
                ordinal: ordinal
            )
            ordinal += 1
        } while state.staff[successor.id] != nil
        state.staff.insert(successor)
        state.people.insert(
            staff: successor,
            assignment: StaffCareerAssignment(
                season: season,
                organisationID: organisationID,
                role: successor.role
            )
        )
        return successor.id
    }

    @discardableResult
    public static func setResponsibility(
        _ responsibility: CollegeCareerResponsibility,
        owner: CareerResponsibilityOwner,
        in state: inout GameState
    ) -> Bool {
        guard var control = state.career.college,
              let programme = state.programmes[control.programmeID] else { return false }
        if case let .delegated(staffID) = owner {
            guard staffID != control.coachID,
                  programme.staffIDs.contains(staffID),
                  state.staff[staffID] != nil else {
                return false
            }
        }
        control.setOwner(owner, for: responsibility)
        guard delegationFitsCapacity(control.responsibilityOwners.values) else { return false }
        var proposed = state
        proposed.career.setCollege(control)
        guard WorldIntegrity.check(proposed).isValid else { return false }
        state = proposed
        return true
    }

    @discardableResult
    public static func setProResponsibility(
        _ responsibility: ProCareerResponsibility,
        owner: CareerResponsibilityOwner,
        in state: inout GameState
    ) -> Bool {
        guard var control = state.career.pro,
              let team = state.proTeams[control.teamID] else { return false }
        if case let .delegated(staffID) = owner {
            guard staffID != control.coachID,
                  team.staffIDs.contains(staffID),
                  state.staff[staffID] != nil else { return false }
        }
        control.setOwner(owner, for: responsibility)
        guard delegationFitsCapacity(control.responsibilityOwners.values) else { return false }
        var proposed = state
        proposed.career.setPro(control)
        guard WorldIntegrity.check(proposed).isValid else { return false }
        state = proposed
        return true
    }

    static func delegationFitsCapacity<S: Sequence>(_ owners: S) -> Bool
    where S.Element == CareerResponsibilityOwner {
        var counts: [UUID: Int] = [:]
        for owner in owners {
            guard case let .delegated(staffID) = owner else { continue }
            counts[staffID, default: 0] += 1
            if counts[staffID, default: 0] > maximumResponsibilitiesPerDelegate {
                return false
            }
        }
        return true
    }
}

/// Runs the same recruiting policy as every other programme, but only when the controlled
/// responsibility has explicitly been delegated to an employed staff member.
public enum CollegeCareerDelegationSystem {
    public static func processRecruiting(
        in state: GameState
    ) throws -> CollegeRecruitingAITransition {
        let unchanged = CollegeRecruitingAITransition(
            college: state.college,
            scouting: state.scouting,
            decisions: [],
            eventPayloads: []
        )
        guard let control = state.career.college else { return unchanged }

        let recruitingIsDelegated = if case .delegated = control
            .responsibilityOwners[.recruiting] { true } else { false }
        let nilIsDelegated = if case .delegated = control
            .responsibilityOwners[.nilAllocation] { true } else { false }
        guard recruitingIsDelegated || nilIsDelegated else { return unchanged }

        let proposed = try CollegeRecruitingAISystem.process(
            programmeIDs: [control.programmeID],
            in: state
        )
        if recruitingIsDelegated && nilIsDelegated { return proposed }

        func applyDelegated(
            _ request: RecruitingActionRequest,
            to state: inout GameState
        ) throws -> RecruitingActionTransition {
            let userRelationship = nilIsDelegated
                ? state.college.programmes[request.programmeID]?
                    .relationships[request.prospectID]
                : nil
            let transition = try CollegeRecruitingSystem.apply(request, in: state)
            var college = transition.college
            if let userRelationship {
                _ = college.updateProgramme(request.programmeID) { programme in
                    _ = programme.updateRelationship(request.prospectID) {
                        $0 = userRelationship
                    }
                }
            }
            state.college = college
            if !nilIsDelegated {
                state.scouting = transition.scouting
            }
            return transition
        }

        var working = state
        var decisions: [RecruitingPolicyDecision] = []
        var payloads: [DomainEventPayload] = []

        for decision in proposed.decisions {
            let isNIL = if case .setNILAllocation = decision.request.action {
                true
            } else {
                false
            }
            guard isNIL ? nilIsDelegated : recruitingIsDelegated else { continue }

            if recruitingIsDelegated,
               case .withdraw = decision.request.action,
               (working.college.programmes[decision.request.programmeID]?
                   .nilAllocation(for: decision.request.prospectID) ?? 0) > 0 {
                continue
            }

            guard let transition = try? applyDelegated(
                decision.request,
                to: &working
            ) else { continue }
            decisions.append(decision)
            payloads.append(contentsOf: transition.eventPayloads)
        }

        if nilIsDelegated,
           decisions.isEmpty,
           let recruiting = working.college.programmes[control.programmeID],
           let prospectID = recruiting.boardIDs.first(where: {
               recruiting.nilAllocation(for: $0) < CollegeRules.aiInitialNILAllocation
           }) {
            let current = recruiting.nilAllocation(for: prospectID)
            let increase = min(
                recruiting.nilState.remaining,
                CollegeRules.aiInitialNILAllocation - current
            )
            if increase > 0 {
                let request = RecruitingActionRequest(
                    programmeID: control.programmeID,
                    prospectID: prospectID,
                    action: .setNILAllocation(amount: current + increase)
                )
                let transition = try applyDelegated(request, to: &working)
                decisions.append(RecruitingPolicyDecision(
                    request: request,
                    score: transition.explanation.total,
                    explanation: transition.explanation
                ))
                payloads.append(contentsOf: transition.eventPayloads)
            }
        }
        return CollegeRecruitingAITransition(
            college: working.college,
            scouting: working.scouting,
            decisions: decisions,
            eventPayloads: payloads
        )
    }
}

public struct ProCareerDelegationTransition: Sendable, Equatable {
    public let state: GameState
    public let eventPayloads: [DomainEventPayload]
    public let settledNegotiationIDs: [UUID]

    public init(
        state: GameState,
        eventPayloads: [DomainEventPayload],
        settledNegotiationIDs: [UUID] = []
    ) {
        self.state = state
        self.eventPayloads = eventPayloads
        self.settledNegotiationIDs = settledNegotiationIDs
    }
}

public enum ProCareerDelegationSystem {
    public static func process(in state: GameState) throws -> ProCareerDelegationTransition {
        guard let control = state.career.pro else {
            return ProCareerDelegationTransition(state: state, eventPayloads: [])
        }
        var next = state
        var payloads: [DomainEventPayload] = []
        var settledNegotiationIDs: [UUID] = []
        if case let .delegated(staffID) = control.responsibilityOwners[.scouting],
           state.proMarket.phase == .freeAgency || state.proMarket.phase == .draft {
            let observed = Set(state.proMarket.observations.lazy
                .filter { $0.teamID == control.teamID }
                .map(\.prospectID))
            if let prospectID = state.proMarket.draftClass.first(where: {
                !observed.contains($0.id)
            })?.id {
                next = try ProMarketSystem.recordScouting(
                    teamID: control.teamID,
                    prospectID: prospectID,
                    in: next
                )
                if let observation = next.proMarket.observations.first(where: {
                    $0.teamID == control.teamID && $0.prospectID == prospectID
                }) {
                    payloads.append(.proDraftScouted(
                        teamID: control.teamID,
                        prospectID: prospectID,
                        confidence: observation.confidence
                    ))
                    _ = next.career.recordDelegatedActivity(CareerDelegatedActivity(
                        id: "\(state.calendar.season)|\(state.calendar.week)|pro.scouting|\(staffID.uuidString)|\(prospectID.uuidString)",
                        calendar: state.calendar,
                        area: .professional(.scouting),
                        actorID: staffID,
                        action: .scouting,
                        effect: .actionsCommitted(count: 1),
                        trigger: state.career.cruise?.status == .active
                            ? .cruise : .scheduledWeek
                    ))
                }
            }
        }
        if case let .delegated(staffID) = control
            .responsibilityOwners[.contractNegotiations],
           let negotiation = next.proMarket.contractNegotiations.first(where: {
               $0.teamID == control.teamID && $0.status.isOpen
           }) {
            do {
                next = try ProManagementSystem.settleNegotiation(
                    negotiationID: negotiation.id,
                    as: .accepted,
                    in: next
                ).state
            } catch ProManagementError.capExceeded {
                next = try ProManagementSystem.settleNegotiation(
                    negotiationID: negotiation.id,
                    as: .rejected,
                    in: next
                ).state
            }
            settledNegotiationIDs.append(negotiation.id)
            _ = next.career.recordDelegatedActivity(CareerDelegatedActivity(
                id: "\(state.calendar.season)|\(state.calendar.week)|pro.contractNegotiations|\(staffID.uuidString)|\(negotiation.id.uuidString)",
                calendar: state.calendar,
                area: .professional(.contractNegotiations),
                actorID: staffID,
                action: .contractNegotiation,
                effect: .actionsCommitted(count: 1),
                trigger: state.career.cruise?.status == .active
                    ? .cruise : .scheduledWeek
            ))
        }
        return ProCareerDelegationTransition(
            state: next,
            eventPayloads: payloads,
            settledNegotiationIDs: settledNegotiationIDs
        )
    }
}
