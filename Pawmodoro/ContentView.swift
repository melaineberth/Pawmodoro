//
//  ContentView.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText: String = ""
    @State private var expandMiniTimer: Bool = false
    @State private var timerManager: TimerManager = .shared
    @State private var themeManager: ThemeManager = .shared
    
    @Namespace private var animation

    var body: some View {
        Group {
            if #available(iOS 26, *) {
                NativeTabView()
            } else {
                NativeTabView()
            }
        }
        .preferredColorScheme(themeManager.preferredColorScheme)
        .onAppear {
            // Configurer le TimerManager avec le UserProgressManager
            let progressManager = UserProgressManager(modelContext: modelContext)
            timerManager.configure(with: progressManager)
            
            // Initialiser le profil utilisateur (et débloquer le chat gratuit si c'est la première fois)
            _ = progressManager.getUserProgress()
        }
    }
    
    @ViewBuilder
    func NativeTabView() -> some View {
        TabView {
            Tab.init("Timer", systemImage: "timer") {
                TimerView()
            }
                        
            Tab.init("Pet Shop", systemImage: "bag.fill") {
                ShopView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserProgress.self, inMemory: true)
}
