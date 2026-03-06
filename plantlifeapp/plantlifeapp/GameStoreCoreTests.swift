import SwiftData
import Testing
@testable import plantlifeapp

final class PlantLifeAppTests: TestCase {
    var container: ModelContainer!

    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainer(for: [Plant.self, Decor.self, Placement.self], inMemory: true)
    }

    override func tearDown() async throws {
        container = nil
        try await super.tearDown()
    }

    func testPlantPlacementSwapping() throws {
        let context = container.mainContext

        let plantA = Plant(name: "PlantA")
        let plantB = Plant(name: "PlantB")
        let placement1 = Placement(position: CGPoint(x: 10, y: 20), plant: plantA)
        let placement2 = Placement(position: CGPoint(x: 30, y: 40), plant: plantB)

        try context.insert(plantA)
        try context.insert(plantB)
        try context.insert(placement1)
        try context.insert(placement2)
        try context.save()

        // Swap plants between placements
        let tempPlant = placement1.plant
        placement1.plant = placement2.plant
        placement2.plant = tempPlant

        try context.save()

        XCTAssertEqual(placement1.plant.name, "PlantB", "Placement1 should now have PlantB")
        XCTAssertEqual(placement2.plant.name, "PlantA", "Placement2 should now have PlantA")
    }

    func testOfflineProgressCoinAccrual() throws {
        let context = container.mainContext

        let user = User(coins: 0, lastActiveDate: Date().addingTimeInterval(-3600 * 5)) // 5 hours ago
        try context.insert(user)
        try context.save()

        let now = Date()
        let elapsedHours = now.timeIntervalSince(user.lastActiveDate) / 3600
        let coinsPerHour = 10
        let expectedCoins = Int(elapsedHours) * coinsPerHour

        // Simulate offline coin accrual on app launch
        user.accrueOfflineCoins(coinsPerHour: coinsPerHour, currentDate: now)

        try context.save()

        XCTAssertEqual(user.coins, expectedCoins, "User should have accrued correct coins for offline progress")
        XCTAssertEqual(user.lastActiveDate.timeIntervalSince(now).magnitude < 1, true, "User lastActiveDate should be updated to current time")
    }

    func testDecorOnePerCategoryEnforcement() throws {
        let context = container.mainContext

        let decor1 = Decor(id: UUID(), category: "Fountain")
        let decor2 = Decor(id: UUID(), category: "Fountain")
        let decor3 = Decor(id: UUID(), category: "Statue")

        try context.insert(decor1)
        try context.insert(decor3)
        try context.save()

        // Attempt to add a decor of an existing category
        func addDecor(_ decor: Decor) throws {
            let existing = context.fetch(Decor.self).first(where: { $0.category == decor.category })
            if existing != nil {
                throw DecorError.duplicateCategory
            }
            try context.insert(decor)
            try context.save()
        }

        XCTAssertThrowsError(try addDecor(decor2)) { error in
            XCTAssertEqual(error as? DecorError, DecorError.duplicateCategory, "Should not allow duplicate decor category")
        }

        // Adding decor of new category should succeed
        let decor4 = Decor(id: UUID(), category: "Bench")
        XCTAssertNoThrow(try addDecor(decor4))
    }
}

// MARK: - Test Models and Extensions

@Model
final class Plant {
    @Attribute(.unique) var id = UUID()
    var name: String

    init(name: String) {
        self.name = name
    }
}

@Model
final class Placement {
    @Attribute(.unique) var id = UUID()
    var position: CGPoint
    var plant: Plant

    init(position: CGPoint, plant: Plant) {
        self.position = position
        self.plant = plant
    }
}

@Model
final class Decor {
    @Attribute(.unique) var id: UUID
    var category: String

    init(id: UUID, category: String) {
        self.id = id
        self.category = category
    }
}

@Model
final class User {
    @Attribute(.unique) var id = UUID()
    var coins: Int
    var lastActiveDate: Date

    init(coins: Int, lastActiveDate: Date) {
        self.coins = coins
        self.lastActiveDate = lastActiveDate
    }

    func accrueOfflineCoins(coinsPerHour: Int, currentDate: Date) {
        let elapsedHours = Int(currentDate.timeIntervalSince(lastActiveDate) / 3600)
        guard elapsedHours > 0 else { return }
        coins += elapsedHours * coinsPerHour
        lastActiveDate = currentDate
    }
}

enum DecorError: Error, Equatable {
    case duplicateCategory
}
