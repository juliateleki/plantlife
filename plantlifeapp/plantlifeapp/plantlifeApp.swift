//
//  plantlifeappApp.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 8/19/25.
//

import SwiftUI
import SwiftData

@main
struct PlantlifeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            PlayerState.self,
            Plant.self,
            DecorItem.self,
            RoomState.self
        ])
    }
}
