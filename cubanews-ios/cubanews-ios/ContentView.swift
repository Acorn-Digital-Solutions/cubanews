//
//  ContentView.swift
//  cubanews-ios
//
//

import SwiftUI

@available(iOS 17, *)
struct ContentView: View {
    var body: some View {
            TabView {
                FeedView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                SavedStoriesView().tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }

                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
        }
}

#Preview {
    if #available(iOS 17, *) {
        ContentView()
    } else {
        // Fallback on earlier versions
    }
}
