//
//  Plant.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import Foundation
import SwiftData

@Model
final class Plant {
    var name: String
    var coinsPerMinute: Double

    init(name: String, coinsPerMinute: Double) {
        self.name = name
        self.coinsPerMinute = coinsPerMinute
    }
}
