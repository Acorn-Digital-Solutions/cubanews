//
//  Config.swift
//  cubanews-ios
//
//  Environment configuration
//

import Foundation

enum Config {
    static var CUBANEWS_API: String {
        guard let apiURL = Bundle.main.object(forInfoDictionaryKey: "CUBANEWS_API") as? String else {
            fatalError("CUBANEWS_API not found in Info.plist")
        }
        return apiURL
    }
}
