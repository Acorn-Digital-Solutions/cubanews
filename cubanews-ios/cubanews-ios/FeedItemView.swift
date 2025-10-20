//
//  FeedItemView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 12/10/2025.
//


import SwiftUI

struct FeedItemView: View {
    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Source and Date
            HStack {
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
            if let imageData = item.imageBytes, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            }

            // Title
            Text(item.title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Share button
            HStack {
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray5).opacity(0.3))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
    }
}
