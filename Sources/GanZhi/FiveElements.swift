import Foundation

/// Represents the Five Elements (Wu Xing).
public enum FiveElements: String, CaseIterable, CustomStringConvertible {
    case wood = "木"
    case fire = "火"
    case earth = "土"
    case metal = "金"
    case water = "水"
    
    /// Localized name based on GanZhiConfig.language
    public var name: String {
        switch GanZhiConfig.language {
        case .simplifiedChinese:
            return self.rawValue
        case .traditionalChinese, .japanese:
            // Same characters
            return self.rawValue
        case .english:
            switch self {
            case .wood: return "Wood"
            case .fire: return "Fire"
            case .earth: return "Earth"
            case .metal: return "Metal"
            case .water: return "Water"
            }
        }
    }
    
    public var description: String {
        return name
    }
}
