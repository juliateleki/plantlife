//
//  DecorItem.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import Foundation
import SwiftData

enum RoomType: String, Codable {
    case living
}

@Model
final class DecorItem {
    var id: String
    var name: String
    var price: Int
    var roomTypeRaw: String
    var isOwned: Bool

    init(id: String, name: String, price: Int, roomType: RoomType, isOwned: Bool = false) {
        self.id = id
        self.name = name
        self.price = price
        self.roomTypeRaw = roomType.rawValue
        self.isOwned = isOwned
    }

    var roomType: RoomType {
        get { RoomType(rawValue: roomTypeRaw) ?? .living }
        set { roomTypeRaw = newValue.rawValue }
    }
}
