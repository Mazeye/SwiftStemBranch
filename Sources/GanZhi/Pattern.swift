import Foundation

/// Represents the BaZi Pattern (GeJu).
public struct Pattern: CustomStringConvertible {
    /// The method used to determine the pattern.
    public enum DeterminationMethod: String, CustomStringConvertible {
        case jianLu = "建禄格" // Month Branch is Lin Guan
        case yangRen = "羊刃格" // Yang Day Master Month Branch is Di Wang
        case transpiredMonthStem = "月支藏干透出月干"
        case transpiredYearStem = "月支藏干透出年干"
        case transpiredHourStem = "月支藏干透出时干"
        case monthBranchMainQi = "月支本气"
        case dominantStrength = "十神成势"
        case yueRen = "月刃格"
        case followSevenKillings = "身弱杀强，建议去印比从杀"
        case special = "特殊格局"
        
        public var description: String {
            switch GanZhiConfig.language {
            case .simplifiedChinese:
                return self.rawValue
            case .traditionalChinese:
                switch self {
                case .jianLu: return "建祿格"
                case .yangRen: return "羊刃格"
                case .transpiredMonthStem: return "月支藏干透出月干"
                case .transpiredYearStem: return "月支藏干透出年干"
                case .transpiredHourStem: return "月支藏干透出時干"
                case .monthBranchMainQi: return "月支本氣"
                case .dominantStrength: return "十神成勢"
                case .yueRen: return "月刃格"
                case .followSevenKillings: return "身弱殺強，建議去印比從殺"
                case .special: return "特殊格局"
                }
            case .japanese:
                switch self {
                case .jianLu: return "建禄格"
                case .yangRen: return "羊刃格"
                case .transpiredMonthStem: return "月支蔵干の月干透出"
                case .transpiredYearStem: return "月支蔵干の年干透出"
                case .transpiredHourStem: return "月支蔵干の時干透出"
                case .monthBranchMainQi: return "月支本気"
                case .dominantStrength: return "通変星が勢力を成した"
                case .yueRen: return "月刃格"
                case .followSevenKillings: return "身弱殺強、印比を捨てて殺に従うべし"
                case .special: return "特殊格局"
                }
            case .english:
                switch self {
                case .jianLu: return "Jian Lu Pattern"
                case .yangRen: return "Yang Ren Pattern"
                case .transpiredMonthStem: return "Month Branch Hidden Stem transpired in Month"
                case .transpiredYearStem: return "Month Branch Hidden Stem transpired in Year"
                case .transpiredHourStem: return "Month Branch Hidden Stem transpired in Hour"
                case .monthBranchMainQi: return "Month Branch Main Qi"
                case .dominantStrength: return "The ten god is dominant"
                case .yueRen: return "Yue Ren Pattern"
                case .followSevenKillings: return "Weak self with strong killer, follow the killer"
                case .special: return "Special Pattern"
                }
            }
        }
    }
    
    /// The main Ten God forming the pattern.
    public let tenGod: TenGods
    
    /// The method used to find this pattern.
    public let method: DeterminationMethod
    
    /// Custom name or explanation (useful for Special patterns).
    /// If nil, the default name is tenGod + "格" (localized).
    public let customName: String?
    
    /// An optional auxiliary Ten God that is stronger than the primary one.
    public let auxiliaryTenGod: TenGods?
    
    /// The method used to find the auxiliary pattern.
    public let auxiliaryMethod: DeterminationMethod?
    
    public init(tenGod: TenGods, method: DeterminationMethod, customName: String? = nil, auxiliaryTenGod: TenGods? = nil, auxiliaryMethod: DeterminationMethod? = nil) {
        self.tenGod = tenGod
        self.method = method
        self.customName = customName
        self.auxiliaryTenGod = auxiliaryTenGod
        self.auxiliaryMethod = auxiliaryMethod
    }
    
    public var description: String {
        func getName(for tg: TenGods, withMethod m: DeterminationMethod?) -> String {
            if tg == .friend { return DeterminationMethod.jianLu.description }
            if tg == .robWealth {
                return (m == .yangRen) ? DeterminationMethod.yangRen.description : DeterminationMethod.yueRen.description
            }
            
            let suffix: String
            switch GanZhiConfig.language {
            case .simplifiedChinese, .traditionalChinese, .japanese:
                suffix = "格"
            case .english:
                suffix = " Pattern"
            }
            return tg.name + suffix
        }

        let primaryDescription: String
        if let name = customName {
            primaryDescription = name
        } else {
            primaryDescription = getName(for: tenGod, withMethod: method)
        }
        
        if let aux = auxiliaryTenGod {
            let auxName = getName(for: aux, withMethod: auxiliaryMethod)
            return "\(primaryDescription)/\(auxName)"
        } else {
            return primaryDescription
        }
    }
    
    /// The combined description of the determination method(s).
    public var methodDescription: String {
        if let auxMethod = auxiliaryMethod {
            return "\(method.description)/\(auxMethod.description)"
        }
        return method.description
    }
}

extension FourPillars {
    
    public func determinePattern() -> Pattern {
        let dayStem = self.day.stem
        let monthBranch = self.month.branch
        let hiddenStems = monthBranch.hiddenStems
        let stage = dayStem.value.lifeStage(in: monthBranch.value)
        
        func getPrimary() -> Pattern {
            if stage == .linGuan { return Pattern(tenGod: .friend, method: .jianLu) }
            if stage == .diWang {
                return (dayStem.yinYang == .yang) ? Pattern(tenGod: .robWealth, method: .yangRen) : Pattern(tenGod: .robWealth, method: .yueRen)
            }
            
            var candidates: [Pattern] = []
            if hiddenStems.contains(self.month.stem.value) { candidates.append(Pattern(tenGod: self.tenGod(for: self.month.stem), method: .transpiredMonthStem)) }
            if hiddenStems.contains(self.year.stem.value) { candidates.append(Pattern(tenGod: self.tenGod(for: self.year.stem), method: .transpiredYearStem)) }
            if hiddenStems.contains(self.hour.stem.value) { candidates.append(Pattern(tenGod: self.tenGod(for: self.hour.stem), method: .transpiredHourStem)) }
            
            if let monthPattern = candidates.first(where: { $0.method == .transpiredMonthStem }), monthPattern.tenGod != .friend, monthPattern.tenGod != .robWealth { return monthPattern }
            
            for hiddenStem in hiddenStems {
                let tenGod = self.tenGod(for: hiddenStem)
                if tenGod == .friend || tenGod == .robWealth { continue }
                if self.month.stem.value == hiddenStem { return Pattern(tenGod: tenGod, method: .transpiredMonthStem) }
                if self.year.stem.value == hiddenStem { return Pattern(tenGod: tenGod, method: .transpiredYearStem) }
                if self.hour.stem.value == hiddenStem { return Pattern(tenGod: tenGod, method: .transpiredHourStem) }
            }
            
            let mainQi = monthBranch.mainQi
            let mainQiTenGod = TenGods.calculate(dayMaster: dayStem.value, targetElement: mainQi.fiveElement, targetYinYang: mainQi.yinYang)
            if mainQiTenGod != .friend && mainQiTenGod != .robWealth { return Pattern(tenGod: mainQiTenGod, method: .monthBranchMainQi) }
            
            return candidates.first(where: { $0.method == .transpiredMonthStem }) ?? candidates.first ?? Pattern(tenGod: mainQiTenGod, method: .monthBranchMainQi)
        }
        
        let primary = getPrimary()

        // 3. Check Ten God Strength for auxiliary pattern
        let strengths = self.tenGodStrengths
        let primaryStrength = strengths[primary.tenGod, default: 0]
        
        let thresholdStrength: Double
        if primary.tenGod == .friend || primary.tenGod == .robWealth {
            // For Peer patterns (JianLu/YangRen), the "dominant" force is the entire Peer group (Self + Friend + RobWealth).
            // An auxiliary must be stronger than the entire Body to be considered valid (e.g., extremely strong Wealth).
            // Note: tenGodStrengths excludes Day Master energy, so we add it manually.
            let selfEnergy = self.day.stem.energy
            let friendScore = strengths[.friend, default: 0]
            let robScore = strengths[.robWealth, default: 0]
            thresholdStrength = friendScore + robScore + selfEnergy
        } else {
            // For other patterns (e.g. Wealth), just compare against the primary Ten God strength.
            thresholdStrength = strengths[primary.tenGod, default: 0]
        }
        
        // Find strongest non-peer (not Friend or Rob Wealth)
        let nonPeers = strengths.filter { $0.key != .friend && $0.key != .robWealth }
        if let strongest = nonPeers.max(by: { $0.value < $1.value }) {
            // Must be strictly stronger than the threshold
            if strongest.value > thresholdStrength && strongest.key != primary.tenGod {
                return Pattern(tenGod: primary.tenGod, method: primary.method, customName: primary.customName, auxiliaryTenGod: strongest.key, auxiliaryMethod: .dominantStrength)
            }
        }
        
        // 4. Check Special Seven Killings Pattern (From Ge / Follow the Killer)
        let totalStrength = strengths.values.reduce(0, +)
        let supportStrength = strengths[.directResource, default: 0] + strengths[.friend, default: 0]
        
        // Conditions:
        // - DM is Yin
        // - No root (Ben Qi or Yu Qi) in any branch
        // - Primary is Seven Killings and no auxiliary
        // - Seven Killings strength > 50%
        // - Support (Direct Resource + non-DM Friend) <= 1.0
        if dayStem.yinYang == .yin && primary.tenGod == .sevenKillings {
            // Check roots
            let branches = [self.year.branch.value, self.month.branch.value, self.day.branch.value, self.hour.branch.value]
            let hasRoot = branches.contains { b in 
                b.benQi == dayStem.value || b.yuQi == dayStem.value
            }
            
            if !hasRoot {
                let primaryStrengthPercentage = (totalStrength > 0) ? (primaryStrength / totalStrength) : 0
                // supportStrength includes DM energy (1.0). 
                // So supportStrength <= 2.0 means at most one extra floating Zheng Yin or Bi Jian.
                if primaryStrengthPercentage > 0.5 && supportStrength <= 2.0 {
                    return Pattern(tenGod: .sevenKillings, method: .followSevenKillings, customName: "特殊七杀格（从格）")
                }
            }
        }
        
        return primary
    }
}
