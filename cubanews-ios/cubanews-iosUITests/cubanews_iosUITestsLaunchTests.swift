//
//  cubanews_iosUITestsLaunchTests.swift
//  cubanews-iosUITests
//
//

import XCTest

final class cubanews_iosUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Take a screenshot of the launch screen (Login View)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchToFeedView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Login to the app
        let googleButton = app.buttons["Continue with Google"]
        if googleButton.waitForExistence(timeout: 5) {
            googleButton.tap()
        }
        
        // Wait for feed view to load
        let titularesHeader = app.staticTexts["Titulares"]
        XCTAssertTrue(titularesHeader.waitForExistence(timeout: 5))
        
        // Take a screenshot of the feed view
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Feed View"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchToSavedStoriesView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Login to the app
        let googleButton = app.buttons["Continue with Google"]
        if googleButton.waitForExistence(timeout: 5) {
            googleButton.tap()
        }
        
        // Navigate to saved stories
        let guardadosTab = app.buttons["Guardados"]
        if guardadosTab.waitForExistence(timeout: 5) {
            guardadosTab.tap()
        }
        
        // Take a screenshot of the saved stories view
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Saved Stories View"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchToProfileView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Login to the app
        let googleButton = app.buttons["Continue with Google"]
        if googleButton.waitForExistence(timeout: 5) {
            googleButton.tap()
        }
        
        // Navigate to profile
        let perfilTab = app.buttons["Perfil"]
        if perfilTab.waitForExistence(timeout: 5) {
            perfilTab.tap()
        }
        
        // Take a screenshot of the profile view
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Profile View"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
