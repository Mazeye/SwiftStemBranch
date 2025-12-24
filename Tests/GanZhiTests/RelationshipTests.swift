import XCTest
@testable import GanZhi

final class RelationshipTests: XCTestCase {
    
    func testStemRelationships() {
        // Jia-Ji Combination
        // 1994-06-25 10:00 -> 甲戌年 庚午月 壬子日 乙巳时 (Wait, let me find a Jia-Ji date)
        // Jia: 2014, Ji: month? 
        // 1989 (Ji Si) year, month Jia?
        // Let's use custom pillars for test if possible, or reliable dates.
        
        // Example: 2014-06-06 12:00 -> 甲午年 庚午月 己未日 庚午时 (Jia-Ji combination year-day)
        let date1 = Date(year: 2014, month: 6, day: 6, hour: 12, minute: 0)!
        let p1 = date1.fourPillars()
        let rels1 = p1.relationships
        
        XCTAssertTrue(rels1.contains { $0.type == .stemCombination && $0.characters == "甲己" })
        XCTAssertTrue(rels1.contains { $0.type == .branchHarm && $0.characters == "午未" })
        XCTAssertTrue(rels1.contains { $0.type == .branchPunishment && $0.characters == "午午" })
    }
    
    func testBranchClashAndHarmony() {
        // Zi-Wu Clash
        let date = Date(year: 1990, month: 12, day: 24, hour: 12, minute: 0)! // Geng Wu Year, Wu Zi Month
        let p = date.fourPillars()
        let rels = p.relationships
        
        XCTAssertTrue(rels.contains { $0.type == .branchClash && ($0.characters == "子午" || $0.characters == "午子") })
    }
    
    func testComplexRelationships() {
        // Triple Harmony: Shen-Zi-Chen
        // 1992 (Shen) Sep (You) 13 (Chen) 00:00 (Zi)
        let date = Date(year: 1992, month: 9, day: 13, hour: 0, minute: 5)!
        let p = date.fourPillars()
        let rels = p.relationships
        
        XCTAssertTrue(rels.contains { $0.type == .branchTripleHarmony && $0.characters == "申子辰" })
    }
}
