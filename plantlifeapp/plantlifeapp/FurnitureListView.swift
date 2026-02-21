import SwiftUI
import SwiftData

struct FurnitureListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [DecorItem]
    @Query private var rooms: [RoomState]

    @StateObject private var gameStore = GameStore()

    var body: some View {
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if let room = rooms.first {
                    Button("Place All") {
                        let owned = items.filter { $0.isOwned }.map { $0.id }
                        var placed = room.placedItemIDs
                        for id in owned {
                            if !placed.contains(id) { placed.append(id) }
                        }
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
