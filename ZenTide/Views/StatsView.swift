import SwiftUI

/// 统计页面
struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    
    var body: some View {
        ZStack {
            // 深色背景
            Color(red: 0.06, green: 0.06, blue: 0.12)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 标题
                    Text("专注统计")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                    
                    // 今日卡片
                    todayCard
                    
                    // 本周分布
                    weekChartCard
                    
                    // 累计统计
                    totalCard
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear { viewModel.refresh() }
    }
    
    // MARK: - 今日卡片
    
    private var todayCard: some View {
        HStack(spacing: 16) {
            statBlock(
                value: "\(viewModel.todayMinutes)",
                unit: "分钟",
                label: "今日专注",
                color: Color(red: 0.30, green: 0.70, blue: 0.90)
            )
            statBlock(
                value: "\(viewModel.todayCount)",
                unit: "次",
                label: "完成次数",
                color: Color(red: 0.40, green: 0.80, blue: 0.50)
            )
        }
    }
    
    private func statBlock(value: String, unit: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(unit)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            Text(label)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 本周柱状图
    
    private var weekChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("本周分布")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(viewModel.weekData) { day in
                    VStack(spacing: 6) {
                        // 柱子
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                day.minutes > 0
                                ? LinearGradient(
                                    colors: [
                                        Color(red: 0.30, green: 0.70, blue: 0.90).opacity(0.6),
                                        Color(red: 0.30, green: 0.70, blue: 0.90)
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                  )
                                : LinearGradient(
                                    colors: [Color.white.opacity(0.06)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                  )
                            )
                            .frame(height: barHeight(for: day.minutes))
                        
                        // 日期标签
                        Text(day.dayLabel)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    private func barHeight(for minutes: Int) -> CGFloat {
        let maxMinutes = max(viewModel.weekData.map(\.minutes).max() ?? 1, 1)
        let ratio = CGFloat(minutes) / CGFloat(maxMinutes)
        return max(ratio * 90, 4)
    }
    
    // MARK: - 累计卡片
    
    private var totalCard: some View {
        VStack(spacing: 12) {
            Text("累计成就")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                VStack(spacing: 4) {
                    Text("\(viewModel.totalSessions)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("完成次数")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    let hours = viewModel.totalMinutes / 60
                    let mins = viewModel.totalMinutes % 60
                    Text(hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("总时长")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
        }
        .padding(20)
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
