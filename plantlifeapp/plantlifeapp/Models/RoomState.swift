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
    var isRugPlaced: Bool

    init(roomType: RoomType, isRugPlaced: Bool = false) {
        self.roomTypeRaw = roomType.rawValue
        self.isRugPlaced = isRugPlaced
    }

    var roomType: RoomType {
        get { RoomType(rawValue: roomTypeRaw) ?? .living }
        set { roomTypeRaw = newValue.rawValue }
    }
}
