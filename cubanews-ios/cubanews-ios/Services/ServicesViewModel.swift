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
    @Published var services: [Service] = []
    @Published var myServices: [Service] = []
    @Published var selectedService: Service = Service()
    @Published var editMode: Bool = false
    @Published var showMyServices: Bool = false
    @Published var filteredServices: [Service] = []
    @Published var searchText: String = ""
    
    private let db = Firestore.firestore(database: "prod")
    
    private var lastDocument: DocumentSnapshot?
    private var isLoading = false
    
    func performSearch() {
        guard !searchText.isEmpty else {
            filteredServices = showMyServices ? myServices : services
            return
        }
        let servicesToFilter = showMyServices ? myServices : services
        filteredServices = servicesToFilter.filter { service in
            service.businessName.lowercased().contains(searchText.lowercased()) ||
            service.description.lowercased().contains(searchText.lowercased()) ||
            service.contactInfo.location.lowercased().contains(searchText.lowercased())
        }
    }

    func loadServices() async {
        self.isLoading = true
        var query = db.collection("services")
            .whereField("status", isEqualTo: ServiceStatus.approved.rawValue)
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }
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
            
            self.services.append(contentsOf: newServices)
            self.lastDocument = snapshot.documents.last
            self.isLoading = false
            self.filteredServices = self.services
            
            NSLog("Firebase ServicesViewModel Loaded \(newServices.count) services.")
            
        } catch {
            NSLog("Firebase ServicesViewModel Error loading my services: \(error)")
        }
    }
    
    func loadMyServices() async {
        let query = db.collection("services")
            .whereField("ownerID", isEqualTo: Auth.auth().currentUser?.uid ?? "")
            .order(by: "createdAt", descending: true)
        
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
            self.myServices = newServices
            NSLog("Firebase ServicesViewModel Loaded \(newServices.count) services.")
        } catch {
            NSLog("Firebase ServicesViewModel Error loading my services: \(error)")
        }
    }
    
    func saveService(updated: Service) {
        var mutableService = updated
        mutableService.lastUpdatedAt = Date().timeIntervalSince1970
        mutableService.status = .inReview
        let index = myServices.firstIndex(where: { $0.id == updated.id }) ?? -1
        if index < 0 {
            mutableService.createdAt = Date().timeIntervalSince1970
        }
        do {
            try db.collection("services").document(mutableService.id).setData(from: mutableService)
            Task {
                await loadServices()
            }
        } catch {
            NSLog("Firebase ServicesViewModel Error saving service: \(error)")
            return
        }
        if index < 0 {
            myServices.append(mutableService)
        } else {
            myServices[index] = mutableService
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
    override func loadServices() async {
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
        filteredServices = services
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

