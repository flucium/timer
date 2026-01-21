import Foundation
import SwiftData

enum Destination: Hashable {
    case timer
    case history
    case settings
}

enum RecordReason: Hashable {
    case stopped
    case finished
}


@Model
final class HistoryEntry {
    var createdAt: Date
    var elapsedSeconds: Int
    var setSeconds: Int
    init(createdAt: Date = Date(), elapsedSeconds: Int, setSeconds: Int) {
        self.createdAt = createdAt
        self.elapsedSeconds = elapsedSeconds
        self.setSeconds = setSeconds
    }
}
