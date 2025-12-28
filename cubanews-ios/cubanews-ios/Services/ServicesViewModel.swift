//
//  ServicesViewModel.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 26/12/2025.
//

import Combine
import FirebaseAuth

@available(iOS 17, *)
@MainActor
class ServicesViewModel: ObservableObject {
    // Singleton instance
    @Published var services: [Service] = []
    @Published var myServices: [Service] = []
    @Published var selectedService: Service = Service()
    @Published var editMode: Bool = false
    @Published var showMyServices: Bool = false

    // Prevent external initialization
    public init() {
        Task {
            // Load services asynchronously then assign on the main actor
            let loaded = await loadServices()
            let myServices = await loadMyServices()
            await MainActor.run {
                self.services = loaded
                self.myServices = myServices
            }
        }
    }
    
    /// Loads a page of services. This is a stub that returns a sample array.
    func loadServices(_ page: Int = 0, pageSize: Int = 10) async -> [Service]{
        // TODO: implement Firestore query and pagination
        return [
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
    
    func loadMyServices() async -> [Service] {
        return [
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
    
    enum ServicesError: Error {
        case notImplemented
    }
    
    func saveService(updated: Service) {
        let index = services.firstIndex(where: { $0.id == updated.id }) ?? -1
        if index < 0 {
            services.append(updated)
        } else {
            services[index] = updated
        }
        let myIndex = myServices.firstIndex(where: { $0.id == updated.id }) ?? -1
        if myIndex < 0 {
            myServices.append(updated)
        } else {
            myServices[myIndex] = updated
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
    
    func deleteService(_ service: Service) {
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
    override func loadServices(_ page: Int = 0, pageSize: Int = 10) async -> [Service]{
        // TODO: implement Firestore query and pagination
        return [
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
    
    override func loadMyServices() async -> [Service] {
        return [
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

