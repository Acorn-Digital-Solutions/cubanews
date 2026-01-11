//
//  LoginView.swift
//  cubanews-ios
//

import SwiftUI
import AuthenticationServices
import SwiftData
import FirebaseAuth
import CryptoKit

@available(iOS 17, *)
struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
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
                AppleSignInView()
            }
            .padding(.horizontal, 40)
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    if #available(iOS 17, *) {
        LoginView()
            .modelContainer(for: UserPreferences.self, inMemory: true)
    } else {
        Text("Requires iOS 17")
    }
}
