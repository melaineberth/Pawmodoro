//
//  TimerView.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import SwiftUI
import ActivityKit
import SwiftData

// MARK: - Timer Type Enum
enum TimerType: String, CaseIterable, Identifiable {
    case pomodoro = "Pomodoro"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    
    var id: String { self.rawValue }
    
    var duration: Int {
        switch self {
        case .pomodoro: return 1500 // 25:00 (25 minutes = 1500 secondes)
        case .shortBreak: return 300 // 5:00 (5 minutes = 300 secondes)
        case .longBreak: return 900 // 15:00 (15 minutes = 900 secondes)
        }
    }
    
    var angle: Double {
        // Convertir la durée en angle (0-360°)
        // 3600 secondes = 360°
        // On s'assure que l'angle est un multiple de 0.5° (intervalle de 5 secondes)
        let rawAngle = (Double(duration) / 3600.0) * 360.0
        let degreesPerFiveSeconds = 360.0 / 720.0 // 0.5°
        return round(rawAngle / degreesPerFiveSeconds) * degreesPerFiveSeconds
    }
}

struct TimerView: View {
    @State private var pets = Pet.preview()
    @State private var timerManager = TimerManager.shared
    @State private var lineWidth: CGFloat = 40
    @State private var selectedPet: Pet? = nil
    @State private var scrollPosition: Pet.ID?
    @State private var isEnhanced: Bool = true
    @State private var showSettingsSheet = false
    @State private var selectedTimerType: TimerType = .pomodoro
    
    // Pour le feedback haptique
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    @State private var lastSnappedSecond: Int = 1800 // 30 minutes = 1800 secondes
    
    // MARK: Properties
    @State var startAngle: Double = 0
    // Angle par défaut correspondant au Pomodoro (initialisé dynamiquement)
    @State var toAngle: Double = TimerType.pomodoro.angle
    
    @State var startProgress: CGFloat = 0
    @State var toProgress: CGFloat = CGFloat(TimerType.pomodoro.duration) / 3600.0
    
    @Environment(\.modelContext) var context

    var body: some View {
        NavigationStack {
            List {
                Section("Modify timer duration"){
                    VStack(alignment: .center, spacing: 40) {
                        
                        // Picker pour sélectionner le type de timer (Pomodoro, Short Break, Long Break)
                        Picker("Timer Type", selection: $selectedTimerType) {
                            ForEach(TimerType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(timerManager.isFocusing) // Bloquer pendant le timer
                        
                        TimerSlider()
                        
                        Text(timerManager.isFocusing ? timerManager.remainingTimeFormatted : formatTime(seconds: getTimeDifference()))
                            .font(.system(size: 48, weight: .semibold))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                        
                        Button {
                            startTimer()
                        } label: {
                            Text(timerManager.isFocusing ? "Stop Timer" : "Start Timer")
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.vertical)
                                .padding(.horizontal, 40)
                                .background(timerManager.isFocusing ? Color(.red) : Color(.orange), in: Capsule())
                        }
                        .glassEffect()
                        .buttonStyle(.plain)
                        .disabled(selectedPet == nil && !timerManager.isFocusing) // On ne peut pas démarrer sans avoir sélectionné un animal
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                }
                
                Section("Timer options") {
                    Toggle("Alarme", isOn: $isEnhanced)
                        .toggleStyle(.switch)
                        .tint(.orange)
                }
            }
            .navigationTitle(Text("Pawmodoro"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettingsSheet = true
                    } label: {
                        Image(systemName: "gear")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.orange)
                }
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView()
            }
        }
        // Force la mise à jour de la vue chaque fois que lastUpdate change
        .onChange(of: timerManager.lastUpdate) { _, _ in
            // Trigger UI update
        }
        // Mettre à jour l'angle du slider quand le type de timer change
        .onChange(of: selectedTimerType) { _, newType in
            guard !timerManager.isFocusing else { return } // Ne pas modifier pendant un timer actif
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                toAngle = newType.angle
                toProgress = CGFloat(newType.duration) / 3600.0
            }
            
            // Feedback haptique
            let feedback = UIImpactFeedbackGenerator(style: .medium)
            feedback.impactOccurred()
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
           
           ZStack(alignment: .center) {
               
               // MARK: Animal Slider Design - Sélection automatique basée sur le scroll !
               ScrollView(.horizontal) {
                   HStack(spacing: 0) {
                       ForEach(pets.filter { $0.isOwned }) { pet in
                           PetSelectionCard(
                               pet: pet,
                               isSelected: selectedPet?.id == pet.id
                           )
                           .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0, alignment: .center)
                       }
                   }
                   .scrollTargetLayout()
               }
               .scrollPosition(id: $scrollPosition) // Track la position du scroll
               .scrollIndicators(.hidden)
               .scrollTargetBehavior(.paging) // Snap sur chaque animal
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
       .padding()
       .frame(width: 300, height: 300)
    }
    
    // MARK: - Helpers pour les chevrons
    
    // Vérifie s'il y a un animal avant celui sélectionné
    var canScrollLeft: Bool {
        guard let selectedPet = selectedPet else {
            return false
        }
        let ownedPets = pets.filter { $0.isOwned }
        guard let currentIndex = ownedPets.firstIndex(where: { $0.id == selectedPet.id }) else {
            return false
        }
        return currentIndex > 0
    }
    
    // Vérifie s'il y a un animal après celui sélectionné
    var canScrollRight: Bool {
        guard let selectedPet = selectedPet else {
            return false
        }
        let ownedPets = pets.filter { $0.isOwned }
        guard let currentIndex = ownedPets.firstIndex(where: { $0.id == selectedPet.id }) else {
            return false
        }
        return currentIndex < ownedPets.count - 1
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
        
        // MARK: Snapping to 5-second intervals (roue crantée)
        // 60 minutes = 3600 secondes
        // On veut des intervalles de 5 secondes
        // Chaque intervalle de 5 sec = 360° / (3600/5) = 360° / 720 = 0.5°
        let degreesPerFiveSeconds = 360.0 / 720.0
        
        // Arrondir à l'intervalle de 5 secondes le plus proche
        let snappedAngle = round(angle / degreesPerFiveSeconds) * degreesPerFiveSeconds
        
        // Calculer les secondes actuelles pour le feedback haptique
        let currentSeconds = Int(round(snappedAngle / degreesPerFiveSeconds)) * 5
        
        // Déclencher un feedback haptique si on change d'intervalle
        if currentSeconds != lastSnappedSecond {
            impactFeedback.impactOccurred()
            lastSnappedSecond = currentSeconds
        }
        
        // Progress
        let progress = snappedAngle / 360
        
        // Update to values avec animation pour un effet fluide
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            self.toAngle = snappedAngle
            self.toProgress = progress
        }
    }
    
    // MARK: Returning Time based on Drag (in seconds, with 5-second intervals)
    func getTime(angle: Double) -> Int {
        // Convertir l'angle (0-360°) en secondes (0-3600)
        // Le cercle complet représente 60 minutes = 3600 secondes
        let totalSeconds = (angle / 360.0) * 3600.0
        
        // Arrondir aux intervalles de 5 secondes
        let snappedSeconds = round(totalSeconds / 5.0) * 5.0
        
        // S'assurer qu'on a au minimum 5 secondes
        return max(5, Int(snappedSeconds))
    }
    
    func getTimeDifference() -> Int {
        // Retourne la différence en secondes entre start et to
        let startSeconds = getTime(angle: startAngle)
        let toSeconds = getTime(angle: toAngle)
        
        var difference = toSeconds - startSeconds
        
        // Gérer le cas où on fait un tour complet
        if difference < 0 {
            difference += 3600
        }
        
        // S'assurer qu'on a au minimum 5 secondes
        return max(5, difference)
    }
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes == 0 {
            // Moins d'une minute : afficher juste les secondes
            return "\(remainingSeconds)s"
        } else if remainingSeconds == 0 {
            // Nombre de minutes exact : afficher juste les minutes
            return "\(minutes):00"
        } else {
            // Minutes et secondes : format MM:SS
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
    
    // MARK: - Timer Control
    
    func startTimer() {
        if timerManager.isFocusing {
            // Si le timer est en cours, l'arrêter
            timerManager.stopActivity()
        } else {
            // Sinon, démarrer un nouveau timer
            let durationInSeconds = getTimeDifference()
            timerManager.startActivity(
                timerName: "Focus Timer",
                duration: durationInSeconds,
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


#Preview {
    TimerView()
}
