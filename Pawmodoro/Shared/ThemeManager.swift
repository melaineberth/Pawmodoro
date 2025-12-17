//
//  ThemeManager.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 17/12/2025.
//

import SwiftUI

/// Gère le thème de l'application avec persistance dans UserDefaults
@Observable
class ThemeManager {
    static let shared = ThemeManager()
    
    enum ThemeMode: String, CaseIterable, Identifiable {
        case auto = "auto"
        case light = "light"
        case dark = "dark"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .auto: return "Auto"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
    }
    
    private let themeModeKey = "app_theme_mode"
    
    var themeMode: ThemeMode {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: themeModeKey)
        }
    }
    
    /// Retourne le ColorScheme à appliquer selon le mode sélectionné
    var preferredColorScheme: ColorScheme? {
        switch themeMode {
        case .auto:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    private init() {
        // Charger le thème sauvegardé ou utiliser .auto par défaut
        if let savedMode = UserDefaults.standard.string(forKey: themeModeKey),
           let mode = ThemeMode(rawValue: savedMode) {
            self.themeMode = mode
        } else {
            self.themeMode = .auto
        }
    }
}
