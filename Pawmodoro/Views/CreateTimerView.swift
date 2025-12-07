//
//  CreateTimerView.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 07/12/2025.
//

import SwiftUI
import UIKit
import SwiftData

struct CreateTimerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @State private var emoji = "😁"
    @State private var pickEmoji: Bool = false
    @State private var bgColor = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    @State private var includesToppings: Bool = false
    @State private var newTimer = CustomTimer(duration: 25)
    @State private var size: CGFloat = 150
                
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Title", text: $newTimer.name)
                    TextField("Short description", text: $newTimer.desc)
                }
                
                Section {
                    Picker("Duration", selection: $newTimer.duration) {
                        ForEach(1...60, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Icon")
                        Spacer()
                        Button {
                            pickEmoji.toggle()
                        } label: {
                            Text(emoji)
                        }
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    ColorPicker("Color", selection: $bgColor)
                }
            }
            .navigationTitle(Text("Add a timer"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            newTimer.icon = emoji
                            newTimer.color = bgColor.toHex()
                            context.insert(newTimer)
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.orange)
                }
            }
            .sheet(isPresented: $pickEmoji) {
            }
        }
    }
}


#Preview {
    CreateTimerView()
        .modelContainer(for: CustomTimer.self)
}

extension Color {
    func toHex() -> String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
