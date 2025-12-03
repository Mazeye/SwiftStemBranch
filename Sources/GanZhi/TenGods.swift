import Foundation

/// Represents the Ten Gods (Shi Shen) in BaZi.
/// These describe the relationship between a Stem/Branch and the Day Master (Day Stem).
public enum TenGods: String, CaseIterable {
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
}

