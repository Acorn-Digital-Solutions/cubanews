//
//  SavedStories.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 26/10/2025.
//
import SwiftUI
import Combine

@available(iOS 17, *)
struct SavedStoriesView: View {
    @EnvironmentObject private var cubanewsViewModel: CubanewsViewModel
    @State private var items: [FeedItem] = []
    @State private var isLoading: Bool = false
    
    private func loadSavedItems() {
        let allItems = cubanewsViewModel.getAllItems()
        let newItems = allItems.filter { cubanewsViewModel.savedItemIds.contains($0.id) }
        let newItemIds = newItems.map { $0.id }
        print("➡️ New Items ids: \(newItemIds)")
        items = allItems.filter { cubanewsViewModel.savedItemIds.contains($0.id) }
    }

    @ViewBuilder
    var content: some View {
        if items.isEmpty && isLoading {
            VStack { ProgressView().padding() }
        } else if items.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "bookmark")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("No tienes historias guardadas.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    NewsHeader(header: "Guardados", showDate: false)
                    ForEach(items) { item in
                        FeedItemView(item: item)
                            .padding(.horizontal)
                    }
                    if isLoading {
                        ProgressView().padding()
                    }
                }
                .padding(.top)
            }
        }
    }

    var body: some View {
        NavigationView {
            content
                .background(Color(.systemBackground))
                .task {
                    loadSavedItems()
                }
                .onChange(of: cubanewsViewModel.savedItemIds) { oldValue, newValue in
                    Task {
                        loadSavedItems()
                    }
                }
        }
        .onAppear {
            AnalyticsService.shared.logScreenView(screenName: "Saved Stories", screenClass: "SavedStoriesView")
        }
    }
}

