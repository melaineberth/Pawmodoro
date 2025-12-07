//
//  Tag.swift
//  ecoo
//
//  Created by Mélaine Berthelot on 05/12/2025.
//

import Foundation

struct Tag: Identifiable, Hashable {
    var name: String
    var color: String
    let id = UUID()
    
    static func preview() -> [Tag] {
        [
            Tag(name: "Food", color: ".red"),
            Tag(name: "Transport", color: ".blue"),
            Tag(name: "Health", color: ".green"),
            Tag(name: "Other", color: ".yellow")
        ]
    }
}
