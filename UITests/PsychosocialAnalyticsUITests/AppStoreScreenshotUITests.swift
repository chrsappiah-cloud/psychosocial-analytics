import XCTest

/// Captures 6.7" App Store screenshots. Run:
/// xcodebuild test -scheme PsychosocialAnalytics -only-testing:PsychosocialAnalyticsUITests/AppStoreScreenshotUITests
final class AppStoreScreenshotUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["--uitesting"]
        app.launch()
    }

    func testCaptureAppStoreScreenshots() throws {
        let loginScreen = app.staticTexts["Psychosocial"].firstMatch
        XCTAssertTrue(loginScreen.waitForExistence(timeout: 10))

        capture(name: "01-login")

        signInAsAdmin()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10))

        capture(tab: "Home", name: "02-home")
        capture(tab: "Upload", name: "03-upload")
        capture(tab: "Assess", name: "04-assess")
        capture(tab: "Clients", name: "05-clients")
        capture(tab: "Insights", name: "06-insights")
        capture(tab: "Settings", name: "07-settings")

        let adminTab = app.tabBars.buttons["Admin"]
        if adminTab.waitForExistence(timeout: 5) {
            capture(tab: "Admin", name: "08-admin-overview")
            captureAdminPayments(name: "09-admin-payments")
            captureAdminApplePay(name: "10-admin-apple-pay")
        } else {
            let more = app.tabBars.buttons["More"]
            if more.waitForExistence(timeout: 5) {
                more.tap()
                sleep(1)
                let adminCell = app.tables.cells.containing(NSPredicate(format: "label CONTAINS 'Admin'")).firstMatch
                if adminCell.waitForExistence(timeout: 5) {
                    adminCell.tap()
                    sleep(1)
                    capture(name: "08-admin-overview")
                }
            }
        }
    }

    private func signInAsAdmin() {
        let adminTabButton = app.buttons["Administrator"]
        if adminTabButton.waitForExistence(timeout: 5) {
            adminTabButton.tap()
            sleep(1)
        }

        let emailField = app.textFields.firstMatch
        if emailField.waitForExistence(timeout: 5) {
            emailField.tap()
            emailField.typeText("admin@psychosocialanalytics.com")
        }

        let passwordField = app.secureTextFields.firstMatch
        if passwordField.waitForExistence(timeout: 5) {
            passwordField.tap()
            passwordField.typeText("admin123")
        }

        let signInButton = app.buttons["Sign In"].firstMatch
        if signInButton.waitForExistence(timeout: 5) {
            signInButton.tap()
            sleep(2)
        }
    }

    private func capture(name: String) {
        sleep(1)
        let shot = app.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func capture(tab title: String, name: String) {
        UITestTabBar.select(title, in: app)
        sleep(2)
        let shot = app.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func captureAdminPayments(name: String) {
        UITestTabBar.select("Admin", in: app)
        sleep(1)

        let paymentsButton = app.buttons["Payments"]
        if paymentsButton.waitForExistence(timeout: 5) {
            paymentsButton.tap()
            sleep(1)
        }

        let shot = app.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func captureAdminApplePay(name: String) {
        UITestTabBar.select("Admin", in: app)
        sleep(1)

        let applePayButton = app.buttons["Apple Pay"]
        if applePayButton.waitForExistence(timeout: 5) {
            applePayButton.tap()
            sleep(1)
        }

        let shot = app.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
