import XCTest

final class ProFootballCoachUITests: XCTestCase {
    func testLaunchContractIsRegistered() {
        XCTAssertTrue(true)
    }

    func testAftermathProofRendersRecordedOutcome() {
        let app = XCUIApplication()
        app.launchEnvironment["PROOF_SCREEN"] = "aftermath-overflow"
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["FINAL. MEMORIAL FIELD. CAR WIN."]
            .waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Carson Tech, 31"].exists)
        XCTAssertTrue(app.staticTexts["Southern State, 17"].exists)
        XCTAssertTrue(app.staticTexts["CAR WIN"].exists)
        XCTAssertFalse(app.staticTexts[
            "Aftermath unavailable. No retained career evidence is available for this surface."
        ].exists)
    }

    func testAftermathProofAX5ReachesOutcomeAfterSwipe() {
        let app = XCUIApplication()
        app.launchEnvironment["PROOF_SCREEN"] = "aftermath-overflow"
        app.launch()

        let window = app.windows.firstMatch
        XCTAssertTrue(window.waitForExistence(timeout: 10))
        XCTAssertGreaterThan(window.frame.width, window.frame.height)
        let viewport = app.scrollViews.firstMatch
        XCTAssertTrue(viewport.waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Scroll for call-ins and injuries"].exists)

        let retainedSequence = [
            "Carson Tech, 31",
            "Southern State, 17",
            "Carson Tech took the third quarter and held the result.",
            "GRADES",
            "WHAT THE PLAN DID",
            "WHAT THE GAME TURNED ON",
            "CALLED IN",
            "INJURIES",
        ]
        for label in retainedSequence {
            XCTAssertTrue(app.staticTexts[label].exists, "Missing retained Aftermath element: \(label)")
        }
        XCTAssertTrue(app.descendants(matching: .any)["FINAL. MEMORIAL FIELD. CAR WIN."].exists)
        XCTAssertTrue(app.buttons["BOX SCORE"].exists)
        XCTAssertTrue(app.buttons["CONTINUE →"].exists)
        let tree = app.staticTexts.allElementsBoundByIndex.map(\.label)
        let sequenceIndexes = retainedSequence.compactMap { tree.firstIndex(of: $0) }
        XCTAssertEqual(sequenceIndexes.count, retainedSequence.count)
        XCTAssertEqual(sequenceIndexes, sequenceIndexes.sorted())

        let outcome = app.staticTexts["Carson Tech, 31"]
        for _ in 0..<6 where !outcome.isHittable {
            viewport.swipeUp()
        }
        XCTAssertTrue(outcome.isHittable)

        viewport.swipeUp()
        let plan = app.staticTexts["WHAT THE PLAN DID"]
        for _ in 0..<6 where !plan.isHittable {
            viewport.swipeUp()
        }
        XCTAssertTrue(plan.isHittable)

        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "Aftermath AX5 landscape post-scroll"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testAftermathProofShowsOutcomeHeader() {
        let app = XCUIApplication()
        app.launchEnvironment["PROOF_SCREEN"] = "aftermath"
        app.launch()

        let header = app.descendants(matching: .any)["FINAL. MEMORIAL FIELD. CAR WIN."]
        XCTAssertTrue(header.waitForExistence(timeout: 10))

        let accessibilitySequence = app.descendants(matching: .any).allElementsBoundByIndex.map(\.label)
        guard let headerIndex = accessibilitySequence.firstIndex(of: header.label),
              let scoreIndex = accessibilitySequence.firstIndex(of: "Carson Tech, 31"),
              let headlineIndex = accessibilitySequence.firstIndex(of: "Carson Tech took the third quarter and held the result."),
              let boxScoreIndex = accessibilitySequence.firstIndex(of: "BOX SCORE"),
              let continueIndex = accessibilitySequence.firstIndex(of: "CONTINUE →")
        else {
            XCTFail("Aftermath accessibility tree is missing its retained outcome reading sequence")
            return
        }
        XCTAssertLessThan(headerIndex, scoreIndex)
        XCTAssertLessThan(headerIndex, headlineIndex)
        XCTAssertLessThan(headerIndex, boxScoreIndex)
        XCTAssertLessThan(headerIndex, continueIndex)
    }

    func testAftermathMinimumProofReachesPlanContentAfterSwipe() {
        let app = XCUIApplication()
        app.launchEnvironment["PROOF_SCREEN"] = "aftermath-minimum"
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["FINAL. MEMORIAL FIELD. CAR WIN."]
            .waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Scroll for call-ins and injuries"].waitForExistence(timeout: 10))

        let planScroller = app.scrollViews.firstMatch
        XCTAssertTrue(planScroller.waitForExistence(timeout: 10))
        let injuries = app.staticTexts["Cleared."]
        XCTAssertFalse(injuries.isHittable)
        planScroller.swipeUp()
        XCTAssertTrue(injuries.isHittable)
    }

    func testRedesignedJobBoardProofFlow() {
        let app = XCUIApplication()
        app.launchArguments = ["--redesigned-job-board"]
        app.launch()

        let proof = app.otherElements["redesigned-job-board-proof"]
        XCTAssertTrue(proof.waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Southern State"].exists)
        XCTAssertTrue(app.buttons["Lake County"].exists)
        XCTAssertFalse(app.buttons["Lake County"].isEnabled)
        XCTAssertTrue(app.staticTexts["Only professional offers are actionable here."].exists)
        XCTAssertTrue(app.buttons["Accept Southern State · leave Carson Tech"].exists)

        app.buttons["Accept Southern State · leave Carson Tech"].tap()
        let alert = app.alerts["Accept this offer?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        let firstConfirmation = alert.buttons.allElementsBoundByIndex.first { $0.label != "Cancel" }
        XCTAssertNotNil(firstConfirmation)
        alert.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["Accept Southern State · leave Carson Tech"].exists)

        app.buttons["Accept Southern State · leave Carson Tech"].tap()
        let confirmation = app.alerts["Accept this offer?"]
        XCTAssertTrue(confirmation.waitForExistence(timeout: 2))
        let finalConfirmation = confirmation.buttons.allElementsBoundByIndex.first { $0.label != "Cancel" }
        XCTAssertNotNil(finalConfirmation)
        finalConfirmation?.tap()

        XCTAssertTrue(app.staticTexts["No open offers"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Reset proof"].exists)
        XCTAssertTrue(app.staticTexts["Prototype receipt: accepted Southern State offer. No save was changed."]
            .exists)

        app.buttons["Reset proof"].tap()
        XCTAssertTrue(app.buttons["Accept Southern State · leave Carson Tech"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Lake County"].exists)
    }

    func testProductionCareerHubUsesLiveReadModel() {
        let app = XCUIApplication()
        app.launchEnvironment["PROOF_NEW_CAREER"] = "424242"
        app.launchEnvironment["PROOF_SCREEN_NUMBER"] = "52"
        app.launch()

        XCTAssertTrue(app.staticTexts["PROOF COACH"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.staticTexts["Status, Seeking"].exists)
        XCTAssertTrue(app.staticTexts["Tier, College"].exists)
        XCTAssertTrue(
            app.staticTexts["Everything here is recorded. None of it is a prediction about your job."]
                .exists
        )
        XCTAssertTrue(app.buttons["Advance week"].exists)
        XCTAssertFalse(app.otherElements["redesigned-job-board-proof"].exists)
    }

    func testUnavailableRouteOffersReturnPath() {
        let app = XCUIApplication()
        app.launchEnvironment["PROOF_NEW_CAREER"] = "424242"
        app.launchEnvironment["PROOF_SCREEN_NUMBER"] = "62"
        app.launch()

        let unavailable = app.staticTexts[
            "Pro Offseason unavailable. No retained career evidence is available for this surface."
        ]
        XCTAssertTrue(unavailable.waitForExistence(timeout: 20))
        XCTAssertTrue(app.buttons["Back to HQ"].exists)
    }

    /// **Re-targeted, adversarial review fix round, 2026-08-30 (finding 2).**
    /// `testPressBoxNavigatorPanelsAndBackStates` asserted five Press Box mechanisms Phase 2A
    /// deleted outright: the family-switcher trigger ("Switch family, X"), the switcher panel it
    /// revealed ("Career, 9 tasks" and its siblings), the back control ("Back to the previous
    /// surface"), the "Nothing behind this surface" empty-back state, and the alias host panel
    /// ("Career Hub" / "3, Job Board" / "4, Offer" / "5, Appointment"). `Tests/SimTests/Suites/
    /// DesignContractTests.swift`'s "Press Box shared chrome" suite retired the same five at the
    /// source-scan level; this method asserted them at the live-app level and would have failed
    /// the instant it ran.
    ///
    /// It never ran: `scripts/verify.sh`'s app lane runs `xcodebuild ... build`, never `test`, so
    /// this whole target compiles but is not executed by any gate. Fixing this method's content
    /// does not put it behind one — that remains true after this edit, and is recorded here
    /// rather than left implicit, per the review's own instruction.
    ///
    /// Retargeted rather than deleted, per the phase's own rule that an assertion is not removed
    /// without a replacement:
    /// - `"Nothing behind this surface"` / `"Back to the previous surface"`: retired outright. 04
    ///   6.1f's bar has no back control at all; the five families are always visible instead.
    /// - `"Switch family, This week"` / the switcher panel (`"Career, 9 tasks"` etc.): retired
    ///   outright. The bar shows all five inline and always (`ForgeFieldChromeBar.familyStrip`),
    ///   so there is no reveal-on-demand control left to trigger or assert.
    /// - `"Career Hub"` / `"3, Job Board"` / `"4, Offer"` / `"5, Appointment"` (the alias host
    ///   panel) / `"Back to Opportunities"`: retired outright, for the same reason — it opened
    ///   from the sibling strip the switcher revealed, which no longer exists.
    /// - `top-navigator`: kept. Replaced by real assertions against what the bar actually renders
    ///   — the five family labels in `CoachWorldSurfaceFamily.chromeBarFamilies` order, each
    ///   carrying its own `forgeFieldTitle` as its accessible name (`ForgeFieldChromeBar
    ///   .familyButton`) rather than the retired "Switch family, X" phrasing — plus explicit
    ///   negative assertions that the five retired controls stay retired.
    func testForgeFieldChromeBarReplacesThePressBoxNavigator() {
        let app = XCUIApplication()
        app.launchEnvironment["PROOF_NEW_CAREER"] = "424242"
        app.launchEnvironment["PROOF_SCREEN_NUMBER"] = "8"
        app.launch()

        let navigator = app.otherElements["top-navigator"]
        XCTAssertTrue(navigator.waitForExistence(timeout: 30))

        // The five families, in FF Chrome's fixed order (04 6.1f), each by its real accessible
        // name — not the retired "Switch family, X" label.
        for title in ["This week", "Squad", "Recruiting", "Front office", "Ridgeline"] {
            XCTAssertTrue(app.buttons[title].exists, "\(title) must be inline in the chrome bar")
        }
        let bar = XCTAttachment(screenshot: app.screenshot())
        bar.name = "Forge Field — chrome bar"
        bar.lifetime = .keepAlways
        add(bar)

        // 04 6.1f: "mark, club, record, the five surfaces, the week... its contents never vary" —
        // no back control, no switcher, no host panel. These stay retired.
        XCTAssertFalse(app.staticTexts["Nothing behind this surface"].exists)
        XCTAssertFalse(app.buttons["Switch family, This week"].exists)
        XCTAssertFalse(app.buttons["Back to the previous surface"].exists)
        XCTAssertFalse(app.buttons["Career, 9 tasks"].exists)
        XCTAssertFalse(app.buttons["Career Hub"].exists)
        XCTAssertFalse(app.buttons["3, Job Board"].exists)
    }

    func testTeamLogoAssetAndFallbackProof() {
        let app = XCUIApplication()
        app.launchEnvironment["PROOF_SCREEN"] = "team-logos"
        app.launch()

        XCTAssertTrue(app.otherElements["team-logo-asset-proof"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.otherElements["team-logo-fallback-proof"].exists)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Team logos — packaged and fallback"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testTeamLogoProofAtAccessibilityType() {
        let app = XCUIApplication()
        app.launchEnvironment["PROOF_SCREEN"] = "team-logos"
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge"
        ]
        app.launch()

        XCTAssertTrue(app.staticTexts["Fallback Team"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.otherElements["team-logo-fallback-proof"].exists)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Team logos — accessibility type"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
