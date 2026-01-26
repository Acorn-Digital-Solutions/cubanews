//
//  AnalyticsService.swift
//  cubanews-ios
//
//  Google Analytics service wrapper that only logs events in Release builds
//

import Foundation

 #if !DEBUG
import FirebaseAnalytics
 #endif

enum AnalyticsEvent: String {
    case AnalyticsEventShare="share"
    case AnalyticsEventLogin="login"
    case AnalyticsEventSignUp="sign_up"
    case AnalyticsEventScreenView="screen_view"
    
    
}
/// Service for logging analytics events
/// Only active in Release configuration - all calls are no-ops in Debug
class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    /// Log a custom event with optional parameters
    /// - Parameters:
    ///   - name: Event name (max 40 characters)
    ///   - parameters: Optional event parameters (max 25 parameters, keys max 40 chars, values max 100 chars)
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
         #if !DEBUG
        Analytics.logEvent(name, parameters: parameters)
        print("📊 Analytics Event: \(name)")
        if let params = parameters {
            print("   Parameters: \(params)")
        }
         #else
        // In debug mode, just log to console without sending to Firebase
        print("🔍 [Debug - Analytics Disabled] Event: \(name)")
        if let params = parameters {
            print("   Parameters: \(params)")
        }
         #endif
    }
    
    /// Log screen view event
    /// - Parameters:
    ///   - screenName: Name of the screen
    ///   - screenClass: Optional screen class identifier
    func logScreenView(screenName: String, screenClass: String? = nil) {
        var parameters: [String: Any] = [
            "screen_name": screenName
        ]
        
        if let screenClass = screenClass {
            parameters["screen_class"] = screenClass
        }
        
        logEvent("screen_view", parameters: parameters)
    }
    
    /// Set user property
    /// - Parameters:
    ///   - value: Property value (max 36 characters)
    ///   - name: Property name (max 24 characters)
    func setUserProperty(_ value: String?, forName name: String) {
         #if !DEBUG
        Analytics.setUserProperty(value, forName: name)
        print("📊 Analytics User Property: \(name) = \(value ?? "nil")")
         #else
        print("🔍 [Debug - Analytics Disabled] User Property: \(name) = \(value ?? "nil")")
         #endif
    }
    
    /// Set user ID for analytics
    /// - Parameter userId: User identifier
    func setUserId(_ userId: String?) {
         #if !DEBUG
        Analytics.setUserID(userId)
        print("📊 Analytics User ID: \(userId ?? "nil")")
         #else
        print("🔍 [Debug - Analytics Disabled] User ID: \(userId ?? "nil")")
         #endif
    }
    
    // MARK: - Common Events
    
    /// Log when user views a news article
    func logArticleView(articleId: String, source: String) {
        logEvent("article_view", parameters: [
            "article_id": articleId,
            "source": source
        ])
    }
    
    /// Log when user saves an article
    func logArticleSave(articleId: String, source: String) {
        logEvent("article_save", parameters: [
            "article_id": articleId,
            "source": source
        ])
    }
    
    /// Log when user shares an article
    func logArticleShare(articleId: String, source: String, method: String) {
        logEvent(AnalyticsEvent.AnalyticsEventShare.rawValue, parameters: [
            "article_id": articleId,
            "source": source,
            "method": method
        ])
    }
    
    /// Log when user logs in
    func logLogin(method: String) {
        logEvent(AnalyticsEvent.AnalyticsEventLogin.rawValue, parameters: [
            "method": method
        ])
    }
    
    /// Log when user signs up
    func logSignUp(method: String) {
        logEvent(AnalyticsEvent.AnalyticsEventSignUp.rawValue, parameters: [
            "method": method
        ])
    }
}
