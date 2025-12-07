//
//  Item.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import Foundation
import SwiftData

@Model
final class UserProgress {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
