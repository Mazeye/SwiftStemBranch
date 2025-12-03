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

func printPillar(_ name: String, _ sb: StemBranch) {
    let stemTenGod = pillars.tenGod(for: sb.stem).rawValue
    let branchTenGod = pillars.tenGod(for: sb.branch).rawValue
    
    // Example: 甲(阳木)[比肩]
    let stemInfo = "\(sb.stem.character)(\(sb.stem.yinYang.rawValue)\(sb.stem.fiveElement.rawValue))[\(stemTenGod)]"
    let branchInfo = "\(sb.branch.character)(\(sb.branch.yinYang.rawValue)\(sb.branch.fiveElement.rawValue))[\(branchTenGod)]"
    
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
