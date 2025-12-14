//
//  CircularProgressView.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 09/12/2025.
//

import SwiftUI

struct TimerProgressView: View {
    // Pour l'animation fluide du cercle
    @State private var animatedProgress: Double = 0
    @State private var lineWidth: CGFloat = 40
    @State private var pets = Pet.preview()
    @State private var timerManager = TimerManager.shared
    
    // Pour le feedback haptique
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    @State private var lastSnappedMinute: Int = 30
    
    // MARK: Properties
    @State var startAngle: Double = 0
    // Angle par défaut à 180° = 30 minutes (la moitié du cercle)
    @State var toAngle: Double = 180
    
    @State var startProgress: CGFloat = 0
    @State var toProgress: CGFloat = 0.5 // 50% du cercle = 30 minutes
    
    var body: some View {
        VStack(spacing: 50) {
            // Le cercle de progression avec le temps au centre
            TimerSlider()
            
            Text(formatTime(minutes: getTimeDifference()))
                .font(.system(size: 48, weight: .semibold))
                .monospacedDigit()
            
            Button {
                
            } label: {
                Text("Start Sleep")
                    .foregroundStyle(.white)
                    .padding(.vertical)
                    .padding(.horizontal, 40)
                    .background(Color(.orange),in: Capsule())
                    .glassEffect()
            }
        }
    }
    
    // MARK: Timer Circular Slider
    
    @ViewBuilder
    func TimerSlider() -> some View {
       GeometryReader { proxy in
            
           let width = proxy.size.width
           
           ZStack {
               
               // MARK: Animal Slider Design
               ScrollView(.horizontal) {
                   HStack(spacing: 25) {
                       ForEach(pets) { pet in
                           Image(pet.image)
                              .resizable()
                              .interpolation(.none) // Pixel art net!
                              .scaledToFit()
                              .frame(height: 120)
                              .animation(.bouncy, value: timerManager.isFocusing)
                       }
                   }
                   .scrollTargetLayout() // Align content to the view
               }
               .contentMargins(50, for: .scrollContent) // Add padding
               .scrollTargetBehavior(.viewAligned) // Align content behavior
               
               Circle()
                   .stroke(.black.opacity(0.06), lineWidth: lineWidth)
               
               Circle()
                   .trim(from: startProgress, to: toProgress)
                   .stroke(Color(.orange), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                   .rotationEffect(.init(degrees: -90))
                              
               Circle()
                   .fill(Color(.white))
                   .frame(width: 30, height: 30)
               // Rotating image inside the circle
                   .rotationEffect(.init(degrees: 90))
                   .rotationEffect(.init(degrees: -toAngle))
                   .background(.white, in: Circle())
               // Moving to right & rotating
                   .offset(x: width / 2)
               // To the current angle
                   .rotationEffect(.init(degrees: toAngle))
                   .gesture(
                    DragGesture()
                        .onChanged({value in
                            onDrag(value: value)
                        })
                   )
                   .rotationEffect(.init(degrees: -90))
           }
        }
       .frame(width: screenBounds().width / 1.6, height: screenBounds().height / 3.2)
    }
    
    func onDrag(value: DragGesture.Value){
        
        // MARK: Converting Translation into Angle
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        
        // Removing the button radius
        // Button Diameter = 30
        // Radius = 15
        let radians = atan2(vector.dy - 15, vector.dx - 15)
        
        // Converting into angle
        var angle = radians * 180 / .pi
        if angle < 0 {
            angle = 360 + angle
        }
        
        // MARK: Snapping to minutes (roue crantée)
        // Chaque minute = 360° / 60 = 6°
        let degreesPerMinute = 360.0 / 60.0
        
        // Arrondir à la minute la plus proche
        let snappedAngle = round(angle / degreesPerMinute) * degreesPerMinute
        
        // Calculer la minute actuelle pour le feedback haptique
        let currentMinute = Int(round(snappedAngle / degreesPerMinute))
        
        // Déclencher un feedback haptique si on change de minute
        if currentMinute != lastSnappedMinute {
            impactFeedback.impactOccurred()
            lastSnappedMinute = currentMinute
        }
        
        // Progress
        let progress = snappedAngle / 360
        
        // Update to values avec animation pour un effet fluide
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            self.toAngle = snappedAngle
            self.toProgress = progress
        }
    }
    
    // MARK: Returning Time based on Drag (1-60 minutes)
    func getTime(angle: Double) -> Int {
        // Convertir l'angle (0-360°) en minutes (1-60)
        // On divise le cercle en 60 segments
        let minutes = Int((angle / 360.0) * 60)
        // S'assurer qu'on a au minimum 1 minute
        return max(1, minutes)
    }
    
    func getTimeDifference() -> Int {
        // Retourne simplement la différence en minutes entre start et to
        let startMinutes = getTime(angle: startAngle)
        let toMinutes = getTime(angle: toAngle)
        
        var difference = toMinutes - startMinutes
        
        // Gérer le cas où on fait un tour complet
        if difference < 0 {
            difference += 60
        }
        
        // S'assurer qu'on a au minimum 1 minute
        return max(1, difference)
    }
    
    func formatTime(minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes):00"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)min"
            }
        }
    }
}

#Preview {
    TimerProgressView()
}
