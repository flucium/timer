import SwiftUI

@main
struct TimerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: 500,
                    idealWidth: 500,
                    maxWidth: 500,
                    minHeight: 600,
                    idealHeight: 600,
                    maxHeight: 600,
                    alignment: .center
                )
        }.windowResizability(.contentSize)
    }
}
