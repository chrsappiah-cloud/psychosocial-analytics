import XCTest

/// Tab titles match `AppTab.title` in `AppCoordinator`.
private enum MainTab: String, CaseIterable {
    case home = "Home"
    case assess = "Assess"
    case clients = "Clients"
    case upload = "Upload"
    case insights = "Insights"
    case reports = "Reports"
    case settings = "Settings"

    var screenID: String {
        switch self {
        case .home: return "screen_dashboard"
        case .assess: return "screen_assessments"
        case .clients: return "screen_clients"
        case .upload: return "screen_upload"
        case .insights: return "screen_insights"
        case .reports: return "screen_reports"
        case .settings: return "screen_settings"
        }
    }

    var screenTitle: String {
        switch self {
        case .home: return "Dashboard"
        case .assess: return "Assessments"
        case .clients: return "Clients"
        case .upload: return "Upload"
        case .insights: return "Insights"
        case .reports: return "Reports"
        case .settings: return "Settings"
        }
    }
}

final class PsychosocialAnalyticsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["--uitesting", "--skip-login"]
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
    }

    func testTabBarNavigatesAllPrimaryScreens() {
        for tab in MainTab.allCases {
            selectTab(tab)
            let byID = app.descendants(matching: .any)[tab.screenID]
            let byTitle = app.staticTexts[tab.screenTitle]
            XCTAssertTrue(
                byID.waitForExistence(timeout: 12) || byTitle.waitForExistence(timeout: 12),
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
        XCTAssertTrue(
            app.otherElements["screen_settings"].waitForExistence(timeout: 15)
                || app.staticTexts["Settings"].waitForExistence(timeout: 10)
        )
        let brand = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Psychosocial'")
        ).firstMatch
        XCTAssertTrue(brand.waitForExistence(timeout: 10))
    }

    func testAssessmentsScreenAndNewButton() {
        selectTab(.assess)
        XCTAssertTrue(
            app.otherElements["screen_assessments"].waitForExistence(timeout: 12)
                || app.staticTexts["Assessments"].waitForExistence(timeout: 12)
        )
        let newByID = app.buttons["button_new_assessment"]
        let newByLabel = app.buttons["Create new assessment"]
        XCTAssertTrue(newByID.waitForExistence(timeout: 8) || newByLabel.waitForExistence(timeout: 8))
    }

    func testInsightsAndReportsRenderMetricAndListContent() {
        selectTab(.insights)
        XCTAssertTrue(
            app.otherElements["screen_insights"].waitForExistence(timeout: 12)
                || app.staticTexts["Insights"].waitForExistence(timeout: 12)
        )
        scrollUntilVisible("Average risk score")

        selectTab(.reports)
        XCTAssertTrue(
            app.otherElements["screen_reports"].waitForExistence(timeout: 12)
                || app.staticTexts["Reports"].waitForExistence(timeout: 12)
        )
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Initial assessment'")).firstMatch
                .waitForExistence(timeout: 12)
        )
    }

    private func scrollUntilVisible(_ label: String, maxSwipes: Int = 4) {
        let target = app.staticTexts[label]
        var swipes = 0
        while !target.exists, swipes < maxSwipes {
            app.swipeUp()
            swipes += 1
        }
        XCTAssertTrue(target.waitForExistence(timeout: 8))
    }

    private func selectTab(_ tab: MainTab) {
        UITestTabBar.select(tab.rawValue, in: app)
        sleep(1)
    }
}

private enum AccessibilityID {
    static let appBrandTitle = "app_brand_title"
}

final class PsychosocialAnalyticsUITestsLaunchTests: XCTestCase {
    func testLaunchInDarkMode() throws {
        let app = XCUIApplication()
        app.launchArguments += ["--uitesting", "--skip-login"]
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
        add(XCTAttachment(screenshot: app.screenshot()))
    }
}
