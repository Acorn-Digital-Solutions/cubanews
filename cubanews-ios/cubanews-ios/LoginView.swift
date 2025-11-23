//
//  LoginView.swift
//  cubanews-ios
//

import SwiftUI
import AuthenticationServices

@available(iOS 17, *)
struct LoginView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Binding var isAuthenticated: Bool
    
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
                // Apple Sign In Button (Native)
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.email, .fullName]
                    },
                    onCompletion: { result in
                        handleSignInWithApple(result)
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(10)
                
                // Google Login Button (Placeholder)
                Button(action: {
                    // TODO: Implement Google Sign In
                    // Placeholder - Mock login for now
                    isAuthenticated = true
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
                
                // Facebook Login Button (Placeholder)
                Button(action: {
                    // TODO: Implement Facebook Sign In
                    // Placeholder - Mock login for now
                    isAuthenticated = true
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
    
    // MARK: - Sign in with Apple Handler
    private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                let email = appleIDCredential.email
                let fullName = appleIDCredential.fullName
                let identityToken = appleIDCredential.identityToken
                let authorizationCode = appleIDCredential.authorizationCode
                
                authManager.handleSignInWithApple(
                    userId: userId,
                    email: email,
                    fullName: fullName,
                    identityToken: identityToken,
                    authorizationCode: authorizationCode
                )
                
                // Update authentication state
                isAuthenticated = true
            }
            
        case .failure(let error):
            authManager.handleSignInFailure(error: error)
        }
    }
}

#Preview {
    if #available(iOS 17, *) {
        // Create a preview model context
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: User.self, configurations: config)
            let authManager = AuthenticationManager(modelContext: container.mainContext)
            
            LoginView(authManager: authManager, isAuthenticated: .constant(false))
        } catch {
            Text("Failed to create preview: \(error.localizedDescription)")
        }
    }
}
