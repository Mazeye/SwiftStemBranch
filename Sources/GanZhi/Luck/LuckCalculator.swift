import Foundation

public struct LuckCalculator {
    public let gender: Gender
    public let pillars: FourPillars
    public let birthDate: Date
    
    public init(gender: Gender, pillars: FourPillars, birthDate: Date) {
        self.gender = gender
        self.pillars = pillars
        self.birthDate = birthDate
    }
    
    /// Calculates the Start Age (起运岁数).
    /// Returns the age in years (decimal).
    /// Algorithm:
    /// 1. Yang Year Male / Yin Year Female: Forward (Next Jie - Birth).
    /// 2. Yin Year Male / Yang Year Female: Backward (Birth - Previous Jie).
    /// 3. Ratio: 3 days = 1 year, 1 day = 4 months, 1 hour = 10 days.
    public func calculateStartAge() -> Double {
        // Correct access: pillars.year.stem (which is Stem)
        let isYangYear = pillars.year.stem.yinYang == .yang
        let isForward = (gender == .male && isYangYear) || (gender == .female && !isYangYear)
        
        let timeDiff: TimeInterval
        if isForward {
            let nextJie = SolarCalculator.findNextJie(from: birthDate)
            timeDiff = nextJie.timeIntervalSince(birthDate)
        } else {
            let prevJie = SolarCalculator.findPreviousJie(from: birthDate)
            timeDiff = birthDate.timeIntervalSince(prevJie)
        }
        
        // 1 year = 3 days = 3 * 24 * 60 minutes
        // Scale factor: Real Days / 3 = Luck Years
        // Result = (DiffSeconds / 86400) / 3
        
        let days = timeDiff / 86400.0
        let luckAge = days / 3.0
        
        return luckAge
    }
    
    /// Generates the Major Cycles (大运).
    /// - Parameter limit: Number of cycles to generate (default 10).
    public func getMajorCycles(limit: Int = 10) -> [MajorCycle] {
        // Correct access: pillars.year.stem (which is Stem)
        let isYangYear = pillars.year.stem.yinYang == .yang
        let isForward = (gender == .male && isYangYear) || (gender == .female && !isYangYear)
        
        let startAge = calculateStartAge()
        let startYear = Calendar.current.component(.year, from: birthDate)
        
        var cycles: [MajorCycle] = []
        var currentSB = pillars.month.value // Start from Month Pillar (using .value for raw StemBranch)
        
        for i in 0..<limit {
            currentSB = isForward ? currentSB.next : currentSB.previous
            
            // Age calculation:
            // First cycle starts at startAge.
            // Subsequent cycles add 10 years.
            // Note: Traditional age is often rounded, but here we return precise.
            
            let cycleStartAge = startAge + Double(i * 10)
            let cycleStartYear = startYear + Int(ceil(cycleStartAge)) // Approximate calendar year
            let cycleEndYear = cycleStartYear + 9
            
            let cycle = MajorCycle(
                stemBranch: currentSB,
                startAge: cycleStartAge,
                startYear: cycleStartYear,
                endYear: cycleEndYear
            )
            cycles.append(cycle)
        }
        
        return cycles
    }
}
