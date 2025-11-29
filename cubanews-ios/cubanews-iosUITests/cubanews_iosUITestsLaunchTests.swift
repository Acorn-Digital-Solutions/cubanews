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
    
    // MARK: - Helper Methods
    
    /// Performs login using the Google button
    private func performLogin(app: XCUIApplication) {
        let googleButton = app.buttons["Continue with Google"]
        if googleButton.waitForExistence(timeout: 5) {
            googleButton.tap()
        }
    }
    
    /// Navigates to the specified tab
    private func navigateToTab(_ tabName: String, app: XCUIApplication) {
        let tab = app.buttons[tabName]
        if tab.waitForExistence(timeout: 5) {
            tab.tap()
        }
    }
    
    /// Takes a screenshot with the given name and adds it to the test
    private func captureScreenshot(named name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Take a screenshot of the launch screen (Login View)
        captureScreenshot(named: "Launch Screen", app: app)
    }
    
    @MainActor
    func testLaunchToFeedView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Login to the app
        performLogin(app: app)
        
        // Wait for feed view to load
        let titularesHeader = app.staticTexts["Titulares"]
        XCTAssertTrue(titularesHeader.waitForExistence(timeout: 5))
        
        // Take a screenshot of the feed view
        captureScreenshot(named: "Feed View", app: app)
    }
    
    @MainActor
    func testLaunchToSavedStoriesView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Login to the app
        performLogin(app: app)
        
        // Navigate to saved stories
        navigateToTab("Guardados", app: app)
        
        // Take a screenshot of the saved stories view
        captureScreenshot(named: "Saved Stories View", app: app)
    }
    
    @MainActor
    func testLaunchToProfileView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Login to the app
        performLogin(app: app)
        
        // Navigate to profile
        navigateToTab("Perfil", app: app)
        
        // Take a screenshot of the profile view
        captureScreenshot(named: "Profile View", app: app)
    }
}
