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

    func start(modelContext: ModelContext) {
        // apply offline earnings once on start
        applyOfflineEarnings(modelContext: modelContext)

        // start live ticking
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick(modelContext: modelContext)
            }
        }
    }

    func stop(modelContext: ModelContext) {
        timer?.invalidate()
        timer = nil
        updateLastActive(modelContext: modelContext)
    }

    private func tick(modelContext: ModelContext) {
        guard let player = fetchPlayer(modelContext),
              let plant = fetchPlant(modelContext) else { return }

        // coinsPerMinute -> coins per second
        let coinsPerSecond = plant.coinsPerMinute / 60.0
        // accumulate with rounding — MVP uses integer coins
        player.coins += Int(coinsPerSecond.rounded(.toNearestOrAwayFromZero))
        player.lastActiveAt = .now
        try? modelContext.save()
    }

    func applyOfflineEarnings(modelContext: ModelContext) {
        guard let player = fetchPlayer(modelContext),
              let plant = fetchPlant(modelContext) else { return }

        let now = Date()
        let elapsed = now.timeIntervalSince(player.lastActiveAt)
        if elapsed <= 0 { return }

        let coinsPerSecond = plant.coinsPerMinute / 60.0
        let earned = Int((elapsed * coinsPerSecond).rounded(.down))

        if earned > 0 {
            player.coins += earned
        }
        player.lastActiveAt = now
        try? modelContext.save()
    }

    func buy(item: DecorItem, modelContext: ModelContext) -> Bool {
        guard let player = fetchPlayer(modelContext) else { return false }
        guard !item.isOwned else { return true }
        guard player.coins >= item.price else { return false }

        player.coins -= item.price
        item.isOwned = true
        try? modelContext.save()
        return true
    }

    func togglePlace(item: DecorItem, in room: RoomState, modelContext: ModelContext) {
        guard item.isOwned else { return }
        room.togglePlaced(item.id)
        try? modelContext.save()
    }

    private func updateLastActive(modelContext: ModelContext) {
        guard let player = fetchPlayer(modelContext) else { return }
        player.lastActiveAt = .now
        try? modelContext.save()
    }

    // MARK: - Fetch helpers

    private func fetchPlayer(_ modelContext: ModelContext) -> PlayerState? {
        let descriptor = FetchDescriptor<PlayerState>()
        return (try? modelContext.fetch(descriptor))?.first
    }

    private func fetchPlant(_ modelContext: ModelContext) -> Plant? {
        let descriptor = FetchDescriptor<Plant>()
        return (try? modelContext.fetch(descriptor))?.first
    }
}
