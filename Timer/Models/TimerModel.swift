import SwiftData
import Foundation

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
