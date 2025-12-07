//
//  FocusAttributes.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import Foundation
import ActivityKit

struct FocusAttributes: ActivityAttributes {
    
    /// ContentState contient les données dynamiques qui changent pendant l'activité.
    /// Pour un timer, on ne stocke PAS le temps restant (ex: "10 min"),
    /// mais la date de fin précise. Le système calculera le compte à rebours lui-même.
    public struct ContentState: Codable, Hashable {
        var endTime: Date
    }

    /// Les propriétés ici sont statiques (elles ne changent pas une fois le timer lancé).
    /// On stocke le nom du fichier image de l'animal choisi.
    var petName: String
}
