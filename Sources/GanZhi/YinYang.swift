import Foundation

/// Represents Yin and Yang.
public enum YinYang: String, CaseIterable, CustomStringConvertible {
    case yin = "阴"
    case yang = "阳"
    
    /// Localized name based on GanZhiConfig.language
    public var name: String {
        switch GanZhiConfig.language {
        case .simplifiedChinese:
            return self.rawValue
        case .traditionalChinese:
            return self == .yin ? "陰" : "陽"
        case .japanese:
            return self == .yin ? "陰" : "陽"
        case .english:
            return self == .yin ? "Yin" : "Yang"
        }
    }
    
    public var description: String {
        return name
    }
}
