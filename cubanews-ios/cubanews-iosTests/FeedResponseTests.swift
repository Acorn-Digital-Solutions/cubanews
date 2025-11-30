//
//  FeedResponseTests.swift
//  cubanews-iosTests
//
//

import Testing
import Foundation
@testable import cubanews_ios

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
