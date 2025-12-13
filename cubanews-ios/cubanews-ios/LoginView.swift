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
    @Binding var userPreferences: UserPreferences?
    private static let TAG = "cubanews_iosApp"
    
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
                // Google Login Button
                Button(action: {
                    // Mock login - just set authenticated to true
//                    isAuthenticated = true
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                        Text("Continue with Google")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
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
                                if email != nil || fullName != nil {
                                    NSLog("➡️ \(Self.TAG) Authorization successful. email: \(String(describing: email)), name: \(String(describing: fullName))")
                                    if let existing = preferences.first {
                                        existing.userEmail = email
                                        existing.userFullName = fullName
                                        try? modelContext.save()
                                        DispatchQueue.main.async {
                                            userPreferences = existing
                                        }
                                        NSLog("➡️ \(Self.TAG) Updated existing UserPreferences")
                                    } else {
                                        let prefs = UserPreferences(userEmail: email, userFullName: fullName)
                                        modelContext.insert(prefs)
                                        try? modelContext.save()
                                        DispatchQueue.main.async {
                                            userPreferences = prefs
                                        }
                                        NSLog("➡️ \(Self.TAG) Created new UserPreferences")
                                    }
                                } else {
                                    NSLog("➡️ \(Self.TAG) Authorization successful but no email or name provided. THIS SHOULD NEVER HAPPEN")
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
                
                // Facebook Login Button
                Button(action: {
                    // Mock login - just set authenticated to true
//                    isAuthenticated = true
                }) {
                    HStack {
                        Image(systemName: "f.circle.fill")
                            .font(.title2)
                        Text("Continue with Facebook")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 40)
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

