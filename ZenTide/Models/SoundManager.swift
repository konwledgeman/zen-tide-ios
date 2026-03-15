import AVFoundation

/// 白噪声音频管理器
/// 从 Bundle 中加载真实自然音效文件并循环播放
class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private(set) var isPlaying = false
    private(set) var currentScene: SoundScene?
    
    var volume: Float = 0.5 {
        didSet {
            audioPlayer?.volume = volume
        }
    }
    
    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话配置失败: \(error)")
        }
    }
    
    /// 播放指定场景的白噪声
    func play(scene: SoundScene) {
        // 停止当前播放
        audioPlayer?.stop()
        audioPlayer = nil
        
        currentScene = scene
        
        // 从 Bundle 中查找音频文件
        guard let url = Bundle.main.url(forResource: scene.rawValue, withExtension: "mp3") else {
            print("⚠️ 未找到音频文件: \(scene.rawValue).mp3")
            isPlaying = false
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1  // 无限循环
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            print("🔊 播放: \(scene.displayName)")
        } catch {
            print("音频播放失败: \(error)")
            isPlaying = false
        }
    }
    
    /// 停止播放
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentScene = nil
    }
    
    /// 暂停
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    /// 恢复
    func resume() {
        audioPlayer?.play()
        isPlaying = true
    }
}
