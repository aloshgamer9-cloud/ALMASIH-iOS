
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
            XCTAssertTrue(tab.waitForExistence(timeout: 10))
            tab.tap()
        }
    }

    func testEveryModuleOpensAndReturns() {
        app.buttons["tab_1"].tap()

        for index in 0...4 {
            let module = app.buttons["module_button_\(index)"]
            XCTAssertTrue(module.waitForExistence(timeout: 10))
            module.tap()

            let back = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(back.waitForExistence(timeout: 10))
            back.tap()

            XCTAssertTrue(module.waitForExistence(timeout: 10))
        }
    }

    func testEveryToolOpensAndReturns() {
        app.buttons["tab_3"].tap()

        for index in 0...4 {
            let tool = app.buttons["tool_button_\(index)"]
            XCTAssertTrue(tool.waitForExistence(timeout: 10))
            tool.tap()

            let back = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(back.waitForExistence(timeout: 10))
            back.tap()

            XCTAssertTrue(tool.waitForExistence(timeout: 10))
        }
    }

    func testMonitorAndSettingsTabsLoad() {
        app.buttons["tab_2"].tap()
        XCTAssertTrue(
            app.staticTexts["MONITOR"].waitForExistence(timeout: 10)
        )

        app.buttons["tab_4"].tap()
        XCTAssertTrue(
            app.staticTexts["SETTINGS"].waitForExistence(timeout: 10)
        )
    }
}
