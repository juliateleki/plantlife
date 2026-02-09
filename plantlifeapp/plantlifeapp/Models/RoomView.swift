//
//  RoomView.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import SwiftUI
import SwiftData

struct RoomView: View {
    let plantName: String
    let plantRate: Double

    let room: RoomState
    let items: [DecorItem]
    let onTogglePlace: (DecorItem) -> Void

    private func emoji(for itemID: String) -> String {
        switch itemID {
        case "rug_01": return "🟫"
        case "chair_01": return "🪑"
        case "couch_01": return "🛋️"
        default: return "📦"
        }
    }

    private func placedSummary() -> String {
        if room.placedItemIDs.isEmpty { return "No decor placed yet" }
        return room.placedItemIDs.map { emoji(for: $0) }.joined(separator: " ")
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
                    Text("🪴 \(plantName)")
                        .font(.title2)
                    Text("\(plantRate, specifier: "%.1f") coins / min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(placedSummary())
                        .padding(.top, 8)
                        .foregroundStyle(room.placedItemIDs.isEmpty ? .secondary : .primary)
                }
            }

            let owned = items.filter { $0.isOwned && $0.roomType == RoomType.living }

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
