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

    private var isPicking: Bool { gameStore.pendingPlacement != nil }

    private func plant(at location: PlantLocation) -> Plant? {
        plants.first { $0.location == Optional(location) }
    }

    private var ownedPlants: [Plant] {
        plants.filter { $0.isOwned && $0.location != nil }
    }

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

    private func fillColor(occupied: Bool, isPicking: Bool) -> Color {
        if occupied { return Color.gray.opacity(0.25) }
        return Color.blue.opacity(isPicking ? 0.2 : 0.1)
    }

    private func borderColor(occupied: Bool, isPicking: Bool) -> Color {
        if occupied { return Color.gray }
        return isPicking ? Color.blue : Color.secondary
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
                    .foregroundStyle(Color.blue)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.clear)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .frame(height: 260)

                VStack(spacing: 10) {
                    // Show all plants visually
                    if ownedPlants.isEmpty {
                        Text("No plants owned yet")
                            .foregroundStyle(Color.secondary)
                    } else {
                        // Display emojis for all owned plants
                        HStack(spacing: 12) {
                            ForEach(ownedPlants, id: \.id) { p in
                                Text(plantEmoji(for: p.id, level: p.level))
                                    .font(.system(size: 40))
                                    .accessibilityLabel("\(p.name), level \(p.level)")
                            }
                        }
                    }

                    Text(placedSummary())
                        .padding(.top, 8)
                        .foregroundStyle(room.placedItemIDs.isEmpty ? Color.secondary : Color.primary)
                }

                // Tap targets for choosing locations
                GeometryReader { geo in
                    let boxSize = CGSize(width: 70, height: 48)
                    let locations: [PlantLocation] = Array(PlantLocation.all)
                    ForEach(locations, id: \.self) { loc in
                        let index: Int = locations.firstIndex(of: loc) ?? 0
                        let col: Int = index % 4
                        let row: Int = index / 4
                        let origin: CGPoint = CGPoint(x: 20 + CGFloat(col) * (boxSize.width + 8),
                                                     y: 20 + CGFloat(row) * (boxSize.height + 8))
                        let rect: CGRect = CGRect(origin: origin, size: boxSize)

                        let occupied = plants.contains { $0.location == Optional(loc) }
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
                                    .fill(fillColor(occupied: occupied, isPicking: isPicking))
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(borderColor(occupied: occupied, isPicking: isPicking), lineWidth: 1)
                                if let occupant = plant(at: loc) {
                                    Text(plantEmoji(for: occupant.id, level: occupant.level))
                                        .font(.system(size: 28))
                                        .transition(.scale)
                                } else if let preview = gameStore.pendingPlacement, isPicking {
                                    Text(plantEmoji(for: preview.id, level: preview.level))
                                        .font(.system(size: 28))
                                        .opacity(0.5)
                                } else {
                                    Text(loc.title)
                                        .font(.caption2)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(occupied ? Color.secondary : Color.primary)
                                        .padding(4)
                                }
                            }
                        }
                        .disabled(occupied || !isPicking)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                    }
                }
                .padding()

                if isPicking {
                    VStack {
                        HStack {
                            Spacer()
                            Button("Cancel") {
                                gameStore.pendingPlacement = nil
                            }
                            .buttonStyle(.bordered)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview("Room – Minimal") {
    let room: RoomState = RoomState(roomType: .living)
    let toggle: (DecorItem) -> Void = { _ in }
    return RoomView(
        plants: [],
        room: room,
        items: [],
        gameStore: GameStore(),
        onTogglePlace: toggle
    )
    .padding()
}

