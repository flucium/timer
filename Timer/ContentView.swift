import Combine
import SwiftUI

struct ContentView: View {
    @State var isStart: Bool = false
    @State private var minutesIndex: Int = 0

    @State private var totalSeconds: Int = 5 * 60
    @State private var remainingSeconds: Int = 5 * 60

    private let ticker = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    private var selectedMinutes: Int { (minutesIndex + 1) * 5 }

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    private var timeText: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func stopAndReset() {
        withAnimation(.linear(duration: 0.2)) {
            isStart = false
            totalSeconds = selectedMinutes * 60
            remainingSeconds = totalSeconds
        }
    }

    var body: some View {
        VStack {

            ZStack {
                Circle()
                    .stroke(lineWidth: 6.0)
                    .opacity(0.2)
                    .foregroundStyle(Color.blue)

                if remainingSeconds < totalSeconds {
                    Circle()
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 8.0,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .trim(from: 0.0, to: progress)
                        .rotationEffect(.degrees(-90))
                        .foregroundStyle(Color.blue)
                        .animation(.linear(duration: 0.2), value: progress)
                }

                Text(timeText)
                    .font(
                        .system(
                            size: 32,
                            weight: .semibold,
                            design: .monospaced
                        )
                    )

            }
            .frame(width: 220, height: 220)
            .padding()
            .onReceive(ticker) { _ in
                guard isStart else { return }
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    
                    isStart = false
                }
            }

            Picker("", selection: $minutesIndex) {
                ForEach(0..<12, id: \.self) { i in
                    Text("\((i + 1) * 5)")
                        .tag(i)
                }
            }

            .pickerStyle(.segmented)
            .frame(height: 140)
            .disabled(isStart)
            .onChange(of: minutesIndex) { _, _ in

                if !isStart {
                    totalSeconds = selectedMinutes * 60
                    remainingSeconds = totalSeconds
                }
            }.padding()

            HStack {

                Button(
                    isStart ? "Start" : (
                        remainingSeconds < totalSeconds ? "Resume" : "Start"
                    )
                ) {
                    if !isStart {
                        isStart = true
                        totalSeconds = selectedMinutes * 60
                        if remainingSeconds <= 0 || remainingSeconds > totalSeconds {
                            remainingSeconds = totalSeconds
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isStart)

                Button("Pause") {
                    withAnimation(.linear(duration: 0.2)) {
                        isStart = false
                    }
                }
                .buttonStyle(.bordered)
                .disabled(!isStart)
                Button("Reset") {
                    stopAndReset()
                }
                .buttonStyle(.bordered)
                Button("Stop") {
                    stopAndReset()
                    
                }
                .buttonStyle(.bordered)
                .disabled(!isStart)
                
            }.padding()
                .onAppear {
                    totalSeconds = selectedMinutes * 60
                    remainingSeconds = totalSeconds
                }
                .onReceive(ticker) { _ in
                    guard isStart else { return }
                    if remainingSeconds > 0 {
                        remainingSeconds -= 1
                    } else {

                        isStart = false
                    }
                }
        }.padding()
    }
}

#Preview {
    ContentView()
}

