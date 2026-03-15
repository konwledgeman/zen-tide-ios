import AVFoundation
import Foundation

/// 白噪声合成管理器
/// 使用 AVAudioEngine 程序化生成不同场景的环境音
class SoundManager {
    static let shared = SoundManager()
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    
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
        // 先完全清理旧引擎
        if let player = playerNode {
            player.stop()
        }
        if let engine = audioEngine, engine.isRunning {
            engine.stop()
        }
        audioEngine = nil
        playerNode = nil
        isPlaying = false
        
        currentScene = scene
        
        // 创建新引擎
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        engine.attach(player)
        
        let sampleRate: Double = 44100
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return }
        
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        // 生成 5 秒循环 buffer
        let buffer = generateBuffer(scene: scene, format: format, seconds: 5.0)
        
        do {
            try engine.start()
            player.volume = volume
            player.scheduleBuffer(buffer, at: nil, options: .loops)
            player.play()
            
            self.audioEngine = engine
            self.playerNode = player
            self.isPlaying = true
            print("🔊 开始播放: \(scene.displayName)")
        } catch {
            print("音频引擎启动失败: \(error)")
        }
    }
    
    /// 停止播放
    func stop() {
        playerNode?.stop()
        if let engine = audioEngine, engine.isRunning {
            engine.stop()
        }
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
    
    // MARK: - 音频合成
    
    private func generateBuffer(scene: SoundScene, format: AVAudioFormat, seconds: Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(format.sampleRate * seconds)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        
        let left = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        let sr = Float(format.sampleRate)
        let count = Int(frameCount)
        
        switch scene {
        case .ocean:  fillOcean(left: left, right: right, count: count, sr: sr)
        case .rain:   fillRain(left: left, right: right, count: count, sr: sr)
        case .forest: fillForest(left: left, right: right, count: count, sr: sr)
        case .fire:   fillFire(left: left, right: right, count: count, sr: sr)
        }
        
        return buffer
    }
    
    // MARK: - 🌊 海浪：深沉低频 + 波浪起伏
    
    private func fillOcean(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, count: Int, sr: Float) {
        // 两层棕噪声用不同种子
        var brownL: Float = 0
        var brownR: Float = 0
        
        for i in 0..<count {
            let t = Float(i) / sr
            
            // 棕噪声（积分白噪声 → 非常低沉）
            brownL += Float.random(in: -0.02...0.02)
            brownR += Float.random(in: -0.02...0.02)
            // 防止漂移
            brownL *= 0.999
            brownR *= 0.999
            
            // 增加少量中频噪声（浪花）
            let foam = Float.random(in: -0.03...0.03)
            
            // 波浪包络：主波 ~8秒 + 大浪 ~20秒
            let wave1 = (sin(t * 0.8) * 0.5 + 0.5)       // 8 秒周期
            let wave2 = (sin(t * 0.3) * 0.3 + 0.7)       // 20 秒周期
            let envelope = wave1 * wave2
            
            let gainL = (brownL * 8.0 + foam * wave1) * envelope
            let gainR = (brownR * 8.0 + foam * 0.7 * wave1) * envelope
            
            left[i] = clamp(gainL, -0.9, 0.9)
            right[i] = clamp(gainR, -0.9, 0.9)
        }
    }
    
    // MARK: - 🌧 雨声：密集高频 + 随机雨滴
    
    private func fillRain(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, count: Int, sr: Float) {
        // 雨声主要是高频 — 用更少的滤波
        var pinkL: Float = 0, pinkR: Float = 0
        var b0L: Float = 0, b1L: Float = 0, b2L: Float = 0
        var b0R: Float = 0, b1R: Float = 0, b2R: Float = 0
        
        for i in 0..<count {
            let whiteL = Float.random(in: -1...1)
            let whiteR = Float.random(in: -1...1)
            
            // 粉噪声（Voss-McCartney 近似）— 比白噪声柔和，比棕噪声明亮
            b0L = 0.99886 * b0L + whiteL * 0.0555179
            b1L = 0.99332 * b1L + whiteL * 0.0750759
            b2L = 0.96900 * b2L + whiteL * 0.1538520
            pinkL = (b0L + b1L + b2L + whiteL * 0.5362) * 0.11
            
            b0R = 0.99886 * b0R + whiteR * 0.0555179
            b1R = 0.99332 * b1R + whiteR * 0.0750759
            b2R = 0.96900 * b2R + whiteR * 0.1538520
            pinkR = (b0R + b1R + b2R + whiteR * 0.5362) * 0.11
            
            // 白噪声混入（增加「滴答」质感）
            let highL = whiteL * 0.08
            let highR = whiteR * 0.08
            
            // 随机大雨滴
            let dropL: Float = Float.random(in: 0...1) < 0.0008 ? Float.random(in: -0.3...0.3) : 0
            let dropR: Float = Float.random(in: 0...1) < 0.0006 ? Float.random(in: -0.25...0.25) : 0
            
            left[i] = clamp(pinkL * 3.5 + highL + dropL, -0.9, 0.9)
            right[i] = clamp(pinkR * 3.5 + highR + dropR, -0.9, 0.9)
        }
    }
    
    // MARK: - 🌲 森林：轻柔风声 + 虫鸣鸟叫
    
    private func fillForest(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, count: Int, sr: Float) {
        var brownL: Float = 0, brownR: Float = 0
        var chirpPhase: Float = 0
        var chirpActive = false
        var chirpTimer: Int = 0
        var chirpDuration: Int = 0
        var chirpFreq: Float = 0
        
        for i in 0..<count {
            let t = Float(i) / sr
            
            // 非常柔和的棕噪声（微风）
            brownL += Float.random(in: -0.008...0.008)
            brownR += Float.random(in: -0.008...0.008)
            brownL *= 0.998
            brownR *= 0.998
            
            // 风声起伏（很缓慢）
            let windEnv = sin(t * 0.2) * 0.3 + 0.7
            
            // 虫鸣/鸟叫（间歇性高频正弦波）
            var chirpSample: Float = 0
            if !chirpActive {
                chirpTimer += 1
                // 大约每 2-4 秒触发一次
                if chirpTimer > Int(sr * Float.random(in: 2...4)) {
                    chirpActive = true
                    chirpTimer = 0
                    chirpDuration = Int(sr * Float.random(in: 0.1...0.4))
                    chirpFreq = Float.random(in: 2000...5000) // 鸟鸣频率
                    chirpPhase = 0
                }
            }
            
            if chirpActive {
                chirpPhase += chirpFreq / sr
                // 颤音效果
                let vibrato = sin(chirpPhase * Float.pi * 2) * sin(Float(chirpTimer) / Float(chirpDuration) * Float.pi)
                chirpSample = vibrato * 0.06
                chirpTimer += 1
                if chirpTimer >= chirpDuration {
                    chirpActive = false
                    chirpTimer = 0
                }
            }
            
            // 左右声道稍有差异，增加空间感
            left[i] = clamp(brownL * 12.0 * windEnv + chirpSample, -0.9, 0.9)
            right[i] = clamp(brownR * 12.0 * windEnv + chirpSample * 0.4, -0.9, 0.9)
        }
    }
    
    // MARK: - 🔥 篝火：低沉呼啸 + 噼啪爆裂
    
    private func fillFire(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, count: Int, sr: Float) {
        var brownL: Float = 0, brownR: Float = 0
        var crackleDecay: Float = 0
        
        for i in 0..<count {
            let t = Float(i) / sr
            
            // 中低频噪声（火焰的持续声）
            brownL += Float.random(in: -0.015...0.015)
            brownR += Float.random(in: -0.015...0.015)
            brownL *= 0.9985
            brownR *= 0.9985
            
            // 额外中频噪声（火焰更有层次）
            let midL = Float.random(in: -0.1...0.1)
            let midR = Float.random(in: -0.1...0.1)
            
            // 呼吸感（火焰跳动）
            let flicker = sin(t * 1.5) * 0.2 + sin(t * 3.7) * 0.15 + 0.65
            
            // 噼啪声（比雨滴更密集、更尖锐）
            if Float.random(in: 0...1) < 0.004 {
                crackleDecay = Float.random(in: 0.3...0.7) // 随机强度
            }
            let crackle = crackleDecay * Float.random(in: -1...1) * 0.15
            crackleDecay *= 0.95 // 快速衰减
            
            let baseL = brownL * 10.0 * flicker + midL * 0.2 * flicker
            let baseR = brownR * 10.0 * flicker + midR * 0.2 * flicker
            
            left[i] = clamp(baseL + crackle, -0.9, 0.9)
            right[i] = clamp(baseR + crackle * 0.7, -0.9, 0.9)
        }
    }
    
    // MARK: - 工具
    
    private func clamp(_ value: Float, _ min: Float, _ max: Float) -> Float {
        return Swift.min(Swift.max(value, min), max)
    }
}
