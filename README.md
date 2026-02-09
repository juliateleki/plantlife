---
## 💾 Data Model Overview

### PlayerState
- Tracks total coins
- Stores fractional coin bank for smooth earnings
- Records last active time for offline progress

### Plant
- Defines the coin generation rate (coins per minute)

### DecorItem
- Represents purchasable furniture and decor
- Tracks ownership status
- Associated with a room type

### RoomState
- Represents a room (currently living room)
- Tracks which decor items are placed using item IDs
---

## 🧪 Tests

The project includes unit tests that verify:

- Buying items succeeds or fails correctly based on coin count
- Placing and removing decor updates room state correctly
- Offline earnings convert elapsed time into coins accurately
- Fractional coins are preserved correctly

All tests run using an in-memory SwiftData store and do not affect real app data.

---

## 🎨 Assets & Graphics

Currently, decor items are rendered using emojis as placeholders.

The project is designed to support vector assets next. Decor graphics will be added as PDF vector assets in `Assets.xcassets` and mapped by decor ID, without requiring changes to the data model.

---

## 🚧 Roadmap Ideas

- Drag-and-drop decor placement
- Multiple rooms
- Plant upgrades and growth stages
- More decor categories
- Subtle animations and sound
- iPad layout support

---

## 🧠 Notes

This project prioritizes clarity, extensibility, and a calm development experience over over-engineering. The codebase is intentionally small and readable, making it easy to expand as new game mechanics are added.
