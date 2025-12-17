//
//  PawmodoroWidget.swift
//  PawmodoroWidget
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct PawmodoroWidgetLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: FocusAttributes.self) { context in
            
            // 1. VUE ÉCRAN DE VERROUILLAGE (Lock Screen)
            VStack {
                HStack {
                    Image("cat_work_\(context.state.currentFrame)")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    VStack(alignment: .leading) {
                        Text(context.attributes.timerName)
                            .foregroundStyle(.white)
                            .font(.callout)
                            .fontWeight(.semibold)
                        Text(context.attributes.totalDuration)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.white)
                        .font(.custom("", size: 35))
                        .monospacedDigit()
                        .dynamicIsland(verticalPlacement: .belowIfTooWide)
                }
                // Bouton Stop
                Button(intent: StopTimerIntent()) {
                    Text("Stop timer")
                        .fontWeight(.semibold)
                        .padding(.vertical, 5)                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                }
                .buttonStyle(.glassProminent) // Important pour garder le style custom
                .tint(.orange)
                .padding(.top, 10)
            }
            .padding()
            .background(.black)

        } dynamicIsland: { context in
            
            DynamicIsland() {
                
                // A. VUE ÉTENDUE (Appui long)
                DynamicIslandExpandedRegion(.leading) {
                    HStack() {
                        Image("cat_work_\(context.state.currentFrame)")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                        VStack(alignment: .leading) {
                            Text(context.attributes.timerName)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text(context.attributes.totalDuration)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                    }
                    .dynamicIsland(verticalPlacement: .belowIfTooWide)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.white)
                        .font(.custom("", size: 35))
                        .monospacedDigit()
                        .dynamicIsland(verticalPlacement: .belowIfTooWide)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // Bouton Stop
                    Button(intent: StopTimerIntent()) {
                        Text("Stop timer")
                            .fontWeight(.semibold)
                            .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.glassProminent) // Important pour garder le style custom
                    .tint(.orange)
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
                   .foregroundStyle(.white)
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

#Preview("Dynamic Island", as: .content, using: FocusAttributes(petName: "Cat", timerName: "Coffee Time", totalDuration: "30 minutes")) {
    PawmodoroWidgetLiveActivity()
} contentStates: {
    FocusAttributes.ContentState(endTime: Date().addingTimeInterval(1500), currentFrame: 0)
    FocusAttributes.ContentState(endTime: Date().addingTimeInterval(60), currentFrame: 1)
}
