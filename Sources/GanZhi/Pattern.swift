import Foundation

/// Represents the BaZi Pattern (GeJu).
public struct Pattern: CustomStringConvertible {
    /// The method used to determine the pattern.
    public enum DeterminationMethod: String {
        case jianLu = "建禄格" // Month Branch is Lin Guan
        case yueRen = "月刃格" // Yin Day Master Month Branch is Di Wang
        case yangRen = "羊刃格" // Yang Day Master Month Branch is Di Wang
        case transpiredMonthStem = "月支藏干透出月干"
        case transpiredYearStem = "月支藏干透出年干"
        case transpiredHourStem = "月支藏干透出时干"
        case monthBranchMainQi = "月支本气"
        case special = "特殊格局"
    }
    
    /// The main Ten God forming the pattern.
    /// For special patterns, this might be a dominant Ten God or nil/generic.
    public let tenGod: TenGods
    
    /// The method used to find this pattern.
    public let method: DeterminationMethod
    
    /// Custom name or explanation (useful for Special patterns).
    /// If nil, the default name is tenGod + "格".
    public let customName: String?
    
    public init(tenGod: TenGods, method: DeterminationMethod, customName: String? = nil) {
        self.tenGod = tenGod
        self.method = method
        self.customName = customName
    }
    
    public var description: String {
        if let name = customName {
            return name
        }
        return tenGod.rawValue + "格"
    }
}

extension FourPillars {
    
    /// Determines the pattern (GeJu) of the BaZi chart based on standard rules.
    ///
    /// Rules:
    /// 1. **Special Priority**: Check for Jian Lu (Lin Guan) and Yue Ren (Di Wang) first.
    ///    - If Month Branch is Day Master's Lin Guan -> Jian Lu Ge.
    ///    - If Month Branch is Day Master's Di Wang -> Yue Ren Ge.
    /// 2. **Transpired Stems**: Priority to Hidden Stems of Month Branch appearing in Year/Month/Hour Stems.
    ///    - Month Stem has highest priority.
    ///    - Prioritize Non-Peer (not Friend/RobWealth) patterns if multiple transpire.
    /// 3. **Month Branch Main Qi**: If no Transpired Stems, use Month Branch Main Qi.
    public func determinePattern() -> Pattern {
        let dayStem = self.day.stem
        let monthBranch = self.month.branch
        let hiddenStems = monthBranch.hiddenStems
        
        // 1. Check Special Patterns: Jian Lu and Yue Ren
        let stage = dayStem.lifeStage(in: monthBranch)
        
        if stage == .linGuan {
            // 建禄格 (Jian Lu Ge)
            return Pattern(tenGod: .friend, method: .jianLu, customName: "建禄格")
        }
        
        if stage == .diWang {
            // 月刃格 (Yue Ren Ge) / 羊刃格 (Yang Ren Ge)
            if dayStem.yinYang == .yang {
                // 阳干直接叫羊刃格 (Yang Stem -> Yang Ren)
                return Pattern(tenGod: .robWealth, method: .yangRen, customName: "羊刃格")
            } else {
                // 阴干定为月刃格 (Yin Stem -> Yue Ren)
                return Pattern(tenGod: .robWealth, method: .yueRen, customName: "月刃格")
            }
        }
        
        // 2. Check Transpired Stems
        // We collect all potential patterns first, then select the best one.
        var candidates: [Pattern] = []
        
        // Check Month Stem
        if hiddenStems.contains(self.month.stem) {
            candidates.append(Pattern(tenGod: self.tenGod(for: self.month.stem), method: .transpiredMonthStem))
        }
        
        // Check Year Stem
        if hiddenStems.contains(self.year.stem) {
             // We iterate hidden stems order to see which one matches (Main > Middle > Residual)
             // But actually, checking if year.stem is in hiddenStems is enough to know it's transpired.
             // We can just add it.
             candidates.append(Pattern(tenGod: self.tenGod(for: self.year.stem), method: .transpiredYearStem))
        }
        
        // Check Hour Stem
        if hiddenStems.contains(self.hour.stem) {
             candidates.append(Pattern(tenGod: self.tenGod(for: self.hour.stem), method: .transpiredHourStem))
        }
        
        // Selection Logic:
        // Priority A: Month Stem Transpired (AND is not Friend/RobWealth if possible? User says Month Stem is most influential)
        // User rule: "If Month Stem transpired... prioritize".
        // But also: "Friend/RobWealth rarely used as pattern".
        // So: If Month Stem is NOT Friend/RobWealth, return it immediately.
        if let monthPattern = candidates.first(where: { $0.method == .transpiredMonthStem }) {
            if monthPattern.tenGod != .friend && monthPattern.tenGod != .robWealth {
                return monthPattern
            }
        }
        
        // Priority B: Other Transpired Stems (Year/Hour) that are NOT Friend/RobWealth
        // We prefer Main Qi > Middle > Residual if possible, but the `candidates` array structure above doesn't preserve that order perfectly across pillars.
        // Let's iterate Hidden Stems order (Main -> Middle -> Residual) and check if they transpired in any pillar.
        
        for hiddenStem in hiddenStems {
            let tenGod = self.tenGod(for: hiddenStem)
            
            // Skip Friend/RobWealth in this phase
            if tenGod == .friend || tenGod == .robWealth { continue }
            
            // Check Month (again, to catch cases where Month was Friend/RobWealth but maybe another hidden stem transpired in Month? No, Month has only 1 stem)
            if self.month.stem == hiddenStem {
                return Pattern(tenGod: tenGod, method: .transpiredMonthStem)
            }
            
            // Check Year
            if self.year.stem == hiddenStem {
                return Pattern(tenGod: tenGod, method: .transpiredYearStem)
            }
            
            // Check Hour
            if self.hour.stem == hiddenStem {
                return Pattern(tenGod: tenGod, method: .transpiredHourStem)
            }
        }
        
        // Priority C: If we only have Friend/RobWealth transpired candidates?
        // User says "rarely used".
        // If we found NO suitable non-peer pattern above, we fall through to Main Qi check.
        
        // 3. Month Branch Main Qi
        let mainQi = monthBranch.mainQi
        let mainQiTenGod = TenGods.calculate(dayMaster: dayStem, targetElement: mainQi.fiveElement, targetYinYang: mainQi.yinYang)
        
        // If Main Qi is NOT Friend/RobWealth, use it.
        if mainQiTenGod != .friend && mainQiTenGod != .robWealth {
            return Pattern(tenGod: mainQiTenGod, method: .monthBranchMainQi)
        }
        
        // If Main Qi IS Friend/RobWealth (and wasn't LinGuan/DiWang caught in Step 1)
        // e.g. Earth Day Master in Earth Month (Grave) -> Main Qi Friend/RobWealth.
        // Or if Step 1 didn't catch it for some reason.
        // In this edge case, we might return the Main Qi pattern anyway, or one of the transpired Peer patterns if they exist.
        // Given the constraints, returning the Main Qi pattern (even if Peer) is the safest fallback if nothing else exists.
        // But we should try to return a transpired Peer pattern if one exists (e.g. Month Stem Transpired Friend) because Transpired > Main Qi generally.
        
        if let bestPeerCandidate = candidates.first(where: { $0.method == .transpiredMonthStem }) ?? candidates.first {
             return bestPeerCandidate
        }
        
        return Pattern(tenGod: mainQiTenGod, method: .monthBranchMainQi)
    }
}
