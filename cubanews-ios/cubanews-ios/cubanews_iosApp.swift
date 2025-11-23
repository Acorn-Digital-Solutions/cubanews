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
    @State private var isAuthenticated = false
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ContentView()
                    .environmentObject(cubanewsViewModel).modelContainer(for: [
                        SavedItem.self,
                        UserPreferences.self,
                        CachedFeedItem.self
                    ])
                
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
