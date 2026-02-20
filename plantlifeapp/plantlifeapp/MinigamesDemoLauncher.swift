import SwiftUI

struct MinigamesDemoLauncher: View {
    var body: some View {
        List {
            Section("Minigames") {
                NavigationLink("Water Drop Catch") {
                    WaterDropCatchView()
                }
            }
        }
        .navigationTitle("Play")
    }
}

struct MinigamesDemoLauncher_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { MinigamesDemoLauncher() }
    }
}
