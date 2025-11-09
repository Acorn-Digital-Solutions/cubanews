import Foundation
import Cache

// A Cache library-backed store for FeedItem
final class FeedCacheStore {
    private let storage: Storage<String, FeedItem>?
    private let queue = DispatchQueue(label: "com.cubanews.feedcache.db", qos: .utility)
    
    // Track saved items separately
    private var savedItemIds: Set<Int64> = []
    private let savedItemsKey = "saved_item_ids"
    
    init?(fileName: String = "feed_cache") {
        do {
            let diskConfig = DiskConfig(name: fileName, expiry: .seconds(3600 * 36))
            let memoryConfig = MemoryConfig(expiry: .seconds(3600), countLimit: 10, totalCostLimit: 0)
            
            let transformer = TransformerFactory.forCodable(ofType: FeedItem.self)
            self.storage = try Storage(
                diskConfig: diskConfig,
                memoryConfig: memoryConfig,
                transformer: transformer
            )	
            
            // Load saved item IDs
            loadSavedItemIds()
        } catch {
            print("❌ FeedCacheStore: could not initialize storage:", error)
            return nil
        }
    }
    
    private func loadSavedItemIds() {
        guard let storage = storage else { return }
        
        // Try to load saved item IDs from a special key
        let stringStorage = storage.transformCodable(ofType: Set<Int64>.self)
        if let ids = try? stringStorage.object(forKey: savedItemsKey) {
            savedItemIds = ids
        }
    }
    
    private func saveSavedItemIds() {
        guard let storage = storage else { return }
        
        let stringStorage = storage.transformCodable(ofType: Set<Int64>.self)
        try? stringStorage.setObject(savedItemIds, forKey: savedItemsKey)
    }
    
    func loadSaved() -> [FeedItem] {
        return queue.sync {
            guard let storage = storage else { return [] }
            
            var savedItems: [FeedItem] = []
            for id in savedItemIds {
                if let item = try? storage.object(forKey: String(id)) {
                    savedItems.append(item)
                }
            }
            return savedItems.removingDuplicates()
        }
    }
    
    func loadAll() -> [FeedItem] {
        return queue.sync {
            guard let storage = storage else { return [] }
            
            var allItems: [FeedItem] = []
            
            // Load all keys from storage
            // Cache library doesn't have a direct way to iterate all keys,
            // so we'll need to track keys ourselves
            // For now, we'll combine saved and recently added items
            
            // This is a limitation - we need to track all item IDs
            // Let's try to use the existing disk storage to get all entries
            do {
                let entries = try storage.existsObject(forKey: "all_item_ids")
                if entries {
                    let stringStorage = storage.transformCodable(ofType: Set<Int64>.self)
                    if let allIds = try? stringStorage.object(forKey: "all_item_ids") {
                        for id in allIds {
                            if let item = try? storage.object(forKey: String(id)) {
                                allItems.append(item)
                            }
                        }
                    }
                }
            } catch {
                // No all_item_ids key exists, return empty
            }
            
            return allItems.removingDuplicates()
        }
    }
    
    func upsertMany(_ items: [FeedItem]) {
        queue.sync {
            guard let storage = storage else { return }
            
            // Load existing IDs
            let stringStorage = storage.transformCodable(ofType: Set<Int64>.self)
            var allIds: Set<Int64> = (try? stringStorage.object(forKey: "all_item_ids")) ?? []
            
            for item in items {
                let key = String(item.id)
                
                // Check if item already exists to preserve saved status and image data
                var itemToSave = item
                if let existingItem = try? storage.object(forKey: key) {
                    // Preserve saved status and image data from existing item
                    itemToSave = FeedItem(
                        id: item.id,
                        title: item.title,
                        url: item.url,
                        source: item.source,
                        updated: item.updated,
                        isoDate: item.isoDate,
                        feedts: item.feedts,
                        content: item.content,
                        tags: item.tags,
                        score: item.score,
                        interactions: item.interactions,
                        aiSummary: item.aiSummary,
                        image: item.image,
                        imageBytes: existingItem.imageBytes ?? item.imageBytes,
                        imageLoadingState: existingItem.imageLoadingState != .LOADING ? existingItem.imageLoadingState : item.imageLoadingState,
                        saved: existingItem.saved
                    )
                }
                
                try? storage.setObject(itemToSave, forKey: key)
                allIds.insert(item.id)
            }
            
            // Save updated IDs list
            try? stringStorage.setObject(allIds, forKey: "all_item_ids")
        }
    }
    
    func upsertImage(for id: Int64, data: Data?, state: ImageLoadingState) {
        queue.sync {
            guard let storage = storage else { return }
            
            let key = String(id)
            
            // Load existing item
            guard var item = try? storage.object(forKey: key) else { return }
            
            // Update image data and state
            item.imageBytes = data
            item.imageLoadingState = state
            
            // Save updated item
            try? storage.setObject(item, forKey: key)
        }
    }
    
    func updateSaved(for id: Int64, saved: Bool) {
        queue.sync {
            guard let storage = storage else { return }
            
            let key = String(id)
            
            // Load existing item
            guard var item = try? storage.object(forKey: key) else { return }
            
            // Update saved status
            item.saved = saved
            
            // Save updated item
            try? storage.setObject(item, forKey: key)
            
            // Update saved IDs set
            if saved {
                savedItemIds.insert(id)
            } else {
                savedItemIds.remove(id)
            }
            
            saveSavedItemIds()
        }
    }
    
    func clearAll() {
        queue.sync {
            guard let storage = storage else { return }
            try? storage.removeAll()
            savedItemIds.removeAll()
            saveSavedItemIds()
        }
    }
}
