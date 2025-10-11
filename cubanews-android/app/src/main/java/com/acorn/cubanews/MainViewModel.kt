package com.acorn.cubanews

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class MainViewModel(application: Application) : AndroidViewModel(application) {

    private val _appVersion = MutableStateFlow("")
    val appVersion: StateFlow<String> = _appVersion

    init {
        viewModelScope.launch {
            _appVersion.value = getAppVersion() + " (" + getAppVersionCode().toString() + ")"
        }
    }

    private fun getAppVersion(): String {
        return try {
            val context = getApplication<Application>()
            val packageInfo = context.packageManager.getPackageInfo(context.packageName, 0)
            packageInfo.versionName ?: "Unknown"
        } catch (_: Exception) {
            "Unknown"
        }
    }

    private fun getAppVersionCode(): Long {
        return try {
            val context = getApplication<Application>()
            val packageInfo = context.packageManager.getPackageInfo(context.packageName, 0)
            packageInfo.longVersionCode
        } catch (_: Exception) {
            -1L
        }
    }
}