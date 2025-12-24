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
    
    private var currentPage: Int = 1
    private let db = Firestore.firestore(database: "prod")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    // Switch (Toggle) for "Mis Servicios" at the very top
                    if (!myServices.isEmpty) {
                        HStack {
                            Toggle("Mis Servicios", isOn: $showMyServices)
                                .toggleStyle(.switch)
                                .onChange(of: showMyServices) { _, newValue in
                                    if newValue {
                                        Task { await loadMyServices() }
                                    }
                                }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    // Choose which array to display based on the toggle
                    let displayed = showMyServices ? myServices : services
                    LazyVStack(spacing: 12) {
                        ForEach(displayed) { service in
                            ServiceView(service: service, canEdit: showMyServices)
                                .padding(.horizontal)
                                .onAppear {
                                    if showMyServices {
                                        if service == myServices.last {
                                            // currently no pagination for myServices
                                        }
                                    } else {
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
        .onAppear() {
            Task {
                await loadMoreServices()
                await loadMyServices()
            }
        }
        
    }
    
    func loadMyServices() async -> Void {
        let servicesCollection = db.collection("services")
        let myServicesSnapshot = try? await servicesCollection
            .whereField("ownerID", isEqualTo: Auth.auth().currentUser?.uid ?? "")
            .getDocuments()
        guard let myDocuments = myServicesSnapshot?.documents else {
            return
        }
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
}
