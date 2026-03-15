import SwiftUI

/// 首页 — 沉浸式专注计时
struct HomeView: View {
    @ObservedObject var viewModel: FocusTimerViewModel
    
    var body: some View {
        let scene = viewModel.selectedScene
        
        ZStack {
            // 动态渐变背景
            LinearGradient(
                colors: scene.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5), value: scene)
            
            // 粒子效果
            ParticleView(
                particleColor: scene.particleColor,
                isActive: viewModel.state == .running
            )
            .ignoresSafeArea()
            
            // 主内容
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                
                // 顶部标题
                VStack(spacing: 4) {
                    Text("ZenTide")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(4)
                    
                    Text(viewModel.state == .running ? "专注中" :
                         viewModel.state == .paused ? "已暂停" :
                         viewModel.state == .finished ? "🎉" : "准备好了吗")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                }
                
                Spacer()
                
                // 计时器圆环
                TimerRingView(
                    progress: viewModel.progress,
                    accentColor: scene.accentColor,
                    timeDisplay: viewModel.timeDisplay,
                    minutesDisplay: viewModel.minutesDisplay,
                    secondsDisplay: viewModel.secondsDisplay,
                    state: viewModel.state
                )
                .onTapGesture {
                    handleTap()
                }
                
                Spacer()
                
                // 操作按钮区
                controlButtons(scene: scene)
                    .padding(.bottom, 20)
                
                // 场景选择
                ScenePickerView(
                    selectedScene: $viewModel.selectedScene,
                    onSelect: { viewModel.selectScene($0) }
                )
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - 操作按钮
    
    @ViewBuilder
    private func controlButtons(scene: SoundScene) -> some View {
        switch viewModel.state {
        case .idle, .finished:
            Button {
                withAnimation(.spring(response: 0.6)) {
                    viewModel.start()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16))
                    Text("开始专注")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(scene.accentColor.opacity(0.3))
                        .overlay(
                            Capsule()
                                .stroke(scene.accentColor.opacity(0.5), lineWidth: 1)
                        )
                )
            }
            
        case .running:
            HStack(spacing: 30) {
                // 放弃
                Button {
                    viewModel.abandon()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
                
                // 暂停
                Button {
                    viewModel.pause()
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            Circle()
                                .fill(scene.accentColor.opacity(0.3))
                                .overlay(
                                    Circle()
                                        .stroke(scene.accentColor.opacity(0.5), lineWidth: 1)
                                )
                        )
                }
            }
            
        case .paused:
            HStack(spacing: 30) {
                // 放弃
                Button {
                    viewModel.abandon()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
                
                // 继续
                Button {
                    viewModel.resume()
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            Circle()
                                .fill(scene.accentColor.opacity(0.3))
                                .overlay(
                                    Circle()
                                        .stroke(scene.accentColor.opacity(0.5), lineWidth: 1)
                                )
                        )
                }
            }
        }
    }
    
    private func handleTap() {
        switch viewModel.state {
        case .idle:
            withAnimation(.spring(response: 0.6)) {
                viewModel.start()
            }
        case .running:
            viewModel.pause()
        case .paused:
            viewModel.resume()
        case .finished:
            withAnimation(.spring(response: 0.6)) {
                viewModel.start()
            }
        }
    }
}
