//
//  ProfileView.swift
//  cubanews-ios
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @State private var selectedPublications: Set<String> = []
    
    let publications = NewsSourceName.allCases.filter { $0 != .unknown }.map { $0.rawValue }
    
    // Inline linked privacy text
    private var privacyAttributedText: AttributedString {
        var text = AttributedString("Consulta nuestra política de privacidad para entender cómo manejamos tus datos.")
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
        var text = AttributedString("La mision de CubaNews es amplificar el mensaje de la prensa independiente cubana . Ver mas en nuestra web cubanews.icu")
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
                        // User name at the top
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text("User")
                                .font(.title)
                                .fontWeight(.bold)
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
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(publications, id: \.self) { publication in
                                        PreferencePillButton(
                                            publication: publication,
                                            isSelected: selectedPublications.contains(publication),
                                            onToggle: {
                                                togglePreference(publication)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal).padding(.vertical)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        Divider()
                        
                        Text("Acerca de CubaNews")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Privacy Section
                        Text(misionAttributedText)
                            .font(.subheadline)
                            .padding(.horizontal)
                        
                        // Inline link for "política de privacidad"
                        Text(privacyAttributedText)
                            .font(.subheadline)
                            .padding(.horizontal)
                        
                        Divider()
                        
                        // Account Management Section
                        ManageAccountSection()
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
            NSLog("ProfileView appeared")
            loadPreferences()
        }
        .onChange(of: selectedPublications) { oldValue, newValue in
            NSLog("selectedPublications changed - oldValue: \(Array(oldValue)), newValue: \(Array(newValue))")
            loadPreferences()
        }
    }
    
    private func loadPreferences() {
        NSLog("xxx - loadPreferences() called - preferences.count: \(preferences.count)")
        // Sync from preferences to state
        selectedPublications.removeAll()
        if let userPrefs = preferences.first {
            NSLog("Found preferences with \(userPrefs.preferredPublications.count) publications")
            selectedPublications = Set(userPrefs.preferredPublications)
            NSLog("selectedPublications now contains: \(Array(selectedPublications))")
        } else {
            NSLog("No preferences found - creating defaults...")
            // Create default preferences if none exist
            let newPrefs = UserPreferences(preferredPublications: [])
            modelContext.insert(newPrefs)
            try? modelContext.save()
        }
    }
    
    private func togglePreference(_ publication: String) {
        NSLog("togglePreference: \(publication)")
        
        if selectedPublications.contains(publication) {
            selectedPublications.remove(publication)
            NSLog("  -> Removed \(publication)")
        } else {
            selectedPublications.insert(publication)
            NSLog("  -> Added \(publication)")
        }
        
        NSLog("  -> selectedPublications now: \(Array(selectedPublications))")
        
        // Save to SwiftData
        if let userPrefs = preferences.first {
            NSLog("  -> Updating existing UserPreferences")
            userPrefs.preferredPublications = Array(selectedPublications)
            do {
                try modelContext.save()
                NSLog("  -> Saved successfully")
            } catch {
                NSLog("  -> Error saving: \(error)")
            }
        } else {
            NSLog("  -> Creating new UserPreferences")
            let newPrefs = UserPreferences(preferredPublications: Array(selectedPublications))
            modelContext.insert(newPrefs)
            do {
                try modelContext.save()
                NSLog("  -> New preferences saved successfully")
            } catch {
                NSLog("  -> Error saving new preferences: \(error)")
            }
        }
    }
}

/// A pill-shaped button for selecting preferences.
/// When unselected, displays with an outlined blue border and blue text.
/// When selected, displays with a solid blue background and white text.
struct PreferencePillButton: View {
    let publication: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Text(publication)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
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

struct ManageAccountSection: View {
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Maneja tu Cuenta")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 2) {
                // Logout Button
                Button(action: handleLogout) {
                    Text("Cerrar Sesión")
                        .font(.body)
                        .fontWeight(.light)
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
                        .fontWeight(.light)
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
        // TODO: Implement logout logic
        // Clear user session, navigate to login screen, etc.
        NSLog("Logout button tapped")
    }
    
    private func handleDeleteAccount() {
        // TODO: Implement delete account logic
        // Delete user data from SwiftData and backend
        NSLog("Delete account confirmed")
    }
}

