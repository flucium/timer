import Combine
import Foundation

private enum RunState {
    case idle
    case running
    case paused
}

@MainActor
final class TimerViewModel: ObservableObject {
    
    @Published private(set) var isStarted: Bool

    @Published private(set) var isPaused: Bool
    
    @Published private(set) var hasAppeared: Bool
    
    @Published private(set) var remainingSeconds:Int
    
    @Published private(set) var totalSeconds: Int

    @Published var minutesIndex: Int
    
    private var timerCancellable: AnyCancellable?

    private var didRecordThisRun: Bool = false
    
    
    var onRecord: ((Int, Int) -> Void)?
    
    var progress: Double {
        guard totalSeconds > 0 else {
            return 0.0
        }
        
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }
    
    
    var timeText: String {
        
        let m = remainingSeconds / 60
        
        let s = remainingSeconds % 60
        
        return String(format: "%02d:%02d", m, s)
    }

    var startButtonTitle: String {
        isPaused ? "Resume" : "Start"
    }

    
    init() {
        self.isStarted = false
        
        self.isPaused = false
        
        self.hasAppeared = false
        
        self.totalSeconds = 5 * 60
        
        self.remainingSeconds = 5 * 60
        
        self.minutesIndex = 0
    }
    
    func onAppear() {
        applyMinutesIndexToSeconds()
    }

    
    func startOrResume() {
        guard !isStarted else {
            return
        }

        if remainingSeconds <= 0 {
            applyMinutesIndexToSeconds()
        }

        didRecordThisRun = false
        
        transition(to: .running)
    }
    
    func stop() {
        let elapsed = elapsedSeconds

        recordForce(elapsed: elapsed)

        didRecordThisRun = false
        
        remainingSeconds = totalSeconds
        
        transition(to: .idle)
    }
    
    func pause() {
        guard isStarted else {
            return
        }
             
        transition(to: .paused)
        
    }
    
    func reset() {
        didRecordThisRun = false
        
        remainingSeconds = totalSeconds
    
        transition(to: .idle)
    }
    
    func minutesIndexChanged() {
        guard !isStarted else {
            return
        }
        
        recordIfNeeded(elapsed: elapsedSeconds)

        didRecordThisRun = false
        
        isPaused = false
        
        applyMinutesIndexToSeconds()
        
        transition(to: .idle)
    }
    
    
    
    private func transition(to state: RunState) {
        switch state {
        case .idle:
            stopTimer()
            isStarted = false
            isPaused = false

        case .running:
            isStarted = true
            isPaused = false
            startTimer()

        case .paused:
            stopTimer()
            isStarted = false
            isPaused = true
        }
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
    
    private func finish() {
        recordIfNeeded(elapsed: totalSeconds)
        
        remainingSeconds = 0
        
        didRecordThisRun = false
        
        transition(to: .idle)
    }
    
    private var elapsedSeconds: Int {
        max(0, totalSeconds - remainingSeconds)
    }

    private func recordIfNeeded(elapsed: Int) {
        guard elapsed > 0 else {
            return
        }
        
        guard !didRecordThisRun else {
            return
        }
        
        didRecordThisRun = true
        
        onRecord?(elapsed, totalSeconds)
    }

    private func recordForce(elapsed: Int) {
        guard elapsed > 0 else {
            return
        }
        
        didRecordThisRun = true
     
        onRecord?(elapsed, totalSeconds)
    }
    
    func applyMinutesIndexToSeconds() {
        let minutes = (minutesIndex + 1) * 5
        
        totalSeconds = minutes * 60
        
        remainingSeconds = totalSeconds
    }
    
}
