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

    private let maxActiveDrops = 30

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
    // Removed fixed spawnInterval constant

    // Round progression & miss limit
    @State private var roundIndex: Int = 0
    @State private var missLimit: Int = 3

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
                        Canvas { ctx, size in
                            for drop in drops {
                                let pt = positionFor(drop: drop, in: size)
                                let rect = CGRect(x: pt.x - 8, y: pt.y - 8, width: 16, height: 16)
                                ctx.fill(Path(ellipseIn: rect), with: .color(.cyan))
                            }
                        }

                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.brown)
                            .frame(width: catcherWidth, height: catcherHeight)
                            .position(x: clampCatcherX(in: geo.size), y: geo.size.height - catcherYInset)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let localX = value.location.x
                                        catcherX = localX - geo.size.width / 2
                                    }
                            )
                    }
                    .contentShape(Rectangle())
                    .onAppear {
                        gameSize = geo.size
                        catcherX = 0
                        if gameSize.width > 0 && drops.isEmpty {
                            spawnDrop()
                        }
                    }
                    .onChange(of: geo.size) { newSize in
                        gameSize = newSize
                    }
                }
                .frame(maxHeight: .infinity)

                footer
            }
            .padding()

            if let coins = rewardCoins {
                resultOverlay(coins: coins)
            }
        }
        .ignoresSafeArea()
        .navigationTitle("Water Drop Catch")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            lastUpdate = Date()
        }
        .onReceive(Timer.publish(every: 1.0/30.0, on: .main, in: .common).autoconnect()) { now in
            if isRunning && rewardCoins == nil {
                step(now: now)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Time: \(Int(ceil(max(0, timeRemaining))))s")
                    .monospacedDigit()
                Text("Round \(roundIndex + 1) · \(difficultyLabel())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
            Text("Missed: \(missedCount) / \(missLimit)")
            if missedCount == 0 {
                Text("Flawless! +5 bonus")
                    .foregroundStyle(.green)
            }
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
        while spawnAccumulator >= currentSpawnInterval() {
            spawnAccumulator -= currentSpawnInterval()
            spawnDrop()
        }

        // Move drops
        let fallPerSecond: CGFloat = currentFallPerSecond() // dynamic fall speed
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

        drops.removeAll { $0.y > 1.2 }

        // Check miss limit end condition
        if missedCount >= missLimit {
            endRound()
            return
        }
    }

    private func spawnDrop() {
        guard gameSize.width > 0 else { return }
        if drops.count >= maxActiveDrops {
            return
        }
        var xNorm = CGFloat.random(in: -1...1)
        // Reduce initial crowding:
        if let lastDrop = drops.last, lastDrop.y < 0.15, abs(lastDrop.x - xNorm) < 0.25 {
            if Bool.random() {
                xNorm += 0.4
            } else {
                xNorm -= 0.4
            }
            xNorm = min(max(xNorm, -1), 1)
        }
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
        rewardCoins = nil
        // roundIndex not reset to keep progressive difficulty
    }

    private func endRound() {
        isRunning = false
        // Reward: small coins, scaled by performance (e.g., 1 coin per 2 catches, min 1, max 25)
        var coins = max(1, min(25, caughtCount / 2))
        if missedCount == 0 {
            coins += 5 // flawless bonus
        }
        rewardCoins = coins
        grantCoins(coins)
        roundIndex += 1
    }

    private func grantCoins(_ coins: Int) {
        guard coins > 0 else { return }
        // Use first PlayerState record
        if let player = players.first {
            player.coins += coins
            try? modelContext.save()
        }
    }

    private func currentSpawnInterval() -> TimeInterval {
        max(0.35, 1.2 - Double(roundIndex) * 0.15)
    }

    private func currentFallPerSecond() -> CGFloat {
        min(0.85, 0.35 + 0.07 * CGFloat(roundIndex))
    }
    
    private func difficultyLabel() -> String {
        switch roundIndex {
        case 0:
            return "Easy"
        case 1:
            return "Normal"
        case 2:
            return "Hard"
        default:
            return "Extreme"
        }
    }
}

#Preview {
    NavigationStack { WaterDropCatchView() }
}
