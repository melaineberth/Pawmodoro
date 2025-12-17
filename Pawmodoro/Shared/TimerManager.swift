//
//  TimerManager.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 09/12/2025.
//

import SwiftUI
import ActivityKit
import SwiftData

@Observable
class TimerManager {
    // État du timer
    var isFocusing = false
    var selectedMinutes: Int = 25
    var currentActivity: Activity<FocusAttributes>?
    
    // Informations pour le mini player
    var currentTimerName: String = ""
    var currentTimerIcon: String = ""
    var endTime: Date?
    
    // Propriété observable pour forcer la mise à jour de l'UI chaque seconde
    var lastUpdate: Date = Date()
    
    // Animation du chat
    var animationTimer: Timer?
    var currentFrame: Int = 0
    
    // Timer pour mettre à jour l'affichage du temps restant
    private var displayTimer: Timer?
    
    // UserProgressManager pour récompenser l'utilisateur
    var progressManager: UserProgressManager?
    
    // Date de début de la session pour calculer la durée réelle
    private var sessionStartTime: Date?
    
    // Singleton pour partager l'état
    static let shared = TimerManager()
    
    private init() {}
    
    // Configurer le progressManager depuis l'extérieur
    func configure(with progressManager: UserProgressManager) {
        self.progressManager = progressManager
    }
    
    // MARK: - Méthodes pour contrôler le timer
    
    func startActivity(timerName: String, duration: Int, icon: String) {
        selectedMinutes = duration
        currentTimerName = timerName
        currentTimerIcon = icon
        sessionStartTime = Date() // Enregistrer le début de la session
        
        // 1. Définir les données statiques
        // Formater la durée pour l'affichage
        let durationText = formatDurationForDisplay(seconds: duration)
        let attributes = FocusAttributes(
            petName: "cat",
            timerName: timerName,
            totalDuration: durationText
        )
        
        // 2. Calculer la date de fin (duration est maintenant en secondes)
        let futureDate = Date().addingTimeInterval(Double(duration))
        endTime = futureDate
        
        // 3. État initial avec la première frame
        let contentState = FocusAttributes.ContentState(
            endTime: futureDate,
            currentFrame: 0
        )
        
        // 4. Lancer l'activité
        do {
            let content = ActivityContent(state: contentState, staleDate: nil)
            
            let activity = try Activity<FocusAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            currentActivity = activity
            isFocusing = true
            
            // 5. Démarrer le timer d'animation
            startAnimationTimer()
            
            // 6. Démarrer le timer d'affichage
            startDisplayTimer()
            
            print("✅ Activité lancée ID: \(activity.id)")
        } catch {
            print("❌ Erreur lors du lancement : \(error.localizedDescription)")
        }
    }
    
    // Helper pour formater la durée en texte lisible
    private func formatDurationForDisplay(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes == 0 {
            return "\(remainingSeconds) sec"
        } else if remainingSeconds == 0 {
            return "\(minutes) min"
        } else {
            return "\(minutes) min \(remainingSeconds) sec"
        }
    }
    
    func stopActivity() {
        guard let activity = currentActivity else { return }
        
        // Arrêter les timers
        stopAnimationTimer()
        stopDisplayTimer()
        
        // État final
        let finalState = FocusAttributes.ContentState(
            endTime: Date(),
            currentFrame: 0
        )
        
        Task {
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            await activity.end(finalContent, dismissalPolicy: .default)
            
            await MainActor.run {
                self.isFocusing = false
                self.currentActivity = nil
                self.endTime = nil
            }
        }
    }
    
    func togglePlayPause() {
        // TODO: Implémenter pause/resume si nécessaire
        // Pour l'instant, juste stop
        if isFocusing {
            stopActivity()
        }
    }
    
    // MARK: - Animation du chat
    
    private func startAnimationTimer() {
        currentFrame = 0
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if timer.fireDate.timeIntervalSinceNow > 30 {
                self.animationTimer?.invalidate()
                self.animationTimer = Timer.scheduledTimer(
                    withTimeInterval: 5.0,
                    repeats: true
                ) { _ in
                    self.currentFrame = (self.currentFrame + 1) % 4
                    self.updateActivityFrame()
                }
            } else {
                self.currentFrame = (self.currentFrame + 1) % 4
                self.updateActivityFrame()
            }
        }
    }
    
    private func stopAnimationTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    // MARK: - Display Timer
    
    private func startDisplayTimer() {
        // Mettre à jour l'affichage chaque seconde
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // CRUCIAL : Mettre à jour lastUpdate pour déclencher la mise à jour de l'UI
            self.lastUpdate = Date()
            
            // Vérifier si le timer est terminé
            if let remaining = self.remainingTime, remaining <= 0 {
                self.completeSession() // Appeler completeSession au lieu de stopActivity
            }
        }
    }
    
    // Nouvelle méthode pour compléter une session avec succès
    func completeSession() {
        guard let startTime = sessionStartTime else {
            stopActivity()
            return
        }
        
        // Calculer la durée réelle de la session
        let actualDuration = Date().timeIntervalSince(startTime)
        
        // Récompenser l'utilisateur via le progressManager
        if let progressManager = progressManager {
            // TODO: Récupérer l'ID du pet actif si besoin
            progressManager.completePomodoro(duration: actualDuration, petUsed: nil)
            print("✅ Session complétée! Durée: \(Int(actualDuration))s, récompense attribuée")
        }
        
        // Arrêter l'activité
        stopActivity()
    }
    
    private func stopDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }
    
    private func updateActivityFrame() {
        guard let activity = currentActivity else { return }
        
        let updatedState = FocusAttributes.ContentState(
            endTime: activity.content.state.endTime,
            currentFrame: currentFrame
        )
        
        Task {
            await activity.update(
                ActivityContent(
                    state: updatedState,
                    staleDate: nil
                )
            )
        }
    }
    
    // MARK: - Helpers
    
    var remainingTime: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSinceNow
    }
    
    var remainingTimeFormatted: String {
        guard let remaining = remainingTime, remaining > 0 else {
            return "0:00"
        }
        
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Calcule la progression du timer (0.0 = début, 1.0 = fin)
    // C'est notre nouvelle propriété pour le cercle de progression !
    var progress: Double {
        guard let endTime = endTime else { return 0 }
        let totalDuration = Double(selectedMinutes) // selectedMinutes contient maintenant des secondes
        let remaining = endTime.timeIntervalSinceNow // Temps restant
        let elapsed = totalDuration - remaining // Temps écoulé
        
        // On limite entre 0 et 1 pour éviter les valeurs bizarres
        return min(max(elapsed / totalDuration, 0), 1)
    }
}
