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
    @State private var searchText: String = ""
    @State private var showBottomSheet: Bool = false
    @State private var predefinedTimers = PredefinedTimer.preview()
    @State private var pets = Pet.preview()
    @State private var timerManager = TimerManager.shared
    
    @Environment(\.modelContext) var context
    @Query private var customTimers: [CustomTimer]
    
    

    var body: some View {
        NavigationStack {
            List {
                animalSection
                predefinedSection
                customSection
            }
            .navigationTitle(Text("Pawmodoro"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showBottomSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.orange)
                }
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            CreateTimerView()
        }
    }
    
    // MARK: - Subviews
    
    private var animalSection: some View {
        Section("Your animal") {
            // 3. Illustration du Chat (Prévisualisation)
            // ScrollView and HStack for horizontal scrolling
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
        }
    }
    
    private var predefinedSection: some View {
        Section("Predefined") {
            ForEach(predefinedTimers) { timer in
                timerRow(
                    name: timer.name,
                    duration: timer.duration,
                    icon: timer.icon,
                    color: timer.color
                )
            }
        }
    }
    
    private var customSection: some View {
        Section("Custom") {
            ForEach(customTimers) { customTimer in
                timerRow(
                    name: customTimer.name,
                    duration: customTimer.duration,
                    icon: customTimer.icon,
                    color: Color(hex: customTimer.color)
                )
                .swipeActions {
                    Button(role: .destructive) {
                        withAnimation {
                            context.delete(customTimer)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .symbolVariant(.fill)
                    }
                }
            }
        }
    }
    
    // Helper pour éviter la duplication de code et simplifier le type-checking
    private func timerRow(name: String, duration: Int, icon: String, color: Color) -> some View {
        Button {
            // Lancer le timer via le TimerManager
            if !timerManager.isFocusing {
                timerManager.startActivity(timerName: name, duration: duration, icon: icon)
            }
        } label: {
            HStack(spacing: 12) {
                // Icône dans un cercle coloré
                Text(icon)
                    .font(.title)
                    .foregroundStyle(color)
                    .padding(15)
                    .background(color)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .fontWeight(.semibold)
                    Text("\(duration) min")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                // Indicateur visuel d'action
                Image(systemName: timerManager.isFocusing && timerManager.currentTimerName == name ? "stop.circle.fill" : "play.circle")
                    .foregroundStyle(timerManager.isFocusing && timerManager.currentTimerName == name ? .red : .gray.opacity(0.5))
            }
        }
    }
}

#Preview {
    TimerView()
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
