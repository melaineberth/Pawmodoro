//
//  ShopView.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 14/12/2025.
//

import SwiftUI

struct ShopView: View {
    @State private var pets = Pet.preview()
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Classic") {
                    ScrollView {
                        // Section Classic
                        VStack {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(pets.filterByCategory(.classic)) { pet in
                                    PetShopCard(pet: pet)
                                }
                            }
                        }
                    }
                }
                
                Section("Seasonal"){
                    
                }
                
                Section("Special"){
                    
                }
            }
            .navigationTitle("Pet Shop")
        }
    }
}

// MARK: - Pet Shop Card Component
struct PetShopCard: View {
    let pet: Pet
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                
                Image(pet.image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .opacity(pet.isOwned ? 1.0 : 0.5)
                                
                // Lock icon si l'animal n'est pas possédé
                if !pet.isOwned {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                }
            }
            .aspectRatio(1, contentMode: .fit) // Force un ratio 1:1 (carré parfait)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Action pour acheter/sélectionner l'animal
            if !pet.isOwned {
                // Logique d'achat à implémenter
                print("Tentative d'achat de \(pet.name)")
            }
        }
    }
}

#Preview {
    ShopView()
}
