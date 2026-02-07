//
//  cubanews_iosUITests.swift
//  cubanews-iosUITests
//
//

import XCTest

final class cubanews_iosUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchEnvironment["IS_RUNNING_UNIT_TESTS"] = "1"
        app.launch()

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }
    
    private func deleteAccount() {
        
    }
    
    // MARK: - Helper Methods
    private func performLogin() {
        let testLoginButtonById = app.buttons["TestLoginButton"]
        let testLoginButtonByLabel = app.buttons["Test Login"]
        if testLoginButtonById.waitForExistence(timeout: 3) {
            testLoginButtonById.tap()
            return
        } else if testLoginButtonByLabel.waitForExistence(timeout: 1) {
            testLoginButtonByLabel.tap()
            return
        }
        // Wait for main content to load
        let titularesTab = app.buttons["Titulares"]
        XCTAssertTrue(titularesTab.waitForExistence(timeout: 5), "Should navigate to main content after login")
    }
    
    /// Navigates to the specified tab
    private func navigateToTab(_ tabName: String) {
        let tab = app.buttons[tabName]
        XCTAssertTrue(tab.waitForExistence(timeout: 5), "\(tabName) tab should exist")
        tab.tap()
    }
    
    
    // MARK: - Tab Navigation Tests
    
    @MainActor
    func testTabBarNavigation() throws {
        performLogin()
        
        // Verify all tabs are present
        let titularesTab = app.buttons["Titulares"]
        let guardadosTab = app.buttons["Guardados"]
        let perfilTab = app.buttons["Perfil"]
        
        XCTAssertTrue(titularesTab.exists, "Titulares tab should exist")
        XCTAssertTrue(guardadosTab.exists, "Guardados tab should exist")
        XCTAssertTrue(perfilTab.exists, "Perfil tab should exist")
    }
    
    @MainActor
    func testNavigateToProfileTab() throws {
        performLogin()
        navigateToTab("Perfil")
        
        // Verify we're on the profile screen by checking for profile elements
        let preferencesHeader = app.staticTexts["Preferencias"]
        XCTAssertTrue(preferencesHeader.waitForExistence(timeout: 5), "Should show Preferencias section")
    }
    
    // MARK: - Saved Stories View Tests
    
    @MainActor
    func testEmptySavedStoriesShowsMessage() throws {
        performLogin()
        navigateToTab("Guardados")
        
        // Verify empty state message
        let emptyMessage = app.staticTexts["No tienes historias guardadas."]
        XCTAssertTrue(emptyMessage.waitForExistence(timeout: 5), "Should show empty state message")
    }
    
    // MARK: - Profile View Tests
    
    @MainActor
    func testProfileViewShowsPreferences() throws {
        performLogin()
        navigateToTab("Perfil")
        
        // Verify preferences section exists
        let preferencesHeader = app.staticTexts["Preferencias"]
        XCTAssertTrue(preferencesHeader.waitForExistence(timeout: 5), "Should show Preferencias header")

    }
    
    @MainActor
    func testProfileViewShowsAccountSection() throws {
        performLogin()
        navigateToTab("Perfil")
        
        app.swipeUp()

        // Verify account section exists
        let accountHeader = app.staticTexts["Maneja tu Cuenta"]
        XCTAssertTrue(accountHeader.exists, "Should show Cuenta header")
    }
    
    @MainActor
    func testProfileViewShowsAboutCubanewsSection() throws {
        performLogin()
        navigateToTab("Perfil")

        // Verify account section exists
        let accountHeader = app.staticTexts["Acerca de CubaNews"]
        XCTAssertTrue(accountHeader.exists, "Should show About section")
    }
    
        
    @MainActor
    func testProfileViewShowsPublicationOptions() throws {
        performLogin()
        navigateToTab("Perfil")
        
        // Verify publication options exist
        let adnCubaOption = app.buttons["ADN Cuba"]
        XCTAssertTrue(adnCubaOption.waitForExistence(timeout: 5), "Should show AdnCuba button")
    }
    
    @MainActor
    func testProfileViewShowsAccountButtons() throws {
        performLogin()
        navigateToTab("Perfil")
        
        // Scroll down to account section
        app.swipeUp()
        
        // Verify delete account button exists
        let deleteButton = app.buttons["Eliminar Cuenta"]
        XCTAssertTrue(deleteButton.exists, "Should show delete account button")
    }
    
    @MainActor
    func testProfileViewShowsVersionInfo() throws {
        performLogin()
        navigateToTab("Perfil")
        
        // Scroll to bottom
        app.swipeUp()
        
        // Verify version info exists
        let versionText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Cubanews Version'")).firstMatch
        XCTAssertTrue(versionText.waitForExistence(timeout: 5), "Should show version info")
        
        // Verify copyright exists
        let copyrightText = app.staticTexts["© Acorn Digital Solutions 2025"]
        XCTAssertTrue(copyrightText.exists, "Should show copyright info")
    }
    
    @MainActor
    func testDeleteAccountShowsConfirmationDialog() throws {
        performLogin()
        navigateToTab("Perfil")
        
        // Scroll to account section
        app.swipeUp()
        
        // Tap delete account button
        let deleteButton = app.buttons["Eliminar Cuenta"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()
        
        // Verify confirmation dialog appears
        let alertTitle = app.staticTexts["¿Eliminar Cuenta?"]
        XCTAssertTrue(alertTitle.waitForExistence(timeout: 5), "Should show delete confirmation dialog")
        
        // Verify cancel button exists
        let cancelButton = app.buttons["Cancelar"]
        XCTAssertTrue(cancelButton.exists, "Should show cancel button")
        
        // Dismiss dialog
        cancelButton.tap()
    }
    
    // MARK: - Feed View Tests
    
    @MainActor
    func testFeedViewShowsHeader() throws {
        performLogin()
        
        // Verify we're on the feed view with the header
        let titularesHeader = app.staticTexts["Titulares"]
        XCTAssertTrue(titularesHeader.waitForExistence(timeout: 5), "Should show Titulares header")
    }
}
