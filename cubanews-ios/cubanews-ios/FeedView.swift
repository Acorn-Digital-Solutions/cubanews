//
//  FeedView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 12/10/2025.
//

import SwiftUI
import Combine
import FirebaseStorage
import SQLite3

@MainActor
class FeedViewModel: ObservableObject {
    @Published var items: [FeedItem] = []
    @Published var isLoading: Bool = false
    
    private var currentPage: Int = 1
    private let pageSize: Int = 2
    
    private let cacheStore = FeedCacheStore()
    
    func fetchFeedItems(reset: Bool = false) async {
        guard !isLoading else { return }
        
        if reset {
            currentPage = 1
            // Show cached data immediately if present
            primeFromCache()
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let urlString = "https://www.cubanews.icu/api/feed?page=\(currentPage)&pageSize=\(pageSize)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                
                print("❌ Invalid response from server \(urlString)")
                return
            }
            
            struct FeedResponse: Codable {
                let banter: String
                let content: FeedContent
            }
            
            struct FeedContent: Codable {
                let timestamp: String
                let feed: [FeedItem]
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let decoded = try decoder.decode(FeedResponse.self, from: data)
            let newItems = decoded.content.feed
            let existingIds = Set(items.map { $0.id })
            let uniqueNewItems = newItems.filter { !existingIds.contains($0.id) }
            if !newItems.isEmpty {
                let uniqueNewItems = newItems.filter { !existingIds.contains($0.id) }
                self.items.append(contentsOf: uniqueNewItems)
                currentPage += 1
                // Persist/merge the new items locally in SQLite
                cacheStore?.upsertMany(uniqueNewItems)
            }
            uniqueNewItems.forEach { fetchImage(feedItem: $0) }
            
        } catch {
            print("❌ Failed to load feed:", error)
        }
    }
    
    func fetchImage(feedItem: FeedItem) {
        guard let imageUrlString = feedItem.image, feedItem.imageLoadingState == .LOADING else { return }

        Task.detached(priority: .background) {
            do {
                let storageRef = Storage.storage().reference(forURL: imageUrlString)
                let data = try await storageRef.data(maxSize: 5 * 1024 * 1024) // 5MB limit
                
                await MainActor.run {
                    self.updateImageState(for: feedItem.id, data: data, state: .LOADED)
                }
            } catch {
                await MainActor.run {
                    self.updateImageState(for: feedItem.id, data: nil, state: .ERROR)
                }
            }
        }
    }

    private func updateImageState(for id: Int64, data: Data?, state: ImageLoadingState) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            var item = items[index]
            item.imageBytes = data
            item.imageLoadingState = state
            items[index] = item
            cacheStore?.upsertImage(for: id, data: data, state: state)
        }
    }
    
    func primeFromCache() {
        if let store = cacheStore {
            self.items = store.loadAll()
        }
    }
}

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.items) { item in
                    FeedItemView(item: item)
                        .padding(.horizontal)
                        .onAppear {
                            if item == viewModel.items.last {
                                Task {
                                    await viewModel.fetchFeedItems()
                                }
                            }
                        }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.top)
        }
    }

    var body: some View {
        NavigationView {
            content
                .background(Color(.systemBackground))
                .navigationTitle("Cubanews")
                .task {
                    viewModel.primeFromCache()
                    await viewModel.fetchFeedItems(reset: true)
                }
        }
    }
}
