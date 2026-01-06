import Foundation
import GanZhi

func runExperiment(runThermal: Bool, runPattern: Bool) {
    let sampleSize = 100_000
    var temperatures: [Double] = []
    var moistures: [Double] = []
    
    // Group by Day Master (Ten Stems)
    var temperaturesByStem: [Stem: [Double]] = [:]
    var moisturesByStem: [Stem: [Double]] = [:]
    
    // Initialize collections
    for stem in Stem.allCases {
        temperaturesByStem[stem] = []
        moisturesByStem[stem] = []
    }
    
    var patternCounts: [String: Int] = [:]
    var elementCollects: [FiveElements: [Double]] = [
        .wood: [], .fire: [], .earth: [], .metal: [], .water: []
    ]
    
    print("Generating \(sampleSize) random BaZi charts...")
    print("Modes: Thermal=\(runThermal), Pattern/Element=\(runPattern)")
    
    let startYear = 1900
    let endYear = 2100
    let secondsInYear = 365.25 * 24 * 3600
    let startDate = Date(year: startYear, month: 1, day: 1, hour: 0, minute: 0)!
    
    for i in 1...sampleSize {
        let randomSeconds = Double.random(in: 0...(Double(endYear - startYear) * secondsInYear))
        let randomDate = startDate.addingTimeInterval(randomSeconds)
        let pillars = randomDate.fourPillars()
        
        let dayMaster = pillars.day.stem.value
        
        // 1. Thermal Balance
        if runThermal {
            let tb = pillars.thermalBalance
            temperatures.append(tb.temperature)
            moistures.append(tb.moisture)
            
            temperaturesByStem[dayMaster]?.append(tb.temperature)
            moisturesByStem[dayMaster]?.append(tb.moisture)
        }
        
        // 2 & 3. Pattern & Five Element Strengths
        if runPattern {
            let pattern = pillars.determinePattern()
            patternCounts[pattern.description, default: 0] += 1
            
            let strengths = pillars.elementStrengths
            for (element, strength) in strengths {
                elementCollects[element]?.append(strength)
            }
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
        // Standard deciles
        for i in stride(from: 0, through: 100, by: 10) {
            let index = min(count - 1, Int(Double(count - 1) * Double(i) / 100.0))
            percentiles[i] = sorted[index]
        }
        // Add 25% and 75%
        for i in [25, 75] {
            let index = min(count - 1, Int(Double(count - 1) * Double(i) / 100.0))
            percentiles[i] = sorted[index]
        }
        
        return Stats(avg: avg, percentiles: percentiles)
    }
    
    print("\n--------------------------------------------------")
    print("Results for \(sampleSize) Random BaZi (1900-2100)")
    
    if runPattern {
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
    }

    if runThermal {
        let tempStats = calculateStats(temperatures)
        let moistStats = calculateStats(moistures)
        
        func printDetailedStats(_ name: String, _ stats: Stats) {
            print("\n\(name) Distribution (Overall):")
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
        
        // Print Grouped By Stem Stats
        print("\n[Thermal Stats by Day Master]")
        
        // Helper to print a compact row
        func printRowStats(label: String, stats: Stats) {
            let p10 = String(format: "%.1f", stats.percentiles[10] ?? 0)
            let p25 = String(format: "%.1f", stats.percentiles[25] ?? 0)
            let p50 = String(format: "%.1f", stats.percentiles[50] ?? 0) // Median
            let p75 = String(format: "%.1f", stats.percentiles[75] ?? 0)
            let p90 = String(format: "%.1f", stats.percentiles[90] ?? 0)
            let avg = String(format: "%.1f", stats.avg)
            print("\(label) | Avg: \(avg) | 10%: \(p10) | 25%: \(p25) | 50%: \(p50) | 75%: \(p75) | 90%: \(p90)")
        }
        
        print("\nTemperature (寒暖) by Day Master:")
        for stem in Stem.allCases {
             if let data = temperaturesByStem[stem], !data.isEmpty {
                 let s = calculateStats(data)
                 printRowStats(label: stem.character.padding(toLength: 4, withPad: " ", startingAt: 0), stats: s)
             }
        }
        
        print("\nMoisture (湿燥) by Day Master:")
        for stem in Stem.allCases {
             if let data = moisturesByStem[stem], !data.isEmpty {
                 let s = calculateStats(data)
                 printRowStats(label: stem.character.padding(toLength: 4, withPad: " ", startingAt: 0), stats: s)
             }
        }
    }
    print("--------------------------------------------------\n")
}

let args = CommandLine.arguments
let runThermal = args.contains("--thermal") || args.contains("-t")
let runPattern = args.contains("--pattern") || args.contains("-p")

// Default to ALL if no flags specified
if !runThermal && !runPattern {
    runExperiment(runThermal: true, runPattern: true)
} else {
    runExperiment(runThermal: runThermal, runPattern: runPattern)
}
