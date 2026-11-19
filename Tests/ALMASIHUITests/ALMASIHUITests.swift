
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
            XCTAssertTrue(
                tab.waitForExistence(timeout: 10),
                "Tab \(index) was not found"
            )
            tab.tap()
        }
    }

    func testEveryModuleOpensAndCloses() {
        let modulesTab = app.buttons["tab_1"]
        XCTAssertTrue(modulesTab.waitForExistence(timeout: 10))
        modulesTab.tap()

        for index in 0...4 {
            let module = app.buttons["module_button_\(index)"]
            XCTAssertTrue(
                module.waitForExistence(timeout: 10),
                "Module \(index) was not found"
            )
            module.tap()

            let close = app.buttons["module_close"]
            XCTAssertTrue(close.waitForExistence(timeout: 10))
            close.tap()
        }
    }

    func testEveryToolOpensAndCloses() {
        let toolsTab = app.buttons["tab_3"]
        XCTAssertTrue(toolsTab.waitForExistence(timeout: 10))
        toolsTab.tap()

        for index in 0...4 {
            let tool = app.buttons["tool_button_\(index)"]
            XCTAssertTrue(
                tool.waitForExistence(timeout: 10),
                "Tool \(index) was not found"
            )
            tool.tap()

            let close = app.buttons["tool_close"]
            XCTAssertTrue(close.waitForExistence(timeout: 10))
            close.tap()
        }
    }

    func testMonitorAndSettingsTabsLoad() {
        let monitorTab = app.buttons["tab_2"]
        XCTAssertTrue(monitorTab.waitForExistence(timeout: 10))
        monitorTab.tap()

        XCTAssertTrue(
            app.staticTexts["MONITOR"].waitForExistence(timeout: 10),
            "Monitor screen did not load"
        )

        let settingsTab = app.buttons["tab_4"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        XCTAssertTrue(
            app.staticTexts["SETTINGS"].waitForExistence(timeout: 10),
            "Settings screen did not load"
        )
    }
}
