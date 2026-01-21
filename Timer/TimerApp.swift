import Foundation
import SwiftUI
import SwiftData

@main
struct TimerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: HistoryEntry.self)
#if os(macOS)
        .commands {
            CommandGroup(after: .textEditing) {
                Button("Delete") {
                    NotificationCenter.default
                        .post(name: .deleteHistorySelection, object: nil)
                }
                .keyboardShortcut(.delete)
            }
        }
#endif // os(macOS)
    }
}


// extension (Delete)
extension Notification.Name {
    static let deleteHistorySelection = Notification.Name(
        "deleteHistorySelection"
    )
}
