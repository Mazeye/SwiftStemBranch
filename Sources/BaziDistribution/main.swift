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
    
    func calculateStats(_ data: [Double]) -> (min: Double, q1: Double, median: Double, q3: Double, max: Double, avg: Double) {
        let count = data.count
        if count == 0 { return (0, 0, 0, 0, 0, 0) }
        let sorted = data.sorted()
        let min = sorted[0]
        let q1 = sorted[count / 4]
        let median = sorted[count / 2]
        let q3 = sorted[count * 3 / 4]
        let max = sorted[count - 1]
        let avg = data.reduce(0, +) / Double(count)
        return (min, q1, median, q3, max, avg)
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
            print("\(element.name.padding(toLength: 4, withPad: " ", startingAt: 0)) | " +
                  "Avg: \(String(format: "%5.2f", stats.avg)) | " +
                  "Min: \(String(format: "%5.2f", stats.min)) | " +
                  "Q1: \(String(format: "%5.2f", stats.q1)) | " +
                  "Med: \(String(format: "%5.2f", stats.median)) | " +
                  "Q3: \(String(format: "%5.2f", stats.q3)) | " +
                  "Max: \(String(format: "%5.2f", stats.max))")
        }
    }

    let tempStats = calculateStats(temperatures)
    let moistStats = calculateStats(moistures)
    
    print("\n[Thermal Balance Distribution]")
    print("Temp   | " +
          "Avg: \(String(format: "%5.2f", tempStats.avg)) | " +
          "Min: \(String(format: "%5.2f", tempStats.min)) | " +
          "Q1: \(String(format: "%5.2f", tempStats.q1)) | " +
          "Med: \(String(format: "%5.2f", tempStats.median)) | " +
          "Q3: \(String(format: "%5.2f", tempStats.q3)) | " +
          "Max: \(String(format: "%5.2f", tempStats.max))")
    print("Moist  | " +
          "Avg: \(String(format: "%5.2f", moistStats.avg)) | " +
          "Min: \(String(format: "%5.2f", moistStats.min)) | " +
          "Q1: \(String(format: "%5.2f", moistStats.q1)) | " +
          "Med: \(String(format: "%5.2f", moistStats.median)) | " +
          "Q3: \(String(format: "%5.2f", moistStats.q3)) | " +
          "Max: \(String(format: "%5.2f", moistStats.max))")
    print("--------------------------------------------------\n")
}

runExperiment()
