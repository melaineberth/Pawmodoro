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
                // On affiche directement l'image correspondant à currentFrame
                // L'animation vient des mises à jour de l'app, pas de TimelineView !
                Image("cat_work_\(context.state.currentFrame)")
                   .resizable()
                   .interpolation(.none)
                   .scaledToFit()
                   .frame(width: 50, height: 50)
                
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
                        Image("cat_work_\(context.state.currentFrame)")
                           .resizable()
                           .interpolation(.none)
                           .scaledToFit()
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
                Image("cat_work_\(context.state.currentFrame)")
                   .resizable()
                   .interpolation(.none)
                   .scaledToFit()
                   .frame(width: 25, height: 25)
                
            } compactTrailing: {
                
                // C. VUE COMPACTE DROITE
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                   .monospacedDigit()
                   .font(.caption2)
                   .foregroundStyle(.yellow)
                   .frame(width: 40)
                
            } minimal: {
                
                // D. VUE MINIMALE
                Image("cat_work_\(context.state.currentFrame)")
                   .resizable()
                   .interpolation(.none)
                   .scaledToFit()
                   .frame(width: 20, height: 20)
            }
        }
    }
}
