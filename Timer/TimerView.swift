import Combine
import SwiftUI
import SwiftData

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
