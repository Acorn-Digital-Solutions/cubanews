//
//  PreferenceSectionView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 10/01/2026.
//
import SwiftUI
import SwiftData

struct PreferencesSectionView: View {
    
    // Keep publications as NewsSourceName so we can show icon and displayName
    let publications: [NewsSourceName] = NewsSourceName.allCases.filter { $0 != .unknown }
    @State private var selectedPublications: Set<String> = []
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    
    private func togglePreference(_ publication: NewsSourceName) {
        let key = publication.rawValue
        NSLog("togglePreference: \(key)")
        
        if selectedPublications.contains(key) {
            selectedPublications.remove(key)
            NSLog("  -> Removed \(key)")
        } else {
            selectedPublications.insert(key)
            NSLog("  -> Added \(key)")
        }
        
        NSLog("  -> selectedPublications now: \(Array(selectedPublications))")
        
        // Save to SwiftData (store rawValue strings to keep compatibility)
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
    
    var body: some View {
        return VStack(alignment: .leading, spacing: 16) {
            Text("Preferencias")
                .font(.headline)
                .padding(.horizontal)
            
            Text("Selecciona tus fuentes de noticias preferidas para personalizar tu feed")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // Display publications in a 2-column grid (two pills per row)
            let columns = [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ]
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                ForEach(publications, id: \.self) { publication in
                    PreferencePillButton(
                        publication: publication,
                        isSelected: selectedPublications.contains(publication.rawValue),
                        onToggle: {
                            togglePreference(publication)
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)
            .padding(.vertical)
        }
        .padding(.bottom, 20)
        .onAppear {
            // Load saved preferences from database when view appears
            if let userPrefs = preferences.first {
                selectedPublications = Set(userPrefs.preferredPublications)
                NSLog("PreferencesSectionView loaded \(userPrefs.preferredPublications.count) saved preferences")
            } else {
                NSLog("PreferencesSectionView: No saved preferences found, creating defaults")
                // Create default preferences if none exist
                let newPrefs = UserPreferences(preferredPublications: [])
                modelContext.insert(newPrefs)
                do {
                    try modelContext.save()
                    NSLog("PreferencesSectionView: Default preferences created successfully")
                } catch {
                    NSLog("PreferencesSectionView: Error creating default preferences: \(error)")
                }
            }
        }
    }
}

#Preview {
    PreferencesSectionView()
}

