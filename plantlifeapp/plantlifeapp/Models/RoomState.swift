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
    var placedItemIDs: [String] // simple MVP: list of decor IDs placed in this room

    init(roomType: RoomType, placedItemIDs: [String] = []) {
        self.roomTypeRaw = roomType.rawValue
        self.placedItemIDs = placedItemIDs
    }

    var roomType: RoomType {
        get { RoomType(rawValue: roomTypeRaw) ?? .living }
        set { roomTypeRaw = newValue.rawValue }
    }

    func isPlaced(_ itemID: String) -> Bool {
        placedItemIDs.contains(itemID)
    }

    func togglePlaced(_ itemID: String) {
        if let idx = placedItemIDs.firstIndex(of: itemID) {
            placedItemIDs.remove(at: idx)
        } else {
            placedItemIDs.append(itemID)
        }
    }
}
