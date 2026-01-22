import Combine
import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \HistoryEntry.createdAt, order: .reverse) private var items: [HistoryEntry]

    @State private var selection: Set<HistoryEntry> = []

    var body: some View {
        List(selection: $selection) {
            ForEach(items) { item in
                HStack {
                    Text(
                        "CreatedAt: \(time(item.createdAt)), " +
                        "SetTime: \(formatSeconds(item.setSeconds)), " +
                        "Total: \(formatSeconds(item.elapsedSeconds))"
                    )
                }
                .tag(item)
                .contextMenu {
                    Button("Delete") {
                        delete(item)
                    }
                }
            }
            .onDelete(perform: deleteByIndexSet)
        }
        .navigationTitle("History")
        .onReceive(
            NotificationCenter.default.publisher(for: .deleteHistorySelection)
        ) { _ in
            deleteSelection()
        }
    }
    
    private func delete(_ item: HistoryEntry) {
        modelContext.delete(item)
        selection.remove(item)

    }

    private func deleteByIndexSet(_ indexSet: IndexSet) {
        for i in indexSet {
            modelContext.delete(items[i])
        }
    }

    private func deleteSelection() {
        for item in selection {
            modelContext.delete(item)
        }
        selection.removeAll()
    }

    private func time(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f.string(from: date)
    }

    private func formatSeconds(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}
