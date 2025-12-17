//
//  ShopView.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 14/12/2025.
//

import SwiftUI
import SwiftData

struct ShopView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var progress: [UserProgress]
    
    @State private var showCurrencySheet = false
    @State private var showPurchaseAlert = false
    @State private var alertMessage = ""
    
    private var userProgress: UserProgress? {
        progress.first
    }
    
    private var progressManager: UserProgressManager {
        UserProgressManager(modelContext: modelContext)
    }
    
    // Liste des animaux disponibles dans le shop
    private var availablePets: [Pet] {
        Pet.preview()
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Classic") {
                    ScrollView {
                        VStack {
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(availablePets.filterByCategory(.classic)) { pet in
                                    PetShopCard(
                                        pet: pet,
                                        isOwned: isPetOwned(pet),
                                        onPurchase: { purchasePet(pet) }
                                    )
                                }
                            }
                            .padding(10)
                        }
                    }
                }
                
                Section("Seasonal") {
                    ScrollView {
                        VStack {
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(availablePets.filterByCategory(.seasonal)) { pet in
                                    PetShopCard(
                                        pet: pet,
                                        isOwned: isPetOwned(pet),
                                        onPurchase: { purchasePet(pet) }
                                    )
                                }
                            }
                            .padding(10)
                        }
                    }
                }
                
                Section("Special") {
                    ScrollView {
                        VStack {
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(availablePets.filterByCategory(.special)) { pet in
                                    PetShopCard(
                                        pet: pet,
                                        isOwned: isPetOwned(pet),
                                        onPurchase: { purchasePet(pet) }
                                    )
                                }
                            }
                            .padding(10)
                        }
                    }
                }
            }
            .navigationTitle("Pet Shop")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCurrencySheet = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundStyle(.yellow)
                            Text("\(userProgress?.coins ?? 0)")
                        }
                        .padding(.horizontal, 5)
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showCurrencySheet) {
                CurrencySheetView(coins: userProgress?.coins ?? 0)
            }
            .alert("Achat", isPresented: $showPurchaseAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func isPetOwned(_ pet: Pet) -> Bool {
        guard let progress = userProgress else { return false }
        return progress.ownsPet(withID: pet.name)
    }
    
    private func purchasePet(_ pet: Pet) {
        let success = progressManager.buyPet(
            name: pet.name,
            type: pet.category.rawValue,
            imageName: pet.image,
            price: pet.price
        )
        
        if success {
            alertMessage = "Vous avez acheté \(pet.name) !"
        } else {
            alertMessage = "Pas assez de pièces. Il vous manque \(pet.price - (userProgress?.coins ?? 0)) pièces."
        }
        
        showPurchaseAlert = true
    }
}

// MARK: - Currency Sheet View
struct CurrencySheetView: View {
    @Environment(\.dismiss) var dismiss
    let coins: Int
    
    var body: some View {
        NavigationStack {
            List {
                Section("Current Balance") {
                    HStack(spacing: 10) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.yellow)
                        
                        Text("\(coins) Coins")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Earn More Coins") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.orange)
                            Text("Complete a Pomodoro session")
                            Spacer()
                            Text("+10/min")
                                .fontWeight(.semibold)
                                .foregroundStyle(.yellow)
                        }
                        
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.red)
                            Text("Daily streak bonus")
                            Spacer()
                            Text("+5")
                                .fontWeight(.semibold)
                                .foregroundStyle(.yellow)
                        }
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.blue)
                            Text("Complete daily challenge")
                            Spacer()
                            Text("+25")
                                .fontWeight(.semibold)
                                .foregroundStyle(.yellow)
                        }
                    }
                }
                
                Section("About Coins") {
                    Text("Coins can be used to unlock new pets in the shop. Complete Pomodoro sessions and daily challenges to earn more!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Coins")
            .navigationBarTitleDisplayMode(.inline)
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Pet Shop Card Component
struct PetShopCard: View {
    let pet: Pet
    let isOwned: Bool
    let onPurchase: () -> Void
    
    @State private var imgSize: CGFloat = 65
    @State private var showAnimationSheet = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
            
            Image(pet.image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: imgSize, height: imgSize)
                .opacity(isOwned ? 1.0 : 0.5)
                .contentShape(Rectangle())
                .onTapGesture {
                    showAnimationSheet = true
                }
                                        
            // Lock icon si l'animal n'est pas possédé (sauf s'il est gratuit)
            if !isOwned && pet.price > 0 {
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .allowsHitTesting(false)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .sheet(isPresented: $showAnimationSheet) {
            PetAnimationPreviewSheet(
                pet: pet,
                isOwned: isOwned,
                onPurchase: onPurchase
            )
        }
    }
}

// MARK: - Pet Animation Preview Sheet
struct PetAnimationPreviewSheet: View {
    let pet: Pet
    let isOwned: Bool
    let onPurchase: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var currentFrame: Int = 0
    @State private var animationTimer: Timer?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                if !isOwned {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(.yellow)
                        Text("\(pet.price) Coins")
                            .fontWeight(.semibold)
                    }
                    .padding(.top, 8)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Owned")
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }
                    .padding(.top, 8)
                }
                
                // Animation de l'animal avec frames comme dans LiveActivity
                Image(getAnimationImageName())
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                VStack(spacing: 8) {
                    Text(pet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(pet.category.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if !isOwned {
                    Button {
                        onPurchase()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: pet.price == 0 ? "gift" : "cart")
                            Text(pet.price == 0 ? "Get for Free" : "Buy for \(pet.price) Coins")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .fontWeight(.medium)
                        .background(pet.price == 0 ? Color.green : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 1000))
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)

        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    // MARK: - Animation Methods
    
    private func getAnimationImageName() -> String {
        let components = pet.image.split(separator: "_")
        if let animalName = components.first {
            return "\(animalName)_work_\(currentFrame)"
        }
        return "\(pet.image)_work_\(currentFrame)"
    }
    
    private func startAnimation() {
        currentFrame = 0
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            currentFrame = (currentFrame + 1) % 4
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

#Preview {
    ShopView()
        .modelContainer(for: UserProgress.self, inMemory: true)
}
