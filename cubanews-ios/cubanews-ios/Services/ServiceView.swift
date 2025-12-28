//
//  ServiceView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 26/12/2025.
//

import SwiftUI

@available(iOS 17, *)
struct ServiceView: View {
    let service: Service
    let viewModel: ServicesViewModel
    
    @Environment(\.openURL) private var openURL
    
    private func statusInfo() -> (String, Color) {
        switch service.status {
        case .inReview:
            return (ServiceStatus.inReview.rawValue, .orange)
        case .approved:
            return (ServiceStatus.approved.rawValue, .green)
        case .rejected:
            return (ServiceStatus.rejected.rawValue, .red)
        }
    }
    
    private var statusBadge: some View {
        let (title, color) = statusInfo()
        return Text(title)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
    
    private var contactInfoPreview: some View {
        let contactInfo = service.contactInfo
        return HStack(alignment: .top, spacing: 14) {
            if (!contactInfo.emailAddress.isEmpty) {
                Button {
                    if let url = URL(string: "mailto:\(contactInfo.emailAddress)") {
                        openURL(url)
                    }
                } label: {
                    Label("", systemImage: "envelope.fill").font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            if (!contactInfo.phoneNumber.isEmpty) {
                Button {
                    dial(number: contactInfo.phoneNumber)
                } label: {
                    Label("", systemImage: "phone.fill")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            if (!contactInfo.facebook.isEmpty) {
                Button {
                    if let url = URL(string: contactInfo.facebook) {
                        openURL(url)
                    }
                } label: {
                    Image("facebook")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 20)
                            .accessibilityLabel("Facebook")
                }
                .buttonStyle(.plain)
            }
            
            if (!contactInfo.instagram.isEmpty) {
                Button {
                    if let url = URL(string: contactInfo.instagram) {
                        openURL(url)
                    }
                } label: {
                    Image("instagram")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 20)
                            .accessibilityLabel("Instagram")
                }
                .buttonStyle(.plain)
            }
            
            if (!contactInfo.websiteURL.isEmpty) {
                Button {
                    if let url = URL(string: contactInfo.websiteURL) {
                        openURL(url)
                    }
                } label: {
                    Label("", systemImage: "globe")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func dial(number: String) {
        let digits = number.filter { $0.isNumber || $0 == "+" }
        guard let url = URL(string: "tel://\(digits)") else {
            return
        }
        openURL(url)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text(service.businessName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Spacer()
                statusBadge
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            Text(service.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack(spacing: 12) {
                contactInfoPreview
                Spacer()
                if (viewModel.showMyServices) {
                    Button {
                        viewModel.editService(service)
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    Button {
                        viewModel.deleteService(service)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
        }
        .padding()
        .background(Color(.systemGray5).opacity(0.3))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
    }
    
}

#Preview {
    ServiceView(service: Service(
        id: UUID().uuidString,
        description: "Authentic Cuban coffee and pastries served daily. Come enjoy our espresso and pastelitos.",
        businessName: "Café Habana",
        contactInfo: ContactInfo(
            emailAddress: "contact@cafehabana.com",
            phoneNumber: "11549123456789",
            websiteURL: "http://www.cafehabana.com",
            facebook: "http://www.facebook.com/cafehabana",
            instagram: "http://www.instagram.com/cafehabana",
            location: "203, Calle 23, Miami, Florida, USA"
        ),
        ownerID: "sasdad",
        status: .approved
    ), viewModel: MockServicesViewModel(editMode: true))
}
