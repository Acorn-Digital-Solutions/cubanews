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
    var id: UUID = UUID();
    var description: String;
    var phoneNumber: String;
    var businessName: String;
    var image: Image?;
    var imageLink: String?;
    var ownerID: String;
    var status: ServiceStatus;
    var expirationDate: Date;
    var createdAt: Date;
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
