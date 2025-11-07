//
//  SavedItemsManager.swift
//  cubanews-ios
//
//  Shared manager for tracking saved items across the app
//

import Foundation
import Combine

@MainActor
class SavedItemsManager: ObservableObject {
    @Published var savedItemIds: Set<Int64> = []
    
    private let cacheStore: FeedCacheStore?
    
    init() {
        self.cacheStore = FeedCacheStore()
        loadSavedItemIds()
    }
    
    /// Load all saved item IDs from the database
    func loadSavedItemIds() {
        guard let store = cacheStore else { return }
        let savedItems = store.loadSaved()
        savedItemIds = Set(savedItems.map { $0.id })
    }
    
    /// Check if an item is saved
    func isSaved(_ itemId: Int64) -> Bool {
        return savedItemIds.contains(itemId)
    }
    
    /// Toggle the saved state of an item
    func toggleSaved(for itemId: Int64) {
        if savedItemIds.contains(itemId) {
            // Remove from saved
            savedItemIds.remove(itemId)
            cacheStore?.updateSaved(for: itemId, saved: false)
        } else {
            // Add to saved
            savedItemIds.insert(itemId)
            cacheStore?.updateSaved(for: itemId, saved: true)
        }
    }
    
    /// Save an item
    func save(_ itemId: Int64) {
        savedItemIds.insert(itemId)
        cacheStore?.updateSaved(for: itemId, saved: true)
    }
    
    /// Unsave an item
    func unsave(_ itemId: Int64) {
        savedItemIds.remove(itemId)
        cacheStore?.updateSaved(for: itemId, saved: false)
    }
}
