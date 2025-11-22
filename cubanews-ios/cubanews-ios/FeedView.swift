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
                HighlightedNewsHeader()
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
        }
    }
}

struct HighlightedNewsHeader: View {
    let todayLocalFormatted = Date().formatted(.dateTime.day().month(.wide))
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image("cubanewsIdentity")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text("Titulares")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            Label(todayLocalFormatted, systemImage: "calendar")
                .labelStyle(.titleOnly)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
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
