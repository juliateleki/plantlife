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
        func makeStoreName() -> String {
            #if DEBUG
            // Auto-bump store name in debug to avoid migration churn during development.
            // Format: Plantlife_YYYYMMDD_HHMMSS_build<build>
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let stamp = formatter.string(from: Date())
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "dev"
            return "Plantlife_\(stamp)_build\(build)"
            #else
            // Stable name for release builds
            return "Plantlife"
            #endif
        }

        let schema = Schema([
            PlayerState.self,
            Plant.self,
            DecorItem.self,
            RoomState.self,
        ])

        do {
            let storeName = makeStoreName()
            let config = ModelConfiguration(storeName, schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            print("❌ Primary ModelContainer creation failed: \(error). Retrying with fresh store name...")
            do {
                let fallbackName = "Plantlife_\(UUID().uuidString)"
                let fallbackConfig = ModelConfiguration(fallbackName, schema: schema, isStoredInMemoryOnly: false)
                container = try ModelContainer(for: schema, configurations: [fallbackConfig])
                print("✅ Fallback ModelContainer created with store name: \(fallbackName)")
            } catch let fallbackError {
                fatalError("❌ Failed to create ModelContainer on fallback as well: \(fallbackError)")
            }
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
                    lastActiveAt: .now
                )
            )
        }

        // Plants
        if plantCount == 0 {
            // Seed with 3 owned plants for balancing tests
            context.insert(
                Plant(
                    id: "plant_pothos",
                    name: "Pothos",
                    isOwned: true,
                    purchasePrice: 20,
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

            context.insert(
                Plant(
                    id: "plant_ficus",
                    name: "Ficus",
                    isOwned: false,
                    purchasePrice: 30,
                    level: 1,
                    baseCoinsPerMinute: 0.07,
                    rateGrowth: 1.0,
                    growthSecondsPerLevel: 1800,
                    lastGrowthAt: .now
                )
            )

            context.insert(
                Plant(
                    id: "plant_fern",
                    name: "Fern",
                    isOwned: false,
                    purchasePrice: 15,
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

