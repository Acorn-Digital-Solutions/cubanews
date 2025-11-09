//
//  SavedStories.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 26/10/2025.
//
import SwiftUI
import Combine

@MainActor
class SavedStoriesViewModel: ObservableObject {
    @Published var items: [FeedItem] = []
    @Published var isLoading: Bool = false

    private var store = FeedCacheStore()

    func fetchSavedItems(savedIds: Set<Int64>) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        let saved = store?.loadSaved() ?? []
        // Filter to only include items that are in the savedIds set
        self.items = saved.filter { savedIds.contains($0.id) }
    }
}

struct SavedStoriesView: View {
    @StateObject private var viewModel = SavedStoriesViewModel()
    @EnvironmentObject var savedItemsManager: SavedItemsManager

    var content: some View {
        Group {
            if viewModel.items.isEmpty && viewModel.isLoading {
                VStack { ProgressView().padding() }
            } else if viewModel.items.isEmpty {
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
                        ForEach(viewModel.items) { item in
                            FeedItemView(item: item)
                                .padding(.horizontal)
                        }
                        if viewModel.isLoading {
                            ProgressView().padding()
                        }
                    }
                    .padding(.top)
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            content
                .background(Color(.systemBackground))
                .navigationTitle("Guardadas")
                .task {
                    await viewModel.fetchSavedItems(savedIds: savedItemsManager.savedItemIds)
                }
                .onChange(of: savedItemsManager.savedItemIds) { _ in
                    Task {
                        await viewModel.fetchSavedItems(savedIds: savedItemsManager.savedItemIds)
                    }
                }
        }
    }
}
