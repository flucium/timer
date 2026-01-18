import Foundation
import Combine

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var isStarted: Bool = false
    @Published var minutesIndex: Int = 0
    @Published private(set) var totalSeconds: Int = 5 * 60
    @Published private(set) var remainingSeconds: Int = 5 * 60
    
    private var cancellable: AnyCancellable?
    
    private var selectedMinutes: Int { (minutesIndex + 1) * 5 }
    
    private func applySelectedMinutes() {
        totalSeconds = selectedMinutes * 60
        remainingSeconds = totalSeconds
    }

    private func startTickerIfNeeded() {
        guard cancellable == nil else { return }

        cancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                guard self.isStarted else { return }

                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.isStarted = false
                    self.stopTicker()
                }
            }
    }

    private func stopTicker() {
        cancellable?.cancel()
        cancellable = nil
    }
   
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }
    
    var timeText: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var startButtonTitle: String {
        if isStarted { return "Start" }
        return (remainingSeconds < totalSeconds) ? "Resume" : "Start"
    }
    
    
    init() {
        applySelectedMinutes()
    }

    deinit {
        cancellable?.cancel()
    }

    func onAppear() {
        applySelectedMinutes()
    }
    
    func minutesIndexChanged() {
        guard !isStarted else { return }
        applySelectedMinutes()
    }

    func startOrResume() {
        guard !isStarted else { return }
        totalSeconds = selectedMinutes * 60
        if remainingSeconds <= 0 || remainingSeconds > totalSeconds {
            remainingSeconds = totalSeconds
        }

        isStarted = true
        startTickerIfNeeded()
    }

    func pause() {
        isStarted = false
        stopTicker()
    }

    func reset() {
        isStarted = false
        stopTicker()
        applySelectedMinutes()
    }

    func stop() {
        reset()
    }

}
