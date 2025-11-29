//
//  InteractionDataTests.swift
//  cubanews-iosTests
//
//

import Testing
import Foundation
@testable import cubanews_ios

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
