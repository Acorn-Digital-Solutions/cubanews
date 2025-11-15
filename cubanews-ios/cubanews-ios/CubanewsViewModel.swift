import SwiftUI
import FirebaseStorage
import Combine

//
//  CubanewsViewModel.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 15/11/2025.
//

@MainActor
final class CubanewsViewModel: ObservableObject {
    // Singleton shared instance
    static let shared = CubanewsViewModel()
    
    private var currentPage: Int = 1
    private let pageSize: Int = 2
    
    @Published var isLoading: Bool = false
    @Published var savedItemIds: Set<Int64> = []
    @Published var allItemsIds: Set<Int64> = []
    @Published var allItems: [FeedItem] = []

    // Prevent external initialization
    private init() {
        // ...existing code...
    }
    
    func toogleSaved(for itemId: Int64) {
        if savedItemIds.contains(itemId) {
            savedItemIds.remove(itemId)
        } else {
            savedItemIds.insert(itemId)
        }
        NSLog("Saved items: \(savedItemIds)")
    }
    
    func isSaved(_ itemId: Int64) -> Bool {
        return savedItemIds.contains(itemId)
    }
    
    func fetchFeedItems() async {
        guard !isLoading else { return }
                
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
            let newItems = decoded.content.feed.filter { !self.allItemsIds.contains($0.id) }
            if !newItems.isEmpty {
                self.allItemsIds.formUnion(newItems.map { $0.id })
                self.allItems.append(contentsOf: newItems)
                currentPage += 1
            }
            newItems.forEach { fetchImage(feedItem: $0) }
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
        if let index = allItems.firstIndex(where: { $0.id == id }) {
            var item = allItems[index]
            item.imageBytes = data
            item.imageLoadingState = state
            allItems[index] = item
        }
    }

}
