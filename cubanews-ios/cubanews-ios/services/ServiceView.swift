//
//  ServiceView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 20/12/2025.
//

import SwiftUI
import UIKit

@available(iOS 17, *)
struct ServiceView: View {
    let service: Service
    let canEdit: Bool
    let editService: () -> Void
    let deleteService: () -> Void
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Optional image preview
                if let url = imageURL(), #available(iOS 15.0, *) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipped()
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                                .foregroundColor(.secondary)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(service.businessName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Text(service.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }

                Spacer()

                statusBadge
            }

            HStack(spacing: 14) {
                Label(formattedDate(from: service.createdAt), systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !service.phoneNumber.isEmpty {
                    Button {
                        dial(number: service.phoneNumber)
                    } label: {
                        Label(service.phoneNumber, systemImage: "phone.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
                
                if canEdit {
                    HStack(spacing: 12) {
                        Button {
                            editService()
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                        Button {
                            deleteService()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.blue)
                        }
                    }
                } else {
                    Button {
                        shareService()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
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

    private func formattedDate(from timestamp: Double) -> String {
        guard timestamp > 0 else { return "" }
        // Detect milliseconds vs seconds
        let seconds = timestamp > 1_000_000_000_000 ? timestamp / 1000 : timestamp
        let date = Date(timeIntervalSince1970: seconds)
        let fmt = DateFormatter()
        fmt.locale = Locale.current
        fmt.dateStyle = .short
        fmt.timeStyle = .none
        return fmt.string(from: date)
    }

    private func dial(number: String) {
        let digits = number.filter { $0.isNumber || $0 == "+" }
        guard let url = URL(string: "tel://\(digits)") else { return }
        openURL(url)
    }

    private func shareService() {
        let text = "\(service.businessName)\n\(service.description)\nPhone: \(service.phoneNumber)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)

        // Present via the first available scene's rootViewController
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let root = window.rootViewController {
            root.present(activityVC, animated: true)
        }
    }

    private func imageURL() -> URL? {
        guard !service.imageStorageURI.isEmpty else { return nil }
        return URL(string: service.imageStorageURI)
    }
}

@available(iOS 17, *)
struct ServiceView_Previews: PreviewProvider {
    static var previews: some View {
        let mock = Service(
            id: "1",
            description: "Experienced plumber offering emergency repairs and installations. Fast response and fair prices.",
            phoneNumber: "+5351234567",
            businessName: "Jose's Plumbing",
            imageStorageURI: "",
            ownerID: "owner123",
            status: .approved,
            expirationDate: Date().addingTimeInterval(60*60*24*30).timeIntervalSince1970,
            createdAt: Date().addingTimeInterval(-60*60*24*7).timeIntervalSince1970
        )
        ServiceView(service: mock, canEdit: false, editService: {}, deleteService: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
