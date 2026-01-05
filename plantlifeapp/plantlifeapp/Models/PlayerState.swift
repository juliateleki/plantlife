//
//  Untitled.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import Foundation
import SwiftData

@Model
final class PlayerState {
    var coins: Int
    var lastActiveAt: Date

    init(coins: Int = 0, lastActiveAt: Date = .now) {
        self.coins = coins
        self.lastActiveAt = lastActiveAt
    }
}
