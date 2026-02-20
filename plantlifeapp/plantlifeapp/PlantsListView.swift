import SwiftUI
import SwiftData

struct PlantsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    @Query private var rooms: [RoomState]

    var body: some View {
        List {
            Section("Your Plants") {
                ForEach(plants.filter { $0.isOwned }) { plant in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(plant.name).bold()
                            HStack(spacing: 8) {
                                Text("Lvl \(plant.level)")
                                    .foregroundStyle(.secondary)
                                if let room = rooms.first, room.isPlantPlaced(plant.id) {
                                    Text("Placed")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                            }
                        }
                        Spacer()
                        if let room = rooms.first {
                            let isPlaced = room.isPlantPlaced(plant.id)
                            Button(isPlaced ? "Remove" : "Place") {
                                var placed = room.placedPlantIDs
                                if let idx = placed.firstIndex(of: plant.id) {
                                    placed.remove(at: idx)
                                } else {
                                    placed.append(plant.id)
                                }
                                room.placedPlantIDs = placed
                                try? modelContext.save()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .navigationTitle("Your Plants")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if let room = rooms.first {
                    Button("Place All") {
                        let owned = plants.filter { $0.isOwned }.map { $0.id }
                        var placed = room.placedPlantIDs
                        for id in owned {
                            if !placed.contains(id) { placed.append(id) }
                        }
                        room.placedPlantIDs = placed
                        try? modelContext.save()
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let room = rooms.first {
                    Button("Remove All") {
                        var placed = room.placedPlantIDs
                        placed.removeAll(where: { id in
                            plants.contains(where: { $0.id == id && $0.isOwned })
                        })
                        room.placedPlantIDs = placed
                        try? modelContext.save()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { PlantsListView() }
}
