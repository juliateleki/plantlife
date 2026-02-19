//
//  ContentView.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import SwiftUI
import SwiftData

private func abbreviated(_ value: Int) -> String {
    let num = Double(value)
    let thousand = 1_000.0
    let million = 1_000_000.0
    let billion = 1_000_000_000.0

    switch num {
    case 0..<thousand:
        return String(Int(num))
    case thousand..<million:
        return String(format: "%.1fK", num / thousand)
    case million..<billion:
        return String(format: "%.1fM", num / million)
    default:
        return String(format: "%.1fB", num / billion)
    }
}

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
                    Text("🪙 \(abbreviated(player.coins))")
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
                                VStack(alignment: .leading) {
                                    Text(item.name).bold()
                                    if let room = rooms.first {
                                        let isPlaced = room.isPlaced(item.id)
                                        Text(isPlaced ? "Placed" : "Owned")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text("Owned")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                if let room = rooms.first {
                                    let isPlaced = room.isPlaced(item.id)
                                    Button(isPlaced ? "Remove" : "Place") {
                                        gameStore.togglePlace(item: item, in: room, modelContext: modelContext)
                                    }
                                    .buttonStyle(.bordered)
                                }
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

#Preview("ContentView – Preview data") {
    let schema = Schema([
        PlayerState.self,
        Plant.self,
        DecorItem.self,
        RoomState.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    let player = PlayerState(coins: 10234, coinBank: 0, lastActiveAt: .now, currentPlantID: "plant_pothos")
    let room = RoomState(roomType: .living)
    let pothos = Plant(id: "plant_pothos", name: "Pothos", isOwned: true, purchasePrice: 0, level: 5, baseCoinsPerMinute: 0.1, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now)
    let snake = Plant(id: "plant_snake", name: "Snake Plant", isOwned: true, purchasePrice: 20, level: 3, baseCoinsPerMinute: 0.05, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now)
    context.insert(player)
    context.insert(room)
    context.insert(pothos)
    context.insert(snake)
    try! context.save()

    return ContentView()
        .modelContainer(container)
}

#Preview("Your Plants – Preview data") {
    let schema = Schema([
        PlayerState.self,
        Plant.self,
        DecorItem.self,
        RoomState.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    // Seed some plants, including Monstera
    let pothos = Plant(id: "plant_pothos", name: "Pothos", isOwned: true, purchasePrice: 0, level: 5, baseCoinsPerMinute: 0.1, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now)
    let snake = Plant(id: "plant_snake", name: "Snake Plant", isOwned: true, purchasePrice: 20, level: 3, baseCoinsPerMinute: 0.05, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now)
    let monstera = Plant(id: "plant_monstera", name: "Monstera", isOwned: true, purchasePrice: 30, level: 8, baseCoinsPerMinute: 0.05, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now)

    context.insert(pothos)
    context.insert(snake)
    context.insert(monstera)
    try! context.save()

    // Pull plants back for the list
    let plants = (try? context.fetch(FetchDescriptor<Plant>())) ?? []

    return NavigationStack {
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
    }
    .modelContainer(container)
}

#Preview("Your Furniture – Preview data") {
    let schema = Schema([
        PlayerState.self,
        Plant.self,
        DecorItem.self,
        RoomState.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    // Seed some decor items
    let rug = DecorItem(id: "rug_01", name: "Cozy Rug", price: 5, roomType: .living, isOwned: true)
    let chair = DecorItem(id: "chair_01", name: "Comfy Chair", price: 12, roomType: .living, isOwned: false)
    let couch = DecorItem(id: "couch_01", name: "Cozy Couch", price: 25, roomType: .living, isOwned: true)

    context.insert(rug)
    context.insert(chair)
    context.insert(couch)
    try! context.save()

    // Fetch items back for the list
    let items = (try? context.fetch(FetchDescriptor<DecorItem>())) ?? []

    return NavigationStack {
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
    }
    .modelContainer(container)
}

