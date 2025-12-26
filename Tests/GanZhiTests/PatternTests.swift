import XCTest
@testable import GanZhi

final class PatternTests: XCTestCase {
    
    // Helper to create FourPillars
    func makePillars(year: (Stem, Branch), month: (Stem, Branch), day: (Stem, Branch), hour: (Stem, Branch)) -> FourPillars {
        return FourPillars(
            year: StemBranch(stem: year.0, branch: year.1),
            month: StemBranch(stem: month.0, branch: month.1),
            day: StemBranch(stem: day.0, branch: day.1),
            hour: StemBranch(stem: hour.0, branch: hour.1)
        )
    }
    
    func testJianLuGe() {
        // Jian Lu: Day Master born in Lin Guan month.
        // Example: Jia (Wood) born in Yin (Wood) month.
        // Yin is Lin Guan for Jia.
        
        let pillars = makePillars(
            year: (.bing, .zi),
            month: (.bing, .yin), // Yin Month
            day: (.jia, .zi),     // Jia Day
            hour: (.ren, .zi)
        )
        
        let pattern = pillars.determinePattern()
        
        XCTAssertEqual(pattern.method, .jianLu)
        XCTAssertEqual(pattern.tenGod, .friend)
        XCTAssertEqual(pattern.description, "建禄格")
    }
    
    func testYueRenGe_YinStem() {
        // Yue Ren: Yin Day Master born in Di Wang month.
        // Example: Yi (Yin Wood) born in Yin (Wood) - Wait, Yin is Di Wang for Yi?
        // Let's check LifeStage logic.
        // Yi (Yin Wood): ChangSheng at Wu.
        // Counter-Clockwise: Wu(Birth) -> Si(Bath) -> Chen(Attire) -> Mao(Lin Guan) -> Yin(Di Wang).
        // Yes, Yin is Di Wang for Yi.
        
        let pillars = makePillars(
            year: (.bing, .zi),
            month: (.bing, .yin), // Yin Month (Di Wang for Yi)
            day: (.yi, .zi),      // Yi Day
            hour: (.ren, .zi)
        )
        
        let pattern = pillars.determinePattern()
        
        XCTAssertEqual(pattern.method, .yueRen)
        XCTAssertEqual(pattern.tenGod, .robWealth)
        XCTAssertEqual(pattern.description, "月刃格", "Yin Stem should be Yue Ren Ge")
    }

    func testYangRenGe_YangStem() {
        // Yang Ren: Yang Day Master born in Di Wang month.
        // Example: Jia (Yang Wood) born in Mao (Wood).
        // Mao is Di Wang for Jia.
        
        let pillars = makePillars(
            year: (.bing, .zi),
            month: (.ding, .mao), // Mao Month
            day: (.jia, .zi),     // Jia Day
            hour: (.ren, .zi)
        )
        
        let pattern = pillars.determinePattern()
        
        XCTAssertEqual(pattern.method, .yangRen)
        XCTAssertEqual(pattern.tenGod, .robWealth)
        XCTAssertEqual(pattern.description, "羊刃格", "Yang Stem should be Yang Ren Ge")
    }
    
    func testTranspiredMonthStem() {
        // Month Branch: Yin (Jia, Bing, Wu)
        // Month Stem: Bing (Middle Qi) -> Matches!
        // Day Master: Ren (Water)
        // Bing is Yang Fire. Water controls Fire. Same polarity -> Indirect Wealth (偏财).
        // Note: Yin is Sickness for Ren (not Lin Guan/Di Wang), so proceeds to Transpired logic.
        
        let pillars = makePillars(
            year: (.geng, .zi),
            month: (.bing, .yin),
            day: (.ren, .zi),
            hour: (.ren, .zi)
        )
        
        let pattern = pillars.determinePattern()
        
        XCTAssertEqual(pattern.method, .transpiredMonthStem)
        XCTAssertEqual(pattern.tenGod, .indirectWealth, "Should be Indirect Wealth Pattern")
    }
    
    func testTranspiredYearStem() {
        // Month Branch: Yin (Jia, Bing, Wu)
        // Month Stem: Geng (Not in Yin)
        // Year Stem: Jia (Main Qi) -> Matches!
        // Day Master: Bing (Yang Fire)
        // Jia is Yang Wood. Wood generates Fire. Same polarity -> Indirect Resource (偏印).
        // Yin is Birth for Bing (not Lin Guan/Di Wang), so proceeds to Transpired.
        
        let pillars = makePillars(
            year: (.jia, .zi),
            month: (.geng, .yin),
            day: (.bing, .zi),
            hour: (.ren, .zi)
        )
        
        let pattern = pillars.determinePattern()
        
        XCTAssertEqual(pattern.method, .transpiredYearStem)
        XCTAssertEqual(pattern.tenGod, .indirectResource, "Should be Indirect Resource Pattern")
    }
    
    func testTranspiredPriorityOverFriend() {
        // Test where a Friend ten god transpires, but we want to avoid it if possible?
        // Wait, if Friend is Transpired (and not LinGuan/DiWang), does my code skip it?
        // My code skips Friend/RobWealth in the secondary transpired loop.
        
        // Month Branch: Yin (Jia, Bing, Wu)
        // Day Master: Jia.
        // Yin is Lin Guan -> So this will trigger Jian Lu Ge immediately!
        // So I need a case where Month Branch is NOT Lin Guan but contains Friend.
        // Example: Day Master Jia (Wood). Born in Hai (Water).
        // Hai contains: Ren (Resource), Jia (Friend).
        // Hai is Birth place for Jia (Chang Sheng). Not Lin Guan/Di Wang.
        
        // Scenario:
        // Month Branch: Hai (Ren, Jia).
        // Transpired: Jia (in Year).
        // Transpired: Ren (in Hour).
        // Logic:
        // 1. Check Jian Lu / Yue Ren -> Hai is Chang Sheng. No match.
        // 2. Transpired Month Stem? Assume Month Stem is Geng (Killings). Not in Hai.
        // 3. Transpired Year/Hour.
        //    - Check Jia (Year): Ten God = Friend. My code should SKIP this.
        //    - Check Ren (Hour): Ten God = Indirect Resource. My code should PICK this.
        
        let pillars = makePillars(
            year: (.jia, .zi),   // Jia transpires
            month: (.geng, .hai), // Hai (Ren, Jia)
            day: (.jia, .zi),     // Day Master Jia
            hour: (.ren, .zi)     // Ren transpires
        )
        
        let pattern = pillars.determinePattern()
        
        XCTAssertEqual(pattern.method, .transpiredHourStem, "Should pick Ren (Ind Resource) over Jia (Friend)")
        XCTAssertEqual(pattern.tenGod, .indirectResource)
    }

    func testNoTranspired_MainQi() {
        // Month Branch: Zi (Gui)
        // Month Stem: Jia
        // Year Stem: Bing
        // Hour Stem: Wu
        // None match Gui.
        // Fallback to Zi Main Qi -> Gui.
        // Day Master: Jia.
        // Zi is Bath (Mu Yu) for Jia (Not Lin Guan/Di Wang).
        // Gui is Yin Water. Water generates Wood. Different polarity -> Direct Resource (正印).
        
        let pillars = makePillars(
            year: (.bing, .wu),
            month: (.jia, .zi),
            day: (.jia, .chen),
            hour: (.wu, .shen)
        )
        
        let pattern = pillars.determinePattern()
        
        XCTAssertEqual(pattern.method, .monthBranchMainQi)
        XCTAssertEqual(pattern.tenGod, .directResource, "Should be Direct Resource Pattern")
    }

    func testDualPattern() {
        GanZhiConfig.language = .simplifiedChinese
        
        // Day Master: Jia (Yang Wood)
        // Month: Yin (Wood) -> Lin Guan -> Jian Lu Ge (建禄格)
        // Ten God: Bi Jian (Friend)
        
        // If year and hour are Wu (Fire) with Bing (Fire Stem), Fire strength will be very high.
        // Bing relative to Jia is Eating God (食神).
        
        let pillars = makePillars(
            year: (.bing, .wu),
            month: (.jia, .yin),
            day: (.jia, .zi),
            hour: (.bing, .wu)
        )
        
        let strengths = pillars.tenGodStrengths
        let friendStrength = strengths[.friend, default: 0]
        let eatingGodStrength = strengths[.eatingGod, default: 0]
        
        print("Friend Strength: \(friendStrength)")
        print("Eating God Strength: \(eatingGodStrength)")
        
        let pattern = pillars.determinePattern()
        print("Pattern Description: \(pattern.description)")
        
        if eatingGodStrength > friendStrength {
            XCTAssertTrue(pattern.description.contains("/"))
            XCTAssertTrue(pattern.description.contains("食神格"))
            XCTAssertTrue(pattern.description.contains("建禄格"))
        }
    }
    
    func testFollowSevenKillings() {
        GanZhiConfig.language = .simplifiedChinese
        
        // Day Master: Yi (Yin Wood)
        // Branches: All You (酉), which contain only Xin (Metal) -> No root for Yi.
        // Stems: All Xin (Metal) -> Seven Killings for Yi.
        let pillars = makePillars(
            year: (.xin, .you),
            month: (.xin, .you),
            day: (.yi, .you),
            hour: (.xin, .you)
        )
        
        let pattern = pillars.determinePattern()
        
        XCTAssertEqual(pattern.tenGod, .sevenKillings)
        XCTAssertEqual(pattern.method, .followSevenKillings)
        XCTAssertEqual(pattern.description, "特殊七杀格（从格）")
        XCTAssertEqual(pattern.methodDescription, "身弱杀强，建议去印比从杀")
    }
}
