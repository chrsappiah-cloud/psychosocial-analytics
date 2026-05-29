import XCTest

/// Captures 6.7" App Store screenshots by saving directly to filesystem.
/// Run: xcodebuild test -scheme PsychosocialAnalytics -only-testing:PsychosocialAnalyticsUITests/AppStoreScreenshotUITests
final class AppStoreScreenshotUITests: XCTestCase {
    private var app: XCUIApplication!
    private let screenshotsDir = "/tmp/appstore_screenshots"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["--uitesting", "--skip-login"]
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
    }

    func testCaptureScreenshots() throws {
        capture(tab: "Home", name: "02-home")
        capture(tab: "Upload", name: "03-upload")
        capture(tab: "Assess", name: "04-assess")
        capture(tab: "Clients", name: "05-clients")
        capture(tab: "Insights", name: "06-insights")
        capture(tab: "Reports", name: "07-reports")
        capture(tab: "Settings", name: "08-settings")
        selectAdminTab()
        sleep(2)
        capture(name: "09-admin-overview")
        app.swipeUp()
        sleep(1)
        capture(name: "10-admin-access")
        app.swipeUp()
        sleep(1)
        capture(name: "11-admin-storage")
    }

    private func saveScreenshot(_ name: String) {
        let shot = app.screenshot()
        let png = shot.pngRepresentation
        let url = URL(fileURLWithPath: "\(screenshotsDir)/\(name).png")
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? png.write(to: url)
        print("SAVED: \(url.path)")
    }

    private func capture(name: String) {
        sleep(1)
        saveScreenshot(name)
        let shot = app.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func capture(tab title: String, name: String) {
        navigateToTab(title)
        sleep(2)
        capture(name: name)
    }

    private func navigateToTab(_ title: String) {
        let direct = app.tabBars.buttons[title]
        if direct.waitForExistence(timeout: 5), direct.isHittable {
            direct.tap()
        } else {
            let more = app.tabBars.buttons["More"]
            if more.waitForExistence(timeout: 5) {
                more.tap()
                sleep(1)
                let cell = app.tables.cells.containing(
                    NSPredicate(format: "label CONTAINS %@", title)
                ).firstMatch
                if cell.waitForExistence(timeout: 5) { cell.tap() }
            }
        }
    }

    private func selectAdminTab() {
        navigateToTab("Admin")
    }
}
