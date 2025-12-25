import Foundation
import GanZhi

func runExperiment() {
    let sampleSize = 100_000
    var temperatures: [Double] = []
    var moistures: [Double] = []
    
    print("Generating \(sampleSize) random BaZi charts...")
    
    let startYear = 1900
    let endYear = 2100
    let secondsInYear = 365.25 * 24 * 3600
    let startDate = Date(year: startYear, month: 1, day: 1, hour: 0, minute: 0)!
    
    for i in 1...sampleSize {
        let randomSeconds = Double.random(in: 0...(Double(endYear - startYear) * secondsInYear))
        let randomDate = startDate.addingTimeInterval(randomSeconds)
        let pillars = randomDate.fourPillars()
        let tb = pillars.thermalBalance
        
        temperatures.append(tb.temperature)
        moistures.append(tb.moisture)
        
        if i % 10000 == 0 {
            print("Progress: \(i)/\(sampleSize)")
        }
    }
    
    temperatures.sort()
    moistures.sort()
    
    func calculateQuartiles(_ data: [Double]) -> (min: Double, p10: Double, q1: Double, median: Double, q3: Double, p90: Double, max: Double, avg: Double) {
        let count = data.count
        let min = data[0]
        let p10 = data[count / 10]
        let q1 = data[count / 4]
        let median = data[count / 2]
        let q3 = data[count * 3 / 4]
        let p90 = data[count * 9 / 10]
        let max = data[count - 1]
        let avg = data.reduce(0, +) / Double(count)
        return (min, p10, q1, median, q3, p90, max, avg)
    }
    
    let tempResults = calculateQuartiles(temperatures)
    let moistResults = calculateQuartiles(moistures)
    
    print("\n--------------------------------------------------")
    print("Results for \(sampleSize) Random BaZi (1900-2100)")
    print("--------------------------------------------------")
    print("Temperature (寒暖):")
    print("  Min:    \(String(format: "%.2f", tempResults.min))")
    print("  10% (P10): \(String(format: "%.2f", tempResults.p10))")
    print("  25% (Q1): \(String(format: "%.2f", tempResults.q1))")
    print("  50% (Med):\(String(format: "%.2f", tempResults.median))")
    print("  75% (Q3): \(String(format: "%.2f", tempResults.q3))")
    print("  90% (P90): \(String(format: "%.2f", tempResults.p90))")
    print("  Max:    \(String(format: "%.2f", tempResults.max))")
    print("  Average: \(String(format: "%.2f", tempResults.avg))")
    print("--------------------------------------------------")
    print("Moisture (湿燥):")
    print("  Min:    \(String(format: "%.2f", moistResults.min))")
    print("  10% (P10): \(String(format: "%.2f", moistResults.p10))")
    print("  25% (Q1): \(String(format: "%.2f", moistResults.q1))")
    print("  50% (Med):\(String(format: "%.2f", moistResults.median))")
    print("  75% (Q3): \(String(format: "%.2f", moistResults.q3))")
    print("  90% (P90): \(String(format: "%.2f", moistResults.p90))")
    print("  Max:    \(String(format: "%.2f", moistResults.max))")
    print("  Average: \(String(format: "%.2f", moistResults.avg))")
    print("--------------------------------------------------")
}

runExperiment()
