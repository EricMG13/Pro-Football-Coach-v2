import Foundation

public enum CareerSessionIntent: Sendable, Equatable {
    case advanceWeek
    case prepareWeek
    case match(MatchAction)
    case recruiting(prospectID: UUID, action: RecruitingAction)
    case tacticalPlan(TacticalPlan)
    case practicePlan(TacticalPracticePlan)
    case personnelPlan(PersonnelPlan)
    case setResponsibility(
        responsibility: CollegeCareerResponsibility,
        owner: CareerResponsibilityOwner
    )
    case setProResponsibility(
        responsibility: ProCareerResponsibility,
        owner: CareerResponsibilityOwner
    )
    case startCruise(requestedEnd: CalendarState)
    case continueCruise
    case stopCruise
    case delegateDecision(decisionID: UUID, staffID: UUID)
    case career(CareerArcAction)
    case proManagement(ProManagementAction)
    case proMarket(ProMarketAction)
    case mandatoryDecision(decisionID: UUID, optionID: UUID)
}

public enum CareerSessionError: Error, Sendable, Equatable {
    case missingControlledCareer
    case missingWeeklyPreparation([TacticalPreparationRequirement])
    case responsibilityDelegated
    case missingMandatoryDecision
    case missingDecisionOption
    case decisionActionFailed
    case responsibilityUpdateFailed
    /// Delegation is atomic across every decision the responsibility has waiting, and one of them
    /// could not be applied -- most often because the recommended options together want more of a
    /// weekly budget than the week has left. Nothing was delegated, including the decision the
    /// player asked about.
    case delegationIncomplete
    case invalidState
    case matchInProgress
    case matchNotStarted
    case staleMatchCheckpoint
    case matchActionFailed(MatchReducerError)
    /// The career reached `SharedRules.maximumCareerSeasons`. Terminal, and the save stays
    /// readable -- every screen still answers, the week simply cannot advance again.
    case careerComplete
}

public struct CareerRecruitingProspectProjection: Sendable, Equatable, Identifiable {
    public var id: UUID { prospectID }
    public let prospectID: UUID
    public let name: String
    public let position: Position
    public let interest: Int
    public let scholarshipOffered: Bool
    public let visitScheduled: Bool
    public let nilAllocation: Int
    public let estimatedOverall: Int?
    public let estimatedPotential: Int?
    public let confidence: Int?
}

public struct CollegeProgrammeProjection: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let name: String
    public let nickname: String
    public let prestige: Int
    public let resources: Int
    public let rosterCount: Int
    public let scholarshipCount: Int
    public let responsibilityOwners: [
        CollegeCareerResponsibility: CareerResponsibilityOwner
    ]
}

public enum CareerResponsibilityArea: Codable, Sendable, Equatable, Hashable {
    case college(CollegeCareerResponsibility)
    case professional(ProCareerResponsibility)
}

public enum CareerResponsibilityPolicy: String, Sendable, Equatable {
    case manual
    case existingAI
    case recommendedOption
    case balanced
    case derivedDepthChart
}

public struct CareerResponsibilityProjection: Sendable, Equatable, Identifiable {
    public var id: CareerResponsibilityArea { area }
    public let area: CareerResponsibilityArea
    public let owner: CareerResponsibilityOwner
    public let assignedStaffID: UUID?
    public let delegateCapacityUsed: Int
    public let delegateCapacityLimit: Int
    public let policy: CareerResponsibilityPolicy
}

public struct CareerWhileAwayProjection: Sendable, Equatable {
    public let cruise: CareerCruiseState?
    public let activities: [CareerDelegatedActivity]
}

public struct CareerProjection: Sendable, Equatable {
    public let calendar: CalendarState
    /// `nil` when the coach is jobless but remains a durable career identity.
    public let tier: CareerJobTier?
    /// The currently controlled organisation, or `nil` while seeking work.
    public let programme: CollegeProgrammeProjection?
    public let recruitingBoard: [CareerRecruitingProspectProjection]
    public let mandatoryDecisions: [MandatoryDecision]
    public let responsibilities: [CareerResponsibilityProjection]
    public let whileAway: CareerWhileAwayProjection
    public let outcomes: CareerOutcomeProjection
}

public enum CareerSessionResult: Sendable, Equatable {
    case intent(IntentResult)
    case preparationCommitted(organisationID: UUID, calendar: CalendarState)
    case responsibilityUpdated(
        responsibility: CollegeCareerResponsibility,
        owner: CareerResponsibilityOwner
    )
    case proResponsibilityUpdated(
        responsibility: ProCareerResponsibility,
        owner: CareerResponsibilityOwner
    )
    case cruiseUpdated(CareerCruiseState)
    case decisionDelegated(decisionID: UUID, staffID: UUID, optionID: UUID)
    case decisionResolved(decisionID: UUID, optionID: UUID)
    case matchStarted(fixtureID: UUID)
    case matchStep(MatchStepReceipt)
}

public struct CareerSessionReceipt: Sendable, Equatable {
    public let projection: CareerProjection
    public let result: CareerSessionResult
}

private struct CareerWeekAdvancePreparation {
    let state: GameState
    let delegatesControlledMatch: Bool
}

/// Actor-owned career state. No suspension occurs between validation and commit, so an intent
/// cannot re-enter the session against a partially applied `GameState`.
public actor CareerSession {
    private var state: GameState

    public init(state: GameState) throws {
        guard state.career.coachID != nil
                || state.career.college != nil
                || state.careerArc.currentJob?.tier == .professional else {
            throw CareerSessionError.missingControlledCareer
        }
        var prepared = ProCapComplianceSystem.refresh(
            in: CareerMandatoryDecisionSystem.refresh(in: state)
        )
        prepared.careerArc.beginSeason(prepared.calendar.season)
        CareerArcSystem.prepareSeasonExpectation(
            in: prepared,
            arc: &prepared.careerArc
        )
        // The recruiting cycle phase is derived from the week (`02` section 4.1), so recomputing it
        // here costs nothing and carries no information loss. It exists because a root written
        // before signing day was reachable carries `active` in the signing week, and the integrity
        // check below would refuse it — turning an openable save into `invalidState`.
        prepared.college.phase = CollegeRules
            .recruitingCyclePhase(inWeek: prepared.calendar.week)
        guard WorldIntegrity.check(prepared).isValid else {
            throw CareerSessionError.invalidState
        }
        self.state = prepared
    }

    public func projection() -> CareerProjection {
        Self.makeProjection(from: state)
    }

    /// The authoritative root, for the composition layer that builds screen read models from it.
    ///
    /// This is a read-only copy of a value type, so a caller cannot write back through it; the only
    /// way to change the world remains `resolve`. It exists because a truthful read model needs the
    /// whole root and `CareerProjection` is deliberately a narrow slice — and because the engine
    /// cannot build those read models itself without importing the UI, which `03b` §1 forbids.
    public func snapshot() -> GameState { state }

    /// Captures the app's per-save pacing preference in the resumable match checkpoint atomically.
    ///
    /// Only into a checkpoint *this call* installed. It is the one write in this actor that does
    /// not go through `MatchReducer`, so it does not move `revision`: two checkpoints differing
    /// only in their pacing target would otherwise share one revision, and `resolveMatch`
    /// authenticates on `(fixtureID, revision)`. Stamping a session before its first snap makes
    /// that unobservable -- the pair is unique from the moment anything can read it. A session
    /// already under way keeps the target it started with, which is also what `04` promises: the
    /// preference applies to the next match, not to one in progress.
    public func advanceWeek(callInsPerGame: Int) throws -> CareerSessionReceipt {
        let receipt = try resolve(.advanceWeek)
        guard case .matchStarted = receipt.result, var match = state.matchSession else {
            return receipt
        }
        match.setCallInTarget(callInsPerGame)
        var candidate = state
        candidate.matchSession = match
        guard WorldIntegrity.check(candidate).isValid else { return receipt }
        state = candidate
        return CareerSessionReceipt(
            projection: Self.makeProjection(from: state),
            result: receipt.result
        )
    }

    /// Revalidates the route's fixture and checkpoint inside the actor before applying the action.
    /// The screen-level preflight remains useful for copy, but this is the authority that closes the
    /// await gap between reading a model and committing a control.
    public func resolveMatch(
        fixtureID: UUID,
        revision: UInt64,
        action: MatchAction
    ) throws -> CareerSessionReceipt {
        guard let match = state.matchSession,
              match.fixtureID == fixtureID,
              match.revision == revision else {
            throw CareerSessionError.staleMatchCheckpoint
        }
        return try resolve(.match(action))
    }

    public func saveData() throws -> Data {
        try Task.checkCancellation()
        return try SaveEnvelope.encode(state)
    }

    public func resolve(_ intent: CareerSessionIntent) throws -> CareerSessionReceipt {
        try Task.checkCancellation()
        let control = state.career.college
        guard state.career.coachID != nil
                || control != nil
                || state.careerArc.currentJob?.tier == .professional else {
            throw CareerSessionError.missingControlledCareer
        }
        var resolutionState = state
        let coachIntent: CoachIntent
        switch intent {
        case let .startCruise(requestedEnd):
            var candidate = state
            guard candidate.career.startCruise(
                requestedEnd: requestedEnd,
                at: candidate.calendar
            ) else { throw CareerSessionError.invalidState }
            state = try runCruise(from: candidate)
            guard let cruise = state.career.cruise else {
                throw CareerSessionError.invalidState
            }
            return CareerSessionReceipt(
                projection: Self.makeProjection(from: state),
                result: .cruiseUpdated(cruise)
            )
        case .continueCruise:
            var candidate = state
            guard candidate.career.resumeCruise() else {
                throw CareerSessionError.invalidState
            }
            state = try runCruise(from: candidate)
            guard let cruise = state.career.cruise else {
                throw CareerSessionError.invalidState
            }
            return CareerSessionReceipt(
                projection: Self.makeProjection(from: state),
                result: .cruiseUpdated(cruise)
            )
        case .stopCruise:
            guard state.career.cruise?.status == .active else {
                throw CareerSessionError.invalidState
            }
            state.career.stopCruise(.userRequested)
            guard let cruise = state.career.cruise else {
                throw CareerSessionError.invalidState
            }
            return CareerSessionReceipt(
                projection: Self.makeProjection(from: state),
                result: .cruiseUpdated(cruise)
            )
        case .prepareWeek:
            guard let organisationID = controlledOrganisationID(in: state),
                  currentUnplayedGame(for: organisationID, in: state) != nil else {
                throw CareerSessionError.missingControlledCareer
            }
            guard !automatesGamePlan(in: state), !automatesPracticePlan(in: state) else {
                throw CareerSessionError.responsibilityDelegated
            }
            let missing = state.tactical.missingPreparation(
                for: organisationID,
                at: state.calendar
            )
            var candidate = state
            if missing.contains(.gamePlan) {
                guard candidate.tactical.setPlan(
                    .balanced,
                    for: organisationID,
                    at: state.calendar
                ) else { throw CareerSessionError.invalidState }
            }
            if missing.contains(.practicePlan) {
                guard candidate.tactical.setPracticePlan(
                    .balanced,
                    for: organisationID,
                    at: state.calendar
                ) else { throw CareerSessionError.invalidState }
            }
            guard WorldIntegrity.check(candidate).isValid else {
                throw CareerSessionError.invalidState
            }
            state = candidate
            return CareerSessionReceipt(
                projection: Self.makeProjection(from: state),
                result: .preparationCommitted(
                    organisationID: organisationID,
                    calendar: state.calendar
                )
            )
        case .advanceWeek:
            // Translated here rather than left to propagate: `WorldSchedulerError` is not a
            // `CareerSessionError`, so the app's exhaustive refusal switch would never see it and
            // a finished career would read as "that action could not be completed".
            guard state.calendar.season < SharedRules.maximumCareerSeasons else {
                throw CareerSessionError.careerComplete
            }
            guard state.matchSession == nil else { throw CareerSessionError.matchInProgress }
            let preparation: CareerWeekAdvancePreparation
            do {
                preparation = try preparedForWeekAdvance(from: state)
            } catch let error as WorldSchedulerError {
                // Installing a controlled fixture now settles the spring window first, so this is
                // where a user-owned portal responsibility is asked for its answers. It matters
                // that it refuses *here*: the branch below returns `.matchStarted` before
                // `IntentResolver` ever runs, so a decision queued for this week would otherwise be
                // stepped over by the match rather than blocking it.
                guard case let .portalDecisionsRequired(_, decisions) = error else { throw error }
                state = try enqueueing(decisions, or: error, in: state)
                throw IntentResolutionError.unresolvedMandatoryDecisions(
                    count: state.pending.mandatoryDecisions.count
                )
            }
            if let match = preparation.state.matchSession, let fixtureID = match.fixtureID {
                state = preparation.state
                return CareerSessionReceipt(
                    projection: Self.makeProjection(from: state),
                    result: .matchStarted(fixtureID: fixtureID)
                )
            }
            // Delegated weeks still use the shared resolver; carry its balanced preparation into
            // the resolver input, committing the actor only after that resolver succeeds.
            resolutionState = preparation.state
            coachIntent = .advanceWeek
        case let .match(action):
            guard var match = state.matchSession else {
                throw CareerSessionError.matchNotStarted
            }
            let step: MatchStepReceipt
            do {
                step = try MatchReducer.reduce(action, state: &match)
            } catch let error as MatchReducerError {
                throw CareerSessionError.matchActionFailed(error)
            }
            var candidate = state
            candidate.matchSession = match
            if match.completed, let completion = match.completion {
                candidate = try WorldScheduler.finalizeControlledMatch(completion, in: candidate)
            }
            state = CareerMandatoryDecisionSystem.refresh(in: candidate)
            return CareerSessionReceipt(
                projection: Self.makeProjection(from: state),
                result: .matchStep(step)
            )
        case let .recruiting(prospectID, action):
            guard let control else { throw CareerSessionError.missingControlledCareer }
            let responsibility: CollegeCareerResponsibility = if case .setNILAllocation = action {
                .nilAllocation
            } else {
                .recruiting
            }
            guard control.responsibilityOwners[responsibility] == .user else {
                throw CareerSessionError.responsibilityDelegated
            }
            coachIntent = .recruiting(RecruitingActionRequest(
                programmeID: control.programmeID,
                prospectID: prospectID,
                action: action
            ))
        case let .tacticalPlan(plan):
            guard let organisationID = control?.programmeID
                    ?? state.careerArc.currentJob?.organisationID else {
                throw CareerSessionError.missingControlledCareer
            }
            if let pro = state.career.pro,
               pro.responsibilityOwners[.gamePlan] != .user {
                throw CareerSessionError.responsibilityDelegated
            }
            coachIntent = .tacticalPlan(TacticalPlanRequest(
                organisationID: organisationID,
                calendar: state.calendar,
                plan: plan
            ))
        case let .practicePlan(plan):
            guard let organisationID = control?.programmeID
                    ?? state.careerArc.currentJob?.organisationID else {
                throw CareerSessionError.missingControlledCareer
            }
            if control.map({ $0.responsibilityOwners[.practicePlan] != .user }) == true
                || state.career.pro.map({
                    $0.responsibilityOwners[.practicePlan] != .user
                }) == true {
                throw CareerSessionError.responsibilityDelegated
            }
            coachIntent = .practicePlan(TacticalPracticePlanRequest(
                organisationID: organisationID,
                calendar: state.calendar,
                plan: plan
            ))
        case let .personnelPlan(plan):
            guard let organisationID = controlledOrganisationID(in: state),
                  plan.organisationID == organisationID,
                  plan.calendar == state.calendar else {
                throw CareerSessionError.missingControlledCareer
            }
            if control.map({ $0.responsibilityOwners[.depthChart] != .user }) == true
                || state.career.pro.map({
                    $0.responsibilityOwners[.depthChart] != .user
                }) == true {
                throw CareerSessionError.responsibilityDelegated
            }
            coachIntent = .personnelPlan(PersonnelPlanRequest(plan: plan))
        case let .setResponsibility(responsibility, owner):
            guard !state.pending.mandatoryDecisions.contains(where: {
                $0.responsibility == responsibility
            }) else {
                throw CareerSessionError.responsibilityUpdateFailed
            }
            var candidate = state
            guard CareerControlSystem.setResponsibility(
                responsibility,
                owner: owner,
                in: &candidate
            ) else {
                throw CareerSessionError.responsibilityUpdateFailed
            }
            state = candidate
            return CareerSessionReceipt(
                projection: Self.makeProjection(from: state),
                result: .responsibilityUpdated(
                    responsibility: responsibility,
                    owner: owner
                )
            )
        case let .setProResponsibility(responsibility, owner):
            var candidate = state
            guard CareerControlSystem.setProResponsibility(
                responsibility,
                owner: owner,
                in: &candidate
            ) else {
                throw CareerSessionError.responsibilityUpdateFailed
            }
            state = candidate
            return CareerSessionReceipt(
                projection: Self.makeProjection(from: state),
                result: .proResponsibilityUpdated(
                    responsibility: responsibility,
                    owner: owner
                )
            )
        case let .delegateDecision(decisionID, staffID):
            guard let control,
                  let decision = state.pending.mandatoryDecisions.first(where: {
                      $0.id == decisionID
                          && $0.owner == .user
                          && $0.programmeID == control.programmeID
                  }),
                  control.responsibilityOwners[decision.responsibility] == .user,
                  let programme = state.programmes[control.programmeID],
                  programme.staffIDs.contains(staffID),
                  staffID != control.coachID,
                  state.staff[staffID] != nil else {
                throw CareerSessionError.responsibilityUpdateFailed
            }
            var candidate = state
            let queued = state.pending.mandatoryDecisions.filter {
                $0.programmeID == control.programmeID
                    && $0.owner == .user
                    && $0.responsibility == decision.responsibility
            }
            var delegatedOptionID: UUID?
            for queuedDecision in queued {
                guard let option = queuedDecision.options.first(where: {
                    $0.id == queuedDecision.recommendedOptionID
                }) else {
                    throw CareerSessionError.missingDecisionOption
                }
                do {
                    candidate = try applyDecision(
                        queuedDecision,
                        option: option,
                        control: control,
                        in: candidate
                    )
                } catch {
                    // Every sibling or none: a partial delegation would leave the responsibility
                    // owned by staff with decisions the staff never answered.
                    throw CareerSessionError.delegationIncomplete
                }
                guard candidate.pending.removeDecision(id: queuedDecision.id) != nil,
                      candidate.career.recordResolution(MandatoryDecisionResolution(
                          decisionID: queuedDecision.id,
                          programmeID: queuedDecision.programmeID,
                          subject: queuedDecision.subject,
                          optionID: option.id,
                          action: option.action,
                          decidedAt: candidate.calendar
                      )),
                      recordDecisionDelegation(
                          decision: queuedDecision,
                          optionID: option.id,
                          staffID: staffID,
                          in: &candidate
                      ) else {
                    throw CareerSessionError.responsibilityUpdateFailed
                }
                if queuedDecision.id == decisionID { delegatedOptionID = option.id }
            }
            // Delegation resolves each sibling with its *recommended* option and then flips the
            // owner below, which is what makes `CollegePortalPolicyV1.makeMarketSnapshot` stop
            // reading those resolutions as overrides and recompute the baseline instead. The two
            // agree today only because the recommendation is the baseline. That equivalence cannot
            // be checked from here -- the baseline is a boundary-state computation -- so it is
            // asserted where it can actually fail, in `makeMarketSnapshot`'s delegated branch.
            guard let delegatedOptionID,
                  CareerControlSystem.setResponsibility(
                      decision.responsibility,
                      owner: .delegated(staffID: staffID),
                      in: &candidate
                  ),
                  WorldIntegrity.check(candidate).isValid else {
                throw CareerSessionError.responsibilityUpdateFailed
            }
            try Task.checkCancellation()
            state = CareerMandatoryDecisionSystem.refresh(in: candidate)
            return CareerSessionReceipt(
                projection: Self.makeProjection(from: state),
                result: .decisionDelegated(
                    decisionID: decisionID,
                    staffID: staffID,
                    optionID: delegatedOptionID
                )
            )
        case let .career(action):
            coachIntent = .career(CareerArcRequest(
                calendar: state.calendar,
                action: action
            ))
        case let .proManagement(action):
            guard let job = state.careerArc.currentJob, job.tier == .professional else {
                throw CareerSessionError.invalidState
            }
            let responsibility: ProCareerResponsibility
            switch action {
            case .acquire, .release:
                responsibility = .rosterManagement
            case .beginNegotiation, .counterNegotiation, .acceptNegotiation,
                 .rejectNegotiation, .withdrawNegotiation:
                responsibility = .contractNegotiations
            }
            guard state.career.pro?.responsibilityOwners[responsibility] ?? .user == .user else {
                throw CareerSessionError.responsibilityDelegated
            }
            coachIntent = .proManagement(ProManagementRequest(
                calendar: state.calendar,
                action: action
            ))
        case let .proMarket(action):
            guard let job = state.careerArc.currentJob, job.tier == .professional else {
                throw CareerSessionError.invalidState
            }
            let responsibility: ProCareerResponsibility = if case .scout = action {
                .scouting
            } else {
                .rosterManagement
            }
            guard state.career.pro?.responsibilityOwners[responsibility] ?? .user == .user else {
                throw CareerSessionError.responsibilityDelegated
            }
            coachIntent = .proMarket(ProMarketRequest(
                calendar: state.calendar,
                action: action
            ))
        case let .mandatoryDecision(decisionID, optionID):
            guard let control else { throw CareerSessionError.missingMandatoryDecision }
            return try resolveDecision(
                decisionID: decisionID,
                optionID: optionID,
                control: control
            )
        }
        let resolved: ResolvedIntent
        do {
            resolved = try IntentResolver.resolve(coachIntent, in: resolutionState)
        } catch let error as WorldSchedulerError {
            guard case let .portalDecisionsRequired(_, decisions) = error else { throw error }
            // Committed against `state`, not `resolutionState`: the advance is refused, so the week
            // stays where it was and the only thing that carries forward is the queue the user now
            // has to answer. `preparedForWeekAdvance` cannot have changed anything here anyway --
            // the scheduler reaches the portal only on a week with no unplayed controlled fixture.
            state = try enqueueing(decisions, or: error, in: state)
            throw IntentResolutionError.unresolvedMandatoryDecisions(
                count: state.pending.mandatoryDecisions.count
            )
        }
        try Task.checkCancellation()
        state = ProCapComplianceSystem.refresh(
            in: CareerMandatoryDecisionSystem.refresh(in: resolved.state)
        )
        return CareerSessionReceipt(
            projection: Self.makeProjection(from: state),
            result: .intent(resolved.result)
        )
    }

    private func resolveDecision(
        decisionID: UUID,
        optionID: UUID,
        control: CollegeCareerControl
    ) throws -> CareerSessionReceipt {
        guard let decision = state.pending.mandatoryDecisions.first(where: {
            $0.id == decisionID
        }) else { throw CareerSessionError.missingMandatoryDecision }
        guard decision.owner == .user,
              control.responsibilityOwners[decision.responsibility] == .user else {
            throw CareerSessionError.responsibilityDelegated
        }
        guard let option = decision.options.first(where: { $0.id == optionID }) else {
            throw CareerSessionError.missingDecisionOption
        }
        var candidate = state
        candidate = try applyDecision(
            decision,
            option: option,
            control: control,
            in: candidate
        )
        guard candidate.pending.removeDecision(id: decisionID) != nil,
              candidate.career.recordResolution(MandatoryDecisionResolution(
                  decisionID: decision.id,
                  programmeID: decision.programmeID,
                  subject: decision.subject,
                  optionID: option.id,
                  action: option.action,
                  decidedAt: candidate.calendar
              )),
              WorldIntegrity.check(candidate).isValid else {
            throw CareerSessionError.decisionActionFailed
        }
        try Task.checkCancellation()
        state = candidate
        return CareerSessionReceipt(
            projection: Self.makeProjection(from: state),
            result: .decisionResolved(decisionID: decisionID, optionID: optionID)
        )
    }

    private func applyDecision(
        _ decision: MandatoryDecision,
        option: MandatoryDecisionOption,
        control: CollegeCareerControl,
        in candidate: GameState
    ) throws -> GameState {
        var candidate = candidate
        switch option.action {
        case let .recruiting(action):
            candidate = try IntentResolver.resolve(
                .recruiting(RecruitingActionRequest(
                    programmeID: control.programmeID,
                    prospectID: decision.subject.entityID,
                    action: action
                )),
                in: candidate
            ).state
        case let .redshirt(plannedAppearanceLimit):
            if let plannedAppearanceLimit {
                candidate.college = try CollegeRedshirtSystem.designate(
                    playerID: decision.subject.entityID,
                    programmeID: control.programmeID,
                    plannedAppearanceLimit: plannedAppearanceLimit,
                    in: candidate
                )
            } else if candidate.college.redshirtPlans[decision.subject.entityID] != nil {
                candidate.college = try CollegeRedshirtSystem.clearDesignation(
                    playerID: decision.subject.entityID,
                    programmeID: control.programmeID,
                    in: candidate
                )
            }
        case let .nilAllocation(amount):
            var applied = false
            _ = candidate.college.updateProgramme(control.programmeID) {
                applied = $0.setRosterNILAllocation(
                    amount,
                    playerID: decision.subject.entityID
                )
            }
            guard applied else { throw CareerSessionError.decisionActionFailed }
        case .portalRetention, .portalRelease:
            break
        }
        return candidate
    }

    private func recordDecisionDelegation(
        decision: MandatoryDecision,
        optionID: UUID,
        staffID: UUID,
        in state: inout GameState
    ) -> Bool {
        let sequence = state.history.nextSequence
        let event = DomainEvent(
            id: DomainEvent.deterministicID(
                rootSeed: state.league.seed,
                sequence: sequence
            ),
            sequence: sequence,
            occurredAt: state.calendar,
            payload: .decisionDelegated(
                decisionID: decision.id,
                programmeID: decision.programmeID,
                responsibility: decision.responsibility,
                staffID: staffID,
                optionID: optionID
            )
        )
        guard state.history.append(event) else { return false }
        return state.career.recordDelegatedActivity(CareerDelegatedActivity(
            id: "\(event.id.uuidString)|decision",
            calendar: state.calendar,
            area: .college(decision.responsibility),
            actorID: staffID,
            action: .decisionApplied,
            effect: .recommendationApplied(optionID: optionID),
            trigger: .mandatoryDecision
        ))
    }

    /// Queues decisions the scheduler derived at a boundary the session cannot reach itself.
    ///
    /// Refuses rather than repairs when the result would not stand: an enqueue that `WorldIntegrity`
    /// rejects means the derivation and the week it is being queued against disagree, and the honest
    /// answer to that is the scheduler's own error, not a queue nothing can ever drain.
    private func enqueueing(
        _ decisions: [MandatoryDecision],
        or error: WorldSchedulerError,
        in source: GameState
    ) throws -> GameState {
        var candidate = source
        for decision in decisions {
            // Already queued is the goal, not a collision. The spring window's decisions are
            // enqueued a week ahead by `CareerMandatoryDecisionSystem.refresh`, so the scheduler's
            // derivation names decisions this root already holds -- which is the two agreeing, and
            // is exactly what the shared derivation exists to guarantee.
            if candidate.pending.mandatoryDecisions.contains(where: { $0.id == decision.id }) {
                continue
            }
            guard candidate.pending.enqueue(decision) else { throw error }
        }
        guard WorldIntegrity.check(candidate).isValid else { throw error }
        return candidate
    }

    private func runCruise(from source: GameState) throws -> GameState {
        var next = source
        for _ in 0..<CareerCruiseState.maximumWeeks {
            try Task.checkCancellation()
            guard next.career.cruise?.status == .active else { return next }
            guard next.calendar.season < SharedRules.maximumCareerSeasons else {
                next.career.stopCruise(.careerComplete)
                return next
            }
            guard next.pending.mandatoryDecisions.isEmpty else {
                next.career.stopCruise(.mandatoryDecision)
                return next
            }
            guard controlledProfessionalCapIsLegal(in: next) else {
                next.career.stopCruise(.capIllegal)
                return next
            }
            if let organisationID = controlledOrganisationID(in: next),
               currentUnplayedGame(for: organisationID, in: next) != nil,
               !shouldDelegateControlledMatch(in: next) {
                next.career.stopCruise(.matchRequiresControl)
                return next
            }
            let availabilityBefore = controlledUnavailableIDs(in: next)
            let preparation = try preparedForWeekAdvance(from: next)
            guard preparation.state.matchSession == nil else {
                next.career.stopCruise(.matchRequiresControl)
                return next
            }
            let resolved: ResolvedIntent
            do {
                resolved = try IntentResolver.resolve(.advanceWeek, in: preparation.state)
            } catch let error as WorldSchedulerError {
                guard case let .portalDecisionsRequired(_, decisions) = error else { throw error }
                next = try enqueueing(decisions, or: error, in: next)
                next.career.stopCruise(.mandatoryDecision)
                return next
            }
            next = ProCapComplianceSystem.refresh(
                in: CareerMandatoryDecisionSystem.refresh(in: resolved.state)
            )
            guard next.career.advanceCruise(to: next.calendar) else {
                throw CareerSessionError.invalidState
            }
            if controlledUnavailableIDs(in: next) != availabilityBefore {
                next.career.stopCruise(.injuryAvailabilityChanged)
            } else if !next.pending.mandatoryDecisions.isEmpty {
                next.career.stopCruise(.mandatoryDecision)
            }
        }
        return next
    }

    private func preparedForWeekAdvance(
        from source: GameState
    ) throws -> CareerWeekAdvancePreparation {
        var prepared = source
        let delegated = shouldDelegateControlledMatch(in: source)
        if let organisationID = controlledOrganisationID(in: source),
           currentUnplayedGame(for: organisationID, in: source) != nil {
            let missing = source.tactical.missingPreparation(
                for: organisationID,
                at: source.calendar
            )
            var unresolved: [TacticalPreparationRequirement] = []
            for requirement in missing {
                switch requirement {
                case .gamePlan where automatesGamePlan(in: source):
                    if prepared.tactical.setPlan(
                        .balanced,
                        for: organisationID,
                        at: source.calendar
                    ) {
                        recordPreparationActivity(
                            action: .gamePlan,
                            in: &prepared
                        )
                    }
                case .practicePlan where automatesPracticePlan(in: source):
                    if prepared.tactical.setPracticePlan(
                        .balanced,
                        for: organisationID,
                        at: source.calendar
                    ) {
                        recordPreparationActivity(
                            action: .practicePlan,
                            in: &prepared
                        )
                    }
                default:
                    unresolved.append(requirement)
                }
            }
            guard unresolved.isEmpty else {
                throw CareerSessionError.missingWeeklyPreparation(unresolved)
            }
            if automatesDepthChart(in: source),
               prepared.tactical.personnelPlan(
                   for: organisationID,
                   at: source.calendar
               ) == nil {
                if prepared.tactical.setPersonnelPlan(PersonnelPlan(
                    organisationID: organisationID,
                    calendar: source.calendar,
                    overrides: []
                )) {
                    recordPreparationActivity(action: .depthChart, in: &prepared)
                }
            }
        }
        if !delegated {
            prepared = try WorldScheduler.prepareControlledMatch(in: prepared)
        }
        return CareerWeekAdvancePreparation(
            state: prepared,
            delegatesControlledMatch: delegated
        )
    }

    private func controlledProfessionalCapIsLegal(in state: GameState) -> Bool {
        guard let teamID = state.career.pro?.teamID else { return true }
        return (try? ProManagementSystem.capSnapshot(teamID: teamID, in: state))?
            .isWithinCap == true
    }

    private func recordPreparationActivity(
        action: CareerDelegatedAction,
        in state: inout GameState
    ) {
        let assignment: (CareerResponsibilityArea, UUID)?
        switch action {
        case .gamePlan:
            if let owner = state.career.pro?.responsibilityOwners[.gamePlan],
               case let .delegated(staffID) = owner {
                assignment = (.professional(.gamePlan), staffID)
            } else if let owner = state.career.college?
                .responsibilityOwners[.practicePlan], case let .delegated(staffID) = owner {
                assignment = (.college(.practicePlan), staffID)
            } else {
                assignment = nil
            }
        case .practicePlan:
            let owner = state.career.college?.responsibilityOwners[.practicePlan]
                ?? state.career.pro?.responsibilityOwners[.practicePlan]
            if case let .delegated(staffID) = owner {
                assignment = state.career.college == nil
                    ? (.professional(.practicePlan), staffID)
                    : (.college(.practicePlan), staffID)
            } else {
                assignment = nil
            }
        case .depthChart:
            let owner = state.career.college?.responsibilityOwners[.depthChart]
                ?? state.career.pro?.responsibilityOwners[.depthChart]
            if case let .delegated(staffID) = owner {
                assignment = state.career.college == nil
                    ? (.professional(.depthChart), staffID)
                    : (.college(.depthChart), staffID)
            } else {
                assignment = nil
            }
        default:
            assignment = nil
        }
        guard let (area, staffID) = assignment else { return }
        _ = state.career.recordDelegatedActivity(CareerDelegatedActivity(
            id: "\(state.calendar.season)|\(state.calendar.week)|\(areaKey(area))|\(staffID.uuidString)|\(action.rawValue)",
            calendar: state.calendar,
            area: area,
            actorID: staffID,
            action: action,
            effect: .actionsCommitted(count: 1),
            trigger: state.career.cruise?.status == .active ? .cruise : .scheduledWeek
        ))
    }

    private func areaKey(_ area: CareerResponsibilityArea) -> String {
        switch area {
        case let .college(value): return "college.\(value.rawValue)"
        case let .professional(value): return "pro.\(value.rawValue)"
        }
    }

    private func controlledUnavailableIDs(in state: GameState) -> Set<UUID> {
        let rosterIDs = state.career.college.flatMap {
            state.programmes[$0.programmeID]?.rosterIDs
        } ?? state.career.pro.flatMap {
            state.proTeams[$0.teamID].map { $0.rosterIDs + $0.practiceSquadIDs }
        } ?? []
        return Set(rosterIDs.filter {
            state.people.playerLifecycle[$0]?.isAvailable == false
        })
    }

    private func shouldDelegateControlledMatch(in state: GameState) -> Bool {
        if let control = state.career.college {
            return CollegeCareerResponsibility.allCases.allSatisfy { responsibility in
                if case .delegated = control.responsibilityOwners[responsibility] {
                    return true
                }
                return false
            }
        }
        if let control = state.career.pro {
            return ProCareerResponsibility.allCases.allSatisfy { responsibility in
                if case .delegated = control.responsibilityOwners[responsibility] {
                    return true
                }
                return false
            }
        }
        return false
    }

    private func automatesGamePlan(in state: GameState) -> Bool {
        if let owner = state.career.pro?.responsibilityOwners[.gamePlan],
           case .delegated = owner {
            return true
        }
        return state.career.college != nil && shouldDelegateControlledMatch(in: state)
    }

    private func automatesPracticePlan(in state: GameState) -> Bool {
        let owner = state.career.college?.responsibilityOwners[.practicePlan]
            ?? state.career.pro?.responsibilityOwners[.practicePlan]
        if case .delegated = owner { return true }
        return false
    }

    private func automatesDepthChart(in state: GameState) -> Bool {
        let owner = state.career.college?.responsibilityOwners[.depthChart]
            ?? state.career.pro?.responsibilityOwners[.depthChart]
        if case .delegated = owner { return true }
        return false
    }

    private func controlledOrganisationID(in state: GameState) -> UUID? {
        state.career.college?.programmeID
            ?? (state.careerArc.currentJob?.tier == .professional
                ? state.careerArc.currentJob?.organisationID
                : nil)
    }

    private func currentUnplayedGame(for organisationID: UUID, in state: GameState)
        -> ScheduledGame? {
        state.competition.currentSchedule.games.first {
            $0.season == state.calendar.season
                && $0.week == state.calendar.week
                && $0.result == nil
                && ($0.homeID == organisationID || $0.awayID == organisationID)
        }
    }

    private static func makeProjection(from state: GameState) -> CareerProjection {
        let control = state.career.college
        let tier: CareerJobTier?
        let programme: CollegeProgrammeProjection?
        let recruiting: ProgrammeRecruitingState?
        if let control,
           let collegeProgramme = state.programmes[control.programmeID],
           let collegeRecruiting = state.college.programmes[control.programmeID] {
            tier = .college
            programme = CollegeProgrammeProjection(
                id: collegeProgramme.id,
                name: collegeProgramme.name,
                nickname: collegeProgramme.nickname,
                prestige: collegeProgramme.prestige.value,
                resources: collegeProgramme.resources.value,
                rosterCount: collegeProgramme.rosterIDs.count,
                scholarshipCount: collegeRecruiting.scholarshipPlayerIDs.count,
                responsibilityOwners: control.responsibilityOwners
            )
            recruiting = collegeRecruiting
        } else if let job = state.careerArc.currentJob,
                  job.tier == .professional,
                  let team = state.proTeams[job.organisationID] {
            tier = .professional
            programme = CollegeProgrammeProjection(
                id: team.id,
                name: team.displayName,
                nickname: team.nickname,
                prestige: team.prestige.value,
                resources: team.prestige.value,
                rosterCount: team.rosterIDs.count,
                scholarshipCount: team.practiceSquadIDs.count,
                responsibilityOwners: [:]
            )
            recruiting = nil
        } else {
            tier = nil
            programme = nil
            recruiting = nil
        }
        let board = recruiting?.boardIDs.compactMap { prospectID
            -> CareerRecruitingProspectProjection? in
            guard let prospect = state.prospects[prospectID],
                  let relationship = recruiting?.relationships[prospectID] else { return nil }
            guard let control else { return nil }
            let observation = state.scouting.observation(
                observerID: control.programmeID,
                prospectID: prospectID
            )
            let estimates = observation.map { observation in
                prospect.position.ratedAttributes.compactMap {
                    observation.estimatedAttributes[$0]?.value
                }
            }
            let estimatedOverall = estimates.flatMap { values in
                values.count == prospect.position.ratedAttributes.count && !values.isEmpty
                    ? values.reduce(0, +) / values.count
                    : nil
            }
            return CareerRecruitingProspectProjection(
                prospectID: prospectID,
                name: prospect.fullName,
                position: prospect.position,
                interest: relationship.interest,
                scholarshipOffered: relationship.scholarshipOffered,
                visitScheduled: relationship.visitScheduled,
                nilAllocation: recruiting?.nilState.recruitingReservations[prospectID] ?? 0,
                estimatedOverall: estimatedOverall,
                estimatedPotential: observation?.estimatedPotential.value,
                confidence: observation?.confidence
            )
        }
        return CareerProjection(
            calendar: state.calendar,
            tier: tier,
            programme: programme,
            recruitingBoard: board ?? [],
            mandatoryDecisions: state.pending.mandatoryDecisions,
            responsibilities: responsibilityProjections(from: state),
            whileAway: CareerWhileAwayProjection(
                cruise: state.career.cruise,
                activities: state.career.delegatedActivities
            ),
            outcomes: CareerOutcomeProjection.make(from: state)
        )
    }

    private static func responsibilityProjections(
        from state: GameState
    ) -> [CareerResponsibilityProjection] {
        if let control = state.career.college {
            return CollegeCareerResponsibility.allCases.map { responsibility in
                let owner = control.responsibilityOwners[responsibility] ?? .user
                return responsibilityProjection(
                    area: .college(responsibility),
                    owner: owner,
                    owners: control.responsibilityOwners.values,
                    policy: collegePolicy(for: responsibility)
                )
            }
        }
        if let control = state.career.pro {
            return ProCareerResponsibility.allCases.map { responsibility in
                let owner = control.responsibilityOwners[responsibility] ?? .user
                return responsibilityProjection(
                    area: .professional(responsibility),
                    owner: owner,
                    owners: control.responsibilityOwners.values,
                    policy: proPolicy(for: responsibility)
                )
            }
        }
        return []
    }

    private static func responsibilityProjection<S: Sequence>(
        area: CareerResponsibilityArea,
        owner: CareerResponsibilityOwner,
        owners: S,
        policy: CareerResponsibilityPolicy
    ) -> CareerResponsibilityProjection where S.Element == CareerResponsibilityOwner {
        let staffID: UUID? = if case let .delegated(id) = owner { id } else { nil }
        let used = staffID.map { id in
            owners.reduce(0) { count, candidate in
                if case let .delegated(candidateID) = candidate, candidateID == id {
                    count + 1
                } else {
                    count
                }
            }
        } ?? 0
        return CareerResponsibilityProjection(
            area: area,
            owner: owner,
            assignedStaffID: staffID,
            delegateCapacityUsed: used,
            delegateCapacityLimit: CareerControlSystem.maximumResponsibilitiesPerDelegate,
            policy: staffID == nil ? .manual : policy
        )
    }

    private static func collegePolicy(
        for responsibility: CollegeCareerResponsibility
    ) -> CareerResponsibilityPolicy {
        switch responsibility {
        case .recruiting: return .existingAI
        case .portalAndRetention, .nilAllocation, .redshirts: return .recommendedOption
        case .practicePlan: return .balanced
        case .depthChart: return .derivedDepthChart
        }
    }

    private static func proPolicy(
        for responsibility: ProCareerResponsibility
    ) -> CareerResponsibilityPolicy {
        switch responsibility {
        case .scouting, .rosterManagement: return .existingAI
        case .contractNegotiations: return .recommendedOption
        case .gamePlan, .practicePlan: return .balanced
        case .depthChart: return .derivedDepthChart
        }
    }
}
