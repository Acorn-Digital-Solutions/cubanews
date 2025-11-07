//
//  cubanews_iosTests.swift
//  cubanews-iosTests
//
//

import Testing
import Foundation
@testable import cubanews_ios

struct cubanews_iosTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func testSaveFeedItem() async throws {
        // Create a test FeedItem
        let testItem = FeedItem(
            id: 12345,
            title: "Test News Item",
            url: "https://example.com/test",
            source: .ADNCUBA,
            updated: 1699999999,
            isoDate: "2023-11-15T00:00:00.000Z",
            feedts: 1699999999,
            content: "Test content",
            tags: ["test"],
            score: 10,
            interactions: InteractionData(feedid: 12345),
            aiSummary: "Test summary",
            image: nil,
            imageBytes: nil,
            imageLoadingState: .LOADED,
            saved: false
        )
        
        // Create a cache store with a test database
        let testDB = "test_feed_cache_\(UUID().uuidString).sqlite"
        guard let store = FeedCacheStore(fileName: testDB) else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create test cache store"])
        }
        
        // Insert the test item
        store.upsertMany([testItem])
        
        // Verify it's not saved initially
        var loadedItems = store.loadAll()
        #expect(loadedItems.count == 1)
        #expect(loadedItems[0].saved == false)
        
        // Save the item
        store.updateSaved(for: testItem.id, saved: true)
        
        // Verify it's now saved
        loadedItems = store.loadAll()
        #expect(loadedItems.count == 1)
        #expect(loadedItems[0].saved == true)
        
        // Verify it appears in saved items
        let savedItems = store.loadSaved()
        #expect(savedItems.count == 1)
        #expect(savedItems[0].id == testItem.id)
        
        // Clean up: remove test database
        try? FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(testDB))
    }
    
    @Test func testSaveStatusPreservedOnUpdate() async throws {
        // Create a test FeedItem
        let testItem = FeedItem(
            id: 54321,
            title: "Original Title",
            url: "https://example.com/test2",
            source: .CIBERCUBA,
            updated: 1699999999,
            isoDate: "2023-11-15T00:00:00.000Z",
            feedts: 1699999999,
            saved: false
        )
        
        // Create a cache store with a test database
        let testDB = "test_feed_cache_\(UUID().uuidString).sqlite"
        guard let store = FeedCacheStore(fileName: testDB) else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create test cache store"])
        }
        
        // Insert and save the item
        store.upsertMany([testItem])
        store.updateSaved(for: testItem.id, saved: true)
        
        // Update the item with new information
        let updatedItem = FeedItem(
            id: 54321,
            title: "Updated Title",
            url: "https://example.com/test2",
            source: .CIBERCUBA,
            updated: 1700000000,
            isoDate: "2023-11-15T00:00:00.000Z",
            feedts: 1700000000,
            saved: false  // This should be ignored because the item was already saved
        )
        store.upsertMany([updatedItem])
        
        // Verify the save status was preserved
        let loadedItems = store.loadAll()
        #expect(loadedItems.count == 1)
        #expect(loadedItems[0].title == "Updated Title")
        #expect(loadedItems[0].saved == true)
        
        // Clean up
        try? FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(testDB))
    }
    
    @Test func testFeedItemViewModelInitialization() async throws {
        // Test that the view model initializes with the correct saved state
        let savedItem = FeedItem(
            id: 99999,
            title: "Saved Item",
            url: "https://example.com/saved",
            source: .ELTOQUE,
            saved: true
        )
        
        let viewModel = FeedItemViewModel(savedItem)
        #expect(viewModel.isSaved == true)
        
        let unsavedItem = FeedItem(
            id: 88888,
            title: "Unsaved Item",
            url: "https://example.com/unsaved",
            source: .CUBANET,
            saved: false
        )
        
        let viewModel2 = FeedItemViewModel(unsavedItem)
        #expect(viewModel2.isSaved == false)
    }

}
