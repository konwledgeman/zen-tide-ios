import SwiftUI

/// 主内容视图 — Tab 导航
struct ContentView: View {
    @StateObject private var timerVM = FocusTimerViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 页面内容
            TabView(selection: $selectedTab) {
                HomeView(viewModel: timerVM)
                    .tag(0)
                
                StatsView()
                    .tag(1)
                
                SettingsView(viewModel: timerVM)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // 自定义底部导航栏
            if timerVM.state != .running {
                customTabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: timerVM.state)
    }
    
    // MARK: - 自定义 Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(icon: "timer", label: "专注", tag: 0)
            tabButton(icon: "chart.bar.fill", label: "统计", tag: 1)
            tabButton(icon: "gearshape.fill", label: "设置", tag: 2)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        )
        .padding(.horizontal, 60)
        .padding(.bottom, 20)
    }
    
    private func tabButton(icon: String, label: String, tag: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(selectedTab == tag ? timerVM.selectedScene.accentColor : .white.opacity(0.4))
                
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(selectedTab == tag ? timerVM.selectedScene.accentColor : .white.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
