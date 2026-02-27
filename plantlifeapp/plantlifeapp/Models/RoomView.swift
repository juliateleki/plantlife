//
//  RoomView.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import SwiftUI
import SwiftData

struct RoomView: View {
    let plants: [Plant]

    let room: RoomState
    let items: [DecorItem]
    @ObservedObject var gameStore: GameStore
    let onTogglePlace: (DecorItem) -> Void

    @Environment(\.modelContext) private var modelContext

    // MARK: - Plant Visual Mapping

    private func plantEmoji(for id: String, level: Int) -> String {
        switch id {
        case "plant_pothos":
            switch level {
            case 1...3: return "🌱"
            case 4...7: return "🪴"
            case 8...14: return "🌿"
            default: return "🌳"
            }

        case "plant_monstera":
            switch level {
            case 1...3: return "🌱"
            case 4...7: return "🌿"
            case 8...14: return "🌴"
            default: return "🌳"
            }

        case "plant_snake":
            switch level {
            case 1...3: return "🌱"
            case 4...7: return "🌾"
            case 8...14: return "🌵"
            default: return "🌳"
            }

        case "plant_ficus":
            switch level {
            case 1...3: return "🌱"
            case 4...7: return "🌿"
            case 8...14: return "🌴"
            default: return "🌳"
            }

        case "plant_fern":
            switch level {
            case 1...3: return "🌱"
            case 4...7: return "🌿"
            case 8...14: return "🌾"
            default: return "🌳"
            }

        default:
            return "🪴"
        }
    }

    // MARK: - Decor Emoji Mapping

    private func emoji(for itemID: String) -> String {
        switch itemID {
        case "rug_01": return "🟫"
        case "chair_01": return "🪑"
        case "couch_01": return "🛋️"
        default: return "📦"
        }
    }

    private func placedSummary() -> String {
        let placed = room.placedItemIDs
        if placed.isEmpty { return "No decor placed yet" }
        return placed.map { emoji(for: $0) }.joined(separator: " ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Living Room")
                .font(.title3).bold()

            if gameStore.pendingPlacement != nil {
                Text("Tap a spot to place \(gameStore.pendingPlacement?.name ?? "plant")")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.thinMaterial)
                    .frame(height: 260)

                VStack(spacing: 10) {
                    // Show all plants visually
                    let ownedPlants = plants.filter { $0.isOwned && $0.location != nil }
                    if ownedPlants.isEmpty {
                        Text("No plants owned yet")
                            .foregroundStyle(.secondary)
                    } else {
                        // Display emojis for all owned plants
                        HStack(spacing: 12) {
                            ForEach(ownedPlants) { p in
                                Text(plantEmoji(for: p.id, level: p.level))
                                    .font(.system(size: 40))
                                    .accessibilityLabel(Text("\(p.name), level \(p.level)"))
                            }
                        }
                    }

                    Text(placedSummary())
                        .padding(.top, 8)
                        .foregroundStyle(room.placedItemIDs.isEmpty ? .secondary : .primary)
                }

                // Tap targets for choosing locations
                GeometryReader { geo in
                    let boxSize = CGSize(width: 70, height: 48)
                    ForEach(PlantLocation.all, id: \.self) { loc in
                        let index = PlantLocation.all.firstIndex(of: loc) ?? 0
                        let col = index % 4
                        let row = index / 4
                        let origin = CGPoint(x: 20 + CGFloat(col) * (boxSize.width + 8),
                                             y: 20 + CGFloat(row) * (boxSize.height + 8))
                        let rect = CGRect(origin: origin, size: boxSize)

                        let occupied = plants.contains { $0.location == loc }
                        let isPicking = (gameStore.pendingPlacement != nil)

                        Button {
                            guard let plant = gameStore.pendingPlacement else { return }
                            if !occupied {
                                _ = gameStore.place(plant: plant, at: loc, modelContext: modelContext)
                                gameStore.pendingPlacement = nil
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(occupied ? Color.gray.opacity(0.25) : Color.blue.opacity(isPicking ? 0.2 : 0.1))
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(occupied ? Color.gray : (isPicking ? Color.blue : Color.secondary), lineWidth: 1)
                                Text(loc.title)
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(occupied ? .secondary : .primary)
                                    .padding(4)
                            }
                        }
                        .disabled(occupied || !isPicking)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview("Room – Multiple plants") {
    let room = RoomState(roomType: .living)
    var plants: [Plant] = [
        Plant(id: "plant_pothos", name: "Pothos", isOwned: true, purchasePrice: 0, level: 6, baseCoinsPerMinute: 0.1, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
        Plant(id: "plant_snake", name: "Snake Plant", isOwned: true, purchasePrice: 20, level: 2, baseCoinsPerMinute: 0.05, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
        Plant(id: "plant_monstera", name: "Monstera", isOwned: true, purchasePrice: 30, level: 8, baseCoinsPerMinute: 0.05, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
    ]
    if let idx = plants.firstIndex(where: { $0.id == "plant_pothos" }) { plants[idx].location = .bookshelf2 }
    if let idx = plants.firstIndex(where: { $0.id == "plant_monstera" }) { plants[idx].location = .hanging1 }
    let items: [DecorItem] = [
        DecorItem(id: "rug_01", name: "Cozy Rug", price: 5, roomType: .living, isOwned: true),
        DecorItem(id: "chair_01", name: "Comfy Chair", price: 12, roomType: .living, isOwned: false),
    ]
    RoomView(
        plants: plants,
        room: room,
        items: items,
        gameStore: GameStore(),
        onTogglePlace: { _ in }
    )
    .padding()
}

