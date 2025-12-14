//
//  TimerView.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import SwiftUI
import ActivityKit
import SwiftData

struct TimerView: View {
    @State private var pets = Pet.preview()
    @State private var timerManager = TimerManager.shared
    @State private var lineWidth: CGFloat = 40
    @State private var selectedPet: Pet? = nil
    @State private var scrollPosition: Pet.ID?
    
    // Pour le feedback haptique
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    @State private var lastSnappedMinute: Int = 30
    
    // MARK: Properties
    @State var startAngle: Double = 0
    // Angle par défaut à 180° = 30 minutes (la moitié du cercle)
    @State var toAngle: Double = 180
    
    @State var startProgress: CGFloat = 0
    @State var toProgress: CGFloat = 0.5 // 50% du cercle = 30 minutes
    
    @Environment(\.modelContext) var context

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                
                TimerSlider()
                
                Text(timerManager.isFocusing ? timerManager.remainingTimeFormatted : formatTime(minutes: getTimeDifference()))
                    .font(.system(size: 48, weight: .semibold))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                
                Button {
                    startTimer()
                } label: {
                    Text(timerManager.isFocusing ? "Stop Timer" : "Start Timer")
                        .foregroundStyle(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 40)
                        .background(timerManager.isFocusing ? Color(.red) : Color(.orange), in: Capsule())
                        .glassEffect()
                }
                .disabled(selectedPet == nil && !timerManager.isFocusing) // On ne peut pas démarrer sans avoir sélectionné un animal
            }
            .navigationTitle(Text("Pawmodoro"))
        }
        // Force la mise à jour de la vue chaque fois que lastUpdate change
        .onChange(of: timerManager.lastUpdate) { _, _ in
            // Trigger UI update
        }
        // Quand la position du scroll change, on met à jour l'animal sélectionné
        .onChange(of: scrollPosition) { _, newPosition in
            guard let newPosition = newPosition,
                  let newPet = pets.first(where: { $0.id == newPosition }),
                  newPet.isOwned else { return }
            
            // Si c'est un nouvel animal, on le sélectionne avec un feedback
            if selectedPet?.id != newPosition {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedPet = newPet
                }
                let feedback = UIImpactFeedbackGenerator(style: .medium)
                feedback.impactOccurred()
            }
        }
        .onAppear {
            // Sélectionner le premier animal possédé au démarrage
            if let firstOwned = pets.first(where: { $0.isOwned }) {
                selectedPet = firstOwned
                scrollPosition = firstOwned.id
            }
        }
    }
    
    // MARK: Timer Circular Slider
    
    @ViewBuilder
    func TimerSlider() -> some View {
       GeometryReader { proxy in
            
           let width = proxy.size.width
           
           ZStack {
               
               // MARK: Animal Slider Design - Sélection automatique basée sur le scroll !
               ScrollView(.horizontal) {
                   HStack(spacing: 40) {
                       ForEach(pets) { pet in
                           PetSelectionCard(
                               pet: pet,
                               isSelected: selectedPet?.id == pet.id
                           )
                       }
                   }
                   .scrollTargetLayout()
               }
               .scrollPosition(id: $scrollPosition) // Track la position du scroll
               .scrollIndicators(.hidden)
               .contentMargins(65, for: .scrollContent)
               .scrollTargetBehavior(.viewAligned) // Snap sur chaque animal
               .disabled(timerManager.isFocusing) // Bloquer le scroll pendant le timer
               
               // Chevron gauche - n'apparaît que s'il y a un animal avant
               if !timerManager.isFocusing, canScrollLeft {
                   Image(systemName: "chevron.left")
                       .font(.system(size: 15, weight: .bold))
                       .foregroundStyle(.secondary)
                       .offset(x: -80) // Position à gauche de l'animal
               }
               
               // Chevron droit - n'apparaît que s'il y a un animal après
               if !timerManager.isFocusing, canScrollRight {
                   Image(systemName: "chevron.right")
                       .font(.system(size: 15, weight: .bold))
                       .foregroundStyle(.secondary)
                       .offset(x: 80) // Position à droite de l'animal
               }
               
               Circle()
                   .stroke(Color(white: 0.95), lineWidth: lineWidth)
               
               Circle()
                   .trim(from: startProgress, to: timerManager.isFocusing ? CGFloat(timerManager.progress) : toProgress)
                   .stroke(Color(.orange), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                   .rotationEffect(.init(degrees: -90))
                   .animation(.linear(duration: 1.0), value: timerManager.progress)
                          
               if !timerManager.isFocusing {
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
                       .opacity(timerManager.isFocusing ? 0.5 : 1.0) // Visuellement désactivé pendant le timer

               }
            }
        }
       .frame(width: screenBounds().width / 1.6, height: screenBounds().height / 3.2)
    }
    
    // MARK: - Helpers pour les chevrons
    
    // Vérifie s'il y a un animal avant celui sélectionné
    var canScrollLeft: Bool {
        guard let selectedPet = selectedPet,
              let currentIndex = pets.firstIndex(where: { $0.id == selectedPet.id }) else {
            return false
        }
        return currentIndex > 0
    }
    
    // Vérifie s'il y a un animal après celui sélectionné
    var canScrollRight: Bool {
        guard let selectedPet = selectedPet,
              let currentIndex = pets.firstIndex(where: { $0.id == selectedPet.id }) else {
            return false
        }
        return currentIndex < pets.count - 1
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
    
    // MARK: - Timer Control
    
    func startTimer() {
        if timerManager.isFocusing {
            // Si le timer est en cours, l'arrêter
            timerManager.stopActivity()
        } else {
            // Sinon, démarrer un nouveau timer
            let duration = getTimeDifference()
            timerManager.startActivity(
                timerName: "Focus Timer",
                duration: duration,
                icon: "🐱"
            )
        }
    }
}

// MARK: - Pet Selection Card Component
struct PetSelectionCard: View {
    let pet: Pet
    let isSelected: Bool
    // Plus besoin de onTap, tout se fait automatiquement avec le scroll !
    
    var body: some View {
        VStack {
            Image(pet.image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(height: 120)
                .opacity(pet.isOwned ? 1.0 : 0.3)
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
        .overlay(
            Group {
                if !pet.isOwned {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.gray)
                }
            }
        )
    }
}


// MARK: Extensions
extension View{
    
    // MARK: Screen Bounds Extension
    func screenBounds()->CGRect{
        return UIScreen.main.bounds
    }
}

#Preview {
    TimerView()
}
