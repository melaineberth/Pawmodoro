//
//  CircularProgressView.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 09/12/2025.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double // 0.0 à 1.0
    let timeRemaining: String
    let totalMinutes: Int
    let timerName: String
    let icon: String
    var accentColor: Color = .orange
    
    // Pour l'animation fluide du cercle
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Le cercle de progression avec le temps au centre
            ZStack {
                // Cercle de fond (gris clair)
                Circle()
                    .stroke(
                        Color.gray.opacity(0.12),
                        lineWidth: 20
                    )
                    .frame(width: 280, height: 280)
                
                // Cercle de progression (coloré)
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        accentColor.gradient,
                        style: StrokeStyle(
                            lineWidth: 20,
                            lineCap: .round
                        )
                    )
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90)) // Commence en haut
                    .animation(.linear(duration: 1), value: animatedProgress)
                
                // Contenu central
                VStack(spacing: 8) {
                    Text(icon)
                        .font(.system(size: 50))
                    
                    VStack(spacing: 0) {
                        Text(timeRemaining)
                            .font(.system(size: 48, weight: .semibold))
                            .monospacedDigit()
                        
                        Text(timerName)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Indication du temps total
            Text("Focus for \(totalMinutes) minutes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Tu peux ajouter des points pour indiquer les sessions si besoin
            // Comme dans l'image de référence
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { oldValue, newValue in
            animatedProgress = newValue
        }
    }
}

#Preview {
    CircularProgressView(
        progress: 0.4,
        timeRemaining: "18:25",
        totalMinutes: 25,
        timerName: "Coffee",
        icon: "☕️"
    )
}
