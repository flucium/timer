import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var timerViewModel: TimerViewModel
    
    var body: some View {
        
        // -- VStack --
        VStack {
            // -- ZStack ⊂ VStack --
            ZStack {
                // -- Circle (default) --
                Circle()
                    .stroke(lineWidth: 6.0)
                    .opacity(0.2)
                    .foregroundStyle(Color.blue)
                // -- End Circle (default) --
                
                // -- Circle (progress) --
                if timerViewModel.remainingSeconds < timerViewModel.totalSeconds{
                    Circle()
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 8.0,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .trim(from: 0.0, to: timerViewModel.progress)
                        .rotationEffect(.degrees(-90))
                        .foregroundStyle(Color.blue)
                        .animation(
                            .linear(duration: 0.2),
                            value:timerViewModel.progress
                        )
                }
                // -- End Circle (progress) --
                
                // -- Text (time text) --
                Text(timerViewModel.timeText)
                    .font(
                        .system(
                            size: 32,
                            weight: .semibold,
                            design: .monospaced
                        )
                    )
                    .frame(width: 220, height: 220)
                // -- End Text (time text) --
            }
            // -- End ZStack ⊂ VStack --
            
            // -- Picker (minutes) --
            Picker("", selection: $timerViewModel.minutesIndex) {
                ForEach(0..<12, id: \.self) { i in
                    Text("\((i + 1) * 5)").tag(i)
                }
            }
            .pickerStyle(.segmented)
            .frame(height: 140)
            .disabled(timerViewModel.isStarted)
            .onChange(of: timerViewModel.minutesIndex) { _, _ in
                timerViewModel.minutesIndexChanged()
            }.padding()
            // -- End Picker (minutes) --
            
            
            // -- HStack ⊂ VStack --
            HStack {
                
                // -- Button (start or resume) --
                Button(timerViewModel.startButtonTitle) {
                    timerViewModel.startOrResume()
                }
                .buttonStyle(.borderedProminent)
                .disabled(timerViewModel.isStarted)
                // -- End Button (start or resume) --
                
                // -- Button (pause) --
                Button("Pause") {
                    timerViewModel.pause()
                }
                .buttonStyle(.bordered)
                .disabled(
                    !timerViewModel.isStarted || timerViewModel.isPaused
                )
                // -- End Button (pause) --
                
                // -- Button (reset) --
                Button("Reset") {
                    timerViewModel.reset()
                }
                .buttonStyle(.bordered)
                // -- End Button (reset) --
                
                // -- Button (stop) --
                Button("Stop") {
                    timerViewModel.stop()
                }
                .buttonStyle(.bordered)
                .disabled(!timerViewModel.isStarted && !timerViewModel.isPaused)
                // -- End Button (stop) --
                
            }
            // -- End HStack ⊂ VStack
            
        }
        .onAppear {
            
            timerViewModel.onAppear()
            
            // -- Record elapsed and set times --
            timerViewModel.onRecord = { elapsed, set in
                
                // -- Insert a new HistoryEntry into the model context --
                modelContext.insert(
                    HistoryEntry(
                        elapsedSeconds: elapsed,
                        setSeconds: set
                    )
                )
                // -- End Insert a new HistoryEntry into the model context --
            }
            // -- End Record elapsed and set times --
        }.padding()
        // -- End VStack --
        
    }
    
    
}

#Preview {
    TimerView()
}

