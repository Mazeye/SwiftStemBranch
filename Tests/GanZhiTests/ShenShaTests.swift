import XCTest
@testable import GanZhi

final class ShenShaTests: XCTestCase {
    
    // Helper to create Pillars
    // Case 1: Jia Zi Day
    func testTianYiGuiRen() {
        // 甲戊并牛羊 (Jia/Wu see Chou/Wei)
        // Create a mock pillars with Jia Day Master and Chou Year Branch
        // We need a way to construct FourPillars manually without Date
        // FourPillars(year: ..., month: ..., day: ..., hour: ...)
        
        let jiaZi = StemBranch(stem: .jia, branch: .zi) // Day
        let yiChou = StemBranch(stem: .yi, branch: .chou) // Year (Chou is Tian Yi for Jia)
        
        let pillars = FourPillars(
            year: yiChou,
            month: StemBranch(stem: .bing, branch: .yin),
            day: jiaZi,
            hour: StemBranch(stem: .ding, branch: .mao)
        )
        
        // Check Year Branch (Chou)
        let stars = pillars.shenSha(for: pillars.year.branch)
        XCTAssertTrue(stars.contains(.tianYi), "Jia Day Master should see Chou as Tian Yi Gui Ren")
        
        // Check Hour Branch (Mao) - Not Tian Yi for Jia
        let hourStars = pillars.shenSha(for: pillars.hour.branch)
        XCTAssertFalse(hourStars.contains(.tianYi), "Mao is not Tian Yi for Jia")
    }
    
    func testLuShen() {
        // 甲禄在寅 (Jia Lu at Yin) - Lu Shen is Lin Guan stage
        
        let jiaYin = StemBranch(stem: .jia, branch: .yin) // Day
        
        let pillars = FourPillars(
            year: StemBranch(stem: .geng, branch: .shen),
            month: StemBranch(stem: .xin, branch: .you),
            day: jiaYin, // Jia Day Master sitting on Yin (Lu)
            hour: StemBranch(stem: .ren, branch: .xu)
        )
        
        // Check Day Branch (Yin)
        let stars = pillars.shenSha(for: pillars.day.branch)
        XCTAssertTrue(stars.contains(.luShen), "Jia Day Master sitting on Yin should have Lu Shen")
    }
    
    func testYangRen() {
        // 甲刃在卯 (Jia Yang Ren at Mao) - Di Wang stage
        
        let jiaZi = StemBranch(stem: .jia, branch: .zi) // Day
        let dingMao = StemBranch(stem: .ding, branch: .mao) // Hour (Mao)
        
        let pillars = FourPillars(
            year: StemBranch(stem: .wu, branch: .chen),
            month: StemBranch(stem: .ji, branch: .si),
            day: jiaZi,
            hour: dingMao
        )
        
        // Check Hour Branch (Mao)
        let stars = pillars.shenSha(for: pillars.hour.branch)
        XCTAssertTrue(stars.contains(.yangRen), "Jia Day Master seeing Mao should have Yang Ren")
    }
    
    func testYiMa() {
        // 申子辰马在寅 (Shen/Zi/Chen Year/Day -> Yi Ma at Yin)
        
        let year = StemBranch(stem: .jia, branch: .zi) // Year Branch Zi
        let hour = StemBranch(stem: .bing, branch: .yin) // Hour Branch Yin
        
        let pillars = FourPillars(
            year: year,
            month: StemBranch(stem: .yi, branch: .chou),
            day: StemBranch(stem: .ding, branch: .mao),
            hour: hour
        )
        
        // Check Hour Branch (Yin)
        let stars = pillars.shenSha(for: pillars.hour.branch)
        XCTAssertTrue(stars.contains(.yiMa), "Zi Year seeing Yin should have Yi Ma")
    }
    
    func testTaoHua() {
        // 申子辰在酉 (Shen/Zi/Chen Year/Day -> Tao Hua at You)
        
        let day = StemBranch(stem: .ren, branch: .chen) // Day Branch Chen
        let month = StemBranch(stem: .gui, branch: .you) // Month Branch You
        
        let pillars = FourPillars(
            year: StemBranch(stem: .jia, branch: .wu),
            month: month,
            day: day,
            hour: StemBranch(stem: .yi, branch: .wei)
        )
        
        // Check Month Branch (You)
        let stars = pillars.shenSha(for: pillars.month.branch)
        XCTAssertTrue(stars.contains(.taoHua), "Chen Day seeing You should have Tao Hua")
    }
    
    func testKongWang() {
        // Jia Zi Day (Xun starts at Jia Zi) -> Empty: Xu, Hai
        
        let jiaZi = StemBranch(stem: .jia, branch: .zi) // Day
        let bingXu = StemBranch(stem: .bing, branch: .xu) // Year (Xu is Kong Wang for Jia Zi Xun)
        
        let pillars = FourPillars(
            year: bingXu,
            month: StemBranch(stem: .wu, branch: .chen),
            day: jiaZi,
            hour: StemBranch(stem: .geng, branch: .wu)
        )
        
        // Check Year Branch (Xu)
        let stars = pillars.shenSha(for: pillars.year.branch)
        XCTAssertTrue(stars.contains(.kongWang), "Jia Zi Day seeing Xu should be Kong Wang")
    }
}

