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

        let ownedPlants = plants.filter { $0.isOwned }

        let activePlant: Plant? = {
            guard let player else { return ownedPlants.first }
            if let id = player.currentPlantID,
               let match = ownedPlants.first(where: { $0.id == id }) {
                return match
            }
            return ownedPlants.first
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

            if !ownedPlants.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Plants")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ownedPlants) { plant in
                                PlantCard(
                                    plant: plant,
                                    isActive: plant.id == activePlant?.id
                                ) {
                                    gameStore.setActivePlant(
                                        plant: plant,
                                        modelContext: modelContext
                                    )
                                }
                            }
                        }
                    }
                }
            }

            if let plant = activePlant {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Active Plant: \(plant.name)")
                        .font(.headline)

                    Text("Level \(plant.level) • \(plant.growthStageLabel)")
                        .foregroundStyle(.secondary)

                    Text("\(plant.coinsPerMinute, specifier: "%.2f") coins / min")
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
                    plantLevel: plant.level,
                    plantID: plant.id,
                    room: room,
                    items: items,
                    onTogglePlace: { item in
                        gameStore.togglePlace(
                            item: item,
                            in: room,
                            modelContext: modelContext
                        )
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
                onSellDecor: { item in
                    _ = gameStore.sellDecor(item: item, modelContext: modelContext)
                },
                onBuyPlant: { plant in
                    _ = gameStore.buyPlant(plant: plant, modelContext: modelContext)
                },
                onSellPlant: { plant in
                    _ = gameStore.sellPlant(plant: plant, modelContext: modelContext)
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

private struct PlantCard: View {
    let plant: Plant
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Text(emojiForStage(plant.growthStageLabel))
                .font(.system(size: 34))

            Text(plant.name)
                .font(.caption)
                .bold()
                .lineLimit(1)

            Text("Lvl \(plant.level)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 110)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(.thinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isActive ? .green : .clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .onTapGesture { onTap() }
    }

    private func emojiForStage(_ stage: String) -> String {
        switch stage {
        case "Sprout": return "🌱"
        case "Baby": return "🪴"
        case "Growing": return "🌿"
        default: return "🌳"
        }
    }
}
