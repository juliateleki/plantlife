//
//  ContentView.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import SwiftUI
import SwiftData

private func abbreviated(_ value: Int) -> String {
    let num = Double(value)
    let thousand = 1_000.0
    let million = 1_000_000.0
    let billion = 1_000_000_000.0

    switch num {
    case 0..<thousand:
        return String(Int(num))
    case thousand..<million:
        return String(format: "%.1fK", num / thousand)
    case million..<billion:
        return String(format: "%.1fM", num / million)
    default:
        return String(format: "%.1fB", num / billion)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var players: [PlayerState]
    @Query private var plants: [Plant]
    @Query private var rooms: [RoomState]
    @Query private var items: [DecorItem]

    @StateObject private var gameStore = GameStore()
    @State private var isShowingMenu = false

    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0

    private let minZoom: CGFloat = 0.6
    private let maxZoom: CGFloat = 3.0

    private func resetData() {
        do {
            let players = try modelContext.fetch(FetchDescriptor<PlayerState>())
            for p in players { modelContext.delete(p) }

            let plants = try modelContext.fetch(FetchDescriptor<Plant>())
            for pl in plants { modelContext.delete(pl) }

            let rooms = try modelContext.fetch(FetchDescriptor<RoomState>())
            for r in rooms { modelContext.delete(r) }

            let items = try modelContext.fetch(FetchDescriptor<DecorItem>())
            for it in items { modelContext.delete(it) }

            try modelContext.save()
            seedData()
        } catch {
            print("❌ Reset failed:", error)
        }
    }

    private func seedData() {
        modelContext.insert(
            PlayerState(
                coins: 100,
                coinBank: 0,
                lastActiveAt: .now
            )
        )

        modelContext.insert(
            Plant(
                id: "plant_pothos",
                name: "Pothos",
                isOwned: true,
                purchasePrice: 20,
                level: 1,
                baseCoinsPerMinute: 0.1,
                rateGrowth: 1.0,
                growthSecondsPerLevel: 1800,
                lastGrowthAt: .now
            )
        )

        modelContext.insert(
            Plant(
                id: "plant_snake",
                name: "Snake Plant",
                isOwned: true,
                purchasePrice: 20,
                level: 1,
                baseCoinsPerMinute: 0.05,
                rateGrowth: 1.0,
                growthSecondsPerLevel: 1800,
                lastGrowthAt: .now
            )
        )

        modelContext.insert(
            Plant(
                id: "plant_monstera",
                name: "Monstera",
                isOwned: true,
                purchasePrice: 30,
                level: 1,
                baseCoinsPerMinute: 0.05,
                rateGrowth: 1.0,
                growthSecondsPerLevel: 1800,
                lastGrowthAt: .now
            )
        )

        modelContext.insert(
            Plant(
                id: "plant_ficus",
                name: "Ficus",
                isOwned: false,
                purchasePrice: 30,
                level: 1,
                baseCoinsPerMinute: 0.07,
                rateGrowth: 1.0,
                growthSecondsPerLevel: 1800,
                lastGrowthAt: .now
            )
        )

        modelContext.insert(
            Plant(
                id: "plant_fern",
                name: "Fern",
                isOwned: false,
                purchasePrice: 15,
                level: 1,
                baseCoinsPerMinute: 0.05,
                rateGrowth: 1.0,
                growthSecondsPerLevel: 1800,
                lastGrowthAt: .now
            )
        )

        modelContext.insert(RoomState(roomType: .living))

        modelContext.insert(DecorItem(id: "rug_01", name: "Cozy Rug", price: 5, roomType: .living, category: .rug))
        modelContext.insert(DecorItem(id: "lamp_01", name: "Warm Lamp", price: 8, roomType: .living, category: .other))
        modelContext.insert(DecorItem(id: "chair_01", name: "Comfy Chair", price: 12, roomType: .living, category: .chair))
        modelContext.insert(DecorItem(id: "chair_02", name: "Modern Chair", price: 18, roomType: .living, category: .chair))
        modelContext.insert(DecorItem(id: "chair_03", name: "Armchair", price: 22, roomType: .living, category: .chair))
        modelContext.insert(DecorItem(id: "couch_01", name: "Cozy Couch", price: 25, roomType: .living, category: .couch))
        modelContext.insert(DecorItem(id: "couch_02", name: "Modern Sofa", price: 35, roomType: .living, category: .couch))

        do {
            try modelContext.save()
        } catch {
            print("❌ Seed save failed:", error)
        }
    }

    var body: some View {
        let player = players.first

        VStack(spacing: 12) {
            HStack {
                Text("🌱 PlantLife")
                    .font(.title2)
                    .bold()

                Spacer()

                if let player {
                    Text("🪙 \(abbreviated(player.coins))")
                        .font(.headline)
                }

                Button {
                    isShowingMenu = true
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .imageScale(.large)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            ApartmentCanvasView(
                zoomScale: $zoomScale,
                lastZoomScale: $lastZoomScale,
                minZoom: minZoom,
                maxZoom: maxZoom
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut) {
                        zoomScale = max(minZoom, zoomScale - 0.2)
                        lastZoomScale = zoomScale
                    }
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }

                Button {
                    withAnimation(.easeInOut) {
                        zoomScale = min(maxZoom, zoomScale + 0.2)
                        lastZoomScale = zoomScale
                    }
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }

                Button("Reset View") {
                    withAnimation(.easeInOut) {
                        zoomScale = 1.0
                        lastZoomScale = 1.0
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom, 12)
        }
        .onAppear {
            gameStore.start(modelContext: modelContext)
        }
        .onDisappear {
            gameStore.stop(modelContext: modelContext)
        }
        .fullScreenCover(isPresented: $isShowingMenu) {
            NavigationStack {
                List {
                    NavigationLink("Your Plants") { PlantsListView() }
                    NavigationLink("Your Furniture") { FurnitureListView() }
                    NavigationLink("Shop") {
                        ShopView(
                            items: items,
                            plants: plants,
                            onBuyDecor: { item in
                                _ = gameStore.buy(item: item, modelContext: modelContext)
                            },
                            onSellDecor: { item in
                                _ = gameStore.sellDecor(item: item, modelContext: modelContext)
                            },
                            onBuyPlant: { plant in
                                _ = gameStore.buyPlant(plant: plant, modelContext: modelContext)
                            },
                            onSellPlant: { plant in
                                _ = gameStore.sellPlant(plant: plant, modelContext: modelContext)
                            }
                        )
                    }
                    NavigationLink("Games") { MinigamesDemoLauncher() }

                    Section("Developer") {
                        Button(role: .destructive) {
                            resetData()
                            isShowingMenu = false
                        } label: {
                            Text("Reset Data")
                        }
                    }
                }
                .navigationTitle("Menu")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { isShowingMenu = false }
                    }
                }
            }
            .environmentObject(gameStore)
        }
    }
}

private struct ApartmentCanvasView: View {
    @Binding var zoomScale: CGFloat
    @Binding var lastZoomScale: CGFloat

    let minZoom: CGFloat
    let maxZoom: CGFloat

    var body: some View {
        GeometryReader { geo in
            let viewportWidth = geo.size.width
            let viewportHeight = geo.size.height

            let baseWidth = max(viewportWidth * 2.2, 1400)
            let baseHeight = viewportHeight * 0.92

            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)

                    ZStack {
                        Image("apartment")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: baseWidth, height: baseHeight)
                            .scaleEffect(zoomScale, anchor: .center)
                    }
                    .frame(
                        width: baseWidth * zoomScale,
                        height: viewportHeight
                    )

                    Spacer(minLength: 0)
                }
                .frame(
                    minWidth: viewportWidth,
                    minHeight: viewportHeight,
                    alignment: .center
                )
            }
            .scrollClipDisabled()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.thinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastZoomScale
                        lastZoomScale = value
                        zoomScale = min(max(zoomScale * delta, minZoom), maxZoom)
                    }
                    .onEnded { _ in
                        lastZoomScale = 1.0
                    }
            )
        }
    }
}

#Preview("ContentView – Apartment") {
    let schema = Schema([
        PlayerState.self,
        Plant.self,
        DecorItem.self,
        RoomState.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)

    context.insert(PlayerState(coins: 10234, coinBank: 0, lastActiveAt: .now))
    context.insert(RoomState(roomType: .living))

    try! context.save()

    return ContentView()
        .modelContainer(container)
}
