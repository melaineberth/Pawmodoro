//
//  Pet.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 05/12/2025.
//

import Foundation

struct Pet: Identifiable, Hashable {
    var name: String
    var image: String
    var isOwned: Bool // Est-ce que l'utilisateur possède cet animal ?
    let id = UUID()
    
    static func preview() -> [Pet] {
        [
            Pet(name: "Cat", image: "cat_idle", isOwned: true),
            Pet(name: "Dog", image: "cat_idle", isOwned: true), // Pour l'instant on réutilise l'image du chat
            Pet(name: "Bird", image: "cat_idle", isOwned: false), // Celui-là est verrouillé
            Pet(name: "Fox", image: "cat_idle", isOwned: false)
        ]
    }
}
