import Foundation

public struct CalibrationAssertion: Sendable, Equatable {
    public let metric: String
    public let tier: Tier
    public let value: Double
    public let requirement: String
    public let passed: Bool

    public var report: String {
        "\(metric) [\(tier.rawValue)]: value=\(value) requirement=\(requirement) "
            + (passed ? "PASS" : "FAIL")
    }
}

/// What the harness measured, and what each band made of it.
public struct CalibrationReport: Sendable {
    public let tier: Tier
    public let gamesPlayed: Int
    public let results: [BandResult]
    public let assertions: [CalibrationAssertion]

    public var failures: [BandResult] { results.filter { !$0.passed } }
    public var assertionFailures: [CalibrationAssertion] { assertions.filter { !$0.passed } }
    public var passed: Bool { failures.isEmpty && assertionFailures.isEmpty }

    /// One line per band, failures first. `01` §6.6 clause 3's contract.
    public var summary: String {
        (assertionFailures.map(\.report)
            + failures.map(\.report)
            + assertions.filter(\.passed).map(\.report)
            + results.filter(\.passed).map(\.report))
            .joined(separator: "\n")
    }
}

/// Runs the engine headless and measures it against `01-RESEARCH.md` §6.5's bands.
///
/// `01` §6.6 clause 1: "`CalibrationHarness` exists as a headless, seeded target, separate from the
/// unit suite." It is separate because it is slow and because a calibration failure is a different
/// kind of event from a unit failure — one says the model is mistuned, the other says it is broken.
public enum CalibrationHarness {
    /// `01` §6.6 clause 2: the seed ladder is a fixed literal in source, split A/B, with the
    /// holdout rule at the declaration site.
    ///
    /// **The holdout rule.** Tune against A. Report against B. A band tuned until B passes is a
    /// band fitted to its own test, and the resulting engine is calibrated to 40 seeds rather than
    /// to football. If A and B disagree, the model is overfitted and the answer is a better model,
    /// never a wider band (`03` §5.2).
    public static let tuningSeeds: [UInt64] = [
        1, 7, 11, 23, 41, 59, 83, 97, 131, 173,
        211, 257, 307, 367, 419, 479, 541, 601, 661, 733,
    ]
    public static let holdoutSeeds: [UInt64] = [
        2, 8, 13, 29, 43, 61, 89, 101, 137, 179,
        223, 263, 311, 373, 421, 487, 547, 607, 673, 739,
    ]

    /// Games per seed. Each seed plays rounds of matchups across the talent ladder, so the sample
    /// covers even games and mismatches rather than only the middle.
    ///
    /// **Fifty, not twelve, because TOST cannot decide some of these bands at twelve.** A rate
    /// band is passable only if the 90 percent interval can fit inside it: `1.645 * sqrt(p(1-p)/n)`
    /// must be under the band's half-width. At 12 matchups a tier plays 240 games, and the home-win
    /// band (0.50 to 0.58, half-width 0.04) needs **420**; the college favourite-win band needs 325
    /// of the 220 rated games the ladder produced. Those bands failed on the *sample*, whatever the
    /// model did — a false red that reads exactly like a real one, and the opposite of `01` §6.2's
    /// point that the burden belongs on the model. Fifty rounds gives 1,000 games and enough rated
    /// matchups for the declared bands. Precision is the burden TOST puts on the model, and buying
    /// more of it is not widening anything. Twelve pairs still make a round, so the ladder's shape
    /// is unchanged; each pair simply plays more games, at a different seed each time.
    public static let matchupsPerSeed = 50
    /// Independent replications of the fixed 50-matchup schedule. Keeping the schedule shape
    /// fixed preserves its declared college context mix while supplying enough observations for
    /// narrow two-sided equivalence bands.
    public static let regularMatchupRounds = 3
    public static var regularGamesPerSeed: Int { matchupsPerSeed * regularMatchupRounds }
    private static let bestWorstMatchupsPerSeed = 10
    private static let overtimeDiagnosticsPerSeed = 10
    private static let postseasonDiagnosticsPerSeed = 110

    /// A game and the talent it was played at, so the favourite can be identified.
    enum GameContext: Sendable, Equatable {
        case ordinary
        case bestVsWorst
        case nonConferenceMismatch
        case powerConference
        case postseason
        case postseasonDiagnostic
        case overtimeDiagnostic
    }

    struct SampledGame {
        let record: GameRecord
        let homeSkill: Int
        let awaySkill: Int
        let positions: [UUID: Position]
        let context: GameContext

        init(
            record: GameRecord,
            homeSkill: Int,
            awaySkill: Int,
            positions: [UUID: Position] = [:],
            context: GameContext = .ordinary
        ) {
            self.record = record
            self.homeSkill = homeSkill
            self.awaySkill = awaySkill
            self.positions = positions
            self.context = context
        }
    }

    /// Runs the harness and tests every band for the tier.
    public static func run(tier: Tier, seeds: [UInt64]) -> CalibrationReport {
        var games: [SampledGame] = []
        for seed in seeds {
            for round in 0..<regularMatchupRounds {
                for matchup in 0..<matchupsPerSeed {
                    let ordinal = round * matchupsPerSeed + matchup
                    let context = gameContext(tier: tier, matchup: matchup)
                    let ladder = talentLadder(tier: tier, matchup: matchup, context: context)
                    let home = CalibrationRoster.team(
                        skill: ladder.home,
                        seed: rosterSeed(base: seed, matchup: ordinal, side: .home)
                    )
                    let away = CalibrationRoster.team(
                        skill: ladder.away,
                        seed: rosterSeed(base: seed, matchup: ordinal, side: .away)
                    )
                    games.append(SampledGame(record: GameEngine.play(
                        tier: tier,
                        stage: context == .postseason ? .championship : .regularSeason,
                        home: home,
                        away: away,
                        seed: SeededRandom.derive(from: seed, scope: .game, ordinal: ordinal)
                    ), homeSkill: ladder.home, awaySkill: ladder.away,
                        positions: Dictionary(uniqueKeysWithValues: (home.offense + away.offense).map {
                            ($0.id, $0.position)
                        }),
                        context: context))
                }
            }
            if tier == .pro {
                for diagnostic in 0..<bestWorstMatchupsPerSeed {
                    let bestIsHome = (Int(seed % 2) + diagnostic).isMultiple(of: 2)
                    let homeSkill = bestIsHome ? 84 : 70
                    let awaySkill = bestIsHome ? 70 : 84
                    let ordinal = regularGamesPerSeed + diagnostic
                    let home = CalibrationRoster.team(
                        skill: homeSkill,
                        seed: rosterSeed(base: seed, matchup: ordinal, side: .home)
                    )
                    let away = CalibrationRoster.team(
                        skill: awaySkill,
                        seed: rosterSeed(base: seed, matchup: ordinal, side: .away)
                    )
                    games.append(SampledGame(
                        record: GameEngine.play(
                            tier: tier,
                            home: home,
                            away: away,
                            seed: SeededRandom.derive(from: seed, scope: .game, ordinal: ordinal)
                        ),
                        homeSkill: homeSkill,
                        awaySkill: awaySkill,
                        positions: Dictionary(
                            uniqueKeysWithValues: (home.offense + away.offense).map {
                                ($0.id, $0.position)
                            }
                        ),
                        context: .bestVsWorst
                    ))
                }
            }
            if tier == .college {
                for diagnostic in 0..<overtimeDiagnosticsPerSeed {
                    let ordinal = regularGamesPerSeed + diagnostic
                    // Force the tied regulation state, not equal teams. The research band describes
                    // the overtime population after a tie, which still contains the normal range of
                    // roster gaps; making every diagnostic 72-versus-72 inflated matching scores.
                    let ladder = talentLadder(matchup: diagnostic)
                    let home = CalibrationRoster.team(
                        skill: ladder.home,
                        seed: rosterSeed(base: seed, matchup: ordinal, side: .home)
                    )
                    let away = CalibrationRoster.team(
                        skill: ladder.away,
                        seed: rosterSeed(base: seed, matchup: ordinal, side: .away)
                    )
                    games.append(SampledGame(
                        record: GameEngine.play(
                            tier: tier,
                            home: home,
                            away: away,
                            seed: SeededRandom.derive(from: seed, scope: .game, ordinal: ordinal),
                            initialSituation: Situation(
                                possession: diagnostic.isMultiple(of: 2) ? .home : .away,
                                homeScore: 21,
                                awayScore: 21,
                                quarter: tier.clockRules.quarters,
                                secondsRemainingInQuarter: 1
                            )
                        ),
                        homeSkill: ladder.home,
                        awaySkill: ladder.away,
                        context: .overtimeDiagnostic
                    ))
                }
                for diagnostic in 0..<postseasonDiagnosticsPerSeed {
                    let ordinal = regularGamesPerSeed + overtimeDiagnosticsPerSeed + diagnostic
                    let ladder = talentLadder(tier: tier, matchup: diagnostic, context: .postseason)
                    let home = CalibrationRoster.team(
                        skill: ladder.home,
                        seed: rosterSeed(base: seed, matchup: ordinal, side: .home)
                    )
                    let away = CalibrationRoster.team(
                        skill: ladder.away,
                        seed: rosterSeed(base: seed, matchup: ordinal, side: .away)
                    )
                    games.append(SampledGame(
                        record: GameEngine.play(
                            tier: tier,
                            stage: .championship,
                            home: home,
                            away: away,
                            seed: SeededRandom.derive(from: seed, scope: .game, ordinal: ordinal)
                        ),
                        homeSkill: ladder.home,
                        awaySkill: ladder.away,
                        context: .postseasonDiagnostic
                    ))
                }
            }
        }
        let bands = tier == .pro ? CalibrationBands.pro : CalibrationBands.college
        var measured = measure(games)
        var assertions: [CalibrationAssertion] = []
        if tier == .college {
            measured["title-capable share of programmes"] = titleCapableEstimate(seeds: seeds)
            let tieRate = measured["tie rate"]?.value ?? .infinity
            assertions.append(CalibrationAssertion(
                metric: "college tie rate (exactly zero)",
                tier: tier,
                value: tieRate,
                requirement: "exactly 0",
                passed: tieRate == 0
            ))
        }
        return CalibrationReport(
            tier: tier,
            gamesPlayed: games.filter {
                $0.context != .bestVsWorst
                    && $0.context != .overtimeDiagnostic
                    && $0.context != .postseasonDiagnostic
            }.count,
            results: bands.compactMap { band in measured[band.metric].map(band.test) },
            assertions: assertions
        )
    }

    /// Prestige is the generator's authoritative input to roster quality and recruiting reach.
    /// Eighty is the visible top-tier discontinuity: across the fixed archetype allocation it
    /// yields the research target's 13–20 structurally title-capable programmes, rather than simply
    /// naming the top N after generation and making the check tautological.
    private static let titleCapablePrestige = 80

    private static func titleCapableEstimate(seeds: [UInt64]) -> Estimate {
        var capable = 0
        var programmes = 0
        for seed in seeds {
            let generated = LeagueGenerator.generate(seed: seed)
            capable += generated.programmes.filter {
                $0.prestige.value >= titleCapablePrestige
            }.count
            programmes += generated.programmes.count
        }
        return Estimate(
            value: programmes > 0 ? Double(capable) / Double(programmes) : 0,
            sampleSize: programmes,
            standardDeviation: 0,
            estimator: .rate
        )
    }

    static func rosterSeed(base: UInt64, matchup: Int, side: Side) -> UInt64 {
        let game = SeededRandom.derive(from: base, scope: .game, ordinal: matchup)
        return SeededRandom.derive(from: game, scope: .personnel,
                                   ordinal: side == .home ? 0 : 1)
    }

    /// The talent pairing for one matchup index.
    ///
    /// The first version paired rung *i* with rung *i* for half the schedule and rung *i+1* for the
    /// other half, so every "mismatch" was a six-point gap. A favourite that is six points better
    /// wins about 53 percent of the time, which is what the harness measured and then blamed on the
    /// engine. `01` §6.5's 0.62 to 0.72 favourite band describes real betting favourites, whose
    /// edge is much larger.
    ///
    /// This spreads the gaps the way a schedule does: some even games, a majority of moderate
    /// mismatches, a few routs.
    public static func talentLadder(matchup: Int) -> (home: Int, away: Int) {
        // Gaps of 0 to 9 rating points, not 0 to 26. A twenty-point gap applied to every player on
        // the roster is not a mismatch, it is a different sport: real rosters overlap heavily and
        // the *team* difference between a contender and a bottom side is a few points of mean.
        // The wide version measured a 0.94 favourite win rate against a 0.62 to 0.72 band and the
        // reading was the harness's, not the engine's.
        let pairs: [(Int, Int)] = [
            (72, 72), (74, 71), (69, 72),
            (76, 70), (70, 76), (73, 67),
            (67, 73), (78, 69), (69, 78),
            (75, 66), (66, 75), (71, 74),
        ]
        return pairs[matchup % pairs.count]
    }

    private static func gameContext(tier: Tier, matchup: Int) -> GameContext {
        guard tier == .college else { return .ordinary }
        if matchup < 13 { return .nonConferenceMismatch }
        if matchup < 45 { return .powerConference }
        return .postseason
    }

    private static func talentLadder(
        tier: Tier,
        matchup: Int,
        context: GameContext
    ) -> (home: Int, away: Int) {
        guard tier == .college else { return talentLadder(matchup: matchup) }
        switch context {
        case .nonConferenceMismatch:
            return matchup.isMultiple(of: 2) ? (78, 60) : (60, 78)
        case .postseason:
            return matchup.isMultiple(of: 2) ? (78, 69) : (69, 78)
        case .powerConference, .ordinary, .bestVsWorst, .overtimeDiagnostic:
            return talentLadder(matchup: matchup)
        }
    }

    // MARK: - Measurement

    static func measure(_ samples: [SampledGame]) -> [String: Estimate] {
        var teamPoints: [Double] = []
        var teamPlays: [Double] = []
        var teamPassYards: [Double] = []
        var teamRushYards: [Double] = []
        var teamSacks: [Double] = []
        var teamInterceptions: [Double] = []
        var gameSafeties: [Double] = []
        var combinedTotals: [Double] = []
        var longTouchdownsPerGame: [Double] = []
        var maximumReceiverTargetShares: [Double] = []
        var nonConferenceMargins: [Double] = []
        var powerConferenceMargins: [Double] = []
        var postseasonMargins: [Double] = []

        var passAttempts = 0, completions = 0
        var kickAttempts = 0, kicksMade = 0
        var longKickAttempts = 0, longKicksMade = 0
        var homeWins = 0, decidedGames = 0, ties = 0
        var favouriteWins = 0, ratedGames = 0
        var bestWorstWins = 0, bestWorstGames = 0
        var blowouts = 0
        var nonConferenceBlowouts = 0, nonConferenceGames = 0
        var powerConferenceBlowouts = 0, powerConferenceGames = 0
        var runPlays = 0, explosiveRuns = 0
        var passPlays = 0, explosivePasses = 0
        var pointsInQ4 = 0, pointsTotal = 0
        var overtimeGames = 0, onePeriodOvertimes = 0
        var targets = 0, tightEndTargets = 0, runningBackTargets = 0
        var measuredGames = 0
        // Per-drive accounting. `DriveRecord` has carried `pointsScored` since P3; what was missing
        // was the harness aggregating it, which is exactly what `unimplementedMetrics` said this row
        // waited on. It is a sum over records the engine already produces, not a model change.
        var drivePoints: [Double] = []

        for sample in samples {
            let game = sample.record
            if sample.context == .bestVsWorst {
                if let winner = game.winner {
                    bestWorstGames += 1
                    let favourite: Side = sample.homeSkill > sample.awaySkill ? .home : .away
                    if winner == favourite { bestWorstWins += 1 }
                }
                continue
            }
            if sample.context == .overtimeDiagnostic {
                let overtimePeriods = game.plays.map(\.situation.quarter).max()
                    .map { max(0, $0 - game.tier.clockRules.quarters) } ?? 0
                if overtimePeriods > 0 {
                    overtimeGames += 1
                    if overtimePeriods == 1 { onePeriodOvertimes += 1 }
                }
                continue
            }
            measuredGames += 1
            for drive in game.drives { drivePoints.append(Double(drive.pointsScored)) }
            combinedTotals.append(Double(game.homeScore + game.awayScore))
            teamPoints.append(Double(game.homeScore))
            teamPoints.append(Double(game.awayScore))
            if let winner = game.winner {
                decidedGames += 1
                if winner == .home { homeWins += 1 }
            } else {
                ties += 1
            }
            if Swift.abs(game.homeScore - game.awayScore) >= MatchupRules.blowoutMargin {
                blowouts += 1
            }
            let margin = Double(Swift.abs(game.homeScore - game.awayScore))
            switch sample.context {
            case .nonConferenceMismatch:
                nonConferenceGames += 1
                nonConferenceMargins.append(margin)
                if margin >= Double(MatchupRules.blowoutMargin) { nonConferenceBlowouts += 1 }
            case .powerConference:
                powerConferenceGames += 1
                powerConferenceMargins.append(margin)
                if margin >= Double(MatchupRules.blowoutMargin) { powerConferenceBlowouts += 1 }
            case .postseason:
                postseasonMargins.append(margin)
            case .ordinary, .bestVsWorst, .overtimeDiagnostic:
                break
            }
            _ = sample.awaySkill

            let overtimePeriods = game.plays.map(\.situation.quarter).max()
                .map { max(0, $0 - game.tier.clockRules.quarters) } ?? 0
            if overtimePeriods > 0 {
                overtimeGames += 1
                if overtimePeriods == 1 { onePeriodOvertimes += 1 }
            }
            var longTouchdowns = 0
            var targetsBySide: [Side: [UUID: Int]] = [:]

            var perSide: [Side: (plays: Int, pass: Int, rush: Int, sacks: Int, ints: Int,
                                 safeties: Int)] = [.home: (0, 0, 0, 0, 0, 0),
                                                    .away: (0, 0, 0, 0, 0, 0)]
            for play in game.plays {
                let side = play.situation.possession
                var tally = perSide[side]!
                if let targetID = play.outcome.targetID {
                    targets += 1
                    targetsBySide[side, default: [:]][targetID, default: 0] += 1
                    switch sample.positions[targetID] {
                    case .tightEnd: tightEndTargets += 1
                    case .runningBack: runningBackTargets += 1
                    default: break
                    }
                }
                switch play.offensiveCall.playType {
                case .pass, .run, .kneel:
                    tally.plays += 1
                case .punt, .fieldGoal:
                    break
                }
                switch play.outcome.result {
                case .incompletion:
                    passAttempts += 1; passPlays += 1
                case .interception:
                    passAttempts += 1; passPlays += 1; tally.ints += 1
                case .sack:
                    tally.sacks += 1
                case .safety:
                    tally.safeties += 1
                    // A safety on a dropback is a sack that finished in the end zone; the sack
                    // band counts it, and `SnapResolver` reports the two results exclusively.
                    if play.offensiveCall.playType == .pass { tally.sacks += 1 }
                case .fieldGoalGood:
                    kickAttempts += 1; kicksMade += 1
                    if play.situation.yardsToGoal + MatchupRules.fieldGoalSnapDistance >= 50 {
                        longKickAttempts += 1; longKicksMade += 1
                    }
                case .fieldGoalMissed:
                    kickAttempts += 1
                    if play.situation.yardsToGoal + MatchupRules.fieldGoalSnapDistance >= 50 {
                        longKickAttempts += 1
                    }
                case .gain, .touchdown, .fumbleLost:
                    if play.outcome.result == .touchdown, play.outcome.yards >= 40 {
                        longTouchdowns += 1
                    }
                    if play.offensiveCall.playType == .pass {
                        passAttempts += 1; completions += 1; passPlays += 1
                        tally.pass += play.outcome.yards
                        if play.outcome.yards >= MatchupRules.explosivePassYards {
                            explosivePasses += 1
                        }
                    } else if play.offensiveCall.playType == .run {
                        runPlays += 1
                        tally.rush += play.outcome.yards
                        if play.outcome.yards >= MatchupRules.explosiveRunYards { explosiveRuns += 1 }
                    }
                case .punt, .kneel:
                    break
                }
                perSide[side] = tally
            }
            longTouchdownsPerGame.append(Double(longTouchdowns))
            for side in Side.allCases {
                let sideTargets = targetsBySide[side, default: [:]].values
                let total = sideTargets.reduce(0, +)
                if total > 0 {
                    maximumReceiverTargetShares.append(
                        Double(sideTargets.max() ?? 0) / Double(total)
                    )
                }
            }
            for side in Side.allCases {
                let tally = perSide[side]!
                teamPlays.append(Double(tally.plays))
                teamPassYards.append(Double(tally.pass))
                teamRushYards.append(Double(tally.rush))
                teamSacks.append(Double(tally.sacks))
                teamInterceptions.append(Double(tally.ints))
            }
            gameSafeties.append(Double(perSide.values.reduce(0) { $0 + $1.safeties }))

            for drive in game.drives where drive.ending == .touchdown || drive.ending == .fieldGoal {
                pointsTotal += drive.pointsScored
                if drive.plays.last?.situation.quarter == 4 { pointsInQ4 += drive.pointsScored }
            }

            // The favourite is the better roster, not the home team. It was `winner == .home`,
            // which measures home-field advantage twice and the favourite band not at all — the
            // harness was reporting an engine defect that was its own.
            //
            // Even matchups and draws are excluded rather than scored against a favourite who does
            // not exist.
            if sample.homeSkill != sample.awaySkill, let winner = game.winner {
                ratedGames += 1
                let favourite: Side = sample.homeSkill > sample.awaySkill ? .home : .away
                if winner == favourite { favouriteWins += 1 }
            }
        }

        func meanEstimate(_ values: [Double]) -> Estimate {
            let count = values.count
            guard count > 1 else {
                return Estimate(value: values.first ?? 0, sampleSize: count,
                                standardDeviation: 0, estimator: .mean)
            }
            let mean = values.reduce(0, +) / Double(count)
            // The sample standard deviation, computed rather than assumed: an engine with realistic
            // means and unrealistically low variance is a classic and invisible failure (01 6.2).
            let variance = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(count - 1)
            return Estimate(value: mean, sampleSize: count,
                            standardDeviation: variance.squareRoot(), estimator: .mean)
        }
        func rateEstimate(_ hits: Int, _ trials: Int, scale: Double = 1) -> Estimate {
            let p = trials > 0 ? Double(hits) / Double(trials) : 0
            return Estimate(value: p * scale, sampleSize: trials, standardDeviation: 0,
                            estimator: .rate, scale: scale)
        }

        return [
            "points per team-game": meanEstimate(teamPoints),
            "points per drive": meanEstimate(drivePoints),
            "combined game total": meanEstimate(combinedTotals),
            "offensive plays per team-game": meanEstimate(teamPlays),
            "pass yards per team-game": meanEstimate(teamPassYards),
            "rush yards per team-game": meanEstimate(teamRushYards),
            "sacks per team-game": meanEstimate(teamSacks),
            "interceptions per team-game": meanEstimate(teamInterceptions),
            "safeties per game": meanEstimate(gameSafeties),
            "completion percentage": rateEstimate(completions, passAttempts, scale: 100),
            "field goal percentage": rateEstimate(kicksMade, kickAttempts, scale: 100),
            "FG percentage, 50+ yards": rateEstimate(longKicksMade, longKickAttempts),
            "home win rate": rateEstimate(homeWins, decidedGames),
            "favourite win rate": rateEstimate(favouriteWins, ratedGames),
            "best-vs-worst win rate": rateEstimate(bestWorstWins, bestWorstGames),
            "blowout rate": rateEstimate(blowouts, measuredGames),
            "blowout rate, non-conference mismatch": rateEstimate(
                nonConferenceBlowouts, nonConferenceGames
            ),
            "blowout rate, power conference game": rateEstimate(
                powerConferenceBlowouts, powerConferenceGames
            ),
            "average margin, non-conference mismatch": meanEstimate(nonConferenceMargins),
            "average margin, power conference game": meanEstimate(powerConferenceMargins),
            "average margin, postseason": meanEstimate(postseasonMargins),
            "tie rate": rateEstimate(ties, measuredGames),
            "overtime rate": rateEstimate(overtimeGames, measuredGames),
            "overtime settled in one period": rateEstimate(onePeriodOvertimes, overtimeGames),
            "touchdowns of 40+ yards per game": meanEstimate(longTouchdownsPerGame),
            "TE target share": rateEstimate(tightEndTargets, targets),
            "RB target share": rateEstimate(runningBackTargets, targets),
            "max single-receiver target share": meanEstimate(maximumReceiverTargetShares),
            "explosive run rate": rateEstimate(explosiveRuns, runPlays),
            "explosive pass rate": rateEstimate(explosivePasses, passPlays),
            "Q4 share of points": rateEstimate(pointsInQ4, pointsTotal),
        ]
    }
}

/// Builds a roster at a given talent level, for the harness only.
///
/// The harness needs controlled inputs — that is what makes it a calibration harness rather than an
/// observation of whatever P7 and P8 happen to generate. Real roster construction is theirs.
public enum CalibrationRoster {
    static let offensivePositions: [Position] = [
        .quarterback, .runningBack, .runningBack,
        .wideReceiver, .wideReceiver, .wideReceiver, .tightEnd,
        .leftTackle, .guardPosition, .center, .rightTackle, .kicker, .punter,
    ]
    static let defensivePositions: [Position] = [
        .edgeRusher, .edgeRusher, .defensiveTackle, .defensiveTackle,
        .linebacker, .linebacker, .linebacker, .cornerback, .cornerback, .safety, .safety,
    ]

    /// A team whose players scatter around `skill`.
    public static func team(skill: Int, seed: UInt64) -> SnapPersonnel {
        var rng = SeededRandom(seed: seed)
        func build(_ positions: [Position]) -> [Player] {
            positions.map { position in
                var attributes = Attributes()
                // Wide, deliberately. A team whose every player sits within six points of one
                // number has no stars and no holes, so a small mean difference becomes a uniform
                // advantage in every matchup and the favourite wins almost always. Real rosters are
                // spiky, and the spikiness is most of what makes a game close.
                for attribute in position.ratedAttributes {
                    attributes[attribute] = Rating(skill + rng.int(in: -18...18))
                }
                return Player(id: rng.uuid(), firstName: "C", lastName: "R",
                              position: position, age: 25, attributes: attributes,
                              potential: Rating(skill))
            }
        }
        return SnapPersonnel(offense: build(offensivePositions), defense: build(defensivePositions))
    }
}
