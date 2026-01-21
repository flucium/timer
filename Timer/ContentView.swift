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
            }.onChange(of: selection) { oldValue, newValue in
                guard timerViewModel.isStarted || timerViewModel.isPaused else {
                    return
                }
                guard newValue != .timer else { return }

                pendingSelection = newValue
                selection = .timer
                showLeaveTimerAlert = true
            }
        } detail: {
            switch selection {
            case .timer:
                TimerView(contentViewModel: timerViewModel)
            case .history:
                HistoryView()
            case .settings:
                SettingsView()
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
            Text(
                "Leaving will stop the timer. Do you want to leave the Timer view?"
            )
        }
    }
}



#Preview {
    ContentView()
}

