import SwiftUI
import FirebaseStorage
import Combine
import SwiftData

actor ImageCache {
    static let shared = ImageCache()

    private let folderURL: URL = {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("CubanewsImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    private func fileURL(for id: Int64) -> URL {
        folderURL.appendingPathComponent("\(id).img")
    }

    func saveImage(_ data: Data, for id: Int64) async {
        let url = fileURL(for: id)
        try? data.write(to: url, options: .atomic)
    }

    func loadImage(for id: Int64) async -> Data? {
        let url = fileURL(for: id)
        return try? Data(contentsOf: url)
    }

    func removeExpiredImages() async {
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        )) ?? []

        let now = Date()
        let expiration: TimeInterval = 24 * 60 * 60

        for url in urls {
            let values = try? url.resourceValues(forKeys: [.contentModificationDateKey])
            if let modified = values?.contentModificationDate,
               now.timeIntervalSince(modified) > expiration {
                try? FileManager.default.removeItem(at: url)
            }
        }
    }
}

//
//  CubanewsViewModel.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 15/11/2025.
//

@available(iOS 17, *)
@Model
final class SavedItem {
    @Attribute(.unique) var id: Int64

    init(id: Int64) {
        self.id = id
    }
}

@available(iOS 17, *)
@MainActor
final class CubanewsViewModel: ObservableObject {
    // Singleton shared instance
    static let shared = CubanewsViewModel()

    // Provide a local shared ModelContainer used by the view model when none is supplied.
    // Creating a ModelContainer can throw; we create it lazily and fall back to a runtime fatal error
    // if creation fails because SwiftData requires a properly configured model container.
    private static let sharedModelContainer: ModelContainer = {
        do {
            // ModelContainer initializer takes variadic model types; pass the type directly.
            return try ModelContainer(for: SavedItem.self)
        } catch {
            fatalError("Failed to create ModelContainer for SavedItem: \(error)")
        }
    }()

    private var currentPage: Int = 1
    private let pageSize: Int = 2

    @Published var isLoading: Bool = false
    @Published var savedItemIds: Set<Int64> = []
    @Published var allItemsIds: Set<Int64> = []
    @Published var latestNews: [FeedItem] = []
    @Published var moreNews: [FeedItem] = []

    private let modelContext: ModelContext

    // Prevent external initialization
    private init() {
        // We're on the MainActor; safe to access the sharedModelContainer.mainContext here.
        self.modelContext = Self.sharedModelContainer.mainContext
        loadSavedIds()
        Task.detached {
            await ImageCache.shared.removeExpiredImages()
        }
    }

    private func loadSavedIds() {
        let items = (try? modelContext.fetch(FetchDescriptor<SavedItem>())) ?? []
        savedItemIds = Set(items.map { $0.id })
    }
    
    func getAllItems() -> [FeedItem] {
        return latestNews + moreNews
    }

    func toogleSaved(for itemId: Int64) {

        if savedItemIds.contains(itemId) {
            savedItemIds.remove(itemId)
            // Remove from SwiftData
            if let existing = try? modelContext.fetch(
                FetchDescriptor<SavedItem>(
                    predicate: #Predicate { $0.id == itemId }
                )
            ).first {
                modelContext.delete(existing)
            }
        } else {
            savedItemIds.insert(itemId)
            // Save to SwiftData
            let newItem = SavedItem(id: itemId)
            modelContext.insert(newItem)
        }
        NSLog("Saved items: \(savedItemIds)")
        try? modelContext.save()

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
                if (currentPage == 1) {
                    self.latestNews.append(contentsOf: newItems)
                } else {
                    self.moreNews.append(contentsOf: newItems)
                }
                currentPage += 1
            }
            newItems.forEach { fetchImage(feedItem: $0) }
        } catch {
            print("❌ Failed to load feed:", error)
        }
    }

    func fetchImage(feedItem: FeedItem) {
        guard let imageUrlString = feedItem.image,
              feedItem.imageLoadingState == .LOADING else { return }

        Task {
            // Try disk cache first
            if let cachedData = await ImageCache.shared.loadImage(for: feedItem.id) {
                await MainActor.run {
                    self.updateImageState(for: feedItem.id, data: cachedData, state: .LOADED)
                }
                return
            }

            // Not cached: download
            do {
                let storageRef = Storage.storage().reference(forURL: imageUrlString)
                let data = try await storageRef.data(maxSize: 5 * 1024 * 1024)

                // Save to disk
                await ImageCache.shared.saveImage(data, for: feedItem.id)

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
        if let index = self.latestNews.firstIndex(where: { $0.id == id }) {
            var item = self.latestNews[index]
            item.imageBytes = data
            item.imageLoadingState = state
            self.latestNews[index] = item
        }
        
        if let index = self.moreNews.firstIndex(where: { $0.id == id }) {
            var item = self.moreNews[index]
            item.imageBytes = data
            item.imageLoadingState = state
            self.moreNews[index] = item
        }
    }

}
