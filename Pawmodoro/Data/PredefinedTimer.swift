//
//  PredefinedTimer.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import SwiftUI
import Foundation

struct PredefinedTimer: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var color: Color
    var icon: String
    var duration: Int
    
    static func preview() -> [PredefinedTimer] {
        [
            PredefinedTimer(name: "Coffee", color: .brown, icon: "☕️", duration: 5),
            PredefinedTimer(name: "Work", color: .blue, icon: "💼", duration: 25),
            PredefinedTimer(name: "Nap", color: .indigo, icon: "🛏️", duration: 20),
            PredefinedTimer(name: "Sport", color: .orange, icon: "⚽️", duration: 60)
        ]
    }
}
