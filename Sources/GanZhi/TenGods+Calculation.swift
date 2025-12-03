import Foundation

extension TenGods {
    /// Calculates the Ten God relationship based on the Day Master (Self) and a Target Stem/Branch.
    ///
    /// - Parameters:
    ///   - dayMaster: The Stem of the Day Pillar (The Self).
    ///   - targetElement: The Five Element of the target.
    ///   - targetYinYang: The Yin/Yang polarity of the target.
    /// - Returns: The corresponding Ten God.
    public static func calculate(dayMaster: Stem, targetElement: FiveElements, targetYinYang: YinYang) -> TenGods {
        let selfElement = dayMaster.fiveElement
        let selfYinYang = dayMaster.yinYang
        let samePolarity = (selfYinYang == targetYinYang)
        
        if selfElement == targetElement {
            // Same Element
            return samePolarity ? .friend : .robWealth
        } else if selfElement.generates(targetElement) {
            // Output (Self generates Target)
            return samePolarity ? .eatingGod : .hurtingOfficer
        } else if targetElement.generates(selfElement) {
            // Resource (Target generates Self)
            // Note: Direct Resource is different polarity, Indirect is same polarity
            // Mother gives birth to me.
            return samePolarity ? .indirectResource : .directResource
        } else if selfElement.controls(targetElement) {
            // Wealth (Self controls Target)
            return samePolarity ? .indirectWealth : .directWealth
        } else if targetElement.controls(selfElement) {
            // Officer/Killing (Target controls Self)
            return samePolarity ? .sevenKillings : .directOfficer
        }
        
        // Should not happen given the circular nature of Five Elements
        return .friend
    }
    
    /// Calculates the Ten God relationship based on the Day Master and a Branch.
    /// Uses the Branch's Main Qi (Ben Qi) for the calculation to handle polarity correctly
    /// (e.g. Zi is Yang Branch but contains Yin Water).
    public static func calculate(dayMaster: Stem, branch: Branch) -> TenGods {
        let targetStem = branch.mainQi
        return calculate(dayMaster: dayMaster, targetElement: targetStem.fiveElement, targetYinYang: targetStem.yinYang)
    }
}

