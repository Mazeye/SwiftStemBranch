import Foundation

/// A date wrapper that facilitates conversion from Gregorian Calendar to Chinese Gan-Zhi (Stem-Branch) Calendar.
/// It supports high-precision astronomical calculations for solar terms and True Solar Time.
public struct LunarDate {
    public let year: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    
    public init(date: Date = Date()) {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        self.year = comps.year!
        self.month = comps.month!
        self.day = comps.day!
        self.hour = comps.hour!
        self.minute = comps.minute!
    }
    
    public init(y: Int, m: Int, d: Int, h: Int, min: Int = 0) {
        self.year = y
        self.month = m
        self.day = d
        self.hour = h
        self.minute = min
    }
    
    public var toDate: Date {
        var comps = DateComponents()
        comps.year = self.year
        comps.month = self.month
        comps.day = self.day
        comps.hour = self.hour
        comps.minute = self.minute
        return Calendar.current.date(from: comps) ?? Date()
    }

    public var fourPillars: FourPillars {
        return calculateFourPillars(for: self.toDate)
    }
    
    public func fourPillars(at location: Location) -> FourPillars {
        let trueSolarDate = getTrueSolarTime(location: location)
        return calculateFourPillars(for: trueSolarDate)
    }

    // MARK: - Internal Logic

    private func calculateFourPillars(for date: Date) -> FourPillars {
        // 1. Astronomical Solar Longitude
        let longitude = SolarCalculator.getSolarLongitude(date: date)
        
        // 2. Day Pillar Calculation using UTC Calendar difference
        
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(secondsFromGMT: 0)!
        
        // Base Date: 2000-01-01
        let baseDate = DateComponents(calendar: utcCal, year: 2000, month: 1, day: 1).date!
        
        let localCal = Calendar.current
        let comps = localCal.dateComponents([.year, .month, .day, .hour], from: date)
        let currentYear = comps.year!
        let currentMonth = comps.month!
        let currentDay = comps.day!
        let currentHour = comps.hour!
        
        let targetComponents = DateComponents(year: currentYear, month: currentMonth, day: currentDay)
        let targetDate = utcCal.date(from: targetComponents)!
        
        let daysDiff = utcCal.dateComponents([.day], from: baseDate, to: targetDate).day!
        
        // Revert to pure mathematical continuity based on 2000-01-01 = Wu-Wu (54).
        // This aligns with the user's expectation that 2008-08-08 is Geng-Chen.
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
    
    private func getTrueSolarTime(location: Location) -> Date {
        let standardDate = self.toDate
        
        let standardLongitude = location.timeZone * 15.0
        let longitudeDiff = location.longitude - standardLongitude
        let longitudeCorrectionMin = longitudeDiff * 4.0
        
        let eotMin = SolarCalculator.getEquationOfTime(date: standardDate)
        
        let totalCorrectionMin = longitudeCorrectionMin + eotMin
        return standardDate.addingTimeInterval(totalCorrectionMin * 60.0)
    }
}
