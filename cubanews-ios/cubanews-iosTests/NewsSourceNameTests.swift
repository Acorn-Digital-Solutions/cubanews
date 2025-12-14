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
    
    @Test func testNewsSourceDisplayNames() throws {
        #expect(NewsSourceName.ADNCUBA.displayName == "ADNCuba")
        #expect(NewsSourceName.CATORCEYMEDIO.displayName == "14yMedio")
        #expect(NewsSourceName.DIARIODECUBA.displayName == "DiarioDeCuba")
        #expect(NewsSourceName.CIBERCUBA.displayName == "CiberCuba")
        #expect(NewsSourceName.ELTOQUE.displayName == "elTOQUE")
        #expect(NewsSourceName.CUBANET.displayName == "Cubanet")
        #expect(NewsSourceName.unknown.displayName == "Unknown")
    }
    
    @Test func testNewsSourceImageNames() throws {
        #expect(NewsSourceName.ADNCUBA.imageName == "adncuba")
        #expect(NewsSourceName.CATORCEYMEDIO.imageName == "catorceymedio")
        #expect(NewsSourceName.DIARIODECUBA.imageName == "ddc")
        #expect(NewsSourceName.CIBERCUBA.imageName == "cibercuba")
        #expect(NewsSourceName.ELTOQUE.imageName == "eltoque")
        #expect(NewsSourceName.CUBANET.imageName == "cubanet")
        #expect(NewsSourceName.unknown.imageName == "cubanewsIdentity")
    }
    
    @Test func testAllSourcesHaveDisplayNames() throws {
        // Ensure all cases have display names defined
        for source in NewsSourceName.allCases {
            let displayName = source.displayName
            #expect(!displayName.isEmpty, "Source \(source.rawValue) should have a non-empty display name")
        }
    }
    
    @Test func testAllSourcesHaveImageNames() throws {
        // Ensure all cases have image names defined
        for source in NewsSourceName.allCases {
            let imageName = source.imageName
            #expect(!imageName.isEmpty, "Source \(source.rawValue) should have a non-empty image name")
        }
    }
}
