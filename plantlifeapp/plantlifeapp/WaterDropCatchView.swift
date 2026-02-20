import SwiftUI
import SwiftData

struct WaterDropCatchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [PlayerState]

    // Game area
    @State private var gameSize: CGSize = .zero

    // Catcher (pot/leaf)
    @State private var catcherX: CGFloat = 0 // centered in geometry
    private let catcherWidth: CGFloat = 80
    private let catcherHeight: CGFloat = 30
    private let catcherYInset: CGFloat = 40 // distance from bottom

    // Droplets
    struct Drop: Identifiable, Equatable {
        let id = UUID()
        var x: CGFloat // relative -1...1 (normalized)
        var y: CGFloat // 0 at top, grows to 1 at bottom
        var speed: CGFloat // units per second in normalized space
        var caught: Bool = false
    }
    @State private var drops: [Drop] = []

    // Spawning & timing
    @State private var lastUpdate: Date = Date()
    @State private var timeRemaining: TimeInterval = 20 // seconds per round
    @State private var isRunning: Bool = true
    @State private var spawnAccumulator: TimeInterval = 0
    private let spawnInterval: TimeInterval = 0.7

    // Scoring
    @State private var caughtCount: Int = 0
    @State private var missedCount: Int = 0
    @State private var rewardCoins: Int? = nil

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.15), Color.green.opacity(0.15)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                header
                GeometryReader { geo in
                    ZStack {
                        // Drops
                        ForEach(drops) { drop in
                            Circle()
                                .fill(Color.cyan)
                                .frame(width: 16, height: 16)
                                .position(positionFor(drop: drop, in: geo.size))
                                .shadow(color: .cyan.opacity(0.5), radius: 3, x: 0, y: 2)
                        }

                        // Catcher
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.brown)
                            .frame(width: catcherWidth, height: catcherHeight)
                            .position(x: clampCatcherX(in: geo.size), y: geo.size.height - catcherYInset)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        // Convert drag to x in view space
                                        let localX = value.location.x
                                        // Centered coordinate
                                        catcherX = localX - geo.size.width / 2
                                    }
                            )
                    }
                    .contentShape(Rectangle())
                    .onAppear {
                        gameSize = geo.size
                        catcherX = 0
                        lastUpdate = Date()
                    }
                    .onChange(of: geo.size) { newSize in
                        gameSize = newSize
                    }
                }
                .frame(maxHeight: 400)

                footer
            }
            .padding()
            .animation(.easeInOut(duration: 0.15), value: caughtCount)

            if let coins = rewardCoins {
                resultOverlay(coins: coins)
            }
        }
        .onReceive(Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()) { now in
            guard isRunning, rewardCoins == nil else { return }
            step(now: now)
        }
        .navigationTitle("Water Drop Catch")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack {
            Text("Time: \(Int(ceil(max(0, timeRemaining))))s")
                .monospacedDigit()
            Spacer()
            Text("Caught: \(caughtCount)")
            Text("Missed: \(missedCount)")
        }
        .font(.headline)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button(isRunning ? "Pause" : "Resume") {
                isRunning.toggle()
                lastUpdate = Date()
            }
            .buttonStyle(.bordered)

            Button("Restart") {
                restart()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            Spacer()
        }
    }

    private func resultOverlay(coins: Int) -> some View {
        VStack(spacing: 12) {
            Text("Round Over")
                .font(.title2).bold()
            Text("You caught \(caughtCount) drops!")
            Text("+\(coins) coins")
                .font(.title3).foregroundStyle(.yellow)
            Button("Play Again") {
                rewardCoins = nil
                restart()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
    }

    // MARK: - Game Loop
    private func step(now: Date) {
        let dt = now.timeIntervalSince(lastUpdate)
        lastUpdate = now
        guard dt > 0 else { return }

        // Countdown
        timeRemaining -= dt
        if timeRemaining <= 0 {
            timeRemaining = 0
            endRound()
            return
        }

        // Spawn
        spawnAccumulator += dt
        while spawnAccumulator >= spawnInterval {
            spawnAccumulator -= spawnInterval
            spawnDrop()
        }

        // Move drops
        let fallPerSecond: CGFloat = 0.45 // normalized per second
        let catcherRect = catcherFrame(in: gameSize)

        var newDrops: [Drop] = []
        for var d in drops {
            d.y += fallPerSecond * d.speed * CGFloat(dt)
            if d.y >= 1.0 { // reached bottom
                // Check catch
                let pos = positionFor(drop: d, in: gameSize)
                if catcherRect.contains(pos) {
                    d.caught = true
                    caughtCount += 1
                } else {
                    missedCount += 1
                }
            } else {
                newDrops.append(d)
            }
        }
        drops = newDrops
    }

    private func spawnDrop() {
        guard gameSize.width > 0 else { return }
        let xNorm = CGFloat.random(in: -1...1)
        let speed = CGFloat.random(in: 0.85...1.25)
        drops.append(Drop(x: xNorm, y: 0, speed: speed, caught: false))
    }

    private func catcherFrame(in size: CGSize) -> CGRect {
        let x = clampCatcherX(in: size)
        let y = size.height - catcherYInset
        return CGRect(x: x - catcherWidth/2, y: y - catcherHeight/2, width: catcherWidth, height: catcherHeight)
    }

    private func clampCatcherX(in size: CGSize) -> CGFloat {
        let minX = catcherWidth/2
        let maxX = size.width - catcherWidth/2
        let proposed = size.width/2 + catcherX
        return min(max(proposed, minX), maxX)
    }

    private func positionFor(drop: Drop, in size: CGSize) -> CGPoint {
        let x = (size.width / 2) + drop.x * (size.width / 2 - 10)
        let y = drop.y * (size.height - catcherYInset - 8)
        return CGPoint(x: x, y: y)
    }

    private func restart() {
        drops.removeAll()
        caughtCount = 0
        missedCount = 0
        timeRemaining = 20
        spawnAccumulator = 0
        isRunning = true
        lastUpdate = Date()
    }

    private func endRound() {
        isRunning = false
        // Reward: small coins, scaled by performance (e.g., 1 coin per 2 catches, min 1, max 25)
        let coins = max(1, min(25, caughtCount / 2))
        rewardCoins = coins
        grantCoins(coins)
    }

    private func grantCoins(_ coins: Int) {
        guard coins > 0 else { return }
        // Use first PlayerState record
        if let player = players.first {
            player.coins += coins
            try? modelContext.save()
        }
    }
}

#Preview {
    NavigationStack { WaterDropCatchView() }
}
