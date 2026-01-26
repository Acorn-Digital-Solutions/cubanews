//
//  AppleSignInView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 10/01/2026.
//
import SwiftUI
import AuthenticationServices
import SwiftData
import FirebaseAuth
import CryptoKit

@available(iOS 17, *)
struct AppleSignInView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    private static let TAG = "cubanews_iosApp"
    // Nonce used for Firebase Apple Sign In
    @State private var currentNonce: String?
    
    // Detect test environment: XCTest presence or custom env var
    private var isRunningTests: Bool {
        if ProcessInfo.processInfo.environment["IS_RUNNING_UNIT_TESTS"] == "1" { return true }
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return true }
        if NSClassFromString("XCTest") != nil { return true }
        return false
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randoms: [UInt8] = [0]
            let count = 16
            randoms = (0..<count).map { _ in UInt8.random(in: 0...255) }
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random) % charset.count])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
    
    /// SHA256 hash of the given string, returned as a hex string.
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // Persist or update UserPreferences in SwiftData
    private func persistPreferences(id: String, email: String?, fullName: String?, appleUserID: String?) {
        if let existing = preferences.first {
            existing.id = id
            existing.userEmail = email ?? existing.userEmail
            existing.userFullName = fullName ?? existing.userFullName
            existing.appleUserID = appleUserID ?? existing.appleUserID
            try? modelContext.save()
            NSLog("➡️ \(Self.TAG) Updated existing UserPreferences (persistPreferences)")
        } else {
            let prefs = UserPreferences(id: id, userEmail: email, userFullName: fullName, appleUserID: appleUserID)
            modelContext.insert(prefs)
            try? modelContext.save()
            print("➡️ \(Self.TAG) Created new UserPreferences (persistPreferences)")
        }
    }
    
    var body: some View {
        // Apple Login Button
        if isRunningTests {
            Button("Test Login") {
                // Create or update a simple test UserPreferences to simulate login
                if let existing = preferences.first {
                    existing.userEmail = existing.userEmail ?? "test@example.com"
                    existing.userFullName = existing.userFullName ?? "Joe Test"
                    existing.appleUserID = existing.appleUserID ?? "uitest-user"
                    try? modelContext.save()
                    NSLog("➡️ \(Self.TAG) Test Login: updated existing UserPreferences")
                } else {
                    let prefs = UserPreferences(userEmail: "test@example.com", userFullName: "UI Test", appleUserID: "uitest-user")
                    modelContext.insert(prefs)
                    try? modelContext.save()
                    NSLog("➡️ \(Self.TAG) Test Login: created UserPreferences")
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("TestLoginButton")
        }
        
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
                // Generate and store nonce for Firebase exchange
                let nonce = randomNonceString()
                currentNonce = nonce
                request.nonce = sha256(nonce)
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    NSLog("➡️ \(Self.TAG) Authorization successful. \(String(describing: authResults))")
                    if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                        let email = credential.email
                        let fullName = credential.fullName.flatMap { PersonNameComponentsFormatter().string(from: $0) }
                        let appleUserID = credential.user

                        NSLog("➡️ \(Self.TAG) Authorization successful. email: \(String(describing: email)), name: \(String(describing: fullName))")
                        
                        guard let nonce = currentNonce else {
                          fatalError("Invalid state: A login callback was received, but no login request was sent.")
                        }
                        guard let appleIDToken = credential.identityToken else {
                          print("Unable to fetch identity token")
                          return
                        }
                        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                          return
                        }
                        
                        let firebaseCredential = OAuthProvider.appleCredential(
                            withIDToken: idTokenString,
                            rawNonce: nonce,
                            fullName: credential.fullName
                        )
                        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
                            if let error = error {
                                NSLog("➡️ \(Self.TAG) Firebase sign-in failed: \(error.localizedDescription)")
                                
                                // Log failed Firebase authentication as a separate event
                                AnalyticsService.shared.logEvent("firebase_auth_failed", parameters: [
                                    "method": "apple",
                                    "error": error.localizedDescription
                                ])
                                
                                // Fallback: persist locally using whatever Apple provided
                                persistPreferences(id: appleUserID, email: email, fullName: fullName, appleUserID: appleUserID)
                                
                                // Log successful login to analytics (Apple Sign In succeeded even though Firebase failed)
                                AnalyticsService.shared.logLogin(method: "apple")
                                AnalyticsService.shared.setUserId(appleUserID)
                                return
                            }

                            // Firebase sign-in succeeded. Persist preferences merging available info.
                            let user = authResult?.user ?? Auth.auth().currentUser
                            let firebaseEmail = user?.email
                            let displayName = user?.displayName ?? fullName
                            NSLog("➡️ \(Self.TAG) Firebase sign-in succeeded. uid: \(user?.uid ?? "<none>") email: \(firebaseEmail ?? "<none>")")
                            persistPreferences(id: user?.uid ?? appleUserID, email: firebaseEmail ?? email, fullName: displayName, appleUserID: appleUserID)
                            
                            // Log successful login to analytics
                            AnalyticsService.shared.logLogin(method: "apple")
                            if let userId = user?.uid {
                                AnalyticsService.shared.setUserId(userId)
                            }
                        }
                    }
                case .failure(let error):
                    // Handle error
                    print("➡️ \(Self.TAG) Authorization failed: \(error)")
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 45)
        .padding()
    }
}

#Preview {
    AppleSignInView()
}

