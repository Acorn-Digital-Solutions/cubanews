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
                            
                            FlowLayout(spacing: 10) {
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
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                        
                        Divider()
                        
                        // Account Management Section
                        ManageAccountSection()
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

struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            if index < result.positions.count {
                let position = result.positions[index]
                subview.place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
            }
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }
        
        totalHeight = currentY + rowHeight
        
        return (CGSize(width: totalWidth, height: totalHeight), positions)
    }
}

struct ManageAccountSection: View {
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

#Preview {
    if #available(iOS 17, *) {
        ProfileView()
            .modelContainer(for: [UserPreferences.self, SavedItem.self])
    }
}
