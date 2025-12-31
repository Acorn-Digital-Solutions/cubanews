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
    
    @State private var showDetailSheet = false
    @Environment(\.openURL) private var openURL
    
    private func statusInfo() -> (String, Color) {
        switch service.status {
        case .inReview:
            return (ServiceStatus.inReview.rawValue, .orange)
        case .approved:
            return (ServiceStatus.approved.rawValue, .green)
        case .rejected, .expired:
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
                    Label("", systemImage: "envelope.fill").font(.title3)
                }
                .buttonStyle(.plain)
            }
            
            if (!contactInfo.phoneNumber.isEmpty) {
                Button {
                    dial(number: contactInfo.phoneNumber)
                } label: {
                    Label("", systemImage: "phone.fill")
                        .font(.title3)
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
                            .frame(width: 20, height: 20)
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
                            .frame(width: 23, height: 23)
                            .accessibilityLabel("Instagram")
                            .padding(.horizontal, 3)
                }
                .buttonStyle(.plain)
            }
            
            if (!contactInfo.websiteURL.isEmpty) {
                Button {
                    if let url = URL(string: contactInfo.websiteURL) {
                        openURL(url)
                    }
                } label: {
                    Label("", systemImage: "globe.fill")
                        .font(.title3)
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
    
    private func truncateToWords(_ text: String, maxWords: Int) -> String {
        let words = text.split(separator: " ")
        if words.count <= maxWords {
            return text
        }
        return words.prefix(maxWords).joined(separator: " ") + "..."
    }
    
    var body: some View {
        Button {
            showDetailSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Text(service.businessName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    if viewModel.showMyServices {
                        Spacer()
                        statusBadge
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                Text(truncateToWords(service.description, maxWords: 50))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
                
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
                        .buttonStyle(.plain)
                        Button {
                            Task {
                                await viewModel.deleteService(service)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
            }
            .padding()
            .frame(height: 150)
            .background(Color(.systemGray5).opacity(0.3))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetailSheet) {
            ServiceDetailSheet(service: .constant(service))
        }
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
