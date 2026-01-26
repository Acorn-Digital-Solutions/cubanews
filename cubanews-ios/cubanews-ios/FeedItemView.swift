//
//  FeedItemView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 12/10/2025.
//

import SwiftUI
import UIKit
import Combine

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

@available(iOS 17, *)
struct FeedItemView: View {
    let item: FeedItem
    @Environment(\.openURL) var openURL
    @State private var showingShareSheet = false
    @ObservedObject private var cubanewsViewModel = CubanewsViewModel.shared

    // Make the initializer explicit and internal so it's accessible from other views
    init(item: FeedItem) {
        self.item = item
    }

    private static let iso8601DateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()
    
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es")
        formatter.unitsStyle = .full   // .short → "hace 5 min"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Source and Date
            HStack {
                let sourceImage = UIImage(named: item.source.rawValue.lowercased()) ?? UIImage(systemName: "newspaper")
                Image(uiImage: sourceImage!)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(item.source.displayName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Text(
                    Self.relativeFormatter.localizedString(
                        for: Self.iso8601DateFormatter.date(from: item.isoDate) ?? Date(),
                        relativeTo: Date()
                    )
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }

            if item.image != nil && item.image?.isEmpty == false {
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
            }

            // Title
            Button(action: {
                if let url = URL(string: item.url) {
                    AnalyticsService.shared.logArticleView(
                        articleId: String(item.id),
                        source: item.source.rawValue
                    )
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

            // Separator
            Divider()
                .padding(.vertical, 4)

            // Save and Share buttons
            HStack(spacing: 20) {
                Spacer()
                
                // Save button
                Button(action: {
                    let wasSaved = cubanewsViewModel.isSaved(item.id)
                    cubanewsViewModel.toggleSaved(for: item.id)
                    if !wasSaved {
                        AnalyticsService.shared.logArticleSave(
                            articleId: String(item.id),
                            source: item.source.rawValue
                        )
                    }
                }) {
                    Label("Guardar", systemImage: cubanewsViewModel.isSaved(item.id) ? "bookmark.fill" : "bookmark")
                        .labelStyle(.titleAndIcon)
                        .font(.system(size: 14))
                        .foregroundColor(cubanewsViewModel.isSaved(item.id) ? .accentColor : .secondary)
                }
                // Share button
                Button(action: {
                    AnalyticsService.shared.logArticleShare(
                        articleId: String(item.id),
                        source: item.source.rawValue,
                        method: "share_sheet"
                    )
                    showingShareSheet = true
                }) {
                    Label("Compartir", systemImage: "square.and.arrow.up")
                        .labelStyle(.titleAndIcon)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
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
