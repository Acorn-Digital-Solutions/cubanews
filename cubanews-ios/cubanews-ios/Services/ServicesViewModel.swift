//
//  ServicesViewModel.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 26/12/2025.
//

import Combine
import FirebaseAuth
import FirebaseFirestore

@available(iOS 17, *)
@MainActor
class ServicesViewModel: ObservableObject {
    // Singleton instance
    @Published var services: [Service] = []
    @Published var myServices: [Service] = []
    @Published var selectedService: Service = Service()
    @Published var editMode: Bool = false
    @Published var showMyServices: Bool = false
    
    private let db = Firestore.firestore(database: "prod")
    private var currentQuery: Query? = nil
    
    public init() {
        Task {
            await loadNextPage()
            await loadMyServices()
        }
    }
    
    private var lastDocument: DocumentSnapshot?
    private var isLoading = false
    private var hasMoreData = true

    func loadServices(_ page: Int = 0, pageSize: Int = 25) async {
        NSLog("Firebase ServicesViewModel Loading services page \(page)...")
        isLoading = true
        
        let query = db.collection("services")
            .whereField("status", isEqualTo: ServiceStatus.approved.rawValue)
            .order(by: "createdAt", descending: true)
            .limit(to: pageSize)
        do {
            let snapshot = try await query.getDocuments()
            guard !snapshot.documents.isEmpty else {
                NSLog("Firebase ServicesViewModel No more services to load.")
                return
            }
            let newServices = snapshot.documents.compactMap { doc -> Service? in
                NSLog("Firebase ServicesViewModel Loaded service doc: \(doc.data())")
                return try? doc.data(as: Service.self)
            }
            DispatchQueue.main.async {
                self.isLoading = false
                if page == 0 {
                    self.services = newServices
                } else {
                    self.services.append(contentsOf: newServices)
                }

                // Update cursor and state
                self.lastDocument = snapshot.documents.last
                self.hasMoreData = newServices.count == pageSize
                self.isLoading = false
            }
            NSLog("Firebase ServicesViewModel Loaded \(newServices.count) services.")
            
        } catch {
            NSLog("Firebase ServicesViewModel Error loading my services: \(error)")
        }
//            .documents.compactMap { doc -> Service? in
//            try? doc.data(as: Service.self)
//        }
//        // For page > 0, start after last document
//        if page > 0, let lastDoc = lastDocument {
//            query = query.start(afterDocument: lastDoc)
//        }
//        
//        query.addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self, let snapshot = snapshot else {
//                self?.isLoading = false
//                return
//            }
//            
//            let newServices = snapshot.documents.compactMap { doc -> Service? in
//                try? doc.data(as: Service.self)
//            }
//            
//            DispatchQueue.main.async {
//                if page == 0 {
//                    self.services = newServices
//                } else {
//                    self.services.append(contentsOf: newServices)
//                }
//                
//                // Update cursor and state
//                self.lastDocument = snapshot.documents.last
//                self.hasMoreData = newServices.count == pageSize
//                self.isLoading = false
//            }
//        }
    }

    func loadNextPage() async {
        let nextPage = lastDocument == nil ? 0 : 1
        await loadServices(nextPage, pageSize: 25)
    }
    
    func loadMyServices() async {
        let query = db.collection("services")
            .whereField("ownerID", isEqualTo: Auth.auth().currentUser?.uid ?? "")
            .order(by: "createdAt", descending: true)
            .limit(to: 25)
        
        do {
            let snapshot = try await query.getDocuments()
            guard !snapshot.documents.isEmpty else {
                NSLog("Firebase ServicesViewModel No more services to load.")
                return
            }
            let newServices = snapshot.documents.compactMap { doc -> Service? in
                NSLog("Firebase ServicesViewModel Loaded service doc: \(doc.data())")
                return try? doc.data(as: Service.self)
            }
            DispatchQueue.main.async {
                self.isLoading = false
                self.myServices.append(contentsOf: newServices)
            }
            NSLog("Firebase ServicesViewModel Loaded \(newServices.count) services.")
        } catch {
            NSLog("Firebase ServicesViewModel Error loading my services: \(error)")
        }
    }
    
    enum ServicesError: Error {
        case notImplemented
        case parseFailed
    }
    
    func saveService(updated: Service) {
        do {
            try db.collection("services").document(updated.id).setData(from: updated)
        } catch {
            NSLog("Firebase ServicesViewModel Error saving service: \(error)")
            return
        }
        let index = myServices.firstIndex(where: { $0.id == updated.id }) ?? -1
        if index < 0 {
            myServices.append(updated)
        } else {
            myServices[index] = updated
        }
        selectedService = Service()
    }
    
    func cancelEdit() {
        editMode = false
        selectedService = Service()
    }
    
    func editService(_ service: Service) {
        selectedService = service
        editMode = true
    }
    
    func deleteService(_ service: Service) async {
        do {
            try await db.collection("services").document(service.id).delete()
        } catch {
            NSLog("Error deleting service: \(error)")
            return;
        }
        services.removeAll { $0.id == service.id }
        myServices.removeAll { $0.id == service.id }
        selectedService = Service()
    }
}

class MockServicesViewModel: ServicesViewModel {
    
    public init(editMode: Bool = false) {
        super.init()
        self.editMode = editMode
    }
    
    /// Loads a page of services. This is a stub that returns a sample array.
    override func loadServices(_ page: Int = 0, pageSize: Int = 10) async {
        // TODO: implement Firestore query and pagination
        services = [
            Service(description: "Descripción del servicio de prueba 1",
                    businessName: "Servicio de Prueba 1",
                    ownerID: Auth.auth().currentUser?.uid ?? "123serer"),
            Service(description: "Descripción del servicio de prueba 1",
                    businessName: "Servicio de Prueba 1",
                    ownerID: Auth.auth().currentUser?.uid ?? "123serer"),
            Service(description: "Descripción del servicio de prueba 1",
                    businessName: "Servicio de Prueba 1",
                    ownerID: "123serer",
                    status: .approved),
            Service(description: "Descripción del servicio de prueba 1",
                    businessName: "Servicio de Prueba 1",
                    ownerID: "123serer",
                    status: .approved),
            Service(
                description: "Authentic Cuban coffee and pastries served daily. Come enjoy our espresso and pastelitos.",
                businessName: "Café Habana",
                contactInfo: ContactInfo(
                    emailAddress: "contact@cafehabana.com",
                    phoneNumber: "11549123456789",
                    websiteURL: "http://www.cafehabana.com",
                    instagram: "http://www.instagram.com/cafehabana",
                    location: "203, Calle 23, Miami, Florida, USA"
                ),
                ownerID: "sasdad",
                status: .approved
            ),
            Service(description: "Descripción del servicio de prueba 1",
                    businessName: "Servicio de Prueba 1",
                    ownerID: Auth.auth().currentUser?.uid ?? "123serer",
                    status: .rejected)
        ]
    }
    
    override func loadMyServices() async {
        myServices = [
            Service(description: "Descripción del servicio de prueba 1",
                    businessName: "Servicio de Prueba 1",
                    ownerID: Auth.auth().currentUser?.uid ?? "123serer"),
            Service(
                description: "Authentic Cuban coffee and pastries served daily. Come enjoy our espresso and pastelitos.",
                businessName: "Café Habana",
                contactInfo: ContactInfo(
                    emailAddress: "contact@cafehabana.com",
                    phoneNumber: "11549123456789",
                    websiteURL: "http://www.cafehabana.com",
                    instagram: "http://www.instagram.com/cafehabana",
                    location: "203, Calle 23, Miami, Florida, USA"
                ),
                ownerID: "sasdad"
            ),
        ]
    }
}

