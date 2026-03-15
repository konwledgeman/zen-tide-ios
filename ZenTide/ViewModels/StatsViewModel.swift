import SwiftUI

/// 统计 ViewModel
class StatsViewModel: ObservableObject {
    @Published var todayMinutes: Int = 0
    @Published var todayCount: Int = 0
    @Published var weekData: [DayStats] = []
    @Published var totalSessions: Int = 0
    @Published var totalMinutes: Int = 0
    
    struct DayStats: Identifiable {
        let id = UUID()
        let dayLabel: String
        let minutes: Int
    }
    
    func refresh() {
        let allSessions = SessionStore.loadAll()
        let todaySessions = SessionStore.todaySessions()
        let weekSessions = SessionStore.thisWeekSessions()
        
        // 今日统计
        todayMinutes = todaySessions.reduce(0) { $0 + $1.duration } / 60
        todayCount = todaySessions.filter { $0.completed }.count
        
        // 总计
        totalSessions = allSessions.filter { $0.completed }.count
        totalMinutes = allSessions.reduce(0) { $0 + $1.duration } / 60
        
        // 本周每日分布
        let calendar = Calendar.current
        let today = Date()
        let weekdayLabels = ["日", "一", "二", "三", "四", "五", "六"]
        
        var dailyData: [DayStats] = []
        for dayOffset in (-6...0) {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                let dayMinutes = weekSessions
                    .filter { calendar.isDate($0.date, inSameDayAs: date) }
                    .reduce(0) { $0 + $1.duration } / 60
                let weekday = calendar.component(.weekday, from: date)
                let label = weekdayLabels[weekday - 1]
                dailyData.append(DayStats(dayLabel: label, minutes: dayMinutes))
            }
        }
        weekData = dailyData
    }
}
