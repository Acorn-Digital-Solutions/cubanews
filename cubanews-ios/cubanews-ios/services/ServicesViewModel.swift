//
//  ServicesViewModel.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 24/12/2025.
//

import SwiftUI
import FirebaseStorage
import Combine
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class ServicesViewModel: ObservableObject {
    // Singleton instance
    static let shared = ServicesViewModel()

    @Published var services: [Service] = []
    @Published var isLoading: Bool = false
    @Published var myServices: [Service] = []
    @Published var isEditingPresented: Bool = false
    @Published var showMyServices: Bool = false
    private let db = Firestore.firestore(database: "prod")

    // Make the initializer private to enforce the singleton
    private init() {}
    
    func saveEditedService(_ updated: Service) async {
        do {
            var toSave = updated
            if toSave.createdAt == 0 {
                toSave.createdAt = Date().timeIntervalSince1970
            }
            toSave.lastUpdatedAt = Date().timeIntervalSince1970
            try await db.collection("services").document(toSave.id).setData(toSave.toFirebaseDocument())
            
            DispatchQueue.main.async {
                self.isEditingPresented = false
                if let i = self.myServices.firstIndex(where: { $0.id == toSave.id }) { self.myServices[i] = toSave }
                else { self.myServices.insert(toSave, at: 0) }
                if let i = self.services.firstIndex(where: { $0.id == toSave.id }) { self.services[i] = toSave }
                else { self.services.insert(toSave, at: 0) }
            }
            await MainActor.run {
                
            }
        } catch {
            NSLog("Error saving service: \(error)")
        }
    }
    
    func loadServices() async {
        
    }
    
    func deleteService(_ service: Service) async {
        do {
            try await db.collection("services").document(service.id).delete()
            DispatchQueue.main.async {
                self.myServices.removeAll { $0.id == service.id }
                // also remove from services list if present
                self.services.removeAll { $0.id == service.id }
            }
        } catch {
            NSLog("Error deleting service: \(error)")
        }
    }
    
    func loadMyServices(reset: Bool = true) async {
        myServices = []
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }

        let query: Query = db.collection("services")
            .whereField("ownerID", isEqualTo: Auth.auth().currentUser?.uid ?? "")
            .order(by: "createdAt", descending: true)

        do {
            let snapshot = try await query.getDocuments()
            guard !snapshot.documents.isEmpty else { return }
            let new = parseServices(from: snapshot.documents)
            myServices = new
        } catch {
            NSLog("Error loading my services: \(error)")
        }
    }

    func loadMoreServices(_ page: Int = 0, _ pageSize: Int = 20) async {
        let servicesCollection = db.collection("services")
        do {
            let snapshot = try await servicesCollection
                .whereField("status", isEqualTo: ServiceStatus.approved.rawValue)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            let newServices = parseServices(from: snapshot.documents)
            services.append(contentsOf: newServices)
            NSLog("Firebase Services loaded: \(newServices.count)")
        } catch {
            NSLog("Error loading public services: \(error)")
        }
    }
    
    private func parseServices(from documents: [QueryDocumentSnapshot]) -> [Service] {
        documents.compactMap { document in
            let data = document.data()
            let statusString = (data["status"] as? String) ?? ServiceStatus.inReview.rawValue
            guard
                let description = data["description"] as? String,
                let phoneNumber = data["phoneNumber"] as? String,
                let businessName = data["businessName"] as? String,
                let ownerID = data["ownerID"] as? String,
                let createdAt = data["createdAt"] as? Double,
                let status = ServiceStatus(rawValue: statusString)
            else { return nil }
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
