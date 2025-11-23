//
//  ProfileView.swift
//  cubanews-ios
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @Query private var preferences: [UserPreferences]
    @State private var selectedPublications: Set<String> = []
    
    // Available publications
    let publications = ["AdnCuba", "Cibercuba", "CatorceYMedio", "ElToque", "DiariodeCuba", "Cubanet"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // User name at the top with real user data
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authManager.currentUser?.displayName ?? "User")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                if let email = authManager.currentUser?.email {
                                    Text(email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        Divider()
                        
                        // Preferences Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Preferencias")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text("Selecciona tus fuentes de noticias preferidas para personalizar tu feed")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(publications, id: \.self) { publication in
                                    PreferenceCheckboxRow(
                                        publication: publication,
                                        isSelected: selectedPublications.contains(publication),
                                        onToggle: {
                                            togglePreference(publication)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                        
                        Divider()
                        
                        // Account Management Section
                        ManageAccountSection(authManager: authManager)
                            .padding(.bottom, 20)
                    }
                }
                
                Spacer()
                
                // App version and copyright at the bottom
                VStack(spacing: 8) {
                    Text("Version 0.0.1")
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
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadPreferences()
        }
    }
    
    private func loadPreferences() {
        if let userPrefs = preferences.first {
            selectedPublications = Set(userPrefs.preferredPublications)
        } else {
            // Create default preferences
            let newPrefs = UserPreferences(preferredPublications: [])
            modelContext.insert(newPrefs)
            try? modelContext.save()
        }
    }
    
    private func togglePreference(_ publication: String) {
        if selectedPublications.contains(publication) {
            selectedPublications.remove(publication)
        } else {
            selectedPublications.insert(publication)
        }
        
        // Save to SwiftData
        if let userPrefs = preferences.first {
            userPrefs.preferredPublications = Array(selectedPublications)
            try? modelContext.save()
        } else {
            // Create new preferences if none exist
            let newPrefs = UserPreferences(preferredPublications: Array(selectedPublications))
            modelContext.insert(newPrefs)
            try? modelContext.save()
        }
    }
}

struct PreferenceCheckboxRow: View {
    let publication: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
                
                Text(publication)
                    .foregroundColor(.primary)
                    .font(.body)
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}

struct ManageAccountSection: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cuenta")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                // Logout Button
                Button(action: handleLogout) {
                    Text("Cerrar Sesión")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                .padding(.horizontal)
                
                // Delete Account Button
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Text("Eliminar Cuenta")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red)
                        )
                }
                .padding(.horizontal)
            }
        }
        .alert("¿Eliminar Cuenta?", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                handleDeleteAccount()
            }
        } message: {
            Text("Esta acción no se puede deshacer. Todos tus datos serán eliminados permanentemente.")
        }
    }
    
    private func handleLogout() {
        authManager.signOut()
        NSLog("✅ User logged out successfully")
    }
    
    private func handleDeleteAccount() {
        authManager.deleteAccount()
        NSLog("✅ User account deleted successfully")
    }
}

#Preview {
    if #available(iOS 17, *) {
        // Create a preview model context with sample data
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(
                for: UserPreferences.self, SavedItem.self, User.self,
                configurations: config
            )
            let authManager = AuthenticationManager(modelContext: container.mainContext)
            
            // Create a sample user for preview
            let sampleUser = User(
                id: "preview-user",
                email: "user@example.com",
                fullName: "Juan Pérez",
                givenName: "Juan",
                familyName: "Pérez"
            )
            container.mainContext.insert(sampleUser)
            authManager.currentUser = sampleUser
            authManager.isAuthenticated = true
            
            ProfileView()
                .environmentObject(authManager)
                .modelContainer(container)
        } catch {
            Text("Failed to create preview: \(error.localizedDescription)")
        }
    }
}
