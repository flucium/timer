import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \HistoryEntry.createdAt, order: .reverse) private var items: [HistoryEntry]

    @StateObject private var historyViewModel = HistoryViewModel()

    var body: some View {
        // -- List --
        List(selection: $historyViewModel.selection){
            // -- ForEach (timer records) --
            ForEach(items) { item in
                // -- HStack --
                HStack {
                    // -- Text (timer record) --
                    Text(
                        "CreatedAt: \(historyViewModel.time(item.createdAt)), " +
                        "SetTime: \(historyViewModel.mmss(item.setSeconds)), " +
                        "Total: \(historyViewModel.mmss(item.elapsedSeconds))"
                    )
                    // -- End Text (timer record) --
                }
                .tag(item)
                .contextMenu {
                    // -- Button (deleting a timer record) --
                    Button("Delete") {
                        historyViewModel.delete(item, in: modelContext)
                    }
                    // -- End Button (deleting a timer record) --
                }
                // -- End HStack --
            }
            .onDelete { indexSet in
                historyViewModel.deleteByIndexSet(indexSet, items: items, in: modelContext)
            }
            // -- End ForEach (timer records) --
        }
        .navigationTitle("History")
        .onReceive(
            NotificationCenter.default.publisher(for: .deleteHistorySelection)
        ) { _ in
            historyViewModel.deleteSelection(in: modelContext)
        }
    }
    // -- End List --
}

#Preview {
    HistoryView()
}
