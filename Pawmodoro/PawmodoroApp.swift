//
//  PawmodoroApp.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import SwiftUI
import SwiftData

@main
struct PawmodoroApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProgress.self,
            CustomTimer.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
