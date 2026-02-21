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

                Section("Chairs") {
                    ForEach(items.filter { $0.category == .chair }) { item in
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
                                    Text("Owned").foregroundStyle(.secondary)
                                    Button("Sell +\(item.price)") { onSellDecor(item) }
                                }
                            } else {
                                Button("Buy") { onBuyDecor(item) }
                            }
                        }
                    }
                }

                Section("Couches") {
                    ForEach(items.filter { $0.category == .couch }) { item in
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
                                    Text("Owned").foregroundStyle(.secondary)
                                    Button("Sell +\(item.price)") { onSellDecor(item) }
                                }
                            } else {
                                Button("Buy") { onBuyDecor(item) }
                            }
                        }
                    }
                }

                Section("Other Decor") {
                    ForEach(items.filter { $0.category != .chair && $0.category != .couch }) { item in
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
                                    Text("Owned").foregroundStyle(.secondary)
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

#Preview("Shop – Large Catalog") {
    let plants: [Plant] = [
        Plant(id: "plant_pothos", name: "Pothos", isOwned: true, purchasePrice: 0, level: 4, baseCoinsPerMinute: 0.12, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
        Plant(id: "plant_snake", name: "Snake Plant", isOwned: false, purchasePrice: 20, level: 2, baseCoinsPerMinute: 0.06, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
        Plant(id: "plant_monstera", name: "Monstera", isOwned: true, purchasePrice: 30, level: 7, baseCoinsPerMinute: 0.08, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
        Plant(id: "plant_ficus", name: "Ficus", isOwned: false, purchasePrice: 45, level: 1, baseCoinsPerMinute: 0.07, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now),
        Plant(id: "plant_fern", name: "Fern", isOwned: false, purchasePrice: 15, level: 3, baseCoinsPerMinute: 0.05, rateGrowth: 1.0, growthSecondsPerLevel: 1800, lastGrowthAt: .now)
    ]
    let items: [DecorItem] = [
        DecorItem(id: "rug_01", name: "Cozy Rug", price: 5, roomType: .living, isOwned: true),
        DecorItem(id: "chair_01", name: "Comfy Chair", price: 12, roomType: .living, isOwned: false),
        DecorItem(id: "couch_01", name: "Cozy Couch", price: 25, roomType: .living, isOwned: true),
        DecorItem(id: "lamp_01", name: "Warm Lamp", price: 8, roomType: .living, isOwned: false),
        DecorItem(id: "shelf_01", name: "Wall Shelf", price: 10, roomType: .living, isOwned: false),
        DecorItem(id: "table_01", name: "Side Table", price: 14, roomType: .living, isOwned: false)
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

