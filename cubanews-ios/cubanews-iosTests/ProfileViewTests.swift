//
//  ProfileViewTests.swift
//  cubanews-iosTests
//
//  Unit tests for ProfileView functionality
//

import Testing
import Foundation
import SwiftData
@testable import cubanews_ios

@available(iOS 17, *)
struct ProfileViewTests {
    
    // MARK: - Publication Preference Tests
    
    @Test func testPreferredPublicationsInitiallyEmpty() throws {
        let prefs = UserPreferences()
        #expect(prefs.preferredPublications.isEmpty)
    }
    
    @Test func testAddingPublicationPreference() throws {
        let prefs = UserPreferences()
        prefs.preferredPublications = ["ADNCUBA"]
        
        #expect(prefs.preferredPublications.count == 1)
        #expect(prefs.preferredPublications.contains("ADNCUBA"))
    }
    
    @Test func testAddingMultiplePublicationPreferences() throws {
        let prefs = UserPreferences()
        prefs.preferredPublications = ["ADNCUBA", "CIBERCUBA", "ELTOQUE"]
        
        #expect(prefs.preferredPublications.count == 3)
        #expect(prefs.preferredPublications.contains("ADNCUBA"))
        #expect(prefs.preferredPublications.contains("CIBERCUBA"))
        #expect(prefs.preferredPublications.contains("ELTOQUE"))
    }
    
    @Test func testRemovingPublicationPreference() throws {
        let prefs = UserPreferences(preferredPublications: ["ADNCUBA", "CIBERCUBA"])
        
        #expect(prefs.preferredPublications.count == 2)
        
        prefs.preferredPublications = prefs.preferredPublications.filter { $0 != "ADNCUBA" }
        
        #expect(prefs.preferredPublications.count == 1)
        #expect(!prefs.preferredPublications.contains("ADNCUBA"))
        #expect(prefs.preferredPublications.contains("CIBERCUBA"))
    }
    
    @Test func testClearingAllPublicationPreferences() throws {
        let prefs = UserPreferences(preferredPublications: ["ADNCUBA", "CIBERCUBA", "ELTOQUE"])
        
        #expect(prefs.preferredPublications.count == 3)
        
        prefs.preferredPublications = []
        
        #expect(prefs.preferredPublications.isEmpty)
    }
    
    @Test func testPublicationPreferencesWithAllSources() throws {
        // Test with all possible news sources (excluding .unknown)
        let allSources = NewsSourceName.allCases
            .filter { $0 != .unknown }
            .map { $0.rawValue }
        
        let prefs = UserPreferences(preferredPublications: allSources)
        
        #expect(prefs.preferredPublications.count == allSources.count)
        
        for source in allSources {
            #expect(prefs.preferredPublications.contains(source))
        }
    }
    
    // MARK: - User Information Tests
    
    @Test func testUserFullNameDefaultsToNil() throws {
        let prefs = UserPreferences()
        #expect(prefs.userFullName == nil)
    }
    
    @Test func testUserEmailDefaultsToNil() throws {
        let prefs = UserPreferences()
        #expect(prefs.userEmail == nil)
    }
    
    @Test func testAppleUserIDDefaultsToNil() throws {
        let prefs = UserPreferences()
        #expect(prefs.appleUserID == nil)
    }
    
    @Test func testSettingUserInformationAfterCreation() throws {
        let prefs = UserPreferences()
        
        prefs.userEmail = "newuser@example.com"
        prefs.userFullName = "New User"
        prefs.appleUserID = "apple_new_id"
        
        #expect(prefs.userEmail == "newuser@example.com")
        #expect(prefs.userFullName == "New User")
        #expect(prefs.appleUserID == "apple_new_id")
    }
    
    @Test func testUpdatingUserEmail() throws {
        let prefs = UserPreferences(userEmail: "old@example.com")
        
        #expect(prefs.userEmail == "old@example.com")
        
        prefs.userEmail = "new@example.com"
        
        #expect(prefs.userEmail == "new@example.com")
    }
    
    @Test func testUpdatingUserFullName() throws {
        let prefs = UserPreferences(userFullName: "Old Name")
        
        #expect(prefs.userFullName == "Old Name")
        
        prefs.userFullName = "New Name"
        
        #expect(prefs.userFullName == "New Name")
    }
    
    // MARK: - Integration Tests
    
    @Test func testCompleteUserProfileSetup() throws {
        // Simulate complete user setup flow
        let prefs = UserPreferences()
        
        // Step 1: Apple Sign In with user info (first time)
        prefs.appleUserID = "001234.abc.5678"
        prefs.userEmail = "user@icloud.com"
        prefs.userFullName = "John Appleseed"
        
        #expect(prefs.appleUserID == "001234.abc.5678")
        #expect(prefs.userEmail == "user@icloud.com")
        #expect(prefs.userFullName == "John Appleseed")
        
        // Step 2: User sets publication preferences
        prefs.preferredPublications = ["ADNCUBA", "ELTOQUE"]
        
        #expect(prefs.preferredPublications.count == 2)
        
        // Step 3: User adds more publications
        prefs.preferredPublications.append("CUBANET")
        
        #expect(prefs.preferredPublications.count == 3)
        #expect(prefs.preferredPublications.contains("CUBANET"))
    }
    
    @Test func testSubsequentSignInWithOnlyAppleUserID() throws {
        // Simulate subsequent sign-in where Apple only provides appleUserID
        let prefs = UserPreferences(
            userEmail: "existing@icloud.com",
            userFullName: "Existing User",
            appleUserID: "001234.abc.5678"
        )
        
        // On subsequent sign-in, only appleUserID is provided
        let subsequentAppleUserID = "001234.abc.5678"
        
        // Verify existing data is preserved
        #expect(prefs.appleUserID == subsequentAppleUserID)
        #expect(prefs.userEmail == "existing@icloud.com")
        #expect(prefs.userFullName == "Existing User")
    }
    
    @Test func testUserPreferencesWithEmptyStrings() throws {
        // Test handling of empty strings vs nil
        let prefs = UserPreferences(userEmail: "", userFullName: "")
        
        #expect(prefs.userEmail == "")
        #expect(prefs.userFullName == "")
        #expect(prefs.userEmail != nil) // Empty string is different from nil
    }
    
    @Test func testUniqueIDConstraint() throws {
        let prefs1 = UserPreferences(id: "default")
        let prefs2 = UserPreferences(id: "default")
        
        // Both can have the same ID in memory, but SwiftData should enforce uniqueness
        #expect(prefs1.id == prefs2.id)
    }
}
