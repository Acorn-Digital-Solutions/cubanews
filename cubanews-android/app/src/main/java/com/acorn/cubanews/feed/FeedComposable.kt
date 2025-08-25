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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.Alignment
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
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
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .clickable {
                val customTabsIntent = CustomTabsIntent.Builder().build()
                customTabsIntent.launchUrl(context, item.url.toUri())
            },
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Image(
                painter = painterResource(id = item.getImageName()),
                contentDescription = "Thumbnail",
                modifier = Modifier
                    .size(64.dp)
                    .clip(RoundedCornerShape(8.dp))
            )
            Spacer(modifier = Modifier.width(16.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = item.title,
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                // Article content/summary (if available)
                val content = try {
                    item.javaClass.getDeclaredField("content").get(item) as? String
                } catch (e: Exception) {
                    try { item.javaClass.getDeclaredField("description").get(item) as? String } catch (e: Exception) { null }
                }
                content?.let {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = it,
                        style = MaterialTheme.typography.bodyMedium,
                        color = Color.DarkGray,
                        maxLines = 3,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                Spacer(modifier = Modifier.height(8.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = item.source.name,
                        style = MaterialTheme.typography.bodySmall,
                        color = Color.Gray
                    )
                    val isoDate = try { item.javaClass.getDeclaredField("isoDate").get(item)?.toString() } catch (e: Exception) { null }
                    isoDate?.let {
                        Text(
                            text = " • $it",
                            style = MaterialTheme.typography.bodySmall,
                            color = Color.Gray
                        )
                    }
                }
            }
        }
    }
    Spacer(modifier = Modifier.height(4.dp))
    HorizontalDivider(color = Color(0x11000000), thickness = 1.dp, modifier = Modifier.padding(horizontal = 24.dp))
}