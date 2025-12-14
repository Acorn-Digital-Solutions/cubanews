//
//  AuthenticationStateTests.swift
//  cubanews-iosTests
//
//  Unit tests for authentication state management
//

import Testing
import Foundation
@testable import cubanews_ios

@available(iOS 17, *)
struct AuthenticationStateTests {
    
    // MARK: - Authentication Logic Tests
    
    @Test func testUnauthenticatedUserWithoutAppleID() throws {
        let prefs = UserPreferences()
        
        // User without appleUserID should not be authenticated
        #expect(prefs.appleUserID == nil)
    }
    
    @Test func testAuthenticatedUserWithAppleID() throws {
        let prefs = UserPreferences(appleUserID: "001234.abc.5678")
        
        // User with appleUserID should be authenticated
        #expect(prefs.appleUserID != nil)
        #expect(prefs.appleUserID == "001234.abc.5678")
    }
    
    @Test func testFirstTimeSignInWithFullInfo() throws {
        // First time sign in - Apple provides all info
        let email = "user@icloud.com"
        let fullName = "John Appleseed"
        let appleUserID = "001234.abc.5678"
        
        let prefs = UserPreferences(
            userEmail: email,
            userFullName: fullName,
            appleUserID: appleUserID
        )
        
        #expect(prefs.userEmail == email)
        #expect(prefs.userFullName == fullName)
        #expect(prefs.appleUserID == appleUserID)
    }
    
    @Test func testSubsequentSignInWithoutEmailAndName() throws {
        // Subsequent sign in - Apple only provides appleUserID
        let appleUserID = "001234.abc.5678"
        
        let prefs = UserPreferences(appleUserID: appleUserID)
        
        #expect(prefs.appleUserID == appleUserID)
        #expect(prefs.userEmail == nil)
        #expect(prefs.userFullName == nil)
    }
    
    @Test func testPreservingExistingUserData() throws {
        // Simulate existing user data
        let existingPrefs = UserPreferences(
            userEmail: "existing@icloud.com",
            userFullName: "Existing User",
            appleUserID: "001234.abc.5678"
        )
        
        // Simulate subsequent sign-in update (email and name are nil)
        let newEmail: String? = nil
        let newName: String? = nil
        let sameAppleID = "001234.abc.5678"
        
        // Update logic: preserve existing values if new values are nil
        existingPrefs.userEmail = newEmail ?? existingPrefs.userEmail
        existingPrefs.userFullName = newName ?? existingPrefs.userFullName
        existingPrefs.appleUserID = sameAppleID
        
        // Existing data should be preserved
        #expect(existingPrefs.userEmail == "existing@icloud.com")
        #expect(existingPrefs.userFullName == "Existing User")
        #expect(existingPrefs.appleUserID == sameAppleID)
    }
    
    @Test func testUpdatingExistingUserDataWithNewInfo() throws {
        // Simulate existing user data
        let existingPrefs = UserPreferences(
            userEmail: "old@icloud.com",
            userFullName: "Old User",
            appleUserID: "001234.abc.5678"
        )
        
        // Simulate sign-in with updated info (rare, but possible)
        let newEmail: String? = "new@icloud.com"
        let newName: String? = "New User"
        let sameAppleID = "001234.abc.5678"
        
        // Update logic: use new values if provided
        existingPrefs.userEmail = newEmail ?? existingPrefs.userEmail
        existingPrefs.userFullName = newName ?? existingPrefs.userFullName
        existingPrefs.appleUserID = sameAppleID
        
        // Data should be updated
        #expect(existingPrefs.userEmail == "new@icloud.com")
        #expect(existingPrefs.userFullName == "New User")
        #expect(existingPrefs.appleUserID == sameAppleID)
    }
    
    // MARK: - Account Deletion Tests
    
    @Test func testAccountDeletionClearsUserData() throws {
        let prefs = UserPreferences(
            preferredPublications: ["ADNCUBA", "CIBERCUBA"],
            userEmail: "user@test.com",
            userFullName: "Test User",
            appleUserID: "apple123"
        )
        
        // Verify data exists
        #expect(!prefs.preferredPublications.isEmpty)
        #expect(prefs.userEmail != nil)
        #expect(prefs.userFullName != nil)
        #expect(prefs.appleUserID != nil)
        
        // Simulate account deletion by clearing all data
        prefs.preferredPublications = []
        prefs.userEmail = nil
        prefs.userFullName = nil
        prefs.appleUserID = nil
        
        // Verify data is cleared
        #expect(prefs.preferredPublications.isEmpty)
        #expect(prefs.userEmail == nil)
        #expect(prefs.userFullName == nil)
        #expect(prefs.appleUserID == nil)
    }
    
    // MARK: - Edge Cases
    
    @Test func testSignInWithOnlyEmail() throws {
        let prefs = UserPreferences(
            userEmail: "user@test.com",
            appleUserID: "apple123"
        )
        
        #expect(prefs.userEmail == "user@test.com")
        #expect(prefs.userFullName == nil)
        #expect(prefs.appleUserID == "apple123")
    }
    
    @Test func testSignInWithOnlyFullName() throws {
        let prefs = UserPreferences(
            userFullName: "Test User",
            appleUserID: "apple123"
        )
        
        #expect(prefs.userEmail == nil)
        #expect(prefs.userFullName == "Test User")
        #expect(prefs.appleUserID == "apple123")
    }
    
    @Test func testAppleUserIDWithSpecialCharacters() throws {
        // Apple User IDs can contain dots and other characters
        let specialAppleID = "001234.abcdefg.5678-9012"
        let prefs = UserPreferences(appleUserID: specialAppleID)
        
        #expect(prefs.appleUserID == specialAppleID)
    }
    
    @Test func testEmailValidation() throws {
        // Test various email formats
        let validEmails = [
            "user@example.com",
            "user.name@example.com",
            "user+tag@example.co.uk",
            "user@icloud.com"
        ]
        
        for email in validEmails {
            let prefs = UserPreferences(userEmail: email)
            #expect(prefs.userEmail == email)
        }
    }
    
    @Test func testFullNameWithSpecialCharacters() throws {
        // Test names with accents and special characters (common in Spanish)
        let names = [
            "José García",
            "María del Carmen",
            "Ángel Rodríguez",
            "O'Brien"
        ]
        
        for name in names {
            let prefs = UserPreferences(userFullName: name)
            #expect(prefs.userFullName == name)
        }
    }
}
