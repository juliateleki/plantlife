//
//  RoomView.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import SwiftUI

struct RoomView: View {
    let plantName: String
    let plantRate: Double
    let plantLevel: Int
    let plantID: String

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

                    // Plant visual evolves automatically by level
                    Text(plantEmoji(for: plantID, level: plantLevel))
                        .font(.system(size: 64))

                    Text("\(plantName)")
                        .font(.title3)

                    Text("\(plantRate, specifier: "%.1f") coins / min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(placedSummary())
                        .padding(.top, 8)
                        .foregroundStyle(room.placedItemIDs.isEmpty ? .secondary : .primary)
                }
            }

            let owned = items.filter { $0.isOwned && $0.roomType == .living }

            if !owned.isEmpty {
                Text("Your items")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(owned) { item in
                            let isPlaced = room.placedItemIDs.contains(item.id)

                            Button {
                                onTogglePlace(item)
                            } label: {
                                Text(isPlaced ? "Remove \(item.name)" : "Place \(item.name)")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }
}
