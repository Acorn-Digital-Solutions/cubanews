package com.acorn.cubanews.feed

import androidx.compose.runtime.Composable
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.*
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

@Composable
fun FeedComposable(feedViewModel: FeedViewModel) {
    val feedItems by remember { feedViewModel.uiState }.collectAsState()
    val listState = rememberLazyListState()

    LaunchedEffect(listState) {
        snapshotFlow { listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index }
            .collect { lastVisibleItemIndex ->
                if (lastVisibleItemIndex != null && lastVisibleItemIndex >= feedItems.size - 3) {
                    feedViewModel.fetchNextFeedBatch()
                }
            }
    }

    LazyColumn(state = listState) {
        // Trigger fetching the first batch when this composable is first composed
        items(feedItems) { item ->
            FeedItemView(item)
        }
    }
}

@Composable
fun FeedItemView(item: FeedItem) {
    Column(modifier = Modifier
        .fillMaxWidth()
        .padding(16.dp)) {
        Text(text = item.title, style = MaterialTheme.typography.titleMedium)
        Text(text = item.source.name, style = MaterialTheme.typography.labelSmall, color = Color.Gray)
        Spacer(modifier = Modifier.height(8.dp))
        item.content?.let { Text(text = it, style = MaterialTheme.typography.bodyMedium) }
    }
}