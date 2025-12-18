//
//  StopTimerIntent.swift
//  Pawmodoro
//
//  App Intent pour arrêter le timer depuis la Dynamic Island
//

import AppIntents
import ActivityKit

struct AlarmActionIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Arrêter le timer"
    static var description: IntentDescription = IntentDescription("Arrête le timer en cours")
    
    // Cette fonction est appelée quand l'utilisateur appuie sur le bouton
    func perform() async throws -> some IntentResult {
        // Récupérer toutes les activités en cours
        let activities = Activity<FocusAttributes>.activities
        
        // Arrêter la première activité trouvée (il ne devrait y en avoir qu'une)
        for activity in activities {
            let finalState = FocusAttributes.ContentState(
                endTime: Date(), // Date immédiate
                currentFrame: 0 // Retour à la première frame
            )
            
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate // Retire immédiatement de la Dynamic Island
            )
            
            print("✅ Timer arrêté depuis la Dynamic Island")
        }
        
        // Notifier l'app principale pour nettoyer les timers
        NotificationCenter.default.post(
            name: NSNotification.Name("StopTimerFromWidget"),
            object: nil
        )
        
        return .result()
    }
}
