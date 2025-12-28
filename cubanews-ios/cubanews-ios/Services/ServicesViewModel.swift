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
final class ServicesViewModel: ObservableObject {
    // Singleton instance
    static let shared = ServicesViewModel()
    @Published var services: [Service] = []
    @Published var myServices: [Service] = []

    // Prevent external initialization
    private init() {
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
            Service(description: "Descripción del servicio de prueba 1",
                    businessName: "Servicio de Prueba 1",
                    ownerID: "123serer",
                    status: .approved),
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
            Service(description: "Descripción del servicio de prueba 1",
                    businessName: "Servicio de Prueba 1",
                    ownerID: Auth.auth().currentUser?.uid ?? "123serer"),
        ]
    }
}
