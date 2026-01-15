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
        case followSevenKillings = "从杀格"
        case followWealth = "从财格"
        case followChild = "从儿格"
        case quZhi = "曲直格"
        case yanShang = "炎上格"
        case jiaSe = "稼穑格"
        case congGe = "从革格"
        case runXia = "润下格"
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
                case .followSevenKillings: return "從殺格"
                case .followWealth: return "從財格"
                case .followChild: return "從兒格"
                case .quZhi: return "曲直格"
                case .yanShang: return "炎上格"
                case .jiaSe: return "稼穑格"
                case .congGe: return "從革格"
                case .runXia: return "潤下格"
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
                case .followSevenKillings: return "従殺格"
                case .followWealth: return "従財格"
                case .followChild: return "従児格"
                case .quZhi: return "曲直格"
                case .yanShang: return "炎上格"
                case .jiaSe: return "稼穑格"
                case .congGe: return "従革格"
                case .runXia: return "潤下格"
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
                case .followSevenKillings: return "Follow Seven Killings"
                case .followWealth: return "Follow Wealth"
                case .followChild: return "Follow Child"
                case .quZhi: return "Qu Zhi Pattern"
                case .yanShang: return "Yan Shang Pattern"
                case .jiaSe: return "Jia Se Pattern"
                case .congGe: return "Cong Ge Pattern"
                case .runXia: return "Run Xia Pattern"
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

        // 3. Check Special Follow Patterns
        let strengths = self.tenGodStrengths
        let totalStrength = strengths.values.reduce(0, +)
        
        let resourcePeerStrength = 
            strengths[.directResource, default: 0] + strengths[.indirectResource, default: 0] +
            strengths[.friend, default: 0] + strengths[.robWealth, default: 0]
        let resourceStrength = strengths[.directResource, default: 0] + strengths[.indirectResource, default: 0]
        let wealthStrength = strengths[.directWealth, default: 0] + strengths[.indirectWealth, default: 0]
        
        // Root check logic
        let branches = [self.year.branch.value, self.month.branch.value, self.day.branch.value, self.hour.branch.value]
        let hasRoot: Bool
        if dayStem.yinYang == .yin {
            // Yin Day Master: No Ben Qi or Yu Qi of the same element
            hasRoot = branches.contains { b in 
                b.benQi == dayStem.value || b.zhongQi == dayStem.value || b.yuQi == dayStem.value
            }
        } else {
            // Yang Day Master: Absolutely no hidden stems of the same Five Element
            hasRoot = branches.contains { b in
                let hidden = b.hiddenStems
                return hidden.contains(where: { $0.fiveElement == dayStem.value.fiveElement })
            }
        }

        if !hasRoot && totalStrength > 0 {
            // Follow Seven Killings (Officer/Killer)
            let killerStrength = strengths[.sevenKillings, default: 0] + strengths[.directOfficer, default: 0]
            if primary.tenGod == .sevenKillings || primary.tenGod == .directOfficer {
                let supportStrength = max(0, resourcePeerStrength - wealthStrength)
                let killerPercentage = killerStrength / totalStrength
                if killerPercentage > 0.5 && supportStrength <= 5.5 && (killerStrength - supportStrength) >= supportStrength * 2 {
                    return Pattern(tenGod: primary.tenGod, method: .followSevenKillings, customName: "从杀格")
                }
            }
            
            // Follow Wealth (Direct/Indirect Wealth)
            let totalWealthStrength = strengths[.directWealth, default: 0] + strengths[.indirectWealth, default: 0]
            if primary.tenGod == .directWealth || primary.tenGod == .indirectWealth {
                let supportStrength = max(0, resourcePeerStrength - wealthStrength)
                let wealthPercentage = totalWealthStrength / totalStrength
                if wealthPercentage > 0.5 && supportStrength <= 5.5 && (wealthStrength - supportStrength) >= supportStrength * 2 {
                    return Pattern(tenGod: primary.tenGod, method: .followWealth, customName: "从财格")
                }
            }
            
            // Follow Child (Eating God/Hurting Officer)
            let childStrength = strengths[.eatingGod, default: 0] + strengths[.hurtingOfficer, default: 0]
            if primary.tenGod == .eatingGod || primary.tenGod == .hurtingOfficer {
                let supportStrength = max(0, resourceStrength - wealthStrength)
                let childPercentage = childStrength / totalStrength
                if childPercentage > 0.5 && supportStrength <= 3.0 && (childStrength - supportStrength) >= supportStrength * 2 {
                    return Pattern(tenGod: primary.tenGod, method: .followChild, customName: "从儿格")
                }
            }
        }
        
        // 4. Check Special "Vitalized" Patterns (专旺格)
        let elementStrengths = self.elementStrengths
        let killerStrength = strengths[.sevenKillings, default: 0] + strengths[.directOfficer, default: 0]
        
        // Helper to check for San He or San Hui of a specific element
        func hasStrongCombination(for element: FiveElements) -> Bool {
            let tripleSets: [FiveElements: Set<Branch>] = [
                .water: [.shen, .zi, .chen],
                .wood: [.hai, .mao, .wei],
                .fire: [.yin, .wu, .xu],
                .metal: [.si, .you, .chou]
            ]
            let directionalSets: [FiveElements: Set<String>] = [
                .wood: ["寅", "卯", "辰"],
                .fire: ["巳", "午", "未"],
                .metal: ["申", "酉", "戌"],
                .water: ["亥", "子", "丑"]
            ]
            
            let chartBranches = Set([self.year.branch.value, self.month.branch.value, self.day.branch.value, self.hour.branch.value])
            let chartBranchChars = Set(chartBranches.map { $0.character })
            
            if let tripleSet = tripleSets[element], tripleSet.isSubset(of: chartBranches) { return true }
            if let directionalSet = directionalSets[element], directionalSet.isSubset(of: chartBranchChars) { return true }
            
            return false
        }
        
        let dmElement = dayStem.value.fiveElement
        let killerThreshold = (dmElement == .water) ? 2.0 : 1.5
        if killerStrength < killerThreshold {
            let elementStrength = elementStrengths[dmElement, default: 0]
            
            switch dmElement {
            case .wood:
                if (hasStrongCombination(for: .wood) || elementStrength >= 24.2) {
                    return Pattern(tenGod: .friend, method: .quZhi, customName: Pattern.DeterminationMethod.quZhi.description)
                }
            case .fire:
                if (hasStrongCombination(for: .fire) || elementStrength >= 23.9) {
                    return Pattern(tenGod: .friend, method: .yanShang, customName: Pattern.DeterminationMethod.yanShang.description)
                }
            case .earth:
                let earthCount = branches.filter { [.chen, .xu, .chou, .wei].contains($0) }.count
                if (earthCount >= 3 || elementStrength >= 33.2) {
                    return Pattern(tenGod: .friend, method: .jiaSe, customName: Pattern.DeterminationMethod.jiaSe.description)
                }
            case .metal:
                if (hasStrongCombination(for: .metal) || elementStrength >= 24.4) {
                    return Pattern(tenGod: .friend, method: .congGe, customName: Pattern.DeterminationMethod.congGe.description)
                }
            case .water:
                if (hasStrongCombination(for: .water) || elementStrength >= 23.8) {
                    return Pattern(tenGod: .friend, method: .runXia, customName: Pattern.DeterminationMethod.runXia.description)
                }
            default: break
            }
        }
        
        // 5. Check Ten God Strength for auxiliary pattern
        let thresholdStrength: Double
        if primary.method == .jianLu || primary.method == .yangRen || primary.method == .yueRen {
            // For Peer patterns (JianLu/YangRen/YueRen), the "dominant" force is the entire Peer group (Self + Friend + RobWealth).
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
        
        return primary
    }
}
