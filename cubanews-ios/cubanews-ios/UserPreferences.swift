//
//  UserPreferences.swift
//  cubanews-ios
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
final class UserPreferences {
    var preferredPublications: [String]
    
    init(preferredPublications: [String] = []) {
        self.preferredPublications = preferredPublications
    }
}
