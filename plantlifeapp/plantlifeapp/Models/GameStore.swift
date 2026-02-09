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

    // Store the context to avoid capturing a non-Sendable ModelContext in the Timer closure.
    private var ctx: ModelContext?

    func start(modelContext: ModelContext) {
        ctx = modelContext
        applyOfflineEarnings(now: .now)

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

    // Exposed for tests (deterministic with injected time).
    func tick(now: Date = .now) {
        guard let modelContext = ctx,
              let player = fetchPlayer(modelContext),
              let plant = fetchPlant(modelContext) else { return }

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

    // Exposed for tests (deterministic with injected time).
    func applyOfflineEarnings(now: Date = .now) {
        guard let modelContext = ctx,
              let player = fetchPlayer(modelContext),
              let plant = fetchPlant(modelContext) else { return }

        let elapsed = now.timeIntervalSince(player.lastActiveAt)
        if elapsed <= 0 { return }

        let coinsPerSecond = plant.coinsPerMinute / 60.0
        player.coinBank += elapsed * coinsPerSecond

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

    func togglePlace(item: DecorItem, in room: RoomState, modelContext: ModelContext) {
        ctx = modelContext

        guard item.isOwned else { return }

        if let idx = room.placedItemIDs.firstIndex(of: item.id) {
            room.placedItemIDs.remove(at: idx)
        } else {
            room.placedItemIDs.append(item.id)
        }

        do {
            try modelContext.save()
        } catch {
            print("❌ Save failed in togglePlace:", error)
        }
    }

    private func updateLastActive(now: Date = .now) {
        guard let modelContext = ctx,
              let player = fetchPlayer(modelContext) else { return }
        player.lastActiveAt = now
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
