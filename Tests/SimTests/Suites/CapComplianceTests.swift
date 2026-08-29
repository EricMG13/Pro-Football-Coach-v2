import Foundation
import FootballSimCore

private enum CapComplianceTestError: Error { case missingFixture }

func runCapComplianceTests() {
    suite("Cap compliance: event plumbing") {
        test("a compliance release headline names the team and the player") {
            let playerID = UUID(uuidString: "00000000-0000-4000-8000-0000000CA001")!
            let teamID = UUID(uuidString: "00000000-0000-4000-8000-0000000CA002")!
            let payload = DomainEventPayload.proCapComplianceRelease(
                playerID: playerID,
                teamID: teamID,
                deadMoneyAdded: 500
            )
            expectEqual(payload.historicalWeight, 20)
            expectEqual(Set(payload.referencedEntityIDs), Set([playerID, teamID]))
        }
    }

    suite("Cap compliance: enforcement") {
        test("season-boundary discharge clears every team's dead money") {
            var state = GameState.bootstrap(seed: 62_007)
            let teamIDs = Array(state.proTeams.ids.prefix(2))
            _ = state.proTeams.update(teamIDs[0]) { $0.deadMoney = 1 }
            _ = state.proTeams.update(teamIDs[1]) { $0.deadMoney = 25_000_000 }

            let discharged = ProManagementSystem.dischargeDeadMoney(in: state)
            expect(discharged.proTeams.values.allSatisfy { $0.deadMoney == 0 },
                   "season-boundary discharge left dead money on the books")
        }

        test("compliance releases the cheapest dead money first, and stops once legal") {
            var state = GameState.bootstrap(seed: 62_001)
            let teamID = state.proTeams.ids[0]
            guard let team = state.proTeams[teamID], team.rosterIDs.count >= 2 else {
                expect(false, "the fixture team has fewer than two rostered players")
                return
            }
            // A clean baseline: every contract this team holds is stripped, so the numbers below
            // are exact rather than layered on whatever bootstrap happened to sign.
            for playerID in team.rosterIDs + team.practiceSquadIDs {
                state.players.update(playerID) { $0.contract = nil }
            }
            _ = state.proTeams.update(teamID) { $0.deadMoney = 0 }

            let capLimit = ProRules.salaryCap(seasonsAfterBase: state.calendar.season)
            let halfCap = capLimit / 2
            let cheapID = team.rosterIDs[0]
            let costlyID = team.rosterIDs[1]
            // Both contracts are legal alone (each capHit is roughly half the cap); together
            // they push the team over. Releasing either alone legalises the team, so the only
            // thing that decides which one goes is dead money: cheap carries 500, costly 50,000.
            // Signing bonuses divide evenly by the 5-year proration so the arithmetic is exact.
            state.players.update(cheapID) {
                $0.contract = Contract(
                    years: 5,
                    baseSalaryByYear: Array(repeating: halfCap - 1_000, count: 5),
                    signingBonus: 500
                )
            }
            state.players.update(costlyID) {
                $0.contract = Contract(
                    years: 5,
                    baseSalaryByYear: Array(repeating: halfCap - 1_000, count: 5),
                    signingBonus: 50_000
                )
            }

            let before = try ProManagementSystem.capSnapshot(teamID: teamID, in: state)
            expect(!before.isWithinCap, "the fixture is not actually over cap")

            let receipt = try ProManagementSystem.enforceCapCompliance(
                at: state.calendar,
                in: state
            )
            expectEqual(receipt.releases.map(\.playerID), [cheapID])
            expectEqual(receipt.releases.first?.deadMoneyAdded, 500)
            expectEqual(receipt.releases.first?.teamID, teamID)

            let after = try ProManagementSystem.capSnapshot(teamID: teamID, in: receipt.state)
            expect(after.isWithinCap, "the team is still over cap after compliance")
            expect(receipt.state.players[costlyID]?.contract != nil,
                   "the costly contract was released even though the cheap one alone sufficed")
            expect(receipt.state.players[cheapID]?.contract == nil)
            expect(receipt.state.proTeams[teamID]?.rosterIDs.contains(cheapID) != true)
            expect(receipt.state.proMarket.freeAgentIDs.contains(cheapID))
            expectEqual(receipt.state.proTeams[teamID]?.deadMoney, 500)
            expect(WorldIntegrity.check(receipt.state).isValid)
        }

        test("compliance never releases a deal whose release costs more cap than it sheds") {
            // A bonus-heavy deal releases *badly*: dead money accelerates every unamortised bonus
            // dollar into this season, while the cap hit it sheds is one season's proration plus
            // base. When the acceleration is the larger number the release moves the team further
            // over the cap, and "cheapest dead money first" walks straight into it, because a deal
            // with almost no bonus left to accelerate is also the cheapest dead money on the books.
            var state = GameState.bootstrap(seed: 62_005)
            let teamID = state.proTeams.ids[0]
            guard let team = state.proTeams[teamID], team.rosterIDs.count >= 2 else {
                expect(false, "the fixture team has fewer than two rostered players")
                return
            }
            for playerID in team.rosterIDs + team.practiceSquadIDs {
                state.players.update(playerID) { $0.contract = nil }
            }
            _ = state.proTeams.update(teamID) { $0.deadMoney = 0 }

            let capLimit = ProRules.salaryCap(seasonsAfterBase: state.calendar.season)
            let trapID = team.rosterIDs[0]
            let payerID = team.rosterIDs[1]
            // trap: no base, a 5-dollar bonus over five years. Cap hit 1, dead money 5 — the
            // cheapest dead money on the roster, and releasing it *adds* 4 dollars of cap.
            state.players.update(trapID) {
                $0.contract = Contract(
                    years: 5,
                    baseSalaryByYear: Array(repeating: 0, count: 5),
                    signingBonus: 5,
                    signedSeason: state.calendar.season
                )
            }
            // payer: the deal that actually puts the team over, and the only one whose release
            // sheds more than it accelerates.
            state.players.update(payerID) {
                $0.contract = Contract(
                    years: 5,
                    baseSalaryByYear: [capLimit] + Array(repeating: 0, count: 4),
                    signingBonus: 5_000_000,
                    signedSeason: state.calendar.season
                )
            }

            let before = try ProManagementSystem.capSnapshot(teamID: teamID, in: state)
            expectEqual(before.committedCap, capLimit + 1_000_001)
            expect(!before.isWithinCap, "the fixture is not actually over cap")

            let receipt = try ProManagementSystem.enforceCapCompliance(
                at: state.calendar,
                in: state
            )
            expectEqual(receipt.releases.map(\.playerID), [payerID])
            expect(receipt.state.players[trapID]?.contract != nil,
                   "the trap deal was released even though releasing it raised the cap")
            let after = try ProManagementSystem.capSnapshot(teamID: teamID, in: receipt.state)
            expect(after.isWithinCap, "the team is still over cap after compliance")
            expect(after.committedCap < before.committedCap,
                   "compliance did not reduce committed cap")
            expect(WorldIntegrity.check(receipt.state).isValid)
        }

        test("compliance preserves the last playable body at every position") {
            var state = GameState.bootstrap(seed: 62_006)
            let teamID = state.proTeams.ids[0]
            guard let team = state.proTeams[teamID],
                  let kickerID = team.rosterIDs.first(where: {
                      state.players[$0]?.position == .kicker
                  }),
                  let payerID = team.rosterIDs.first(where: {
                      state.players[$0]?.position == .wideReceiver
                  }) else {
                expect(false, "the fixture team lacks a kicker or receiver")
                return
            }
            for playerID in team.rosterIDs + team.practiceSquadIDs {
                state.players.update(playerID) { $0.contract = nil }
            }
            _ = state.proTeams.update(teamID) { $0.deadMoney = 0 }

            let capLimit = ProRules.salaryCap(seasonsAfterBase: state.calendar.season)
            state.players.update(kickerID) {
                $0.contract = Contract(
                    years: 1,
                    baseSalaryByYear: [1],
                    signingBonus: 0,
                    signedSeason: state.calendar.season
                )
            }
            state.players.update(payerID) {
                $0.contract = Contract(
                    years: 5,
                    baseSalaryByYear: [capLimit - 1] + Array(repeating: 0, count: 4),
                    signingBonus: 5,
                    signedSeason: state.calendar.season
                )
            }

            let receipt = try ProManagementSystem.enforceCapCompliance(
                at: state.calendar,
                in: state
            )
            expectEqual(receipt.releases.map(\.playerID), [payerID])
            expect(receipt.state.proTeams[teamID]?.rosterIDs.contains(kickerID) == true,
                   "compliance released the team's last kicker")
            expect(WorldIntegrity.check(receipt.state).isValid)
        }

        test("a team already within the cap is untouched") {
            let state = GameState.bootstrap(seed: 62_002)
            let receipt = try ProManagementSystem.enforceCapCompliance(
                at: state.calendar,
                in: state
            )
            expect(receipt.releases.isEmpty, "a legal bootstrap world had releases forced on it")
            expectEqual(
                try SaveEnvelope.encode(receipt.state),
                try SaveEnvelope.encode(state)
            )
        }

        test("a team with no releasable path to legality throws rather than persists") {
            var state = GameState.bootstrap(seed: 62_003)
            let teamID = state.proTeams.ids[0]
            guard let team = state.proTeams[teamID], let onlyPlayerID = team.rosterIDs.first else {
                expect(false, "the fixture team has no rostered players")
                return
            }
            for playerID in team.rosterIDs + team.practiceSquadIDs where playerID != onlyPlayerID {
                _ = state.proTeams.update(teamID) { squad in
                    squad.rosterIDs.removeAll { $0 == playerID }
                    squad.practiceSquadIDs.removeAll { $0 == playerID }
                }
            }
            // Dead money already on the books, alone, exceeds the cap. No release of the one
            // remaining contracted player can ever bring committedCap back under the limit,
            // because releasing it only adds more dead money on top.
            let capLimit = ProRules.salaryCap(seasonsAfterBase: state.calendar.season)
            _ = state.proTeams.update(teamID) { $0.deadMoney = capLimit + 1 }
            state.players.update(onlyPlayerID) {
                $0.contract = Contract(years: 1, baseSalaryByYear: [1], signingBonus: 0)
            }

            do {
                _ = try ProManagementSystem.enforceCapCompliance(at: state.calendar, in: state)
                expect(false, "an unfixable over-cap team did not throw")
            } catch ProManagementError.capExceeded {
                expect(true)
            } catch {
                expect(false, "wrong error: \(error)")
            }
        }

        test("the controlled team is never auto-released from") {
            var state = GameState.bootstrap(seed: 62_004)
            let teamID = state.proTeams.ids[0]
            guard let team = state.proTeams[teamID], team.rosterIDs.count >= 1 else {
                expect(false, "the fixture team has no rostered players")
                return
            }
            state.careerArc = CareerArcState(
                currentJob: CareerJob(
                    organisationID: teamID,
                    tier: .professional,
                    startedAt: state.calendar
                ),
                status: .employed
            )
            let capLimit = ProRules.salaryCap(seasonsAfterBase: state.calendar.season)
            let overCapPlayerID = team.rosterIDs[0]
            state.players.update(overCapPlayerID) {
                $0.contract = Contract(
                    years: 1,
                    baseSalaryByYear: [capLimit + 1_000_000],
                    signingBonus: 0
                )
            }

            let receipt = try ProManagementSystem.enforceCapCompliance(
                at: state.calendar,
                in: state
            )
            expect(receipt.releases.isEmpty, "the controlled team was released from")
            expect(receipt.state.players[overCapPlayerID]?.contract != nil,
                   "the controlled team's over-cap contract was force-released")
        }
    }

    suite("Cap compliance: controlled-team authority") {
        @Sendable func unwrap<T>(_ value: T?) throws -> T {
            guard let value else { throw CapComplianceTestError.missingFixture }
            return value
        }

        @Sendable func controlledFixture(seed: UInt64) throws -> (GameState, UUID) {
            var state = GameState.bootstrap(seed: seed)
            let teamID = try unwrap(state.proTeams.ids.first)
            let coachID = try unwrap(state.proTeams[teamID]?.staffIDs.first {
                state.staff[$0]?.role == .headCoach
            })
            state.career = CareerControlState(pro: ProCareerControl(
                coachID: coachID,
                teamID: teamID,
                startedAt: state.calendar
            ))
            state.careerArc = CareerArcState(
                currentJob: CareerJob(
                    organisationID: teamID,
                    tier: .professional,
                    startedAt: state.calendar
                ),
                status: .employed
            )
            return (state, teamID)
        }

        @Sendable func releasablePlayerIDs(
            count: Int,
            teamID: UUID,
            state: GameState
        ) throws -> [UUID] {
            let team = try unwrap(state.proTeams[teamID])
            var remainingByPosition = Dictionary(
                grouping: team.rosterIDs.compactMap { state.players[$0] },
                by: \Player.position
            ).mapValues(\.count)
            var selected: [UUID] = []
            for playerID in team.rosterIDs {
                guard let position = state.players[playerID]?.position,
                      remainingByPosition[position, default: 0]
                        > (SharedRules.minimumPlayableRosterByPosition[position] ?? 0) else {
                    continue
                }
                selected.append(playerID)
                remainingByPosition[position, default: 0] -= 1
                if selected.count == count { return selected }
            }
            throw CapComplianceTestError.missingFixture
        }

        test("a controlled over-cap root persists one decision and exact release arithmetic") {
            var (state, teamID) = try controlledFixture(seed: 62_008)
            let playerID = try releasablePlayerIDs(count: 1, teamID: teamID, state: state)[0]
            let team = try unwrap(state.proTeams[teamID])
            for rosteredID in team.rosterIDs + team.practiceSquadIDs {
                state.players.update(rosteredID) { $0.contract = nil }
            }
            let capLimit = ProRules.salaryCap(seasonsAfterBase: state.calendar.season)
            state.players.update(playerID) {
                $0.contract = Contract(
                    years: 5,
                    baseSalaryByYear: [capLimit + 1_000_000] + Array(repeating: 0, count: 4),
                    signingBonus: 500,
                    signedSeason: state.calendar.season
                )
            }

            state = ProCapComplianceSystem.refresh(in: state)
            let decision = try unwrap(state.pending.professionalCapCompliance)
            expectEqual(decision.teamID, teamID)
            expect(WorldIntegrity.check(state).isValid)

            let projection = try ProCapComplianceSystem.projection(teamID: teamID, in: state)
            let release = try unwrap(projection.actions.first {
                $0.playerID == playerID && $0.kind == .release
            })
            expect(release.isEligible)
            expectEqual(release.currentCapHit, capLimit + 1_000_100)
            expectEqual(release.projectedDeadMoney, 500)
            expectEqual(release.projectedRemainingCap, capLimit - 500)
            expectEqual(
                release.action,
                .management(.release(playerID: playerID, teamID: teamID))
            )
            let restructure = try unwrap(projection.actions.first {
                $0.playerID == playerID && $0.kind == .restructure
            })
            expect(!restructure.isEligible)
            expect(restructure.unavailableReason?.contains("undefined") == true)
            expectEqual(restructure.projectedRemainingCap, nil)
            expectEqual(restructure.projectedDeadMoney, nil)

            let restored = try SaveEnvelope.decode(
                GameState.self,
                from: SaveEnvelope.encode(state)
            )
            expectEqual(restored.pending.professionalCapCompliance, decision)
            expectEqual(
                ProCapComplianceSystem.refresh(in: restored).pending.professionalCapCompliance,
                decision
            )
        }

        test("a release cannot create or worsen cap noncompliance") {
            var (state, teamID) = try controlledFixture(seed: 62_012)
            let playerID = try releasablePlayerIDs(count: 1, teamID: teamID, state: state)[0]
            let team = try unwrap(state.proTeams[teamID])
            for rosteredID in team.rosterIDs + team.practiceSquadIDs {
                state.players.update(rosteredID) { $0.contract = nil }
            }
            let capLimit = ProRules.salaryCap(seasonsAfterBase: state.calendar.season)
            state.players.update(playerID) {
                $0.contract = Contract(
                    years: 5,
                    baseSalaryByYear: Array(repeating: 0, count: 5),
                    signingBonus: capLimit * 2,
                    signedSeason: state.calendar.season
                )
            }
            let before = try SaveEnvelope.encode(state)
            let release = try unwrap(
                ProCapComplianceSystem.projection(teamID: teamID, in: state).actions.first {
                    $0.playerID == playerID && $0.kind == .release
                }
            )
            expect(!release.isEligible)
            expect(release.unavailableReason?.contains("salary cap") == true)

            do {
                _ = try ProManagementSystem.release(playerID: playerID, from: teamID, in: state)
                expect(false, "a release was allowed to create cap noncompliance")
            } catch ProManagementError.capExceeded {
                expectEqual(try SaveEnvelope.encode(state), before)
            } catch {
                expect(false, "wrong release refusal: \(error)")
            }
        }

        test("a controlled next-season overage becomes one blocking decision") {
            var state = GameState.bootstrap(seed: 62_013)
            for _ in 0..<(SharedRules.inSeasonWeeks - 1) {
                state = try WorldScheduler.advanceWeek(state).state
            }
            let playingIDs = Set(state.competition.currentSchedule.games
                .filter {
                    $0.season == state.calendar.season
                        && $0.week == state.calendar.week
                        && $0.result == nil
                        && $0.tier == .pro
                }
                .flatMap { [$0.homeID, $0.awayID] })
            let teamID = try unwrap(state.proTeams.ids.first {
                !playingIDs.contains($0)
            })
            let team = try unwrap(state.proTeams[teamID])
            let coachID = try unwrap(team.staffIDs.first {
                state.staff[$0]?.role == .headCoach
            })
            let playerID = try unwrap(team.rosterIDs.first)
            state.career = CareerControlState(pro: ProCareerControl(
                coachID: coachID,
                teamID: teamID,
                startedAt: state.calendar
            ))
            state.careerArc = CareerArcState(
                currentJob: CareerJob(
                    organisationID: teamID,
                    tier: .professional,
                    startedAt: state.calendar
                ),
                status: .employed
            )
            for rosteredID in team.rosterIDs + team.practiceSquadIDs {
                state.players.update(rosteredID) { $0.contract = nil }
            }
            let nextCap = ProRules.salaryCap(seasonsAfterBase: state.calendar.season + 1)
            state.players.update(playerID) {
                $0.contract = Contract(
                    years: 2,
                    baseSalaryByYear: [1, nextCap + 1],
                    signingBonus: 0,
                    signedSeason: state.calendar.season
                )
            }
            expect(WorldIntegrity.check(state).isValid)

            let transition = try WorldScheduler.advanceWeek(state)
            let decision = transition.state.pending.professionalCapCompliance
            expectEqual(decision?.teamID, teamID)
            expectEqual(decision?.createdAt, transition.state.calendar)
            expect(
                try !ProManagementSystem.capSnapshot(
                    teamID: teamID,
                    in: transition.state
                ).isWithinCap
            )
            expect(WorldIntegrity.check(transition.state).isValid)
            do {
                _ = try WorldScheduler.advanceWeek(transition.state)
                expect(false, "the next-season cap decision did not block week advance")
            } catch WorldSchedulerError.unresolvedProfessionalCapCompliance(teamID) {
                expect(true)
            } catch {
                expect(false, "wrong cap-decision refusal: \(error)")
            }
        }

        testAsync("multi-release compliance survives reload and blocks advance until legal") {
            var (state, teamID) = try controlledFixture(seed: 62_009)
            let playerIDs = try releasablePlayerIDs(count: 3, teamID: teamID, state: state)
            let team = try unwrap(state.proTeams[teamID])
            for rosteredID in team.rosterIDs + team.practiceSquadIDs {
                state.players.update(rosteredID) { $0.contract = nil }
            }
            let capLimit = ProRules.salaryCap(seasonsAfterBase: state.calendar.season)
            for playerID in playerIDs {
                state.players.update(playerID) {
                    $0.contract = Contract(
                        years: 1,
                        baseSalaryByYear: [capLimit * 3 / 5],
                        signingBonus: 0,
                        signedSeason: state.calendar.season
                    )
                }
            }
            state = ProCapComplianceSystem.refresh(in: state)
            let decisionID = try unwrap(state.pending.professionalCapCompliance?.id)

            do {
                _ = try WorldScheduler.advanceWeek(state)
                expect(false, "an unresolved cap decision did not block direct week advance")
            } catch WorldSchedulerError.unresolvedProfessionalCapCompliance(teamID) {
                expect(true)
            } catch {
                expect(false, "wrong advance refusal: \(error)")
            }

            let session = try CareerSession(state: state)
            _ = try await session.resolve(.proManagement(.release(
                playerID: playerIDs[0],
                teamID: teamID
            )))
            let afterFirst = await session.snapshot()
            expectEqual(afterFirst.pending.professionalCapCompliance?.id, decisionID)
            expect(
                try !ProManagementSystem.capSnapshot(teamID: teamID, in: afterFirst).isWithinCap,
                "the fixture unexpectedly became legal after one release"
            )

            let restored = try SaveEnvelope.decode(
                GameState.self,
                from: await session.saveData()
            )
            expect(restored.proTeams[teamID]?.rosterIDs.contains(playerIDs[0]) == false)
            expectEqual(restored.pending.professionalCapCompliance?.id, decisionID)
            let resumed = try CareerSession(state: restored)
            _ = try await resumed.resolve(.proManagement(.release(
                playerID: playerIDs[1],
                teamID: teamID
            )))
            let legal = await resumed.snapshot()
            expectEqual(legal.pending.professionalCapCompliance, nil)
            expect(try ProManagementSystem.capSnapshot(teamID: teamID, in: legal).isWithinCap)
            expect(legal.proTeams[teamID]?.rosterIDs.contains(playerIDs[0]) == false)
            expect(legal.proTeams[teamID]?.rosterIDs.contains(playerIDs[1]) == false)
            expect(WorldIntegrity.check(legal).isValid)
        }

        testAsync("a progressive extension can reduce an overage before a final release") {
            var (state, teamID) = try controlledFixture(seed: 62_011)
            let playerIDs = try releasablePlayerIDs(count: 2, teamID: teamID, state: state)
            let team = try unwrap(state.proTeams[teamID])
            for rosteredID in team.rosterIDs + team.practiceSquadIDs {
                state.players.update(rosteredID) { $0.contract = nil }
            }
            let capLimit = ProRules.salaryCap(seasonsAfterBase: state.calendar.season)
            for playerID in playerIDs {
                state.players.update(playerID) {
                    $0.contract = Contract(
                        years: 1,
                        baseSalaryByYear: [capLimit * 4 / 5],
                        signingBonus: 0,
                        signedSeason: state.calendar.season
                    )
                }
            }
            state = ProCapComplianceSystem.refresh(in: state)
            let negotiation = try ProManagementSystem.beginNegotiation(
                playerID: playerIDs[0],
                teamID: teamID,
                offer: Contract(
                    years: 1,
                    baseSalaryByYear: [capLimit / 2],
                    signingBonus: 0
                ),
                deadline: state.calendar.advancedWeek(),
                in: state
            )
            let extensionRow = try unwrap(
                ProCapComplianceSystem.projection(teamID: teamID, in: negotiation.state)
                    .actions.first {
                        $0.playerID == playerIDs[0] && $0.kind == .extendContract
                    }
            )
            expect(extensionRow.isEligible)
            expect((extensionRow.projectedRemainingCap ?? 0) < 0)

            let session = try CareerSession(state: negotiation.state)
            _ = try await session.resolve(.proManagement(.acceptNegotiation(
                negotiationID: negotiation.negotiation.id
            )))
            let improved = await session.snapshot()
            let improvedCap = try ProManagementSystem.capSnapshot(teamID: teamID, in: improved)
            expect(!improvedCap.isWithinCap)
            expect(improved.pending.professionalCapCompliance != nil)

            _ = try await session.resolve(.proManagement(.release(
                playerID: playerIDs[1],
                teamID: teamID
            )))
            let legal = await session.snapshot()
            expect(try ProManagementSystem.capSnapshot(teamID: teamID, in: legal).isWithinCap)
            expectEqual(legal.pending.professionalCapCompliance, nil)
        }

        test("extension, promotion, and waiver rows compose existing executable actions") {
            var (state, teamID) = try controlledFixture(seed: 62_010)
            let playerID = try releasablePlayerIDs(count: 1, teamID: teamID, state: state)[0]
            let before = try ProManagementSystem.capSnapshot(teamID: teamID, in: state)
            let offer = Contract(
                years: 2,
                baseSalaryByYear: [1_000_000, 1_000_000],
                signingBonus: 200_000
            )
            let negotiation = try ProManagementSystem.beginNegotiation(
                playerID: playerID,
                teamID: teamID,
                offer: offer,
                deadline: state.calendar.advancedWeek(),
                in: state
            )
            state = try ProMarketSystem.moveToPracticeSquad(
                playerID: playerID,
                teamID: teamID,
                in: negotiation.state
            )

            let projection = try ProCapComplianceSystem.projection(teamID: teamID, in: state)
            let extensionRow = try unwrap(projection.actions.first {
                $0.playerID == playerID && $0.kind == .extendContract
            })
            let currentHit = try unwrap(state.players[playerID]?.contract)
                .capHit(atSeason: state.calendar.season)
            expect(extensionRow.isEligible)
            expectEqual(extensionRow.currentCapHit, currentHit)
            expectEqual(extensionRow.projectedDeadMoney, before.deadMoney)
            expectEqual(
                extensionRow.projectedRemainingCap,
                before.remainingCap + currentHit - offer.capHit(inYear: 0)
            )
            expectEqual(
                extensionRow.action,
                .management(.acceptNegotiation(negotiationID: negotiation.negotiation.id))
            )

            let promotion = try unwrap(projection.actions.first {
                $0.playerID == playerID && $0.kind == .promoteFromPracticeSquad
            })
            expect(promotion.isEligible)
            expectEqual(promotion.projectedRemainingCap, before.remainingCap)
            expectEqual(promotion.projectedDeadMoney, before.deadMoney)
            expectEqual(
                promotion.action,
                .market(.promoteFromPracticeSquad(playerID: playerID, teamID: teamID))
            )
            let waiver = try unwrap(projection.actions.first {
                $0.playerID == playerID && $0.kind == .placeOnWaivers
            })
            expect(waiver.isEligible)
            expectEqual(waiver.projectedRemainingCap, before.remainingCap)
            expectEqual(waiver.projectedDeadMoney, before.deadMoney)
            expectEqual(
                waiver.action,
                .market(.placeOnWaivers(playerID: playerID, teamID: teamID))
            )
        }
    }
}
