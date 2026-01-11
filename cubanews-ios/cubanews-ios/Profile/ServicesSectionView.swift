//
//  ServicesSectionView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 10/01/2026.
//
import SwiftUI
import SwiftData

@available(iOS 17, *)
struct ServicesSectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @Binding var advertiseServices: Bool
    
    init(advertiseServices: Binding<Bool>) {
        self._advertiseServices = advertiseServices
    }
    
    private func saveAdvertiseServicesPreference(_ newValue: Bool) {
        NSLog("saveAdvertiseServicesPreference: \(newValue)")
        
        if let userPrefs = preferences.first {
            NSLog("  -> Updating existing UserPreferences")
            userPrefs.advertiseServices = newValue
            do {
                try modelContext.save()
                NSLog("  -> Saved advertiseServices successfully")
            } catch {
                NSLog("  -> Error saving advertiseServices: \(error)")
            }
        } else {
            NSLog("  -> Creating new UserPreferences with advertiseServices")
            let newPrefs = UserPreferences(preferredPublications: [])
            newPrefs.advertiseServices = newValue
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Servicios")
                .font(.headline)
                .padding(.horizontal)
            
            Toggle(isOn: $advertiseServices) {
                Text("Anunciar mis servicios en CubaNews")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .onChange(of: advertiseServices) { oldValue, newValue in
                saveAdvertiseServicesPreference(newValue)
            }
        }
    }
}

#Preview {
    ServicesSectionView(advertiseServices: .constant(true))
}
