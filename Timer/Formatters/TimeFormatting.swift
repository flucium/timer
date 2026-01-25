import Foundation

enum TimeFormatting {
    static func mmss(_ seconds: Int) -> String {
        
        let s = max(0, seconds)
        
        return String(format: "%02d:%02d", s / 60, s % 60)
    }
}
