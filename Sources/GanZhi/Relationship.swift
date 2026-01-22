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

    // MARK: - Special Relationships
    case fuYin = "伏吟"  // Identical
    case fanYin = "反吟"  // Heaven Clash Earth Clash

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
            case .fuYin: return "伏吟"
            case .fanYin: return "反吟"
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
            case .fuYin: return "伏吟"
            case .fanYin: return "反吟"
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
            case .fuYin: return "Fu Yin"
            case .fanYin: return "Fan Yin"
            }
        }
    }
}

/// Represents a specific interaction between pillars in the chart.
public struct Relationship: CustomStringConvertible {
    public let type: RelationshipType
    public let pillars: [String]  // Decoupled from FourPillars.PillarType
    public let characters: String
    /// The Five Element associated with this relationship (e.g., .wood for Wood Directional Harmony).
    public let relatedElement: FiveElements?

    public let isAffectionate: Bool  // New: For Stem Clash (TenGod based)

    public init(
        type: RelationshipType, pillars: [String], characters: String,
        relatedElement: FiveElements? = nil, isAffectionate: Bool = false
    ) {
        self.type = type
        self.pillars = pillars
        self.characters = characters
        self.relatedElement = relatedElement
        self.isAffectionate = isAffectionate
    }

    public struct Listing {
        public let pillars: String
        public let characters: String
        public let type: String
    }

    public var listing: Listing {
        let pillarNames = pillars.joined(separator: "-")
        var typeName = type.name
        if isAffectionate && type == .stemClash {
            typeName += " (Affectionate)"
        }
        return Listing(
            pillars: pillarNames,
            characters: characters,
            type: typeName
        )
    }

    public var description: String {
        let l = listing
        return "[\(l.pillars)] \(l.characters)\(l.type)"
    }

    // MARK: - Analysis Logic

    /// Analyzes the relationship between two StemBranch pairs.
    /// - Parameters:
    ///   - lhs: The first StemBranch (e.g., Year Pillar).
    ///   - rhs: The second StemBranch (e.g., Grand Luck).
    ///   - lhsName: Name of the first source (e.g., "Year").
    ///   - rhsName: Name of the second source (e.g., "Grand Luck").
    /// - Returns: A list of relationships found.
    public static func analyze(lhs: StemBranch, rhs: StemBranch, lhsName: String, rhsName: String)
        -> [Relationship]
    {
        var rels: [Relationship] = []
        let sources = [lhsName, rhsName]
        let stems = [lhs.stem, rhs.stem]
        let branches = [lhs.branch, rhs.branch]

        // 0. Special Relationships

        // Fu Yin (伏吟): Identical Pillar
        if lhs == rhs {
            rels.append(
                Relationship(
                    type: .fuYin,
                    pillars: sources,
                    characters: lhs.character + rhs.character
                ))
        }

        // Fan Yin (反吟): Tian Ke Di Chong (Heavenly Clash Earthly Clash)
        // Strictly: Stem Clash AND Branch Clash
        let isStemClash = abs(stems[0].index - stems[1].index) == 6
        let isBranchClash = abs(branches[0].index - branches[1].index) == 6

        if isStemClash && isBranchClash {
            rels.append(
                Relationship(
                    type: .fanYin,
                    pillars: sources,
                    characters: lhs.character + rhs.character
                ))
        }

        // 1. Stem Relationships

        // Combination
        if abs(stems[0].index - stems[1].index) == 5 {
            rels.append(
                Relationship(
                    type: .stemCombination,
                    pillars: sources,
                    characters: stems[0].character + stems[1].character,
                    relatedElement: nil  // TODO: Add transformation logic if needed
                ))
        }

        // Clash
        if abs(stems[0].index - stems[1].index) == 6 {
            // Determine Affectionate vs Ruthless
            // Ruthless (Seven Killings): Same Polarity Control
            // Affectionate (Direct Officer): Diff Polarity Control
            // But Clash is always index diff 6, which implies Same Polarity (e.g. Jia(1) vs Geng(7)).
            // Wait, standard Clash (Jia-Geng) IS Seven Killings (Yang Metal attacks Yang Wood).
            // Is there any "Affectionate Clash"?
            // User said: "Affectionate/Ruthless control is basically Ten Gods... Seven Killings is ruthless, Direct Officer is affectionate."
            // Direct Officer (e.g. Jia(1) vs Xin(8)) involves diff polarity.
            // But simple Clash (Chong) is usually strictly defined as the 6th position (Opposition), which is same polarity.
            // Maybe user implies "Control" (Ke) generally, not just "Clash" (Chong).
            // But standard list includes "Stem Clash".
            // If we strictly check specific clashes, they are usually ruthless.
            // However, we will mark `isAffectionate = false` (Ruthless) for standard Clashes.
            // If user wants generic Control detection, that's broader.
            // We'll stick to standard Clashes for now.
            rels.append(
                Relationship(
                    type: .stemClash,
                    pillars: sources,
                    characters: stems[0].character + stems[1].character,
                    isAffectionate: false
                ))
        }

        // 2. Branch Relationships

        let b1 = branches[0]
        let b2 = branches[1]
        let bChars = b1.character + b2.character

        // Six Harmony
        let sixHarmonyPairs: Set<Set<Branch>> = [
            [.zi, .chou], [.yin, .hai], [.mao, .xu],
            [.chen, .you], [.si, .shen], [.wu, .wei],
        ]
        if sixHarmonyPairs.contains([b1, b2]) {
            rels.append(Relationship(type: .branchSixHarmony, pillars: sources, characters: bChars))
        }

        // Clash
        if abs(b1.index - b2.index) == 6 {
            rels.append(Relationship(type: .branchClash, pillars: sources, characters: bChars))
        }

        // Harm
        let harmPairs: Set<Set<Branch>> = [
            [.zi, .wei], [.chou, .wu], [.yin, .si],
            [.mao, .chen], [.shen, .hai], [.you, .xu],
        ]
        if harmPairs.contains([b1, b2]) {
            rels.append(Relationship(type: .branchHarm, pillars: sources, characters: bChars))
        }

        // Punishment (Pairwise)
        if b1 == b2 && [.chen, .wu, .you, .hai].contains(b1) {
            rels.append(Relationship(type: .branchPunishment, pillars: sources, characters: bChars))
        }
        let punishPairs: Set<Set<Branch>> = [
            [.zi, .mao], [.yin, .si], [.si, .shen], [.shen, .yin],
            [.chou, .wei], [.wei, .xu], [.xu, .chou],
        ]
        if punishPairs.contains([b1, b2]) {
            rels.append(Relationship(type: .branchPunishment, pillars: sources, characters: bChars))
        }

        // Destruction
        let destructPairs: Set<Set<Branch>> = [
            [.zi, .you], [.si, .shen], [.yin, .hai],
            [.chen, .chou], [.wu, .mao], [.xu, .wei],
        ]
        if destructPairs.contains([b1, b2]) {
            rels.append(
                Relationship(type: .branchDestruction, pillars: sources, characters: bChars))
        }

        return rels
    }
}
