import Foundation

// ponytail: hand-rolled harness because neither XCTest nor swift-testing ships with
// Command Line Tools (both live inside Xcode). ~50 lines, real exit codes, zero deps.
// Swap for swift-testing if the project ever builds on a machine with full Xcode.

/// Resolves the path of the running test binary, for tests that re-exec themselves
/// (via `Process`) to assert a crash/fail-fast exit code.
///
/// `CommandLine.arguments[0]` is whatever argv the parent used to launch this process, not
/// necessarily an absolute, launchable path. `swift run --scratch-path <dir> -c release SimTests`
/// passes a path relative to the invoking cwd, so re-launching that string from a child `Process`
/// fails with "the file doesn't exist" whenever the scratch path isn't SwiftPM's default.
/// `Bundle.main.executablePath` reads the path dyld actually loaded, sidestepping argv entirely.
func currentExecutableURL() -> URL {
    guard let path = Bundle.main.executablePath else {
        fatalError("could not resolve the running executable's own path")
    }
    return URL(fileURLWithPath: path)
}

enum TestKit {
    nonisolated(unsafe) private static var failures: [String] = []
    nonisolated(unsafe) private static var checks = 0
    nonisolated(unsafe) private static var suiteName = ""
    nonisolated(unsafe) private static var currentTest = ""
    nonisolated(unsafe) private static var testsRun = 0
    nonisolated(unsafe) private static var failedTests = Set<String>()

    /// Reports each suite as it closes, so a run that dies still says how far it got.
    ///
    /// It reported only at `finish()` until 2026-08-13. The first full run since `0deb629` hit a
    /// `try!` inside a test fixture; the process aborted, and because nothing had been printed the
    /// log was the fatal error and nothing else — no account of the twenty suites that had already
    /// passed, and no indication of where the run was. That was recoverable only because the
    /// failure was deterministic and could be hunted down by a second run.
    static func suite(_ name: String, _ body: () -> Void) {
        suiteName = name
        let testsBefore = testsRun
        let failuresBefore = failures.count
        body()
        let failed = failures.count - failuresBefore
        print("[\(failed == 0 ? "ok  " : "FAIL")] \(name) — \(testsRun - testsBefore) tests"
            + (failed == 0 ? "" : ", \(failed) failed checks"))
    }

    static func test(_ name: String, _ body: () throws -> Void) {
        currentTest = name
        testsRun += 1
        if ProcessInfo.processInfo.environment["TRACE_TESTS"] != nil {
            FileHandle.standardError.write(Data("> \(suiteName) / \(name)\n".utf8))
        }
        do {
            try body()
        } catch {
            record("threw \(error)")
        }
    }

    /// Runs an async test body to completion.
    ///
    /// Never use this for `@MainActor` work: it blocks the calling thread waiting on the
    /// semaphore, so a hop back to the main actor would deadlock. Actor-isolated and detached
    /// work is fine, which is all the async surface this project has.
    static func testAsync(_ name: String, _ body: @escaping @Sendable () async throws -> Void) {
        currentTest = name
        testsRun += 1
        if ProcessInfo.processInfo.environment["TRACE_TESTS"] != nil {
            FileHandle.standardError.write(Data("> \(suiteName) / \(name)\n".utf8))
        }
        let done = DispatchSemaphore(value: 0)
        Task {
            do { try await body() } catch { record("threw \(error)") }
            done.signal()
        }
        done.wait()
    }

    /// Core assertion. Records a failure with suite/test context instead of trapping,
    /// so one bad expectation doesn't hide the rest of the suite.
    static func expect(
        _ condition: Bool,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        checks += 1
        guard !condition else { return }
        let detail = message()
        let location = "\(URL(fileURLWithPath: "\(file)").lastPathComponent):\(line)"
        record(detail.isEmpty ? "expectation failed at \(location)" : "\(detail) [\(location)]")
    }

    static func expectEqual<T: Equatable>(
        _ lhs: T,
        _ rhs: T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let prefix = message()
        expect(
            lhs == rhs,
            "\(prefix.isEmpty ? "" : prefix + ": ")expected \(rhs), got \(lhs)",
            file: file,
            line: line
        )
    }

    /// Numeric closeness check for statistical assertions.
    static func expectClose(
        _ value: Double,
        _ target: Double,
        _ tolerance: Double,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let prefix = message()
        expect(
            abs(value - target) <= tolerance,
            "\(prefix.isEmpty ? "" : prefix + ": ")\(value) not within \(tolerance) of \(target)",
            file: file,
            line: line
        )
    }

    /// Range check used pervasively by the calibration suites.
    static func expectIn(
        _ value: Double,
        _ range: ClosedRange<Double>,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let prefix = message()
        expect(
            range.contains(value),
            "\(prefix.isEmpty ? "" : prefix + ": ")\(value) outside \(range.lowerBound)...\(range.upperBound)",
            file: file,
            line: line
        )
    }

    private static func record(_ detail: String) {
        let label = "\(suiteName) / \(currentTest)"
        failedTests.insert(label)
        failures.append("  FAIL \(label): \(detail)")
    }

    /// Prints the summary and terminates with a conventional exit code.
    static func finish() -> Never {
        print("\n\(testsRun) tests, \(checks) checks")
        if failures.isEmpty {
            print("all passed")
            exit(0)
        }
        print("\(failedTests.count) failing test(s), \(failures.count) failed check(s):")
        for failure in failures.prefix(60) { print(failure) }
        if failures.count > 60 { print("  ... \(failures.count - 60) more") }
        exit(1)
    }
}

func suite(_ name: String, _ body: () -> Void) { TestKit.suite(name, body) }
func test(_ name: String, _ body: () throws -> Void) { TestKit.test(name, body) }
func testAsync(_ name: String, _ body: @escaping @Sendable () async throws -> Void) {
    TestKit.testAsync(name, body)
}
func expect(
    _ condition: Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) { TestKit.expect(condition, message(), file: file, line: line) }
func expectEqual<T: Equatable>(
    _ lhs: T,
    _ rhs: T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) { TestKit.expectEqual(lhs, rhs, message(), file: file, line: line) }
func expectClose(
    _ value: Double,
    _ target: Double,
    _ tolerance: Double,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) { TestKit.expectClose(value, target, tolerance, message(), file: file, line: line) }
func expectIn(
    _ value: Double,
    _ range: ClosedRange<Double>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) { TestKit.expectIn(value, range, message(), file: file, line: line) }

// MARK: - The season horizon

/// The ceiling on how many simulated seasons any validation, test or soak may run.
///
/// **Owner decision, 2026-09-02: ten seasons, everywhere, no exceptions.** Every season knob in the
/// suite reads this rather than carrying its own literal, so the cap is one edit and a lane cannot
/// quietly opt out of it. `TestHorizon.clamped(_:)` is how an environment-supplied count is brought
/// inside the cap; a lane that ignores it is a lane the cap does not reach.
///
/// This restores canon rather than contradicting it. `03` section 6 states the soak as "Ten
/// seasons", and section 7's save-size budget is stated "at 10 seasons"; the twenty-season M3 range
/// and the unbounded professional soak had both grown past what canon asks for.
///
/// **What the cap costs, stated rather than discovered later.** Two measurements the tree used to
/// be able to take are now out of reach, and both are recorded in `docs/STATUS.md`:
///
/// 1. The M3 college soak's twenty-season run, which is what distinguished *bounded* save growth
///    from *slow* save growth — at ten seasons the margin against the 8 MiB ceiling is comfortable,
///    and at twenty it was about 8.35 MB. The ten-season figure alone cannot tell those apart.
/// 2. `runM2SoakTests`'s settled-population age-curve band, which needed at least twelve seasons
///    for the bootstrap cohort to age out. That branch is now unreachable and is deleted rather
///    than left as a condition that silently never fires.
enum TestHorizon {
    /// The maximum number of simulated seasons any lane may run.
    static let maximumSeasons = 10

    /// `requested` brought inside the cap, with a floor of one season.
    ///
    /// Clamps rather than trapping on purpose: an over-large `PRO_SOAK_SEASONS=40` should run the
    /// longest legal soak and say so, not refuse to start. A non-positive request is the caller
    /// asking for no simulation at all, which is a mistake worth a floor rather than a crash.
    static func clamped(_ requested: Int) -> Int {
        min(maximumSeasons, max(1, requested))
    }
}
