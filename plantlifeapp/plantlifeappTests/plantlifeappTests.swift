//
//  plantlifeappTests.swift
//  plantlifeappTests
//
//  Created by Julia Teleki on 8/19/25.
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
    func buySucceedsWhenEnoughCoins() async throws {
        try await MainActor.run {
            let ctx = try makeInMemoryContext()
            let store = GameStore()

            let player = PlayerState(coins: 20, coinBank: 0, lastActiveAt: .now)
            let plant = Plant(name: "Pothos", coinsPerMinute: 6)
            let item = DecorItem(id: "chair_01", name: "Comfy Chair", price: 12, roomType: .living)

            ctx.insert(player)
            ctx.insert(plant)
            ctx.insert(item)
            try ctx.save()

            let ok = store.buy(item: item, modelContext: ctx)

            #expect(ok == true)
            #expect(item.isOwned == true)
            #expect(player.coins == 8)
        }
    }

    @Test
    func buyFailsWhenNotEnoughCoins() async throws {
        try await MainActor.run {
            let ctx = try makeInMemoryContext()
            let store = GameStore()

            let player = PlayerState(coins: 5, coinBank: 0, lastActiveAt: .now)
            let plant = Plant(name: "Pothos", coinsPerMinute: 6)
            let item = DecorItem(id: "couch_01", name: "Cozy Couch", price: 25, roomType: .living)

            ctx.insert(player)
            ctx.insert(plant)
            ctx.insert(item)
            try ctx.save()

            let ok = store.buy(item: item, modelContext: ctx)

            #expect(ok == false)
            #expect(item.isOwned == false)
            #expect(player.coins == 5)
        }
    }

    @Test
    func togglePlaceAddsAndRemovesItemID() async throws {
        try await MainActor.run {
            let ctx = try makeInMemoryContext()
            let store = GameStore()

            let player = PlayerState(coins: 100, coinBank: 0, lastActiveAt: .now)
            let plant = Plant(name: "Pothos", coinsPerMinute: 6)
            let room = RoomState(roomType: .living)

            let item = DecorItem(id: "rug_01", name: "Cozy Rug", price: 5, roomType: .living, isOwned: true)

            ctx.insert(player)
            ctx.insert(plant)
            ctx.insert(room)
            ctx.insert(item)
            try ctx.save()

            #expect(room.placedItemIDs.contains(item.id) == false)

            store.togglePlace(item: item, in: room, modelContext: ctx)
            #expect(room.placedItemIDs.contains(item.id) == true)

            store.togglePlace(item: item, in: room, modelContext: ctx)
            #expect(room.placedItemIDs.contains(item.id) == false)
        }
    }

    @Test
    func togglePlaceDoesNothingIfNotOwned() async throws {
        try await MainActor.run {
            let ctx = try makeInMemoryContext()
            let store = GameStore()

            let player = PlayerState(coins: 0, coinBank: 0, lastActiveAt: .now)
            let plant = Plant(name: "Pothos", coinsPerMinute: 6)
            let room = RoomState(roomType: .living)

            let item = DecorItem(id: "chair_01", name: "Comfy Chair", price: 12, roomType: .living, isOwned: false)

            ctx.insert(player)
            ctx.insert(plant)
            ctx.insert(room)
            ctx.insert(item)
            try ctx.save()

            store.togglePlace(item: item, in: room, modelContext: ctx)
            #expect(room.placedItemIDs.isEmpty == true)
        }
    }

    @Test
    func offlineEarningsConvertsWholeCoinsAndKeepsRemainder() async throws {
        try await MainActor.run {
            let ctx = try makeInMemoryContext()
            let store = GameStore()

            let plant = Plant(name: "Pothos", coinsPerMinute: 6)

            let now = Date()
            let player = PlayerState(coins: 0, coinBank: 0, lastActiveAt: now.addingTimeInterval(-25))

            ctx.insert(player)
            ctx.insert(plant)
            try ctx.save()

            store.start(modelContext: ctx)
            store.applyOfflineEarnings(now: now)

            #expect(player.coins == 2)
            #expect(abs(player.coinBank - 0.5) < 0.0001)
        }
    }
}
