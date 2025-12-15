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
    @Query private var items: [UserProgress]
    
    @State private var searchText: String = ""
    @State private var expandMiniTimer: Bool = false
    @State private var timerManager: TimerManager = .shared
    
    @Namespace private var animation

    var body: some View {
        Group {
            if #available(iOS 26, *) {
                NativeTabView()
            } else {
                NativeTabView()
            }
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
        .tint(.orange)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserProgress.self, inMemory: true)
}
