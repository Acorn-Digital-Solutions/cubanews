//
//  User.swift
//  cubanews-ios
//
//  Created for Sign in with Apple implementation
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
final class User {
    @Attribute(.unique) var id: String
    var email: String?
    var fullName: String?
    var givenName: String?
    var familyName: String?
    var identityToken: String?
    var authorizationCode: String?
    var createdAt: Date
    var lastLoginAt: Date
    
    init(
        id: String,
        email: String? = nil,
        fullName: String? = nil,
        givenName: String? = nil,
        familyName: String? = nil,
        identityToken: String? = nil,
        authorizationCode: String? = nil,
        createdAt: Date = Date(),
        lastLoginAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.givenName = givenName
        self.familyName = familyName
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
    
    func updateLastLogin() {
        self.lastLoginAt = Date()
    }
    
    var displayName: String {
        if let fullName = fullName, !fullName.isEmpty {
            return fullName
        }
        if let givenName = givenName, !givenName.isEmpty {
            return givenName
        }
        if let email = email, !email.isEmpty {
            return email
        }
        return "User"
    }
}
