import SwiftUI
import SwiftData

struct PlantsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    @Query private var rooms: [RoomState]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var gameStore: GameStore

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
                                if plant.location != nil {
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
                        let isPlaced = (plant.location != nil)
                        Button(isPlaced ? "Remove" : "Place") {
                            if isPlaced {
                                _ = gameStore.removeFromLocation(plant: plant, modelContext: modelContext)
                            } else {
                                gameStore.pendingPlacement = plant
                                dismiss()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .navigationTitle("Your Plants")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Place All") {
                    var used = Set(plants.compactMap { $0.location })
                    for plant in plants.filter({ $0.isOwned && $0.location == nil }) {
                        if let free = PlantLocation.all.first(where: { !used.contains($0) }) {
                            _ = gameStore.place(plant: plant, at: free, modelContext: modelContext)
                            used.insert(free)
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Remove All") {
                    for plant in plants where plant.location != nil {
                        _ = gameStore.removeFromLocation(plant: plant, modelContext: modelContext)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { PlantsListView() }
}
