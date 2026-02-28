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
        .toolbar {}
    }
}

#Preview {
    NavigationStack { PlantsListView() }
}
