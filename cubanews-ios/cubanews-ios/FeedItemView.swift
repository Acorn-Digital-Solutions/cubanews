//
//  FeedItemView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 12/10/2025.
//


import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct FeedItemView: View {
    let item: FeedItem
    @Environment(\.openURL) var openURL
    @State private var showingShareSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Source and Date
            HStack {
                let sourceImage = UIImage(named: item.source.rawValue.lowercased()) ?? UIImage(systemName: "newspaper")
                Image(uiImage: sourceImage!)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(item.source.rawValue.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Text(DateFormatter.localizedString(from: ISO8601DateFormatter().date(from: item.isoDate) ?? Date(), dateStyle: .medium, timeStyle: .short))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Image (if exists)
            if item.imageLoadingState == .LOADING {
                ProgressView()
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            } else if let imageData = item.imageBytes, let uiImage = UIImage(data: imageData) {
                Button(action: {
                    if let url = URL(string: item.url) {
                        openURL(url)
                    }
                }) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Title
            Button(action: {
                if let url = URL(string: item.url) {
                    openURL(url)
                }
            }) {
                Text(item.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .buttonStyle(PlainButtonStyle())

            // Share button
            HStack {
                Spacer()
                Button(action: {
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showingShareSheet) {
                    if let url = URL(string: item.url) {
                        ShareSheet(items: [url])
                    } else {
                        ShareSheet(items: [item.title])
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
