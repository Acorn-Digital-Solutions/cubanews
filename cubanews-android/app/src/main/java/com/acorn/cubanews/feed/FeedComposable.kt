package com.acorn.cubanews.feed

import androidx.compose.ui.platform.LocalContext
import androidx.browser.customtabs.CustomTabsIntent
import androidx.compose.runtime.Composable
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.*
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.ui.res.painterResource
import androidx.core.net.toUri

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
    val context = LocalContext.current
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .padding(top = 8.dp)
            .clickable {
                val customTabsIntent = CustomTabsIntent.Builder().build()
                customTabsIntent.launchUrl(context, item.url.toUri())
            }
    ) {
        Image(
            painter = painterResource(id = item.getImageName()), // replace with your asset filename
            contentDescription = "Icon",
            modifier = Modifier
                .size(40.dp)
                .padding(end = 8.dp)
        )
        Column {
            Text(text = item.title, style = MaterialTheme.typography.titleMedium)
            Text(
                text = item.source.name,
                style = MaterialTheme.typography.labelSmall,
                color = Color.Gray
            )
            Spacer(modifier = Modifier.height(8.dp))

        }
    }
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp).padding(bottom = 8.dp)
    ) {
        item.content?.let {
            Text(text = it, style = MaterialTheme.typography.bodyMedium)
        }
    }
}