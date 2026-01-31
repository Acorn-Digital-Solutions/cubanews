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
    let TAG = "CubanewsViewModel"
    
    private var currentPage: Int = 1
    private let pageSize: Int = 2

    @Published var isLoading: Bool = false
    @Published var refreshing: Bool = false
    @Published var savedItemIds: Set<Int64> = []
    @Published var allItemsIds: Set<Int64> = []
    @Published var latestNews: [FeedItem] = []
    @Published var moreNews: [FeedItem] = []
    @Published var selectedPublications: Set<String> = []
    private var fetchTask: Task<Void, Never>?

    private let modelContext: ModelContext

    private var didRunStartupCleanup = false
    private var isInitialized = false

    // Initialize with ModelContext from app level
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Call this after ViewModel is created to perform heavy initialization
    func initialize() async {
        guard !isInitialized else { return }
        isInitialized = true
        
        // Load critical data first (lightweight, sync on main thread)
        await MainActor.run {
            loadSavedIds()
            loadPreferences()
        }
        
        // Defer everything else - will load on first fetch
        Task.detached(priority: .background) {
            await ImageCache.shared.removeExpiredImages()
        }
    }
    
    private func loadCachedItemsToLatestNews() async {
        let cachedItems = await fetchItemsFromCache(loadImages: false)
        if !cachedItems.isEmpty {
            await MainActor.run {
                self.latestNews = cachedItems.sorted(by: sortFeedItems(a:b:))
            }
        }
    }
    
    func loadPreferences() {
        if let userPrefs = ((try? modelContext.fetch(FetchDescriptor<UserPreferences>())) ?? []).first {
            selectedPublications = Set(userPrefs.preferredPublications)
        }
    }
    
    func reloadPreferencesAndResort() {
        loadPreferences()
        // Re-sort the latestNews list with the updated preferences
        self.latestNews = self.latestNews.sorted(by: sortFeedItems(a:b:))
        NSLog("➡️ \(TAG) Re-sorted latestNews with updated preferences")
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
    
    private func fetchItemsFromCache(loadImages: Bool = true) async -> [FeedItem] {
        let cachedItems = (try? modelContext.fetch(FetchDescriptor<CachedFeedItem>())) ?? []
        let items = cachedItems.map { $0.feedItem }
        // Fetch images only if requested, defer for startup performance
        if loadImages {
            for item in items {
                fetchImage(feedItem: item)
            }
        }
        return items
    }
    
    private func shouldUpdateLatestNews(with itemIds: Set<Int64>) -> Bool {
        // Always update if latest news is empty
        if self.latestNews.isEmpty {
            return true
        }
        let currentIds = Set(self.latestNews.map { $0.id })
        
        // Update if there are new items we don't have, or if items have been removed from the server
        // This ensures we stay in sync with the server's first page
        return currentIds != itemIds
    }
    
    func sortFeedItems(a: FeedItem, b: FeedItem) -> Bool {
        let aIsPreferred = selectedPublications.contains(a.source.rawValue)
        let bIsPreferred = selectedPublications.contains(b.source.rawValue)
        
        if aIsPreferred != bIsPreferred {
            return aIsPreferred
        }
        return a.isoDate > b.isoDate
    }

    func startFetch(reset: Bool = false) {
        // Prevent multiple simultaneous refreshes
        if reset {
            guard !refreshing else { return }
            // Don't clear allItemsIds or moreNews here - let the fetch handle updates
            currentPage = 1
            refreshing = true
        }

        // Cancel any ongoing fetch
        fetchTask?.cancel()
        fetchTask = Task { [weak self] in
            guard let self else { return }
            await self.fetchFeedItems()
            // Reset refreshing on the main actor after fetch completes
            await MainActor.run {
                self.refreshing = false
            }
        }
    }

    private func fetchFeedItems() async {
        guard !isLoading else { return }
        
        // Load cache on first fetch if latestNews is empty
        if latestNews.isEmpty && currentPage == 1 {
            await loadCachedItemsToLatestNews()
        }
        
        // If this is a reset (manual refresh), clear pagination state
        if currentPage == 1 && refreshing {
            self.allItemsIds = []
            self.moreNews = []
        }
        
        isLoading = true
        defer { isLoading = false }
        let urlString = "\(Config.CUBANEWS_API.trimmingCharacters(in: .whitespacesAndNewlines))/feed?page=\(currentPage)&pageSize=\(pageSize)"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                NSLog("❌ \(TAG) Invalid response from server \(urlString)")
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
                    self.latestNews = newItems.sorted(by: sortFeedItems(a:b:))
                    let existingCachedItems = (try? modelContext.fetch(FetchDescriptor<CachedFeedItem>())) ?? []
                    for item in existingCachedItems {
                        modelContext.delete(item)
                    }
                    // Insert new cached items
                    for item in newItems {
                        let cachedItem = CachedFeedItem(feedItem: item)
                        modelContext.insert(cachedItem)
                    }
                    // Perform a single save for all operations
                    try? modelContext.save()
                }
                currentPage += 1
                if currentPage == 2 { // first page just loaded successfully
                    performStartupCleanupIfNeeded()
                }
            }
            newItems.forEach { fetchImage(feedItem: $0) }
        } catch is CancellationError {
            NSLog("➡️ \(TAG): Request was cancelled")
            return
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                NSLog("➡️ \(TAG): URLSession task cancelled")
                return
            }
            print("❌ Failed to load feed:", error)
        }
    }

    private func performStartupCleanupIfNeeded() {
        guard !didRunStartupCleanup else { return }
        didRunStartupCleanup = true

        let cutoff = Date().addingTimeInterval(-48 * 60 * 60)

        // Remove old cached feed items based on FeedItem.isoDate
        let isoFormatter = ISO8601DateFormatter()
        let allCached = (try? modelContext.fetch(FetchDescriptor<CachedFeedItem>())) ?? []

        for cached in allCached {
            if let articleDate = isoFormatter.date(from: cached.feedItem.isoDate),
               articleDate < cutoff {
                modelContext.delete(cached)
            }
        }

        try? modelContext.save()

        // Clean image disk cache (48h)
        Task.detached {
            await ImageCache.shared.removeExpiredImages()
        }

        NSLog("➡️ \(TAG): Startup cache cleanup completed")
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
