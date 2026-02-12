//
//  GameStore.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import Foundation
import SwiftData

@MainActor
final class GameStore: ObservableObject {
    private var timer: Timer?
    private let tickInterval: TimeInterval = 1.0

    // Stored context so the timer closure does not capture ModelContext directly.
    private var ctx: ModelContext?

    func start(modelContext: ModelContext) {
        ctx = modelContext
        applyOfflineProgress(now: .now)

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.tick(now: .now)
            }
        }
    }

    func stop(modelContext: ModelContext) {
        timer?.invalidate()
        timer = nil
        ctx = modelContext
        updateLastActive(now: .now)
    }

    func tick(now: Date = .now) {
        guard let modelContext = ctx,
              let player = fetchPlayer(modelContext),
              let plant = fetchActivePlant(modelContext, player: player) else { return }

        // Auto growth while running
        _ = plant.applyAutoGrowth(now: now)

        // Earn coins
        let coinsPerSecond = plant.coinsPerMinute / 60.0
        player.coinBank += coinsPerSecond

        let whole = Int(player.coinBank)
        if whole > 0 {
            player.coins += whole
            player.coinBank -= Double(whole)
        }

        player.lastActiveAt = now
        try? modelContext.save()
    }

    func applyOfflineProgress(now: Date = .now) {
        guard let modelContext = ctx,
              let player = fetchPlayer(modelContext),
              let plant = fetchActivePlant(modelContext, player: player) else { return }

        let start = player.lastActiveAt
        if now <= start { return }

        if plant.lastGrowthAt > now {
            plant.lastGrowthAt = start
        }

        var t = start
        while t < now {
            let nextGrowth = plant.lastGrowthAt.addingTimeInterval(plant.growthSecondsPerLevel)
            let segmentEnd = min(now, nextGrowth)

            let dt = segmentEnd.timeIntervalSince(t)
            if dt > 0 {
                let cps = plant.coinsPerMinute / 60.0
                player.coinBank += dt * cps
            }

            if segmentEnd >= nextGrowth && nextGrowth <= now {
                plant.level += 1
                plant.lastGrowthAt = nextGrowth
            }

            t = segmentEnd
            if dt == 0 { break }
        }

        let whole = Int(player.coinBank)
        if whole > 0 {
            player.coins += whole
            player.coinBank -= Double(whole)
        }

        player.lastActiveAt = now
        try? modelContext.save()
    }

    func buy(item: DecorItem, modelContext: ModelContext) -> Bool {
        ctx = modelContext

        guard let player = fetchPlayer(modelContext) else { return false }
        guard !item.isOwned else { return true }
        guard player.coins >= item.price else { return false }

        player.coins -= item.price
        item.isOwned = true
        try? modelContext.save()
        return true
    }

    func sellDecor(item: DecorItem, modelContext: ModelContext) -> Bool {
        ctx = modelContext

        guard let player = fetchPlayer(modelContext) else { return false }
        guard item.isOwned else { return false }

        // Remove from any rooms where it's placed
        let rooms = (try? modelContext.fetch(FetchDescriptor<RoomState>())) ?? []
        for room in rooms {
            var placed = room.placedItemIDs
            if let idx = placed.firstIndex(of: item.id) {
                placed.remove(at: idx)
                room.placedItemIDs = placed
            }
        }

        item.isOwned = false
        player.coins += item.price

        try? modelContext.save()
        return true
    }

    func togglePlace(item: DecorItem, in room: RoomState, modelContext: ModelContext) {
        ctx = modelContext

        guard item.isOwned else { return }

        var placed = room.placedItemIDs
        if let idx = placed.firstIndex(of: item.id) {
            placed.remove(at: idx)
        } else {
            placed.append(item.id)
        }
        room.placedItemIDs = placed

        try? modelContext.save()
    }

    func buyPlant(plant: Plant, modelContext: ModelContext) -> Bool {
        ctx = modelContext
        guard let player = fetchPlayer(modelContext) else { return false }
        guard !plant.isOwned else { return true }
        guard player.coins >= plant.purchasePrice else { return false }

        player.coins -= plant.purchasePrice
        plant.isOwned = true

        if player.currentPlantID == nil {
            player.currentPlantID = plant.id
        }

        try? modelContext.save()
        return true
    }

    func sellPlant(plant: Plant, modelContext: ModelContext) -> Bool {
        ctx = modelContext
        guard let player = fetchPlayer(modelContext) else { return false }
        guard plant.isOwned else { return false }

        // Do not allow selling the active plant
        if player.currentPlantID == plant.id {
            return false
        }

        plant.isOwned = false
        player.coins += plant.purchasePrice

        try? modelContext.save()
        return true
    }

    func setActivePlant(plant: Plant, modelContext: ModelContext) {
        ctx = modelContext
        guard let player = fetchPlayer(modelContext) else { return }
        guard plant.isOwned else { return }

        player.currentPlantID = plant.id
        try? modelContext.save()
    }

    private func updateLastActive(now: Date = .now) {
        guard let modelContext = ctx,
              let player = fetchPlayer(modelContext) else { return }
        player.lastActiveAt = now
        try? modelContext.save()
    }

    private func fetchPlayer(_ modelContext: ModelContext) -> PlayerState? {
        (try? modelContext.fetch(FetchDescriptor<PlayerState>()))?.first
    }

    private func fetchActivePlant(_ modelContext: ModelContext, player: PlayerState) -> Plant? {
        let all = (try? modelContext.fetch(FetchDescriptor<Plant>())) ?? []
        if all.isEmpty { return nil }

        if let id = player.currentPlantID,
           let match = all.first(where: { $0.id == id && $0.isOwned }) {
            return match
        }

        if let firstOwned = all.first(where: { $0.isOwned }) {
            if player.currentPlantID != firstOwned.id {
                player.currentPlantID = firstOwned.id
                try? modelContext.save()
            }
            return firstOwned
        }

        return all.first
    }
}
