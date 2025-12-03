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
        // Correct BaZi: Wu-Zi Year, Geng-Shen Month, Geng-Chen Day, Bing-Xu Hour
        
        // Use standard calendar
        let date = Date(year: 2008, month: 8, day: 8, hour: 20, minute: 8)!
        let pillars = date.fourPillars()
        
        XCTAssertEqual(pillars.year.character, "戊子")
        XCTAssertEqual(pillars.month.character, "庚申")
        XCTAssertEqual(pillars.day.character, "庚辰")
        XCTAssertEqual(pillars.hour.character, "丙戌")
    }
    
    func testTrueSolarTimeAdjustment() {
        // 2024-06-15 10:00
        let date = Date(year: 2024, month: 6, day: 15, hour: 10, minute: 0)!
        let urumqi = Location(longitude: 87.6, timeZone: 8.0)
        
        let standardPillars = date.fourPillars()
        let trueSolarPillars = date.fourPillars(at: urumqi)
        
        XCTAssertEqual(standardPillars.hour.branch.character, "巳")
        XCTAssertEqual(trueSolarPillars.hour.branch.character, "辰")
    }
    
    func testFiveElementsDistribution() {
        // Test case: 2008-08-08 20:08
        // Year: 戊子 (Earth, Water)
        // Month: 庚申 (Metal, Metal)
        // Day: 庚辰 (Metal, Earth)
        // Hour: 丙戌 (Fire, Earth)
        
        let date = Date(year: 2008, month: 8, day: 8, hour: 20, minute: 8)!
        let pillars = date.fourPillars()
        let counts = pillars.fiveElementCounts
        
        XCTAssertEqual(counts[.earth], 3)
        XCTAssertEqual(counts[.metal], 3)
        XCTAssertEqual(counts[.water], 1)
        XCTAssertEqual(counts[.fire], 1)
        XCTAssertEqual(counts[.wood, default: 0], 0)
    }
}
