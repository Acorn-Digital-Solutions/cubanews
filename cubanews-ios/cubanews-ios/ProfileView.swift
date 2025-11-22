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
    
    // Available publications
    let publications = ["AdnCuba", "Cibercuba", "CatorceYMedio", "ElToque", "DiariodeCuba", "Cubanet"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // User name at the top
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("User")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    Divider()
                    
                    // Preferences Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Preferred Publications")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text("Select your preferred news sources to personalize your feed")
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
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Profile")
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

#Preview {
    if #available(iOS 17, *) {
        ProfileView()
            .modelContainer(for: [UserPreferences.self, SavedItem.self])
    }
}
