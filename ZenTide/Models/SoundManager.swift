import AVFoundation

/// 白噪声合成管理器
/// 使用 AVAudioEngine 程序化生成不同场景的环境音
class SoundManager {
    static let shared = SoundManager()
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var mixerNode: AVAudioMixerNode?
    
    private(set) var isPlaying = false
    private(set) var currentScene: SoundScene?
    
    var volume: Float = 0.5 {
        didSet {
            playerNode?.volume = volume
        }
    }
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话配置失败: \(error)")
        }
    }
    
    /// 播放指定场景的白噪声
    func play(scene: SoundScene) {
        stop()
        currentScene = scene
        
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        engine.attach(player)
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        // 生成场景对应的环境音 buffer
        let buffer = generateNoiseBuffer(scene: scene, format: format, durationSeconds: 4.0)
        
        do {
            try engine.start()
            player.volume = volume
            // 无限循环播放
            player.scheduleBuffer(buffer, at: nil, options: .loops)
            player.play()
            
            self.audioEngine = engine
            self.playerNode = player
            self.isPlaying = true
        } catch {
            print("音频引擎启动失败: \(error)")
        }
    }
    
    /// 停止播放
    func stop() {
        playerNode?.stop()
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil
        isPlaying = false
        currentScene = nil
    }
    
    /// 暂停
    func pause() {
        playerNode?.pause()
        isPlaying = false
    }
    
    /// 恢复
    func resume() {
        playerNode?.play()
        isPlaying = true
    }
    
    // MARK: - 噪声生成
    
    /// 根据场景生成不同特征的噪声
    private func generateNoiseBuffer(
        scene: SoundScene,
        format: AVAudioFormat,
        durationSeconds: Double
    ) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(format.sampleRate * durationSeconds)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        
        let leftChannel = buffer.floatChannelData![0]
        let rightChannel = buffer.floatChannelData![1]
        
        // 不同场景生成不同音色的噪声
        switch scene {
        case .ocean:
            generateOceanNoise(left: leftChannel, right: rightChannel, frameCount: Int(frameCount), sampleRate: format.sampleRate)
        case .rain:
            generateRainNoise(left: leftChannel, right: rightChannel, frameCount: Int(frameCount), sampleRate: format.sampleRate)
        case .forest:
            generateForestNoise(left: leftChannel, right: rightChannel, frameCount: Int(frameCount), sampleRate: format.sampleRate)
        case .fire:
            generateFireNoise(left: leftChannel, right: rightChannel, frameCount: Int(frameCount), sampleRate: format.sampleRate)
        }
        
        return buffer
    }
    
    /// 海浪 — 低频为主，有节奏的起伏
    private func generateOceanNoise(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double) {
        var prevL: Float = 0
        var prevR: Float = 0
        
        for i in 0..<frameCount {
            let t = Double(i) / sampleRate
            
            // 白噪声基底
            let white = Float.random(in: -1...1) * 0.3
            
            // 低通滤波（模拟海浪的低沉感）
            let alpha: Float = 0.03
            prevL = prevL * (1 - alpha) + white * alpha
            prevR = prevR * (1 - alpha) + Float.random(in: -1...1) * 0.3 * alpha
            
            // 海浪起伏包络（周期约 8 秒）
            let wave = Float(sin(t * 0.8) * 0.5 + 0.5)
            let surge = Float(sin(t * 0.25) * 0.3 + 0.7)
            
            left[i] = prevL * wave * surge * 6.0
            right[i] = prevR * wave * surge * 6.0
        }
    }
    
    /// 雨声 — 高频密集噪声，偶尔有重滴
    private func generateRainNoise(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double) {
        var prevL: Float = 0
        var prevR: Float = 0
        
        for i in 0..<frameCount {
            // 粉噪声（介于白噪声和棕噪声之间，接近雨声频谱）
            let white = Float.random(in: -1...1)
            let alpha: Float = 0.15
            prevL = prevL * (1 - alpha) + white * alpha
            prevR = prevR * (1 - alpha) + Float.random(in: -1...1) * alpha
            
            // 随机雨滴（模拟大雨滴）
            let drop: Float = Float.random(in: 0...1) < 0.001 ? Float.random(in: -0.3...0.3) : 0
            
            left[i] = (prevL * 3.0 + drop)
            right[i] = (prevR * 3.0 + drop * 0.7)
        }
    }
    
    /// 森林 — 柔和的低频加偶尔的鸟鸣频率
    private func generateForestNoise(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double) {
        var prevL: Float = 0
        var prevR: Float = 0
        
        for i in 0..<frameCount {
            let t = Double(i) / sampleRate
            
            // 非常柔和的棕噪声（风声）
            let white = Float.random(in: -1...1)
            let alpha: Float = 0.02
            prevL = prevL * (1 - alpha) + white * alpha
            prevR = prevR * (1 - alpha) + Float.random(in: -1...1) * alpha
            
            // 风声起伏
            let wind = Float(sin(t * 0.3) * 0.3 + 0.7)
            
            // 偶尔的高频音（模拟鸟鸣/虫鸣）
            let chirp: Float
            if Float.random(in: 0...1) < 0.0003 {
                chirp = sin(Float(t * 2500)) * 0.05
            } else {
                chirp = 0
            }
            
            left[i] = (prevL * wind * 5.0 + chirp)
            right[i] = (prevR * wind * 5.0 + chirp * 0.5)
        }
    }
    
    /// 篝火 — 低沉噼啪声
    private func generateFireNoise(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double) {
        var prevL: Float = 0
        var prevR: Float = 0
        
        for i in 0..<frameCount {
            let t = Double(i) / sampleRate
            
            // 低频噪声基底（火焰的隆隆声）
            let white = Float.random(in: -1...1)
            let alpha: Float = 0.04
            prevL = prevL * (1 - alpha) + white * alpha
            prevR = prevR * (1 - alpha) + Float.random(in: -1...1) * alpha
            
            // 噼啪声（随机脉冲）
            let crackle: Float
            if Float.random(in: 0...1) < 0.002 {
                crackle = Float.random(in: -0.4...0.4)
            } else {
                crackle = 0
            }
            
            // 火焰呼吸感
            let breath = Float(sin(t * 0.5) * 0.2 + 0.8)
            
            left[i] = (prevL * breath * 5.0 + crackle)
            right[i] = (prevR * breath * 5.0 + crackle * 0.6)
        }
    }
}
