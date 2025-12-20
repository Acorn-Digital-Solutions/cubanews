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
    var expirationDate: Double;
    var createdAt: Double = 0;
    
    func toFirebaseDocument() -> [String: Any] {
        return [
            "id": id,
            "description": description,
            "phoneNumber": phoneNumber,
            "businessName": businessName,
            "imageStorageURI": imageStorageURI,
            "ownerID": ownerID,
            "status": status.rawValue,
            "expirationDate": expirationDate,
            "createdAt": createdAt
        ]
    }
}

@available(iOS 17, *)
struct ServicesView: View {
    
    @State private var services: [Service] = []
    private var currentPage: Int = 1
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(services) { service in
                        ServiceView(service: service)
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
        }.onAppear() {
            Task {
                await loadMoreServices()
            }
        }
        
    }
    
    func loadMoreServices() async -> Void {
        
    }
}
