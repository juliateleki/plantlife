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
    @State private var isShopOpen = false
    @State private var upgradeErrorText: String?

    var body: some View {
        let player = players.first
        let plant = plants.first
        let room = rooms.first

        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🌱 PlantLife")
                    .font(.title2).bold()

                Spacer()

                Button("Shop") {
                    isShopOpen = true
                }
            }

            if let player {
                Text("Coins: \(player.coins)")
                    .font(.headline)
            }

            if let plant {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Plant: \(plant.name)")
                        .font(.headline)

                    Text("Level \(plant.level) • \(plant.growthStageLabel)")
                        .foregroundStyle(.secondary)

                    Text("\(plant.coinsPerMinute, specifier: "%.1f") coins / min")
                        .foregroundStyle(.secondary)

                    HStack {
                        let cost = plant.nextUpgradeCost
                        Button("Upgrade (\(cost) coins)") {
                            let ok = gameStore.upgradePlant(modelContext: modelContext)
                            upgradeErrorText = ok ? nil : "Not enough coins to upgrade."
                        }
                        .buttonStyle(.borderedProminent)

                        if let upgradeErrorText {
                            Text(upgradeErrorText)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if let plant, let room {
                RoomView(
                    plantName: plant.name,
                    plantRate: plant.coinsPerMinute,
                    room: room,
                    items: items,
                    onTogglePlace: { item in
                        gameStore.togglePlace(item: item, in: room, modelContext: modelContext)
                    }
                )
            } else {
                Text("Loading world…")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $isShopOpen) {
            ShopView(
                items: items,
                onBuy: { item in
                    _ = gameStore.buy(item: item, modelContext: modelContext)
                }
            )
        }
        .onAppear {
            gameStore.start(modelContext: modelContext)
        }
        .onDisappear {
            gameStore.stop(modelContext: modelContext)
        }
    }
}
