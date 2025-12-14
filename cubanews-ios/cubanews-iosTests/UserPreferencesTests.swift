//
//  UserPreferencesTests.swift
//  cubanews-iosTests
//

import Testing
import Foundation
import SwiftData
@testable import cubanews_ios

@available(iOS 17, *)
struct UserPreferencesTests {
    
    @Test func testUserPreferencesInitializationWithDefaults() throws {
        let prefs = UserPreferences()
        
        #expect(prefs.id == "default")
        #expect(prefs.preferredPublications.isEmpty)
        #expect(prefs.userEmail == nil)
        #expect(prefs.userFullName == nil)
        #expect(prefs.appleUserID == nil)
    }
    
    @Test func testUserPreferencesInitializationWithEmail() throws {
        let prefs = UserPreferences(
            userEmail: "test@example.com",
            userFullName: "Test User",
            appleUserID: "001234.abc123.5678"
        )
        
        #expect(prefs.id == "default")
        #expect(prefs.preferredPublications.isEmpty)
        #expect(prefs.userEmail == "test@example.com")
        #expect(prefs.userFullName == "Test User")
        #expect(prefs.appleUserID == "001234.abc123.5678")
    }
    
    @Test func testUserPreferencesWithPreferredPublications() throws {
        let publications = ["ADNCUBA", "CIBERCUBA", "ELTOQUE"]
        let prefs = UserPreferences(
            preferredPublications: publications,
            userEmail: "user@test.com",
            userFullName: "John Doe",
            appleUserID: "apple123"
        )
        
        #expect(prefs.preferredPublications == publications)
        #expect(prefs.userEmail == "user@test.com")
        #expect(prefs.userFullName == "John Doe")
        #expect(prefs.appleUserID == "apple123")
    }
    
    @Test func testUserPreferencesCustomID() throws {
        let prefs = UserPreferences(id: "custom-id")
        
        #expect(prefs.id == "custom-id")
        #expect(prefs.preferredPublications.isEmpty)
    }
    
    @Test func testUserPreferencesAppleUserIDOnly() throws {
        // Test case where only appleUserID is provided (subsequent sign-ins)
        let prefs = UserPreferences(appleUserID: "apple456")
        
        #expect(prefs.appleUserID == "apple456")
        #expect(prefs.userEmail == nil)
        #expect(prefs.userFullName == nil)
    }
    
    @Test func testUserPreferencesPartialInfo() throws {
        // Test with only email, no full name
        let prefs = UserPreferences(userEmail: "partial@test.com", appleUserID: "apple789")
        
        #expect(prefs.userEmail == "partial@test.com")
        #expect(prefs.userFullName == nil)
        #expect(prefs.appleUserID == "apple789")
    }
    
    @Test func testUserPreferencesUpdatePublications() throws {
        let prefs = UserPreferences()
        
        #expect(prefs.preferredPublications.isEmpty)
        
        // Add publications
        prefs.preferredPublications = ["ADNCUBA", "CUBANET"]
        
        #expect(prefs.preferredPublications.count == 2)
        #expect(prefs.preferredPublications.contains("ADNCUBA"))
        #expect(prefs.preferredPublications.contains("CUBANET"))
    }
    
    @Test func testUserPreferencesUpdateAppleUserID() throws {
        let prefs = UserPreferences(userEmail: "test@example.com")
        
        #expect(prefs.appleUserID == nil)
        
        // Update with Apple user ID
        prefs.appleUserID = "new_apple_id"
        
        #expect(prefs.appleUserID == "new_apple_id")
    }
    
    @Test func testUserPreferencesUpdateUserInfo() throws {
        let prefs = UserPreferences(appleUserID: "apple_id_123")
        
        #expect(prefs.userEmail == nil)
        #expect(prefs.userFullName == nil)
        
        // Update user info (simulating first sign-in data)
        prefs.userEmail = "updated@example.com"
        prefs.userFullName = "Updated Name"
        
        #expect(prefs.userEmail == "updated@example.com")
        #expect(prefs.userFullName == "Updated Name")
        #expect(prefs.appleUserID == "apple_id_123")
    }
}
