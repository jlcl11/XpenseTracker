//
//  CreateAndDeleteMovementTests.swift
//  SpendRUITests
//
//  Created by José Luis Corral on 23/12/23.
//

import XCTest

final class CreateAndDeleteMovementTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testCreateAndMovement() throws {
     
        let app = XCUIApplication()
                let credentials: String = "example@example.com"

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials)

        app.buttons["Log In"].tap()

        XCTAssertTrue(app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).waitForExistence(timeout: 3))
        app.navigationBars["Welcome example"].buttons["Add"].tap()
        
        let nameTextField = app.textFields["Name (max 15 characters)"]
        nameTextField.tap()
        nameTextField.typeText("Example")
        
        let amountTxtField = app.textFields["Amount"]
        amountTxtField.tap()
        amountTxtField.typeText("30")
        app.textFields["Name (max 15 characters)"].tap()
        app.buttons[" Save"].tap()
        XCTAssertTrue(XCUIApplication().staticTexts["-30.0 A$"].exists)
                                 
    }
   
}
