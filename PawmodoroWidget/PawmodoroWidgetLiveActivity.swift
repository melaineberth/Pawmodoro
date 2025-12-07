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
        
        ActivityConfiguration(for: FocusAttributes.self) { context in
            
            // 1. VUE ÉCRAN DE VERROUILLAGE (Lock Screen)
            HStack {
                // Animation inline du chat - APPROCHE DIRECTE
                TimelineView(.animation) { timeline in
                    let frame = computeFrame(date: timeline.date)
                    
                    Image("cat_work_\(frame)")
                       .resizable()
                       .interpolation(.none)
                       .scaledToFit()
                       .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading) {
                    Text("Focus en cours")
                       .font(.headline)
                       .foregroundStyle(.white)
                    
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                       .font(.system(.body, design: .monospaced))
                       .foregroundStyle(.yellow)
                }
                Spacer()
            }
           .padding()
           .activityBackgroundTint(Color.black.opacity(0.8))
            
        } dynamicIsland: { context in
            
            DynamicIsland {
                
                // A. VUE ÉTENDUE (Appui long)
                DynamicIslandExpandedRegion(.leading) {
                    VStack(spacing: 4) {
                        // Animation inline pour la vue étendue
                        TimelineView(.animation) { timeline in
                            let frame = computeFrame(date: timeline.date)
                            
                            Image("cat_work_\(frame)")
                               .resizable()
                               .interpolation(.none)
                               .scaledToFit()
                               .frame(width: 60, height: 60)
                        }
                        
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
                
                // B. VUE COMPACTE GAUCHE
                TimelineView(.animation) { timeline in
                    let frame = computeFrame(date: timeline.date)
                    
                    Image("cat_work_\(frame)")
                       .resizable()
                       .interpolation(.none)
                       .scaledToFit()
                       .frame(width: 25, height: 25)
                }
                
            } compactTrailing: {
                
                // C. VUE COMPACTE DROITE
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                   .monospacedDigit()
                   .font(.caption2)
                   .foregroundStyle(.yellow)
                   .frame(width: 40)
                
            } minimal: {
                
                // D. VUE MINIMALE
                TimelineView(.animation) { timeline in
                    let frame = computeFrame(date: timeline.date)
                    
                    Image("cat_work_\(frame)")
                       .resizable()
                       .interpolation(.none)
                       .scaledToFit()
                       .frame(width: 20, height: 20)
                }
            }
        }
    }
    
    // Fonction PURE pour calculer la frame - CRITIQUE pour que ça marche !
    // Cette fonction DOIT être déterministe (même date = même résultat)
    private func computeFrame(date: Date) -> Int {
        let animationSpeed = 0.5 // Vitesse : change toutes les 0.5 secondes
        let frameCount = 4 // Nombre total de frames
        
        // Calcul basé sur le timestamp absolu (secondes depuis 1970)
        let totalSeconds = date.timeIntervalSince1970
        let steppedIndex = Int(totalSeconds / animationSpeed)
        
        // Boucle infinie : 0, 1, 2, 3, 0, 1, 2, 3...
        return steppedIndex % frameCount
    }
}
