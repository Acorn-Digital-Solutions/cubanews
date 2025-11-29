//
//  NewsSourceNameTests.swift
//  cubanews-iosTests
//
//

import Testing
import Foundation
@testable import cubanews_ios

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
