//
//  LoginView.swift
//  cubanews-ios
//

import SwiftUI
import AuthenticationServices
import SwiftData

@available(iOS 17, *)
struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    private static let TAG = "cubanews_iosApp"

    // Detect test environment: XCTest presence or custom env var
    private var isRunningTests: Bool {
        if ProcessInfo.processInfo.environment["IS_RUNNING_UNIT_TESTS"] == "1" { return true }
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return true }
        if NSClassFromString("XCTest") != nil { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App Logo/Title
            VStack(spacing: 10) {
                Image("cubanewsIdentity")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 250, height: 250)
                Text("Cuba News").font(.largeTitle).fontWeight(.bold)

            }
            .padding(.bottom, 50)

            // Login Buttons
            VStack(spacing: 16) {
                // Test-only login button: only visible while running tests
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
                
                // Apple Login Button
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            NSLog("➡️ \(Self.TAG) Authorization successful. \(String(describing: authResults))")
                            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                let email = credential.email
                                let fullName = credential.fullName.flatMap { PersonNameComponentsFormatter().string(from: $0) }
                                let appleUserID = credential.user
                                // Save the Apple user identifier at minimum. The email and full name
                                // are only provided by Apple the first time a user signs in. Relying
                                // on them prevents subsequent sign-ins from being recorded.
                                NSLog("➡️ \(Self.TAG) Authorization successful. email: \(String(describing: email)), name: \(String(describing: fullName))")
                                if let existing = preferences.first {
                                    // Update fields that are available (may be nil)
                                    existing.userEmail = email ?? existing.userEmail
                                    existing.userFullName = fullName ?? existing.userFullName
                                    existing.appleUserID = credential.user
                                    try? modelContext.save()
                                    NSLog("➡️ \(Self.TAG) Updated existing UserPreferences")
                                } else {
                                    // Create with whatever data we have (appleUserID is always present)
                                    let prefs = UserPreferences(userEmail: email, userFullName: fullName, appleUserID: appleUserID)
                                    modelContext.insert(prefs)
                                    try? modelContext.save()
                                    NSLog("➡️ \(Self.TAG) Created new UserPreferences")
                                }
                            }
                        case .failure(let error):
                            // Handle error
                            NSLog("➡️ \(Self.TAG) Authorization failed: \(error)")
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 45)
                .padding()
            }
            .padding(.horizontal, 40)
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}
