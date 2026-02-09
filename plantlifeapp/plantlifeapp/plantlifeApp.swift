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

      // Bump store name to avoid migration headaches as we evolve the schema.
      let config = ModelConfiguration("Plantlife_v3", schema: schema, isStoredInMemoryOnly: false)

      container = try ModelContainer(for: schema, configurations: [config])

      // Seed once at app launch
      seedWorldIfNeeded(container: container)

    } catch {
      fatalError("❌ Failed to create ModelContainer: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(container)
  }
}

// MARK: - Seeding

@MainActor
private func seedWorldIfNeeded(container: ModelContainer) {
  let context = ModelContext(container)

  do {
    let playerCount = try context.fetch(FetchDescriptor<PlayerState>()).count
    let plantCount = try context.fetch(FetchDescriptor<Plant>()).count
    let roomCount = try context.fetch(FetchDescriptor<RoomState>()).count
    let itemCount = try context.fetch(FetchDescriptor<DecorItem>()).count

    print(
      "📦 Before seed — players \(playerCount) plants \(plantCount) rooms \(roomCount) items \(itemCount)"
    )

    if playerCount == 0 {
      context.insert(PlayerState(coins: 0, coinBank: 0, lastActiveAt: .now))
    }

    if plantCount == 0 {
      context.insert(Plant(name: "Pothos", coinsPerMinute: 6))
    }

    if roomCount == 0 {
      context.insert(RoomState(roomType: RoomType.living))
    }

    if itemCount == 0 {
      context.insert(
        DecorItem(
          id: "rug_01",
          name: "Cozy Rug",
          price: 5,
          roomType: RoomType.living
        )
      )

      context.insert(
        DecorItem(
          id: "chair_01",
          name: "Comfy Chair",
          price: 12,
          roomType: RoomType.living
        )
      )

      context.insert(
        DecorItem(
          id: "couch_01",
          name: "Cozy Couch",
          price: 25,
          roomType: RoomType.living
        )
      )
    }

    try context.save()

    let playerCount2 = try context.fetch(FetchDescriptor<PlayerState>()).count
    let plantCount2 = try context.fetch(FetchDescriptor<Plant>()).count
    let roomCount2 = try context.fetch(FetchDescriptor<RoomState>()).count
    let itemCount2 = try context.fetch(FetchDescriptor<DecorItem>()).count

    print(
      "✅ After seed — players \(playerCount2) plants \(plantCount2) rooms \(roomCount2) items \(itemCount2)"
    )

  } catch {
    print("❌ Seeding failed:", error)
  }
}
