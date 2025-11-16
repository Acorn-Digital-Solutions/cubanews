//
//  LoginView.swift
//  cubanews-ios
//

import SwiftUI

@available(iOS 17, *)
struct LoginView: View {
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Logo/Title
            VStack(spacing: 10) {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Cubanews")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 50)
            
            // Login Buttons
            VStack(spacing: 16) {
                // Google Login Button
                Button(action: {
                    // Mock login - just set authenticated to true
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
                
                // Apple Login Button
                Button(action: {
                    // Mock login - just set authenticated to true
                    isAuthenticated = true
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.title2)
                        Text("Continue with Apple")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // Facebook Login Button
                Button(action: {
                    // Mock login - just set authenticated to true
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
}

#Preview {
    if #available(iOS 17, *) {
        LoginView(isAuthenticated: .constant(false))
    }
}
