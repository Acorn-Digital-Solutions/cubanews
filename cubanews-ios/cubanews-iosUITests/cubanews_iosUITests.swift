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
        app.launch()

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }
    
    // MARK: - Login Screen Tests
    
    @MainActor
    func testLoginScreenDisplaysLoginButtons() throws {
        // Verify that the login screen shows the login options
        let googleButton = app.buttons["Continue with Google"]
        let appleButton = app.buttons["Continue with Apple"]
        let facebookButton = app.buttons["Continue with Facebook"]
        
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5), "Google login button should exist")
        XCTAssertTrue(appleButton.exists, "Apple login button should exist")
        XCTAssertTrue(facebookButton.exists, "Facebook login button should exist")
    }
    
    @MainActor
    func testLoginWithGoogleNavigatesToMainContent() throws {
        // Tap Google login button
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Verify we're now on the main content (TabView)
        let titularesTab = app.buttons["Titulares"]
        XCTAssertTrue(titularesTab.waitForExistence(timeout: 5), "Should navigate to main content after login")
    }
    
    @MainActor
    func testLoginWithAppleNavigatesToMainContent() throws {
        // Tap Apple login button
        let appleButton = app.buttons["Continue with Apple"]
        XCTAssertTrue(appleButton.waitForExistence(timeout: 5))
        appleButton.tap()
        
        // Verify we're now on the main content (TabView)
        let titularesTab = app.buttons["Titulares"]
        XCTAssertTrue(titularesTab.waitForExistence(timeout: 5), "Should navigate to main content after login")
    }
    
    @MainActor
    func testLoginWithFacebookNavigatesToMainContent() throws {
        // Tap Facebook login button
        let facebookButton = app.buttons["Continue with Facebook"]
        XCTAssertTrue(facebookButton.waitForExistence(timeout: 5))
        facebookButton.tap()
        
        // Verify we're now on the main content (TabView)
        let titularesTab = app.buttons["Titulares"]
        XCTAssertTrue(titularesTab.waitForExistence(timeout: 5), "Should navigate to main content after login")
    }
    
    // MARK: - Tab Navigation Tests
    
    @MainActor
    func testTabBarNavigation() throws {
        // First login
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Verify all tabs are present
        let titularesTab = app.buttons["Titulares"]
        let guardadosTab = app.buttons["Guardados"]
        let perfilTab = app.buttons["Perfil"]
        
        XCTAssertTrue(titularesTab.waitForExistence(timeout: 5), "Titulares tab should exist")
        XCTAssertTrue(guardadosTab.exists, "Guardados tab should exist")
        XCTAssertTrue(perfilTab.exists, "Perfil tab should exist")
    }
    
    @MainActor
    func testNavigateToSavedStoriesTab() throws {
        // First login
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Navigate to Guardados tab
        let guardadosTab = app.buttons["Guardados"]
        XCTAssertTrue(guardadosTab.waitForExistence(timeout: 5))
        guardadosTab.tap()
        
        // Verify we're on the saved stories screen
        let navigationTitle = app.navigationBars["Guardadas"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 5), "Should show Guardadas navigation title")
    }
    
    @MainActor
    func testNavigateToProfileTab() throws {
        // First login
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Navigate to Perfil tab
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Verify we're on the profile screen by checking for profile elements
        let preferencesHeader = app.staticTexts["Preferencias"]
        XCTAssertTrue(preferencesHeader.waitForExistence(timeout: 5), "Should show Preferencias section")
    }
    
    // MARK: - Saved Stories View Tests
    
    @MainActor
    func testEmptySavedStoriesShowsMessage() throws {
        // First login
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Navigate to Guardados tab
        let guardadosTab = app.buttons["Guardados"]
        XCTAssertTrue(guardadosTab.waitForExistence(timeout: 5))
        guardadosTab.tap()
        
        // Verify empty state message
        let emptyMessage = app.staticTexts["No tienes historias guardadas."]
        XCTAssertTrue(emptyMessage.waitForExistence(timeout: 5), "Should show empty state message")
    }
    
    // MARK: - Profile View Tests
    
    @MainActor
    func testProfileViewShowsPreferences() throws {
        // First login
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Navigate to Perfil tab
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Verify preferences section exists
        let preferencesHeader = app.staticTexts["Preferencias"]
        XCTAssertTrue(preferencesHeader.waitForExistence(timeout: 5), "Should show Preferencias header")
        
        // Verify account section exists
        let accountHeader = app.staticTexts["Cuenta"]
        XCTAssertTrue(accountHeader.exists, "Should show Cuenta header")
    }
    
    @MainActor
    func testProfileViewShowsPublicationOptions() throws {
        // First login
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Navigate to Perfil tab
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Verify publication options exist
        let adnCubaOption = app.staticTexts["AdnCuba"]
        XCTAssertTrue(adnCubaOption.waitForExistence(timeout: 5), "Should show AdnCuba option")
    }
    
    @MainActor
    func testProfileViewShowsAccountButtons() throws {
        // First login
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Navigate to Perfil tab
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Scroll down to account section
        app.swipeUp()
        
        // Verify logout button exists
        let logoutButton = app.buttons["Cerrar Sesion"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "Should show logout button")
        
        // Verify delete account button exists
        let deleteButton = app.buttons["Eliminar Cuenta"]
        XCTAssertTrue(deleteButton.exists, "Should show delete account button")
    }
    
    @MainActor
    func testProfileViewShowsVersionInfo() throws {
        // First login
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Navigate to Perfil tab
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Scroll to bottom
        app.swipeUp()
        
        // Verify version info exists
        let versionText = app.staticTexts["Version 0.0.1"]
        XCTAssertTrue(versionText.waitForExistence(timeout: 5), "Should show version info")
        
        // Verify copyright exists
        let copyrightText = app.staticTexts["© Acorn Digital Solutions 2025"]
        XCTAssertTrue(copyrightText.exists, "Should show copyright info")
    }
    
    @MainActor
    func testDeleteAccountShowsConfirmationDialog() throws {
        // First login
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Navigate to Perfil tab
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
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
        // First login
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5))
        googleButton.tap()
        
        // Verify we're on the feed view with the header
        let titularesHeader = app.staticTexts["Titulares"]
        XCTAssertTrue(titularesHeader.waitForExistence(timeout: 5), "Should show Titulares header")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
