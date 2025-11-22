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
    
    // Helper function to format today's date in Spanish
    private func formatTodayInSpanish() -> String {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        
        let spanishMonths = [
            "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
            "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
        ]
        
        let monthName = spanishMonths[month - 1]
        return "\(day) de \(monthName)"
    }
    
    // Helper function to check if a feed item is from today
    private func isFromToday(_ item: FeedItem) -> Bool {
        guard let feedts = item.feedts else { return false }
        
        let itemDate = Date(timeIntervalSince1970: TimeInterval(feedts / 1000))
        let calendar = Calendar.current
        
        return calendar.isDateInToday(itemDate)
    }
    
    // Separate items into today and older in a single pass
    private func separateItems() -> (today: [FeedItem], older: [FeedItem]) {
        var todayItems: [FeedItem] = []
        var olderItems: [FeedItem] = []
        
        for item in viewModel.allItems {
            if isFromToday(item) {
                todayItems.append(item)
            } else {
                olderItems.append(item)
            }
        }
        
        return (todayItems, olderItems)
    }

    @available(iOS 17, *)
    private var content: some View {
        let separated = separateItems()
        let todayItems = separated.today
        let olderItems = separated.older
        
        return ScrollView {
            LazyVStack(spacing: 12) {
                // Today's date header
                Text(formatTodayInSpanish())
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Today's news items
                ForEach(todayItems) { item in
                    FeedItemView(item: item)
                        .padding(.horizontal)
                        .onAppear {
                            // Trigger pagination when reaching the last item in this section
                            if item == todayItems.last {
                                Task {
                                    await viewModel.fetchFeedItems()
                                }
                            }
                        }
                }
                
                // Separator header if there are older items
                if !olderItems.isEmpty {
                    Text("Más Noticias:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 16)
                }
                
                // Older news items
                ForEach(olderItems) { item in
                    FeedItemView(item: item)
                        .padding(.horizontal)
                        .onAppear {
                            // Trigger pagination when reaching the last item in this section
                            if item == olderItems.last {
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
