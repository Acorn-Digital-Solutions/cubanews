//
//  ContentView.swift
//  cubanews-ios
//
//

import SwiftUI

struct ContentView: View {
    var body: some View {
            TabView {
                FeedView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                Text("Profile")
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
        }
}

#Preview {
    ContentView()
}
