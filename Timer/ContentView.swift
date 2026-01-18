import Combine
import SwiftUI

struct ContentView: View {
    @StateObject private var contentViewModel = ContentViewModel()
    @State private var selection: Destination? = .timer
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: Destination.timer) {
                    Label("Timer", systemImage: "timer")
                }
                NavigationLink(value: Destination.history) {
                    Label("History", systemImage: "info")
                }
                NavigationLink(value: Destination.settings) {
                    Label("Settings", systemImage: "gear")
                }
            }
        } detail: {
            switch selection {
            case .timer:
                timerView
            case .history:
                EmptyView()
            case .settings:
                EmptyView()
            default:
                EmptyView()
            }
        }
    }

    private var timerView: some View {
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
                .disabled(!contentViewModel.isStarted)

                Button("Reset") {
                    contentViewModel.reset()
                }
                .buttonStyle(.bordered)

                Button("Stop") {
                    contentViewModel.stop()
                }
                .buttonStyle(.bordered)
                .disabled(!contentViewModel.isStarted)
            }
            .padding()
        }
        .padding()
        .onAppear { contentViewModel.onAppear() }
    }
        
}
    
#Preview {
    ContentView()
}

