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
            VStack(spacing: 30) {
                if timerManager.isFocusing {
                    // Notre nouveau composant circulaire ! ✨
                    CircularProgressView(
                        progress: timerManager.progress,
                        timeRemaining: timerManager.remainingTimeFormatted,
                        totalMinutes: timerManager.selectedMinutes,
                        timerName: timerManager.currentTimerName,
                        icon: timerManager.currentTimerIcon,
                        accentColor: .orange // Tu peux changer la couleur ici
                    )
                    .padding(.top, 60)
                    
                    // Bouton pause/stop plus visible
                    HStack(spacing: 20) {
                        Button {
                            timerManager.togglePlayPause()
                        } label: {
                            HStack {
                                Image(systemName: "pause.fill")
                                Text("Pause")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.orange.gradient)
                            .cornerRadius(15)
                        }
                        
                        Button {
                            timerManager.stopActivity()
                            expandMiniTimer = false
                        } label: {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.red.gradient)
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                } else {
                    // État quand aucun timer n'est actif
                    VStack(spacing: 20) {
                        Image(systemName: "timer")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)
                        
                        Text("No timer active")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start a timer from the home tab")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            expandMiniTimer = false
                        } label: {
                            Text("Close")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.orange.gradient)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                    }
                    .padding(.top, 100)
                }
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .ignoresSafeArea(edges: .all)
            .navigationTransition(.zoom(sourceID: "MINITIMER", in: animation))
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
                        .font(.caption)
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
