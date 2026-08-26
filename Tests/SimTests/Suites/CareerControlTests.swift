import Foundation
import FootballSimCore

func runCareerControlTests() {
    suite("Controlled college career authority") {
        test("a chosen college job becomes one persisted authoritative career") {
            let source = GameState.bootstrap(seed: 98_001)
            let programmeID = source.programmes.ids[0]
            let headCoachID = source.programmes[programmeID]!.staffIDs.first {
                source.staff[$0]?.role == .headCoach
            }!

            let transition = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            )

            expectEqual(transition.state.career.college?.programmeID, programmeID)
            expect(transition.state.career.college?.coachID != headCoachID)
            expectEqual(
                transition.state.career.college?.coachID,
                transition.state.career.coachID
            )
            let playerCoachID = transition.state.career.coachID!
            expect(transition.state.programmes[programmeID]!.staffIDs.contains(playerCoachID))
            expect(!transition.state.programmes[programmeID]!.staffIDs.contains(headCoachID))
            expectEqual(transition.state.staff[playerCoachID]?.role, .headCoach)
            expect(transition.state.people.staffCareers[playerCoachID] != nil)
            expectEqual(transition.state.career.college?.startedAt, source.calendar)
            expectEqual(
                Set(transition.state.career.college?.responsibilityOwners.map(\.key) ?? []),
                Set(CollegeCareerResponsibility.allCases)
            )
            expect(transition.state.career.college?.responsibilityOwners.values.allSatisfy {
                $0 == .user
            } ?? false)
            expectEqual(source.career, CareerControlState())
            expect(WorldIntegrity.check(transition.state).isValid)

            let restored = try SaveEnvelope.decode(
                GameState.self,
                from: SaveEnvelope.encode(transition.state)
            )
            expectEqual(restored, transition.state)

            do {
                _ = try CareerControlSystem.startCollegeCareer(
                    at: source.programmes.ids[1],
                    in: transition.state
                )
                expect(false, "a second controlled college job was started")
            } catch let error as CareerControlError {
                expectEqual(error, .careerAlreadyStarted)
            }
        }

        test("scheduled recruiting AI never acts for the controlled programme") {
            let source = GameState.bootstrap(seed: 98_002)
            let programmeID = source.programmes.ids[0]
            let controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state

            let transition = try CollegeRecruitingAISystem.process(in: controlled)

            expect(!transition.decisions.contains(where: {
                $0.request.programmeID == programmeID
            }))
            expect(transition.decisions.contains(where: {
                $0.request.programmeID != programmeID
            }))
            expectEqual(
                transition.college.programmes[programmeID],
                controlled.college.programmes[programmeID]
            )
        }

        test("delegation ownership is limited to staff employed by the controlled programme") {
            let source = GameState.bootstrap(seed: 98_003)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let coordinatorID = controlled.programmes[programmeID]!.staffIDs.first {
                controlled.staff[$0]?.role == .offensiveCoordinator
            }!
            let outsiderID = controlled.programmes[controlled.programmes.ids[1]]!.staffIDs[0]

            expect(CareerControlSystem.setResponsibility(
                .recruiting,
                owner: .delegated(staffID: coordinatorID),
                in: &controlled
            ))
            expectEqual(
                controlled.career.college?.responsibilityOwners[.recruiting],
                .delegated(staffID: coordinatorID)
            )
            let beforeRejected = try SaveEnvelope.encode(controlled)
            expect(!CareerControlSystem.setResponsibility(
                .recruiting,
                owner: .delegated(staffID: outsiderID),
                in: &controlled
            ))
            expectEqual(try SaveEnvelope.encode(controlled), beforeRejected)
            expect(WorldIntegrity.check(controlled).isValid)
        }

        test("a delegate owns at most two college responsibilities") {
            let source = GameState.bootstrap(seed: 98_023)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let staffID = controlled.programmes[programmeID]!.staffIDs.first {
                controlled.staff[$0]?.role == .offensiveCoordinator
            }!

            expect(CareerControlSystem.setResponsibility(
                .recruiting,
                owner: .delegated(staffID: staffID),
                in: &controlled
            ))
            expect(CareerControlSystem.setResponsibility(
                .practicePlan,
                owner: .delegated(staffID: staffID),
                in: &controlled
            ))
            let beforeRejected = try SaveEnvelope.encode(controlled)
            expect(!CareerControlSystem.setResponsibility(
                .depthChart,
                owner: .delegated(staffID: staffID),
                in: &controlled
            ))
            expectEqual(try SaveEnvelope.encode(controlled), beforeRejected)
            expectEqual(
                CareerControlSystem.maximumResponsibilitiesPerDelegate,
                2
            )
        }

        test("career-owned staff are not silently removed by routine retirement") {
            let source = GameState.bootstrap(seed: 98_011)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let coachID = controlled.career.college!.coachID
            let coordinatorID = controlled.programmes[programmeID]!.staffIDs.first {
                controlled.staff[$0]?.role == .offensiveCoordinator
            }!
            let delegates = controlled.programmes[programmeID]!.staffIDs.filter {
                controlled.staff[$0]?.role != .headCoach
            }
            for (index, responsibility) in CollegeCareerResponsibility.allCases.enumerated() {
                expect(CareerControlSystem.setResponsibility(
                    responsibility,
                    owner: .delegated(staffID: index < 2
                        ? coordinatorID
                        : delegates[index / 2]),
                    in: &controlled
                ))
            }
            _ = controlled.staff.update(coachID) {
                $0.age = PeopleRules.staffAgeRange.upperBound
            }
            _ = controlled.staff.update(coordinatorID) {
                $0.age = PeopleRules.staffAgeRange.upperBound
            }
            controlled.calendar = CalendarState(
                season: controlled.calendar.season,
                week: SharedRules.inSeasonWeeks
            )
            controlled.league.week = SharedRules.inSeasonWeeks

            let transition = try SeasonLifecycleSystem.advance(
                after: controlled.calendar,
                in: controlled
            )

            expect(transition.programmes[programmeID]?.staffIDs.contains(coachID) == true)
            expect(transition.programmes[programmeID]?.staffIDs.contains(coordinatorID) == true)
            expectEqual(transition.staff[coachID]?.age, PeopleRules.staffAgeRange.upperBound)
            expectEqual(
                transition.staff[coordinatorID]?.age,
                PeopleRules.staffAgeRange.upperBound
            )
        }

        test("mandatory decisions persist typed authority and stable options") {
            let source = GameState.bootstrap(seed: 98_004)
            let programmeID = source.programmes.ids[0]
            let controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let prospectID = controlled.prospects.ids[0]
            let decisionID = UUID(uuidString: "00000000-0000-4000-8000-0000000000D1")!
            let keepID = UUID(uuidString: "00000000-0000-4000-8000-0000000000D2")!
            let withdrawID = UUID(uuidString: "00000000-0000-4000-8000-0000000000D3")!
            let decision = MandatoryDecision(
                id: decisionID,
                programmeID: programmeID,
                subject: .recruiting(prospectID: prospectID),
                createdAt: controlled.calendar,
                deadline: controlled.calendar.advancedWeek(),
                owner: .user,
                options: [
                    MandatoryDecisionOption(
                        id: keepID,
                        action: .recruiting(.offerScholarship)
                    ),
                    MandatoryDecisionOption(
                        id: withdrawID,
                        action: .recruiting(.withdraw)
                    ),
                ],
                recommendedOptionID: keepID,
                reasons: [
                    MandatoryDecisionReason(
                        code: .rosterNeed,
                        value: 8,
                        relatedEntityID: prospectID
                    ),
                    MandatoryDecisionReason(code: .deadline, value: 1),
                ]
            )
            var state = controlled

            expect(state.pending.enqueue(decision))
            expect(!state.pending.enqueue(decision))
            expectEqual(state.pending.mandatoryDecisions, [decision])
            expectEqual(decision.responsibility, .recruiting)
            expectEqual(decision.options.map(\.id), [keepID, withdrawID])
            expectEqual(decision.recommendedOptionID, keepID)
            expect(WorldIntegrity.check(state).isValid)

            let restored = try SaveEnvelope.decode(
                GameState.self,
                from: SaveEnvelope.encode(state)
            )
            expectEqual(restored, state)

            do {
                _ = try IntentResolver.resolve(.advanceWeek, in: state)
                expect(false, "advance week bypassed a typed mandatory decision")
            } catch let error as IntentResolutionError {
                expectEqual(error, .unresolvedMandatoryDecisions(count: 1))
            }
        }

        testAsync("career session derives programme authority and projects only observed recruiting truth") {
            let source = GameState.bootstrap(seed: 98_005)
            let programmeID = source.programmes.ids[0]
            let controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let prospectID = controlled.prospects.ids[0]
            let hiddenPotential = controlled.prospects[prospectID]!.potential.value
            let session = try CareerSession(state: controlled)

            let receipt = try await session.resolve(.recruiting(
                prospectID: prospectID,
                action: .addToBoard
            ))
            let projection = receipt.projection

            guard let projectedProgramme = projection.programme else {
                expect(false, "a controlled college session lost its programme projection")
                return
            }
            expectEqual(projectedProgramme.id, programmeID)
            expectEqual(projectedProgramme.name, controlled.programmes[programmeID]!.name)
            expectEqual(projection.recruitingBoard.count, 1)
            expectEqual(projection.recruitingBoard[0].prospectID, prospectID)
            expectEqual(projection.recruitingBoard[0].estimatedOverall, nil)
            expectEqual(projection.recruitingBoard[0].estimatedPotential, nil)
            expect(!projection.recruitingBoard.contains(where: {
                $0.estimatedPotential == hiddenPotential
            }))
            switch receipt.result {
            case let .intent(.recruitingUpdated(result)):
                expectEqual(result.request.programmeID, programmeID)
                expectEqual(result.request.prospectID, prospectID)
            default:
                expect(false, "career recruiting returned the wrong receipt")
            }
        }

        testAsync("a cancelled career intent leaves actor-owned state byte-identical") {
            let source = GameState.bootstrap(seed: 98_006)
            let programmeID = source.programmes.ids[0]
            let controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let prospectID = controlled.prospects.ids[0]
            let session = try CareerSession(state: controlled)
            let before = try await session.saveData()

            let cancelled = Task {
                withUnsafeCurrentTask { $0?.cancel() }
                return try await session.resolve(.recruiting(
                    prospectID: prospectID,
                    action: .addToBoard
                ))
            }
            do {
                _ = try await cancelled.value
                expect(false, "a cancelled career intent mutated the session")
            } catch is CancellationError {
                expect(true)
            }

            expectEqual(try await session.saveData(), before)
            expectEqual((await session.projection()).recruitingBoard.count, 0)
        }

        testAsync("delegated recruiting uses the shared policy while direct user intents are refused") {
            let source = GameState.bootstrap(seed: 98_007)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let coordinatorID = controlled.programmes[programmeID]!.staffIDs.first {
                controlled.staff[$0]?.role == .offensiveCoordinator
            }!
            expect(CareerControlSystem.setResponsibility(
                .recruiting,
                owner: .delegated(staffID: coordinatorID),
                in: &controlled
            ))

            let userNILState = controlled.college.programmes[programmeID]!.nilState
            let delegated = try CollegeCareerDelegationSystem.processRecruiting(in: controlled)
            expect(!delegated.decisions.isEmpty)
            expect(delegated.decisions.allSatisfy {
                $0.request.programmeID == programmeID
            })
            expectEqual(
                delegated.eventPayloads.count,
                delegated.decisions.count
            )
            expect(delegated.decisions.allSatisfy { decision in
                if case .setNILAllocation = decision.request.action { return false }
                return true
            })
            expectEqual(
                delegated.college.programmes[programmeID]!.nilState,
                userNILState
            )
            controlled.college = delegated.college
            controlled.scouting = delegated.scouting

            expect(CareerControlSystem.setResponsibility(
                .recruiting,
                owner: .user,
                in: &controlled
            ))
            expect(CareerControlSystem.setResponsibility(
                .nilAllocation,
                owner: .delegated(staffID: coordinatorID),
                in: &controlled
            ))
            let userRelationships = controlled.college.programmes[programmeID]!.relationships
            let userScouting = controlled.scouting
            let nilOnly = try CollegeCareerDelegationSystem.processRecruiting(in: controlled)
            expect(!nilOnly.decisions.isEmpty)
            expect(nilOnly.decisions.allSatisfy { decision in
                if case .setNILAllocation = decision.request.action { return true }
                return false
            })
            expectEqual(
                nilOnly.college.programmes[programmeID]!.relationships,
                userRelationships
            )
            expectEqual(nilOnly.scouting, userScouting)

            expect(CareerControlSystem.setResponsibility(
                .recruiting,
                owner: .delegated(staffID: coordinatorID),
                in: &controlled
            ))
            let sharedPolicy = try CollegeRecruitingAISystem.process(
                programmeIDs: [programmeID],
                in: controlled
            )
            let bothDelegated = try CollegeCareerDelegationSystem.processRecruiting(
                in: controlled
            )
            expectEqual(bothDelegated, sharedPolicy)

            let session = try CareerSession(state: controlled)
            do {
                _ = try await session.resolve(.recruiting(
                    prospectID: controlled.prospects.ids[0],
                    action: .setNILAllocation(amount: 0)
                ))
                expect(false, "a user intent bypassed delegated NIL authority")
            } catch let error as CareerSessionError {
                expectEqual(error, .responsibilityDelegated)
            }
        }

        testAsync("career session delegation records its named employed owner") {
            let source = GameState.bootstrap(seed: 98_017)
            let programmeID = source.programmes.ids[0]
            let controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let staffID = controlled.programmes[programmeID]!.staffIDs
                .compactMap { controlled.staff[$0] }
                .first { $0.id != controlled.career.college!.coachID }!
                .id
            let session = try CareerSession(state: controlled)

            let receipt = try await session.resolve(.setResponsibility(
                responsibility: .recruiting,
                owner: .delegated(staffID: staffID)
            ))
            if case let .responsibilityUpdated(responsibility, owner) = receipt.result {
                expectEqual(responsibility, .recruiting)
                expectEqual(owner, .delegated(staffID: staffID))
            } else {
                expect(false, "delegation did not return its typed receipt")
            }
            guard let projectedProgramme = receipt.projection.programme else {
                expect(false, "delegation lost its programme projection")
                return
            }
            expectEqual(
                projectedProgramme.responsibilityOwners[.recruiting],
                .delegated(staffID: staffID)
            )

            let restored = try SaveEnvelope.decode(
                GameState.self,
                from: try await session.saveData()
            )
            expectEqual(
                restored.career.college?.responsibilityOwners[.recruiting],
                .delegated(staffID: staffID)
            )
            expect(WorldIntegrity.check(restored).isValid)
        }

        testAsync("career session commits a calendar-scoped personnel override") {
            let source = GameState.bootstrap(seed: 98_018)
            let programmeID = source.programmes.ids[0]
            let controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let quarterbacks = controlled.programmes[programmeID]!.rosterIDs
                .compactMap { controlled.players[$0] }
                .filter { $0.position == .quarterback }
                .map(\.id)
            guard let first = quarterbacks.first else {
                expect(false, "the generated roster had no quarterback")
                return
            }
            let plan = PersonnelPlan(
                organisationID: programmeID,
                calendar: controlled.calendar,
                overrides: [DepthChartOverride(position: .quarterback, playerIDs: [first])]
            )
            let session = try CareerSession(state: controlled)
            let receipt = try await session.resolve(.personnelPlan(plan))
            if case let .intent(.tacticalUpdated(result)) = receipt.result {
                expectEqual(result.kind, .personnelPlan)
                expectEqual(result.organisationID, programmeID)
            } else {
                expect(false, "personnel update did not return its typed receipt")
            }
            let restored = try SaveEnvelope.decode(
                GameState.self,
                from: try await session.saveData()
            )
            expectEqual(
                restored.tactical.personnelPlan(for: programmeID, at: restored.calendar),
                plan
            )
            expect(WorldIntegrity.check(restored).isValid)
        }

        testAsync("delegating a pending decision applies the recommendation atomically") {
            let source = GameState.bootstrap(seed: 98_019)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let prospectID = controlled.prospects.ids[0]
            let decisionID = UUID(uuidString: "00000000-0000-4000-8000-000000000F19")!
            let addID = UUID(uuidString: "00000000-0000-4000-8000-000000000F1A")!
            let withdrawID = UUID(uuidString: "00000000-0000-4000-8000-000000000F1B")!
            let decision = MandatoryDecision(
                id: decisionID,
                programmeID: programmeID,
                subject: .recruiting(prospectID: prospectID),
                createdAt: controlled.calendar,
                deadline: controlled.calendar,
                owner: .user,
                options: [
                    MandatoryDecisionOption(id: addID, action: .recruiting(.addToBoard)),
                    MandatoryDecisionOption(id: withdrawID, action: .recruiting(.withdraw)),
                ],
                recommendedOptionID: addID,
                reasons: [MandatoryDecisionReason(code: .rosterNeed, value: 1)]
            )
            expect(controlled.pending.enqueue(decision))
            let staffID = controlled.programmes[programmeID]!.staffIDs
                .compactMap { controlled.staff[$0] }
                .first { $0.id != controlled.career.college!.coachID }!
                .id
            let session = try CareerSession(state: controlled)

            let receipt = try await session.resolve(.delegateDecision(
                decisionID: decisionID,
                staffID: staffID
            ))
            if case let .decisionDelegated(resolvedID, resolvedStaffID, optionID) = receipt.result {
                expectEqual(resolvedID, decisionID)
                expectEqual(resolvedStaffID, staffID)
                expectEqual(optionID, addID)
            } else {
                expect(false, "delegation did not return its typed receipt")
            }
            expect(!receipt.projection.mandatoryDecisions.contains { $0.id == decisionID })
            let restored = try SaveEnvelope.decode(
                GameState.self,
                from: try await session.saveData()
            )
            expectEqual(
                restored.career.college?.responsibilityOwners[.recruiting],
                .delegated(staffID: staffID)
            )
            expect(restored.career.mandatoryDecisionResolutions.contains {
                $0.decisionID == decisionID && $0.optionID == addID
            })
            expect(restored.history.recent.contains { event in
                event.payload == .decisionDelegated(
                    decisionID: decisionID,
                    programmeID: programmeID,
                    responsibility: .recruiting,
                    staffID: staffID,
                    optionID: addID
                )
            })
            expect(restored.career.delegatedActivities.contains { activity in
                activity.area == .college(.recruiting)
                    && activity.actorID == staffID
                    && activity.action == .decisionApplied
                    && activity.effect == .recommendationApplied(optionID: addID)
                    && activity.trigger == .mandatoryDecision
            })
            expect(WorldIntegrity.check(restored).isValid)
        }

        testAsync("mandatory decision resolution is atomic and uses its persisted option") {
            let source = GameState.bootstrap(seed: 98_008)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let prospectID = controlled.prospects.ids[0]
            let decisionID = UUID(uuidString: "00000000-0000-4000-8000-0000000000E1")!
            let addID = UUID(uuidString: "00000000-0000-4000-8000-0000000000E2")!
            let withdrawID = UUID(uuidString: "00000000-0000-4000-8000-0000000000E3")!
            _ = controlled.pending.enqueue(MandatoryDecision(
                id: decisionID,
                programmeID: programmeID,
                subject: .recruiting(prospectID: prospectID),
                createdAt: controlled.calendar,
                deadline: controlled.calendar,
                owner: .user,
                options: [
                    MandatoryDecisionOption(id: addID, action: .recruiting(.addToBoard)),
                    MandatoryDecisionOption(id: withdrawID, action: .recruiting(.withdraw)),
                ],
                recommendedOptionID: addID,
                reasons: [MandatoryDecisionReason(code: .deadline, value: 0)]
            ))
            let session = try CareerSession(state: controlled)
            let before = try await session.saveData()

            do {
                _ = try await session.resolve(.mandatoryDecision(
                    decisionID: decisionID,
                    optionID: UUID(uuidString: "00000000-0000-4000-8000-0000000000EF")!
                ))
                expect(false, "an unknown decision option was accepted")
            } catch let error as CareerSessionError {
                expectEqual(error, .missingDecisionOption)
            }
            expectEqual(try await session.saveData(), before)

            let receipt = try await session.resolve(.mandatoryDecision(
                decisionID: decisionID,
                optionID: addID
            ))
            expect(!receipt.projection.mandatoryDecisions.contains(where: {
                $0.id == decisionID
            }))
            expectEqual(receipt.projection.recruitingBoard.map(\.prospectID), [prospectID])
            expectEqual(receipt.result, .decisionResolved(
                decisionID: decisionID,
                optionID: addID
            ))
        }

        test("week-one redshirt exceptions produce stable causal decisions") {
            let source = GameState.bootstrap(seed: 98_009)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let roster = controlled.programmes[programmeID]!.rosterIDs.compactMap {
                controlled.players[$0]
            }
            let position = Position.allCases.first { position in
                roster.filter { $0.position == position }.count
                    > (SharedRules.minimumPlayableRosterByPosition[position] ?? 0)
            } ?? .quarterback
            let positionPlayers = roster.filter { $0.position == position }.sorted {
                if $0.overall.value != $1.overall.value {
                    return $0.overall.value > $1.overall.value
                }
                return $0.id.uuidString < $1.id.uuidString
            }
            let candidateIndex = SharedRules.minimumPlayableRosterByPosition[position] ?? 0
            let candidateID = positionPlayers[candidateIndex].id
            _ = controlled.players.update(candidateID) {
                $0.eligibility = Eligibility(
                    seasonsRemaining: CollegeRules.seasonsOfCompetition,
                    yearsRemaining: CollegeRules.eligibilityClockYears
                )
            }

            let first = CareerMandatoryDecisionSystem.refresh(in: controlled)
            let second = CareerMandatoryDecisionSystem.refresh(in: controlled)
            let decision = first.pending.mandatoryDecisions.first {
                $0.subject == .redshirt(playerID: candidateID)
            }

            expect(decision != nil)
            expectEqual(first.pending, second.pending)
            expectEqual(decision?.deadline, controlled.calendar)
            expectEqual(decision?.owner, .user)
            expectEqual(decision?.options.count, 2)
            expect(decision?.reasons.contains(where: { $0.code == .playingTime }) ?? false)
            expect(WorldIntegrity.check(first).isValid)

            var automatic = controlled
            let staffID = automatic.programmes[programmeID]!.staffIDs.first {
                automatic.staff[$0]?.role != .headCoach
            }!
            expect(CareerControlSystem.setResponsibility(
                .redshirts,
                owner: .delegated(staffID: staffID),
                in: &automatic
            ))
            let fillerActivities = (0..<CareerControlState.maximumDelegatedActivities).map {
                CareerDelegatedActivity(
                    id: "filler-\($0)",
                    calendar: automatic.calendar,
                    area: .college(.redshirts),
                    actorID: staffID,
                    action: .decisionApplied,
                    effect: .actionsCommitted(count: 1),
                    trigger: .scheduledWeek
                )
            }
            automatic.career = CareerControlState(
                college: automatic.career.college,
                pro: automatic.career.pro,
                coachID: automatic.career.coachID,
                mandatoryDecisionResolutions: automatic.career.mandatoryDecisionResolutions,
                delegatedActivities: fillerActivities,
                cruise: automatic.career.cruise
            )
            let delegated = CareerMandatoryDecisionSystem.refresh(in: automatic)
            expect(delegated.career.mandatoryDecisionResolutions.contains {
                $0.decisionID == decision?.id
            })
            expect(delegated.career.delegatedActivities.contains { activity in
                activity.area == .college(.redshirts)
                    && activity.actorID == staffID
                    && activity.action == .decisionApplied
                    && activity.trigger == .mandatoryDecision
            })
            expect(delegated.history.recent.contains { event in
                event.payload == .decisionDelegated(
                    decisionID: decision!.id,
                    programmeID: programmeID,
                    responsibility: .redshirts,
                    staffID: staffID,
                    optionID: decision!.recommendedOptionID
                )
            })
            expectEqual(CareerMandatoryDecisionSystem.refresh(in: delegated), delegated)
            expectEqual(
                delegated.career.delegatedActivities.count,
                CareerControlState.maximumDelegatedActivities
            )
            expect(!delegated.career.delegatedActivities.contains { $0.id == "filler-0" })
            expect(WorldIntegrity.check(delegated).isValid)
        }

        testAsync("a fully delegated controlled career completes a deterministic annual cycle") {
            func delegatedState(seed: UInt64) throws -> GameState {
                let source = GameState.bootstrap(seed: seed)
                let programmeID = source.programmes.ids[0]
                var state = try CareerControlSystem.startCollegeCareer(
                    at: programmeID,
                    in: source
                ).state
                let staffIDs = state.programmes[programmeID]!.staffIDs.filter {
                    state.staff[$0]?.role != .headCoach
                }
                for (index, responsibility) in CollegeCareerResponsibility.allCases.enumerated() {
                    expect(CareerControlSystem.setResponsibility(
                        responsibility,
                        owner: .delegated(staffID: staffIDs[index / 2]),
                        in: &state
                    ))
                }
                return state
            }

            let first = try CareerSession(state: delegatedState(seed: 98_010))
            let second = try CareerSession(state: delegatedState(seed: 98_010))
            for _ in 0...SharedRules.inSeasonWeeks {
                async let firstAdvance = first.resolve(.advanceWeek)
                async let secondAdvance = second.resolve(.advanceWeek)
                _ = try await (firstAdvance, secondAdvance)
            }

            let firstProjection = await first.projection()
            let secondProjection = await second.projection()
            expectEqual(firstProjection, secondProjection)
            expectEqual(firstProjection.calendar, CalendarState(season: 1, week: 2))
            expect(firstProjection.mandatoryDecisions.isEmpty)
            let firstData = try await first.saveData()
            expectEqual(firstData, try await second.saveData())
            let restored = try SaveEnvelope.decode(GameState.self, from: firstData)
            expect(WorldIntegrity.check(restored).isValid)
            expectEqual(restored.college.portal.phase, .closed)
        }

    }
}

func runCareerPortalDecisionTests() {
    suite("Controlled college portal decisions") {
        testAsync("spring retention choices pause a user-owned portal responsibility") {
            var state = GameState.bootstrap(seed: 98_001)
            for _ in 0..<SharedRules.inSeasonWeeks {
                state = try WorldScheduler.advanceWeek(state).state
            }
            expectEqual(state.college.portal.phase, .awaitingSpring)
            guard let snapshot = CollegePortalPolicyV1.makeSnapshot(
                targetSeason: state.calendar.season,
                window: .spring,
                in: state
            ) else {
                expect(false, "the spring fixture did not expose an authoritative snapshot")
                return
            }
            // The programme must also be idle this week. This test's `advanceWeek` exists to run
            // the spring portal transaction to completion; a controlled programme with an unplayed
            // fixture pauses the week at its match instead, and the portal record it then asserts
            // is never written. That requirement used to be satisfied by luck — whichever intent
            // came first happened to belong to a programme on a bye — and it broke the day the
            // signing-week phase changed which intents the snapshot produced. Stated rather than
            // drawn.
            let playingProgrammeIDs = Set(
                state.competition.currentSchedule.games
                    .filter {
                        $0.season == state.calendar.season
                            && $0.week == state.calendar.week
                            && $0.result == nil
                    }
                    .flatMap { [$0.homeID, $0.awayID] }
            )
            guard let retainedIntent = snapshot.intents.first(where: { intent in
                guard !playingProgrammeIDs.contains(intent.sourceProgrammeID),
                      let programme = state.college.programmes[intent.sourceProgrammeID],
                      let transition = CollegePortalPolicyV1.resolveRetention(
                          for: intent.sourceProgrammeID,
                          programme: programme,
                          using: snapshot
                      ) else { return false }
                return transition.resolutions[intent.playerID]?.outcome == .retained
            }) else {
                expect(false, "the spring fixture produced no retainable portal intent at an idle programme")
                return
            }
            var delegatedControl = try CareerControlSystem.startCollegeCareer(
                at: retainedIntent.sourceProgrammeID,
                in: state
            ).state
            let delegatedStaffID = delegatedControl.programmes[
                retainedIntent.sourceProgrammeID
            ]!.staffIDs.first {
                delegatedControl.staff[$0]?.role != .headCoach
            }!
            expect(CareerControlSystem.setResponsibility(
                .portalAndRetention,
                owner: .delegated(staffID: delegatedStaffID),
                in: &delegatedControl
            ))
            let delegatedSession = try CareerSession(state: delegatedControl)
            _ = try await delegatedSession.resolve(.advanceWeek)
            let delegatedSnapshot = await delegatedSession.snapshot()
            expect(delegatedSnapshot.career.delegatedActivities.contains { activity in
                activity.area == .college(.portalAndRetention)
                    && activity.actorID == delegatedStaffID
                    && activity.action == .portalAndRetention
                    && activity.trigger == .scheduledWeek
            })

            let controlled = try CareerControlSystem.startCollegeCareer(
                at: retainedIntent.sourceProgrammeID,
                in: state
            ).state
            let session = try CareerSession(state: controlled)
            let projection = await session.projection()
            let decision = projection.mandatoryDecisions.first {
                $0.subject == .portalRetention(
                    playerID: retainedIntent.playerID,
                    window: .spring
                )
            }

            expect(decision != nil)
            expectEqual(decision?.deadline, state.calendar)
            expectEqual(decision?.owner, .user)
            expectEqual(decision?.recommendedOptionID, decision?.options.first {
                if case .portalRetention = $0.action { return true }
                return false
            }?.id)
            guard let decision else { return }
            let releaseOption = decision.options.first {
                $0.action == .portalRelease
            }!
            _ = try await session.resolve(.mandatoryDecision(
                decisionID: decision.id,
                optionID: releaseOption.id
            ))
            let afterDecision = await session.projection()
            expect(!afterDecision.mandatoryDecisions.contains(where: {
                $0.id == decision.id
            }))
            for remaining in afterDecision.mandatoryDecisions {
                guard case .portalRetention = remaining.subject,
                      let release = remaining.options.first(where: {
                          $0.action == .portalRelease
                      }) else { continue }
                _ = try await session.resolve(.mandatoryDecision(
                    decisionID: remaining.id,
                    optionID: release.id
                ))
            }
            let resolved = await session.snapshot()
            let releaseResolution = resolved.career.mandatoryDecisionResolutions.first {
                $0.subject == .portalRetention(
                    playerID: retainedIntent.playerID,
                    window: .spring
                )
            }
            expect(releaseResolution != nil)
            expect(releaseResolution?.action == .portalRelease)
            let saved = try await session.saveData()
            let restored = try SaveEnvelope.decode(GameState.self, from: saved)
            let persistedResolution = restored.career.mandatoryDecisionResolutions.first {
                $0.subject == .portalRetention(
                    playerID: retainedIntent.playerID,
                    window: .spring
                )
            }
            expectEqual(persistedResolution?.action, .portalRelease)
        }
    }
}

func runWeeklyAuthorityTests() {
    suite("Weekly preparation authority") {
        testAsync("a user-controlled match week pauses until preparation is authored") {
            let source = GameState.bootstrap(seed: 98_014)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            controlled.calendar = CalendarState(season: 0, week: 3)
            controlled.league.week = 3
            controlled.pending = PendingQueues()
            let session = try CareerSession(state: controlled)

            do {
                _ = try await session.resolve(.advanceWeek)
                expect(false, "a user-controlled week advanced without preparation")
            } catch let error as CareerSessionError {
                expectEqual(error, .missingWeeklyPreparation([.gamePlan, .practicePlan]))
            }

            _ = try await session.resolve(.tacticalPlan(.balanced))
            do {
                _ = try await session.resolve(.advanceWeek)
                expect(false, "a user-controlled week advanced without practice")
            } catch let error as CareerSessionError {
                expectEqual(error, .missingWeeklyPreparation([.practicePlan]))
            }

            _ = try await session.resolve(.practicePlan(.balanced))
            let receipt = try await session.advanceWeek(callInsPerGame: 12)
            expectEqual(receipt.projection.calendar, controlled.calendar)
            expectEqual(await session.snapshot().matchSession?.callInTarget, 12)
            if case .matchStarted = receipt.result {
                expect(true)
            } else {
                expect(false, "prepared week did not start its resumable controlled match")
            }
        }

        test("direct scheduler advancement refuses to abstract a user-controlled fixture") {
            let source = GameState.bootstrap(seed: 98_017)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            controlled.calendar = CalendarState(season: 0, week: 3)
            controlled.league.week = 3
            controlled.pending = PendingQueues()

            do {
                _ = try WorldScheduler.advanceWeek(controlled)
                expect(false, "the direct scheduler abstracted a user-controlled fixture")
            } catch let error as WorldSchedulerError {
                guard case .controlledMatchRequired = error else {
                    expect(false, "wrong scheduler boundary: \(error)")
                    return
                }
                expect(true)
            }
        }

        testAsync("a delayed match action is rejected after the checkpoint advances") {
            let source = GameState.bootstrap(seed: 98_020)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            controlled.calendar = CalendarState(season: 0, week: 3)
            controlled.league.week = 3
            controlled.pending = PendingQueues()
            let session = try CareerSession(state: controlled)
            _ = try await session.resolve(.tacticalPlan(.balanced))
            _ = try await session.resolve(.practicePlan(.balanced))
            _ = try await session.resolve(.advanceWeek)
            let checkpoint = await session.snapshot()
            guard let started = checkpoint.matchSession,
                  let fixtureID = started.fixtureID else {
                expect(false, "prepared week did not install a match checkpoint")
                return
            }
            let oldRevision = started.revision
            _ = try await session.resolveMatch(
                fixtureID: fixtureID,
                revision: oldRevision,
                action: .advance
            )
            do {
                _ = try await session.resolveMatch(
                    fixtureID: fixtureID,
                    revision: oldRevision,
                    action: .togglePause
                )
                expect(false, "a delayed action mutated a newer match checkpoint")
            } catch let error as CareerSessionError {
                expectEqual(error, .staleMatchCheckpoint)
            }
        }

        testAsync("balanced preparation commits both records in one receipt") {
            let source = GameState.bootstrap(seed: 98_015)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            controlled.calendar = CalendarState(season: 0, week: 3)
            controlled.league.week = 3
            controlled.pending = PendingQueues()
            let session = try CareerSession(state: controlled)

            let receipt = try await session.resolve(.prepareWeek)
            if case let .preparationCommitted(organisationID, calendar) = receipt.result {
                expectEqual(organisationID, programmeID)
                expectEqual(calendar, controlled.calendar)
            } else {
                expect(false, "preparation did not return its typed receipt")
            }
            let saved = try await session.saveData()
            let restored = try SaveEnvelope.decode(GameState.self, from: saved)
            expectEqual(
                restored.tactical.plan(for: programmeID, at: restored.calendar),
                .balanced
            )
            expectEqual(
                restored.tactical.practicePlan(for: programmeID, at: restored.calendar),
                .balanced
            )
        }

        testAsync("delegated preparation reaches the same weekly resolver") {
            let source = GameState.bootstrap(seed: 98_016)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            controlled.calendar = CalendarState(season: 0, week: 3)
            controlled.league.week = 3
            controlled.pending = PendingQueues()
            let staffIDs = controlled.programmes[programmeID]!.staffIDs.filter {
                controlled.staff[$0]?.role != .headCoach
            }
            for (index, responsibility) in CollegeCareerResponsibility.allCases.enumerated() {
                expect(CareerControlSystem.setResponsibility(
                    responsibility,
                    owner: .delegated(staffID: staffIDs[index / 2]),
                    in: &controlled
                ))
            }
            let session = try CareerSession(state: controlled)
            let receipt = try await session.resolve(.advanceWeek)
            expect(receipt.projection.calendar != controlled.calendar)
        }

        testAsync("delegated practice and depth chart act without giving the user duplicate authority") {
            let source = GameState.bootstrap(seed: 98_025)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            controlled.calendar = CalendarState(season: 0, week: 3)
            controlled.league.week = 3
            controlled.pending = PendingQueues()
            let staffIDs = controlled.programmes[programmeID]!.staffIDs.filter {
                controlled.staff[$0]?.role != .headCoach
            }
            expect(CareerControlSystem.setResponsibility(
                .practicePlan,
                owner: .delegated(staffID: staffIDs[0]),
                in: &controlled
            ))
            expect(CareerControlSystem.setResponsibility(
                .depthChart,
                owner: .delegated(staffID: staffIDs[0]),
                in: &controlled
            ))
            let session = try CareerSession(state: controlled)

            do {
                _ = try await session.resolve(.practicePlan(.balanced))
                expect(false, "the user replaced a delegated practice plan")
            } catch let error as CareerSessionError {
                expectEqual(error, .responsibilityDelegated)
            }
            do {
                _ = try await session.resolve(.personnelPlan(PersonnelPlan(
                    organisationID: programmeID,
                    calendar: controlled.calendar,
                    overrides: []
                )))
                expect(false, "the user replaced a delegated depth chart")
            } catch let error as CareerSessionError {
                expectEqual(error, .responsibilityDelegated)
            }

            _ = try await session.resolve(.tacticalPlan(.balanced))
            _ = try await session.resolve(.advanceWeek)
            let prepared = await session.snapshot()
            expectEqual(
                prepared.tactical.practicePlan(for: programmeID, at: controlled.calendar),
                .balanced
            )
            expectEqual(
                prepared.tactical.personnelPlan(for: programmeID, at: controlled.calendar),
                PersonnelPlan(
                    organisationID: programmeID,
                    calendar: controlled.calendar,
                    overrides: []
                )
            )
        }

        testAsync("cruise advances delegated weeks to a bounded persisted endpoint") {
            func fixture() throws -> GameState {
                let source = GameState.bootstrap(seed: 98_027)
                let programmeID = source.programmes.ids[0]
                var state = try CareerControlSystem.startCollegeCareer(
                    at: programmeID,
                    in: source
                ).state
                state.calendar = CalendarState(season: 0, week: 3)
                state.league.week = 3
                state.pending = PendingQueues()
                let staffIDs = state.programmes[programmeID]!.staffIDs.filter {
                    state.staff[$0]?.role != .headCoach
                }
                for (index, responsibility) in CollegeCareerResponsibility.allCases.enumerated() {
                    expect(CareerControlSystem.setResponsibility(
                        responsibility,
                        owner: .delegated(staffID: staffIDs[index / 2]),
                        in: &state
                    ))
                }
                return state
            }

            let first = try CareerSession(state: fixture())
            let second = try CareerSession(state: fixture())
            let end = CalendarState(season: 0, week: 4)
            let firstReceipt = try await first.resolve(.startCruise(requestedEnd: end))
            let secondReceipt = try await second.resolve(.startCruise(requestedEnd: end))
            expectEqual(firstReceipt, secondReceipt)
            expectEqual(firstReceipt.projection.calendar, end)
            expectEqual(firstReceipt.projection.whileAway.cruise?.status, .completed)
            expectEqual(
                firstReceipt.projection.whileAway.cruise?.stopReason,
                .requestedEnd
            )
            expect(!firstReceipt.projection.whileAway.activities.isEmpty)
            let saved = try await first.saveData()
            let restored = try SaveEnvelope.decode(GameState.self, from: saved)
            expectEqual(restored.career.cruise, firstReceipt.projection.whileAway.cruise)
            expectEqual(try await second.saveData(), saved)

            let outOfRange = try CareerSession(state: fixture())
            do {
                _ = try await outOfRange.resolve(.startCruise(
                    requestedEnd: CalendarState(season: 2, week: 14)
                ))
                expect(false, "cruise accepted more than its 52-week bound")
            } catch let error as CareerSessionError {
                expectEqual(error, .invalidState)
            }
        }

        testAsync("cruise stops before a mandatory player decision") {
            let source = GameState.bootstrap(seed: 98_028)
            let programmeID = source.programmes.ids[0]
            var controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let staffIDs = controlled.programmes[programmeID]!.staffIDs.filter {
                controlled.staff[$0]?.role != .headCoach
            }
            for (index, responsibility) in CollegeCareerResponsibility.allCases.enumerated() {
                guard responsibility != .recruiting else { continue }
                expect(CareerControlSystem.setResponsibility(
                    responsibility,
                    owner: .delegated(staffID: staffIDs[index / 2]),
                    in: &controlled
                ))
            }
            let prospectID = controlled.prospects.ids[0]
            let decisionID = UUID(uuidString: "00000000-0000-4000-8000-000000000F28")!
            let optionA = UUID(uuidString: "00000000-0000-4000-8000-000000000F29")!
            let optionB = UUID(uuidString: "00000000-0000-4000-8000-000000000F2A")!
            expect(controlled.pending.enqueue(MandatoryDecision(
                id: decisionID,
                programmeID: programmeID,
                subject: .recruiting(prospectID: prospectID),
                createdAt: controlled.calendar,
                deadline: controlled.calendar,
                owner: .user,
                options: [
                    MandatoryDecisionOption(id: optionA, action: .recruiting(.addToBoard)),
                    MandatoryDecisionOption(id: optionB, action: .recruiting(.withdraw)),
                ],
                recommendedOptionID: optionA,
                reasons: [MandatoryDecisionReason(code: .deadline, value: 1)]
            )))
            let session = try CareerSession(state: controlled)

            let receipt = try await session.resolve(.startCruise(
                requestedEnd: controlled.calendar.advancedWeek()
            ))
            expectEqual(receipt.projection.calendar, controlled.calendar)
            expectEqual(receipt.projection.whileAway.cruise?.status, .stopped)
            expectEqual(
                receipt.projection.whileAway.cruise?.stopReason,
                .mandatoryDecision
            )

            let saved = try await session.saveData()
            let restored = try SaveEnvelope.decode(GameState.self, from: saved)
            let resumed = try CareerSession(state: restored)
            _ = try await resumed.resolve(.mandatoryDecision(
                decisionID: decisionID,
                optionID: optionA
            ))
            _ = try await resumed.resolve(.setResponsibility(
                responsibility: .recruiting,
                owner: .delegated(staffID: staffIDs[0])
            ))
            let completed = try await resumed.resolve(.continueCruise)
            expectEqual(completed.projection.calendar, controlled.calendar.advancedWeek())
            expectEqual(completed.projection.whileAway.cruise?.status, .completed)
            expectEqual(completed.projection.whileAway.cruise?.stopReason, .requestedEnd)
            expectEqual(
                Set(completed.projection.whileAway.activities.map(\.id)).count,
                completed.projection.whileAway.activities.count
            )
        }
    }
}

func runProfessionalCareerSessionTests() {
    suite("Professional career session") {
        testAsync("promotion opens a professional projection and persists its tactical plan") {
            let source = GameState.bootstrap(seed: 98_013)
            let programmeID = source.programmes.ids[0]
            let controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let team = controlled.proTeams.values[0]
            let opportunity = CareerOpportunity(
                id: UUID(uuidString: "00000000-0000-4000-8000-000000000F02")!,
                organisationID: team.id,
                tier: .professional,
                offeredAt: controlled.calendar,
                expiresAt: controlled.calendar.advancedWeek(),
                prestige: team.prestige,
                rationale: .staffRecommendation
            )
            var candidate = controlled
            candidate.careerArc = CareerArcState(
                currentJob: CareerJob(
                    organisationID: programmeID,
                    tier: .college,
                    startedAt: candidate.calendar
                ),
                opportunities: [opportunity],
                status: .employed
            )
            let promoted = try IntentResolver.resolve(
                .career(CareerArcRequest(
                    calendar: candidate.calendar,
                    action: .acceptOpportunity(opportunityID: opportunity.id)
                )),
                in: candidate
            ).state
            let session = try CareerSession(state: promoted)
            expectEqual(promoted.career.coachID, controlled.career.college?.coachID)
            expectEqual(promoted.career.pro?.teamID, team.id)
            expectEqual(promoted.career.pro?.coachID, promoted.career.coachID)
            expectEqual(
                Set(promoted.career.pro?.responsibilityOwners.map(\.key) ?? []),
                Set(ProCareerResponsibility.allCases)
            )
            expect(promoted.career.pro?.responsibilityOwners.values.allSatisfy {
                $0 == .user
            } ?? false)
            let projection = await session.projection()
            expectEqual(projection.tier, .professional)
            expectEqual(projection.programme?.id, team.id)
            expect(projection.recruitingBoard.isEmpty)
            expect(projection.mandatoryDecisions.isEmpty)
            expectEqual(projection.responsibilities.count, ProCareerResponsibility.allCases.count)
            expectEqual(
                Set(projection.responsibilities.compactMap { item in
                    if case let .professional(responsibility) = item.area {
                        return responsibility
                    }
                    return nil
                }),
                Set(ProCareerResponsibility.allCases)
            )

            _ = try await session.resolve(.tacticalPlan(.balanced))
            let saved = try await session.saveData()
            let restored = try SaveEnvelope.decode(GameState.self, from: saved)
            expectEqual(restored.tactical.plan(for: team.id, at: restored.calendar), .balanced)
            expectEqual(restored.career.pro, promoted.career.pro)
            expect(WorldIntegrity.check(restored).isValid)
        }

        test("professional delegation uses employed staff and the shared capacity bound") {
            let source = GameState.bootstrap(seed: 98_024)
            let programmeID = source.programmes.ids[0]
            let controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let team = controlled.proTeams.values[0]
            let opportunity = CareerOpportunity(
                id: UUID(uuidString: "00000000-0000-4000-8000-000000000F24")!,
                organisationID: team.id,
                tier: .professional,
                offeredAt: controlled.calendar,
                expiresAt: controlled.calendar.advancedWeek(),
                prestige: team.prestige,
                rationale: .staffRecommendation
            )
            var candidate = controlled
            candidate.careerArc = CareerArcState(
                currentJob: CareerJob(
                    organisationID: programmeID,
                    tier: .college,
                    startedAt: candidate.calendar
                ),
                opportunities: [opportunity],
                status: .employed
            )
            var promoted = try IntentResolver.resolve(
                .career(CareerArcRequest(
                    calendar: candidate.calendar,
                    action: .acceptOpportunity(opportunityID: opportunity.id)
                )),
                in: candidate
            ).state
            let staffID = promoted.proTeams[team.id]!.staffIDs.first {
                promoted.staff[$0]?.role != .headCoach
            }!
            let outsiderID = promoted.proTeams.values.first { $0.id != team.id }!.staffIDs[0]

            expect(CareerControlSystem.setProResponsibility(
                .scouting,
                owner: .delegated(staffID: staffID),
                in: &promoted
            ))
            expect(CareerControlSystem.setProResponsibility(
                .rosterManagement,
                owner: .delegated(staffID: staffID),
                in: &promoted
            ))
            expect(!CareerControlSystem.setProResponsibility(
                .contractNegotiations,
                owner: .delegated(staffID: staffID),
                in: &promoted
            ))
            expect(!CareerControlSystem.setProResponsibility(
                .gamePlan,
                owner: .delegated(staffID: outsiderID),
                in: &promoted
            ))
            expect(WorldIntegrity.check(promoted).isValid)
        }

        testAsync("professional delegated areas reject duplicate user actions") {
            let source = GameState.bootstrap(seed: 98_026)
            let programmeID = source.programmes.ids[0]
            let controlled = try CareerControlSystem.startCollegeCareer(
                at: programmeID,
                in: source
            ).state
            let team = controlled.proTeams.values[0]
            let opportunity = CareerOpportunity(
                id: UUID(uuidString: "00000000-0000-4000-8000-000000000F26")!,
                organisationID: team.id,
                tier: .professional,
                offeredAt: controlled.calendar,
                expiresAt: controlled.calendar.advancedWeek(),
                prestige: team.prestige,
                rationale: .staffRecommendation
            )
            var candidate = controlled
            candidate.careerArc = CareerArcState(
                currentJob: CareerJob(
                    organisationID: programmeID,
                    tier: .college,
                    startedAt: candidate.calendar
                ),
                opportunities: [opportunity],
                status: .employed
            )
            let promoted = try IntentResolver.resolve(
                .career(CareerArcRequest(
                    calendar: candidate.calendar,
                    action: .acceptOpportunity(opportunityID: opportunity.id)
                )),
                in: candidate
            ).state
            let staffID = promoted.proTeams[team.id]!.staffIDs.first {
                promoted.staff[$0]?.role != .headCoach
            }!
            let session = try CareerSession(state: promoted)
            _ = try await session.resolve(.setProResponsibility(
                responsibility: .gamePlan,
                owner: .delegated(staffID: staffID)
            ))
            _ = try await session.resolve(.setProResponsibility(
                responsibility: .practicePlan,
                owner: .delegated(staffID: staffID)
            ))

            do {
                _ = try await session.resolve(.tacticalPlan(.balanced))
                expect(false, "the user replaced a delegated professional game plan")
            } catch let error as CareerSessionError {
                expectEqual(error, .responsibilityDelegated)
            }
            do {
                _ = try await session.resolve(.practicePlan(.balanced))
                expect(false, "the user replaced a delegated professional practice plan")
            } catch let error as CareerSessionError {
                expectEqual(error, .responsibilityDelegated)
            }
        }
    }
}
