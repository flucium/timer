import SwiftUI
import SwiftData
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {

    @Published var selection: Set<HistoryEntry> = []

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()

        f.timeStyle = .short

        f.dateStyle = .none

        return f
    }()

    func mmss(_ s: Int) -> String {
        String(format: "%02d:%02d", max(0, s) / 60, max(0, s) % 60)
    }
    
    func time(_ date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }
    
    func delete(_ item: HistoryEntry, in modelContext: ModelContext) {
        modelContext.delete(item)

        selection.remove(item)
    }

    func deleteByIndexSet(_ indexSet: IndexSet, items: [HistoryEntry], in modelContext: ModelContext) {
        for i in indexSet {
            modelContext.delete(items[i])
        }
    }

    func deleteSelection(in modelContext: ModelContext) {
        for item in selection {
            modelContext.delete(item)
        }

        selection.removeAll()
    }
}

