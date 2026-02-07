package com.acorn.cubanews.saved

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "saved_items")

class SavedItemsManager(private val context: Context) {
    companion object {
        private val SAVED_ITEMS_KEY = stringSetPreferencesKey("saved_item_ids")
    }

    val savedItemIds: Flow<Set<String>> = context.dataStore.data
        .map { preferences ->
            preferences[SAVED_ITEMS_KEY] ?: emptySet()
        }

    suspend fun saveItem(itemId: Long) {
        context.dataStore.edit { preferences ->
            val currentItems = preferences[SAVED_ITEMS_KEY] ?: emptySet()
            preferences[SAVED_ITEMS_KEY] = currentItems + itemId.toString()
        }
    }

    suspend fun unsaveItem(itemId: Long) {
        context.dataStore.edit { preferences ->
            val currentItems = preferences[SAVED_ITEMS_KEY] ?: emptySet()
            preferences[SAVED_ITEMS_KEY] = currentItems - itemId.toString()
        }
    }

    suspend fun isSaved(itemId: Long): Boolean {
        var result = false
        context.dataStore.data.map { preferences ->
            val savedItems = preferences[SAVED_ITEMS_KEY] ?: emptySet()
            result = savedItems.contains(itemId.toString())
        }
        return result
    }
}
