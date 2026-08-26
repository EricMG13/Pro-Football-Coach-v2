import Foundation
import FootballSimCore

/// Host gate for D4's week-advance budget. Device release gates remain outside this suite.
func runPerformanceBudgetTests() {
    suite("Performance budgets — host gate") {
        let state = GameState.bootstrap(seed: 20_260_820)

        test("uses the shipping college league size") {
            expectEqual(state.programmes.count, 134)
        }

        test("a warmed shipping-size week advance stays inside two seconds") {
            let clock = ContinuousClock()
            do {
                _ = try WorldScheduler.advanceWeek(state)
                let fixtures = [20_260_821, 20_260_822, 20_260_823].map(GameState.bootstrap)
                let samples = try fixtures.map { fixture in
                    let started = clock.now
                    _ = try WorldScheduler.advanceWeek(fixture)
                    return seconds(started.duration(to: clock.now))
                }.sorted()
                let median = samples[samples.count / 2]
                expect(
                    median <= 2,
                    String(
                        format: "shipping-size warmed week median %.3f s exceeds the 2.000 s "
                            + "host ceiling; samples=%@",
                        median,
                        String(describing: samples)
                    )
                )
                print(String(
                    format: "PERFORMANCE GATE: shipping college %d programmes; warmed median "
                        + "%.3f s; target 1.200 s (%+.3f s); hard ceiling 2.000 s (%+.3f s); "
                        + "samples=%@ (host threshold asserted; device gate remains open)",
                    state.programmes.count,
                    median,
                    median - 1.2,
                    median - 2.0,
                    String(describing: samples)
                ))
            } catch {
                expect(false, "performance fixture threw: \(error)")
            }
        }
    }
}
