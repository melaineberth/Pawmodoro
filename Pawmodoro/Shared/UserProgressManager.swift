//
//  UserProgressManager.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 17/12/2025.
//

import Foundation
import SwiftData
import SwiftUI

/// Manager pour faciliter l'accès et la modification des données utilisateur
@Observable
class UserProgressManager {
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Récupérer ou créer la progression utilisateur
    func getUserProgress() -> UserProgress {
        let descriptor = FetchDescriptor<UserProgress>()
        
        do {
            let results = try modelContext.fetch(descriptor)
            if let existing = results.first {
                return existing
            }
        } catch {
            print("Erreur lors de la récupération de UserProgress: \(error)")
        }
        
        // Créer un nouveau profil utilisateur
        let newProgress = UserProgress(
            coins: 0, // Pas de pièces au départ
            totalPomodorosCompleted: 0,
            currentStreak: 0,
            lastSessionDate: nil,
            ownedPets: [],
            activePetID: nil
        )
        
        // Donner le premier animal gratuitement (Chat)
        let starterPet = PetData(
            id: "Cat",
            name: "Cat",
            type: "Classic",
            imageName: "cat_idle",
            price: 0,
            purchaseDate: Date()
        )
        
        newProgress.ownedPets.append(starterPet)
        newProgress.activePetID = "Cat"
        
        modelContext.insert(newProgress)
        modelContext.insert(starterPet)
        try? modelContext.save()
        
        print("✅ Nouveau profil créé avec le chat gratuit!")
        
        return newProgress
    }
    
    /// Ajouter des pièces après une session complétée
    func completePomodoro(duration: TimeInterval, petUsed: String? = nil) {
        let progress = getUserProgress()
        
        // Calculer les pièces gagnées (exemple: 10 pièces par session de 25 min)
        let coinsEarned = Int(duration / 60) * 10
        progress.addCoins(coinsEarned)
        progress.totalPomodorosCompleted += 1
        progress.lastSessionDate = Date()
        
        // Créer une entrée d'historique
        let session = PomodoroSession(
            startTime: Date().addingTimeInterval(-duration),
            endTime: Date(),
            duration: duration,
            completed: true,
            coinsEarned: coinsEarned,
            petUsed: petUsed
        )
        modelContext.insert(session)
        
        try? modelContext.save()
    }
    
    /// Acheter un animal
    func buyPet(name: String, type: String, imageName: String, price: Int) -> Bool {
        let progress = getUserProgress()
        let pet = PetData(
            name: name,
            type: type,
            imageName: imageName,
            price: price,
            purchaseDate: Date()
        )
        
        let success = progress.purchasePet(pet)
        if success {
            modelContext.insert(pet)
            try? modelContext.save()
        }
        return success
    }
    
    /// Obtenir tous les animaux possédés
    func getOwnedPets() -> [PetData] {
        return getUserProgress().ownedPets
    }
    
    /// Définir l'animal actif
    func setActivePet(_ petID: String?) {
        let progress = getUserProgress()
        progress.activePetID = petID
        progress.updatedAt = Date()
        try? modelContext.save()
    }
    
    /// Obtenir l'historique des sessions
    func getPomodoroHistory(limit: Int = 10) -> [PomodoroSession] {
        var descriptor = FetchDescriptor<PomodoroSession>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Erreur lors de la récupération de l'historique: \(error)")
            return []
        }
    }
    
    /// Obtenir les statistiques
    func getStats() -> (coins: Int, totalPomodoros: Int, streak: Int) {
        let progress = getUserProgress()
        return (
            coins: progress.coins,
            totalPomodoros: progress.totalPomodorosCompleted,
            streak: progress.currentStreak
        )
    }
}
