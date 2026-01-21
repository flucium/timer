import Combine
import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var selection: Destination? = .timer
    
    @StateObject private var timerViewModel = ContentViewModel()
    @State private var pendingSelection: Destination? = nil
    @State private var showLeaveTimerAlert = false

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: Destination.timer) {
                    Label("Timer", systemImage: "timer")
                }
                NavigationLink(value: Destination.history) {
                    Label("History", systemImage: "text.justify")
                }
                NavigationLink(value: Destination.settings) {
                    Label("Settings", systemImage: "gear")
                }
            }.onChange(of: selection) { _, newValue in
                guard timerViewModel.isStarted || timerViewModel.isPaused else { return }
                guard newValue != .timer else { return }

                pendingSelection = newValue
                selection = .timer
                showLeaveTimerAlert = true
            }
        } detail: {
            switch selection {
            case .timer:
                // TimerView()
                TimerView(contentViewModel: timerViewModel)
            case .history:
                HistoryView()
            case .settings:
                EmptyView()
            default:
                EmptyView()
            }
        }.alert("Timer is running", isPresented: $showLeaveTimerAlert) {
            Button("Leave", role: .destructive) {

                timerViewModel.stop()

                selection = pendingSelection
                pendingSelection = nil
            }
            Button("Stay", role: .cancel) {
                pendingSelection = nil
            }
        } message: {
            Text("Leaving will stop the timer. Do you want to leave the Timer view?")
        }
    }

    
    
}

struct TimerView: View{
    @Environment(\.modelContext) private var modelContext
    
    // @StateObject private var contentViewModel = ContentViewModel()
    @ObservedObject var contentViewModel: ContentViewModel
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 6.0)
                    .opacity(0.2)
                    .foregroundStyle(Color.blue)

                if contentViewModel.remainingSeconds < contentViewModel.totalSeconds {
                    Circle()
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 8.0,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .trim(from: 0.0, to: contentViewModel.progress)
                        .rotationEffect(.degrees(-90))
                        .foregroundStyle(Color.blue)
                        .animation(
                            .linear(duration: 0.2),
                            value: contentViewModel.progress
                        )
                }

                Text(contentViewModel.timeText)
                    .font(
                        .system(
                            size: 32,
                            weight: .semibold,
                            design: .monospaced
                        )
                    )
                    .frame(width: 220, height: 220)
                    .padding()
            }

            Picker("", selection: $contentViewModel.minutesIndex) {
                ForEach(0..<12, id: \.self) { i in
                    Text("\((i + 1) * 5)").tag(i)
                }
            }
            .pickerStyle(.segmented)
            .frame(height: 140)
            .disabled(contentViewModel.isStarted)
            .onChange(of: contentViewModel.minutesIndex) { _, _ in
                contentViewModel.minutesIndexChanged()
            }
            .padding()

            HStack {
                Button(contentViewModel.startButtonTitle) {
                    contentViewModel.startOrResume()
                }
                .buttonStyle(.borderedProminent)
                .disabled(contentViewModel.isStarted)

                Button("Pause") {
                    contentViewModel.pause()
                }
                .buttonStyle(.bordered)
                // .disabled(!contentViewModel.isStarted)
                .disabled(!contentViewModel.isStarted || contentViewModel.isPaused)

                Button("Reset") {
                    contentViewModel.reset()
                }
                .buttonStyle(.bordered)

                Button("Stop") {
                    contentViewModel.stop()
                }
                .buttonStyle(.bordered)
                // .disabled(!contentViewModel.isStarted)
                .disabled(!contentViewModel.isStarted && !contentViewModel.isPaused)
            }
            .padding()
        }
        .padding()
        .onAppear {
            contentViewModel.onAppear()

            contentViewModel.onRecord = { elapsed, set in
                modelContext.insert(
                    HistoryEntry(
                        elapsedSeconds: elapsed,
                        setSeconds: set
                    )
                )
            }
        }
    
    }
}

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

#Preview {
    ContentView()
}

