import XCTest

/// Tab order matches `RootShellView` insertion order.
private enum MainTab: Int {
    case home = 0
    case assess = 1
    case clients = 2
    case insights = 3
    case reports = 4
    case settings = 5

    var screenID: String {
        switch self {
        case .home: return "screen_dashboard"
        case .assess: return "screen_assessments"
        case .clients: return "screen_clients"
        case .insights: return "screen_insights"
        case .reports: return "screen_reports"
        case .settings: return "screen_settings"
        }
    }
}

final class PsychosocialAnalyticsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["--uitesting"]
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
    }

    func testTabBarNavigatesAllPrimaryScreens() {
        for tab in [MainTab.home, .assess, .clients, .insights, .reports, .settings] {
            selectTab(tab)
            XCTAssertTrue(
                app.descendants(matching: .any)[tab.screenID].waitForExistence(timeout: 10),
                "Screen \(tab.screenID) not visible"
            )
        }
    }

    func testDashboardShowsCaseloadCopy() {
        selectTab(.home)
        XCTAssertTrue(app.staticTexts["Welcome back"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Your caseload at a glance"].exists)
        XCTAssertTrue(app.staticTexts["Active cases"].exists)
    }

    func testClientsSearchFieldExists() {
        selectTab(.clients)
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 10))
    }

    func testSettingsShowsApplicationMetadata() {
        selectTab(.settings)
        XCTAssertTrue(app.otherElements["screen_settings"].waitForExistence(timeout: 10))
        let appName = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'psychosocial'")
        ).firstMatch
        XCTAssertTrue(appName.waitForExistence(timeout: 10))
    }

    func testAssessmentsScreenAndNewButton() {
        selectTab(.assess)
        XCTAssertTrue(app.otherElements["screen_assessments"].waitForExistence(timeout: 10))
        let newByID = app.buttons["button_new_assessment"]
        let newByLabel = app.buttons["Create new assessment"]
        XCTAssertTrue(newByID.waitForExistence(timeout: 5) || newByLabel.waitForExistence(timeout: 5))
    }

    func testInsightsAndReportsRenderMetricAndListContent() {
        selectTab(.insights)
        XCTAssertTrue(app.otherElements["screen_insights"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Average risk score"].waitForExistence(timeout: 10))

        selectTab(.reports)
        XCTAssertTrue(app.otherElements["screen_reports"].waitForExistence(timeout: 10))
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Initial assessment'")).firstMatch
                .waitForExistence(timeout: 10)
        )
    }

    private func selectTab(_ tab: MainTab) {
        let button = app.tabBars.buttons.element(boundBy: tab.rawValue)
        XCTAssertTrue(button.waitForExistence(timeout: 10))
        button.tap()
    }
}

final class PsychosocialAnalyticsUITestsLaunchTests: XCTestCase {
    func testLaunchInDarkMode() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
        add(XCTAttachment(screenshot: app.screenshot()))
    }
}
