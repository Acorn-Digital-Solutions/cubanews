//
//  AuthenticationManager.swift
//  cubanews-ios
//
//  Created for Sign in with Apple implementation
//

import Foundation
import AuthenticationServices
import SwiftData

@available(iOS 17, *)
@MainActor
class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadCurrentUser()
    }
    
    /// Load the current user from SwiftData on app launch
    func loadCurrentUser() {
        let descriptor = FetchDescriptor<User>(
            sortBy: [SortDescriptor(\.lastLoginAt, order: .reverse)]
        )
        
        if let users = try? modelContext.fetch(descriptor),
           let user = users.first {
            self.currentUser = user
            self.isAuthenticated = true
            NSLog("✅ Loaded existing user: \(user.displayName)")
        } else {
            self.currentUser = nil
            self.isAuthenticated = false
            NSLog("ℹ️ No existing user found")
        }
    }
    
    /// Handle successful Apple Sign In
    func handleSignInWithApple(
        userId: String,
        email: String?,
        fullName: PersonNameComponents?,
        identityToken: Data?,
        authorizationCode: Data?
    ) {
        // Check if user already exists
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.id == userId }
        )
        
        let existingUser = try? modelContext.fetch(descriptor).first
        
        if let user = existingUser {
            // Update existing user
            user.updateLastLogin()
            
            // Update token information if available
            if let token = identityToken {
                user.identityToken = token.base64EncodedString()
            }
            if let code = authorizationCode {
                user.authorizationCode = code.base64EncodedString()
            }
            
            self.currentUser = user
            NSLog("✅ Updated existing user: \(user.displayName)")
        } else {
            // Create new user
            let newUser = User(
                id: userId,
                email: email,
                fullName: fullName?.formatted(),
                givenName: fullName?.givenName,
                familyName: fullName?.familyName,
                identityToken: identityToken?.base64EncodedString(),
                authorizationCode: authorizationCode?.base64EncodedString()
            )
            
            modelContext.insert(newUser)
            self.currentUser = newUser
            NSLog("✅ Created new user: \(newUser.displayName)")
        }
        
        // Save to SwiftData
        do {
            try modelContext.save()
            self.isAuthenticated = true
        } catch {
            NSLog("❌ Failed to save user: \(error)")
        }
    }
    
    /// Handle sign in failure
    func handleSignInFailure(error: Error) {
        NSLog("❌ Sign in with Apple failed: \(error.localizedDescription)")
        
        // Check if user cancelled
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                NSLog("ℹ️ User cancelled sign in")
            case .failed:
                NSLog("❌ Authorization failed")
            case .invalidResponse:
                NSLog("❌ Invalid response from Apple")
            case .notHandled:
                NSLog("❌ Request not handled")
            case .unknown:
                NSLog("❌ Unknown error")
            @unknown default:
                NSLog("❌ Unexpected error")
            }
        }
    }
    
    /// Sign out the current user
    func signOut() {
        if let user = currentUser {
            // Delete user from SwiftData
            modelContext.delete(user)
            try? modelContext.save()
            NSLog("✅ User signed out and deleted from local storage")
        }
        
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    /// Delete user account
    func deleteAccount() {
        if let user = currentUser {
            modelContext.delete(user)
            try? modelContext.save()
            NSLog("✅ User account deleted")
        }
        
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
