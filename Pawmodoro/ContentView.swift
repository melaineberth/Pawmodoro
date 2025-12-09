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
                    .tabBarMinimizeBehavior(.onScrollDown)
                    .tabViewBottomAccessory {
                        MiniTimerView()
                            .matchedTransitionSource(id: "MINITIMER", in: animation)
                            .onTapGesture {
                                expandMiniTimer.toggle()
                            }
                    }
            } else {
                NativeTabView()
            }
        }
        .fullScreenCover(isPresented: $expandMiniTimer) {
            ScrollView {
                VStack(spacing: 20) {
                    // Afficher plus d'informations sur le timer
                    if timerManager.isFocusing {
                        VStack(spacing: 12) {
                            Text(timerManager.currentTimerIcon)
                                .font(.system(size: 80))
                            
                            Text(timerManager.currentTimerName)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(timerManager.remainingTimeFormatted)
                                .font(.system(size: 60, weight: .light, design: .rounded))
                                .monospacedDigit()
                            
                            Text("of \(timerManager.selectedMinutes) minutes")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 40)
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 10) {
                    Capsule()
                        .fill(.primary.secondary)
                        .frame(width: 35, height: 3)
                    
                    HStack(spacing: 0) {
                        HStack(spacing: 12) {
                            if timerManager.isFocusing {
                                Text(timerManager.currentTimerIcon)
                                    .font(.system(size: 40))
                                    .frame(width: 80, height: 80)
                                    .background(.blue.gradient)
                                    .cornerRadius(20)
                            } else {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.blue.gradient)
                                    .frame(width: 80, height: 80)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(timerManager.isFocusing ? timerManager.currentTimerName : "No Timer")
                                    .font(.callout)
                                
                                Text(timerManager.isFocusing ? timerManager.remainingTimeFormatted : "Start a timer")
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            }
                            .lineLimit(1)
                        }
                        
                        Spacer(minLength: 0)
                        
                        Group {
                            Button("", systemImage: timerManager.isFocusing ? "pause.circle.fill" : "play.circle.fill") {
                                if timerManager.isFocusing {
                                    timerManager.togglePlayPause()
                                }
                            }
                            .disabled(!timerManager.isFocusing)
                            
                            Button("", systemImage: "stop.circle.fill") {
                                timerManager.stopActivity()
                                expandMiniTimer = false
                            }
                            .disabled(!timerManager.isFocusing)
                        }
                        .font(.title)
                        .foregroundStyle(Color.primary, Color.primary.opacity(0.1))
                    }
                    .padding(.horizontal, 15)
                }
                .navigationTransition(.zoom(sourceID: "MINITIMER", in: animation))
            }
        }
    }
    
    @ViewBuilder
    func NativeTabView() -> some View {
        TabView {
            Tab.init("Home", systemImage: "house.fill") {
                TimerView()
            }
                        
            Tab.init("Pet Shop", systemImage: "bag.fill") {
                NavigationStack {
                    List {
                        
                    }
                    .navigationTitle("Pet Shop")
                }
            }
            
            Tab.init("Settings", systemImage: "gear") {
                NavigationStack {
                    List {
                        
                    }
                    .navigationTitle("Settings")
                }
            }            
        }
    }

    @ViewBuilder
    func TimerInfo(_ size: CGSize) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: size.height / 4)
                .fill(.blue.gradient)
                .frame(width: size.width, height: size.height)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Some Apple Music Title")
                    .font(.callout)
                
                Text("Some Artist Name")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            .lineLimit(1)
        }
    }

    @ViewBuilder
    func MiniTimerView() -> some View {
        HStack(spacing: 15) {
            HStack(spacing: 12) {
                // Afficher l'icône du timer en cours
                if timerManager.isFocusing {
                    Text(timerManager.currentTimerIcon)
                        .font(.title2)
                        .frame(width: 30, height: 30)
                        .background(.blue.gradient)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.gradient)
                        .frame(width: 30, height: 30)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(timerManager.isFocusing ? timerManager.currentTimerName : "No Timer")
                        .font(.callout)
                        .lineLimit(1)
                    
                    Text(timerManager.isFocusing ? timerManager.remainingTimeFormatted : "Start a timer")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer(minLength: 0)
            
            if timerManager.isFocusing {
                Button {
                    timerManager.togglePlayPause()
                } label: {
                    Image(systemName: "pause.fill")
                        .contentShape(.rect)
                }
                .padding(.trailing, 10)
                
                Button {
                    timerManager.stopActivity()
                } label: {
                    Image(systemName: "stop.fill")
                        .contentShape(.rect)
                }
            } else {
                Button {
                    // Pas de timer actif
                } label: {
                    Image(systemName: "play.fill")
                        .contentShape(.rect)
                        .opacity(0.3)
                }
                .disabled(true)
                .padding(.trailing, 10)
            }
        }
        .padding(.horizontal, 15)
    }

}

#Preview {
    ContentView()
        .modelContainer(for: UserProgress.self, inMemory: true)
}
