import Foundation

/// Represents a geographic location used for True Solar Time calculation.
public struct Location {
    /// East longitude is positive, West is negative.
    public let longitude: Double
    
    /// Timezone offset from UTC in hours (e.g., +8.0 for Beijing).
    public let timeZone: Double
    
    public init(longitude: Double, timeZone: Double) {
        self.longitude = longitude
        self.timeZone = timeZone
    }
    
    public static let beijing = Location(longitude: 120.0, timeZone: 8.0)
}

