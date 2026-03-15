import AVFoundation

/// 白噪声音频管理器
/// MVP 阶段使用系统音效模拟，后续可替换为真实白噪声文件
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
        // 配置音频会话
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话配置失败: \(error)")
        }
    }
    
    /// 播放指定场景的白噪声
    func play(scene: SoundScene) {
        currentScene = scene
        
        // 尝试加载音频文件（Bundle 中）
        if let url = Bundle.main.url(forResource: scene.rawValue, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1  // 无限循环
                audioPlayer?.volume = volume
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("音频播放失败: \(error)")
            }
        } else {
            // MVP: 没有音频文件时静默运行
            isPlaying = true
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
