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
        .toolbar {}
        .onAppear { gameStore.start(modelContext: modelContext) }
        .onDisappear { gameStore.stop(modelContext: modelContext) }
    }
}

#Preview {
    NavigationStack { FurnitureListView() }
}
