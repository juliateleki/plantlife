//
//  plantlifeappTests.swift
//  plantlifeappTests
//
//  Created by Julia Teleki on 1/5/26.
//

import Foundation
import SwiftData
import Testing
@testable import plantlifeapp

struct plantlifeappTests {

    @MainActor
    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([
            PlayerState.self,
            Plant.self,
            DecorItem.self,
            RoomState.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    @Test
    func upgradePlantSucceedsWhenEnoughCoins() async throws {
        try await MainActor.run {
            let ctx = try makeInMemoryContext()
            let store = GameStore()

            let player = PlayerState(coins: 50, coinBank: 0, lastActiveAt: .now)
            let plant = Plant(name: "Pothos", baseCoinsPerMinute: 6, rateGrowth: 1.10, upgradeBaseCost: 10, upgradeGrowth: 1.20)

            ctx.insert(player)
            ctx.insert(plant)
            try ctx.save()

            let ok = store.upgradePlant(modelContext: ctx)

            #expect(ok == true)
            #expect(plant.level == 2)
            #expect(player.coins == 40)
        }
    }

    @Test
    func upgradePlantFailsWhenNotEnoughCoins() async throws {
        try await MainActor.run {
            let ctx = try makeInMemoryContext()
            let store = GameStore()

            let player = PlayerState(coins: 5, coinBank: 0, lastActiveAt: .now)
            let plant = Plant(name: "Pothos", baseCoinsPerMinute: 6, rateGrowth: 1.10, upgradeBaseCost: 10, upgradeGrowth: 1.20)

            ctx.insert(player)
            ctx.insert(plant)
            try ctx.save()

            let ok = store.upgradePlant(modelContext: ctx)

            #expect(ok == false)
            #expect(plant.level == 1)
            #expect(player.coins == 5)
        }
    }
}
