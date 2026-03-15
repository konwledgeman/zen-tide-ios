import SwiftUI
import Combine

/// 专注计时器状态
enum TimerState {
    case idle       // 未开始
    case running    // 计时中
    case paused     // 已暂停
    case finished   // 已完成
}

/// 专注计时器 ViewModel
class FocusTimerViewModel: ObservableObject {
    // MARK: - 计时器状态
    @Published var state: TimerState = .idle
    @Published var remainingSeconds: Int = 25 * 60
    @Published var totalSeconds: Int = 25 * 60
    @Published var progress: CGFloat = 0.0
    
    // MARK: - 场景和设置
    @Published var selectedScene: SoundScene = .ocean
    @Published var focusDuration: Int = 25  // 分钟
    @Published var soundEnabled: Bool = true
    @Published var volume: Float = 0.5
    
    // MARK: - 内部
    private var timer: Timer?
    private var startTime: Date?
    
    init() {
        totalSeconds = focusDuration * 60
        remainingSeconds = totalSeconds
    }
    
    // MARK: - 格式化显示
    
    /// 剩余时间显示（MM:SS）
    var timeDisplay: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 分钟显示
    var minutesDisplay: String {
        return "\(remainingSeconds / 60)"
    }
    
    /// 秒钟显示
    var secondsDisplay: String {
        return String(format: "%02d", remainingSeconds % 60)
    }
    
    // MARK: - 操作
    
    /// 开始专注
    func start() {
        guard state == .idle || state == .finished else { return }
        
        totalSeconds = focusDuration * 60
        remainingSeconds = totalSeconds
        progress = 0.0
        state = .running
        startTime = Date()
        
        // 播放白噪声
        if soundEnabled {
            SoundManager.shared.volume = volume
            SoundManager.shared.play(scene: selectedScene)
        }
        
        startTimer()
    }
    
    /// 暂停
    func pause() {
        guard state == .running else { return }
        state = .paused
        timer?.invalidate()
        timer = nil
        
        if soundEnabled {
            SoundManager.shared.pause()
        }
    }
    
    /// 恢复
    func resume() {
        guard state == .paused else { return }
        state = .running
        
        if soundEnabled {
            SoundManager.shared.resume()
        }
        
        startTimer()
    }
    
    /// 放弃
    func abandon() {
        let elapsed = totalSeconds - remainingSeconds
        
        // 记录未完成的会话（如果已超过 1 分钟）
        if elapsed >= 60 {
            let session = FocusSession(
                duration: elapsed,
                scene: selectedScene,
                completed: false
            )
            SessionStore.save(session)
        }
        
        reset()
    }
    
    /// 切换场景
    func selectScene(_ scene: SoundScene) {
        selectedScene = scene
        
        // 如果正在播放，切换音频
        if state == .running && soundEnabled {
            SoundManager.shared.play(scene: scene)
        }
    }
    
    /// 设置专注时长
    func setDuration(_ minutes: Int) {
        focusDuration = minutes
        if state == .idle || state == .finished {
            totalSeconds = minutes * 60
            remainingSeconds = totalSeconds
            progress = 0.0
        }
    }
    
    // MARK: - 内部方法
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        guard remainingSeconds > 0 else {
            finish()
            return
        }
        
        remainingSeconds -= 1
        withAnimation(.linear(duration: 1.0)) {
            progress = CGFloat(totalSeconds - remainingSeconds) / CGFloat(totalSeconds)
        }
    }
    
    private func finish() {
        state = .finished
        timer?.invalidate()
        timer = nil
        SoundManager.shared.stop()
        
        // 保存完成的会话
        let session = FocusSession(
            duration: totalSeconds,
            scene: selectedScene,
            completed: true
        )
        SessionStore.save(session)
    }
    
    private func reset() {
        state = .idle
        timer?.invalidate()
        timer = nil
        totalSeconds = focusDuration * 60
        remainingSeconds = totalSeconds
        progress = 0.0
        SoundManager.shared.stop()
    }
}
