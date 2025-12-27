import Foundation
import GanZhi

func runExperiment() {
    let sampleSize = 100_000
    var temperatures: [Double] = []
    var moistures: [Double] = []
    
    var patternCounts: [String: Int] = [:]
    var elementCollects: [FiveElements: [Double]] = [
        .wood: [], .fire: [], .earth: [], .metal: [], .water: []
    ]
    
    print("Generating \(sampleSize) random BaZi charts...")
    
    let startYear = 1900
    let endYear = 2100
    let secondsInYear = 365.25 * 24 * 3600
    let startDate = Date(year: startYear, month: 1, day: 1, hour: 0, minute: 0)!
    
    for i in 1...sampleSize {
        let randomSeconds = Double.random(in: 0...(Double(endYear - startYear) * secondsInYear))
        let randomDate = startDate.addingTimeInterval(randomSeconds)
        let pillars = randomDate.fourPillars()
        
        // 1. Thermal Balance
        let tb = pillars.thermalBalance
        temperatures.append(tb.temperature)
        moistures.append(tb.moisture)
        
        // 2. Pattern
        let pattern = pillars.determinePattern()
        patternCounts[pattern.description, default: 0] += 1
        
        // 3. Five Element Strengths
        let strengths = pillars.elementStrengths
        for (element, strength) in strengths {
            elementCollects[element]?.append(strength)
        }
        
        if i % 10000 == 0 {
            print("Progress: \(i)/\(sampleSize)")
        }
    }
    
    struct Stats {
        let avg: Double
        let percentiles: [Int: Double] // 0, 10, 20... 100
    }

    func calculateStats(_ data: [Double]) -> Stats {
        let count = data.count
        if count == 0 { return Stats(avg: 0, percentiles: [:]) }
        let sorted = data.sorted()
        let avg = data.reduce(0, +) / Double(count)
        
        var percentiles: [Int: Double] = [:]
        for i in stride(from: 0, through: 100, by: 10) {
            let index = min(count - 1, Int(Double(count - 1) * Double(i) / 100.0))
            percentiles[i] = sorted[index]
        }
        return Stats(avg: avg, percentiles: percentiles)
    }
    
    print("\n--------------------------------------------------")
    print("Results for \(sampleSize) Random BaZi (1900-2100)")
    
    print("\n[Pattern Probability Ranking]")
    let sortedPatterns = patternCounts.sorted(by: { $0.value > $1.value })
    for (pattern, count) in sortedPatterns {
        let prob = (Double(count) / Double(sampleSize)) * 100
        let paddedPattern = pattern.padding(toLength: 20, withPad: " ", startingAt: 0)
        print("\(paddedPattern): \(count) (\(String(format: "%.2f", prob))%)")
    }
    
    print("\n[Five Element Strength Distribution]")
    for element in FiveElements.allCases {
        if let data = elementCollects[element] {
            let stats = calculateStats(data)
            let p0 = String(format: "%5.2f", stats.percentiles[0] ?? 0)
            let p50 = String(format: "%5.2f", stats.percentiles[50] ?? 0)
            let p100 = String(format: "%5.2f", stats.percentiles[100] ?? 0)
            let avg = String(format: "%5.2f", stats.avg)
            
            print("\(element.name.padding(toLength: 4, withPad: " ", startingAt: 0)) | Avg: \(avg) | Min: \(p0) | Med: \(p50) | Max: \(p100)")
        }
    }

    let tempStats = calculateStats(temperatures)
    let moistStats = calculateStats(moistures)
    
    func printDetailedStats(_ name: String, _ stats: Stats) {
        print("\n\(name) Distribution:")
        print("  Average: \(String(format: "%.2f", stats.avg))")
        print("  Percentiles:")
        let keys = stats.percentiles.keys.sorted()
        for key in keys {
            let label = "\(key)%".padding(toLength: 5, withPad: " ", startingAt: 0)
            let val = String(format: "%.2f", stats.percentiles[key] ?? 0)
            print("    \(label): \(val)")
        }
    }
    
    printDetailedStats("Temperature (寒暖)", tempStats)
    printDetailedStats("Moisture (湿燥)", moistStats)
    print("--------------------------------------------------\n")
}

runExperiment()
