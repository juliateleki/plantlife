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
    let onTogglePlace: (DecorItem) -> Void

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
            }
        }
    }
}

#Preview("Room – Multiple plants") {
    let room = RoomState(roomType: .living)
    let plants: [Plant] = [
        Plant(id: "plant_pothos", name: "Pothos", isOwned: true, purchasePrice: 0, level: 6, baseCoinsPerMinute: 0.1, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
        Plant(id: "plant_snake", name: "Snake Plant", isOwned: true, purchasePrice: 20, level: 2, baseCoinsPerMinute: 0.05, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
        Plant(id: "plant_monstera", name: "Monstera", isOwned: true, purchasePrice: 30, level: 8, baseCoinsPerMinute: 0.05, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
    ]
    var plants = plants
    if let idx = plants.firstIndex(where: { $0.id == "plant_pothos" }) { plants[idx].location = .bookshelf2 }
    if let idx = plants.firstIndex(where: { $0.id == "plant_monstera" }) { plants[idx].location = .hanging1 }
    let items: [DecorItem] = [
        DecorItem(id: "rug_01", name: "Cozy Rug", price: 5, roomType: .living, isOwned: true),
        DecorItem(id: "chair_01", name: "Comfy Chair", price: 12, roomType: .living, isOwned: false),
    ]
    return RoomView(
        plants: plants,
        room: room,
        items: items,
        onTogglePlace: { _ in }
    )
    .padding()
}

