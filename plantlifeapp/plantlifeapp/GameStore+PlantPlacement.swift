import Foundation
import SwiftData

extension GameStore {
    /// Place a plant at a specific location, ensuring no two plants share the same location.
    /// If another plant currently occupies `location`, it will be cleared first.
    @MainActor
    @discardableResult
    func place(plant: Plant, at location: PlantLocation, modelContext: ModelContext) -> Bool {
        // Ensure we operate on main actor and with correct context
        let ctx = modelContext
        // Fetch all plants to clear conflicts
        let allPlants = (try? ctx.fetch(FetchDescriptor<Plant>())) ?? []
        for other in allPlants where other !== plant {
            if other.location == location {
                other.location = nil
            }
        }
        plant.location = location
        do {
            try ctx.save()
            return true
        } catch {
            // Revert on failure
            plant.location = nil
            return false
        }
    }

    /// Remove a plant from its current location (if any).
    @MainActor
    @discardableResult
    func removeFromLocation(plant: Plant, modelContext: ModelContext) -> Bool {
        let ctx = modelContext
        plant.location = nil
        do {
            try ctx.save()
            return true
        } catch {
            return false
        }
    }
}
