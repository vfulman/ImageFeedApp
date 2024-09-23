import XCTest


class Image_FeedUITests: XCTestCase {
    private enum UITestsConstants {
        static let email = ""
        static let passwd = ""
        static let name = ""
        static let loginName = ""
    }
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        let button = app.buttons["Authenticate"]
        XCTAssertTrue(button.waitForExistence(timeout: 10))
        button.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText(UITestsConstants.email)
        XCUIApplication().toolbars.buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText(UITestsConstants.passwd)
        XCUIApplication().toolbars.buttons["Done"].tap()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        sleep(5)
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        app.swipeUp()
        sleep(5)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["LikeButton"].tap()
        sleep(5)
        cellToLike.buttons["LikeButton"].tap()
        sleep(5)
        cellToLike.tap()
        sleep(5)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(5)
        let navBackButtonWhiteButton = app.buttons["BackwardButton"]
        sleep(5)
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(5)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(5)
        XCTAssertTrue(app.staticTexts[UITestsConstants.name].exists)
        XCTAssertTrue(app.staticTexts[UITestsConstants.loginName].exists)
        
        app.buttons["LogoutButton"].tap()
        sleep(5)
        app.alerts["LogoutAlert"].scrollViews.otherElements.buttons["LogoutAlertYes"].tap()
    }
}
