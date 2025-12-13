//
//  UserPreferences.swift
//  cubanews-ios
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
final class UserPreferences {
    @Attribute(.unique) var id: String
    var preferredPublications: [String]
    var appleUserID: String?
    var userEmail: String?
    var userFullName: String?
    
    init(id: String = "default", preferredPublications: [String] = [], userEmail: String? = nil, userFullName: String? = nil, appleUserID: String? = nil) {
        self.id = id
        self.preferredPublications = preferredPublications
        self.userEmail = userEmail
        self.userFullName = userFullName
        self.appleUserID = appleUserID
    }
}
