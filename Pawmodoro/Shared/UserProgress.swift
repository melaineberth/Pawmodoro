//
//  UserProgress.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import Foundation
import SwiftData

/// Modèle principal pour stocker la progression de l'utilisateur
@Model
final class UserProgress {
    var coins: Int
    var totalPomodorosCompleted: Int
    var currentStreak: Int
    var lastSessionDate: Date?
    var ownedPets: [PetData]
    var activePetID: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        coins: Int = 0,
        totalPomodorosCompleted: Int = 0,
        currentStreak: Int = 0,
        lastSessionDate: Date? = nil,
        ownedPets: [PetData] = [],
        activePetID: String? = nil
    ) {
        self.coins = coins
        self.totalPomodorosCompleted = totalPomodorosCompleted
        self.currentStreak = currentStreak
        self.lastSessionDate = lastSessionDate
        self.ownedPets = ownedPets
        self.activePetID = activePetID
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Ajouter des pièces après une session
    func addCoins(_ amount: Int) {
        coins += amount
        updatedAt = Date()
    }
    
    /// Acheter un animal
    func purchasePet(_ pet: PetData) -> Bool {
        guard coins >= pet.price else { return false }
        coins -= pet.price
        ownedPets.append(pet)
        updatedAt = Date()
        return true
    }
    
    /// Vérifier si l'utilisateur possède un animal
    func ownsPet(withID id: String) -> Bool {
        ownedPets.contains(where: { $0.id == id })
    }
}
/// Modèle pour représenter un animal
@Model
final class PetData {
    var id: String
    var name: String
    var type: String
    var imageName: String
    var price: Int
    var purchaseDate: Date?
    
    init(
        id: String = UUID().uuidString,
        name: String,
        type: String,
        imageName: String,
        price: Int,
        purchaseDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.imageName = imageName
        self.price = price
        self.purchaseDate = purchaseDate
    }
}

/// Modèle pour stocker l'historique des sessions Pomodoro
@Model
final class PomodoroSession {
    var id: String
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var completed: Bool
    var coinsEarned: Int
    var petUsed: String?
    
    init(
        id: String = UUID().uuidString,
        startTime: Date = Date(),
        endTime: Date? = nil,
        duration: TimeInterval = 0,
        completed: Bool = false,
        coinsEarned: Int = 0,
        petUsed: String? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.completed = completed
        self.coinsEarned = coinsEarned
        self.petUsed = petUsed
    }
}

