import Foundation

/// Represents the Four Pillars of Destiny (BaZi).
/// Contains the Stem-Branch pairs for Year, Month, Day, and Hour.
public struct FourPillars {
    public let year: StemBranch
    public let month: StemBranch
    public let day: StemBranch
    public let hour: StemBranch
    
    public init(year: StemBranch, month: StemBranch, day: StemBranch, hour: StemBranch) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
    }
    
    public var description: String {
        return "\(year.character)年 \(month.character)月 \(day.character)日 \(hour.character)时"
    }
    
    /// Calculates the distribution of Five Elements in the Four Pillars.
    public var fiveElementCounts: [FiveElements: Int] {
        var counts: [FiveElements: Int] = [
            .wood: 0, .fire: 0, .earth: 0, .metal: 0, .water: 0
        ]
        
        let items: [FiveElements] = [
            year.stem.fiveElement, year.branch.fiveElement,
            month.stem.fiveElement, month.branch.fiveElement,
            day.stem.fiveElement, day.branch.fiveElement,
            hour.stem.fiveElement, hour.branch.fiveElement
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
            year.stem.yinYang, year.branch.yinYang,
            month.stem.yinYang, month.branch.yinYang,
            day.stem.yinYang, day.branch.yinYang,
            hour.stem.yinYang, hour.branch.yinYang
        ]
        
        for item in items {
            counts[item, default: 0] += 1
        }
        
        return counts
    }
    
    /// Calculates the Ten God (Shi Shen) for a given Stem relative to the Day Master.
    public func tenGod(for stem: Stem) -> TenGods {
        return TenGods.calculate(dayMaster: day.stem, targetElement: stem.fiveElement, targetYinYang: stem.yinYang)
    }
    
    /// Calculates the Ten God (Shi Shen) for a given Branch relative to the Day Master.
    /// This uses the Branch's main Qi (Ben Qi) for determining the Ten God.
    public func tenGod(for branch: Branch) -> TenGods {
        return TenGods.calculate(dayMaster: day.stem, branch: branch)
    }
}

