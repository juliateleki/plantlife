import SwiftUI
import SwiftData

struct FurnitureListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [DecorItem]
    @Query private var rooms: [RoomState]
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        List {
            Section("Chairs") {
                ForEach(items.filter { $0.isOwned && $0.category == .chair }) { item in
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
                                if isPlaced {
                                    gameStore.togglePlace(item: item, in: room, modelContext: modelContext)
                                } else {
                                    gameStore.pendingDecorPlacement = item
                                    dismiss()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            Section("Couches") {
                ForEach(items.filter { $0.isOwned && $0.category == .couch }) { item in
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
                                if isPlaced {
                                    gameStore.togglePlace(item: item, in: room, modelContext: modelContext)
                                } else {
                                    gameStore.pendingDecorPlacement = item
                                    dismiss()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            Section("Other Decor") {
                ForEach(items.filter { $0.isOwned && $0.category != .chair && $0.category != .couch }) { item in
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
                                if isPlaced {
                                    gameStore.togglePlace(item: item, in: room, modelContext: modelContext)
                                } else {
                                    gameStore.pendingDecorPlacement = item
                                    dismiss()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .navigationTitle("Your Furniture")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if let room = rooms.first {
                    Button("Place All") {
                        var placed = room.placedItemIDs
                        // Ensure at most one chair and one couch
                        let ownedChairs = items.filter { $0.isOwned && $0.category == .chair }
                        let ownedCouches = items.filter { $0.isOwned && $0.category == .couch }
                        let ownedOthers = items.filter { $0.isOwned && $0.category != .chair && $0.category != .couch }

                        // Pick first owned chair and couch if any
                        if let chair = ownedChairs.first {
                            placed.removeAll { id in
                                if let d = items.first(where: { $0.id == id }) { return d.category == .chair }
                                return false
                            }
                            if !placed.contains(chair.id) { placed.append(chair.id) }
                        }
                        if let couch = ownedCouches.first {
                            placed.removeAll { id in
                                if let d = items.first(where: { $0.id == id }) { return d.category == .couch }
                                return false
                            }
                            if !placed.contains(couch.id) { placed.append(couch.id) }
                        }
                        // Add all other decor
                        for item in ownedOthers {
                            if !placed.contains(item.id) { placed.append(item.id) }
                        }
                        room.placedItemIDs = placed
                        try? modelContext.save()
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let room = rooms.first {
                    Button("Remove All") {
                        var placed = room.placedItemIDs
                        let ownedIDs = Set(items.filter { $0.isOwned }.map { $0.id })
                        placed.removeAll { ownedIDs.contains($0) }
                        room.placedItemIDs = placed
                        try? modelContext.save()
                    }
                }
            }
        }
        .onAppear { gameStore.start(modelContext: modelContext) }
        .onDisappear { gameStore.stop(modelContext: modelContext) }
    }
}

#Preview {
    NavigationStack { FurnitureListView() }
}
