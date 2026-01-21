import Combine
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \HistoryEntry.createdAt, order: .reverse) private var items: [HistoryEntry]

    @State private var selection: Set<HistoryEntry> = []
    
    var body: some View {
        HStack{
            Button("All Reset") {
                items.forEach { item in
                    delete(item)
                }
            }
        }.padding()
    }
    
    private func delete(_ item: HistoryEntry) {
        modelContext.delete(item)
        selection.remove(item)
    }
}
