# 🌱 PlantLife

PlantLife is a cozy, idle gardening game built with SwiftUI and SwiftData. You grow plants, earn coins over time (even while the app is closed), and decorate your room with furniture and decor items.

The game focuses on calm progression, offline earnings, and incremental customization. Think _idle game meets interior decorating_, built natively for iOS.

---

## 🎮 Gameplay Overview

You start with a single plant that generates coins over time.

Coins are earned:

- Every second while the app is open
- Retroactively when the app is reopened (offline earnings)

You can spend coins in the shop to buy decor items like rugs, chairs, and couches. Owned items can be placed or removed from your room at any time.

At the moment, decor placement is binary (placed or not placed). Future versions will support positioning, multiple rooms, and upgrades.

---

## 🕹️ How to Play

1. Launch the app
2. Watch your plant generate coins over time
3. Open the shop and buy decor items when you can afford them
4. Place owned items in your room
5. Close the app and come back later to collect offline earnings

That’s it. The loop is intentionally simple.

---

## 🧱 Tech Stack

### Frontend

- SwiftUI
- Native iOS views
- State-driven UI

### Persistence

- SwiftData
- Local on-device storage
- In-memory SwiftData for tests

### Architecture

- ObservableObject game store
- SwiftData models as the source of truth
- Simple idle game loop driven by a timer

### Testing

- Swift Testing framework
- Unit tests for economy, purchases, placement, and offline earnings

plantlifeapp/
├─ plantlifeApp.swift # App entry point & seeding
├─ ContentView.swift # Main screen
├─ Models/
│ ├─ PlayerState.swift # Coins, offline tracking
│ ├─ Plant.swift # Coin generation rate
│ ├─ DecorItem.swift # Shop items
│ ├─ RoomState.swift # Room & placed decor
│ ├─ GameStore.swift # Game loop & economy logic
│ ├─ RoomView.swift # Room UI
│ └─ ShopView.swift # Shop UI
├─ Assets.xcassets # App icons & future decor assets
├─ plantlifeappTests/ # SwiftData unit tests

---

## 🗂️ Project Structure

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
