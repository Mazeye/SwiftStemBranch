import Foundation

/// Provides astronomical calculations for solar position and time correction.
/// Implements simplified algorithms from Jean Meeus' "Astronomical Algorithms".
public struct SolarCalculator {
    private static let pi = 3.14159265358979323846
    
    private static func rad(_ d: Double) -> Double { return d * pi / 180.0 }
    private static func deg(_ r: Double) -> Double { return r * 180.0 / pi }
    
    /// Normalizes an angle to the range [0, 360).
    public static func normalize(_ d: Double) -> Double {
        var res = d.truncatingRemainder(dividingBy: 360.0)
        if res < 0 { res += 360.0 }
        return res
    }
    
    /// Calculates the Julian Day (JD) from a Date.
    /// - Parameter date: The input date.
    /// - Returns: The Julian Day number.
    public static func toJulianDay(date: Date) -> Double {
        let timeInterval = date.timeIntervalSince1970
        return timeInterval / 86400.0 + 2440587.5
    }
    
    /// Calculates the Equation of Time (EoT) in minutes.
    /// Represents the difference between Apparent Solar Time and Mean Solar Time.
    ///
    /// - Parameter date: The date to calculate for.
    /// - Returns: The time difference in minutes (positive or negative).
    public static func getEquationOfTime(date: Date) -> Double {
        let JD = toJulianDay(date: date)
        let T = (JD - 2451545.0) / 36525.0
        
        // Solar Geometric Mean Longitude L0
        var L0 = 280.46646 + 36000.76983 * T + 0.0003032 * T * T
        L0 = normalize(L0)
        
        // Solar Mean Anomaly M
        var M = 357.52911 + 35999.05029 * T - 0.0001537 * T * T
        M = normalize(M)
        
        // Earth's orbital eccentricity e
        let e = 0.016708634 - 0.000042037 * T - 0.0000001267 * T * T
        
        // Solar Mean Longitude y (y = tan^2(epsilon/2))
        // Obliquity of the Ecliptic epsilon approx 23.439 degrees
        let epsilon = 23.4392911
        let y = pow(tan(rad(epsilon/2)), 2)
        
        // Equation of Time (E) in radians
        let L0_rad = rad(L0)
        let M_rad = rad(M)
        
        let E_rad = y * sin(2 * L0_rad)
                  - 2 * e * sin(M_rad)
                  + 4 * e * y * sin(M_rad) * cos(2 * L0_rad)
                  - 0.5 * y * y * sin(4 * L0_rad)
                  - 1.25 * e * e * sin(2 * M_rad)
        
        // Convert to degrees, then to minutes (1 degree = 4 minutes)
        let E_deg = deg(E_rad)
        return E_deg * 4.0
    }

    /// Calculates the Apparent Solar Longitude (True Ecliptic Longitude).
    /// Used for determining solar terms (Jie Qi).
    ///
    /// - Parameter date: The date to calculate for.
    /// - Returns: The longitude in degrees [0, 360). 0 = Spring Equinox.
    public static func getSolarLongitude(date: Date) -> Double {
        let JD = toJulianDay(date: date)
        let T = (JD - 2451545.0) / 36525.0
        
        var L0 = 280.46646 + 36000.76983 * T + 0.0003032 * T * T
        L0 = normalize(L0)
        
        var M = 357.52911 + 35999.05029 * T - 0.0001537 * T * T
        M = normalize(M)
        let M_rad = rad(M)
        
        let C = (1.914602 - 0.004817 * T - 0.000014 * T * T) * sin(M_rad)
              + (0.019993 - 0.000101 * T) * sin(2 * M_rad)
              + 0.000289 * sin(3 * M_rad)
        
        let trueLong = L0 + C
        
        let Omega = 125.04 - 1934.136 * T
        let lambda = trueLong - 0.00569 - 0.00478 * sin(rad(Omega))
        
        return normalize(lambda)
    }
}

