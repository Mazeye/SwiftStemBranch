import Foundation
import GanZhi

func runExperiment(runThermal: Bool, runPattern: Bool, runElements: Bool) {
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

    // Group by Day Master Element (Five Elements)
    var temperaturesByElement: [FiveElements: [Double]] = [:]
    var moisturesByElement: [FiveElements: [Double]] = [:]

    for element in FiveElements.allCases {
        temperaturesByElement[element] = []
        moisturesByElement[element] = []
    }

    var patternCounts: [String: Int] = [:]

    // Matrix: [DM Element : [Target Element : [Values]]]
    var elementStatsByDM: [FiveElements: [FiveElements: [Double]]] = [:]
    for dm in FiveElements.allCases {
        elementStatsByDM[dm] = [:]
        for target in FiveElements.allCases {
            elementStatsByDM[dm]?[target] = []
        }
    }

    print("Generating \(sampleSize) random BaZi charts...")
    print("Modes: Thermal=\(runThermal), Pattern=\(runPattern), Elements=\(runElements)")

    let startYear = 1900
    let endYear = 2100
    let secondsInYear = 365.25 * 24 * 3600
    let startDate = Date(year: startYear, month: 1, day: 1, hour: 0, minute: 0)!

    for i in 1...sampleSize {
        let randomSeconds = Double.random(in: 0...(Double(endYear - startYear) * secondsInYear))
        let randomDate = startDate.addingTimeInterval(randomSeconds)
        let pillars = randomDate.fourPillars()

        // 1. Thermal Balance
        if runThermal {
            let dayMaster = pillars.day.stem.value
            let tb = pillars.thermalBalance
            temperatures.append(tb.temperature)
            moistures.append(tb.moisture)

            temperaturesByStem[dayMaster]?.append(tb.temperature)
            moisturesByStem[dayMaster]?.append(tb.moisture)

            let dmElement = dayMaster.fiveElement
            temperaturesByElement[dmElement]?.append(tb.temperature)
            moisturesByElement[dmElement]?.append(tb.moisture)
        }

        // 2. Pattern
        if runPattern {
            let pattern = pillars.determinePattern()
            patternCounts[pattern.description, default: 0] += 1
        }

        // 3. Five Element Analysis (Grouped by DM)
        if runElements {
            let dmElement = pillars.day.stem.value.fiveElement
            let strengths = pillars.elementStrengths

            for (element, strength) in strengths {
                elementStatsByDM[dmElement]?[element]?.append(strength)
            }
        }

        if i % 10000 == 0 {
            print("Progress: \(i)/\(sampleSize)")
        }
    }

    struct Stats {
        let avg: Double
        let percentiles: [Int: Double]  // 0, 10, 20... 100
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
    }

    if runElements {
        print("\n[Five Element Distribution by Day Master]")
        print("Format: [Target Element] Avg (Med) | ...")

        for dm in FiveElements.allCases {
            print("\n=== Day Master: \(dm.name) (日主: \(dm.name)) ===")
            print("Target |   Avg |   Min |   10% |   25% |   50% |   75% |   90% |   Max")
            print("-------|-------|-------|-------|-------|-------|-------|-------|------")

            for target in FiveElements.allCases {
                if let data = elementStatsByDM[dm]?[target] {
                    let s = calculateStats(data)
                    let avg = String(format: "%5.1f", s.avg)
                    let min = String(format: "%5.1f", s.percentiles[0] ?? 0)
                    let p10 = String(format: "%5.1f", s.percentiles[10] ?? 0)
                    let p25 = String(format: "%5.1f", s.percentiles[25] ?? 0)
                    let p50 = String(format: "%5.1f", s.percentiles[50] ?? 0)
                    let p75 = String(format: "%5.1f", s.percentiles[75] ?? 0)
                    let p90 = String(format: "%5.1f", s.percentiles[90] ?? 0)
                    let max = String(format: "%5.1f", s.percentiles[100] ?? 0)

                    // Highlight Self Element
                    let marker = (target == dm) ? "*" : " "

                    print(
                        "\(marker) \(target.name)  | \(avg) | \(min) | \(p10) | \(p25) | \(p50) | \(p75) | \(p90) | \(max)"
                    )
                }
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

        printDetailedStats("Global Temperature", tempStats)
        printDetailedStats("Global Moisture", moistStats)

        print("\n--- Thermal Distribution by Day Master Element ---")
        for element in FiveElements.allCases {
            if let temps = temperaturesByElement[element], let moists = moisturesByElement[element]
            {
                let tStats = calculateStats(temps)
                let mStats = calculateStats(moists)
                printDetailedStats("[\(element.name)] Temperature", tStats)
                printDetailedStats("[\(element.name)] Moisture", mStats)
            }
        }
    }
    print("--------------------------------------------------\n")
}

let args = CommandLine.arguments
let runThermal = args.contains("--thermal") || args.contains("-t")
let runPattern = args.contains("--pattern") || args.contains("-p")
let runElements = args.contains("--elements") || args.contains("-e")

// Default to ALL if no flags specified
if !runThermal && !runPattern && !runElements {
    runExperiment(runThermal: true, runPattern: true, runElements: true)
} else {
    runExperiment(runThermal: runThermal, runPattern: runPattern, runElements: runElements)
}
