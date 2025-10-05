package com.acorn.cubanews.feed

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.acorn.cubanews.R
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
    val aiSummary: String? = null,
    val image: String? = null,
    val imageBytes: ByteArray? = null
) {
    fun getImageName(): Int {
        return when (source) {
            NewsSourceName.ADNCUBA -> R.drawable.adncuba
            NewsSourceName.CATORCEYMEDIO -> R.drawable.catorceymedio
            NewsSourceName.DIARIODECUBA ->  R.drawable.ddc
            NewsSourceName.CIBERCUBA -> R.drawable.cibercuba
            NewsSourceName.ELTOQUE -> R.drawable.eltoque
            NewsSourceName.CUBANET -> R.drawable.cubanet
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as FeedItem

        if (id != other.id) return false
        if (updated != other.updated) return false
        if (feedts != other.feedts) return false
        if (score != other.score) return false
        if (title != other.title) return false
        if (url != other.url) return false
        if (source != other.source) return false
        if (isoDate != other.isoDate) return false
        if (content != other.content) return false
        if (tags != other.tags) return false
        if (interactions != other.interactions) return false
        if (aiSummary != other.aiSummary) return false
        if (image != other.image) return false
        if (!imageBytes.contentEquals(other.imageBytes)) return false

        return true
    }

    override fun hashCode(): Int {
        var result = id.hashCode()
        result = 31 * result + updated
        result = 31 * result + (feedts?.hashCode() ?: 0)
        result = 31 * result + score
        result = 31 * result + title.hashCode()
        result = 31 * result + url.hashCode()
        result = 31 * result + source.hashCode()
        result = 31 * result + isoDate.hashCode()
        result = 31 * result + (content?.hashCode() ?: 0)
        result = 31 * result + tags.hashCode()
        result = 31 * result + interactions.hashCode()
        result = 31 * result + (aiSummary?.hashCode() ?: 0)
        result = 31 * result + (image?.hashCode() ?: 0)
        result = 31 * result + (imageBytes?.contentHashCode() ?: 0)
        return result
    }
}

open class FeedViewModel(private val feedService: FeedService = FeedService()) : ViewModel() {
    private val pageSize = 10
    private val _page = MutableStateFlow(0)
    val page: StateFlow<Int> = _page.asStateFlow()
    private val _uiState = MutableStateFlow<List<FeedItem>>(emptyList())
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
            newItems.forEach { fetchImage(it) }
        }
    }

    open fun fetchImage(feedItem: FeedItem) {
        val imageUrl = feedItem.image
        if (imageUrl != null) {
            viewModelScope.launch {
                val imageBytes = feedService.fetchImage(imageUrl)
                if (imageBytes == null) {
                    return@launch
                }
                val newItems = _uiState.value.map {
                    if (it.id == feedItem.id) {
                        it.copy(imageBytes = imageBytes)
                    } else {
                        it
                    }
                }
                _uiState.value = newItems
            }
        }
    }
}