package com.acorn.cubanews.services

import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase

enum class ServiceStatus(val displayName: String) {
    IN_REVIEW("En Revisión"),
    APPROVED("Aprobado"),
    REJECTED("Rechazado"),
    EXPIRED("Expirado")
}

data class ContactInfo(
    val emailAddress: String = "",
    val phoneNumber: String = "",
    val websiteURL: String = "",
    val facebook: String = "",
    val instagram: String = "",
    val location: String = ""
)

data class Service(
    val id: String = "",
    val description: String = "",
    val businessName: String = "",
    val contactInfo: ContactInfo = ContactInfo(),
    val ownerID: String = Firebase.auth.currentUser?.uid ?: "",
    val status: ServiceStatus = ServiceStatus.IN_REVIEW,
    val expirationDate: Double = 0.0,
    val createdAt: Double = 0.0,
    val lastUpdatedAt: Double = 0.0
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
            "id" to id,
            "description" to description,
            "businessName" to businessName,
            "contactInfo" to mapOf(
                "emailAddress" to contactInfo.emailAddress,
                "phoneNumber" to contactInfo.phoneNumber,
                "websiteURL" to contactInfo.websiteURL,
                "facebook" to contactInfo.facebook,
                "instagram" to contactInfo.instagram,
                "location" to contactInfo.location
            ),
            "ownerID" to ownerID,
            "status" to status.name,
            "expirationDate" to expirationDate,
            "createdAt" to createdAt,
            "lastUpdatedAt" to lastUpdatedAt
        )
    }

    companion object {
        fun fromMap(id: String, data: Map<String, Any>): Service {
            val contactInfoMap = data["contactInfo"] as? Map<String, Any> ?: emptyMap()
            val statusString = data["status"] as? String ?: "IN_REVIEW"
            
            return Service(
                id = id,
                description = data["description"] as? String ?: "",
                businessName = data["businessName"] as? String ?: "",
                contactInfo = ContactInfo(
                    emailAddress = contactInfoMap["emailAddress"] as? String ?: "",
                    phoneNumber = contactInfoMap["phoneNumber"] as? String ?: "",
                    websiteURL = contactInfoMap["websiteURL"] as? String ?: "",
                    facebook = contactInfoMap["facebook"] as? String ?: "",
                    instagram = contactInfoMap["instagram"] as? String ?: "",
                    location = contactInfoMap["location"] as? String ?: ""
                ),
                ownerID = data["ownerID"] as? String ?: "",
                status = try {
                    ServiceStatus.valueOf(statusString)
                } catch (e: Exception) {
                    ServiceStatus.IN_REVIEW
                },
                expirationDate = (data["expirationDate"] as? Number)?.toDouble() ?: 0.0,
                createdAt = (data["createdAt"] as? Number)?.toDouble() ?: 0.0,
                lastUpdatedAt = (data["lastUpdatedAt"] as? Number)?.toDouble() ?: 0.0
            )
        }
    }
}
