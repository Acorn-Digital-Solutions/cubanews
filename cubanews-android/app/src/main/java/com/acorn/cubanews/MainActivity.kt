package com.acorn.cubanews

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.acorn.cubanews.feed.FeedComposable
import com.acorn.cubanews.feed.FeedViewModel
import com.acorn.cubanews.ui.theme.CubanewsTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            CubanewsTheme {
                Material3BottomNavApp()
            }
        }
    }
}

sealed class Screen(val route: String, val icon: ImageVector, val label: String) {
    object Home : Screen("home", Icons.Filled.Home, "Home")
    object Search : Screen("search", Icons.Filled.Search, "Search")
    object Profile : Screen("profile", Icons.Filled.Person, "Profile")
}

val bottomNavItems = listOf(
    Screen.Home,
    Screen.Search,
    Screen.Profile
)

@Preview
@Composable
fun Material3BottomNavAppPreview() {
    Material3BottomNavApp()
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Material3BottomNavApp() {
    val navController = rememberNavController()
    val currentDestination = navController
        .currentBackStackEntryAsState().value?.destination

    Scaffold(
        topBar = {
            TopAppBar(title = {
                Text(currentDestination?.route?.uppercase() ?: "Cubanews")
            })
        },
        bottomBar = {
            NavigationBar {
                bottomNavItems.forEach { screen ->
                    val selected = currentDestination?.route == screen.route
                    NavigationBarItem(
                        selected = selected,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = { Icon(screen.icon, contentDescription = screen.label) },
                        label = { Text(screen.label) }
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Home.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Home.route) { HomeScreen() }
            composable(Screen.Search.route) { SearchScreen() }
            composable(Screen.Profile.route) { ProfileScreen() }
        }
    }
}

@Composable
fun HomeScreen() {
    Surface(modifier = Modifier.fillMaxSize()) {
        FeedComposable(viewModel(FeedViewModel::class))
    }
}

@Composable
fun SearchScreen() {
    Surface(modifier = Modifier.fillMaxSize()) {
        CenteredText("Search something...")
    }
}

@Composable
fun ProfileScreen() {
    Surface(modifier = Modifier.fillMaxSize()) {
        CenteredText("This is your profile")
    }
}

@Composable
fun CenteredText(text: String) {
    androidx.compose.foundation.layout.Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        contentAlignment = androidx.compose.ui.Alignment.Center
    ) {
        Text(text, style = MaterialTheme.typography.headlineSmall)
    }
}
