import SwiftUI

/// 粒子效果视图
/// 营造沉浸式自然氛围
struct ParticleView: View {
    let particleColor: Color
    let isActive: Bool
    
    @State private var particles: [Particle] = []
    @State private var timer: Timer?
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var speed: CGFloat
    }
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.x * size.width,
                        y: particle.y * size.height,
                        width: particle.size,
                        height: particle.size
                    )
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(particleColor.opacity(particle.opacity))
                    )
                }
            }
            .onAppear {
                initParticles()
                startAnimation()
            }
            .onDisappear {
                timer?.invalidate()
            }
            .onChange(of: isActive) { _, active in
                if active {
                    startAnimation()
                } else {
                    timer?.invalidate()
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func initParticles() {
        particles = (0..<30).map { _ in
            Particle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.1...0.4),
                speed: CGFloat.random(in: 0.0002...0.001)
            )
        }
    }
    
    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30, repeats: true) { _ in
            for i in particles.indices {
                particles[i].y -= particles[i].speed
                particles[i].x += CGFloat.random(in: -0.0005...0.0005)
                
                // 粒子飘出屏幕顶部后重置到底部
                if particles[i].y < -0.05 {
                    particles[i].y = 1.05
                    particles[i].x = CGFloat.random(in: 0...1)
                    particles[i].opacity = Double.random(in: 0.1...0.4)
                }
            }
        }
    }
}
