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
    let stemTenGod = pillars.tenGod(for: pillar.stem).rawValue
    let branchTenGod = pillars.tenGod(for: pillar.branch).rawValue
    
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

print("--------------------------------------------------")
print("地支藏干 (本气/中气/余气):")

let pillarsList = [pillars.year, pillars.month, pillars.day, pillars.hour]
let positions = ["年", "月", "日", "时"]

for (index, pillar) in pillarsList.enumerated() {
    let branch = pillar.branch
    let hidden = pillars.hiddenTenGods(for: branch)
    
    var details: [String] = []
    
    // Ben Qi
    let ben = hidden.benQi
    details.append("本气: \(ben.stem.character)[\(ben.tenGod.rawValue)]")
    
    // Zhong Qi
    if let zhong = hidden.zhongQi {
        details.append("中气: \(zhong.stem.character)[\(zhong.tenGod.rawValue)]")
    }
    
    // Yu Qi
    if let yu = hidden.yuQi {
        details.append("余气: \(yu.stem.character)[\(yu.tenGod.rawValue)]")
    }
    
    print("\(positions[index])支 [\(branch.character)]: \(details.joined(separator: ", "))")
}
print("--------------------------------------------------")
