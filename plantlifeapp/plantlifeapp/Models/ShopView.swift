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
    let activePlantID: String?

    let onBuyDecor: (DecorItem) -> Void
    let onSellDecor: (DecorItem) -> Void

    let onBuyPlant: (Plant) -> Void
    let onSellPlant: (Plant) -> Void
    let onSetActivePlant: (Plant) -> Void

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
                                    if activePlantID == plant.id {
                                        Text("Active")
                                            .foregroundStyle(.secondary)
                                        Button("Sell") { onSellPlant(plant) }
                                            .disabled(true)
                                    } else {
                                        Button("Set Active") { onSetActivePlant(plant) }
                                        Button("Sell +\(plant.purchasePrice)") { onSellPlant(plant) }
                                    }
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
