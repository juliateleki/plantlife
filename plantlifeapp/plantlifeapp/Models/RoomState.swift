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

    // Persist as JSON Data to avoid SwiftData transformable ambiguity on [String].
    var placedItemIDsJSON: Data

    init(roomType: RoomType, placedItemIDs: [String] = []) {
        self.roomTypeRaw = roomType.rawValue
        self.placedItemIDsJSON = (try? JSONEncoder().encode(placedItemIDs)) ?? Data()
    }

    var roomType: RoomType {
        get { RoomType(rawValue: roomTypeRaw) ?? .living }
        set { roomTypeRaw = newValue.rawValue }
    }

    // Public API used by the rest of the app.
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
