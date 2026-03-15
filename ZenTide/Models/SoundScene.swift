import SwiftUI

/// 自然声音场景
/// 每种场景对应独特的渐变配色和白噪声
enum SoundScene: String, CaseIterable, Identifiable {
    case ocean = "ocean"
    case rain = "rain"
    case forest = "forest"
    case fire = "fire"
    
    var id: String { rawValue }
    
    /// 场景显示名
    var displayName: String {
        switch self {
        case .ocean: return "海浪"
        case .rain: return "雨声"
        case .forest: return "森林"
        case .fire: return "篝火"
        }
    }
    
    /// 场景图标
    var icon: String {
        switch self {
        case .ocean: return "🌊"
        case .rain: return "🌧"
        case .forest: return "🌲"
        case .fire: return "🔥"
        }
    }
    
    /// 场景渐变色（深色主题）
    var gradientColors: [Color] {
        switch self {
        case .ocean:
            return [Color(red: 0.05, green: 0.10, blue: 0.25),
                    Color(red: 0.08, green: 0.25, blue: 0.45)]
        case .rain:
            return [Color(red: 0.08, green: 0.08, blue: 0.15),
                    Color(red: 0.12, green: 0.18, blue: 0.35)]
        case .forest:
            return [Color(red: 0.05, green: 0.15, blue: 0.10),
                    Color(red: 0.08, green: 0.28, blue: 0.18)]
        case .fire:
            return [Color(red: 0.18, green: 0.08, blue: 0.05),
                    Color(red: 0.35, green: 0.15, blue: 0.08)]
        }
    }
    
    /// 高亮色（用于进度环和按钮）
    var accentColor: Color {
        switch self {
        case .ocean: return Color(red: 0.30, green: 0.70, blue: 0.90)
        case .rain: return Color(red: 0.50, green: 0.60, blue: 0.85)
        case .forest: return Color(red: 0.40, green: 0.80, blue: 0.50)
        case .fire: return Color(red: 0.95, green: 0.55, blue: 0.25)
        }
    }
    
    /// 粒子颜色
    var particleColor: Color {
        switch self {
        case .ocean: return Color(red: 0.50, green: 0.80, blue: 1.0).opacity(0.3)
        case .rain: return Color(red: 0.60, green: 0.70, blue: 0.95).opacity(0.25)
        case .forest: return Color(red: 0.55, green: 0.90, blue: 0.60).opacity(0.2)
        case .fire: return Color(red: 1.0, green: 0.60, blue: 0.20).opacity(0.25)
        }
    }
}
