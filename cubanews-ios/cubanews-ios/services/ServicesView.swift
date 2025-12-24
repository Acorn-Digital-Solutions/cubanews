//
//  ServicesView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 20/12/2025.
//
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

// Compact capsule toggle that looks like a pill/check button
@available(iOS 17, *)
struct CapsuleCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation { configuration.isOn.toggle() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(configuration.isOn ? .green : .gray)
                configuration.label
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(configuration.isOn ? Color.green.opacity(0.12) : Color(UIColor.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}

enum ServiceStatus: String, Codable, CaseIterable {
    case inReview="En Revisión"
    case approved="Aprobado"
    case rejected="Rechazado"
}

struct Service: Identifiable, Equatable {
    var id: String = UUID().uuidString;
    var description: String = "";
    var phoneNumber: String = "";
    var businessName: String = "";
    var imageStorageURI: String = "";
    var ownerID: String;
    var status: ServiceStatus = .inReview;
    var expirationDate: Double?;
    var createdAt: Double = 0;
    
    func toFirebaseDocument() -> [String: Any] {
        var doc: [String: Any] = [
            "id": id,
            "description": description,
            "phoneNumber": phoneNumber,
            "businessName": businessName,
            "imageStorageURI": imageStorageURI,
            "ownerID": ownerID,
            "status": status.rawValue,
            "createdAt": createdAt
        ]
        if let expirationDate = expirationDate {
            doc["expirationDate"] = expirationDate
        }
        return doc
    }
}

@available(iOS 17, *)
struct ServicesView: View {
    
    @State private var services: [Service] = []
    @State private var myServices: [Service] = []
    @State private var showMyServices: Bool = false
    
    // Pagination / editing state for myServices
    @State private var myServicesPageSize: Int = 20
    @State private var myServicesLastDocument: QueryDocumentSnapshot? = nil
    @State private var isLoadingMyServices: Bool = false
    @State private var editSheetPresented: Bool = false
    @State private var editingService: Service? = nil
    
    private var currentPage: Int = 1
    private let db = Firestore.firestore(database: "prod")
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 12) {
                        // Improved pill-style Toggle for "Mis Servicios" showing count
                        HStack {
                            Toggle(isOn: $showMyServices) {
                                HStack(spacing: 8) {
                                    Text("Mis servicios")
                                        .font(.headline)
                                    if myServices.count > 0 {
                                        Text("\(myServices.count)")
                                            .font(.caption2)
                                            .padding(.vertical, 3)
                                            .padding(.horizontal, 6)
                                            .background(Capsule().fill(Color.blue.opacity(0.12)))
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .toggleStyle(CapsuleCheckboxToggleStyle())
                            .onChange(of: showMyServices) { _, newValue in
                                if newValue {
                                    Task { await loadMyServices() }
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)

                        // If showing user's services, render a dedicated infinite scroll list
                        if showMyServices {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mis servicios")
                                    .font(.headline)
                                    .padding(.horizontal)

                                LazyVStack(spacing: 8) {
                                    ForEach(myServices) { service in
                                        HStack(spacing: 12) {
                                            // Truncated description (first 20 characters)
                                            ServiceView(service: service, canEdit: true,
                                                        editingService: saveEditedService,
                                                        deleteService: deleteService)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(8)
                                        .onAppear {
                                            // Infinite scroll: when last item appears, load next page
                                            if service == myServices.last {
                                                Task {
                                                    await loadMyServices()
                                                }
                                            }
                                        }
                                    }

                                    if isLoadingMyServices {
                                        ProgressView()
                                            .padding()
                                    }

                                    if myServices.isEmpty && !isLoadingMyServices {
                                        VStack(spacing: 12) {
                                            Text("No hay servicios")
                                                .foregroundColor(.secondary)
                                                .padding()

                                            Button(action: {
                                                // Create new service
                                                editingService = Service(
                                                    id: UUID().uuidString,
                                                    description: "",
                                                    phoneNumber: "",
                                                    businessName: "",
                                                    imageStorageURI: "",
                                                    ownerID: Auth.auth().currentUser?.uid ?? "",
                                                    status: .inReview,
                                                    expirationDate: nil,
                                                    createdAt: Date().timeIntervalSince1970
                                                )
                                                editSheetPresented = true
                                            }) {
                                                Label("Crear servicio", systemImage: "plus")
                                                    .padding(.vertical, 10)
                                                    .padding(.horizontal, 16)
                                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Choose which array to display based on the toggle
                        let displayed = showMyServices ? [] : services
                        LazyVStack(spacing: 12) {
                            ForEach(displayed) { service in
                                ServiceView(service: service, canEdit: false)
                                    .padding(.horizontal)
                                    .onAppear {
                                        if service == services.last {
                                            Task {
                                                await loadMoreServices()
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $editSheetPresented, onDismiss: { editingService = nil }) {
            // Simple editor sheet that mirrors the create popup but preloaded for editing
            if let editing = editingService {
                ServiceEditSheet(
                    service: editing,
                    onSave: { updated in
                        Task { await saveEditedService(updated) }
                    },
                    onCancel: {
                        editSheetPresented = false
                    }
                )
            }
        }
        .onAppear() {
            Task {
                await loadMoreServices()
                // Do not preload myServices unless the toggle is on; helps with startup
                await loadMyServices()
            }
        }
        
    }
    
    func loadMyServices() async -> Void {
        let servicesCollection = db.collection("services")
        isLoadingMyServices = true
        defer { isLoadingMyServices = false }
        
        let myServicesSnapshot = try? await servicesCollection
            .whereField("ownerID", isEqualTo: Auth.auth().currentUser?.uid ?? "").getDocuments()
        
        guard let myDocuments = myServicesSnapshot?.documents else {
            return
        }
        myServicesLastDocument = myDocuments.last
        myServices = parseServices(from: myDocuments)
    }
    
    func loadMoreServices() async -> Void {
        let servicesCollection = db.collection("services")
        let querySnapshot = try? await servicesCollection
            .whereField("status", isEqualTo: ServiceStatus.approved.rawValue)
            .getDocuments()
        guard let documents = querySnapshot?.documents else {
            return
        }
        let newServices = parseServices(from: documents)
        NSLog("Firebase Services loaded: \(newServices.count)")
        services = services + newServices
    }

    private func parseServices(from documents: [QueryDocumentSnapshot]) -> [Service] {
        return documents.compactMap { document in
            NSLog("➡️ Firebase Procesando documento de servicio: \(document.documentID)")
            let data = document.data()
            let statusString = (data["status"] as? String) ?? ServiceStatus.inReview.rawValue
            guard
                let description = data["description"] as? String,
                let phoneNumber = data["phoneNumber"] as? String,
                let businessName = data["businessName"] as? String,
                let ownerID = data["ownerID"] as? String,
                let createdAt = data["createdAt"] as? Double,
                let status = ServiceStatus(rawValue: statusString)
            else {
                return nil
            }
            let expirationDate = data["expirationDate"] as? Double
            let imageStorageURI = data["imageStorageURI"] as? String ?? ""

            return Service(
                id: document.documentID,
                description: description,
                phoneNumber: phoneNumber,
                businessName: businessName,
                imageStorageURI: imageStorageURI,
                ownerID: ownerID,
                status: status,
                expirationDate: expirationDate,
                createdAt: createdAt
            )
        }
    }
    
    func truncate(_ text: String, length: Int) -> String {
        if text.count <= length {
            return text
        } else {
            let index = text.index(text.startIndex, offsetBy: length)
            return String(text[..<index]) + "..."
        }
    }
    
    // MARK: - Delete service helper
    func deleteService(_ service: Service) async {
        do {
            try await db.collection("services").document(service.id).delete()
            await MainActor.run {
                myServices.removeAll { $0.id == service.id }
                // also remove from services list if present
                services.removeAll { $0.id == service.id }
            }
        } catch {
            NSLog("Error deleting service: \(error)")
        }
    }

    // MARK: - Save edited service helper
    func saveEditedService(_ updated: Service) async {
        do {
            try await db.collection("services").document(updated.id).setData(updated.toFirebaseDocument())
            await MainActor.run {
                if let idx = myServices.firstIndex(where: { $0.id == updated.id }) {
                    myServices[idx] = updated
                }
                if let idx2 = services.firstIndex(where: { $0.id == updated.id }) {
                    services[idx2] = updated
                }
                editSheetPresented = false
                editingService = nil
            }
        } catch {
            NSLog("Error saving edited service: \(error)")
        }
    }
}

// MARK: - Service Edit Sheet View

struct ServiceEditSheet: View {
    var service: Service
    var onSave: (Service) -> Void
    var onCancel: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var description: String
    @State private var phoneNumber: String
    @State private var businessName: String
    @State private var imageStorageURI: String
    @State private var status: ServiceStatus
    @State private var expirationDate: Date = Date()
    @State private var isNew: Bool = false

    init(service: Service, onSave: @escaping (Service) -> Void, onCancel: @escaping () -> Void) {
        self.service = service
        self.onSave = onSave
        self.onCancel = onCancel

        // Initialize state variables
        _description = State(initialValue: service.description)
        _phoneNumber = State(initialValue: service.phoneNumber)
        _businessName = State(initialValue: service.businessName)
        _imageStorageURI = State(initialValue: service.imageStorageURI)
        _status = State(initialValue: service.status)
        _expirationDate = State(initialValue: service.expirationDate != nil ? Date(timeIntervalSince1970: service.expirationDate!) : Date())
        _isNew = State(initialValue: service.createdAt == 0)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información del servicio")) {
                    TextField("Descripción", text: $description)
                    TextField("Número de teléfono", text: $phoneNumber)
                    TextField("Nombre del negocio", text: $businessName)
                    TextField("Imagen (URL)", text: $imageStorageURI)
                        .keyboardType(.URL)
                }

                Section(header: Text("Estado del servicio")) {
                    Picker("Estado", selection: $status) {
                        ForEach(ServiceStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)

                    if status == .inReview {
                        DatePicker("Fecha de expiración", selection: $expirationDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                }

                Section {
                    Button(action: {
                        // Save action
                        let updatedService = Service(
                            id: service.id,
                            description: description,
                            phoneNumber: phoneNumber,
                            businessName: businessName,
                            imageStorageURI: imageStorageURI,
                            ownerID: service.ownerID,
                            status: status,
                            expirationDate: status == .inReview ? expirationDate.timeIntervalSince1970 : nil,
                            createdAt: service.createdAt
                        )
                        onSave(updatedService)
                        dismiss()
                    }) {
                        Text("Guardar")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        // Cancel action
                        onCancel()
                        dismiss()
                    }) {
                        Text("Cancelar")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .navigationTitle(isNew ? "Nuevo servicio" : "Editar servicio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
