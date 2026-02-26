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
    // Global balance knob to slow down coin generation
    private let coinGenerationNerf: Double = 0.25 // 25% of previous rate

    private var timer: Timer?
    private let tickInterval: TimeInterval = 1.0

    // Stored context so the timer closure does not capture ModelContext directly.
    private var ctx: ModelContext?

    // Safety cap so a bad timestamp can't generate absurd amounts of coins.
    private let maxOfflineSeconds: TimeInterval = 24 * 60 * 60


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
              let player = fetchPlayer(modelContext) else { return }

        clampPlayerCoinsIfNeeded(player)

        // Fetch room and plants
        let rooms = (try? modelContext.fetch(FetchDescriptor<RoomState>())) ?? []
        let room = rooms.first
        let allPlants = (try? modelContext.fetch(FetchDescriptor<Plant>())) ?? []

        // Determine placed plants by location (no two plants share a location)
        let placedPlants = allPlants.filter { $0.isOwned && $0.location != nil }

        var totalCoinsPerSecond: Double = 0
        for plant in placedPlants {
            _ = plant.applyAutoGrowth(now: now)
            totalCoinsPerSecond += (plant.coinsPerMinute / 60.0)
        }
        totalCoinsPerSecond *= coinGenerationNerf

        if totalCoinsPerSecond.isFinite, totalCoinsPerSecond > 0 {
            player.coinBank += totalCoinsPerSecond
        }

        cashOutCoinBankSafely(player: player)

        player.lastActiveAt = now
        try? modelContext.save()
    }

    func applyOfflineProgress(now: Date = .now) {
        guard let modelContext = ctx,
              let player = fetchPlayer(modelContext) else { return }

        clampPlayerCoinsIfNeeded(player)

        let start = player.lastActiveAt
        guard now > start else { return }

        var elapsed = now.timeIntervalSince(start)
        if elapsed > maxOfflineSeconds { elapsed = maxOfflineSeconds }
        if !elapsed.isFinite || elapsed < 0 { elapsed = 0 }

        // Fetch room and plants
        let rooms = (try? modelContext.fetch(FetchDescriptor<RoomState>())) ?? []
        let room = rooms.first
        let allPlants = (try? modelContext.fetch(FetchDescriptor<Plant>())) ?? []

        // Determine placed plants by location (no two plants share a location)
        let placedPlants = allPlants.filter { $0.isOwned && $0.location != nil }

        var totalCoinsPerSecond: Double = 0
        for plant in placedPlants {
            _ = plant.applyAutoGrowth(now: now)
            totalCoinsPerSecond += (plant.coinsPerMinute / 60.0)
        }
        totalCoinsPerSecond *= coinGenerationNerf

        if totalCoinsPerSecond.isFinite, totalCoinsPerSecond > 0, elapsed > 0 {
            player.coinBank += elapsed * totalCoinsPerSecond
        }

        cashOutCoinBankSafely(player: player)

        player.lastActiveAt = now
        try? modelContext.save()
    }

    private func clampPlayerCoinsIfNeeded(_ player: PlayerState) {
        // If something ever put coins out of range, clamp it.
        if player.coins < 0 { player.coins = 0 }
        // Int can't exceed Int.max in memory, but leaving this here for clarity.
    }

    private func addCoinsClamped(_ amount: Int, to player: PlayerState) {
        guard amount > 0 else { return }
        let headroom = Int.max - player.coins
        if headroom <= 0 {
            player.coins = Int.max
            return
        }
        player.coins += min(amount, headroom)
    }

    private func cashOutCoinBankSafely(player: PlayerState) {
        if !player.coinBank.isFinite || player.coinBank < 0 {
            player.coinBank = 0
            return
        }

        let wholeDouble = floor(player.coinBank)
        if wholeDouble < 1 { return }

        // Convert to an Int amount without overflowing
        let headroom = Int.max - player.coins
        if headroom <= 0 {
            player.coins = Int.max
            player.coinBank = 0
            return
        }

        let wholeToAddDouble = min(wholeDouble, Double(headroom))
        if wholeToAddDouble < 1 { return }

        let wholeToAdd = Int(wholeToAddDouble) // <= headroom, safe
        addCoinsClamped(wholeToAdd, to: player)
        player.coinBank -= Double(wholeToAdd)

        if player.coinBank < 0 { player.coinBank = 0 }
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

        let rooms = (try? modelContext.fetch(FetchDescriptor<RoomState>())) ?? []
        for room in rooms {
            var placed = room.placedItemIDs
            if let idx = placed.firstIndex(of: item.id) {
                placed.remove(at: idx)
                room.placedItemIDs = placed
            }
        }

        item.isOwned = false
        addCoinsClamped(item.price, to: player)

        try? modelContext.save()
        return true
    }

    func togglePlace(item: DecorItem, in room: RoomState, modelContext: ModelContext) {
        ctx = modelContext

        guard item.isOwned else { return }

        var placed = room.placedItemIDs

        // If already placed, remove it
        if let idx = placed.firstIndex(of: item.id) {
            placed.remove(at: idx)
        } else {
            // Enforce only one chair and one couch in the living room
            if item.category == .chair {
                // Remove any other placed chair
                placed.removeAll { placedID in
                    if let other = try? modelContext.fetch(FetchDescriptor<DecorItem>(predicate: #Predicate { $0.id == placedID })).first {
                        return other.category == .chair
                    }
                    return false
                }
            } else if item.category == .couch {
                // Remove any other placed couch
                placed.removeAll { placedID in
                    if let other = try? modelContext.fetch(FetchDescriptor<DecorItem>(predicate: #Predicate { $0.id == placedID })).first {
                        return other.category == .couch
                    }
                    return false
                }
            }
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

        try? modelContext.save()
        return true
    }

    func sellPlant(plant: Plant, modelContext: ModelContext) -> Bool {
        ctx = modelContext
        guard let player = fetchPlayer(modelContext) else { return false }
        guard plant.isOwned else { return false }

        plant.isOwned = false
        addCoinsClamped(plant.purchasePrice, to: player)

        try? modelContext.save()
        return true
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
}

