import Foundation

/// Represents Gender for Major Cycle calculation.
public enum Gender: String, Codable {
    case male = "男"
    case female = "女"
}

/// Represents a single Major Cycle (10-year Luck Pillar).
public struct MajorCycle {
    public let stemBranch: StemBranch
    public let startAge: Double    // Precise starting age (e.g., 3.4 years)
    public let startYear: Int      // Gregorian start year
    public let endYear: Int        // Gregorian end year
    
    public var description: String {
        return "\(stemBranch.character)运 (起运: \(String(format: "%.1f", startAge))岁, \(startYear)-\(endYear))"
    }
}

