//
//  ShopView.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import SwiftUI
import SwiftData

struct ShopView: View {
    let items: [DecorItem]
    let plants: [Plant]

    let onBuyDecor: (DecorItem) -> Void
    let onSellDecor: (DecorItem) -> Void

    let onBuyPlant: (Plant) -> Void
    let onSellPlant: (Plant) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Plants") {
                    ForEach(plants) { plant in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(plant.name).bold()
                                Text("Level \(plant.level) • \(plant.growthStageLabel)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(plant.coinsPerMinute, specifier: "%.1f") coins / min")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if plant.isOwned {
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Owned")
                                        .foregroundStyle(.secondary)
                                    Button("Sell +\(plant.purchasePrice)") { onSellPlant(plant) }
                                }
                            } else {
                                Button("Buy \(plant.purchasePrice)") { onBuyPlant(plant) }
                            }
                        }
                    }
                }

                Section("Decor") {
                    ForEach(items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name).bold()
                                Text("Price: \(item.price)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if item.isOwned {
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Owned")
                                        .foregroundStyle(.secondary)
                                    Button("Sell +\(item.price)") { onSellDecor(item) }
                                }
                            } else {
                                Button("Buy") { onBuyDecor(item) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Shop")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
#Preview("Shop – All items and plants") {
    let plants: [Plant] = [
        Plant(id: "plant_pothos", name: "Pothos", isOwned: true, purchasePrice: 0, level: 3, baseCoinsPerMinute: 0.1, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
        Plant(id: "plant_snake", name: "Snake Plant", isOwned: false, purchasePrice: 20, level: 1, baseCoinsPerMinute: 0.05, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
        Plant(id: "plant_monstera", name: "Monstera", isOwned: true, purchasePrice: 30, level: 5, baseCoinsPerMinute: 0.05, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now)
    ]

    let items: [DecorItem] = [
        DecorItem(id: "rug_01", name: "Cozy Rug", price: 5, roomType: .living, isOwned: true),
        DecorItem(id: "chair_01", name: "Comfy Chair", price: 12, roomType: .living, isOwned: false),
        DecorItem(id: "couch_01", name: "Cozy Couch", price: 25, roomType: .living, isOwned: false)
    ]

    return ShopView(
        items: items,
        plants: plants,
        onBuyDecor: { _ in },
        onSellDecor: { _ in },
        onBuyPlant: { _ in },
        onSellPlant: { _ in }
    )
}

