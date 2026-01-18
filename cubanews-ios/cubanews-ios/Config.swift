//
//  Config.swift
//  cubanews-ios
//
//  Environment configuration
//

import Foundation

/// Environment configuration for the cubanews-ios app.
/// 
/// Configuration values are loaded from xcconfig files (Debug.xcconfig or Release.xcconfig)
/// and injected into Info.plist at build time.
/// 
/// Note: If CUBANEWS_API is missing, it indicates a build configuration error.
/// This should never happen in properly configured builds and will fail at app launch
/// to prevent incorrect API calls.
enum Config {
    /// The API endpoint URL for the current build configuration.
    /// - Debug builds: http://localhost:3000/api
    /// - Release builds: https://www.cubanews.icu/api
    static var CUBANEWS_API: String {
        guard let apiURL = Bundle.main.object(forInfoDictionaryKey: "CUBANEWS_API") as? String else {
            fatalError("CUBANEWS_API configuration missing from Info.plist. Ensure xcconfig files are properly configured for your build scheme.")
        }
        return apiURL
    }
}
