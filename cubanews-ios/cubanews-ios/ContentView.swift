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
                        Label("Titulares", systemImage: "house.fill")
                    }
                
                SavedStoriesView().tabItem {
                    Label("Guardados", systemImage: "bookmark.fill")
                }

                ProfileView()
                    .tabItem {
                        Label("Perfil", systemImage: "person.fill")
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
