//
//  cubanews_iosApp.swift
//  cubanews-ios
//

import SwiftUI
import FirebaseCore
import FirebaseStorage
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@available(iOS 17, *)
@main
struct cubanews_iosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var cubanewsViewModel = CubanewsViewModel.shared
    @StateObject private var authManager: AuthenticationManager
    
    // MARK: - IMPORTANT: Apple Sign In Configuration
    // To enable Sign in with Apple, you need to:
    // 1. Add "Sign in with Apple" capability in Xcode project settings
    // 2. Configure your Apple Developer account:
    //    - Team ID: [YOUR_TEAM_ID]
    //    - Bundle Identifier: [YOUR_BUNDLE_ID] (e.g., com.acorndigital.cubanews)
    //    - Enable "Sign in with Apple" in App ID capabilities
    // 3. Create an App ID on Apple Developer portal with Sign in with Apple enabled
    // 4. Add the "Sign in with Apple" entitlement to your app
    // 5. For development, ensure your device/simulator is signed into an Apple ID
    
    init() {
        // Create the model container with User model
        let container = try! ModelContainer(for: SavedItem.self, UserPreferences.self, User.self)
        
        // Initialize AuthenticationManager with the model context
        _authManager = StateObject(wrappedValue: AuthenticationManager(modelContext: container.mainContext))
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(cubanewsViewModel)
                    .environmentObject(authManager)
                    .modelContainer(for: [
                        SavedItem.self,
                        UserPreferences.self,
                        User.self,
                        CachedFeedItem.self
                    ])
                
            } else {
                LoginView(authManager: authManager, isAuthenticated: $authManager.isAuthenticated)
            }
        }
    }
}
