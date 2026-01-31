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
    FirebaseApp.configure()
    
    #if !DEBUG
    // Google Analytics is only active in Release builds
    Analytics.setAnalyticsCollectionEnabled(true)
    NSLog("📊 \(Self.TAG) Google Analytics enabled (Release build)")
    
    // Initialize LogRocket
    // TODO: Replace with your actual LogRocket App ID from https://app.logrocket.com
    AnalyticsService.shared.initializeLogRocket(appId: "nrgolf/calypso")
    NSLog("📹 \(Self.TAG) LogRocket enabled (Release build)")
    #else
    print("🔍 \(Self.TAG) Google Analytics disabled (Debug build)")
    print("🔍 \(Self.TAG) LogRocket disabled (Debug build)")
    #endif
    
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
    @State private var cubanewsViewModel: CubanewsViewModel?
    @Query private var preferences: [UserPreferences]
    @State private var isLoadingPreferences: Bool = true
    @Environment(\.modelContext) private var modelContext
        
    private var userPreferences: UserPreferences? {
        return preferences.first
    }
    
    var body: some View {
        Group {
            if isLoadingPreferences {
                AppLaunchView()
            } else if let viewModel = cubanewsViewModel {
                ContentView().environmentObject(viewModel)
            }
        }
        .task {
            await launch()
        }
    }
    
    @MainActor
    private func launch() async {
        NSLog("➡️: CUBANEWS_API \(Config.CUBANEWS_API)")
        
        // Initialize ViewModel with ModelContext
        let viewModel = CubanewsViewModel(modelContext: modelContext)
        self.cubanewsViewModel = viewModel
        
        // Perform async initialization
        await viewModel.initialize()
        
        // Mark preferences as loaded
        isLoadingPreferences = false
        
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
                        NSLog("✅ Local user data deleted")
                    } catch {
                        NSLog("❌ Failed to delete account: \(error)")
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
