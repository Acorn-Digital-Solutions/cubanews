package com.acorn.cubanews.feed

import android.util.Log
import com.google.gson.Gson
import com.google.firebase.storage.FirebaseStorage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.tasks.await
import java.net.HttpURLConnection
import java.net.URL
data class FeedResponseData(
    val content: FeedContent?
)

data class FeedContent(
    val feed: List<FeedItem>?
)
class FeedService {
    val tag = "FEED_SERVICE"
    private val gson = Gson()
    private val baseUrl = "https://www.cubanews.icu/api/feed"
    suspend fun fetchFeedBatch(page: Int, pageSize: Int): List<FeedItem> {
        Log.d(tag, "Load feed batch, page: ${page+1}, pageSize: ${pageSize}")
        return withContext(Dispatchers.IO) {
            try {
                val url = URL("$baseUrl?page=${page+1}&pageSize=2")
                val connection = url.openConnection() as HttpURLConnection
                connection.requestMethod = "GET"
                connection.connectTimeout = 5000
                connection.readTimeout = 5000

                if (connection.responseCode == HttpURLConnection.HTTP_OK) {
                    val json = connection.inputStream.bufferedReader().use { it.readText() }
                    val response = gson.fromJson(json, FeedResponseData::class.java)
                    response.content?.feed ?: emptyList()
                } else {
                    Log.e(tag, "Failed to fetch feed: ${connection.responseCode}")
                    emptyList()
                }
            } catch (e: Exception) {
                Log.e(tag, "Error fetching feed", e)
                emptyList()
            }
        }

//        val newFeedItems = List(pageSize) { index ->
//            val id = page * 10 + index
//            FeedItem(
//                id = id,
//                title = "Sample Title $id",
//                url = "https://example.com/item$id",
//                source = NewsSourceName.ADNCUBA,
//                updated = System.currentTimeMillis().toInt(),
//                isoDate = "2025-07-26T00:00:00Z",
//                feedts = null,
//                content = "Sample content for item $id",
//                tags = listOf("sample", "news"),
//                score = id * 10,
//                interactions = InteractionData(feedid = id),
//                aiSummary = "This is a summary for item $id."
//            )
//        }
//        return newFeedItems
    }

    suspend fun fetchImage(url: String): ByteArray? {
        return withContext(Dispatchers.IO) {
            try {
                val storageRef = FirebaseStorage.getInstance().getReferenceFromUrl(url)
                // Limit to 5MB per image
                val maxDownloadSizeBytes = 5 * 1024 * 1024L
                storageRef.getBytes(maxDownloadSizeBytes).await()
            } catch (e: Exception) {
                Log.e(tag, "Error downloading image from Firebase Storage", e)
                null
            }
        }
    }
}