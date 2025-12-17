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
    var price: Int // Prix en pièces pour acheter cet animal
    var category: Category // Catégorie de l'animal
    let id = UUID()
    
    // MARK: - Category Enum
    enum Category: String, CaseIterable, Hashable {
        case classic = "Classic"
        case special = "Special"
        case seasonal = "Seasonal"
        case premium = "Premium"
    }
    
    static func preview() -> [Pet] {
        [
            Pet(name: "Cat", image: "cat_idle", isOwned: true, price: 0, category: .classic), // Gratuit, donné automatiquement au démarrage
            Pet(name: "Owl", image: "owl_idle", isOwned: false, price: 100, category: .classic),
            Pet(name: "Penguin", image: "penguin_idle", isOwned: false, price: 150, category: .classic),
            Pet(name: "Lazybones", image: "lazybones_idle", isOwned: false, price: 200, category: .classic),
            Pet(name: "Rabbit", image: "rabbit_idle", isOwned: false, price: 250, category: .classic),
            Pet(name: "Fox", image: "fox_idle", isOwned: false, price: 300, category: .classic),
            Pet(name: "Castor", image: "castor_anim", isOwned: false, price: 300, category: .classic),
            Pet(name: "Raccoon", image: "raccoon_idle", isOwned: false, price: 350, category: .classic),
            Pet(name: "Capybara", image: "capybara_idle", isOwned: false, price: 500, category: .classic)
        ]
    }
}
// MARK: - Array Extension for filtering by category
extension Array where Element == Pet {
    func filterByCategory(_ category: Pet.Category) -> [Pet] {
        return self.filter { $0.category == category }
    }
}

