import Foundation
import GanZhi

let args = CommandLine.arguments

// Helper to parse date
func parseDate(_ args: [String]) -> Date {
    if args.count > 1 {
        let dateString = args[1...].joined(separator: " ")
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        
        // Try yyyy-MM-dd HH:mm
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Try yyyy-MM-dd
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        print("无效日期格式。请使用 'yyyy-MM-dd HH:mm' 或 'yyyy-MM-dd'。正在使用当前时间。")
    }
    return Date()
}

let date = parseDate(args)
let pillars = date.fourPillars()


print("--------------------------------------------------")
print("八字: \(pillars.year.character)年 \(pillars.month.character)月 \(pillars.day.character)日 \(pillars.hour.character)时")
print("--------------------------------------------------")
print("详细属性:")

func printPillar(_ name: String, _ pillar: FourPillars.Pillar) {
    // Access underlying value for TenGod calculation which expects raw Stem/Branch
    let stemTenGod = pillars.tenGod(for: pillar.stem.value).rawValue
    let branchTenGod = pillars.tenGod(for: pillar.branch.value).rawValue
    
    // Example: 甲(阳木)[比肩]
    let stemInfo = "\(pillar.stem.character)(\(pillar.stem.yinYang.rawValue)\(pillar.stem.fiveElement.rawValue))[\(stemTenGod)]"
    let branchInfo = "\(pillar.branch.character)(\(pillar.branch.yinYang.rawValue)\(pillar.branch.fiveElement.rawValue))[\(branchTenGod)]"
    
    print("\(name): \(stemInfo) \(branchInfo)")
}

printPillar("年柱", pillars.year)
printPillar("月柱", pillars.month)
printPillar("日柱", pillars.day)
printPillar("时柱", pillars.hour)

print("--------------------------------------------------")
print("五行分布:")
let counts = pillars.fiveElementCounts
for element in FiveElements.allCases {
    let count = counts[element, default: 0]
    let bar = String(repeating: "█", count: count)
    print("\(element.rawValue): \(count) \(bar)")
}
print("--------------------------------------------------")
print("阴阳分布:")
let yinYangCounts = pillars.yinYangCounts
for yy in YinYang.allCases {
    let count = yinYangCounts[yy, default: 0]
    let bar = String(repeating: "█", count: count)
    print("\(yy.rawValue): \(count) \(bar)")
}
print("--------------------------------------------------")

print("通根与透干关系:")

let pillarsList = [pillars.year, pillars.month, pillars.day, pillars.hour]
let positions = ["年", "月", "日", "时"]

print("\n天干通根 (天干 -> 地支):")
for (index, pillar) in pillarsList.enumerated() {
    let stem = pillar.stem
    let roots = stem.stemRoots
    let rootStr = roots.isEmpty ? "[]" : "[" + roots.map { $0.character }.joined(separator: ", ") + "]"
    print("\(positions[index])干 [\(stem.character)]: \(rootStr)")
}

print("\n地支透干 (地支 -> 天干):")
for (index, pillar) in pillarsList.enumerated() {
    let branch = pillar.branch
    let revealed = branch.branchRevealedStems
    let revealedStr = revealed.isEmpty ? "[]" : "[" + revealed.map { $0.character }.joined(separator: ", ") + "]"
    print("\(positions[index])支 [\(branch.character)]: \(revealedStr)")
}
print("--------------------------------------------------")
