package com.acorn.cubanews

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.acorn.cubanews.feed.FeedComposable
import com.acorn.cubanews.feed.FeedService
import com.acorn.cubanews.feed.FeedViewModel
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class FeedComposableTest {
    @get:Rule
    val composeTestRule = createComposeRule()

    private lateinit var feedViewModel: FeedViewModel

    @Before
    fun beforeEach() {
        feedViewModel = FeedViewModel(FeedService())
        feedViewModel.fetchNextFeedBatch()
    }

    @Test
    fun feedComposable_displaysFeedItems() {
        composeTestRule.setContent {
            FeedComposable(feedViewModel)
        }
        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithText("Sample Title 10").assertIsDisplayed()
    }
}