package com.acorn.cubanews.feed

import androidx.compose.runtime.remember
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

enum class NewsSourceName(val value: String) {
    ADNCUBA("adncuba"),
    CATORCEYMEDIO("catorceymedio"),
    DIARIODECUBA("diariodecuba"),
    CIBERCUBA("cibercuba"),
    ELTOQUE("eltoque"),
    CUBANET("cubanet");

    override fun toString(): String = value
}

data class InteractionData(
    val feedid: Int,
    val view: Int = 0,
    val like: Int = 0,
    val share: Int = 0
)

data class FeedItem(
    val id: Int,
    val title: String,
    val url: String,
    val source: NewsSourceName,
    val updated: Int,
    val isoDate: String,
    val feedts: Int? = null,
    val content: String? = null,
    val tags: List<String> = emptyList(),
    val score: Int,
    val interactions: InteractionData,
    val aiSummary: String
)

class FeedViewModel : ViewModel() {
    val pageSize = 10
    private val _page = MutableStateFlow(0)
    val page: StateFlow<Int> = _page.asStateFlow()
    private val _uiState = MutableStateFlow<List<FeedItem>>(emptyList());
    val uiState: StateFlow<List<FeedItem>> = _uiState.asStateFlow()

    init {
        fetchNextFeedBatch()
    }

    fun fetchNextFeedBatch() {
        val currentPage = _page.value
        val newFeedItems = List(10) { index ->
            val id = currentPage * 10 + index
            FeedItem(
                id = id,
                title = "Sample Title $id",
                url = "https://example.com/item$id",
                source = NewsSourceName.ADNCUBA,
                updated = System.currentTimeMillis().toInt(),
                isoDate = "2025-07-26T00:00:00Z",
                feedts = null,
                content = "Sample content for item $id",
                tags = listOf("sample", "news"),
                score = id * 10,
                interactions = InteractionData(feedid = id),
                aiSummary = "This is a summary for item $id."
            )
        }
        _uiState.value += newFeedItems
        _page.value = currentPage + 1
    }
}