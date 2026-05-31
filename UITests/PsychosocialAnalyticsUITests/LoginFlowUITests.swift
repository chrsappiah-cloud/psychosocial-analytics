import XCTest

private extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        tap()
        if let stringValue = self.value as? String, !stringValue.isEmpty {
            let delete = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
            typeText(delete)
        }
        typeText(text)
    }
}

/// Smoke tests for sign-in flows without `--skip-login`.
final class LoginFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["--uitesting", "--fresh-auth"]
        app.launch()
        let loginTab = app.buttons["login_tab_public"]
        let loginLabel = app.buttons["Public Access"]
        XCTAssertTrue(
            loginTab.waitForExistence(timeout: 15) || loginLabel.waitForExistence(timeout: 2),
            "Expected login screen"
        )
    }

    func testPublicLoginShowsHomeTabBar() {
        let emailField = app.textFields["field_login_email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 10))
        emailField.clearAndTypeText("clinician@example.com")

        dismissKeyboardIfPresent()
        app.buttons["button_sign_in"].tap()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }

    func testAdminLoginShowsAdminTab() {
        app.buttons["login_tab_administrator"].tap()

        let emailField = app.textFields["field_login_email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 10))
        emailField.clearAndTypeText("admin@psychosocialanalytics.com")

        let passwordField = app.secureTextFields["field_login_password"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.clearAndTypeText("admin123")

        dismissKeyboardIfPresent()
        app.buttons["button_sign_in"].tap()

        XCTAssertTrue(app.tabBars.buttons["Admin"].waitForExistence(timeout: 20))
    }

    func testAdminLoginRejectsInvalidPassword() {
        app.buttons["login_tab_administrator"].tap()

        let emailField = app.textFields["field_login_email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 10))
        emailField.clearAndTypeText("admin@psychosocialanalytics.com")

        let passwordField = app.secureTextFields["field_login_password"]
        passwordField.clearAndTypeText("wrong-password")

        dismissKeyboardIfPresent()
        app.buttons["button_sign_in"].tap()

        XCTAssertTrue(
            app.staticTexts["Invalid administrator credentials. Please try again."]
                .waitForExistence(timeout: 10)
        )
        XCTAssertTrue(app.buttons["login_tab_public"].exists)
    }

    private func dismissKeyboardIfPresent() {
        if app.keyboards.count > 0 {
            app.swipeDown()
        }
    }
}
