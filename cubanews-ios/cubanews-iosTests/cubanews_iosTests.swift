//
//  cubanews_iosTests.swift
//  cubanews-iosTests
//
//

import Testing
import Foundation
@testable import cubanews_ios

// MARK: - NewsSourceName Tests

struct NewsSourceNameTests {
    
    @Test func testNewsSourceNameRawValues() throws {
        #expect(NewsSourceName.ADNCUBA.rawValue == "ADNCUBA")
        #expect(NewsSourceName.CATORCEYMEDIO.rawValue == "CATORCEYMEDIO")
        #expect(NewsSourceName.DIARIODECUBA.rawValue == "DIARIODECUBA")
        #expect(NewsSourceName.CIBERCUBA.rawValue == "CIBERCUBA")
        #expect(NewsSourceName.ELTOQUE.rawValue == "ELTOQUE")
        #expect(NewsSourceName.CUBANET.rawValue == "CUBANET")
        #expect(NewsSourceName.unknown.rawValue == "unknown")
    }
    
    @Test func testNewsSourceNameDecoding() throws {
        let jsonADNCUBA = "\"ADNCUBA\""
        let jsonLowercase = "\"adncuba\""
        let jsonUnknown = "\"invalidSource\""
        
        let decoder = JSONDecoder()
        
        let decodedUpper = try decoder.decode(NewsSourceName.self, from: jsonADNCUBA.data(using: .utf8)!)
        #expect(decodedUpper == .ADNCUBA)
        
        let decodedLower = try decoder.decode(NewsSourceName.self, from: jsonLowercase.data(using: .utf8)!)
        #expect(decodedLower == .ADNCUBA)
        
        let decodedUnknown = try decoder.decode(NewsSourceName.self, from: jsonUnknown.data(using: .utf8)!)
        #expect(decodedUnknown == .unknown)
    }
    
    @Test func testNewsSourceNameCaseInsensitiveDecoding() throws {
        let sources = ["CIBERCUBA", "cibercuba", "CiberCuba", "CIBERCUBA"]
        let decoder = JSONDecoder()
        
        for source in sources {
            let json = "\"\(source)\""
            let decoded = try decoder.decode(NewsSourceName.self, from: json.data(using: .utf8)!)
            #expect(decoded == .CIBERCUBA)
        }
    }
}

// MARK: - InteractionData Tests

struct InteractionDataTests {
    
    @Test func testInteractionDataInitialization() throws {
        let interaction = InteractionData(feedid: 123, likes: 10, comments: 5, shares: 2)
        
        #expect(interaction.feedid == 123)
        #expect(interaction.likes == 10)
        #expect(interaction.comments == 5)
        #expect(interaction.shares == 2)
    }
    
    @Test func testInteractionDataDefaultValues() throws {
        let interaction = InteractionData(feedid: 456)
        
        #expect(interaction.feedid == 456)
        #expect(interaction.likes == nil)
        #expect(interaction.comments == nil)
        #expect(interaction.shares == nil)
    }
    
    @Test func testInteractionDataCodable() throws {
        let interaction = InteractionData(feedid: 789, likes: 100, comments: 50, shares: 25)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(interaction)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(InteractionData.self, from: data)
        
        #expect(decoded.feedid == interaction.feedid)
        #expect(decoded.likes == interaction.likes)
        #expect(decoded.comments == interaction.comments)
        #expect(decoded.shares == interaction.shares)
    }
    
    @Test func testInteractionDataDecodingWithNullValues() throws {
        let json = """
        {"feedid": 123, "likes": null, "comments": null, "shares": null}
        """
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(InteractionData.self, from: json.data(using: .utf8)!)
        
        #expect(decoded.feedid == 123)
        #expect(decoded.likes == nil)
        #expect(decoded.comments == nil)
        #expect(decoded.shares == nil)
    }
}

// MARK: - ImageLoadingState Tests

struct ImageLoadingStateTests {
    
    @Test func testImageLoadingStateRawValues() throws {
        #expect(ImageLoadingState.LOADING.rawValue == "LOADING")
        #expect(ImageLoadingState.LOADED.rawValue == "LOADED")
        #expect(ImageLoadingState.ERROR.rawValue == "ERROR")
    }
    
    @Test func testImageLoadingStateCodable() throws {
        let states: [ImageLoadingState] = [.LOADING, .LOADED, .ERROR]
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for state in states {
            let data = try encoder.encode(state)
            let decoded = try decoder.decode(ImageLoadingState.self, from: data)
            #expect(decoded == state)
        }
    }
}

// MARK: - FeedItem Tests

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

// MARK: - FeedItem Array Extension Tests

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

// MARK: - FeedResponse Tests

struct FeedResponseTests {
    
    @Test func testFeedResponseDecoding() throws {
        let json = """
        {
            "banter": "Good morning!",
            "content": {
                "timestamp": "2024-01-15T10:30:00.000Z",
                "feed": [
                    {
                        "id": 1,
                        "title": "News Article",
                        "url": "https://news.com",
                        "source": "ADNCUBA",
                        "updated": 0,
                        "isoDate": "2024-01-15T10:30:00.000Z"
                    }
                ]
            }
        }
        """
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(FeedResponse.self, from: json.data(using: .utf8)!)
        
        #expect(response.banter == "Good morning!")
        #expect(response.content.timestamp == "2024-01-15T10:30:00.000Z")
        #expect(response.content.feed.count == 1)
        #expect(response.content.feed[0].title == "News Article")
    }
    
    @Test func testFeedContentDecoding() throws {
        let json = """
        {
            "timestamp": "2024-01-15T10:30:00.000Z",
            "feed": []
        }
        """
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let content = try decoder.decode(FeedContent.self, from: json.data(using: .utf8)!)
        
        #expect(content.timestamp == "2024-01-15T10:30:00.000Z")
        #expect(content.feed.isEmpty)
    }
}
