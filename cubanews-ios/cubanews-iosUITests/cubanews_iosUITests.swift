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
    
    // MARK: - Helper Methods
    
    /// Performs Apple Sign In and waits for the main content to appear
    private func performLogin() {
        // Since Apple Sign In button is now the primary method
        let appleSignInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
        
        if appleSignInButton.waitForExistence(timeout: 5) {
            appleSignInButton.tap()
            
            // Wait for main content to load
            let titularesTab = app.buttons["Titulares"]
            XCTAssertTrue(titularesTab.waitForExistence(timeout: 10), "Should navigate to main content after login")
        } else {
            // If already logged in, should see main content
            let titularesTab = app.buttons["Titulares"]
            XCTAssertTrue(titularesTab.waitForExistence(timeout: 5), "Should be on main content if already authenticated")
        }
    }
    
    /// Navigates to the specified tab
    private func navigateToTab(_ tabName: String) {
        let tab = app.buttons[tabName]
        XCTAssertTrue(tab.waitForExistence(timeout: 5), "\(tabName) tab should exist")
        tab.tap()
    }
    
    // MARK: - Login Screen Tests
    
    @MainActor
    func testLoginScreenDisplaysAppleSignInButton() throws {
        // Verify that the login screen shows Apple Sign In button
        let appleSignInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
        
        XCTAssertTrue(appleSignInButton.waitForExistence(timeout: 5), "Apple Sign In button should exist")
    }
    
    @MainActor
    func testLoginScreenDisplaysAppLogo() throws {
        // Verify the app shows the Cuba News logo on login screen
        let logoImage = app.images["cubanewsIdentity"]
        let appTitle = app.staticTexts["Cuba News"]
        
        XCTAssertTrue(logoImage.waitForExistence(timeout: 5) || appTitle.waitForExistence(timeout: 5), 
                     "Login screen should show app logo or title")
    }
    
    @MainActor
    func testAppleSignInNavigatesToMainContent() throws {
        let appleSignInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
        
        if appleSignInButton.waitForExistence(timeout: 5) {
            appleSignInButton.tap()
            
            // Verify we're now on the main content (TabView)
            let titularesTab = app.buttons["Titulares"]
            XCTAssertTrue(titularesTab.waitForExistence(timeout: 10), "Should navigate to main content after Apple Sign In")
        } else {
            // Already authenticated, skip test
            let titularesTab = app.buttons["Titulares"]
            XCTAssertTrue(titularesTab.waitForExistence(timeout: 5), "Already authenticated")
        }
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
    func testProfileViewShowsUserName() throws {
        performLogin()
        navigateToTab("Perfil")
        
        // Verify user name or default name is shown
        // The name could be "Usuario Anónimo" or the actual user's name from Apple Sign In
        let hasUserIcon = app.images.matching(identifier: "person.circle.fill").firstMatch.exists
        XCTAssertTrue(hasUserIcon, "Should show user icon")
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
        let adnCubaOption = app.buttons["ADNCUBA"]
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
        let versionText = app.staticTexts["Cubanews Version 0.0.1"]
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
        
        // Verify message about irreversibility
        let alertMessage = app.staticTexts["Esta acción no se puede deshacer. Todos tus datos serán eliminados permanentemente."]
        XCTAssertTrue(alertMessage.exists, "Should show warning message")
        
        // Verify cancel button exists
        let cancelButton = app.buttons["Cancelar"]
        XCTAssertTrue(cancelButton.exists, "Should show cancel button")
        
        // Verify delete button exists
        let confirmDeleteButton = app.buttons["Eliminar"]
        XCTAssertTrue(confirmDeleteButton.exists, "Should show delete confirmation button")
        
        // Dismiss dialog
        cancelButton.tap()
    }
    
    @MainActor
    func testLaunchScreenDisplaysBeforeContent() throws {
        // Test that launch screen with logo appears briefly
        // This test verifies the loading state implementation
        
        // The launch screen should show the app logo
        let logo = app.images["cubanewsIdentity"]
        
        // Either we see the logo briefly, or we're already past it to main content
        let logoExists = logo.waitForExistence(timeout: 2)
        let mainContentExists = app.buttons["Titulares"].waitForExistence(timeout: 3)
        
        XCTAssertTrue(logoExists || mainContentExists, "Should show either launch screen or main content")
    }
    
    @MainActor
    func testPreferencesPublicationsToggle() throws {
        performLogin()
        navigateToTab("Perfil")
        
        // Find and tap a publication preference
        let adnCubaButton = app.buttons["ADNCUBA"]
        XCTAssertTrue(adnCubaButton.waitForExistence(timeout: 5), "Should show publication preference button")
        
        // Toggle the preference
        adnCubaButton.tap()
        
        // Wait for the UI to update after toggle
        // The button should remain visible but its state may change
        _ = adnCubaButton.waitForExistence(timeout: 2)
        
        // The button should still exist (just changed state)
        XCTAssertTrue(adnCubaButton.exists, "Button should still exist after toggle")
    }
    
    // MARK: - Feed View Tests
    
    @MainActor
    func testFeedViewShowsHeader() throws {
        performLogin()
        
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
