package com.acorn.cubanews.profile

import android.content.Intent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.acorn.cubanews.MainViewModel
import java.time.LocalDate
import androidx.core.net.toUri

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileComposable(viewModel: MainViewModel = viewModel()) {
    val appVersion by viewModel.appVersion.collectAsState()
    Scaffold { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .background(MaterialTheme.colorScheme.background),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Profile content (scrollable if needed)
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp)
            ) {
                // Add other profile-related UI elements here...
            }

            // Footer at the bottom
            AboutComposable(appVersion)
        }
    }
}

@Composable
fun ProfileSection() {
    return Card {
        Text("This is your profile")
    }
}

@Composable
fun AboutComposable(appVersion: String) {
    val context = LocalContext.current
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        HorizontalDivider(
            thickness = 1.dp,
            color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f)
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = "© ${LocalDate.now().year} Acorn Digital Solutions",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "App Version: $appVersion",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "Our mission: https://www.cubanews.icu/about",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.clickable {
                val intent = Intent(Intent.ACTION_VIEW, "https://www.cubanews.icu/about".toUri())
                context.startActivity(intent)
            }
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "Contact us: hello@acorndigitalsolutions.com",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.clickable {
                val intent = Intent(Intent.ACTION_SENDTO).apply {
                    data = "mailto:hello@acorndigitalsolutions.com".toUri()
                }
                context.startActivity(intent)
            }
        )
    }
}


@Composable
@Preview
fun ProfileComposablePreview() {
    ProfileComposable()
}