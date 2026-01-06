//
//  ContentView.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext

  @Query private var players: [PlayerState]
  @Query private var plants: [Plant]
  @Query private var rooms: [RoomState]
  @Query private var items: [DecorItem]

  @StateObject private var gameStore = GameStore()
  @State private var showShop = false

  var body: some View {
    let player = players.first
    let plant = plants.first
    let room = rooms.first

    NavigationStack {
      VStack(spacing: 16) {
        HStack {
          Text("Coins: \(player?.coins ?? 0)")
            .font(.title2).bold()
          Spacer()
          Button("Shop") { showShop = true }
        }
        .padding(.horizontal)

        if let plant, let room {
          RoomView(
            plantName: plant.name,
            plantRate: plant.coinsPerMinute,
            room: room,
            items: items
          ) { item in
            gameStore.togglePlace(
              item: item,
              in: room,
              modelContext: modelContext
            )
          }
          .padding(.horizontal)
        } else {
          Text(
            "Players \(players.count) Plants \(plants.count) Rooms \(rooms.count) Items \(items.count)"
          )

        }

        Spacer()
      }
      .navigationTitle("Plantlife")
    }
    .sheet(isPresented: $showShop) {
      ShopView(items: items) { item in
        _ = gameStore.buy(item: item, modelContext: modelContext)
      }
    }
    .onAppear {
//      seedIfNeeded()
      gameStore.start(modelContext: modelContext)
    }
    .onDisappear {
      gameStore.stop(modelContext: modelContext)
    }
  }

  //  private func seedIfNeeded() {
  //    print("🌱 seedIfNeeded called")
  //
  //    if players.isEmpty {
  //      modelContext.insert(
  //        PlayerState(coins: 0, coinBank: 0, lastActiveAt: .now)
  //      )
  //      print("→ inserted Player")
  //    }
  //    if plants.isEmpty {
  //      modelContext.insert(Plant(name: "Pothos", coinsPerMinute: 6))
  //      print("→ inserted Plant")
  //    }
  //    if rooms.isEmpty {
  //      modelContext.insert(RoomState(roomType: RoomType.living))
  //      print("→ inserted Room")
  //    }
  //    if items.isEmpty {
  //      modelContext.insert(
  //        DecorItem(
  //          id: "rug_01",
  //          name: "Cozy Rug",
  //          price: 5,
  //          roomType: RoomType.living
  //        )
  //      )
  //      print("→ inserted Decor")
  //    }
  //
  //    do {
  //      try modelContext.save()
  //      print("✅ save succeeded")
  //    } catch {
  //      print("❌ save failed:", error)
  //    }
  //
  //    // Force a direct fetch (bypasses @Query) to verify what’s in the DB
  //    do {
  //      let pCount = try modelContext.fetch(FetchDescriptor<PlayerState>()).count
  //      let plCount = try modelContext.fetch(FetchDescriptor<Plant>()).count
  //      let rCount = try modelContext.fetch(FetchDescriptor<RoomState>()).count
  //      let iCount = try modelContext.fetch(FetchDescriptor<DecorItem>()).count
  //      print(
  //        "📦 DB counts — players:",
  //        pCount,
  //        "plants:",
  //        plCount,
  //        "rooms:",
  //        rCount,
  //        "items:",
  //        iCount
  //      )
  //    } catch {
  //      print("❌ fetch failed:", error)
  //    }
  //  }

}
