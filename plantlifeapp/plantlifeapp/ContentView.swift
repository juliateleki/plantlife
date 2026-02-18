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
    @State private var isPlantsMenuOpen = false
    @State private var isFurnitureMenuOpen = false

    var body: some View {
        let player = players.first
        let room = rooms.first

        let ownedPlants = plants.filter { $0.isOwned }

        let selectedPlant: Plant? = {
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

                if let player {
                    Text("Coins: \(player.coins)")
                        .font(.headline)
                }

                Menu {
                    Button("Your Plants") { isPlantsMenuOpen = true }
                    Button("Your Furniture") { isFurnitureMenuOpen = true }
                    Button("Shop") { isShopOpen = true }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .imageScale(.large)
                        .padding(.leading, 8)
                }
            }

            if let plant = selectedPlant, let room {
                RoomView(
                    plants: ownedPlants,
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
        .sheet(isPresented: $isPlantsMenuOpen) {
            NavigationStack {
                List {
                    Section("Your Plants") {
                        ForEach(plants.filter { $0.isOwned }) { plant in
                            HStack {
                                Text(plant.name).bold()
                                Spacer()
                                Text("Lvl \(plant.level)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle("Your Plants")
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { isPlantsMenuOpen = false } } }
            }
        }
        .sheet(isPresented: $isFurnitureMenuOpen) {
            NavigationStack {
                List {
                    Section("Your Furniture") {
                        ForEach(items.filter { $0.isOwned }) { item in
                            HStack {
                                Text(item.name).bold()
                                Spacer()
                                Text("Owned")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle("Your Furniture")
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { isFurnitureMenuOpen = false } } }
            }
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
    let isSelected: Bool
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
                .stroke(isSelected ? .green : .clear, lineWidth: 2)
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
