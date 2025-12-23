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
    public var year: Pillar { Pillar(parent: self, type: .year) }
    public var month: Pillar { Pillar(parent: self, type: .month) }
    public var day: Pillar { Pillar(parent: self, type: .day) }
    public var hour: Pillar { Pillar(parent: self, type: .hour) }
    
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
    
    public func tenGod(for stemWrapper: Pillar.StemWrapper) -> TenGods {
        return tenGod(for: stemWrapper.value)
    }
    
    public func tenGod(for branchWrapper: Pillar.BranchWrapper) -> TenGods {
        return tenGod(for: branchWrapper.value)
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
    
    public func hiddenTenGods(for branchWrapper: Pillar.BranchWrapper) -> BranchTenGods {
        return hiddenTenGods(for: branchWrapper.value)
    }
    
    // MARK: - Contextual Types
    
    /// Identifies a specific pillar within the Four Pillars.
    public enum PillarType: Int, CaseIterable {
        case year = 0
        case month = 1
        case day = 2
        case hour = 3
    }
    
    /// Calculates the energy coefficient of the Branch at the specified pillar.
    ///
    /// - Month Branch: 3.0
    /// - Other Branches: 1.0
    public func branchEnergy(for pillarType: PillarType) -> Double {
        return (pillarType == .month) ? 3.0 : 1.0
    }

    /// Calculates the energy coefficient of the Stem at the specified pillar.
    ///
    /// The formula is:
    /// Score = Sum over all branches B of (BranchEnergy * RootingScore * DistanceDecay)
    ///
    /// - BranchEnergy:
    ///   - Month Branch: 3.0
    ///   - Others: 1.0
    ///
    /// - RootingScore (if Stem's element matches Hidden Stem's element):
    ///   - Matches Ben Qi (Main): 6
    ///   - Matches Zhong Qi (Middle): 4
    ///   - Matches Yu Qi (Residual): 2
    ///
    /// - DistanceDecay (Distance = abs(SourcePillar - BranchPillar)):
    ///   - 0: 1.0 (100%)
    ///   - 1: 0.9 (90%)
    ///   - 2: 0.8 (80%)
    ///   - 3: 0.7 (70%)
    public func stemEnergy(for pillarType: PillarType) -> Double {
        let targetStem: Stem
        switch pillarType {
        case .year: targetStem = _year.stem
        case .month: targetStem = _month.stem
        case .day: targetStem = _day.stem
        case .hour: targetStem = _hour.stem
        }
        
        let sourceIndex = pillarType.rawValue
        
        var totalScore: Double = 1.0
        
        // Iterate through all branches to find roots
        let branches: [(pillar: PillarType, branch: Branch)] = [
            (.year, _year.branch),
            (.month, _month.branch),
            (.day, _day.branch),
            (.hour, _hour.branch)
        ]
        
        for (branchPillar, branch) in branches {
            let branchIndex = branchPillar.rawValue
            
            // 1. Branch Base Score (Branch Energy)
            let branchBaseScore = branchEnergy(for: branchPillar)
            
            // 2. Rooting Score
            var rootScore: Double = 0.0
            
            // Allow rooting in multiple hidden stems if elements match (additive)
            if branch.benQi == targetStem {
                rootScore += 3.0
            }
            if let z = branch.zhongQi, z == targetStem {
                rootScore += 2.0
            }
            if let y = branch.yuQi, y == targetStem {
                rootScore += 1.0
            }
            
            // If no root found in this branch, contribution is 0
            if rootScore == 0 {
                continue
            }
            
            // 3. Distance Decay
            let distance = abs(sourceIndex - branchIndex)
            let decay: Double
            switch distance {
            case 0: decay = 1.0
            case 1: decay = 0.9
            case 2: decay = 0.8
            case 3: decay = 0.7
            default: decay = 0.0 // Should not happen
            }
            
            // Calculate contribution
            let contribution = branchBaseScore + rootScore * decay
            totalScore += contribution
        }
        
        return totalScore
    }

    /// A wrapper for a specific Pillar that provides context-aware Stem and Branch accessors.
    public struct Pillar {
        private let parent: FourPillars
        private let type: PillarType
        
        public init(parent: FourPillars, type: PillarType) {
            self.parent = parent
            self.type = type
        }
        
        public var value: StemBranch {
            switch type {
            case .year: return parent._year
            case .month: return parent._month
            case .day: return parent._day
            case .hour: return parent._hour
            }
        }
        
        /// The Stem of this pillar, including its calculated energy.
        public var stem: StemWrapper {
            StemWrapper(value: value.stem, energy: parent.stemEnergy(for: type))
        }
        
        /// The Branch of this pillar, including its calculated energy.
        public var branch: BranchWrapper {
            BranchWrapper(value: value.branch, energy: parent.branchEnergy(for: type))
        }
        
        public var character: String { value.character }
        
        /// A wrapper for a Stem within a specific Pillar context.
        @dynamicMemberLookup
        public struct StemWrapper: Equatable {
            public let value: Stem
            public let energy: Double
            
            public subscript<T>(dynamicMember keyPath: KeyPath<Stem, T>) -> T {
                return value[keyPath: keyPath]
            }
            
            public static func ==(lhs: StemWrapper, rhs: Stem) -> Bool {
                return lhs.value == rhs
            }
            
            public static func ==(lhs: Stem, rhs: StemWrapper) -> Bool {
                return lhs == rhs.value
            }
        }
        
        /// A wrapper for a Branch within a specific Pillar context.
        @dynamicMemberLookup
        public struct BranchWrapper: Equatable {
            public let value: Branch
            public let energy: Double
            
            public subscript<T>(dynamicMember keyPath: KeyPath<Branch, T>) -> T {
                return value[keyPath: keyPath]
            }
            
            public static func ==(lhs: BranchWrapper, rhs: Branch) -> Bool {
                return lhs.value == rhs
            }
            
            public static func ==(lhs: Branch, rhs: BranchWrapper) -> Bool {
                return lhs == rhs.value
            }
        }
    }
}
