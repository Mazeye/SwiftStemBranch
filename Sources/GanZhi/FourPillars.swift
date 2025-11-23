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
}

