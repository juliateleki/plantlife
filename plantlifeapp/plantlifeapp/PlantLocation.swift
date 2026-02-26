import Foundation

/// Discrete, named locations in the room where a plant can be placed.
/// Use these to ensure no two plants occupy the same spot.
enum PlantLocation: String, Codable, Sendable {
    // Bookshelf spots
    case bookshelf1
    case bookshelf2
    case bookshelf3
    case bookshelf4
    case bookshelf5
    case bookshelf6
    case bookshelf7
    case bookshelf8

    // Floor spot
    case floor

    // Hanging plants
    case hanging1
    case hanging2

    // Plant stand
    case plantStand

    /// Stable identifier for use in Lists and pickers
    var id: String { rawValue }

    /// Human-readable title for UI
    var title: String {
        switch self {
        case .bookshelf1: return "Bookshelf 1"
        case .bookshelf2: return "Bookshelf 2"
        case .bookshelf3: return "Bookshelf 3"
        case .bookshelf4: return "Bookshelf 4"
        case .bookshelf5: return "Bookshelf 5"
        case .bookshelf6: return "Bookshelf 6"
        case .bookshelf7: return "Bookshelf 7"
        case .bookshelf8: return "Bookshelf 8"
        case .floor: return "Floor"
        case .hanging1: return "Hanging 1"
        case .hanging2: return "Hanging 2"
        case .plantStand: return "Plant Stand"
        }
    }

    /// Explicit ordering for UI; avoids relying on CaseIterable
    static let all: [PlantLocation] = [
        .bookshelf1, .bookshelf2, .bookshelf3, .bookshelf4,
        .bookshelf5, .bookshelf6, .bookshelf7, .bookshelf8,
        .floor,
        .hanging1, .hanging2,
        .plantStand
    ]
}
