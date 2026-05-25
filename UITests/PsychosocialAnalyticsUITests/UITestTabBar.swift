import XCTest

/// iOS shows at most five tabs; tabs after the fourth appear under **More** in a fixed list order.
enum UITestTabBar {
    /// Order matches `AppTab` cases after `.upload` in `RootShellView`.
    private static let moreMenuIndex: [String: Int] = [
        "Insights": 0,
        "Reports": 1,
        "Settings": 2
    ]

    static func select(_ title: String, in app: XCUIApplication, file: StaticString = #file, line: UInt = #line) {
        let direct = app.tabBars.buttons[title]
        if direct.waitForExistence(timeout: 4), direct.isHittable {
            direct.tap()
            return
        }

        let more = app.tabBars.buttons["More"]
        XCTAssertTrue(more.waitForExistence(timeout: 8), "More tab missing for \(title)", file: file, line: line)
        more.tap()
        sleep(1)

        if let index = moreMenuIndex[title] {
            let cell = app.tables.cells.element(boundBy: index)
            if cell.waitForExistence(timeout: 8) {
                cell.tap()
                return
            }
        }

        let candidates: [XCUIElement] = [
            app.buttons[title],
            app.cells[title],
            app.staticTexts[title],
            app.tables.staticTexts[title],
            app.tables.cells.containing(NSPredicate(format: "label CONTAINS %@", title)).firstMatch
        ]
        for element in candidates {
            if element.waitForExistence(timeout: 3), element.isHittable {
                element.tap()
                return
            }
        }

        XCTFail("Overflow item \(title) missing", file: file, line: line)
    }
}
