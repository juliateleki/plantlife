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
    // Stable ID so we can buy/select plants reliably
    var id: String

    var name: String
    
    var locationRaw: String?
    var location: PlantLocation? {
        get { locationRaw.flatMap { PlantLocation(rawValue: $0) } }
        set { locationRaw = newValue?.rawValue }
    }

    // Ownership and shop price
    var isOwned: Bool
    var purchasePrice: Int

    // Progression
    var level: Int

    // Base rate at level 1
    var baseCoinsPerMinute: Double

    // Rate growth per level (multiplicative)
    var rateGrowth: Double

    // Auto growth pacing
    var growthSecondsPerLevel: Double
    var lastGrowthAt: Date

    init(
        id: String,
        name: String,
        isOwned: Bool = false,
        purchasePrice: Int,
        level: Int = 1,
        baseCoinsPerMinute: Double,
        rateGrowth: Double = 1.15,
        growthSecondsPerLevel: Double = 120,
        lastGrowthAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.isOwned = isOwned
        self.purchasePrice = purchasePrice
        self.level = max(1, level)
        self.baseCoinsPerMinute = baseCoinsPerMinute
        self.rateGrowth = rateGrowth
        self.growthSecondsPerLevel = max(5, growthSecondsPerLevel)
        self.lastGrowthAt = lastGrowthAt
    }

    var coinsPerMinute: Double {
        let lvl = Double(max(1, level))

        // Very gentle scaling
        let raw = baseCoinsPerMinute * pow(lvl, 1.05)

        // Hard cap to keep gameplay slow and readable
        return min(raw, 12.0)
    }


    var growthStageLabel: String {
        switch level {
        case 1...3: return "Sprout"
        case 4...7: return "Baby"
        case 8...14: return "Growing"
        default: return "Blooming"
        }
    }

    var nextGrowthAt: Date {
        lastGrowthAt.addingTimeInterval(growthSecondsPerLevel)
    }

  func applyAutoGrowth(now: Date) -> Int {
      guard now > lastGrowthAt else { return 0 }

      let elapsed = now.timeIntervalSince(lastGrowthAt)
      if elapsed < growthSecondsPerLevel { return 0 }

      let rawLevels = Int(elapsed / growthSecondsPerLevel)

      // Prevent huge jumps due to bad timestamps or long absences
      let levels = min(rawLevels, 20)

      level += levels
      lastGrowthAt = lastGrowthAt.addingTimeInterval(Double(levels) * growthSecondsPerLevel)
      return levels
  }

}
