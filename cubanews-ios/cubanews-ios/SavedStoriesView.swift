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
    
    private var cubanewsViewModel = CubanewsViewModel.shared

    func loadSavedItems() -> Void {
        let newItems = cubanewsViewModel.allItems.filter { cubanewsViewModel.savedItemIds.contains($0.id) }
        let newItemIds = newItems.map { $0.id }
        print("➡️ New Items ids: \(newItemIds)")
        items = cubanewsViewModel.allItems.filter { cubanewsViewModel.savedItemIds.contains($0.id) }
    }
}

struct SavedStoriesView: View {
    @StateObject private var viewModel = SavedStoriesViewModel()
    @ObservedObject private var cubanewsViewModel = CubanewsViewModel.shared

    @ViewBuilder
    var content: some View {
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

    var body: some View {
        NavigationView {
            content
                .background(Color(.systemBackground))
                .navigationTitle("Guardadas")
                .task {
                    viewModel.loadSavedItems()
                }
                .onChange(of: cubanewsViewModel.savedItemIds) { _ in
                    Task {
                        viewModel.loadSavedItems()
                    }
                }
        }
    }
}
