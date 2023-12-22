//
//  SpendRUITests.swift
//  SpendRUITests
//
//  Created by José Luis Corral on 18/12/23.
//

import XCTest

final class LoginTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testFirebaseLogin() throws {
        
        let app = XCUIApplication()
        let credentials:String = "example@example.com"
        
        let usernameTextField = app.textFields["Email"]
        XCTAssertTrue(usernameTextField.exists)
        usernameTextField.tap()
        usernameTextField.typeText(credentials)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordSecureTextField.exists)
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(credentials)
        
        let loginButton = app/*@START_MENU_TOKEN@*/.staticTexts["Log In"]/*[[".buttons[\"Log In\"].staticTexts[\"Log In\"]",".staticTexts[\"Log In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        
        let orderByLabel = app.staticTexts["Order by"]
   
           let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: app.staticTexts["Order by"])
        
           let result = XCTWaiter.wait(for: [expectation], timeout: 10.0)
           if result == .completed {
            
               XCTAssertTrue(orderByLabel.exists)
           } else {
               XCTFail("The Login hasn't succed")
           }
    }
    
    func testGoesToSignUpScreen() {
        
        let app = XCUIApplication()
        
        let goToSignUpButton = app.staticTexts["Sign Up"]
        XCTAssertTrue(goToSignUpButton.exists)
        goToSignUpButton.tap()
        
        let navigationTittle = app.navigationBars["Sign Up"].staticTexts["Sign Up"]
        XCTAssertTrue(navigationTittle.exists)
    }
  
    func testLoginWrentWrong() throws{
        
        let app = XCUIApplication()
        let loginButton = app/*@START_MENU_TOKEN@*/.staticTexts["Log In"]/*[[".buttons[\"Log In\"].staticTexts[\"Log In\"]",".staticTexts[\"Log In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        let alert = app.alerts["Something went wrong"].scrollViews.otherElements.buttons["Ok"]
        XCTAssertTrue(alert.exists)
        
        let loginLabel = XCUIApplication().staticTexts["Please sign in to continue"]
        XCTAssertTrue(loginLabel.exists)
                
    }
    
}
