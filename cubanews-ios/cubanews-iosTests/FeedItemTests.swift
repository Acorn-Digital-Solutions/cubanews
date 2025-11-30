//
//  FeedItemTests.swift
//  cubanews-iosTests
//
//

import Testing
import Foundation
@testable import cubanews_ios

struct FeedItemTests {
    
    @Test func testFeedItemInitialization() throws {
        let item = FeedItem(
            id: 1,
            title: "Test Title",
            url: "https://example.com",
            source: .ADNCUBA
        )
        
        #expect(item.id == 1)
        #expect(item.title == "Test Title")
        #expect(item.url == "https://example.com")
        #expect(item.source == .ADNCUBA)
        #expect(item.updated == 0)
        #expect(item.isoDate == "")
        #expect(item.feedts == nil)
        #expect(item.content == nil)
        #expect(item.tags.isEmpty)
        #expect(item.score == 0)
        #expect(item.aiSummary == nil)
        #expect(item.image == nil)
        #expect(item.imageBytes == nil)
        #expect(item.imageLoadingState == .LOADING)
        #expect(item.saved == false)
    }
    
    @Test func testFeedItemFullInitialization() throws {
        let interactions = InteractionData(feedid: 1, likes: 10, comments: 5, shares: 2)
        let imageData = "test".data(using: .utf8)
        
        let item = FeedItem(
            id: 1,
            title: "Test Title",
            url: "https://example.com",
            source: .CIBERCUBA,
            updated: 1234567890,
            isoDate: "2024-01-01T12:00:00Z",
            feedts: 9876543210,
            content: "Test content",
            tags: ["politics", "economy"],
            score: 95,
            interactions: interactions,
            aiSummary: "AI generated summary",
            image: "https://image.example.com/test.jpg",
            imageBytes: imageData,
            imageLoadingState: .LOADED,
            saved: true
        )
        
        #expect(item.id == 1)
        #expect(item.title == "Test Title")
        #expect(item.url == "https://example.com")
        #expect(item.source == .CIBERCUBA)
        #expect(item.updated == 1234567890)
        #expect(item.isoDate == "2024-01-01T12:00:00Z")
        #expect(item.feedts == 9876543210)
        #expect(item.content == "Test content")
        #expect(item.tags == ["politics", "economy"])
        #expect(item.score == 95)
        #expect(item.interactions.likes == 10)
        #expect(item.aiSummary == "AI generated summary")
        #expect(item.image == "https://image.example.com/test.jpg")
        #expect(item.imageBytes == imageData)
        #expect(item.imageLoadingState == .LOADED)
        #expect(item.saved == true)
    }
    
    @Test func testFeedItemEquatable() throws {
        let item1 = FeedItem(id: 1, title: "Title 1", url: "https://example1.com", source: .ADNCUBA)
        let item2 = FeedItem(id: 1, title: "Title 2", url: "https://example2.com", source: .CIBERCUBA)
        let item3 = FeedItem(id: 2, title: "Title 1", url: "https://example1.com", source: .ADNCUBA)
        
        // Items with same ID should be equal (regardless of other properties)
        #expect(item1 == item2)
        // Items with different IDs should not be equal
        #expect(item1 != item3)
    }
    
    @Test func testFeedItemIdentifiable() throws {
        let item = FeedItem(id: 42, title: "Test", url: "https://test.com", source: .ELTOQUE)
        #expect(item.id == 42)
    }
    
    @Test func testFeedItemDecodingFromJSON() throws {
        let json = """
        {
            "id": 123,
            "title": "Breaking News",
            "url": "https://news.example.com/article",
            "source": "CUBANET",
            "updated": 1700000000,
            "isoDate": "2024-01-15T10:30:00.000Z",
            "feedts": 1700000001,
            "content": "Full article content here",
            "tags": ["breaking", "news"],
            "score": 85,
            "interactions": {
                "feedid": 123,
                "likes": 50,
                "comments": 20,
                "shares": 10
            },
            "aiSummary": "Summary of the article",
            "image": "https://images.example.com/photo.jpg"
        }
        """
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let item = try decoder.decode(FeedItem.self, from: json.data(using: .utf8)!)
        
        #expect(item.id == 123)
        #expect(item.title == "Breaking News")
        #expect(item.url == "https://news.example.com/article")
        #expect(item.source == .CUBANET)
        #expect(item.updated == 1700000000)
        #expect(item.isoDate == "2024-01-15T10:30:00.000Z")
        #expect(item.feedts == 1700000001)
        #expect(item.content == "Full article content here")
        #expect(item.tags == ["breaking", "news"])
        #expect(item.score == 85)
        #expect(item.interactions.likes == 50)
        #expect(item.aiSummary == "Summary of the article")
        #expect(item.image == "https://images.example.com/photo.jpg")
        #expect(item.imageBytes == nil)
        #expect(item.imageLoadingState == .LOADING)
    }
    
    @Test func testFeedItemDecodingWithStringUpdated() throws {
        let json = """
        {
            "id": 456,
            "title": "Test",
            "url": "https://test.com",
            "source": "ADNCUBA",
            "updated": "1700000000",
            "isoDate": "2024-01-15T10:30:00.000Z"
        }
        """
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let item = try decoder.decode(FeedItem.self, from: json.data(using: .utf8)!)
        
        #expect(item.updated == 1700000000)
    }
    
    @Test func testFeedItemDecodingWithStringFeedts() throws {
        let json = """
        {
            "id": 789,
            "title": "Test",
            "url": "https://test.com",
            "source": "ELTOQUE",
            "updated": 0,
            "isoDate": "2024-01-15T10:30:00.000Z",
            "feedts": "9876543210"
        }
        """
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let item = try decoder.decode(FeedItem.self, from: json.data(using: .utf8)!)
        
        #expect(item.feedts == 9876543210)
    }
    
    @Test func testFeedItemDecodingWithMissingOptionalFields() throws {
        let json = """
        {
            "id": 999,
            "title": "Minimal Article",
            "url": "https://minimal.com",
            "source": "DIARIODECUBA",
            "updated": 0,
            "isoDate": "2024-01-15T10:30:00.000Z"
        }
        """
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let item = try decoder.decode(FeedItem.self, from: json.data(using: .utf8)!)
        
        #expect(item.id == 999)
        #expect(item.title == "Minimal Article")
        #expect(item.content == nil)
        #expect(item.tags.isEmpty)
        #expect(item.score == 0)
        #expect(item.aiSummary == nil)
        #expect(item.image == nil)
    }
    
    @Test func testFeedItemDecodingUnknownSource() throws {
        let json = """
        {
            "id": 111,
            "title": "Unknown Source Article",
            "url": "https://unknown.com",
            "source": "UNKNOWNSOURCE",
            "updated": 0,
            "isoDate": "2024-01-15T10:30:00.000Z"
        }
        """
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let item = try decoder.decode(FeedItem.self, from: json.data(using: .utf8)!)
        
        #expect(item.source == .unknown)
    }
}
