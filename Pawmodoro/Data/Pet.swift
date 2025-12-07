//
//  Tag.swift
//  ecoo
//
//  Created by Mélaine Berthelot on 05/12/2025.
//

import Foundation

struct Pet: Identifiable, Hashable {
    var name: String
    var image: String
    let id = UUID()
    
    static func preview() -> [Pet] {
        [
            Pet(name: "Cat", image: "cat_idle"),
            Pet(name: "Cat", image: "cat_idle"),
            Pet(name: "Cat", image: "cat_idle"),
            Pet(name: "Cat", image: "cat_idle")
        ]
    }
}
