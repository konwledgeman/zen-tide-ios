import SwiftUI

/// 圆环计时器视图
struct TimerRingView: View {
    let progress: CGFloat
    let accentColor: Color
    let timeDisplay: String
    let minutesDisplay: String
    let secondsDisplay: String
    let state: TimerState
    
    /// 呼吸动画缩放
    @State private var breathScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 背景光晕
            Circle()
                .fill(accentColor.opacity(0.08))
                .frame(width: 280, height: 280)
                .scaleEffect(breathScale)
            
            // 背景轨道
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 4)
                .frame(width: 240, height: 240)
            
            // 进度环
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [accentColor.opacity(0.5), accentColor],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * Double(progress))
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: progress)
            
            // 进度端点光点
            if progress > 0.01 {
                Circle()
                    .fill(accentColor)
                    .frame(width: 12, height: 12)
                    .shadow(color: accentColor.opacity(0.6), radius: 8)
                    .offset(y: -120)
                    .rotationEffect(.degrees(360 * Double(progress)))
            }
            
            // 时间显示
            VStack(spacing: 4) {
                if state == .finished {
                    // 完成状态
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(accentColor)
                    Text("专注完成")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    // 时间显示
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(minutesDisplay)
                            .font(.system(size: 72, weight: .thin, design: .rounded))
                            .foregroundColor(.white)
                        Text(":")
                            .font(.system(size: 56, weight: .thin, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .offset(y: -4)
                        Text(secondsDisplay)
                            .font(.system(size: 72, weight: .thin, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .monospacedDigit()
                    
                    if state == .idle {
                        Text("点击开始专注")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    } else if state == .paused {
                        Text("已暂停")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(accentColor.opacity(0.7))
                    }
                }
            }
        }
        .onAppear {
            if state == .running {
                startBreathing()
            }
        }
        .onChange(of: state) { _, newState in
            if newState == .running {
                startBreathing()
            } else {
                breathScale = 1.0
            }
        }
    }
    
    private func startBreathing() {
        withAnimation(
            .easeInOut(duration: 4.0)
            .repeatForever(autoreverses: true)
        ) {
            breathScale = 1.06
        }
    }
}
