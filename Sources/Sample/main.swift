import Foundation
import GanZhi

let args = CommandLine.arguments

// Helper to parse date
func parseDate(_ args: [String]) -> (Date, Gender) {
    let date = Date()
    var gender: Gender = .male // Default fallback
    
    // Parse gender explicitly
    if args.contains("-f") || args.contains("--female") {
        gender = .female
    } else if args.contains("-m") || args.contains("--male") {
        gender = .male
    }
    
    // Filter out flags to get date string parts
    let dateArgs = args.dropFirst().filter { !$0.starts(with: "-") }
    
    if !dateArgs.isEmpty {
        let dateString = dateArgs.joined(separator: " ")
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        
        // Try yyyy-MM-dd HH:mm
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let d = formatter.date(from: dateString) {
            return (d, gender)
        }
        
        // Try yyyy-MM-dd
        formatter.dateFormat = "yyyy-MM-dd"
        if let d = formatter.date(from: dateString) {
            return (d, gender)
        }
        
        print("无效日期格式。请使用 'yyyy-MM-dd HH:mm' 或 'yyyy-MM-dd'。正在使用当前时间。")
    }
    return (date, gender)
}

let (date, gender) = parseDate(args)
let pillars = date.fourPillars()


print("--------------------------------------------------")
print("八字: \(pillars.year.character)年 \(pillars.month.character)月 \(pillars.day.character)日 \(pillars.hour.character)时")
print("--------------------------------------------------")
print("详细属性:")

func printPillar(_ name: String, _ pillar: FourPillars.Pillar) {    
    let stemTenGod = pillars.tenGod(for: pillar.stem).rawValue
    let stemLifeStage = pillar.stem.lifeStage(in: pillar.branch).description
    let branchTenGod = pillars.tenGod(for: pillar.branch).rawValue
    
    // Example: 甲(阳木)[比肩][临官]
    let stemInfo = "\(pillar.stem.character)(\(pillar.stem.yinYang.rawValue)\(pillar.stem.fiveElement.rawValue))[\(stemTenGod)][\(stemLifeStage)]"
    let branchInfo = "\(pillar.branch.character)(\(pillar.branch.yinYang.rawValue)\(pillar.branch.fiveElement.rawValue))[\(branchTenGod)]"
    
    print("\(name): \(stemInfo) \(branchInfo)")
}

printPillar("年柱", pillars.year)
printPillar("月柱", pillars.month)
printPillar("日柱", pillars.day)
printPillar("时柱", pillars.hour)

print("--------------------------------------------------")
print("格局:")
let pattern = pillars.determinePattern()
print("格局名称: \(pattern.description)")
print("判定依据: \(pattern.method.rawValue)")
print("核心十神: \(pattern.tenGod.rawValue)")
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

print("藏干信息:")

let pillarsList = [pillars.year, pillars.month, pillars.day, pillars.hour]
let positions = ["年", "月", "日", "时"]

for (index, pillar) in pillarsList.enumerated() {
    let branch = pillar.branch
    let hidden = pillars.hiddenTenGods(for: branch)
    
    var info = "本气: \(hidden.benQi.stem.character)(\(hidden.benQi.tenGod.rawValue))"
    
    if let zhong = hidden.zhongQi {
        info += " 中气: \(zhong.stem.character)(\(zhong.tenGod.rawValue))"
    }
    
    if let yu = hidden.yuQi {
        info += " 余气: \(yu.stem.character)(\(yu.tenGod.rawValue))"
    }
    
    print("\(positions[index])支 [\(branch.character)]: \(info)")
}

print("--------------------------------------------------")
print("大运排盘 (\(gender.rawValue)命):")

let calculator = LuckCalculator(gender: gender, pillars: pillars, birthDate: date)
let cycles = calculator.getMajorCycles()
let startAge = calculator.calculateStartAge()

print("起运岁数: \(String(format: "%.2f", startAge)) 岁")

for cycle in cycles {
    print(cycle.description)
}

print("--------------------------------------------------")
