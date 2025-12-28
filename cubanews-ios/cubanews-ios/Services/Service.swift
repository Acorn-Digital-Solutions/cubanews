//
//  Service.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 26/12/2025.
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

struct ContactInfo: Equatable {
    var emailAddress: String = "";
    var phoneNumber: String = "";
    var websiteURL: String = "";
    var socialMediaURL: String = "";
    var location: String = "";
}

struct Service: Identifiable, Equatable {
    var id: String = UUID().uuidString;
    var description: String = "";
    var businessName: String = "";
    var contactInfo: ContactInfo = ContactInfo();
    var ownerID: String;
    var status: ServiceStatus = .inReview;
    var expirationDate: Double = 0;
    var createdAt: Double = 0;
    var lastUpdatedAt: Double = 0;
}
