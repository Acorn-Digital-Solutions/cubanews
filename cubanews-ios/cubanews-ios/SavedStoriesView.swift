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

    func fetchSavedItems(reset: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        let saved = store?.loadSaved() ?? []
        self.items = saved
    }
}

struct SavedStoriesView: View {
    @StateObject private var viewModel = SavedStoriesViewModel()

    var content: some View {
        Group {
            if viewModel.items.isEmpty && viewModel.isLoading {
                VStack { ProgressView().padding() }
            } else if viewModel.items.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No saved stories yet")
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
                .navigationTitle("Saved")
                .task {
                    await viewModel.fetchSavedItems(reset: true)
                }
        }
    }
}
