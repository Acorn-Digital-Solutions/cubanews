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
    @EnvironmentObject private var viewModel: CubanewsViewModel
        
    @available(iOS 17, *)
    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                NewsHeader(header: "Titulares", showDate: true)
                ForEach(viewModel.latestNews) { item in
                    FeedItemView(item: item)
                        .padding(.horizontal)
                        .onAppear {
                            // Load image when item appears
                            viewModel.fetchImage(feedItem: item)
                            // Trigger pagination
                            if item == viewModel.latestNews.last {
                                viewModel.startFetch()
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
                                viewModel.startFetch()
                            }
                        }
                }
            }
            .padding(.top)
        }
        .refreshable {
            viewModel.startFetch(reset: true)
        }
    }

    var body: some View {
        NavigationView {
            content
                .background(Color(.systemBackground))
        }.onAppear {
            AnalyticsService.shared.logScreenView(screenName: "Feed", screenClass: "FeedView")
            // Trigger initial fetch when view appears
            viewModel.startFetch()
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
