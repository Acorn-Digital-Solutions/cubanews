package com.acorn.cubanews.feed

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

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
    val id: Long,
    val title: String,
    val url: String,
    val source: NewsSourceName,
    val updated: Int = 0,
    val isoDate: String = "",
    val feedts: Long? = null,
    val content: String? = null,
    val tags: List<String> = emptyList(),
    val score: Int = 0,
    val interactions: InteractionData = InteractionData(feedid = 0),
    val aiSummary: String? = null
)

open class FeedViewModel(private val feedService: FeedService = FeedService()) : ViewModel() {
    private val pageSize = 10
    private val _page = MutableStateFlow(0)
    val page: StateFlow<Int> = _page.asStateFlow()
    private val _uiState = MutableStateFlow<List<FeedItem>>(emptyList());
    val uiState: StateFlow<List<FeedItem>> = _uiState.asStateFlow()

    init {
        this.fetchNextFeedBatch()
    }

    open fun fetchNextFeedBatch() {
        val currentPage = _page.value
        viewModelScope.launch {
            val newItems = feedService.fetchFeedBatch(currentPage, pageSize)
            _uiState.value += newItems
            _page.value = currentPage + 1
        }
    }
}