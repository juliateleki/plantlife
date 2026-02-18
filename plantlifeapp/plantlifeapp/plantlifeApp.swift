//
//  plantlifeappApp.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 8/19/25.
//

import SwiftData
import SwiftUI

@main
struct PlantlifeApp: App {

    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                PlayerState.self,
                Plant.self,
                DecorItem.self,
                RoomState.self,
            ])

            // Bump store name whenever the SwiftData schema changes.
            let config = ModelConfiguration("Plantlife_v8", schema: schema, isStoredInMemoryOnly: false)

            container = try ModelContainer(for: schema, configurations: [config])

        } catch {
            fatalError("❌ Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    seedWorldIfNeeded(container: container)
                }
        }
        .modelContainer(container)
    }
}

@MainActor
private func seedWorldIfNeeded(container: ModelContainer) {
    let context = ModelContext(container)

    do {
        let playerCount = try context.fetch(FetchDescriptor<PlayerState>()).count
        let plantCount = try context.fetch(FetchDescriptor<Plant>()).count
        let roomCount = try context.fetch(FetchDescriptor<RoomState>()).count
        let itemCount = try context.fetch(FetchDescriptor<DecorItem>()).count

        // Player
        if playerCount == 0 {
            // Start with Pothos as the selected plant
            context.insert(
                PlayerState(
                    coins: 100,
                    coinBank: 0,
                    lastActiveAt: .now,
                    currentPlantID: "plant_pothos"
                )
            )
        } else {
            // Ensure currentPlantID is set if missing
            if let player = (try? context.fetch(FetchDescriptor<PlayerState>()))?.first,
               player.currentPlantID == nil {
                player.currentPlantID = "plant_pothos"
            }
        }

        // Plants
        if plantCount == 0 {
            // Seed with 3 owned plants for balancing tests
            context.insert(
                Plant(
                    id: "plant_pothos",
                    name: "Pothos",
                    isOwned: true,
                    purchasePrice: 0,
                    level: 1,
                    baseCoinsPerMinute: 0.1,
                    rateGrowth: 1.0,
                    growthSecondsPerLevel: 1800,
                    lastGrowthAt: .now
                )
            )

            context.insert(
                Plant(
                    id: "plant_snake",
                    name: "Snake Plant",
                    isOwned: true,
                    purchasePrice: 20,
                    level: 1,
                    baseCoinsPerMinute: 0.05,
                    rateGrowth: 1.0,
                    growthSecondsPerLevel: 1800,
                    lastGrowthAt: .now
                )
            )

            context.insert(
                Plant(
                    id: "plant_monstera",
                    name: "Monstera",
                    isOwned: true,
                    purchasePrice: 30,
                    level: 1,
                    baseCoinsPerMinute: 0.05,
                    rateGrowth: 1.0,
                    growthSecondsPerLevel: 1800,
                    lastGrowthAt: .now
                )
            )
        }

        // Room
        if roomCount == 0 {
            context.insert(RoomState(roomType: .living))
        }

        // Decor shop items
        if itemCount == 0 {
            context.insert(DecorItem(id: "rug_01", name: "Cozy Rug", price: 5, roomType: .living))
            context.insert(DecorItem(id: "chair_01", name: "Comfy Chair", price: 12, roomType: .living))
            context.insert(DecorItem(id: "couch_01", name: "Cozy Couch", price: 25, roomType: .living))
        }

        try context.save()
    } catch {
        print("❌ Seeding failed:", error)
    }
}
