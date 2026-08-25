import Foundation

/// Owner-evidence gate for the human season-throughput budget.
///
/// A headless process cannot measure how long a person takes to read and act on a decision. The
/// owner protocol therefore supplies the observed duration and its provenance through the
/// environment when the instrument is run. Missing evidence is a red, explicit gate rather than
/// an estimate dressed up as a measurement.
func runAgencyBudgetTests() {
    suite("Agency budget — owner evidence") {
        test("requires a dated owner observation") {
            let environment = ProcessInfo.processInfo.environment
            guard let rawSeconds = environment["AGENCY_BUDGET_SECONDS"],
                  let seconds = Double(rawSeconds), seconds.isFinite, seconds >= 0,
                  let hardware = environment["AGENCY_BUDGET_HARDWARE"], !hardware.isEmpty,
                  let build = environment["AGENCY_BUDGET_BUILD"], !build.isEmpty,
                  let protocolDate = environment["AGENCY_BUDGET_DATE"],
                  protocolDate.range(of: "^\\d{4}-\\d{2}-\\d{2}", options: .regularExpression) != nil else {
                expect(false, "owner observation required: set AGENCY_BUDGET_SECONDS, "
                    + "AGENCY_BUDGET_HARDWARE, AGENCY_BUDGET_BUILD, and AGENCY_BUDGET_DATE")
                return
            }

            let hours = seconds / 3_600
            print(String(
                format: "AGENCY BUDGET: %.3f h; target 6.000…8.000 h; hardware %@; build %@; "
                    + "observed %@ (owner evidence)",
                hours, hardware, build, protocolDate
            ))
            expect((6.0...8.0).contains(hours), String(
                format: "observed season duration %.3f h is outside the 6…8 h product budget",
                hours
            ))
        }
    }
}
