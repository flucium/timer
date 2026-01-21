import Foundation
import Combine

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var minutesIndex: Int = 0
    
    @Published private(set) var totalSeconds: Int = 5 * 60
    
    @Published private(set) var remainingSeconds: Int = 5 * 60
    
    @Published private(set) var isStarted: Bool = false
    
    @Published private(set) var startButtonTitle: String = "Start"

    private var timerCancellable: AnyCancellable?
    
    private var isPaused: Bool = false
    
    private var didRecordThisRun: Bool = false
    
    // var onRecord: ((RecordReason, Int, Int) -> Void)?
    var onRecord: ((Int, Int) -> Void)?

    var progress: Double {
        guard totalSeconds > 0 else { return 0.0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var timeText: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    
    func onAppear() {
        applyMinutesIndexToSeconds()
        updateStartButtonTitle()
    }

    func startOrResume() {
        guard !isStarted else { return }

        if remainingSeconds <= 0 {
            applyMinutesIndexToSeconds()
            isPaused = false
        }

        isStarted = true
        if !isPaused {
            didRecordThisRun = false
        }
        updateStartButtonTitle()
        startTimer()
    }
    
    func minutesIndexChanged() {
        guard !isStarted else { return }

        isPaused = false
        applyMinutesIndexToSeconds()
        updateStartButtonTitle()
    }

    func stop() {
        stopTimer()

         let elapsed = max(0, totalSeconds - remainingSeconds)
         if elapsed > 0 && !didRecordThisRun {
             didRecordThisRun = true
             onRecord?(elapsed, totalSeconds)
         }

         isStarted = false
         isPaused = false
         remainingSeconds = totalSeconds
         didRecordThisRun = false
         updateStartButtonTitle()
    }

    func pause() {
        guard isStarted else { return }
        stopTimer()
        isStarted = false
        isPaused = true
        updateStartButtonTitle()
    }

    func reset() {
        stopTimer()
        isStarted = false
        isPaused = false
        didRecordThisRun = false
        remainingSeconds = totalSeconds
        updateStartButtonTitle()
    }

    
    private func startTimer() {
        stopTimer()

        timerCancellable = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }


    private func finish() {
        
        if !didRecordThisRun {
            didRecordThisRun = true
            onRecord?(totalSeconds, totalSeconds)
        }

        stopTimer()
        isStarted = false
        isPaused = false
        remainingSeconds = 0
        didRecordThisRun = false
        updateStartButtonTitle()
    }
    
    private func tick() {
        guard remainingSeconds > 0 else {
            finish()
            return
        }

        remainingSeconds -= 1

        if remainingSeconds <= 0 {
            finish()
        }
    }

    
    private func applyMinutesIndexToSeconds() {
        let minutes = (minutesIndex + 1) * 5
        totalSeconds = minutes * 60
        remainingSeconds = totalSeconds
    }

    private func updateStartButtonTitle() {
        startButtonTitle = isPaused ? "Resume" : "Start"
    }
}

