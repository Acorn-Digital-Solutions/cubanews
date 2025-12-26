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
    var lastUpdatedAt: Double = 0;
    
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
    
    @ObservedObject private var servicesViewModel = ServicesViewModel.shared
    @State private var editingService: Service? = nil
    @State private var editingCopy: Service = Service(id: "", description: "", phoneNumber: "", businessName: "", imageStorageURI: "", ownerID: "", status: .inReview, expirationDate: nil, createdAt: 0)
    @State private var isEditingPresented: Bool = false
     
     private let db = Firestore.firestore(database: "prod")
     
     var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 12) {
                        topToggleBar
                        myServicesSection
                        publicServicesSection
                    }
                    .padding(.vertical, 12)
                }
                if (servicesViewModel.showMyServices) {
                    floatingAddButton
                }
            }
            .navigationTitle("Servicios")
        }
        .sheet(isPresented: $isEditingPresented, onDismiss: { /* nothing */ }) {
            ServiceEditSheet(
                service: $editingCopy,
                onSave: { updated in Task { await servicesViewModel.saveEditedService(updated); isEditingPresented = false } },
                onCancel: { isEditingPresented = false }
            )
        }
         .task {
             await servicesViewModel.loadMoreServices()
         }
     }

    // MARK: - Subviews to reduce type-checker complexity
    @ViewBuilder
    private var topToggleBar: some View {
        HStack {
            Toggle(isOn: $servicesViewModel.showMyServices) {
                HStack(spacing: 8) {
                    Text("Mis servicios")
                        .font(.headline)
                    if servicesViewModel.myServices.count > 0 {
                        Text("\(servicesViewModel.myServices.count)")
                            .font(.caption2)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 6)
                            .background(Capsule().fill(Color.blue.opacity(0.12)))
                            .foregroundColor(.blue)
                    }
                }
            }
            .toggleStyle(CapsuleCheckboxToggleStyle())
            .onChange(of: servicesViewModel.showMyServices) { _, newValue in
                if newValue {
                    Task { await loadMyServices(reset: true) }
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var myServicesSection: some View {
        if servicesViewModel.showMyServices {
            VStack(alignment: .leading, spacing: 8) {
                LazyVStack(spacing: 8) {
                    ForEach(servicesViewModel.myServices) { service in
                        ServiceView(
                            service: service,
                            canEdit: true,
                            editService: {
                                editingCopy = service
                                isEditingPresented = true
                            },
                            deleteService: {
                                Task { await deleteService(service) }
                            }
                        )
                        .padding(.horizontal)
                        .onAppear {
                            if service == servicesViewModel.myServices.last {
                                Task { await loadMyServices(reset: false) }
                            }
                        }
                    }

                    if servicesViewModel.isLoading {
                        ProgressView()
                            .padding()
                    }

                    if servicesViewModel.myServices.isEmpty && !servicesViewModel.isLoading {
                        VStack(spacing: 12) {
                            Button(action: {
                                editingCopy = newEmptyService()
                                isEditingPresented = true
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
    }

    @ViewBuilder
    private var publicServicesSection: some View {
        let displayed: [Service] = servicesViewModel.showMyServices ? [] : servicesViewModel.services
        LazyVStack(spacing: 12) {
            ForEach(displayed) { service in
                ServiceView(service: service, canEdit: false, editService: {}, deleteService: {})
                    .padding(.horizontal)
                    .onAppear {
                        if service == servicesViewModel.services.last {
                            Task { await servicesViewModel.loadMoreServices() }
                        }
                    }
            }
        }
    }

    private var floatingAddButton: some View {
        Button {
            editingCopy = newEmptyService()
            isEditingPresented = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
        }
        .padding(.trailing, 18)
        .padding(.bottom, 34)
    }
    
    // MARK: - Helpers
    private func newEmptyService() -> Service {
        Service(
            id: UUID().uuidString,
            description: "",
            phoneNumber: "",
            businessName: "",
            imageStorageURI: "",
            ownerID: Auth.auth().currentUser?.uid ?? "",
            status: .inReview,
            expirationDate: nil,
            createdAt: 0 // mark new so sheet shows "Nuevo servicio"
        )
    }

    private func truncate(_ text: String, length: Int) -> String {
        if text.count <= length { return text }
        let idx = text.index(text.startIndex, offsetBy: length)
        return String(text[..<idx]) + "..."
    }

    private func loadMyServices(reset: Bool) async {
        await servicesViewModel.loadMyServices(reset: reset)
    }

    private func deleteService(_ service: Service) async {
        await servicesViewModel.deleteService(service)
    }
}

// MARK: - ServiceEditSheet (binding-based, no internal state)
@available(iOS 17, *)
struct ServiceEditSheet: View {
    @Binding var service: Service
    var onSave: (Service) -> Void
    var onCancel: () -> Void

    @Environment(\.dismiss) var dismiss

    init(service: Binding<Service>, onSave: @escaping (Service) -> Void, onCancel: @escaping () -> Void) {
        self._service = service
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información del servicio")) {
                    TextField("Descripción", text: $service.description)
                    TextField("Número de teléfono", text: $service.phoneNumber)
                    TextField("Nombre del negocio", text: $service.businessName)
                    DatePicker("Fecha de expiración", selection: Binding(get: {
                        Date(timeIntervalSince1970: service.expirationDate ?? Date().timeIntervalSince1970)
                    }, set: { newDate in
                        service.expirationDate = newDate.timeIntervalSince1970
                    }), displayedComponents: .date)
                    .datePickerStyle(.compact)
                }

                Section {
                    HStack(spacing: 16) {
                        Spacer()

                        Button("Guardar") {
                            onSave(service)
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(minWidth: 120)

                        Spacer()

                        Button("Cancelar") {
                            onCancel()
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .frame(minWidth: 120)

                        Spacer()
                    }
                }
            }
            .navigationTitle(service.createdAt == 0 ? "Nuevo servicio" : "Editar servicio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
