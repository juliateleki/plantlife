//
//  Plant.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import Foundation
import SwiftData

@Model
final class Plant {
    var name: String

    // Progression
    var level: Int

    // Base rate at level 1
    var baseCoinsPerMinute: Double

    // Rate growth per level (multiplicative)
    var rateGrowth: Double

    // Upgrade economy
    var upgradeBaseCost: Int
    var upgradeGrowth: Double

    init(
        name: String,
        level: Int = 1,
        baseCoinsPerMinute: Double,
        rateGrowth: Double = 1.15,
        upgradeBaseCost: Int = 10,
        upgradeGrowth: Double = 1.35
    ) {
        self.name = name
        self.level = max(1, level)
        self.baseCoinsPerMinute = baseCoinsPerMinute
        self.rateGrowth = rateGrowth
        self.upgradeBaseCost = upgradeBaseCost
        self.upgradeGrowth = upgradeGrowth
    }

    var coinsPerMinute: Double {
        let exponent = Double(max(0, level - 1))
        return baseCoinsPerMinute * pow(rateGrowth, exponent)
    }

    var nextUpgradeCost: Int {
        let exponent = Double(max(0, level - 1))
        let raw = Double(upgradeBaseCost) * pow(upgradeGrowth, exponent)
        return max(1, Int(raw.rounded(.up)))
    }

    var growthStageLabel: String {
        switch level {
        case 1...3: return "Sprout"
        case 4...7: return "Baby"
        case 8...14: return "Growing"
        default: return "Blooming"
        }
    }
}
