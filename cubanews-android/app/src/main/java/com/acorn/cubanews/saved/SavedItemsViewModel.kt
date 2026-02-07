package com.acorn.cubanews.saved

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.acorn.cubanews.feed.FeedItem
import com.acorn.cubanews.feed.FeedService
import com.acorn.cubanews.feed.FeedViewModel
import com.acorn.cubanews.feed.ImageLoadingState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class SavedItemsViewModel(
    context: Context,
    private val feedViewModel: FeedViewModel,
    private val feedService: FeedService = FeedService()
) : ViewModel() {
    private val savedItemsManager = SavedItemsManager(context)
    
    private val _savedItems = MutableStateFlow<List<FeedItem>>(emptyList())
    val savedItems: StateFlow<List<FeedItem>> = _savedItems.asStateFlow()
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    init {
        loadSavedItems()
    }

    fun loadSavedItems() {
        viewModelScope.launch {
            _isLoading.value = true
            val savedIds = savedItemsManager.savedItemIds.first()
            // Get all items from feed
            val allItems = feedViewModel.uiState.value
            val savedItemsList = allItems.filter { savedIds.contains(it.id.toString()) }
            _savedItems.value = savedItemsList
            _isLoading.value = false
            
            // Load images for items that don't have them
            savedItemsList.forEach { item ->
                if (item.imageLoadingState == ImageLoadingState.LOADING && item.image != null) {
                    fetchImage(item)
                }
            }
        }
    }

    private fun fetchImage(feedItem: FeedItem) {
        val imageUrl = feedItem.image
        if (imageUrl != null) {
            viewModelScope.launch {
                val imageBytes = feedService.fetchImage(imageUrl)
                if (imageBytes != null) {
                    val newItems = _savedItems.value.map {
                        if (it.id == feedItem.id) {
                            it.copy(imageBytes = imageBytes, imageLoadingState = ImageLoadingState.LOADED)
                        } else {
                            it
                        }
                    }
                    _savedItems.value = newItems
                } else {
                    val newItems = _savedItems.value.map {
                        if (it.id == feedItem.id) {
                            it.copy(imageLoadingState = ImageLoadingState.FAILED)
                        } else {
                            it
                        }
                    }
                    _savedItems.value = newItems
                }
            }
        }
    }
}
