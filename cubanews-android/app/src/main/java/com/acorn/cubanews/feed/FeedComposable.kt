package com.acorn.cubanews.feed

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.browser.customtabs.CustomTabsIntent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.ThumbUp
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asAndroidBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.imageResource
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.tooling.preview.PreviewParameterProvider
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import java.io.ByteArrayOutputStream
import com.acorn.cubanews.R

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
            FeedItemView(item, likeCallback = { feedViewModel.like(item) } )
        }
    }
}

@Composable
fun FeedItemView(item: FeedItem, likeCallback: (item: FeedItem) -> Unit) {
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
        colors = CardDefaults.cardColors(containerColor = if(isSystemInDarkTheme()) Color.DarkGray else MaterialTheme.colorScheme.surface)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(10.dp)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(0.dp, 0.dp, 0.dp, 8.dp)) {
                Image(
                    painter = painterResource(id = item.getImageName()),
                    contentDescription = "Thumbnail",
                    modifier = Modifier
                        .size(16.dp)
                        .clip(RoundedCornerShape(8.dp))
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = item.source.name,
                    style = MaterialTheme.typography.bodySmall,
                    color = if (isSystemInDarkTheme()) Color.White else Color.Gray,
                )
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    text = item.isoDate.split("T").first(),
                    style = MaterialTheme.typography.bodySmall,
                    color = if (isSystemInDarkTheme()) Color.White else Color.Gray,
                )
            }
            Row(
                modifier = Modifier.fillMaxWidth()
            ) {
                if (item.imageBytes != null && item.imageLoadingState == ImageLoadingState.LOADED) {
                    val bitmap = BitmapFactory.decodeByteArray(item.imageBytes, 0, item.imageBytes.size)
                    Image(
                        painter = BitmapPainter(bitmap.asImageBitmap()),
                        contentDescription = "Main Image",
                        modifier = Modifier
                            .fillMaxWidth(0.35f)
                            .clip(RoundedCornerShape(8.dp))
                    )
                } else if (item.image !== null) {
                    Box(
                        modifier = Modifier
                            .size(100.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color.White),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = Color.Black)
                    }
                }
                Spacer(modifier = Modifier.width(16.dp))
                Column(modifier = Modifier.weight(1f)) {

                    Text(
                        text = item.title,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface,
                        maxLines = 4,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
            Row(
                modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {

                IconButton(
                    modifier = Modifier.width(40.dp).height(25.dp),
                    onClick = {likeCallback(item)}
                ) {
                    Row {
                        Icon(
                            imageVector = Icons.Default.ThumbUp,
                            contentDescription = "Interesante",
                            tint = MaterialTheme.colorScheme.primary,
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = "${item.interactions.like}",
                            style = MaterialTheme.typography.bodyLarge,
                            color = if (isSystemInDarkTheme()) Color.White else Color.Gray,
                        )
                    }
                }

                IconButton(
                    modifier = Modifier.width(30.dp).height(25.dp),
                    onClick = {
                        val shareIntent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, item.url)
                        }
                        val chooser = Intent.createChooser(shareIntent, "Compartir noticia")
                        context.startActivity(chooser)}
                ) {
                    Icon(
                        imageVector = Icons.Default.Share,
                        contentDescription = "Compartir noticia",
                        tint = MaterialTheme.colorScheme.primary,
                    )
                }
            }
        }
    }
    Spacer(modifier = Modifier.height(4.dp))
}


class FeedItemPreviewProvider : PreviewParameterProvider<FeedItem> {
    override val values: Sequence<FeedItem> = sequenceOf(
        FeedItem(
            title = "Sample News Title",
            source = NewsSourceName.CATORCEYMEDIO,
            isoDate = "2024-06-01T12:00:00Z",
            url = "https://example.com/news",
            imageBytes = null, // will be populated in preview
            imageLoadingState = ImageLoadingState.LOADED,
            image = null,
            id = 1L,
            updated = 0,
            feedts = 0,
            content = "Sample content for the news item.",
            score = 1,
        )
    )
}

@Preview(showBackground = true, name = "FeedItem Preview with Image")
@Composable
fun FeedItemViewPreview() {
    // Load image from drawable
    val bitmap = ImageBitmap.imageResource(id = R.drawable.sample_image).asAndroidBitmap()
    val stream = ByteArrayOutputStream()
    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream)
    val imageBytes = stream.toByteArray()

    // Get the base FeedItem and attach image bytes
    val item = FeedItemPreviewProvider().values.first().copy(imageBytes = imageBytes)

    FeedItemView(item = item, likeCallback = {})
}