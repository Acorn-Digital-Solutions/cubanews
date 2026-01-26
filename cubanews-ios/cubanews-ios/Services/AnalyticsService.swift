//
//  AnalyticsService.swift
//  cubanews-ios
//
//  Analytics service wrapper with Firebase Analytics and LogRocket support
//  Only logs events in Release builds
//

import Foundation

 #if !DEBUG
import FirebaseAnalytics
import LogRocket
 #endif

enum AnalyticsEvent: String {
    case AnalyticsEventShare="share"
    case AnalyticsEventLogin="login"
    case AnalyticsEventSignUp="sign_up"
    case AnalyticsEventScreenView="screen_view"
    
    
}
/// Service for logging analytics events
/// Only active in Release configuration - all calls are no-ops in Debug
/// Integrates Firebase Analytics and LogRocket
class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    /// Initialize LogRocket with app ID
    /// - Parameter appId: Your LogRocket app ID (format: "app-id/project-name")
    func initializeLogRocket(appId: String) {
         #if !DEBUG
        SDK.initialize(configuration: Configuration(appID: appId))
        print("📹 LogRocket initialized with app ID: \(appId)")
         #else
        print("🔍 [Debug - LogRocket Disabled] Would initialize with app ID: \(appId)")
         #endif
    }
    
    /// Identify the user in LogRocket
    /// - Parameters:
    ///   - userId: Unique user identifier
    ///   - traits: Optional user traits/properties
    func identifyUser(_ userId: String, traits: [String: String]? = nil) {
         #if !DEBUG
        if let traits = traits {
            SDK.identify(userID: userId, userInfo: traits)
        } else {
            SDK.identify(userID: userId)
        }
        print("📹 LogRocket identified user: \(userId)")
         #else
        print("🔍 [Debug - LogRocket Disabled] Identify user: \(userId)")
        if let traits = traits {
            print("   Traits: \(traits)")
        }
         #endif
    }
    
    /// Log a custom event with optional parameters
    /// Sends to both Firebase Analytics and LogRocket
    /// - Parameters:
    ///   - name: Event name (max 40 characters)
    ///   - parameters: Optional event parameters (max 25 parameters, keys max 40 chars, values max 100 chars)
    func logEvent(_ name: String, parameters: [String: String]? = nil) {
         #if !DEBUG
        // Log to Firebase Analytics
        Analytics.logEvent(name, parameters: parameters)
        
        // Log to LogRocket
        SDK.track(CustomEventBuilder.init(name))
        
        print("📊 Analytics Event: \(name)")
        if let params = parameters {
            print("   Parameters: \(params)")
        }
         #else
        // In debug mode, just log to console without sending to Firebase or LogRocket
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
        var parameters: [String: String] = [
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
        
        // Also identify user in LogRocket
        if let id = userId {
            SDK.identify(userID: id)
        }
        
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
