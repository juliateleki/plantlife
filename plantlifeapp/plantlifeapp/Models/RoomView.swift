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
                    let ownedPlants = plants.filter { $0.isOwned }
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

