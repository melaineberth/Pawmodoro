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
                // Chat animé qui bouge !
                AnimatedPixelPet(baseName: "cat_work_", frameCount: 4, animationSpeed: 0.5)
                   .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text("Focus en cours")
                       .font(.headline)
                       .foregroundStyle(.white)
                    
                    // Le timer magique d'Apple qui se met à jour tout seul
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                       .font(.system(.body, design: .monospaced))
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
                DynamicIslandExpandedRegion(.leading) {
                    VStack(spacing: 4) {
                        AnimatedPixelPet(baseName: "cat_work_", frameCount: 4, animationSpeed: 0.5)
                           .frame(width: 60, height: 60)
                        
                        Text("Focus")
                           .font(.caption)
                           .foregroundStyle(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                           .multilineTextAlignment(.trailing)
                           .foregroundStyle(.yellow)
                           .font(.title2)
                           .monospacedDigit()
                        
                        Text("restant")
                           .font(.caption2)
                           .foregroundStyle(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // Message motivant
                    HStack {
                        Image(systemName: "flame.fill")
                           .foregroundStyle(.orange)
                        Text("Keep going! 🐾")
                           .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 8)
                }
                
            } compactLeading: {
                
                // B. VUE COMPACTE GAUCHE (Petite pilule)
                // Chat animé miniature
                AnimatedPixelPet(baseName: "cat_work_", frameCount: 4, animationSpeed: 0.5)
                   .frame(width: 25, height: 25)
                
            } compactTrailing: {
                
                // C. VUE COMPACTE DROITE
                // Le compte à rebours minimaliste
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                   .monospacedDigit()
                   .font(.caption2)
                   .foregroundStyle(.yellow)
                   .frame(width: 40)
                
            } minimal: {
                
                // D. VUE MINIMALE (Si une autre app utilise aussi l'île)
                AnimatedPixelPet(baseName: "cat_work_", frameCount: 4, animationSpeed: 0.5)
                   .frame(width: 20, height: 20)
            }
        }
    }
}
