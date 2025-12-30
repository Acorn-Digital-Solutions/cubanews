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
    var advertiseServices: Bool = false
    public static let defaultID = "default"
    
    init(id: String = defaultID, preferredPublications: [String] = [], userEmail: String? = nil, userFullName: String? = nil,
         appleUserID: String? = nil, advertiseServices: Bool = false) {
        self.id = id
        self.preferredPublications = preferredPublications
        self.userEmail = userEmail
        self.userFullName = userFullName
        self.appleUserID = appleUserID
        self.advertiseServices = advertiseServices
    }
}
