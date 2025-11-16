//
//  FeedView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 12/10/2025.
//

import SwiftUI
import Combine

@available(iOS 17, *)
struct FeedView: View {
    @ObservedObject private var viewModel = CubanewsViewModel.shared

    @available(iOS 17, *)
    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.allItems) { item in
                    FeedItemView(item: item)
                        .padding(.horizontal)
                        .onAppear {
                            if item == viewModel.allItems.last {
                                Task {
                                    await viewModel.fetchFeedItems()
                                }
                            }
                        }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.top)
        }
    }

    var body: some View {
        NavigationView {
            content
                .background(Color(.systemBackground))
                .navigationTitle("Cubanews")
                .task {
                    await viewModel.fetchFeedItems()
                }
        }
    }
}
