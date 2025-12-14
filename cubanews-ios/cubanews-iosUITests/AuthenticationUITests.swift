//
//  AuthenticationUITests.swift
//  cubanews-iosUITests
//
//  Tests for Apple Sign In authentication flow and related features
//

import XCTest

final class AuthenticationUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Reset app state for authentication tests
        app.launchArguments = ["RESET_USER_DATA"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Launch Screen Tests
    
    @MainActor
    func testAppLaunchShowsLaunchScreen() throws {
        // Verify the launch screen appears with the app logo
        let logo = app.images["cubanewsIdentity"]
        
        // Should show logo on launch (or already past it)
        let logoShown = logo.waitForExistence(timeout: 2)
        let contentShown = app.buttons["Titulares"].waitForExistence(timeout: 3) || 
                          app.buttons.matching(identifier: "Sign in with Apple").firstMatch.waitForExistence(timeout: 3)
        
        XCTAssertTrue(logoShown || contentShown, "Should show launch screen or content after launch")
    }
    
    @MainActor
    func testLaunchScreenDisappearsAfterLoad() throws {
        // Wait for launch screen to disappear
        let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
        let mainContent = app.buttons["Titulares"]
        
        // Should transition to either login screen or main content
        let transitioned = signInButton.waitForExistence(timeout: 5) || mainContent.waitForExistence(timeout: 5)
        XCTAssertTrue(transitioned, "Should transition from launch screen to app content")
    }
    
    // MARK: - Authentication State Tests
    
    @MainActor
    func testUnauthenticatedUserSeesLoginScreen() throws {
        // When not authenticated, should show login screen
        let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
        let mainContent = app.buttons["Titulares"]
        
        // Should show login screen or already authenticated
        let showsLogin = signInButton.waitForExistence(timeout: 5)
        let showsMain = mainContent.waitForExistence(timeout: 5)
        
        XCTAssertTrue(showsLogin || showsMain, "Should show login screen if not authenticated, or main content if authenticated")
    }
    
    @MainActor
    func testAppleSignInButtonAccessibility() throws {
        // Check if login screen is shown
        let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
        
        if signInButton.waitForExistence(timeout: 5) {
            // Verify button is enabled and hittable
            XCTAssertTrue(signInButton.isEnabled, "Sign In button should be enabled")
            XCTAssertTrue(signInButton.isHittable, "Sign In button should be hittable")
        }
    }
    
    // MARK: - Profile Information Tests
    
    @MainActor
    func testProfileDisplaysUserInformation() throws {
        // Skip login if already authenticated
        let titularesTab = app.buttons["Titulares"]
        if !titularesTab.waitForExistence(timeout: 3) {
            // Need to sign in first
            let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
            if signInButton.waitForExistence(timeout: 5) {
                signInButton.tap()
                XCTAssertTrue(titularesTab.waitForExistence(timeout: 10), "Should navigate to main content after sign in")
            }
        }
        
        // Navigate to profile
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Verify user icon is displayed
        let userIcon = app.images.matching(identifier: "person.circle.fill").firstMatch
        XCTAssertTrue(userIcon.waitForExistence(timeout: 5), "Should show user profile icon")
    }
    
    // MARK: - Preferences Tests
    
    @MainActor
    func testPublicationPreferencesDisplay() throws {
        // Navigate to profile after authentication
        let titularesTab = app.buttons["Titulares"]
        if !titularesTab.waitForExistence(timeout: 3) {
            let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
            if signInButton.waitForExistence(timeout: 5) {
                signInButton.tap()
                XCTAssertTrue(titularesTab.waitForExistence(timeout: 10))
            }
        }
        
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Verify preferences section
        let preferencesHeader = app.staticTexts["Preferencias"]
        XCTAssertTrue(preferencesHeader.waitForExistence(timeout: 5), "Should show preferences header")
        
        // Verify description text
        let descriptionText = app.staticTexts["Selecciona tus fuentes de noticias preferidas para personalizar tu feed"]
        XCTAssertTrue(descriptionText.exists, "Should show preferences description")
    }
    
    @MainActor
    func testPublicationPreferencesAreInteractive() throws {
        // Navigate to profile
        let titularesTab = app.buttons["Titulares"]
        if !titularesTab.waitForExistence(timeout: 3) {
            let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
            if signInButton.waitForExistence(timeout: 5) {
                signInButton.tap()
                XCTAssertTrue(titularesTab.waitForExistence(timeout: 10))
            }
        }
        
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Find and interact with a publication button
        let publicationButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS[c] 'CUBA'"))
        XCTAssertGreaterThan(publicationButtons.count, 0, "Should have publication preference buttons")
        
        if publicationButtons.count > 0 {
            let firstButton = publicationButtons.firstMatch
            XCTAssertTrue(firstButton.exists, "Publication button should exist")
            XCTAssertTrue(firstButton.isEnabled, "Publication button should be enabled")
            XCTAssertTrue(firstButton.isHittable, "Publication button should be hittable")
        }
    }
    
    // MARK: - Account Management Tests
    
    @MainActor
    func testDeleteAccountButtonIsVisible() throws {
        // Navigate to profile
        let titularesTab = app.buttons["Titulares"]
        if !titularesTab.waitForExistence(timeout: 3) {
            let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
            if signInButton.waitForExistence(timeout: 5) {
                signInButton.tap()
                XCTAssertTrue(titularesTab.waitForExistence(timeout: 10))
            }
        }
        
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Scroll to account section
        app.swipeUp()
        
        // Verify account management section
        let accountHeader = app.staticTexts["Maneja tu Cuenta"]
        XCTAssertTrue(accountHeader.exists, "Should show account management header")
        
        let deleteButton = app.buttons["Eliminar Cuenta"]
        XCTAssertTrue(deleteButton.exists, "Should show delete account button")
        XCTAssertTrue(deleteButton.isEnabled, "Delete account button should be enabled")
    }
    
    @MainActor
    func testDeleteAccountConfirmationFlow() throws {
        // Navigate to profile
        let titularesTab = app.buttons["Titulares"]
        if !titularesTab.waitForExistence(timeout: 3) {
            let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
            if signInButton.waitForExistence(timeout: 5) {
                signInButton.tap()
                XCTAssertTrue(titularesTab.waitForExistence(timeout: 10))
            }
        }
        
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Scroll to and tap delete account
        app.swipeUp()
        
        let deleteButton = app.buttons["Eliminar Cuenta"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()
        
        // Verify all parts of confirmation dialog
        let alertTitle = app.alerts["¿Eliminar Cuenta?"]
        XCTAssertTrue(alertTitle.waitForExistence(timeout: 3), "Should show delete confirmation alert")
        
        let cancelButton = alertTitle.buttons["Cancelar"]
        XCTAssertTrue(cancelButton.exists, "Should show cancel button")
        
        let deleteConfirmButton = alertTitle.buttons["Eliminar"]
        XCTAssertTrue(deleteConfirmButton.exists, "Should show delete confirmation button")
        
        // Cancel the deletion
        cancelButton.tap()
        
        // Should still be on profile screen
        let preferencesHeader = app.staticTexts["Preferencias"]
        XCTAssertTrue(preferencesHeader.exists, "Should remain on profile screen after canceling")
    }
    
    // MARK: - Privacy and About Section Tests
    
    @MainActor
    func testPrivacyPolicyLinkIsVisible() throws {
        // Navigate to profile
        let titularesTab = app.buttons["Titulares"]
        if !titularesTab.waitForExistence(timeout: 3) {
            let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
            if signInButton.waitForExistence(timeout: 5) {
                signInButton.tap()
                XCTAssertTrue(titularesTab.waitForExistence(timeout: 10))
            }
        }
        
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Scroll to find privacy policy text
        app.swipeUp()
        
        let privacyText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'política de privacidad'")).firstMatch
        XCTAssertTrue(privacyText.waitForExistence(timeout: 5), "Should show privacy policy text")
    }
    
    @MainActor
    func testAboutCubanewsSectionIsVisible() throws {
        // Navigate to profile
        let titularesTab = app.buttons["Titulares"]
        if !titularesTab.waitForExistence(timeout: 3) {
            let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
            if signInButton.waitForExistence(timeout: 5) {
                signInButton.tap()
                XCTAssertTrue(titularesTab.waitForExistence(timeout: 10))
            }
        }
        
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Verify about section
        let aboutHeader = app.staticTexts["Acerca de CubaNews"]
        XCTAssertTrue(aboutHeader.exists, "Should show about CubaNews header")
    }
    
    @MainActor
    func testVersionInfoIsDisplayed() throws {
        // Navigate to profile
        let titularesTab = app.buttons["Titulares"]
        if !titularesTab.waitForExistence(timeout: 3) {
            let signInButton = app.buttons.matching(identifier: "Sign in with Apple").firstMatch
            if signInButton.waitForExistence(timeout: 5) {
                signInButton.tap()
                XCTAssertTrue(titularesTab.waitForExistence(timeout: 10))
            }
        }
        
        let perfilTab = app.buttons["Perfil"]
        XCTAssertTrue(perfilTab.waitForExistence(timeout: 5))
        perfilTab.tap()
        
        // Scroll to bottom
        app.swipeUp()
        app.swipeUp()
        
        // Verify version info
        let versionText = app.staticTexts["Cubanews Version 0.0.1"]
        XCTAssertTrue(versionText.waitForExistence(timeout: 5), "Should show version info")
        
        let copyrightText = app.staticTexts["© Acorn Digital Solutions 2025"]
        XCTAssertTrue(copyrightText.exists, "Should show copyright info")
    }
}
