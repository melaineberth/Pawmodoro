//
//  Settings.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 14/12/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @State private var isEnhanced: Bool = true
    @State private var themeManager: ThemeManager = .shared
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var progress: [UserProgress]
    
    private var userProgress: UserProgress? {
        progress.first
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Stats"){
                    // Pomodoros complétés
                    StatCard(
                        title: "Pomodoros completed",
                        value: "\(userProgress?.totalPomodorosCompleted ?? 0)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Current series",
                        value: "\(userProgress?.currentStreak ?? 0)",
                        icon: "flame.fill",
                        color: .orange
                    )
                }
                
                Section("General") {
                    NavigationLink("Leave Feedback") {
                        
                    }
                }
                
                Section {
                    Toggle("Alarme", isOn: $isEnhanced)
                        .toggleStyle(.switch)
                        .tint(.orange)
                    
                    Toggle("Push Notifications", isOn: $isEnhanced)
                        .toggleStyle(.switch)
                        .tint(.orange)
                    
                    Picker("Theme Mode", selection: $themeManager.themeMode) {
                        ForEach(ThemeManager.ThemeMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    
                    NavigationLink("FAQ") {
                        
                    }
                }
                
                Section("Legal") {
                    NavigationLink("Data Privacy Terms") {
                        
                    }

                    NavigationLink("Terms and Conditions") {
                        
                    }
                }
            }
            .navigationTitle(Text("Settings"))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .padding(.vertical, 8)
    }
}


#Preview {
    SettingsView()
}
