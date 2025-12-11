import Foundation

/// Represents the Four Pillars of Destiny (BaZi).
/// Contains the Stem-Branch pairs for Year, Month, Day, and Hour.
public struct FourPillars {
    // Internal storage of raw StemBranch data
    private let _year: StemBranch
    private let _month: StemBranch
    private let _day: StemBranch
    private let _hour: StemBranch
    
    public init(year: StemBranch, month: StemBranch, day: StemBranch, hour: StemBranch) {
        self._year = year
        self._month = month
        self._day = day
        self._hour = hour
    }
    
    // Accessors returning Contextual Pillar wrappers
    public var year: Pillar { Pillar(value: _year) }
    public var month: Pillar { Pillar(value: _month) }
    public var day: Pillar { Pillar(value: _day) }
    public var hour: Pillar { Pillar(value: _hour) }
    
    public var description: String {
        return "\(_year.character)年 \(_month.character)月 \(_day.character)日 \(_hour.character)时"
    }
    
    /// Calculates the distribution of Five Elements in the Four Pillars.
    public var fiveElementCounts: [FiveElements: Int] {
        var counts: [FiveElements: Int] = [
            .wood: 0, .fire: 0, .earth: 0, .metal: 0, .water: 0
        ]
        
        let items: [FiveElements] = [
            _year.stem.fiveElement, _year.branch.fiveElement,
            _month.stem.fiveElement, _month.branch.fiveElement,
            _day.stem.fiveElement, _day.branch.fiveElement,
            _hour.stem.fiveElement, _hour.branch.fiveElement
        ]
        
        for element in items {
            counts[element, default: 0] += 1
        }
        
        return counts
    }
    
    /// Calculates the distribution of Yin and Yang in the Four Pillars.
    public var yinYangCounts: [YinYang: Int] {
        var counts: [YinYang: Int] = [
            .yin: 0, .yang: 0
        ]
        
        let items: [YinYang] = [
            _year.stem.yinYang, _year.branch.yinYang,
            _month.stem.yinYang, _month.branch.yinYang,
            _day.stem.yinYang, _day.branch.yinYang,
            _hour.stem.yinYang, _hour.branch.yinYang
        ]
        
        for item in items {
            counts[item, default: 0] += 1
        }
        
        return counts
    }
    
    /// Calculates the Ten God (Shi Shen) for a given Stem relative to the Day Master.
    public func tenGod(for stem: Stem) -> TenGods {
        return TenGods.calculate(dayMaster: _day.stem, targetElement: stem.fiveElement, targetYinYang: stem.yinYang)
    }
    
    /// Calculates the Ten God (Shi Shen) for a given Branch relative to the Day Master.
    /// This uses the Branch's main Qi (Ben Qi) for determining the Ten God.
    public func tenGod(for branch: Branch) -> TenGods {
        return TenGods.calculate(dayMaster: _day.stem, branch: branch)
    }
    
    // MARK: - Hidden Stems Ten Gods
    
    /// Contains Ten God information for all Hidden Stems in a Branch.
    public struct BranchTenGods {
        /// The Ten God corresponding to the Main Qi (Ben Qi).
        public let benQi: (stem: Stem, tenGod: TenGods)
        
        /// The Ten God corresponding to the Middle Qi (Zhong Qi), if present.
        public let zhongQi: (stem: Stem, tenGod: TenGods)?
        
        /// The Ten God corresponding to the Residual Qi (Yu Qi), if present.
        public let yuQi: (stem: Stem, tenGod: TenGods)?
    }
    
    /// Calculates Ten Gods for all Hidden Stems (Ben Qi, Zhong Qi, Yu Qi) of a given Branch.
    public func hiddenTenGods(for branch: Branch) -> BranchTenGods {
        let ben = (branch.benQi, tenGod(for: branch.benQi))
        
        var zhong: (Stem, TenGods)? = nil
        if let z = branch.zhongQi {
            zhong = (z, tenGod(for: z))
        }
        
        var yu: (Stem, TenGods)? = nil
        if let y = branch.yuQi {
            yu = (y, tenGod(for: y))
        }
        
        return BranchTenGods(benQi: ben, zhongQi: zhong, yuQi: yu)
    }
    
    // MARK: - Contextual Types
    
    /// A wrapper for StemBranch that provides context-aware Stem and Branch accessors.
    public struct Pillar {
        public let value: StemBranch
        
        public init(value: StemBranch) {
            self.value = value
        }
        
        public var stem: Stem {
            value.stem
        }
        
        public var branch: Branch {
            value.branch
        }
        
        public var character: String { value.character }
    }
}
