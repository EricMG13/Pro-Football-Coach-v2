import Foundation

/// Optional diagnostic for the human season-throughput target; it is not a release gate.
func runAgencyBudgetTests() {
    suite("Agency budget — optional diagnostic") {
        test("reports a supplied observation without requiring one") {
            let environment = ProcessInfo.processInfo.environment
            guard let rawSeconds = environment["AGENCY_BUDGET_SECONDS"],
                  let seconds = Double(rawSeconds), seconds.isFinite, seconds >= 0,
                  let hardware = environment["AGENCY_BUDGET_HARDWARE"], !hardware.isEmpty,
                  let build = environment["AGENCY_BUDGET_BUILD"], !build.isEmpty,
                  let protocolDate = environment["AGENCY_BUDGET_DATE"],
                  protocolDate.range(
                      of: "^\\d{4}-\\d{2}-\\d{2}",
                      options: .regularExpression
                  ) != nil else {
                print("AGENCY BUDGET: optional observation not supplied; diagnostic skipped")
                return
            }

            let hours = seconds / 3_600
            print(String(
                format: "AGENCY BUDGET: %.3f h; target 6.000…8.000 h; hardware %@; build %@; "
                    + "observed %@ (optional observation)",
                hours,
                hardware,
                build,
                protocolDate
            ))
            expect((6.0...8.0).contains(hours), String(
                format: "observed season duration %.3f h is outside the 6…8 h product budget",
                hours
            ))
        }
    }
}
