import Foundation

/// Represents the BaZi Pattern (GeJu).
public struct Pattern: CustomStringConvertible {
    /// The method used to determine the pattern.
    public enum DeterminationMethod: String, CustomStringConvertible {
        case jianLu = "建禄格" // Month Branch is Lin Guan
        case yueRen = "月刃格" // Yin Day Master Month Branch is Di Wang
        case yangRen = "羊刃格" // Yang Day Master Month Branch is Di Wang
        case transpiredMonthStem = "月支藏干透出月干"
        case transpiredYearStem = "月支藏干透出年干"
        case transpiredHourStem = "月支藏干透出时干"
        case monthBranchMainQi = "月支本气"
        case special = "特殊格局"
        
        public var description: String {
            switch GanZhiConfig.language {
            case .simplifiedChinese:
                return self.rawValue
            case .traditionalChinese:
                switch self {
                case .jianLu: return "建祿格"
                case .yueRen: return "月刃格"
                case .yangRen: return "羊刃格"
                case .transpiredMonthStem: return "月支藏干透出月干"
                case .transpiredYearStem: return "月支藏干透出年干"
                case .transpiredHourStem: return "月支藏干透出時干"
                case .monthBranchMainQi: return "月支本氣"
                case .special: return "特殊格局"
                }
            case .japanese:
                switch self {
                case .jianLu: return "建禄格"
                case .yueRen: return "月刃格"
                case .yangRen: return "羊刃格"
                case .transpiredMonthStem: return "月支蔵干の月干透出"
                case .transpiredYearStem: return "月支蔵干の年干透出"
                case .transpiredHourStem: return "月支蔵干の時干透出"
                case .monthBranchMainQi: return "月支本気"
                case .special: return "特殊格局"
                }
            case .english:
                switch self {
                case .jianLu: return "Jian Lu Pattern"
                case .yueRen: return "Yue Ren Pattern"
                case .yangRen: return "Yang Ren Pattern"
                case .transpiredMonthStem: return "Month Branch Hidden Stem transpired in Month"
                case .transpiredYearStem: return "Month Branch Hidden Stem transpired in Year"
                case .transpiredHourStem: return "Month Branch Hidden Stem transpired in Hour"
                case .monthBranchMainQi: return "Month Branch Main Qi"
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
    
    public init(tenGod: TenGods, method: DeterminationMethod, customName: String? = nil) {
        self.tenGod = tenGod
        self.method = method
        self.customName = customName
    }
    
    public var description: String {
        // If it's a special pattern method (JianLu/YueRen/YangRen), ignore tenGod name and use Method description/name logic.
        switch method {
        case .jianLu, .yueRen, .yangRen:
            // These methods have their own specific names which are essentially the pattern names.
            // Using method.description is correct.
            return method.description
        default:
            // Standard TenGod pattern
            if let name = customName {
                return name
            }
            
            let suffix: String
            switch GanZhiConfig.language {
            case .simplifiedChinese, .traditionalChinese, .japanese:
                suffix = "格"
            case .english:
                suffix = " Pattern"
            }
            
            return tenGod.name + suffix
        }
    }
}

extension FourPillars {
    
    public func determinePattern() -> Pattern {
        let dayStem = self.day.stem
        let monthBranch = self.month.branch
        let hiddenStems = monthBranch.hiddenStems
        
        // 1. Check Special Patterns: Jian Lu and Yue Ren
        let stage = dayStem.lifeStage(in: monthBranch)
        
        if stage == .linGuan {
            // 建禄格 (Jian Lu Ge)
            // No customName needed, Pattern.description handles it via method.description
            return Pattern(tenGod: .friend, method: .jianLu)
        }
        
        if stage == .diWang {
            // 月刃格 (Yue Ren Ge) / 羊刃格 (Yang Ren Ge)
            if dayStem.yinYang == .yang {
                return Pattern(tenGod: .robWealth, method: .yangRen)
            } else {
                return Pattern(tenGod: .robWealth, method: .yueRen)
            }
        }
        
        // 2. Check Transpired Stems
        var candidates: [Pattern] = []
        
        if hiddenStems.contains(self.month.stem) {
            candidates.append(Pattern(tenGod: self.tenGod(for: self.month.stem), method: .transpiredMonthStem))
        }
        if hiddenStems.contains(self.year.stem) {
             candidates.append(Pattern(tenGod: self.tenGod(for: self.year.stem), method: .transpiredYearStem))
        }
        if hiddenStems.contains(self.hour.stem) {
             candidates.append(Pattern(tenGod: self.tenGod(for: self.hour.stem), method: .transpiredHourStem))
        }
        
        if let monthPattern = candidates.first(where: { $0.method == .transpiredMonthStem }) {
            if monthPattern.tenGod != .friend && monthPattern.tenGod != .robWealth {
                return monthPattern
            }
        }
        
        for hiddenStem in hiddenStems {
            let tenGod = self.tenGod(for: hiddenStem)
            if tenGod == .friend || tenGod == .robWealth { continue }
            
            if self.month.stem == hiddenStem {
                return Pattern(tenGod: tenGod, method: .transpiredMonthStem)
            }
            if self.year.stem == hiddenStem {
                return Pattern(tenGod: tenGod, method: .transpiredYearStem)
            }
            if self.hour.stem == hiddenStem {
                return Pattern(tenGod: tenGod, method: .transpiredHourStem)
            }
        }
        
        let mainQi = monthBranch.mainQi
        let mainQiTenGod = TenGods.calculate(dayMaster: dayStem, targetElement: mainQi.fiveElement, targetYinYang: mainQi.yinYang)
        
        if mainQiTenGod != .friend && mainQiTenGod != .robWealth {
            return Pattern(tenGod: mainQiTenGod, method: .monthBranchMainQi)
        }
        
        if let bestPeerCandidate = candidates.first(where: { $0.method == .transpiredMonthStem }) ?? candidates.first {
             return bestPeerCandidate
        }
        
        return Pattern(tenGod: mainQiTenGod, method: .monthBranchMainQi)
    }
}
