#if canImport(XCTest)
import XCTest
import SwiftData
@testable import plantlifeapp

final class GameStoreCoreTests: XCTestCase {

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

    @MainActor
    func testPlantPlacementSwapsExistingOccupant() throws {
        let ctx = try makeInMemoryContext()
        let store = GameStore()

        // Seed plants
        let a = Plant(id: "plant_a", name: "A", isOwned: true, purchasePrice: 0, level: 1, baseCoinsPerMinute: 1.0)
        let b = Plant(id: "plant_b", name: "B", isOwned: true, purchasePrice: 0, level: 1, baseCoinsPerMinute: 1.0)
        ctx.insert(a)
        ctx.insert(b)
        try ctx.save()

        // Place A at floor
        XCTAssertTrue(store.place(plant: a, at: .floor, modelContext: ctx))
        XCTAssertEqual(a.location, .floor)

        // Place B at same location; A should be unplaced
        XCTAssertTrue(store.place(plant: b, at: .floor, modelContext: ctx))
        XCTAssertEqual(b.location, .floor)
        XCTAssertNil(a.location)
    }

    @MainActor
    func testOfflineProgressAccrualCashesOut() throws {
        let ctx = try makeInMemoryContext()
        let store = GameStore()

        // Player last active 10 minutes ago
        let tenMinutes: TimeInterval = 600
        let start = Date().addingTimeInterval(-tenMinutes)
        let player = PlayerState(coins: 0, coinBank: 0, lastActiveAt: start)
        ctx.insert(player)

        // One owned, placed plant producing 6 coins/min (0.1/sec), nerfed to 25% => 0.025/sec
        // Over 600s => 15 coins
        let plant = Plant(id: "plant_pothos", name: "Pothos", isOwned: true, purchasePrice: 0, level: 1, baseCoinsPerMinute: 6.0)
        plant.location = .bookshelf1
        ctx.insert(plant)

        // Also need a room record to mirror app environment
        let room = RoomState(roomType: .living)
        ctx.insert(room)
        try ctx.save()

        // Starting the store applies offline progress once
        store.start(modelContext: ctx)
        store.stop(modelContext: ctx)

        XCTAssertGreaterThanOrEqual(player.coins, 15)
    }

    @MainActor
    func testDecorOnePerCategory() throws {
        let ctx = try makeInMemoryContext()
        let store = GameStore()

        let room = RoomState(roomType: .living)
        let chair1 = DecorItem(id: "chair_01", name: "Comfy Chair", price: 10, roomType: .living, isOwned: true, category: .chair)
        let chair2 = DecorItem(id: "chair_02", name: "Modern Chair", price: 12, roomType: .living, isOwned: true, category: .chair)

        ctx.insert(room)
        ctx.insert(chair1)
        ctx.insert(chair2)
        try ctx.save()

        // Place first chair
        store.togglePlace(item: chair1, in: room, modelContext: ctx)
        XCTAssertTrue(room.placedItemIDs.contains(chair1.id))

        // Place second chair; first should be removed
        store.togglePlace(item: chair2, in: room, modelContext: ctx)
        XCTAssertTrue(room.placedItemIDs.contains(chair2.id))
        XCTAssertFalse(room.placedItemIDs.contains(chair1.id))
    }
}
#endif

