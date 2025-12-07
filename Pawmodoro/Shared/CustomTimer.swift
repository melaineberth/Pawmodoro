//
//  CustomTimer.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import Foundation
import SwiftData

@Model
final class CustomTimer {
    var name: String
    var desc: String
    var color: String
    var icon: String
    var duration: Int
    
    init(name: String = "",
         desc: String = "",
         color: String = "",
         icon: String = "",
         duration: Int = 0) {
        self.name = name
        self.desc = desc
        self.color = color
        self.icon = icon
        self.duration = duration
    }
}
