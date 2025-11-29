import Foundation

public extension Date {
    
    /// Calculates the Four Pillars (BaZi) for this date.
    ///
    /// - Parameter calendar: The calendar to use for interpreting the date components (Year/Month/Day/Hour). 
    ///                       Defaults to `Calendar(identifier: .gregorian)` to ensure consistency across system settings.
    /// - Returns: The Four Pillars structure.
    func fourPillars(calendar: Calendar = Calendar(identifier: .gregorian)) -> FourPillars {
        return calculateFourPillars(for: self, using: calendar)
    }
    
    /// Calculates the Four Pillars (BaZi) using True Solar Time for a specific location.
    ///
    /// - Parameters:
    ///   - location: The geographic location (longitude and timezone) for time correction.
    ///   - calendar: The calendar used for date component interpretation. Defaults to `Calendar(identifier: .gregorian)`.
    /// - Returns: The corrected Four Pillars structure.
    func fourPillars(at location: Location, calendar: Calendar = Calendar(identifier: .gregorian)) -> FourPillars {
        let trueSolarDate = getTrueSolarTime(for: self, location: location, calendar: calendar)
        return calculateFourPillars(for: trueSolarDate, using: calendar)
    }
    
    // MARK: - Helper Initializer
    
    /// Creates a Date from components.
    /// - Parameters:
    ///   - year: Year
    ///   - month: Month
    ///   - day: Day
    ///   - hour: Hour (0-23)
    ///   - minute: Minute (0-59)
    ///   - timeZone: TimeZone (defaults to current)
    init?(year: Int, month: Int, day: Int, hour: Int, minute: Int, timeZone: TimeZone = .current) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        guard let date = calendar.date(from: comps) else { return nil }
        self = date
    }
    
    // MARK: - Internal Logic
    
    private func calculateFourPillars(for date: Date, using calendar: Calendar) -> FourPillars {
        // Force the calendar to be Gregorian if it's not passed explicitly, 
        // but even if passed, we must ensure the interpretation of Y/M/D is solar-based for the algorithm.
        // However, if the user INTENDS to use a different calendar (e.g. ISO8601), we respect it.
        // BUT, GanZhi calculation relies on solar terms which align with Gregorian dates.
        // The safest way is to ensure we interpret the components as Gregorian components.
        // If the user passes a Chinese Calendar, `comps.year` might be 4721, which breaks SolarCalculator.
        
        // CRITICAL FIX: We must ensure we use a Gregorian calendar to extract components 
        // for the SolarCalculator and Index algorithms, regardless of what the user's system calendar is.
        // The `calendar` parameter is retained for TimeZone info, but the Identifier must be Gregorian.
        
        var gregCal = Calendar(identifier: .gregorian)
        gregCal.timeZone = calendar.timeZone // Preserve the timezone from the input calendar
        
        // 1. Astronomical Solar Longitude (based on absolute UTC time)
        let longitude = SolarCalculator.getSolarLongitude(date: date)
        
        // 2. Day Pillar Calculation
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(secondsFromGMT: 0)!
        
        // Base Date: 2000-01-01 (Wu-Wu, index 54)
        let baseDate = DateComponents(calendar: utcCal, year: 2000, month: 1, day: 1).date!
        
        // Extract Y/M/D from input date using the GREGORIAN calendar (User's local time context)
        let comps = gregCal.dateComponents([.year, .month, .day, .hour], from: date)
        let currentYear = comps.year!
        let currentMonth = comps.month!
        let currentDay = comps.day!
        let currentHour = comps.hour!
        
        // Construct Target Date as 20xx-xx-xx 00:00:00 UTC
        let targetComponents = DateComponents(year: currentYear, month: currentMonth, day: currentDay)
        let targetDate = utcCal.date(from: targetComponents)!
        
        let daysDiff = utcCal.dateComponents([.day], from: baseDate, to: targetDate).day!
        
        // Base Index 54 (Wu-Wu)
        let baseIndex = 54
        
        let normalizedDiff = (daysDiff % 60 + 60) % 60
        let dayIndex = (baseIndex + normalizedDiff) % 60
        
        let daySB = StemBranch.from(index: dayIndex)
        
        // --- Year Pillar ---
        var effectiveYear = currentYear
        if currentMonth < 3 && longitude < 315 {
            effectiveYear -= 1
        }
        let yearIndex = (effectiveYear - 4 + 6000) % 60
        let yearSB = StemBranch.from(index: yearIndex)
        
        // --- Month Pillar ---
        let adjustedLong = SolarCalculator.normalize(longitude - 315)
        let monthBranchOffset = Int(floor(adjustedLong / 30.0))
        let rawBranchIndex = monthBranchOffset + 2 
        let monthBranch = Branch.from(index: rawBranchIndex)
        
        let monthStemStart = (yearSB.stem.index % 5) * 2 + 2
        let monthOffset = (monthBranch.index - 2 + 12) % 12
        let monthStem = Stem.from(index: monthStemStart + monthOffset)
        let monthSB = StemBranch(stem: monthStem, branch: monthBranch)
        
        // --- Hour Pillar ---
        let hourBranchIndex = (currentHour + 1) / 2
        let hourBranch = Branch.from(index: hourBranchIndex)
        
        let lookupDayStem: Stem
        if currentHour >= 23 {
            lookupDayStem = daySB.stem.next
        } else {
            lookupDayStem = daySB.stem
        }
        
        let hourStemStart = (lookupDayStem.index % 5) * 2
        let hourStem = Stem.from(index: hourStemStart + hourBranch.index)
        let hourSB = StemBranch(stem: hourStem, branch: hourBranch)
        
        return FourPillars(year: yearSB, month: monthSB, day: daySB, hour: hourSB)
    }
    
    private func getTrueSolarTime(for date: Date, location: Location, calendar: Calendar) -> Date {
        // 1. Longitude Correction
        let standardLongitude = location.timeZone * 15.0
        let longitudeDiff = location.longitude - standardLongitude
        let longitudeCorrectionMin = longitudeDiff * 4.0
        
        // 2. Equation of Time Correction
        let eotMin = SolarCalculator.getEquationOfTime(date: date)
        
        let totalCorrectionMin = longitudeCorrectionMin + eotMin
        return date.addingTimeInterval(totalCorrectionMin * 60.0)
    }
}
