//
//  FeedView.swift
//  cubanews-ios
//
//  Created by Sergio Navarrete on 12/10/2025.
//

import SwiftUI
import SwiftData
import Combine

@available(iOS 17, *)
struct FeedView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var viewModel = CubanewsViewModel.shared
        
    @available(iOS 17, *)
    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                NewsHeader(header: "Titulares", showDate: true)
                ForEach(viewModel.latestNews) { item in
                    FeedItemView(item: item)
                        .padding(.horizontal)
                        .onAppear {
                            if item == viewModel.latestNews.last {
                                Task {
                                    await viewModel.fetchFeedItems()
                                }
                            }
                        }
                }
                if (viewModel.moreNews.count > 0) {
                    MoreNewsHeader()
                }
                ForEach(viewModel.moreNews) { item in
                    FeedItemView(item: item)
                        .padding(.horizontal)
                        .onAppear {
                            if item == viewModel.moreNews.last {
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
                .task {
                    await viewModel.fetchFeedItems()
                }
        }.onAppear {
            NSLog("\(String(describing: type(of: self))) appeared")
            viewModel.loadPreferences()
        }.onChange(of: viewModel.selectedPublications) { oldValue, newValue in
            NSLog("\(String(describing: type(of: self))) selectedPublications changed - oldValue: \(Array(oldValue)), newValue: \(Array(newValue))")
            viewModel.loadPreferences()
        }
    }
}

struct MoreNewsHeader: View {
    var body: some View {
        Label("Más Historias", systemImage: "calendar")
            .labelStyle(.titleOnly)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.gray)
        
    }
}
