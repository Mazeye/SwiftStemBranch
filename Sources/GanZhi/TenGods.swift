import Foundation

/// Represents the Ten Gods (Shi Shen) in BaZi.
/// These describe the relationship between a Stem/Branch and the Day Master (Day Stem).
public enum TenGods: String, CaseIterable, CustomStringConvertible {
    case friend = "比肩"        // Same Element, Same Polarity
    case robWealth = "劫财"     // Same Element, Different Polarity
    case eatingGod = "食神"     // Output Element, Same Polarity
    case hurtingOfficer = "伤官" // Output Element, Different Polarity
    case directWealth = "正财"  // Controlled Element, Different Polarity
    case indirectWealth = "偏财" // Controlled Element, Same Polarity
    case directOfficer = "正官" // Controlling Element, Different Polarity
    case sevenKillings = "七杀" // Controlling Element, Same Polarity
    case directResource = "正印" // Producing Element, Different Polarity
    case indirectResource = "偏印" // Producing Element, Same Polarity
    
    /// Localized name based on GanZhiConfig.language.
    /// Default (Simplified Chinese) returns rawValue.
    public var name: String {
        switch GanZhiConfig.language {
        case .simplifiedChinese:
            return self.rawValue
        case .traditionalChinese:
            switch self {
            case .friend: return "比肩"
            case .robWealth: return "劫財"
            case .eatingGod: return "食神"
            case .hurtingOfficer: return "傷官"
            case .directWealth: return "正財"
            case .indirectWealth: return "偏財"
            case .directOfficer: return "正官"
            case .sevenKillings: return "七殺"
            case .directResource: return "正印"
            case .indirectResource: return "偏印"
            }
        case .japanese:
            switch self {
            case .friend: return "比肩"
            case .robWealth: return "劫財"
            case .eatingGod: return "食神"
            case .hurtingOfficer: return "傷官"
            case .directWealth: return "正財"
            case .indirectWealth: return "偏財"
            case .directOfficer: return "正官"
            case .sevenKillings: return "偏官"
            case .directResource: return "印綬"
            case .indirectResource: return "偏印"
            }
        case .english:
            switch self {
            case .friend: return "Friend"
            case .robWealth: return "Rob Wealth"
            case .eatingGod: return "Eating God"
            case .hurtingOfficer: return "Hurting Officer"
            case .directWealth: return "Direct Wealth"
            case .indirectWealth: return "Indirect Wealth"
            case .directOfficer: return "Direct Officer"
            case .sevenKillings: return "Seven Killings"
            case .directResource: return "Direct Resource"
            case .indirectResource: return "Indirect Resource"
            }
        }
    }
    
    public var description: String {
        return name
    }
}
