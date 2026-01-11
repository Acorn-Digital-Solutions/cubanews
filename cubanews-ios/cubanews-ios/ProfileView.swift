//
//  ProfileView.swift
//  cubanews-ios
//

import SwiftUI
import SwiftData
import AuthenticationServices

@available(iOS 17, *)
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @State private var selectedPublications: Set<String> = []
    @State private var userFullName: String = "Usuario Anónimo"
    @State private var advertiseServices: Bool = false
    
    private static let TAG = "ProfileView"
    
    private var userPreferences: UserPreferences? {
        return preferences.first
    }
    
    private var isAuthenticated: Bool {
        return userPreferences?.appleUserID != nil && userPreferences?.appleUserID != UserPreferences.defaultID
    }
    
    // Inline linked privacy text
    private var privacyAttributedText: AttributedString {
        var text = AttributedString("Cubanews no comparte informacion de sus usuarios con terceros. Consulta nuestra política de privacidad para más detalles.")
        // Base color for non-link text
        text.foregroundColor = .gray
        if let range = text.range(of: "política de privacidad"),
           let url = URL(string: "https://www.freeprivacypolicy.com/live/38c1b534-4ac4-4b6d-8c68-71f89805459f") {
            text[range].link = url
            text[range].foregroundColor = .blue
            // Optional underline to indicate interactivity
            text[range].underlineStyle = .single
        }
        return text
    }
    
    private var misionAttributedText: AttributedString {
        var text = AttributedString("La mision de CubaNews es amplificar el mensaje de la prensa independiente cubana . Ver más en nuestra web cubanews.icu")
        // Base color for non-link text
        text.foregroundColor = .gray
        if let range = text.range(of: "cubanews.icu"),
           let url = URL(string: "https://www.cubanews.icu/about") {
            text[range].link = url
            text[range].foregroundColor = .blue
            // Optional underline to indicate interactivity
            text[range].underlineStyle = .single
        }
        return text
    }
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        NewsHeader(header: "Perfil")
                        // User name at the top
                        AccountSectionView()
                        Divider()
                        PreferencesSectionView()
                        Divider()
                        if isAuthenticated {
                            ServicesSectionView(advertiseServices: $advertiseServices)
                            Divider()
                        }
                        AboutSectionView()
                        Divider()
                        
                        // Account Management Section
                        ManageAccountSectionView()
                            .padding(.bottom, 20)
                        
                        Spacer()
                        
                        // App version and copyright at the bottom
                        VStack(spacing: 8) {
                            Text("Cubanews Version 0.0.1")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("© Acorn Digital Solutions 2025")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(UIColor.systemBackground))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            NSLog("➡️ \(Self.TAG) Checking authentication status \(preferences.first?.appleUserID ?? UserPreferences.defaultID)")
            NSLog("ProfileView appeared")
            loadPreferences()
        }
        .onChange(of: selectedPublications) { oldValue, newValue in
            NSLog("selectedPublications changed - oldValue: \(Array(oldValue)), newValue: \(Array(newValue))")
            loadPreferences()
        }
    }
    
    private func loadPreferences() {
        print("➡️ \(Self.TAG) - loadPreferences() called - preferences.count: \(preferences.count)")
        // Sync from preferences to state
        selectedPublications.removeAll()
        if let userPrefs = preferences.first {
            print("➡️ \(Self.TAG) - UserID:  \(userPrefs.id)")
            NSLog("Found preferences with \(userPrefs.preferredPublications.count) publications")
            selectedPublications = Set(userPrefs.preferredPublications)
            NSLog("selectedPublications now contains: \(Array(selectedPublications))")
            userFullName = userPrefs.userFullName ?? "Usuario Anónimo"
            advertiseServices = userPrefs.advertiseServices
        } else {
            NSLog("No preferences found - creating defaults...")
            // Create default preferences if none exist
            let newPrefs = UserPreferences(preferredPublications: [])
            modelContext.insert(newPrefs)
            try? modelContext.save()
        }
    }
}

/// A pill-shaped button for selecting preferences.
/// When unselected, displays with an outlined blue border and blue text.
/// When selected, displays with a solid blue background and white text.
struct PreferencePillButton: View {
    let publication: NewsSourceName
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(publication.imageName)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 20, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(publication.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color.clear)
            )
            .overlay(
                Capsule()
                    .stroke(Color.blue, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AccountDeletedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("Cuenta eliminada")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Todos tus datos han sido eliminados correctamente.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                do {
                    try modelContext.save()
                } catch {
                    NSLog("Error saving model context after account deletion: \(error)")
                }
                dismiss()
            } label: {
                Text("Volver al inicio")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 16)
        }
        .padding()
    }
}


#Preview("ProfileView") {
    NavigationStack {
        if #available(iOS 17, *) {
            ProfileView()
        } else {
            Text("ProfileView requires iOS 17 or later.")
        }
    }
}
