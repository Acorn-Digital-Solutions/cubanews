//
//  cubanews_iosApp.swift
//  cubanews-ios
//

import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseAnalytics
import SwiftData

#if !DEBUG
import LogRocket
#endif

class AppDelegate: NSObject, UIApplicationDelegate {
    private static let TAG = "cubanews_iosApp"
    
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Configure Firebase synchronously (required), but defer analytics setup
    FirebaseApp.configure()
    
    // Defer non-critical analytics initialization to background
    Task.detached(priority: .utility) {
        #if !DEBUG
        // Google Analytics is only active in Release builds
        Analytics.setAnalyticsCollectionEnabled(true)
        
        // Initialize LogRocket
        AnalyticsService.shared.initializeLogRocket(appId: "nrgolf/calypso")
        #endif
    }
    
    return true
  }
}

@available(iOS 17, *)
@main
struct cubanews_iosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [SavedItem.self, CachedFeedItem.self, UserPreferences.self])
    }
}

struct RootView: View {
    @State private var isReady = false
    @State private var cubanewsViewModel: CubanewsViewModel?
    @Environment(\.modelContext) private var modelContext
    let start = Date()
    
    var body: some View {
        Group {
            if isReady, let viewModel = cubanewsViewModel {
                ContentView()
                    .environmentObject(viewModel)
            } else {
                AppLaunchView()
            }
        }
        .task {
            // All initialization happens here in background
            let viewModel = CubanewsViewModel(modelContext: modelContext)
            
            // Perform lightweight initialization
            await viewModel.initialize()
            
            
            // Ensure the launch view is visible for at least 1 seconds
            let elapsed = Date().timeIntervalSince(self.start)
            let remaining = max(0, 1.0 - elapsed)
            if remaining > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
            }
            // Update state on main thread
            await MainActor.run {
                self.cubanewsViewModel = viewModel
                
                NSLog("➡️: CUBANEWS_API \(Config.CUBANEWS_API)")
                self.isReady = true
            }
            
            // Handle test cleanup in background after app is visible
            if ProcessInfo.processInfo.environment["IS_RUNNING_UNIT_TESTS"] == "1" {
                Task.detached(priority: .background) {
                    await MainActor.run {
                        do {
                            try modelContext.fetch(FetchDescriptor<UserPreferences>())
                                .forEach { modelContext.delete($0) }
                            
                            try modelContext.fetch(FetchDescriptor<SavedItem>())
                                .forEach { modelContext.delete($0) }
                            
                            try modelContext.fetch(FetchDescriptor<CachedFeedItem>())
                                .forEach { modelContext.delete($0) }
                            
                            try modelContext.save()
                        } catch {}
                    }
                }
            }
        }
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
