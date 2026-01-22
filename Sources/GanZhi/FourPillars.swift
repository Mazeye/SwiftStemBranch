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
    
    // MARK: - Relationships
    
    /// Detects all relationships (combinations, clashes, punishments, etc.) within the Four Pillars.
    public var relationships: [Relationship] {
        var results: [Relationship] = []
        let pillars = [year, month, day, hour]
        
        // 1. Stem Relationships (Combinations & Clashes)
        for i in 0..<pillars.count {
            for j in i+1..<pillars.count {
                if let rel = checkStemRelationship(p1: pillars[i], p2: pillars[j]) {
                    results.append(rel)
                }
            }
        }
        
        // 2. Branch Relationships (Six Harmony, Clash, Harm, Punishment, Destruction)
        for i in 0..<pillars.count {
            for j in i+1..<pillars.count {
                results.append(contentsOf: checkBranchPairRelationships(p1: pillars[i], p2: pillars[j]))
            }
        }
        
        // 3. Complex Branch Relationships (Triple Harmony, Directional Harmony, Triple Punishment)
        results.append(contentsOf: checkComplexBranchRelationships())
        
        return results
    }
    
    private func checkStemRelationship(p1: Pillar, p2: Pillar) -> Relationship? {
        let s1 = p1.stem.value
        let s2 = p2.stem.value
        
        // Combination (五合): Diff is 5 (e.g., Jia-Ji: 1 and 6)
        if abs(s1.rawValue - s2.rawValue) == 5 {
            return Relationship(type: .stemCombination, pillars: [p1.type, p2.type], characters: s1.character + s2.character)
        }
        
        // Clash (相冲): Standard is Geng-Jia, Xin-Yi, Ren-Bing, Gui-Ding
        // Usually Yang-Yang or Yin-Yin with diff of 6 in sequence (but only specific pairs)
        let stems = [s1, s2].sorted(by: { $0.rawValue < $1.rawValue })
        let pairs: Set<[Stem]> = [[.jia, .geng], [.yi, .xin], [.bing, .ren], [.ding, .gui]]
        if pairs.contains(stems) {
            return Relationship(type: .stemClash, pillars: [p1.type, p2.type], characters: stems[0].character + stems[1].character)
        }
        
        return nil
    }
    
    private func checkBranchPairRelationships(p1: Pillar, p2: Pillar) -> [Relationship] {
        var rels: [Relationship] = []
        let b1 = p1.branch.value
        let b2 = p2.branch.value
        let chars = b1.character + b2.character
        let types = [p1.type, p2.type]
        
        // Six Harmony (六合)
        let harmonyPairs: [Set<Branch>] = [
            [.zi, .chou], [.yin, .hai], [.mao, .xu], [.chen, .you], [.si, .shen], [.wu, .wei]
        ]
        if harmonyPairs.contains(Set([b1, b2])) {
            rels.append(Relationship(type: .branchSixHarmony, pillars: types, characters: chars))
        }
        
        // Clash (六冲): Diff is 6
        if abs(b1.rawValue - b2.rawValue) == 6 {
            rels.append(Relationship(type: .branchClash, pillars: types, characters: chars))
        }
        
        // Harm (六害)
        let harmPairs: [Set<Branch>] = [
            [.zi, .wei], [.chou, .wu], [.yin, .si], [.mao, .chen], [.shen, .hai], [.you, .xu]
        ]
        if harmPairs.contains(Set([b1, b2])) {
            rels.append(Relationship(type: .branchHarm, pillars: types, characters: chars))
        }
        
        // Punishment (相刑) - Pair-based
        // Zuo-Mao (二刑)
        if (b1 == .zi && b2 == .mao) || (b1 == .mao && b2 == .zi) {
            rels.append(Relationship(type: .branchPunishment, pillars: types, characters: chars))
        }
        // Self Punishment (自刑): Chen, Wu, You, Hai
        if b1 == b2 {
            let selfPunish: Set<Branch> = [.chen, .wu, .you, .hai]
            if selfPunish.contains(b1) {
                rels.append(Relationship(type: .branchPunishment, pillars: types, characters: chars))
            }
        }
        
        // Destruction (相破)
        let destructPairs: [Set<Branch>] = [
            [.zi, .you], [.mao, .wu], [.shen, .si], [.yin, .hai], [.chen, .chou], [.xu, .wei]
        ]
        if destructPairs.contains(Set([b1, b2])) {
            rels.append(Relationship(type: .branchDestruction, pillars: types, characters: chars))
        }
        
        return rels
    }
    
    private func checkComplexBranchRelationships() -> [Relationship] {
        var rels: [Relationship] = []
        let pillars = [year, month, day, hour]
        let branches = pillars.map { $0.branch.value }
        
        // Directional Harmony (三会)
        let directionalSets: [(Set<Branch>, String, FiveElements)] = [
            ([.yin, .mao, .chen], "寅卯辰", .wood),
            ([.si, .wu, .wei], "巳午未", .fire),
            ([.shen, .you, .xu], "申酉戌", .metal),
            ([.hai, .zi, .chou], "亥子丑", .water)
        ]
        for (set, chars, element) in directionalSets {
            if set.allSatisfy({ branches.contains($0) }) {
                let involved = pillars.filter { set.contains($0.branch.value) }.map { $0.type }
                rels.append(Relationship(type: .branchDirectional, pillars: involved, characters: chars, relatedElement: element))
            }
        }
        
        // Triple Harmony (三合)
        let tripleSets: [(Set<Branch>, String, FiveElements)] = [
            ([.shen, .zi, .chen], "申子辰", .water),
            ([.hai, .mao, .wei], "亥卯未", .wood),
            ([.yin, .wu, .xu], "寅午戌", .fire),
            ([.si, .you, .chou], "巳酉丑", .metal)
        ]
        for (set, chars, element) in tripleSets {
            if set.allSatisfy({ branches.contains($0) }) {
                let involved = pillars.filter { set.contains($0.branch.value) }.map { $0.type }
                rels.append(Relationship(type: .branchTripleHarmony, pillars: involved, characters: chars, relatedElement: element))
            }
        }
        
        // Triple Punishment (三刑)
        let triplePunishSets: [(Set<Branch>, String)] = [
            ([.yin, .si, .shen], "寅巳申"),
            ([.chou, .wei, .xu], "丑未戌")
        ]
        for (set, chars) in triplePunishSets {
            if set.allSatisfy({ branches.contains($0) }) {
                let involved = pillars.filter { set.contains($0.branch.value) }.map { $0.type }
                rels.append(Relationship(type: .branchPunishment, pillars: involved, characters: chars))
            }
        }
        
        return rels
    }
    
    /// Evaluates the thermal and moisture balance (Tiao Hou) of the chart.
    public var thermalBalance: ThermalBalance {
        let monthBranch = month.branch.value
        var totalTemp = monthBranch.thermalBaseline
        var totalMoisture = 0.0
        
        let pillars = [year, month, day, hour]
        
        // Helper to get Life Stage based multiplier
        // Di Wang (Peak) -> 2.0, Si/Jue (Death/Extinction) -> 0.5, Others -> 1.0
        func getLifeStageMultiplier(for stem: Stem, in branch: Branch) -> Double {
            let stage = stem.lifeStage(in: branch)
            switch stage {
            case .diWang: return 2.0
            case .si, .jue: return 0.5
            default: return 1.0
            }
        }
        
        for pillar in pillars {
            let stem = pillar.stem.value
            let branch = pillar.branch.value
            let sEnergy = pillar.stem.energy
            let bEnergy = pillar.branch.energy
            
            // 1. Temperature Calculation (Fire focus)
            // Heavenly Stems: Bing (丙) and Ding (丁)
            if stem.fireTemperatureBase > 0 {
                // Weight based on Life Stage in the LOCAL branch
                var weight = getLifeStageMultiplier(for: stem, in: branch)
                
                // Bing fire also has a monthly coefficient (Dual adjustment)
                // Ding fire only has local adjustment
                if stem == .bing {
                    weight *= monthBranch.bingFireCoefficient
                }
                
                totalTemp += (stem.fireTemperatureBase * weight * sEnergy)
            }
            
            // Hidden Stems (all branches contribute via their hidden fire)
            let branchEnergy = pillar.branch.energy
            let hidden = hiddenTenGods(for: branch)
            
            // Helper to process hidden fire
            func processHiddenFire(stem: Stem, hiddenWeight: Double) {
                if stem.fireTemperatureBase > 0 {
                    let weight = hiddenWeight
                    totalTemp += (stem.fireTemperatureBase * weight * branchEnergy)
                }
            }
            
            processHiddenFire(stem: hidden.benQi.stem, hiddenWeight: 2.0)
            if let zhong = hidden.zhongQi {
                processHiddenFire(stem: zhong.stem, hiddenWeight: 1)
            }
            if let yu = hidden.yuQi {
                processHiddenFire(stem: yu.stem, hiddenWeight: 0.5)
            }
            
            // 2. Moisture Calculation (Mirroring Fire Logic)
            // Water Stems: Gui (癸) and Ren (壬)
            if stem.waterMoistureBase > 0 {
                // Weight based on Life Stage in the LOCAL branch
                let weight = getLifeStageMultiplier(for: stem, in: branch)
                
                // Note: User requested to REMOVE month coefficient for moisture
                
                totalMoisture += (stem.waterMoistureBase * weight * sEnergy)
            }
            
            // Hidden Stems (all branches contribute via their hidden water)
            func processHiddenWater(stem: Stem, hiddenWeight: Double) {
                if stem.waterMoistureBase > 0 {
                    let weight = hiddenWeight
                    totalMoisture += (stem.waterMoistureBase * weight * branchEnergy)
                }
            }
            
            processHiddenWater(stem: hidden.benQi.stem, hiddenWeight: 2.0)
            if let zhong = hidden.zhongQi {
                processHiddenWater(stem: zhong.stem, hiddenWeight: 1)
            }
            if let yu = hidden.yuQi {
                processHiddenWater(stem: yu.stem, hiddenWeight: 0.5)
            }
            
            // 3. Earth Calculation (Additive)
            // Add Earth Moisture Base from Stems and Branches directly
            totalMoisture += (stem.earthMoistureBase * sEnergy)
            totalMoisture += (branch.earthMoistureBase * bEnergy)
        }
        
        // User requested to clamp negative moisture to 0
        totalMoisture = max(0, totalMoisture)
        
        return ThermalBalance(temperature: totalTemp, moisture: totalMoisture)
    }
    
    // MARK: - Contextual Types
    
    /// Identifies a specific pillar within the Four Pillars.
    public enum PillarType: Int, CaseIterable {
        case year = 0
        case month = 1
        case day = 2
        case hour = 3
        
        public var name: String {
            switch GanZhiConfig.language {
            case .simplifiedChinese:
                switch self {
                case .year: return "年柱"
                case .month: return "月柱"
                case .day: return "日柱"
                case .hour: return "时柱"
                }
            case .traditionalChinese:
                switch self {
                case .year: return "年柱"
                case .month: return "月柱"
                case .day: return "日柱"
                case .hour: return "时柱"
                }
            case .japanese:
                switch self {
                case .year: return "年柱"
                case .month: return "月支"
                case .day: return "日柱"
                case .hour: return "時柱"
                }
            case .english:
                switch self {
                case .year: return "Year"
                case .month: return "Month"
                case .day: return "Day"
                case .hour: return "Hour"
                }
            }
        }
    }
    
    /// Calculates the seasonal coefficient (Wang Xiang Xiu Qiu Si) for a given element.
    /// Based on the Month Branch (Commander).
    private func getSeasonalCoefficient(for element: FiveElements) -> Double {
        let monthElement = _month.branch.fiveElement
        
        // 1. Wang (Same as Month): 1.4
        if element == monthElement {
            return 1.4
        }
        
        // 2. Xiang (Month Produces Element): 1.2
        if monthElement.generates(element) {
            return 1.2
        }
        
        // 3. Xiu (Element Produces Month): 1.0
        if element.generates(monthElement) {
            return 1.0
        }
        
        // 4. Qiu (Element Controls Month): 0.8
        if element.controls(monthElement) {
            return 0.8
        }
        
        // 5. Si (Month Controls Element): 0.6
        if monthElement.controls(element) {
            return 0.6
        }
        
        return 1.0 // Fallback
    }

    /// Calculates the energy coefficient of the Branch at the specified pillar.
    ///
    /// - Month Branch: 3.0 (The Commander, unadjusted)
    /// - Other Branches: 1.0 * SeasonalCoefficient
    public func branchEnergy(for pillarType: PillarType) -> Double {
        if pillarType == .month {
            return 3.0
        }
        
        let branch = (pillarType == .year) ? _year.branch :
                     (pillarType == .day) ? _day.branch :
                     _hour.branch
                     
        let coeff = getSeasonalCoefficient(for: branch.fiveElement)
        return 1.0 * coeff
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
        
        // 1. Base Score scaled by Seasonal Coefficient (Wang Xiang Xiu Qiu Si)
        // User Logic: Only adjust the Base 1.0. Root score inherits branch adjustment.
        // Formula: (1.0 * SeasonalCoeff) + RootScores
        
        let seasonalCoeff = getSeasonalCoefficient(for: targetStem.fiveElement)
        var totalScore: Double = 1.0 * seasonalCoeff
        
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
            // This already includes the coefficient for non-month branches
            let branchBaseScore = branchEnergy(for: branchPillar)
            
            // Calculate Seasonal Coefficient for Root Adjustment
            // Month Branch is the standard (1.0 relative to itself for rooting quality)
            // Other branches get the same coefficient applied to their base energy
            let seasonalCoeff: Double
            if branchPillar == .month {
                seasonalCoeff = 1.0
            } else {
                seasonalCoeff = getSeasonalCoefficient(for: branch.fiveElement)
            }
            
            // 2. Rooting Score
            var rootScore: Double = 0.0
            
            // Allow rooting in multiple hidden stems if elements match (additive)
            
            // Ben Qi (Main)
            if branch.benQi == targetStem {
                rootScore += 3.0
            } else if branch.benQi.fiveElement == targetStem.fiveElement {
                rootScore += 1.5
            }
            
            // Zhong Qi (Middle)
            if let z = branch.zhongQi {
                if z == targetStem {
                    rootScore += 2.0
                } else if z.fiveElement == targetStem.fiveElement {
                    rootScore += 1.0
                }
            }
            
            // Yu Qi (Residual)
            if let y = branch.yuQi {
                if y == targetStem {
                    rootScore += 1.0
                } else if y.fiveElement == targetStem.fiveElement {
                    rootScore += 0.5
                }
            }
            
            // Apply Seasonal Coefficient to Root Score
            // "Weak Branch = Weak Root"
            rootScore *= seasonalCoeff
            
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
        public let type: PillarType
        
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
