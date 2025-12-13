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
    @State private var userPreferences: UserPreferences? = nil
    @State private var isLoadingPreferences: Bool = true
    private let modelContainer: ModelContainer
    private static let TAG = "cubanews_iosApp"
    
    init() {
        NSLog("➡️ \(Self.TAG) Creating ModelContainer")
        modelContainer = {
            do {
                let schema = Schema([SavedItem.self, CachedFeedItem.self, UserPreferences.self])
                return try ModelContainer(for: schema)
            } catch {
                fatalError("➡️ \(Self.TAG) Failed to create ModelContainer")
            }
        }()
    }
        
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoadingPreferences {
                    AppLaunchView()
                } else if userPreferences?.userEmail != nil {
                    ContentView()
                        .environmentObject(cubanewsViewModel)
                } else {
                    LoginView(userPreferences: $userPreferences)
                        .environmentObject(cubanewsViewModel)
                }
            }
            .modelContainer(modelContainer)
            .task {
                await loadUserPreferences()
            }
        }
    }
    
    @MainActor
    private func loadUserPreferences() async {
        let start = Date()

        let context = modelContainer.mainContext
        do {
            let prefs = try context.fetch(FetchDescriptor<UserPreferences>()).first
            userPreferences = prefs
            NSLog("➡️ \(Self.TAG) Loaded UserPreferences: \(prefs?.appleUserID ?? "nil") \(prefs?.userEmail ?? "nil")")
        } catch {
            userPreferences = nil
            NSLog("➡️ \(Self.TAG) Failed to load UserPreferences: \(error)")
        }

        // Ensure the launch view is visible for at least 2 seconds
        let elapsed = Date().timeIntervalSince(start)
        let remaining = max(0, 1.0 - elapsed)
        if remaining > 0 {
            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
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
