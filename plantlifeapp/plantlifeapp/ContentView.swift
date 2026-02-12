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

    var body: some View {
        let player = players.first
        let room = rooms.first

        // Active plant is derived from player.currentPlantID
        let activePlant: Plant? = {
            guard let player else { return plants.first }
            if let id = player.currentPlantID,
               let match = plants.first(where: { $0.id == id && $0.isOwned }) {
                return match
            }
            return plants.first(where: { $0.isOwned }) ?? plants.first
        }()

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

            if let plant = activePlant {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Plant: \(plant.name)")
                        .font(.headline)

                    Text("Level \(plant.level) • \(plant.growthStageLabel)")
                        .foregroundStyle(.secondary)

                    Text("\(plant.coinsPerMinute, specifier: "%.1f") coins / min")
                        .foregroundStyle(.secondary)

                    Text("Grows automatically every \(Int(plant.growthSecondsPerLevel))s")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if let plant = activePlant, let room {
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
                plants: plants,
                activePlantID: player?.currentPlantID,
                onBuyDecor: { item in
                    _ = gameStore.buy(item: item, modelContext: modelContext)
                },
                onBuyPlant: { plant in
                    _ = gameStore.buyPlant(plant: plant, modelContext: modelContext)
                },
                onSetActivePlant: { plant in
                    gameStore.setActivePlant(plant: plant, modelContext: modelContext)
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
