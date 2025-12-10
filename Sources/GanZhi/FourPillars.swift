import Foundation

public protocol Rooting {
    var stemRoots: [Branch] { get }
}

public protocol Revealing {
    var branchRevealedStems: [Stem] { get }
}

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
    public var year: Pillar { Pillar(value: _year, context: self) }
    public var month: Pillar { Pillar(value: _month, context: self) }
    public var day: Pillar { Pillar(value: _day, context: self) }
    public var hour: Pillar { Pillar(value: _hour, context: self) }
    
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
    
    // Helper accessors for internal use
    private var allStems: [Stem] { [_year.stem, _month.stem, _day.stem, _hour.stem] }
    private var allBranches: [Branch] { [_year.branch, _month.branch, _day.branch, _hour.branch] }
    
    // MARK: - Contextual Types
    
    /// A wrapper for StemBranch that provides context-aware Stem and Branch accessors.
    public struct Pillar {
        public let value: StemBranch
        private let context: FourPillars
        
        fileprivate init(value: StemBranch, context: FourPillars) {
            self.value = value
            self.context = context
        }
        
        public var stem: StemWrapper {
            StemWrapper(value: value.stem, allBranches: context.allBranches)
        }
        
        public var branch: BranchWrapper {
            BranchWrapper(value: value.branch, allStems: context.allStems)
        }
        
        public var character: String { value.character }
    }
    
    /// A wrapper for Stem that includes Rooting information.
    public struct StemWrapper: Rooting {
        public let value: Stem
        private let allBranches: [Branch]
        
        fileprivate init(value: Stem, allBranches: [Branch]) {
            self.value = value
            self.allBranches = allBranches
        }
        
        public var stemRoots: [Branch] {
            allBranches.filter { $0.hiddenStems.contains(value) }
        }
        
        // Forwarding properties
        public var character: String { value.character }
        public var fiveElement: FiveElements { value.fiveElement }
        public var yinYang: YinYang { value.yinYang }
        public var index: Int { value.index }
    }
    
    /// A wrapper for Branch that includes Revealing information.
    public struct BranchWrapper: Revealing {
        public let value: Branch
        private let allStems: [Stem]
        
        fileprivate init(value: Branch, allStems: [Stem]) {
            self.value = value
            self.allStems = allStems
        }
        
        public var branchRevealedStems: [Stem] {
            value.hiddenStems.filter { allStems.contains($0) }
        }
        
        // Forwarding properties
        public var character: String { value.character }
        public var fiveElement: FiveElements { value.fiveElement }
        public var yinYang: YinYang { value.yinYang }
        public var hiddenStems: [Stem] { value.hiddenStems }
        public var mainQi: Stem { value.mainQi }
        public var index: Int { value.index }
    }
}
