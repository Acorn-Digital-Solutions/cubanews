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
    
    init(id: String = "default", preferredPublications: [String] = []) {
        self.id = id
        self.preferredPublications = preferredPublications
    }
}
