import Foundation

/// Represents the state of the moon at a given time.
public struct LunarPhase: Sendable, Codable {
    /// The number of days since the last New Moon (approx. 0 to 29.53).
    public let age: Double
    
    /// The percentage of the moon's surface illuminated (0.0 to 1.0).
    public let illumination: Double
    
    /// A human-readable description of the phase.
    public var phaseName: String {
        switch age {
        case 0..<1.0: return "新月"
        case 1.0..<6.5: return "蛾眉月"
        case 6.5..<8.5: return "上弦月"
        case 8.5..<13.5: return "盈凸月"
        case 13.5..<15.5: return "满月"
        case 15.5..<21.5: return "亏凸月"
        case 21.5..<23.5: return "下弦月"
        case 23.5..<28.5: return "残月"
        default: return "新月"
        }
    }
}

/// Provides simplified astronomical calculations for the moon.
public struct LunarCalculator {
    
    private static let synodicMonth = 29.530588853
    
    /// Calculates the lunar phase for a given date.
    /// - Parameter date: The date to calculate for.
    /// - Returns: A `LunarPhase` object containing age and illumination.
    public static func getLunarPhase(date: Date) -> LunarPhase {
        let JD = SolarCalculator.toJulianDay(date: date)
        let T = (JD - 2451545.0) / 36525.0
        
        // 1. Mean Longitude of the Moon (L')
        var L_prime = 218.3164477 + 481267.88123421 * T
        L_prime = SolarCalculator.normalize(L_prime)
        
        // 2. Mean Elongation of the Moon (D)
        var D = 297.8501921 + 445267.1114034 * T
        D = SolarCalculator.normalize(D)
        
        // 3. Moon's Mean Anomaly (M')
        var M_prime = 134.9633964 + 477198.8675055 * T
        M_prime = SolarCalculator.normalize(M_prime)
        
        // 4. Sun's Mean Anomaly (M)
        var M = 357.5291092 + 35999.0502909 * T
        M = SolarCalculator.normalize(M)
        
        // Simplified Phase Angle calculation
        // The elongation D is approximately the phase angle in degrees where 0 = New Moon, 180 = Full Moon.
        // To get lunar age: (age / 29.53) = (D / 360)
        let age = (D / 360.0) * synodicMonth
        
        // Illumination formula: (1 - cos(D)) / 2
        let D_rad = D * .pi / 180.0
        let illumination = (1.0 - cos(D_rad)) / 2.0
        
        return LunarPhase(
            age: age,
            illumination: illumination
        )
    }
}
