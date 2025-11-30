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
    private static let TAG: String = "FeedItemView"
    
    /// Threshold to distinguish milliseconds from seconds timestamps.
    /// This value (1_000_000_000_000) corresponds to September 9, 2001 when interpreted as seconds.
    /// Timestamps greater than this are assumed to be in milliseconds.
    private static let millisecondsThreshold: Int64 = 1_000_000_000_000
    
    let item: FeedItem
    @Environment(\.openURL) var openURL
    @State private var showingShareSheet = false
    private var cubanewsViewModel = CubanewsViewModel.shared

    // Make the initializer explicit and internal so it's accessible from other views
    init(item: FeedItem) {
        self.item = item
    }
    
    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        // Debug logging
        #if DEBUG
        NSLog("\(TAG): 🌍 RelativeDateTimeFormatter locale: \(formatter.locale?.identifier ?? "nil")")
        NSLog("\(TAG): 🌍 Current device locale: \(Locale.current.identifier)")
        NSLog("\(TAG): 🌍 Preferred languages: \(Locale.preferredLanguages)")
        #endif
        formatter.locale = Locale(identifier: Locale.preferredLanguages.first ?? "es_ES")
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        
        return formatter
    }()

    private static let iso8601DateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = .current
        f.timeZone = .current
        return f
    }()

    private static func resolvedDate(for item: FeedItem) -> Date? {
        // Try ISO 8601 first
        if !item.isoDate.isEmpty, let isoParsed = iso8601DateFormatter.date(from: item.isoDate) {
            return isoParsed
        }
        // Fallback to feedts then updated epoch (seconds or milliseconds)
        let candidates: [Int64?] = [item.feedts, item.updated]
        for candidate in candidates {
            if let raw = candidate, raw > 0 {
                // Detect ms vs s using millisecondsThreshold
                let seconds: TimeInterval = raw > millisecondsThreshold ? TimeInterval(raw) / 1000.0 : TimeInterval(raw)
                return Date(timeIntervalSince1970: seconds)
            }
        }
        return nil
    }

    private static func relativeTimeString(for item: FeedItem) -> String {
        guard let date = resolvedDate(for: item) else { return "Unknown time" }
        let now = Date()
        // Clamp future dates to now to avoid "in X" for slight clock skews
        let reference = date > now ? now : date
        return relativeDateFormatter.localizedString(for: reference, relativeTo: now)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Source and Date
            HStack {
                let sourceImage = UIImage(named: item.source.rawValue.lowercased()) ?? UIImage(systemName: "newspaper")
                let relative = Self.relativeTimeString(for: item)
                Image(uiImage: sourceImage!)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(item.source.rawValue.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                // Replaced absolute date with relative time string
                Text(relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Published " + relative)
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

            // Separator
            Divider()
                .padding(.vertical, 4)

            // Save and Share buttons
            HStack(spacing: 20) {
                Spacer()

                // Save button
                Button(action: {
                    cubanewsViewModel.toggleSaved(for: item.id)
                }) {
                    Image(systemName: cubanewsViewModel.isSaved(item.id) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(cubanewsViewModel.isSaved(item.id) ? .accentColor : .secondary)
                }
                .buttonStyle(.plain)

                // Share button
                Button(action: {
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
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
