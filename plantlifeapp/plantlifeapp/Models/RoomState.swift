//
//  RoomState.swift
//  plantlifeapp
//

import Foundation
import SwiftData

@Model
final class RoomState {
    var roomTypeRaw: String

    // Persist placed decor IDs as JSON Data for SwiftData stability.
    // This avoids @Attribute(.transformable) ambiguity issues with [String].
    var placedItemIDsJSON: Data

    init(roomType: RoomType, placedItemIDs: [String] = []) {
        self.roomTypeRaw = roomType.rawValue
        self.placedItemIDsJSON = (try? JSONEncoder().encode(placedItemIDs)) ?? Data()
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

    func isPlaced(_ itemID: String) -> Bool {
        placedItemIDs.contains(itemID)
    }
}
