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
final class SavedItem: Sendable {
    @Attribute(.unique) var id: Int64

    init(id: Int64) {
        self.id = id
    }
}

@available(iOS 17, *)
@Model
final class CachedFeedItem: Sendable {
    @Attribute(.unique) var id: Int64
    var feedItem: FeedItem
    
    init(feedItem: FeedItem) {
        self.id = feedItem.id
        self.feedItem = feedItem
    }
}

struct FeedResponse: Codable, Sendable {
    let banter: String
    let content: FeedContent
}

struct FeedContent: Codable, Sendable {
    let timestamp: String
    let feed: [FeedItem]
}


@available(iOS 17, *)
@MainActor
final class CubanewsViewModel: ObservableObject {
    // Singleton shared instance
    static let shared = CubanewsViewModel()
    let TAG = "CubanewsViewModel"
    private static let sharedModelContainer: ModelContainer = {
        do {
            // ModelContainer initializer takes variadic model types; pass the type directly.
            let schema = Schema([SavedItem.self, CachedFeedItem.self, UserPreferences.self])
            return try ModelContainer(for: schema)
        } catch {
            let TAG = "CubanewsViewModel"
            fatalError("➡️ \(TAG) Failed to create ModelContainer for SavedItem and CachedFeedItem: \(error)")
        }
    }()

    private var currentPage: Int = 1
    private let pageSize: Int = 2

    @Published var isLoading: Bool = false
    @Published var savedItemIds: Set<Int64> = []
    @Published var allItemsIds: Set<Int64> = []
    @Published var latestNews: [FeedItem] = []
    @Published var moreNews: [FeedItem] = []
    @Published var selectedPublications: Set<String> = []

    private let modelContext: ModelContext

    // Prevent external initialization
    private init() {
        // We're on the MainActor; safe to access the sharedModelContainer.mainContext here.
        self.modelContext = Self.sharedModelContainer.mainContext
        loadSavedIds()
        loadPreferences()
        Task.detached {
            await ImageCache.shared.removeExpiredImages()
        }
    }
    
    func loadPreferences() {
        if let userPrefs = ((try? modelContext.fetch(FetchDescriptor<UserPreferences>())) ?? []).first {
            NSLog("➡️ \(TAG) Found preferences with \(userPrefs.preferredPublications.count) publications")
            selectedPublications = Set(userPrefs.preferredPublications)
            NSLog("➡️ \(TAG) selectedPublications now contains: \(Array(selectedPublications))")
        }
    }

    private func loadSavedIds() {
        let items = (try? modelContext.fetch(FetchDescriptor<SavedItem>())) ?? []
        savedItemIds = Set(items.map { $0.id })
    }
    
    func getAllItems() -> [FeedItem] {
        return latestNews + moreNews
    }

    func toggleSaved(for itemId: Int64) {

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
    
    func fetchItemsFromCache() -> [FeedItem] {
        NSLog("➡️ \(TAG): FetchingFeedItemsFromCache_START")
        let cachedItems = (try? modelContext.fetch(FetchDescriptor<CachedFeedItem>())) ?? []
        cachedItems.forEach { fetchImage(feedItem: $0.feedItem) }
        NSLog("➡️ \(TAG): FetchingFeedItemsFromCache_END")
        return cachedItems.map { $0.feedItem }
    }
    
    private func shouldUpdateLatestNews(with itemIds: Set<Int64>) -> Bool {
        return self.latestNews.isEmpty || Set(self.latestNews.map { $0.id }).isDisjoint(with: itemIds)
    }
    
    func sortFeedItems(a: FeedItem, b: FeedItem) -> Bool {
        let aIsPreferred = selectedPublications.contains(a.source.rawValue)
        let bIsPreferred = selectedPublications.contains(b.source.rawValue)
        
        if aIsPreferred != bIsPreferred {
            return aIsPreferred
        }
        return a.isoDate > b.isoDate
    }

    func fetchFeedItems() async {
        self.latestNews = self.latestNews.sorted(by: sortFeedItems(a:b:))
        NSLog("➡️ \(TAG): FetchingFeedItems_START")
        if self.latestNews.isEmpty {
            let cachedItems = fetchItemsFromCache()
            NSLog("➡️ \(TAG): Cached items count: \(cachedItems.count)")
            if cachedItems.count > 0 {
                NSLog("➡️ \(TAG): Filling latest news from cache")
                self.latestNews = cachedItems.sorted(by: sortFeedItems(a:b:))
            }
        }
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }
        NSLog("➡️ \(TAG): FetchingFeedItemsFromWeb_START")
        let urlString = "https://www.cubanews.icu/api/feed?page=\(currentPage)&pageSize=\(pageSize)"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Invalid response from server \(urlString)")
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let decoded = try decoder.decode(FeedResponse.self, from: data)
            let newItems = decoded.content.feed.filter { !self.allItemsIds.contains($0.id) }
            if !newItems.isEmpty {
                self.allItemsIds.formUnion(newItems.map { $0.id })
                if (currentPage > 1) {
                    self.moreNews.append(contentsOf: newItems)
                } else if (shouldUpdateLatestNews(with: Set(newItems.map { $0.id }))) {
                    NSLog("➡️ \(TAG): Updating Latest News")
                    self.latestNews = newItems.sorted(by: sortFeedItems(a:b:))
                    let existingCachedItems = (try? modelContext.fetch(FetchDescriptor<CachedFeedItem>())) ?? []
                    for item in existingCachedItems {
                        modelContext.delete(item)
                    }
                    // Insert new cached items
                    NSLog("➡️ \(TAG): UpdatingCachedFeedItems_START")
                    for item in newItems {
                        let cachedItem = CachedFeedItem(feedItem: item)
                        modelContext.insert(cachedItem)
                    }
                    NSLog("➡️ \(TAG): UpdatingCachedFeedItems_END")
                    // Perform a single save for all operations
                    try? modelContext.save()
                    
                }
                currentPage += 1
            }
            newItems.forEach { fetchImage(feedItem: $0) }
            NSLog("➡️ \(TAG): FetchingFeedItemsFromWeb_END")
        } catch {
            print("❌ Failed to load feed:", error)
        }
    }

    func fetchImage(feedItem: FeedItem) {
        guard feedItem.imageBytes == nil else {
            return // Image already loaded
        }
        guard let imageUrlString = feedItem.image else {
            return // No image URL
        }
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
