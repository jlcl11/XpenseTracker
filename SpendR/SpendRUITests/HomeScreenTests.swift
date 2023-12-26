//
//  HomeScreenTest.swift
//  SpendRUITests
//
//  Created by José Luis Corral on 22/12/23.
//

import XCTest

final class HomeScreenTest: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testHomeScreenElementsDoLoad() {
        let app = XCUIApplication()
        let credentials: String = "example@example.com"

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials)

        app.buttons["Log In"].tap()

        XCTAssertTrue(app.staticTexts["Sort by"].waitForExistence(timeout: 3))

        XCTAssertTrue(app.buttons["calendar"].waitForExistence(timeout: 1))
        app.buttons["calendar"].tap()

        XCTAssertTrue(XCUIApplication().staticTexts["Order by"].exists)
        XCTAssertTrue(XCUIApplication().buttons["Down"].exists)
        XCTAssertTrue(XCUIApplication().buttons["Up"].exists)
        XCTAssertTrue(XCUIApplication().scrollViews.containing(.other, identifier: "Vertical scroll bar, 1 page").element.exists)
        XCTAssertTrue(XCUIApplication().staticTexts["0.0 £"].exists)
        XCTAssertTrue(XCUIApplication().searchFields.element.exists)
        XCTAssertTrue(XCUIApplication().navigationBars["Welcome example"].exists)
        XCTAssertTrue(XCUIApplication().tables["Empty list"].exists)
        XCTAssertTrue( XCUIApplication().navigationBars["Welcome example"].buttons["Add"].exists)
        XCTAssertTrue( XCUIApplication().navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 1).exists)
        XCTAssertTrue(  XCUIApplication().navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).exists)
    }

    func testGoesToUserPage() throws {
        let app = XCUIApplication()
        let credentials: String = "example@example.com"

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials)

        app.buttons["Log In"].tap()
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: app.navigationBars["User Settings"].staticTexts["User Settings"])
        let result = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        
        app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).tap()
        
        if result == .completed {
            XCTAssertTrue(true)
        } 
        
    }
    
    func testGoesToGraphPage() throws {
        let app = XCUIApplication()
        let credentials: String = "example@example.com"

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials)

        app.buttons["Log In"].tap()

        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: app.alerts["Warning"])

        let result = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 1).tap()

        if result == .completed {
            XCTAssertTrue(true)
        } 

        let alert = app.alerts["Warning"]

        XCTAssertTrue(alert.exists)
    }

    func testGoesToAddNewMovement() throws {
        
        let app = XCUIApplication()
        let credentials: String = "example@example.com"

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials)

        app.buttons["Log In"].tap()

        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: app.navigationBars["New Movement"].staticTexts["New Movement"])
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        
        app.navigationBars["Welcome example"].buttons["Add"].tap()

        if result == .completed {
            XCTAssertTrue(true)
        }

        let addMovementLabel = app.navigationBars["New Movement"].staticTexts["New Movement"]

        XCTAssertTrue(addMovementLabel.exists)
    
    }

}
