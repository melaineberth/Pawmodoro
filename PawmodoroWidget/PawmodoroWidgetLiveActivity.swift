//
//  PawmodoroWidget.swift
//  PawmodoroWidget
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PawmodoroWidgetLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        
        // On lie la configuration à nos données "FocusAttributes"
        ActivityConfiguration(for: FocusAttributes.self) { context in
            
            // 1. VUE ÉCRAN DE VERROUILLAGE (Lock Screen)
            // C'est la bannière qui apparaît en bas de l'écran verrouillé
            HStack {
                // Image du chat (interpolation.none pour garder le pixel art net)
                Image("\(context.attributes.petName)_work")
                   .resizable()
                   .interpolation(.none) // CRUCIAL pour le pixel art!
                   .scaledToFit()
                   .frame(width: 50, height: 50)
                
                VStack(alignment:.leading) {
                    Text("Focus en cours")
                       .font(.headline)
                       .foregroundStyle(.white)
                    
                    // Le timer magique d'Apple qui se met à jour tout seul
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                       .font(.system(.body, design:.monospaced))
                       .foregroundStyle(.yellow)
                }
                Spacer()
            }
           .padding()
           .activityBackgroundTint(Color.black.opacity(0.8))
            
        } dynamicIsland: { context in
            
            // 2. CONFIGURATION DYNAMIC ISLAND
            DynamicIsland {
                
                // A. VUE ÉTENDUE (Appui long)
                // On a plus de place, on affiche le chat en grand et le temps
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image("\(context.attributes.petName)_work")
                           .resizable()
                           .interpolation(.none)
                           .frame(width: 40, height: 40)
                        Text("Focus")
                           .font(.caption)
                           .foregroundStyle(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                       .multilineTextAlignment(.trailing)
                       .foregroundStyle(.yellow)
                       .font(.title2)
                       .monospacedDigit()
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // Ici on pourrait mettre une barre de progression ou un bouton "Stop"
                    Text("Keep going! 🐾")
                       .font(.caption)
                       .foregroundStyle(.white.opacity(0.8))
                       .padding(.top, 8)
                }
                
            } compactLeading: {
                
                // B. VUE COMPACTE GAUCHE (Petite pilule)
                // Juste la tête du chat
                Image("\(context.attributes.petName)_work")
                   .resizable()
                   .interpolation(.none)
                   .scaledToFit()
                   .frame(width: 24, height: 24)
                
            } compactTrailing: {
                
                // C. VUE COMPACTE DROITE
                // Le compte à rebours minimaliste
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                   .monospacedDigit()
                   .font(.caption2)
                   .foregroundStyle(.yellow)
                   .frame(width: 40) // Fixe la largeur pour éviter que ça "saute"
                
            } minimal: {
                
                // D. VUE MINIMALE (Si une autre app utilise aussi l'île)
                Image(systemName: "timer")
                   .foregroundStyle(.yellow)
            }
        }
    }
}
