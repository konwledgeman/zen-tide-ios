import Foundation

/// 专注会话记录
struct FocusSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    /// 专注时长（秒）
    let duration: Int
    /// 使用的场景
    let scene: String
    /// 是否完成（未中途放弃）
    let completed: Bool
    
    init(duration: Int, scene: SoundScene, completed: Bool) {
        self.id = UUID()
        self.date = Date()
        self.duration = duration
        self.scene = scene.rawValue
        self.completed = completed
    }
    
    /// 格式化时长
    var formattedDuration: String {
        let minutes = duration / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)小时\(mins)分钟" : "\(hours)小时"
        }
        return "\(minutes)分钟"
    }
}

/// 会话持久化管理
class SessionStore {
    private static let key = "zen_tide_sessions"
    
    /// 保存会话
    static func save(_ session: FocusSession) {
        var sessions = loadAll()
        sessions.append(session)
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    /// 加载全部会话
    static func loadAll() -> [FocusSession] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let sessions = try? JSONDecoder().decode([FocusSession].self, from: data) else {
            return []
        }
        return sessions
    }
    
    /// 今日会话
    static func todaySessions() -> [FocusSession] {
        let calendar = Calendar.current
        return loadAll().filter { calendar.isDateInToday($0.date) }
    }
    
    /// 本周会话
    static func thisWeekSessions() -> [FocusSession] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return []
        }
        return loadAll().filter { $0.date >= weekStart }
    }
}
