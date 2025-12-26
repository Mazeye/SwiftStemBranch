import XCTest
@testable import GanZhi

final class ThermalBalanceTests: XCTestCase {
    
    func testTemperatureLogic() {
        // 1. Winter month (Zi 子), no fire
        // Baseline: -30.0
        let winterNoFire = FourPillars(
            year: StemBranch(stem: .jia, branch: .zi),
            month: StemBranch(stem: .jia, branch: .zi),
            day: StemBranch(stem: .jia, branch: .zi),
            hour: StemBranch(stem: .jia, branch: .zi)
        )
        // For Zi month/branch, Jia energy calculation involves seeking roots.
        // But for temperature, only fire matters now.
        // Total Temp = -30.0 (baseline) + 0 (no fire stems/branches)
        XCTAssertEqual(winterNoFire.thermalBalance.temperature, -30.0)
        
        // 2. Summer month (Wu 午), with fire
        // Baseline: 30.0
        // Bing Zi Pillar: Bing (Fire Stem) on Zi (Water Branch)
        // Bing fire on Zi: Life stage is 'Si' (Death) -> Multiplier 0.5
        // Wu month Bing multiplier: 1.2
        // Total Bing Weight = 0.5 * 1.2 = 0.6
        // Bing Base: 10.0
        // Energy: stemEnergy involves rooting. On a chart with many Zi/Wu, energy will be > 1.0.
        // For simplicity, let's just check if it's hotter than baseline.
        let summerWithFire = FourPillars(
            year: StemBranch(stem: .jia, branch: .zi),
            month: StemBranch(stem: .jia, branch: .wu),
            day: StemBranch(stem: .bing, branch: .zi),
            hour: StemBranch(stem: .jia, branch: .zi)
        )
        let temp = summerWithFire.thermalBalance.temperature
        print("Summer with Bing on Zi temp: \(temp)")
        XCTAssertTrue(temp > 30.0)
        
        // 3. Life Stage weighting: Di Wang (2.0) vs Si (0.5)
        // Bing on Wu (Di Wang) vs Bing on Zi (Si)
        let bingOnWu = FourPillars(
            year: StemBranch(stem: .jia, branch: .zi),
            month: StemBranch(stem: .jia, branch: .zi),
            day: StemBranch(stem: .bing, branch: .wu),
            hour: StemBranch(stem: .jia, branch: .zi)
        )
        let bingOnZi = FourPillars(
            year: StemBranch(stem: .jia, branch: .zi),
            month: StemBranch(stem: .jia, branch: .zi),
            day: StemBranch(stem: .bing, branch: .zi),
            hour: StemBranch(stem: .jia, branch: .zi)
        )
        // Both Zi month (Baseline -30.0)
        // Bing on Wu weight: 2.0 (Di Wang) * 0.8 (Zi month Bing coeff) = 1.6
        // Bing on Zi weight: 0.5 (Si) * 0.8 (Zi month Bing coeff) = 0.4
        XCTAssertTrue(bingOnWu.thermalBalance.temperature > bingOnZi.thermalBalance.temperature)
    }
}
