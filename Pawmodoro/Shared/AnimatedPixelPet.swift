//
//  AnimatedPixelPet.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import SwiftUI

struct AnimatedPixelPet: View {
    // Configuration de l'animation
    let baseName: String // ex: "cat_work_"
    let frameCount: Int // Nombre total d'images (4 dans notre cas)
    let animationSpeed: Double // Vitesse en secondes (0.5 = change toutes les 0.5s)
    
    // Initializer avec valeurs par défaut
    init(baseName: String = "cat_work_",
         frameCount: Int = 4,
         animationSpeed: Double = 0.5) {
        self.baseName = baseName
        self.frameCount = frameCount
        self.animationSpeed = animationSpeed
    }
    
    var body: some View {
        // TimelineView demande à SwiftUI de rafraîchir la vue en continu
        // C'est la magie qui permet l'animation dans un Widget !
        TimelineView(.animation) { context in
            // On calcule quelle frame afficher en fonction du temps
            let currentFrame = frameIndex(for: context.date)
            
            Image("\(baseName)\(currentFrame)")
               .resizable()
               .interpolation(.none) // CRUCIAL pour le pixel art net
               .aspectRatio(contentMode: .fit)
        }
    }
    
    /// Calcule l'index de la frame à afficher en fonction du temps
    /// C'est une fonction "pure" : même temps = même résultat
    private func frameIndex(for date: Date) -> Int {
        // On utilise le timestamp absolu (secondes depuis 1970)
        let totalSeconds = date.timeIntervalSince1970
        
        // On divise par la vitesse pour ralentir l'animation
        // Ex: à 0.5s, on change de frame toutes les demi-secondes
        let steppedIndex = Int(totalSeconds / animationSpeed)
        
        // Modulo pour boucler l'animation (0, 1, 2, 3, 0, 1, 2, 3...)
        return steppedIndex % frameCount
    }
}

// Preview pour tester dans Xcode
#Preview {
    AnimatedPixelPet()
        .frame(width: 100, height: 100)
        .background(Color.black)
}
