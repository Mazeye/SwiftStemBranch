import Foundation
import GanZhi

let args = CommandLine.arguments

// Helper to parse date
func parseDate(_ args: [String]) -> (Date, Gender) {
    let date = Date()
    var gender: Gender = .male // Default fallback
    
    // Parse language
    if args.contains("-en") || args.contains("--english") {
        GanZhiConfig.language = .english
    } else if args.contains("-jp") || args.contains("--japanese") {
        GanZhiConfig.language = .japanese
    } else if args.contains("-tc") || args.contains("--traditional") {
        GanZhiConfig.language = .traditionalChinese
    } else if args.contains("-sc") || args.contains("--simplified") {
        GanZhiConfig.language = .simplifiedChinese
    }
    
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

// Localized strings for Sample output labels
let labels: [String: String] = {
    switch GanZhiConfig.language {
    case .simplifiedChinese:
        return [
            "bazi": "八字", "year": "年", "month": "月", "day": "日", "hour": "时",
            "details": "详细属性:", "yearPillar": "年柱", "monthPillar": "月柱",
            "dayPillar": "日柱", "hourPillar": "时柱", "pattern": "格局:",
            "patternName": "格局名称", "method": "判定依据", "coreTenGod": "核心十神",
            "fiveElements": "五行分布:", "yinYang": "阴阳分布:", "hiddenStems": "藏干信息:",
            "mainQi": "本气", "middleQi": "中气", "residualQi": "余气", "shenSha": "神煞",
            "luckCycles": "大运排盘", "startAge": "起运岁数", "age": "岁",
            "male": "男", "female": "女", "ming": "命"
        ]
    case .traditionalChinese:
        return [
            "bazi": "八字", "year": "年", "month": "月", "day": "日", "hour": "時",
            "details": "詳細屬性:", "yearPillar": "年柱", "monthPillar": "月柱",
            "dayPillar": "日柱", "hourPillar": "時柱", "pattern": "格局:",
            "patternName": "格局名稱", "method": "判定依據", "coreTenGod": "核心十神",
            "fiveElements": "五行分布:", "yinYang": "陰陽分布:", "hiddenStems": "藏干信息:",
            "mainQi": "本氣", "middleQi": "中氣", "residualQi": "餘氣", "shenSha": "神煞",
            "luckCycles": "大運排盤", "startAge": "起運歲數", "age": "歲",
            "male": "男", "female": "女", "ming": "命"
        ]
    case .japanese:
        return [
            "bazi": "命式", "year": "年", "month": "月", "day": "日", "hour": "時",
            "details": "詳細:", "yearPillar": "年柱", "monthPillar": "月柱",
            "dayPillar": "日柱", "hourPillar": "時柱", "pattern": "格局:",
            "patternName": "格局名", "method": "判定法", "coreTenGod": "中心通変星",
            "fiveElements": "五行分布:", "yinYang": "陰陽分布:", "hiddenStems": "蔵干:",
            "mainQi": "本気", "middleQi": "中気", "residualQi": "余気", "shenSha": "神煞",
            "luckCycles": "大運:", "startAge": "立運", "age": "歳",
            "male": "男", "female": "女", "ming": "命"
        ]
    case .english:
        return [
            "bazi": "BaZi Chart", "year": "Y", "month": "M", "day": "D", "hour": "H",
            "details": "Details:", "yearPillar": "Year", "monthPillar": "Month",
            "dayPillar": "Day", "hourPillar": "Hour", "pattern": "Pattern:",
            "patternName": "Name", "method": "Method", "coreTenGod": "Core God",
            "fiveElements": "Five Elements:", "yinYang": "Yin/Yang:", "hiddenStems": "Hidden Stems:",
            "mainQi": "Main", "middleQi": "Middle", "residualQi": "Residual", "shenSha": "Stars",
            "luckCycles": "Luck Cycles", "startAge": "Start Age", "age": "yrs",
            "male": "Male", "female": "Female", "ming": ""
        ]
    }
}()

func L(_ key: String) -> String { labels[key] ?? key }

print("--------------------------------------------------")
print("\(L("bazi")): \(pillars.year.character)\(L("year")) \(pillars.month.character)\(L("month")) \(pillars.day.character)\(L("day")) \(pillars.hour.character)\(L("hour"))")
print("--------------------------------------------------")
print(L("details"))

func printPillar(_ name: String, _ pillar: FourPillars.Pillar) {    
    let stemTenGod = pillars.tenGod(for: pillar.stem).name 
    let stemLifeStage = pillar.stem.lifeStage(in: pillar.branch).description
    let branchTenGod = pillars.tenGod(for: pillar.branch).name 
    
    // Example: 甲(阳木)[比肩][临官]
    let stemInfo = "\(pillar.stem.character)(\(pillar.stem.yinYang.description)\(pillar.stem.fiveElement.description))[\(stemTenGod)][\(stemLifeStage)]"
    let branchInfo = "\(pillar.branch.character)(\(pillar.branch.yinYang.description)\(pillar.branch.fiveElement.description))[\(branchTenGod)]"
    
    print("\(name): \(stemInfo) \(branchInfo)")
}

printPillar(L("yearPillar"), pillars.year)
printPillar(L("monthPillar"), pillars.month)
printPillar(L("dayPillar"), pillars.day)
printPillar(L("hourPillar"), pillars.hour)

print("--------------------------------------------------")
print(L("pattern"))
let pattern = pillars.determinePattern()
print("\(L("patternName")): \(pattern.description)")
print("\(L("method")): \(pattern.method.description)")
print("\(L("coreTenGod")): \(pattern.tenGod.name)")
print("--------------------------------------------------")

print(L("fiveElements"))
let counts = pillars.fiveElementCounts
for element in FiveElements.allCases {
    let count = counts[element, default: 0]
    let bar = String(repeating: "█", count: count)
    print("\(element.description): \(count) \(bar)") 
}
print("--------------------------------------------------")
print(L("yinYang"))
let yinYangCounts = pillars.yinYangCounts
for yy in YinYang.allCases {
    let count = yinYangCounts[yy, default: 0]
    let bar = String(repeating: "█", count: count)
    print("\(yy.description): \(count) \(bar)")
}
print("--------------------------------------------------")

print(L("hiddenStems"))

let pillarsList = [pillars.year, pillars.month, pillars.day, pillars.hour]
let positions = [L("year"), L("month"), L("day"), L("hour")] 

for (index, pillar) in pillarsList.enumerated() {
    let branch = pillar.branch
    let hidden = pillars.hiddenTenGods(for: branch)
    
    var info = "\(L("mainQi")): \(hidden.benQi.stem.character)(\(hidden.benQi.tenGod.name))"
    
    if let zhong = hidden.zhongQi {
        info += " \(L("middleQi")): \(zhong.stem.character)(\(zhong.tenGod.name))"
    }
    
    if let yu = hidden.yuQi {
        info += " \(L("residualQi")): \(yu.stem.character)(\(yu.tenGod.name))"
    }
    
    // Shen Sha
    let stars = pillars.shenSha(for: branch)
    if !stars.isEmpty {
        let starsStr = stars.map { $0.name }.joined(separator: " ")
        info += " \(L("shenSha")): \(starsStr)"
    }
    
    let posName = positions[index]
    let branchLabel = (GanZhiConfig.language == .english) ? "\(posName) Branch" : "\(posName)支"
    
    print("\(branchLabel) [\(branch.character)]: \(info)")
}

print("--------------------------------------------------")
let genderStr = (gender == .male) ? L("male") : L("female")
print("\(L("luckCycles")) (\(genderStr)\(L("ming"))):")

let calculator = LuckCalculator(gender: gender, pillars: pillars, birthDate: date)
let cycles = calculator.getMajorCycles()
let startAge = calculator.calculateStartAge()

print("\(L("startAge")): \(String(format: "%.2f", startAge)) \(L("age"))")

for cycle in cycles {
    print(cycle.description) 
}

print("--------------------------------------------------")
