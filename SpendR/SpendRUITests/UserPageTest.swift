//
//  UserPageTest.swift
//  SpendRUITests
//
//  Created by José Luis Corral on 23/12/23.
//

import XCTest

final class UserPageTest: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testUserScreenElementsDoLoad() throws {
        let app = XCUIApplication()
        let credentials: String = "example@example.com"

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials)

        app.buttons["Log In"].tap()

        XCTAssertTrue(app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).waitForExistence(timeout: 3))

        app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).tap()
        
        XCTAssertTrue( XCUIApplication().navigationBars["User Settings"].staticTexts["User Settings"].exists)
        XCTAssertTrue(app/*@START_MENU_TOKEN@*/.staticTexts["Curreny"]/*[[".buttons[\"Euro\"].staticTexts[\"Curreny\"]",".staticTexts[\"Curreny\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        XCTAssertTrue(app.staticTexts["Tags"].exists)
        XCTAssertTrue(XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.exists)
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.tap()
        XCTAssertTrue(app.staticTexts["New Tag"].exists)
        XCTAssertTrue(XCUIApplication().colorWells.otherElements.children(matching: .button).element.exists)
        XCTAssertTrue(app.staticTexts["Label color"].exists)
        XCTAssertTrue(XCUIApplication().buttons["Edit"].exists)
        XCTAssertTrue(app.staticTexts["Tag icon"].exists)
        XCTAssertTrue( XCUIApplication()/*@START_MENU_TOKEN@*/.buttons["Save Tag"].staticTexts["Save Tag"]/*[[".buttons[\"Save Tag\"].staticTexts[\"Save Tag\"]",".staticTexts[\"Save Tag\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.exists)
        XCTAssertTrue(app/*@START_MENU_TOKEN@*/.buttons["Log out"].staticTexts["Log out"]/*[[".buttons[\"Log out\"].staticTexts[\"Log out\"]",".staticTexts[\"Log out\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.exists)
    }
    
    func testAddTag() {
        let app = XCUIApplication()
                let credentials: String = "example@example.com"

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials)

        app.buttons["Log In"].tap()

        XCTAssertTrue(app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).waitForExistence(timeout: 3))

        app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).tap()
        
        XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
                

        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.tap()
        
        let nameTxTField = app.textFields["Name"]
        nameTxTField.tap()
        nameTxTField.typeText("Art")
        app.colorWells.otherElements.children(matching: .button).element.tap()
        
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.otherElements["oscuro rojo 22"].tap()
        elementsQuery.buttons["cerrar"].tap()
        app.buttons["Edit"].tap()
        app.scrollViews.otherElements.buttons["Markup"].tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Save Tag"]/*[[".buttons[\"Save Tag\"].staticTexts[\"Save Tag\"]",".staticTexts[\"Save Tag\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
   
        app/*@START_MENU_TOKEN@*/.buttons["Art"]/*[[".scrollViews.buttons[\"Art\"]",".buttons[\"Art\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.staticTexts["Art"].tap()
        let deleteTagAlert = app.alerts["Are you sure?"].scrollViews.otherElements.buttons["Cancel"]
                
        XCTAssertTrue(deleteTagAlert.exists)
        
        XCUIApplication().alerts["Are you sure?"].scrollViews.otherElements.buttons["Ok"].tap()
                
    }
    
    func testAddingTagShowsOnMainScreen() throws {
        let app = XCUIApplication()
                let credentials: String = "example@example.com"

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials)

        app.buttons["Log In"].tap()

        XCTAssertTrue(app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).waitForExistence(timeout: 3))

        app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).tap()
        
        XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
                

        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.tap()
        
        let nameTxTField = app.textFields["Name"]
        nameTxTField.tap()
        nameTxTField.typeText("Art")
        app.colorWells.otherElements.children(matching: .button).element.tap()
        
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.otherElements["oscuro rojo 22"].tap()
        elementsQuery.buttons["cerrar"].tap()
        app.buttons["Edit"].tap()
        app.scrollViews.otherElements.buttons["Markup"].tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Save Tag"]/*[[".buttons[\"Save Tag\"].staticTexts[\"Save Tag\"]",".staticTexts[\"Save Tag\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
   
        app.navigationBars["User Settings"].buttons["Home"].tap()
        XCTAssertTrue(app/*@START_MENU_TOKEN@*/.buttons["Art"]/*[[".scrollViews.buttons[\"Art\"]",".buttons[\"Art\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.staticTexts["Art"].exists)
       
        app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).tap()
        app/*@START_MENU_TOKEN@*/.buttons["Art"]/*[[".scrollViews.buttons[\"Art\"]",".buttons[\"Art\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.alerts["Are you sure?"].scrollViews.otherElements.buttons["Ok"].tap()
        
    }
    
    func testLogOutWorks() throws{
        let app = XCUIApplication()
                let credentials: String = "example@example.com"

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials)

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials)

        app.buttons["Log In"].tap()

        XCTAssertTrue(app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).waitForExistence(timeout: 3))

        app.navigationBars["Welcome example"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).tap()
       
        app.buttons["Log out"].tap()
        app.alerts["Are you sure?"].scrollViews.otherElements.buttons["Ok"].tap()
        
        XCTAssertTrue(app.staticTexts["Please sign in to continue"].exists)
                
    }
}
