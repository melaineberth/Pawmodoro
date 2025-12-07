//
//  FocusAttributes.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import Foundation
import ActivityKit

struct FocusAttributes: ActivityAttributes {
    
    // ContentState contient les données dynamiques qui changent pendant l'activité.
    // On ajoute currentFrame pour l'animation du chat !
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var currentFrame: Int // 0, 1, 2, 3 pour l'animation du chat
    }

    // Les propriétés ici sont statiques (elles ne changent pas une fois le timer lancé).
    var petName: String
}
