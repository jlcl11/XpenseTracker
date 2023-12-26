//
//  SignUpTests.swift
//  SpendRUITests
//
//  Created by José Luis Corral on 22/12/23.
//

import XCTest

final class SignUpTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testScreenElementsShow() throws {
        
        XCUIApplication()/*@START_MENU_TOKEN@*/.staticTexts["Sign Up"]/*[[".buttons[\"Sign Up\"].staticTexts[\"Sign Up\"]",".staticTexts[\"Sign Up\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let app = XCUIApplication()
        
        let signUpLable = app.staticTexts["Sign Up to continue using the app"]
        XCTAssertTrue(signUpLable.exists)
        
        let nameTxtField = app.textFields["Name"]
        XCTAssertTrue(nameTxtField.exists)
        
        let surnameTxtField = app.textFields["Surname"]
        XCTAssertTrue(surnameTxtField.exists)
        
        let emailTxtField = app.textFields["Email"]
        XCTAssertTrue(emailTxtField.exists)
        
        let passwordTxtField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordTxtField.exists)
        
        let confirmPasswordTxtField = app.secureTextFields["Confirm password"]
        XCTAssertTrue(confirmPasswordTxtField.exists)
       
        let currencyDropdown = app/*@START_MENU_TOKEN@*/.staticTexts["Currency"]/*[[".buttons[\"Swiss Franc\"].staticTexts[\"Currency\"]",".staticTexts[\"Currency\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(currencyDropdown.exists)
        
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
   
    }
    
    func testDialogShowsWhenFieldsAreEmpty() throws {
     
        let app = XCUIApplication()
        let signUpButton = app/*@START_MENU_TOKEN@*/.staticTexts["Sign Up"]/*[[".buttons[\"Sign Up\"].staticTexts[\"Sign Up\"]",".staticTexts[\"Sign Up\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(signUpButton.exists)
        signUpButton.tap()
        
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        
        let faltanCamposAlert = app.alerts["Oh no!"]
        XCTAssertTrue(faltanCamposAlert.exists)
        faltanCamposAlert.scrollViews.otherElements.buttons["Ok"].tap()
        
        let signUpLabel = app.staticTexts["Sign Up to continue using the app"]
        XCTAssertTrue(signUpLabel.exists)
    }
}
