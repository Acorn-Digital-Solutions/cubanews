package com.acorn.cubanews.services

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.firebase.auth.ktx.auth
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import java.util.*

class ServicesViewModel : ViewModel() {
    private val firestore = Firebase.firestore
    private val auth = Firebase.auth
    
    private val _services = MutableStateFlow<List<Service>>(emptyList())
    val services: StateFlow<List<Service>> = _services.asStateFlow()
    
    private val _myServices = MutableStateFlow<List<Service>>(emptyList())
    val myServices: StateFlow<List<Service>> = _myServices.asStateFlow()
    
    private val _filteredServices = MutableStateFlow<List<Service>>(emptyList())
    val filteredServices: StateFlow<List<Service>> = _filteredServices.asStateFlow()
    
    private val _searchText = MutableStateFlow("")
    val searchText: StateFlow<String> = _searchText.asStateFlow()
    
    private val _showMyServices = MutableStateFlow(false)
    val showMyServices: StateFlow<Boolean> = _showMyServices.asStateFlow()
    
    private val _editMode = MutableStateFlow(false)
    val editMode: StateFlow<Boolean> = _editMode.asStateFlow()
    
    private val _selectedService = MutableStateFlow(Service())
    val selectedService: StateFlow<Service> = _selectedService.asStateFlow()

    init {
        loadServices()
        loadMyServices()
    }

    fun updateSearchText(text: String) {
        _searchText.value = text
        performSearch()
    }

    fun toggleShowMyServices() {
        _showMyServices.value = !_showMyServices.value
    }

    fun toggleEditMode() {
        _editMode.value = !_editMode.value
    }

    fun setSelectedService(service: Service) {
        _selectedService.value = service
    }

    fun performSearch() {
        val query = _searchText.value.lowercase()
        _filteredServices.value = if (query.isEmpty()) {
            _services.value
        } else {
            _services.value.filter {
                it.businessName.lowercase().contains(query) ||
                it.description.lowercase().contains(query)
            }
        }
    }

    fun loadServices() {
        viewModelScope.launch {
            try {
                val snapshot = firestore.collection("services")
                    .whereEqualTo("status", ServiceStatus.APPROVED.name)
                    .get()
                    .await()
                
                val servicesList = snapshot.documents.mapNotNull { doc ->
                    try {
                        Service.fromMap(doc.id, doc.data ?: emptyMap())
                    } catch (e: Exception) {
                        Log.e("ServicesViewModel", "Error parsing service: ${e.message}")
                        null
                    }
                }
                
                _services.value = servicesList
                _filteredServices.value = servicesList
            } catch (e: Exception) {
                Log.e("ServicesViewModel", "Error loading services: ${e.message}")
            }
        }
    }

    fun loadMyServices() {
        viewModelScope.launch {
            try {
                val currentUserId = auth.currentUser?.uid ?: return@launch
                
                val snapshot = firestore.collection("services")
                    .whereEqualTo("ownerID", currentUserId)
                    .get()
                    .await()
                
                val myServicesList = snapshot.documents.mapNotNull { doc ->
                    try {
                        Service.fromMap(doc.id, doc.data ?: emptyMap())
                    } catch (e: Exception) {
                        Log.e("ServicesViewModel", "Error parsing my service: ${e.message}")
                        null
                    }
                }
                
                _myServices.value = myServicesList
            } catch (e: Exception) {
                Log.e("ServicesViewModel", "Error loading my services: ${e.message}")
            }
        }
    }

    fun saveService(service: Service) {
        viewModelScope.launch {
            try {
                val currentUserId = auth.currentUser?.uid ?: return@launch
                val now = System.currentTimeMillis() / 1000.0
                
                val serviceToSave = if (service.id.isEmpty()) {
                    // New service
                    service.copy(
                        id = UUID.randomUUID().toString(),
                        ownerID = currentUserId,
                        createdAt = now,
                        lastUpdatedAt = now,
                        status = ServiceStatus.IN_REVIEW
                    )
                } else {
                    // Update existing service
                    service.copy(
                        lastUpdatedAt = now
                    )
                }
                
                firestore.collection("services")
                    .document(serviceToSave.id)
                    .set(serviceToSave.toMap())
                    .await()
                
                loadMyServices()
                loadServices()
            } catch (e: Exception) {
                Log.e("ServicesViewModel", "Error saving service: ${e.message}")
            }
        }
    }

    fun deleteService(serviceId: String) {
        viewModelScope.launch {
            try {
                firestore.collection("services")
                    .document(serviceId)
                    .delete()
                    .await()
                
                loadMyServices()
                loadServices()
            } catch (e: Exception) {
                Log.e("ServicesViewModel", "Error deleting service: ${e.message}")
            }
        }
    }

    fun cancelEdit() {
        _selectedService.value = Service()
        _editMode.value = false
    }
}
