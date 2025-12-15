//
//  Settings.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 14/12/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var isEnhanced: Bool = true
    @State private var themeMode: ThemeMode = .auto
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    enum ThemeMode: String, CaseIterable, Identifiable {
        case auto, light, dark
        var id: Self { self }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    NavigationLink("Leave Feedback") {
                        
                    }
                }
                
                Section {
                    Toggle("Push Notifications", isOn: $isEnhanced)
                        .toggleStyle(.switch)
                        .tint(.orange)
                    
                    Picker("Theme Mode", selection: $themeMode) {
                        Text("Auto").tag(ThemeMode.auto)
                        Text("Light").tag(ThemeMode.light)
                        Text("Dark").tag(ThemeMode.dark)
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
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(preferredColorScheme)
    }
    
    private var preferredColorScheme: ColorScheme? {
        switch themeMode {
        case .auto:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

#Preview {
    SettingsView()
}
