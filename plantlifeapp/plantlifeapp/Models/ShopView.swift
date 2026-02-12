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
    let onBuyPlant: (Plant) -> Void
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
                                if activePlantID == plant.id {
                                    Text("Active")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Button("Set Active") { onSetActivePlant(plant) }
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
                                Text("Owned")
                                    .foregroundStyle(.secondary)
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
