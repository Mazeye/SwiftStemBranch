import Foundation
import GanZhi

// Helper to run analysis
func testAnalysis(year: (Stem, Branch), month: (Stem, Branch), day: (Stem, Branch), hour: (Stem, Branch)) {
    let pillarYear = StemBranch(stem: year.0, branch: year.1)
    let pillarMonth = StemBranch(stem: month.0, branch: month.1)
    let pillarDay = StemBranch(stem: day.0, branch: day.1)
    let pillarHour = StemBranch(stem: hour.0, branch: hour.1)
    
    let chart = FourPillars(year: pillarYear, month: pillarMonth, day: pillarDay, hour: pillarHour)
    
    print("---------------------------------------------------")
    print("Chart: \(chart)")
    print("Pattern: \(chart.determinePattern())")
    let analysis = chart.usefulGodAnalysis
    print("Results:")
    print(analysis.description)
    print("Yong Shen: \(analysis.yongShen.map { $0.name })")
    print("Ji Shen: \(analysis.jiShen.map { $0.name })")
    print("Fav Elements: \(analysis.favorableElements.map { $0.description })")
}

public func runUsefulGodTest() {
    print("Running Useful God Test...")

    // 1. Weak Day Master Example
    // DM: Jia Wood in Shen Month (Metal, Dead). Lots of Metal/Fire.
    testAnalysis(
        year: (.geng, .shen), // Metal Metal
        month: (.jia, .shen), // Wood Metal
        day: (.jia, .zi),     // Wood Water (Zi provides some root/resource)
        hour: (.bing, .yin)   // Fire Wood
    )

    // 2. Strong Day Master Example
    // DM: Bing Fire in Wu Month (Fire, Peak).
    testAnalysis(
        year: (.bing, .wu),
        month: (.bing, .wu),
        day: (.bing, .wu),
        hour: (.ren, .chen)   // Water Earth (Weak Killings)
    )

    // 3. Cold/Winter Example (Tiao Hou)
    // DM: Jia Wood in Zi Month (Water, Winter). Freezing.
    testAnalysis(
        year: (.ren, .zi),
        month: (.ren, .zi),
        day: (.jia, .zi),
        hour: (.ren, .shen)   // Water Metal
    )
    
    // Correction for call 3 (Winter / Cold)
    print("\n--- Corrected Winter Call ---")
    let pYear = StemBranch(stem: .geng, branch: .zi) // Metal Water
    let pMonth = StemBranch(stem: .wu, branch: .zi)  // Earth Water
    let pDay = StemBranch(stem: .jia, branch: .chen) // Wood Earth
    let pHour = StemBranch(stem: .jia, branch: .zi)  // Wood Water
    let winterChart = FourPillars(year: pYear, month: pMonth, day: pDay, hour: pHour)
    print("Winter Chart: \(winterChart)")
    print(winterChart.usefulGodAnalysis.description)
    print("Yong Shen: \(winterChart.usefulGodAnalysis.yongShen.map{ $0.name })")
    print("Fav Elements: \(winterChart.usefulGodAnalysis.favorableElements.map{ $0.description })")
}
