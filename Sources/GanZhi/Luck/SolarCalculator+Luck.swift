import Foundation

extension SolarCalculator {
    /// Finds the exact date of the previous "Jie" (Solar Section) relative to the given date.
    /// "Jie" are the terms that mark the start of a zodiac month (e.g. LiChun, JingZhe).
    ///
    /// - Parameters:
    ///   - date: The reference date.
    /// - Returns: The date of the previous Jie.
    public static func findPreviousJie(from date: Date) -> Date {
        // Algorithm:
        // 1. Get current longitude.
        // 2. Determine the target longitude of the previous Jie.
        //    Jie longitudes are 315, 345, 15, 45, ... (15 + n*30)
        
        let currentLong = getSolarLongitude(date: date)
        
        // Find the largest Jie longitude <= currentLong (handling circular wrap at 315/0)
        // Normalized: L' = (L - 315 + 360) % 360
        // Jie L' are: 0, 30, 60, ... 330.
        // So target L' = floor(L' / 30) * 30.
        
        let L_prime = normalize(currentLong - 315)
        let target_L_prime = floor(L_prime / 30.0) * 30.0
        let targetLong = normalize(target_L_prime + 315)
        
        // Now find the time T where Longitude(T) == targetLong.
        // Since we want "Previous", we search backwards.
        
        return binarySearchDate(targetLongitude: targetLong, near: date, direction: -1)
    }
    
    /// Finds the exact date of the next "Jie" (Solar Section).
    public static func findNextJie(from date: Date) -> Date {
        let currentLong = getSolarLongitude(date: date)
        
        let L_prime = normalize(currentLong - 315)
        let target_L_prime = (floor(L_prime / 30.0) + 1) * 30.0
        let targetLong = normalize(target_L_prime + 315)
        
        return binarySearchDate(targetLongitude: targetLong, near: date, direction: 1)
    }
    
    // Helper for binary search
    private static func binarySearchDate(targetLongitude: Double, near date: Date, direction: Double) -> Date {
        // We know terms are roughly 30 days apart (Jie to Jie).
        // Let's search within a +/- 35 day window to be safe.
        // direction: -1 for previous, 1 for next.
        
        var low: TimeInterval
        var high: TimeInterval
        
        if direction < 0 {
            // Searching backwards
            high = date.timeIntervalSince1970
            low = high - 40 * 86400 // 40 days back
        } else {
            // Searching forwards
            low = date.timeIntervalSince1970
            high = low + 40 * 86400
        }
        
        // Binary search for precision (e.g. 1 second or less)
        for _ in 0..<30 {
            let mid = (low + high) / 2
            let midDate = Date(timeIntervalSince1970: mid)
            let midLong = getSolarLongitude(date: midDate)
            
            // Calculate delta in range (-180, 180)
            var delta = midLong - targetLongitude
            if delta > 180 { delta -= 360 }
            if delta < -180 { delta += 360 }
            
            if delta > 0 {
                // mid is "after" target
                high = mid
            } else {
                // mid is "before" target
                low = mid
            }
        }
        
        return Date(timeIntervalSince1970: (low + high) / 2)
    }
}
