//
//  ProfileView.swift
//  cubanews-ios
//

import SwiftUI
import SwiftData
import AuthenticationServices
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@available(iOS 17, *)
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @State private var selectedPublications: Set<String> = []
    @State private var userFullName: String = "Usuario Anónimo"
    public static let TAG = "ProfileView"
    
    // Keep publications as NewsSourceName so we can show icon and displayName
    let publications: [NewsSourceName] = NewsSourceName.allCases.filter { $0 != .unknown }
    
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
                        // User name at the top
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
                        
                        Divider()
                        
                        CreateServiceSection().padding(.bottom, 20)
                        
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
        print("➡️ \(Self.TAG) - loadPreferences() called - preferences.count: \(preferences.count)")
        // Sync from preferences to state
        selectedPublications.removeAll()
        if let userPrefs = preferences.first {
            print("➡️ \(Self.TAG) - UserID:  \(userPrefs.id)")
            NSLog("Found preferences with \(userPrefs.preferredPublications.count) publications")
            selectedPublications = Set(userPrefs.preferredPublications)
            NSLog("selectedPublications now contains: \(Array(selectedPublications))")
            userFullName = userPrefs.userFullName ?? "Usuario Anónimo"
        } else {
            NSLog("No preferences found - creating defaults...")
            // Create default preferences if none exist
            let newPrefs = UserPreferences(preferredPublications: [])
            modelContext.insert(newPrefs)
            try? modelContext.save()
        }
    }
    
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

struct CreateServiceSection: View {
    @State private var showCreateServiceDrawer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Servicios")
                .font(.headline)
                .padding(.horizontal)

            Text("Anuncia tu negocio en nuestro catálogo gratis")
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding(.horizontal)

            Button {
                showCreateServiceDrawer = true
            } label: {
                Text("Crear Servicio")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                    )
            }
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $showCreateServiceDrawer) {
            CreateServiceView()
        }
    }
}



struct CreateServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var service = Service(
        description: "",
        phoneNumber: "",
        businessName: "",
        ownerID: Auth.auth().currentUser?.uid ?? "",
        status: .inReview,
        expirationDate: 0,
        createdAt: Date().timeIntervalSince1970
    )
    @State private var expirationDate = Date()

    @State private var isSaving = false
    @State private var errorMessage: String?

    private let db = Firestore.firestore(database: "prod")

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Negocio")) {
                    TextField("Nombre del negocio", text: $service.businessName)
                    TextField("Teléfono", text: $service.phoneNumber)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Descripción")) {
                    TextEditor(text: $service.description)
                        .frame(height: 120)
                }

                Section(header: Text("Expiración")) {
                    DatePicker(
                        "Fecha",
                        selection: $expirationDate,
                        displayedComponents: .date
                    )
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Crear Servicio")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveService()
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !service.businessName.isEmpty &&
        !service.description.isEmpty &&
        !service.phoneNumber.isEmpty
    }

    private func saveService() {
        isSaving = true
        errorMessage = nil
        service.createdAt = Date().timeIntervalSince1970
        service.expirationDate = expirationDate.timeIntervalSince1970

        Task {
            do {
                NSLog("Firebase writing service")
                NSLog("🔥 Firebase apps:", FirebaseApp.allApps ?? [:])
                NSLog("🔥 Firebase User: \(Auth.auth().currentUser?.uid ?? "")")
                try await db
                    .collection("services")
                    .document(service.id)
                    .setData(service.toFirebaseDocument())
                isSaving = false
                dismiss()
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
                NSLog("ProfileView Error writing service: \(error)")
            }
        }
    }
}

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
