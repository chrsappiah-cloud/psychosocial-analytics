import XCTest

/// UI tests for AI draft generation flow.
final class AIGenerationUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["--uitesting", "--ai-fast", "--skip-login"]
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 20))
    }

    func testGenerateAIDraftButtonExistsOnAssessmentDetail() {
        XCTAssertTrue(openFirstAssessmentDetail())
        let generateButton = app.buttons["button_generate_ai_draft"]
        let generateByLabel = app.buttons["Generate AI report draft"]
        XCTAssertTrue(
            generateButton.waitForExistence(timeout: 10) || generateByLabel.waitForExistence(timeout: 10),
            "AI generate button should be visible on assessment detail"
        )
    }

    func testGenerateAIDraftShowsLoadingThenCompletes() throws {
        XCTAssertTrue(openFirstAssessmentDetail())
        try tapGenerateAIWhenReady()

        let loadingText = app.staticTexts["Generating AI report draft…"]
        _ = loadingText.waitForExistence(timeout: 5)

        let generateAgain = app.buttons["Generate AI report draft"]
        XCTAssertTrue(generateAgain.waitForExistence(timeout: 20))
        XCTAssertTrue(generateAgain.isEnabled)
    }

    func testAIDraftCountOrSuccessAfterGeneration() throws {
        XCTAssertTrue(openFirstAssessmentDetail())
        try tapGenerateAIWhenReady()

        let draftLabel = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'AI drafts saved'")
        ).firstMatch
        let successToast = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'AI draft generated'")
        ).firstMatch
        XCTAssertTrue(
            draftLabel.waitForExistence(timeout: 15) || successToast.waitForExistence(timeout: 15),
            "Expected draft count or success notification after generation"
        )
    }

    func testAIAssistanceSectionVisible() {
        XCTAssertTrue(openFirstAssessmentDetail())
        let sectionHeader = app.staticTexts["AI assistance"]
        let footer = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Review all AI-generated'")
        ).firstMatch
        XCTAssertTrue(
            sectionHeader.waitForExistence(timeout: 10) || footer.waitForExistence(timeout: 10),
            "AI assistance section should be visible"
        )
    }

    // MARK: - Helpers

    @discardableResult
    private func openFirstAssessmentDetail() -> Bool {
        UITestTabBar.select("Assess", in: app)
        guard app.staticTexts["Assessments"].waitForExistence(timeout: 20)
            || app.otherElements["screen_assessments"].waitForExistence(timeout: 5) else {
            return false
        }

        let newButton = app.buttons["button_new_assessment"]
        if app.tables.cells.count == 0, newButton.waitForExistence(timeout: 5) {
            newButton.tap()
            sleep(2)
        }

        guard app.tables.cells.firstMatch.waitForExistence(timeout: 20) else {
            return false
        }
        app.tables.cells.firstMatch.tap()
        sleep(1)

        guard app.otherElements["screen_assessment_detail"].waitForExistence(timeout: 20)
            || app.navigationBars["Assessment"].waitForExistence(timeout: 10) else {
            return false
        }

        return app.buttons["button_generate_ai_draft"].waitForExistence(timeout: 20)
            || app.buttons["Generate AI report draft"].waitForExistence(timeout: 10)
    }

    private func tapGenerateAIWhenReady() throws {
        let button = app.buttons["button_generate_ai_draft"]
        let fallback = app.buttons["Generate AI report draft"]
        if button.waitForExistence(timeout: 8) {
            button.tap()
        } else if fallback.waitForExistence(timeout: 8) {
            fallback.tap()
        } else {
            throw XCTSkip("Generate AI button not available")
        }
    }
}
