import XCTest
@testable import GanZhi

final class GanZhiTests: XCTestCase {
    
    func testStemBranchCycle() {
        let jiaZi = StemBranch.from(index: 0)
        XCTAssertEqual(jiaZi.character, "甲子")
        let guiHai = StemBranch.from(index: 59)
        XCTAssertEqual(guiHai.character, "癸亥")
        XCTAssertEqual(jiaZi.next.character, "乙丑")
        XCTAssertEqual(jiaZi.previous.character, "癸亥")
    }
    
    func testSolarLongitude() {
        let components = DateComponents(timeZone: TimeZone(secondsFromGMT: 0), year: 2024, month: 3, day: 20, hour: 3, minute: 6)
        let date = Calendar.current.date(from: components)!
        let longitude = SolarCalculator.getSolarLongitude(date: date)
        XCTAssertEqual(longitude, 0.0, accuracy: 0.1, "Spring Equinox should be near 0 degrees")
    }
    
    func testRealWorldBazi() {
        // Test case: 2008-08-08 20:08 (Beijing Olympics Opening)
        // Standard Time: 2008-08-08 20:08
        // Based on Math Continuity from 2000-01-01 (Wu-Wu):
        // Year: Wu-Zi (戊子)
        // Month: Geng-Shen (庚申)
        // Day: Geng-Chen (庚辰)
        // Hour: Bing-Xu (丙戌)
        
        let date = LunarDate(y: 2008, m: 8, d: 8, h: 20, min: 8)
        let pillars = date.fourPillars
        
        // 2008 is Wu-Zi (戊子)
        XCTAssertEqual(pillars.year.character, "戊子")
        
        // August 8 is after Li Qiu (Start of Autumn, Aug 7).
        // So it is Shen (Monkey) Month.
        // Wu Year -> Geng-Shen Month
        XCTAssertEqual(pillars.month.character, "庚申")
        
        // Day Pillar: 2008-08-08
        // Mathematical Calculation: Geng-Chen (庚辰)
        XCTAssertEqual(pillars.day.character, "庚辰")
        
        // Hour Pillar: 20:08 is Xu Hour (19:00-21:00)
        // Geng Day -> Bing-Xu Hour (Five Rats: Yi/Geng -> Bing)
        XCTAssertEqual(pillars.hour.character, "丙戌")
    }
    
    func testTrueSolarTimeAdjustment() {
        let date = LunarDate(y: 2024, m: 6, d: 15, h: 10, min: 0) // 10:00
        let urumqi = Location(longitude: 87.6, timeZone: 8.0)
        
        let standardPillars = date.fourPillars
        let trueSolarPillars = date.fourPillars(at: urumqi)
        
        XCTAssertEqual(standardPillars.hour.branch.character, "巳")
        XCTAssertEqual(trueSolarPillars.hour.branch.character, "辰")
    }
}
