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
    private let modelContainer: ModelContainer = {
        do {
            let schema = Schema([SavedItem.self, CachedFeedItem.self, UserPreferences.self])
            return try ModelContainer(for: schema)
        } catch {
            fatalError("➡️ Failed to create ModelContainer")
        }
    }()
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}

struct RootView: View {
    private static let TAG = "cubanews_iosApp"
    @StateObject private var cubanewsViewModel = CubanewsViewModel.shared
    @Query private var preferences: [UserPreferences]
    @State private var isLoadingPreferences: Bool = true
    @Environment(\.modelContext) private var modelContext
        
    private var userPreferences: UserPreferences? {
        return preferences.first
    }
    
    private var isAuthenticated: Bool {
        NSLog("➡️ \(Self.TAG) Checking authentication status")
        return userPreferences?.appleUserID != nil
    }
    
    var body: some View {
        Group {
            if isLoadingPreferences {
                AppLaunchView()
            } else if isAuthenticated {
                ContentView()
                    .environmentObject(cubanewsViewModel)
            } else {
                LoginView()
                    .environmentObject(cubanewsViewModel)
            }
        }
        .task {
            await launch()
        }
    }
    
    @MainActor
    private func launch() async {
        let start = Date()
        // Ensure the launch view is visible for at least 2 seconds
        let elapsed = Date().timeIntervalSince(start)
        let remaining = max(0, 1.0 - elapsed)
        if remaining > 0 {
            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
        }

        // If running under UI tests and a special flag is present, create a fake
        // UserPreferences object so the app behaves as if the user is already
        // authenticated. This avoids tapping the real sign-in button in UI tests.
        if ProcessInfo.processInfo.environment["UITEST_FAKE_LOGIN"] == "1" {
            // Only insert if none exist
            if (try? modelContext.fetch(FetchDescriptor<UserPreferences>()))?.first == nil {
                let fake = UserPreferences(id: "default", preferredPublications: [], userEmail: "test@example.com", userFullName: "UI Test", appleUserID: "uitest-user")
                modelContext.insert(fake)
                try? modelContext.save()
                NSLog("➡️ \(Self.TAG) Inserted fake UserPreferences for UI tests")
            }
        }

        isLoadingPreferences = false
    }

}

struct AppLaunchView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Image("cubanewsIdentity")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 250, height: 250)
                    
            }
        }
    }
}
