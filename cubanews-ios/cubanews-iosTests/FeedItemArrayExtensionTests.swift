//
//  FeedItemArrayExtensionTests.swift
//  cubanews-iosTests
//
//

import Testing
import Foundation
@testable import cubanews_ios

struct FeedItemArrayExtensionTests {
    
    @Test func testRemovingDuplicatesWithNoDuplicates() throws {
        let items = [
            FeedItem(id: 1, title: "Article 1", url: "https://1.com", source: .ADNCUBA),
            FeedItem(id: 2, title: "Article 2", url: "https://2.com", source: .CIBERCUBA),
            FeedItem(id: 3, title: "Article 3", url: "https://3.com", source: .ELTOQUE)
        ]
        
        let result = items.removingDuplicates()
        
        #expect(result.count == 3)
        #expect(result[0].id == 1)
        #expect(result[1].id == 2)
        #expect(result[2].id == 3)
    }
    
    @Test func testRemovingDuplicatesWithDuplicates() throws {
        let items = [
            FeedItem(id: 1, title: "Article 1", url: "https://1.com", source: .ADNCUBA),
            FeedItem(id: 2, title: "Article 2", url: "https://2.com", source: .CIBERCUBA),
            FeedItem(id: 1, title: "Duplicate of 1", url: "https://1-dup.com", source: .ELTOQUE),
            FeedItem(id: 3, title: "Article 3", url: "https://3.com", source: .CUBANET),
            FeedItem(id: 2, title: "Duplicate of 2", url: "https://2-dup.com", source: .DIARIODECUBA)
        ]
        
        let result = items.removingDuplicates()
        
        #expect(result.count == 3)
        #expect(result[0].id == 1)
        #expect(result[1].id == 2)
        #expect(result[2].id == 3)
        // First occurrence should be kept
        #expect(result[0].title == "Article 1")
        #expect(result[1].title == "Article 2")
    }
    
    @Test func testRemovingDuplicatesWithEmptyArray() throws {
        let items: [FeedItem] = []
        let result = items.removingDuplicates()
        #expect(result.isEmpty)
    }
    
    @Test func testRemovingDuplicatesWithAllDuplicates() throws {
        let items = [
            FeedItem(id: 1, title: "First", url: "https://1.com", source: .ADNCUBA),
            FeedItem(id: 1, title: "Second", url: "https://2.com", source: .CIBERCUBA),
            FeedItem(id: 1, title: "Third", url: "https://3.com", source: .ELTOQUE)
        ]
        
        let result = items.removingDuplicates()
        
        #expect(result.count == 1)
        #expect(result[0].title == "First")
    }
    
    @Test func testRemovingDuplicatesPreservesOrder() throws {
        let items = [
            FeedItem(id: 5, title: "Five", url: "https://5.com", source: .ADNCUBA),
            FeedItem(id: 3, title: "Three", url: "https://3.com", source: .CIBERCUBA),
            FeedItem(id: 1, title: "One", url: "https://1.com", source: .ELTOQUE),
            FeedItem(id: 4, title: "Four", url: "https://4.com", source: .CUBANET),
            FeedItem(id: 2, title: "Two", url: "https://2.com", source: .DIARIODECUBA)
        ]
        
        let result = items.removingDuplicates()
        
        #expect(result.count == 5)
        #expect(result.map { $0.id } == [5, 3, 1, 4, 2])
    }
}
