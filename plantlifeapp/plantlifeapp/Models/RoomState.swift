//
//  RoomState.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import Foundation
import SwiftData

@Model
final class RoomState {
    var roomTypeRaw: String

    // Persist placed decor IDs as JSON Data for SwiftData stability.
    // This avoids @Attribute(.transformable) ambiguity issues with [String].
    var placedItemIDsJSON: Data

    // Persist placed plant IDs as JSON Data similar to decor.
    var placedPlantIDsJSON: Data

    init(roomType: RoomType, placedItemIDs: [String] = [], placedPlantIDs: [String] = []) {
        self.roomTypeRaw = roomType.rawValue
        self.placedItemIDsJSON = (try? JSONEncoder().encode(placedItemIDs)) ?? Data()
        self.placedPlantIDsJSON = (try? JSONEncoder().encode(placedPlantIDs)) ?? Data()
    }

    var roomType: RoomType {
        get { RoomType(rawValue: roomTypeRaw) ?? .living }
        set { roomTypeRaw = newValue.rawValue }
    }

    // The rest of the app uses this. It looks like a normal [String],
    // but it persists as JSON Data under the hood.
    var placedItemIDs: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: placedItemIDsJSON)) ?? []
        }
        set {
            placedItemIDsJSON = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    var placedPlantIDs: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: placedPlantIDsJSON)) ?? []
        }
        set {
            placedPlantIDsJSON = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    func isPlaced(_ itemID: String) -> Bool {
        placedItemIDs.contains(itemID)
    }

    func isPlantPlaced(_ plantID: String) -> Bool {
        placedPlantIDs.contains(plantID)
    }
}
