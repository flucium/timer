import Combine
import SwiftUI

private enum NavigationDestination: Hashable {
    case timer
    case history
    case settings
}

struct HomeView: View {
    @State private var selection: Set<HistoryEntry> = []
    @State private var pendingSelection:Set<HistoryEntry> = []
    @State private var showLeaveTimerAlert = false
    @State private var destination:NavigationDestination? = .timer
    @State private var pendingDestination: NavigationDestination? = nil
    
    @ObservedObject private var timerViewModel = TimerViewModel()
    
    var body: some View {
        // -- NavigationSplitView --
        NavigationSplitView {
            // -- List --
            List(selection: $destination) {
                // -- NavigationLink --
                NavigationLink(value: NavigationDestination.timer) {
                    Label("Timer", systemImage: "timer")
                }
                NavigationLink(value: NavigationDestination.history) {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                // NavigationLink(value: NavigationDestination.settings) {
                    // Label("Settings", systemImage: "gearshape")
                // }
                // -- End NavigationLink --
            }
            // -- End List --
        }detail: {
            detail(for: destination)
        }
        .onChange(of: destination) { _, newValue in
            
            guard timerViewModel.isStarted || timerViewModel.isPaused else {
                return
            }
            
            guard newValue != .timer else {
                return
            }

            pendingDestination = newValue
            
            destination = .timer
            
            showLeaveTimerAlert = true
        }
        .alert("Timer is running", isPresented: $showLeaveTimerAlert) {
            // -- Button (leave/stay) --
            Button("Leave", role: .destructive) {

                timerViewModel.stop()

                destination = pendingDestination
                pendingDestination = nil
            }
            Button("Stay", role: .cancel) {
                pendingDestination = nil
            }
            // -- End Button (leave/stay) --
        } message: {
            // -- Text (leaving message) --
            Text(
                "Leaving will stop the timer. Do you want to leave the Timer view?"
            )
            // -- End Text (leaving message) --
        }
        // -- End NavigationSplitView --
    }
    
    // -- ViewBuilder (detail) --
    @ViewBuilder
    private func detail(for destination: NavigationDestination?) -> some View {
        switch destination {
        case .timer:
            TimerView()
                .environmentObject(timerViewModel)
        case .history:
            HistoryView()
        // case .settings:
            // EmptyView()
        default:
            EmptyView()
        }
    }
    // -- End ViewBuilder (detail) --
}

#Preview {
    HomeView()
}

