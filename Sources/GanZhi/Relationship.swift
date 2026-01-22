import Foundation

/// Defines the types of relationships between Heavenly Stems and Earthly Branches.
public enum RelationshipType: String, CaseIterable {
    // MARK: - Stem Relationships
    case stemCombination = "天干五合"
    case stemClash = "天干相冲"
    
    // MARK: - Branch Relationships
    case branchSixHarmony = "地支六合"
    case branchTripleHarmony = "地支三合"
    case branchDirectional = "地支三会"
    case branchClash = "地支六冲"
    case branchHarm = "地支六害"
    case branchPunishment = "地支相刑"
    case branchDestruction = "地支相破"
    
    public var name: String {
        switch GanZhiConfig.language {
        case .simplifiedChinese: return self.rawValue
        case .traditionalChinese:
            switch self {
            case .stemCombination: return "天干五合"
            case .stemClash: return "天干相衝"
            case .branchSixHarmony: return "地支六合"
            case .branchTripleHarmony: return "地支三合"
            case .branchDirectional: return "地支三會"
            case .branchClash: return "地支六衝"
            case .branchHarm: return "地支六害"
            case .branchPunishment: return "地支相刑"
            case .branchDestruction: return "地支相破"
            }
        case .japanese:
            switch self {
            case .stemCombination: return "干合"
            case .stemClash: return "相冲"
            case .branchSixHarmony: return "支合"
            case .branchTripleHarmony: return "三合"
            case .branchDirectional: return "三会"
            case .branchClash: return "六冲"
            case .branchHarm: return "六害"
            case .branchPunishment: return "刑"
            case .branchDestruction: return "破"
            }
        case .english:
            switch self {
            case .stemCombination: return "Stem Combination"
            case .stemClash: return "Stem Clash"
            case .branchSixHarmony: return "Branch Six Harmony"
            case .branchTripleHarmony: return "Branch Triple Harmony"
            case .branchDirectional: return "Branch Directional Harmony"
            case .branchClash: return "Branch Clash"
            case .branchHarm: return "Branch Harm"
            case .branchPunishment: return "Branch Punishment"
            case .branchDestruction: return "Branch Destruction"
            }
        }
    }
}

/// Represents a specific interaction between pillars in the chart.
public struct Relationship: CustomStringConvertible {
    public let type: RelationshipType
    public let pillars: [FourPillars.PillarType]
    public let characters: String
    /// The Five Element associated with this relationship (e.g., .wood for Wood Directional Harmony).
    public let relatedElement: FiveElements?
    
    public init(type: RelationshipType, pillars: [FourPillars.PillarType], characters: String, relatedElement: FiveElements? = nil) {
        self.type = type
        self.pillars = pillars
        self.characters = characters
        self.relatedElement = relatedElement
    }
    
    public var description: String {
        let pillarNames = pillars.map { $0.name }.joined(separator: "-")
        return "[\(pillarNames)] \(characters)\(type.name)"
    }
}
