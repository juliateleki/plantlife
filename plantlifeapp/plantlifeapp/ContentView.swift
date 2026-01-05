//
//  ContentView.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import SwiftUI
import SwiftData

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
                        gameStore.togglePlace(item: item, in: room, modelContext: modelContext)
                    }
                    .padding(.horizontal)
                } else {
                    Text("Loading world…")
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
            seedIfNeeded()
            gameStore.start(modelContext: modelContext)
        }
        .onDisappear {
            gameStore.stop(modelContext: modelContext)
        }
    }

    private func seedIfNeeded() {
        // Player
        if players.isEmpty {
            modelContext.insert(PlayerState(coins: 0, lastActiveAt: .now))
        }
        // Plant
        if plants.isEmpty {
            modelContext.insert(Plant(name: "Pothos", coinsPerMinute: 6)) // 6/min = 0.1/sec
        }
        // Room
        if rooms.isEmpty {
            modelContext.insert(RoomState(roomType: .living))
        }
        // Shop Items
        if items.isEmpty {
            modelContext.insert(DecorItem(id: "rug_01", name: "Cozy Rug", price: 25, roomType: .living))
        }

        try? modelContext.save()
    }
}
