import SwiftUI

/// 设置页面
struct SettingsView: View {
    @ObservedObject var viewModel: FocusTimerViewModel
    
    private let durationOptions = [15, 25, 30, 45, 60]
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.12)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("设置")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                    
                    // 专注时长
                    settingSection(title: "专注时长") {
                        HStack(spacing: 10) {
                            ForEach(durationOptions, id: \.self) { min in
                                Button {
                                    viewModel.setDuration(min)
                                } label: {
                                    Text("\(min)")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(viewModel.focusDuration == min ? .white : .white.opacity(0.4))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(viewModel.focusDuration == min
                                                      ? viewModel.selectedScene.accentColor.opacity(0.3)
                                                      : Color.white.opacity(0.06))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(viewModel.focusDuration == min
                                                        ? viewModel.selectedScene.accentColor.opacity(0.5)
                                                        : Color.clear, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        Text("分钟")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    
                    // 声音设置
                    settingSection(title: "声音") {
                        Toggle(isOn: $viewModel.soundEnabled) {
                            Text("白噪声")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .tint(viewModel.selectedScene.accentColor)
                        
                        if viewModel.soundEnabled {
                            HStack {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(.white.opacity(0.3))
                                    .font(.system(size: 12))
                                Slider(value: $viewModel.volume, in: 0...1)
                                    .tint(viewModel.selectedScene.accentColor)
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.white.opacity(0.3))
                                    .font(.system(size: 12))
                            }
                        }
                    }
                    
                    // 关于
                    settingSection(title: "关于") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("版本")
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("1.0.0 (MVP)")
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .font(.system(size: 14, design: .rounded))
                            
                            Divider()
                                .background(Color.white.opacity(0.06))
                            
                            HStack {
                                Text("开发者")
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text("KnowledgeMan")
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .font(.system(size: 14, design: .rounded))
                        }
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func settingSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: 16) {
                content()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
}
