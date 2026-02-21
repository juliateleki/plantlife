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

enum DecorCategory: String, Codable {
    case chair
    case couch
    case rug
    case other
}

@Model
final class DecorItem {
    var id: String
    var name: String
    var price: Int
    var roomTypeRaw: String
    var categoryRaw: String
    var isOwned: Bool

    init(id: String, name: String, price: Int, roomType: RoomType, category: DecorCategory = .other, isOwned: Bool = false) {
        self.id = id
        self.name = name
        self.price = price
        self.roomTypeRaw = roomType.rawValue
        self.categoryRaw = category.rawValue
        self.isOwned = isOwned
    }

    var roomType: RoomType {
        get { RoomType(rawValue: roomTypeRaw) ?? .living }
        set { roomTypeRaw = newValue.rawValue }
    }
    
    var category: DecorCategory {
        get { DecorCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}
