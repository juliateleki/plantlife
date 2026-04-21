//
//  ShopView.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import SwiftUI
import SwiftData
import UIKit

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
                        plantRow(plant)
                    }
                }

                Section("Chairs") {
                    ForEach(items.filter { $0.category == .chair }) { item in
                        decorRow(item)
                    }
                }

                Section("Couches") {
                    ForEach(items.filter { $0.category == .couch }) { item in
                        decorRow(item)
                    }
                }

                Section("Other Decor") {
                    ForEach(items.filter { $0.category != .chair && $0.category != .couch }) { item in
                        decorRow(item)
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

    @ViewBuilder
    private func plantRow(_ plant: Plant) -> some View {
        HStack(spacing: 12) {
            ShopThumbnailView(
                assetName: plantAssetName(for: plant),
                fallback: plantFallback(for: plant)
            )

            VStack(alignment: .leading, spacing: 4) {
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

                    Button("Sell +\(plant.purchasePrice)") {
                        onSellPlant(plant)
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                Button("Buy \(plant.purchasePrice)") {
                    onBuyPlant(plant)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func decorRow(_ item: DecorItem) -> some View {
        HStack(spacing: 12) {
            ShopThumbnailView(
                assetName: decorAssetName(for: item),
                fallback: decorFallback(for: item)
            )

            VStack(alignment: .leading, spacing: 4) {
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

                    Button("Sell +\(item.price)") {
                        onSellDecor(item)
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                Button("Buy \(item.price)") {
                    onBuyDecor(item)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 4)
    }

    private func plantAssetName(for plant: Plant) -> String? {
        switch plant.id {
        case "plant_pothos":
            return "plant_pothos_thumb"
        case "plant_snake":
            return "plant_snake_thumb"
        case "plant_monstera":
            return "plant_monstera_thumb"
        case "plant_ficus":
            return "plant_ficus_thumb"
        case "plant_fern":
            return "plant_fern_thumb"
        default:
            return nil
        }
    }

    private func decorAssetName(for item: DecorItem) -> String? {
        switch item.id {
        case "chair_01":
            return "chair_01_thumb"
        case "couch_01":
            return "classic-couch"
        case "couch_02":
            return "modern-couch"
        case "rug_01":
            return "rug_01_thumb"
        default:
            return nil
        }
    }

    private func plantFallback(for plant: Plant) -> String {
        switch plant.id {
        case "plant_pothos":
            switch plant.level {
            case 1...3: return "🌱"
            case 4...7: return "🪴"
            case 8...14: return "🌿"
            default: return "🌳"
            }

        case "plant_monstera":
            switch plant.level {
            case 1...3: return "🌱"
            case 4...7: return "🌿"
            case 8...14: return "🌴"
            default: return "🌳"
            }

        case "plant_snake":
            switch plant.level {
            case 1...3: return "🌱"
            case 4...7: return "🌾"
            case 8...14: return "🌵"
            default: return "🌳"
            }

        case "plant_ficus":
            switch plant.level {
            case 1...3: return "🌱"
            case 4...7: return "🌿"
            case 8...14: return "🌴"
            default: return "🌳"
            }

        case "plant_fern":
            switch plant.level {
            case 1...3: return "🌱"
            case 4...7: return "🌿"
            case 8...14: return "🌾"
            default: return "🌳"
            }

        default:
            return "🪴"
        }
    }

    private func decorFallback(for item: DecorItem) -> String {
        switch item.id {
        case "chair_01":
            return "🪑"
        case "couch_01":
            return "🛋️"
        case "rug_01":
            return "🟫"
        default:
            return "📦"
        }
    }
}

private struct ShopThumbnailView: View {
    let assetName: String?
    let fallback: String

    private var hasAsset: Bool {
        guard let assetName else { return false }
        return UIImage(named: assetName) != nil
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.secondary.opacity(0.08))

            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)

            if hasAsset, let assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            } else {
                Text(fallback)
                    .font(.system(size: 28))
            }
        }
        .frame(width: 60, height: 60)
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
        DecorItem(id: "chair_01", name: "Comfy Chair", price: 12, roomType: .living, category: .chair, isOwned: false),
        DecorItem(id: "couch_01", name: "Cozy Couch", price: 25, roomType: .living, category: .couch, isOwned: false)
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
