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

// --------------------------------------------------
// Demo: Register a Custom Shen Sha Rule
// --------------------------------------------------
// Example 1: Pure Yin (All Stems and Branches are Yin)
ShenShaRegistry.register("四柱纯阴") { p in
    let stems = [p.year.stem, p.month.stem, p.day.stem, p.hour.stem]
    let branches = [p.year.branch, p.month.branch, p.day.branch, p.hour.branch]
    return stems.allSatisfy { $0.yinYang == .yin } && branches.allSatisfy { $0.yinYang == .yin }
}

ShenShaRegistry.register("四柱纯阳") { p in
    let stems = [p.year.stem, p.month.stem, p.day.stem, p.hour.stem]
    let branches = [p.year.branch, p.month.branch, p.day.branch, p.hour.branch]
    return stems.allSatisfy { $0.yinYang == .yang } && branches.allSatisfy { $0.yinYang == .yang }
}

// Example 2: Simple Test Rule (Year Stem is Yi) - Just to show it works with current default date
ShenShaRegistry.register("测试规则(年干为乙)") { p in
    return p.year.stem == .yi
}

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
    let stemLifeStage = pillar.stem.value.lifeStage(in: pillar.branch.value).description
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

// Calculate Weighted Five Elements
var elementScores: [FiveElements: Double] = [
    .wood: 0, .fire: 0, .earth: 0, .metal: 0, .water: 0
]
// Calculate Weighted Ten Gods
var tenGodScores: [TenGods: Double] = [
    .friend: 0, .robWealth: 0, .eatingGod: 0, .hurtingOfficer: 0,
    .directWealth: 0, .indirectWealth: 0, .directOfficer: 0, .sevenKillings: 0,
    .directResource: 0, .indirectResource: 0
]
var dayMasterScore: Double = 0.0

let currentPillars = [pillars.year, pillars.month, pillars.day, pillars.hour]
for (index, pillar) in currentPillars.enumerated() {
    let type = FourPillars.PillarType.allCases[index]
    let stem = pillar.stem
    let branch = pillar.branch
    
    // Five Elements
    elementScores[stem.fiveElement, default: 0] += stem.energy
    elementScores[branch.fiveElement, default: 0] += branch.energy
    
    // Ten Gods
    if type == .day {
        dayMasterScore += stem.energy
    } else {
        let sTenGod = pillars.tenGod(for: stem)
        tenGodScores[sTenGod, default: 0] += stem.energy
    }
    
    let bTenGod = pillars.tenGod(for: branch)
    tenGodScores[bTenGod, default: 0] += branch.energy
}

let totalScore = elementScores.values.reduce(0, +)

for element in FiveElements.allCases {
    let score = elementScores[element, default: 0]
    let percentage = (totalScore > 0) ? (score / totalScore) * 100 : 0
    let barCount = Int(percentage / 2) // 1 char per 2%
    let bar = String(repeating: "█", count: barCount)
    let scoreStr = String(format: "%.1f", score)
    print("\(element.description): \(scoreStr) \(bar)") 
}
print("--------------------------------------------------")

// Print Ten Gods Ranking
print((GanZhiConfig.language == .english) ? "Ten Gods Strength:" : "十神力量排序:")

// Create a unified list for sorting
var ranking: [(name: String, score: Double)] = tenGodScores.map { ($0.key.description, $0.value) }
ranking.append(((GanZhiConfig.language == .english) ? "Day Master" : "日主", dayMasterScore))

let sortedRanking = ranking.sorted { $0.score > $1.score }

for item in sortedRanking {
    if item.score > 0 {
        let scoreStr = String(format: "%.1f", item.score)
        print("\(item.name): \(scoreStr)")
    }
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
    let hidden = pillars.hiddenTenGods(for: branch.value)
    
    var info = "\(L("mainQi")): \(hidden.benQi.stem.character)(\(hidden.benQi.tenGod.name))"
    
    if let zhong = hidden.zhongQi {
        info += " \(L("middleQi")): \(zhong.stem.character)(\(zhong.tenGod.name))"
    }
    
    if let yu = hidden.yuQi {
        info += " \(L("residualQi")): \(yu.stem.character)(\(yu.tenGod.name))"
    }
    
    // Shen Sha
    let stars = pillars.shenSha(for: branch.value)
    if !stars.isEmpty {
        let starsStr = stars.map { $0.name }.joined(separator: " ")
        info += " \(L("shenSha")): \(starsStr)"
    }
    
    let posName = positions[index]
    let branchLabel = (GanZhiConfig.language == .english) ? "\(posName) Branch" : "\(posName)支"
    
    print("\(branchLabel) [\(branch.character)]: \(info)")
}

print("--------------------------------------------------")
let globalStarNames = pillars.allGlobalShenShaNames
if !globalStarNames.isEmpty {
    let title = (GanZhiConfig.language == .english) ? "Global Stars" : "全局神煞"
    let starsStr = globalStarNames.joined(separator: " ")
    print("\(title): \(starsStr)")
    print("--------------------------------------------------")
}

let genderStr = (gender == .male) ? L("male") : L("female")
print("\(L("luckCycles")) (\(genderStr)\(L("ming"))):")

let calculator = LuckCalculator(gender: gender, pillars: pillars, birthDate: date)
let cycles = calculator.getMajorCycles()
let startAge = calculator.calculateStartAge()

print("\(L("startAge")): \(String(format: "%.2f", startAge)) \(L("age"))")

// Helper for Liu Nian Stem-Branch
func getStemBranch(forYear year: Int) -> StemBranch {
    // 1984 is Jia Zi (Year of the Wood Rat), Index 0
    let offset = year - 1984
    var index = offset % 60
    if index < 0 { index += 60 }
    return StemBranch.from(index: index)
}

let birthYear = Calendar.current.component(.year, from: date)

for cycle in cycles {
    print(cycle.description)
    // Print Liu Nian for this cycle
    var liuNianOutput = "  "
    for year in cycle.startYear...cycle.endYear {
        let sb = getStemBranch(forYear: year)
        let age = year - birthYear
        liuNianOutput += "\(year)\(sb.character)[\(age)\(L("age"))] "
        
        // Break line every 5 years for readability
        if (year - cycle.startYear + 1) % 5 == 0 && year != cycle.endYear {
            liuNianOutput += "\n  "
        }
    }
    print(liuNianOutput)
}

// Energy Coefficients
print("--------------------------------------------------")
let energyTitle = (GanZhiConfig.language == .english) ? "Energy Coefficients:" : "能量系数:"
print(energyTitle)

let pillarsType: [FourPillars.PillarType] = [.year, .month, .day, .hour]
if GanZhiConfig.language == .english {
    print("Pillar | Stem Energy | Branch Energy")
} else {
    print("柱名   | 天干能量    | 地支能量")
}

let currentPillarsForTable = [pillars.year, pillars.month, pillars.day, pillars.hour]
for (index, pillar) in currentPillarsForTable.enumerated() {
    let pType = FourPillars.PillarType.allCases[index]
    let sEnergy = pillar.stem.energy
    let bEnergy = pillar.branch.energy
    
    let pName: String
    switch pType {
    case .year: pName = L("yearPillar")
    case .month: pName = L("monthPillar")
    case .day: pName = L("dayPillar")
    case .hour: pName = L("hourPillar")
    }
    
    // Formatting for alignment
    let sEnergyStr = String(format: "%.1f", sEnergy).padding(toLength: 8, withPad: " ", startingAt: 0)
    let bEnergyStr = String(format: "%.1f", bEnergy)
    
    print("\(pName)   | \(sEnergyStr)    | \(bEnergyStr)")
}
print("--------------------------------------------------")
