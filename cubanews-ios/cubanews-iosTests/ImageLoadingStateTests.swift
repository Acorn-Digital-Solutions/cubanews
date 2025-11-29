//
//  ImageLoadingStateTests.swift
//  cubanews-iosTests
//
//

import Testing
import Foundation
@testable import cubanews_ios

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
