//
//  ManageAccountSection.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 10/01/2026.
//
import SwiftUI
import SwiftData

struct ManageAccountSection: View {
    @State private var showingDeleteAlert = false
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @State private var showDeletedConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Maneja tu Cuenta")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 2) {
                // Delete Account Button
                Button("Eliminar Cuenta") {
                    showingDeleteAlert = true
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .tint(.red)
                .frame(maxWidth: .infinity)
            }
        }
        .alert("¿Eliminar Cuenta?", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                Task {
                    await handleDeleteAccount()
                }
            }
        } message: {
            Text("Esta acción no se puede deshacer. Todos tus datos serán eliminados permanentemente.")
        }
    }
    
    @MainActor
    private func handleDeleteAccount() async {
        guard preferences.first != nil else { return }
        do {
            try modelContext.fetch(FetchDescriptor<UserPreferences>())
                .forEach { modelContext.delete($0) }
            
            try modelContext.fetch(FetchDescriptor<SavedItem>())
                .forEach { modelContext.delete($0) }
            
            try modelContext.fetch(FetchDescriptor<CachedFeedItem>())
                .forEach { modelContext.delete($0) }
            
            try modelContext.save()
            NSLog("✅ Local user data deleted")
        } catch {
            NSLog("❌ Failed to delete account: \(error)")
        }
    }
   
}

#Preview {
    ManageAccountSection()
        .modelContainer(for: [UserPreferences.self, SavedItem.self, CachedFeedItem.self], inMemory: true)
}

