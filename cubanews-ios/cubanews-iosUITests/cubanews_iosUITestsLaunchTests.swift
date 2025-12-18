//
//  cubanews_iosUITestsLaunchTests.swift
//  cubanews-iosUITests
//
//

import XCTest

final class cubanews_iosUITestsLaunchTests: XCTestCase {

    // Shared app instance for all tests so we can set launchEnvironment once
    var app: XCUIApplication!

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Initialize the shared app and set the test flag so the app under test sees it
        app = XCUIApplication()
        app.launchEnvironment["IS_RUNNING_UNIT_TESTS"] = "1"
    }
    
    // MARK: - Helper Methods
    
    /// Performs login using the Test Login button when available, otherwise falls back to the Google button
    private func performLogin(app: XCUIApplication) {
        // First try the test-only button (accessibilityIdentifier: TestLoginButton)
        let testLoginButtonById = app.buttons["TestLoginButton"]
        let testLoginButtonByLabel = app.buttons["Test Login"]
        if testLoginButtonById.waitForExistence(timeout: 3) {
            testLoginButtonById.tap()
            return
        } else if testLoginButtonByLabel.waitForExistence(timeout: 1) {
            testLoginButtonByLabel.tap()
            return
        }

        // Fallback to Google button for environments where the test button isn't shown
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
        app.launch()

        // Take a screenshot of the launch screen (Login View)
        captureScreenshot(named: "Launch Screen", app: app)
    }
    
    @MainActor
    func testLaunchToFeedView() throws {
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
        app.launch()
        
        // Login to the app
        performLogin(app: app)
        
        // Navigate to profile
        navigateToTab("Perfil", app: app)
        
        // Take a screenshot of the profile view
        captureScreenshot(named: "Profile View", app: app)
    }
}
