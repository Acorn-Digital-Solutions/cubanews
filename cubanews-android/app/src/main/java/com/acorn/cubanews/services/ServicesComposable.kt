package com.acorn.cubanews.services

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun ServicesComposable(viewModel: ServicesViewModel) {
    val services by viewModel.filteredServices.collectAsState()
    val myServices by viewModel.myServices.collectAsState()
    val showMyServices by viewModel.showMyServices.collectAsState()
    val searchText by viewModel.searchText.collectAsState()
    val editMode by viewModel.editMode.collectAsState()
    val selectedService by viewModel.selectedService.collectAsState()
    val isAuthenticated = false // TODO: Implement authentication check

    Box(modifier = Modifier.fillMaxSize()) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Servicios",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold
                )
            }

            // Search bar
            OutlinedTextField(
                value = searchText,
                onValueChange = { viewModel.updateSearchText(it) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                placeholder = { Text("Buscar servicios...") },
                leadingIcon = {
                    Icon(Icons.Default.Search, contentDescription = "Search")
                },
                singleLine = true,
                shape = RoundedCornerShape(12.dp)
            )

            Spacer(modifier = Modifier.height(16.dp))

            // My Services toggle (if authenticated and has services)
            if (isAuthenticated && myServices.isNotEmpty()) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Switch(
                        checked = showMyServices,
                        onCheckedChange = { viewModel.toggleShowMyServices() }
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Mis servicios (${myServices.size})")
                }
                Spacer(modifier = Modifier.height(8.dp))
            }

            // Services list
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .weight(1f)
            ) {
                val displayServices = if (showMyServices) myServices else services
                
                if (displayServices.isEmpty()) {
                    item {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(32.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icon(
                                imageVector = Icons.Default.GridOn,
                                contentDescription = "No services",
                                modifier = Modifier.size(64.dp),
                                tint = MaterialTheme.colorScheme.secondary
                            )
                            Spacer(modifier = Modifier.height(16.dp))
                            Text(
                                text = if (showMyServices) "No tienes servicios creados" 
                                       else "No se encontraron servicios",
                                style = MaterialTheme.typography.bodyLarge,
                                color = MaterialTheme.colorScheme.secondary
                            )
                        }
                    }
                } else {
                    items(displayServices) { service ->
                        ServiceCard(
                            service = service,
                            onEdit = if (showMyServices) {
                                {
                                    viewModel.setSelectedService(service)
                                    viewModel.toggleEditMode()
                                }
                            } else null,
                            onClick = {
                                viewModel.setSelectedService(service)
                            }
                        )
                    }
                }
            }
        }

        // Floating action button for creating new service
        if (isAuthenticated && showMyServices) {
            FloatingActionButton(
                onClick = {
                    viewModel.setSelectedService(Service())
                    viewModel.toggleEditMode()
                },
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(16.dp),
                containerColor = MaterialTheme.colorScheme.primary
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add service")
            }
        }
    }

    // Edit/Create service dialog
    if (editMode) {
        ServiceEditDialog(
            service = selectedService,
            onDismiss = { viewModel.cancelEdit() },
            onSave = { updatedService ->
                viewModel.saveService(updatedService)
                viewModel.cancelEdit()
            }
        )
    }
}

@Composable
fun ServiceCard(
    service: Service,
    onEdit: (() -> Unit)? = null,
    onClick: () -> Unit
) {
    val context = LocalContext.current
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .clickable(onClick = onClick),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = service.businessName,
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.weight(1f)
                )
                
                if (service.status != ServiceStatus.APPROVED) {
                    Chip(
                        text = service.status.displayName,
                        color = when (service.status) {
                            ServiceStatus.IN_REVIEW -> Color(0xFFFF9800)
                            ServiceStatus.REJECTED -> Color(0xFFF44336)
                            ServiceStatus.EXPIRED -> Color.Gray
                            else -> Color.Green
                        }
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = service.description,
                style = MaterialTheme.typography.bodyMedium,
                maxLines = 3
            )

            if (service.contactInfo.phoneNumber.isNotEmpty() ||
                service.contactInfo.emailAddress.isNotEmpty()) {
                Spacer(modifier = Modifier.height(12.dp))
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    if (service.contactInfo.phoneNumber.isNotEmpty()) {
                        IconButton(
                            onClick = {
                                val intent = Intent(Intent.ACTION_DIAL).apply {
                                    data = Uri.parse("tel:${service.contactInfo.phoneNumber}")
                                }
                                context.startActivity(intent)
                            },
                            modifier = Modifier
                                .background(
                                    MaterialTheme.colorScheme.primaryContainer,
                                    CircleShape
                                )
                                .size(40.dp)
                        ) {
                            Icon(
                                Icons.Default.Phone,
                                contentDescription = "Call",
                                tint = MaterialTheme.colorScheme.onPrimaryContainer
                            )
                        }
                    }
                    
                    if (service.contactInfo.emailAddress.isNotEmpty()) {
                        IconButton(
                            onClick = {
                                val intent = Intent(Intent.ACTION_SENDTO).apply {
                                    data = Uri.parse("mailto:${service.contactInfo.emailAddress}")
                                }
                                context.startActivity(intent)
                            },
                            modifier = Modifier
                                .background(
                                    MaterialTheme.colorScheme.primaryContainer,
                                    CircleShape
                                )
                                .size(40.dp)
                        ) {
                            Icon(
                                Icons.Default.Email,
                                contentDescription = "Email",
                                tint = MaterialTheme.colorScheme.onPrimaryContainer
                            )
                        }
                    }
                }
            }

            if (onEdit != null) {
                Spacer(modifier = Modifier.height(8.dp))
                TextButton(onClick = onEdit) {
                    Text("Editar")
                }
            }
        }
    }
}

@Composable
fun Chip(text: String, color: Color) {
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = color.copy(alpha = 0.2f)
    ) {
        Text(
            text = text,
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
            style = MaterialTheme.typography.labelSmall,
            color = color
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ServiceEditDialog(
    service: Service,
    onDismiss: () -> Unit,
    onSave: (Service) -> Unit
) {
    var businessName by remember { mutableStateOf(service.businessName) }
    var description by remember { mutableStateOf(service.description) }
    var phoneNumber by remember { mutableStateOf(service.contactInfo.phoneNumber) }
    var emailAddress by remember { mutableStateOf(service.contactInfo.emailAddress) }
    var websiteURL by remember { mutableStateOf(service.contactInfo.websiteURL) }
    var location by remember { mutableStateOf(service.contactInfo.location) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text(if (service.id.isEmpty()) "Crear Servicio" else "Editar Servicio")
        },
        text = {
            LazyColumn(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                item {
                    OutlinedTextField(
                        value = businessName,
                        onValueChange = { businessName = it },
                        label = { Text("Nombre del negocio") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
                
                item {
                    OutlinedTextField(
                        value = description,
                        onValueChange = { description = it },
                        label = { Text("Descripción") },
                        modifier = Modifier.fillMaxWidth(),
                        minLines = 3
                    )
                }
                
                item {
                    Text(
                        "Información de contacto",
                        style = MaterialTheme.typography.titleSmall,
                        modifier = Modifier.padding(top = 8.dp)
                    )
                }
                
                item {
                    OutlinedTextField(
                        value = phoneNumber,
                        onValueChange = { phoneNumber = it },
                        label = { Text("Teléfono") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
                
                item {
                    OutlinedTextField(
                        value = emailAddress,
                        onValueChange = { emailAddress = it },
                        label = { Text("Email") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
                
                item {
                    OutlinedTextField(
                        value = websiteURL,
                        onValueChange = { websiteURL = it },
                        label = { Text("Sitio web") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
                
                item {
                    OutlinedTextField(
                        value = location,
                        onValueChange = { location = it },
                        label = { Text("Ubicación") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    val updatedService = service.copy(
                        businessName = businessName,
                        description = description,
                        contactInfo = ContactInfo(
                            phoneNumber = phoneNumber,
                            emailAddress = emailAddress,
                            websiteURL = websiteURL,
                            location = location
                        )
                    )
                    onSave(updatedService)
                }
            ) {
                Text("Guardar")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancelar")
            }
        }
    )
}
