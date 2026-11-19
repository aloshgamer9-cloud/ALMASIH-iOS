
import XCTest

final class ALMASIHUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAllMainTabsAreReachable() {
        for index in 0...4 {
            let tab = app.buttons["tab_\(index)"]
            XCTAssertTrue(tab.waitForExistence(timeout: 5))
            tab.tap()
        }
    }

    func testEveryModuleOpensAndCloses() {
        app.buttons["tab_1"].tap()

        for index in 0...4 {
            let module = app.buttons["module_button_\(index)"]
            XCTAssertTrue(module.waitForExistence(timeout: 5))
            module.tap()

            let close = app.buttons["module_close"]
            XCTAssertTrue(close.waitForExistence(timeout: 5))
            close.tap()
        }
    }

    func testEveryToolOpensAndCloses() {
        app.buttons["tab_3"].tap()

        for index in 0...4 {
            let tool = app.buttons["tool_button_\(index)"]
            XCTAssertTrue(tool.waitForExistence(timeout: 5))
            tool.tap()

            let close = app.buttons["tool_close"]
            XCTAssertTrue(close.waitForExistence(timeout: 5))
            close.tap()
        }
    }

    func testMonitorAndSettingsTabsLoad() {
        app.buttons["tab_2"].tap()
        XCTAssertTrue(app.staticTexts["MONITOR"].waitForExistence(timeout: 5))

        app.buttons["tab_4"].tap()
        XCTAssertTrue(app.staticTexts["ALMASIH"].firstMatch.waitForExistence(timeout: 5))
    }
}
