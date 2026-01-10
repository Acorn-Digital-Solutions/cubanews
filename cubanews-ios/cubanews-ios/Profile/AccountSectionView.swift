//
//  AccountSectionView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 10/01/2026.
//
import SwiftUI
import SwiftData

struct AccountSectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    let injectedPreferences: UserPreferences?
    
    init(injectedPreferences: UserPreferences? = nil) {
        self.injectedPreferences = injectedPreferences
    }
    
    private var userPreferences: UserPreferences? {
        return injectedPreferences ?? preferences.first
    }
    
    private var userFullName: String {
        return userPreferences?.userFullName ?? "Usuario Anónimo"
    }
    
    private var isAuthenticated: Bool {
        return userPreferences?.appleUserID != nil && userPreferences?.appleUserID != UserPreferences.defaultID
    }
    
    var body: some View {
        if (isAuthenticated) {
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text(userFullName)
                    .font(.title)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)
        } else {
            VStack(alignment: .leading, spacing: 16) {
                Text("Para anunciar negocios y demás funcionalidades premium, crea tu cuenta.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                AppleSignInView()
            }
        }
    }
}

#Preview {
    AccountSectionView()
}

#Preview("Logged In") {
    let mockPreferences = UserPreferences(
        userFullName: "Sample User",
        appleUserID: "mock_apple_user_id_123"
    )
    return AccountSectionView(injectedPreferences: mockPreferences)
}
