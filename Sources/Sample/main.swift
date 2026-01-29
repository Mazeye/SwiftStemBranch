import Foundation
import GanZhi

let args = CommandLine.arguments

// Helper to parse date
func parseDate(_ args: [String]) -> (Date, Gender) {
    let date = Date()
    var gender: Gender = .male  // Default fallback

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

if args.contains("--test-yong-shen") {
    runUsefulGodTest()
    exit(0)
}

let (date, gender) = parseDate(args)
let pillars = date.fourPillars()

// --------------------------------------------------
// Demo: Register a Custom Global Situation Rule
// --------------------------------------------------
// Example 1: Pure Yin (All Stems and Branches are Yin)
GlobalSituationRegistry.register("四柱纯阴") { p in
    let stems = [p.year.stem, p.month.stem, p.day.stem, p.hour.stem]
    let branches = [p.year.branch, p.month.branch, p.day.branch, p.hour.branch]
    return stems.allSatisfy { $0.yinYang == .yin } && branches.allSatisfy { $0.yinYang == .yin }
}

GlobalSituationRegistry.register("四柱纯阳") { p in
    let stems = [p.year.stem, p.month.stem, p.day.stem, p.hour.stem]
    let branches = [p.year.branch, p.month.branch, p.day.branch, p.hour.branch]
    return stems.allSatisfy { $0.yinYang == .yang } && branches.allSatisfy { $0.yinYang == .yang }
}

// Example 2: Simple Test Rule (Year Stem is Yi) - Just to show it works with current default date
GlobalSituationRegistry.register("测试规则(年干为乙)") { p in
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
            "male": "男", "female": "女", "ming": "命",
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
            "male": "男", "female": "女", "ming": "命",
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
            "male": "男", "female": "女", "ming": "命",
        ]
    case .english:
        return [
            "bazi": "BaZi Chart", "year": "Y", "month": "M", "day": "D", "hour": "H",
            "details": "Details:", "yearPillar": "Year", "monthPillar": "Month",
            "dayPillar": "Day", "hourPillar": "Hour", "pattern": "Pattern:",
            "patternName": "Name", "method": "Method", "coreTenGod": "Core God",
            "fiveElements": "Five Elements:", "yinYang": "Yin/Yang:",
            "hiddenStems": "Hidden Stems:",
            "mainQi": "Main", "middleQi": "Middle", "residualQi": "Residual", "shenSha": "Stars",
            "luckCycles": "Luck Cycles", "startAge": "Start Age", "age": "yrs",
            "male": "Male", "female": "Female", "ming": "",
        ]
    }
}()

func L(_ key: String) -> String { labels[key] ?? key }

print("--------------------------------------------------")
print(
    "\(L("bazi")): \(pillars.year.character)\(L("year")) \(pillars.month.character)\(L("month")) \(pillars.day.character)\(L("day")) \(pillars.hour.character)\(L("hour"))"
)
print("--------------------------------------------------")
print(L("details"))

func printPillar(_ name: String, _ pillar: FourPillars.Pillar) {
    let stemTenGod = pillars.tenGod(for: pillar.stem).name
    let stemLifeStage = pillar.stem.value.lifeStage(in: pillar.branch.value).description
    let branchTenGod = pillars.tenGod(for: pillar.branch).name

    // Example: 甲(阳木)[比肩][临官]
    let stemInfo =
        "\(pillar.stem.character)(\(pillar.stem.yinYang.description)\(pillar.stem.fiveElement.description))[\(stemTenGod)][\(stemLifeStage)]"
    let branchInfo =
        "\(pillar.branch.character)(\(pillar.branch.yinYang.description)\(pillar.branch.fiveElement.description))[\(branchTenGod)]"

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
print("\(L("method")): \(pattern.methodDescription)")
print("\(L("coreTenGod")): \(pattern.tenGod.name)")
print("--------------------------------------------------")

let chartRels = pillars.relationships
if !chartRels.isEmpty {
    let relTitle = (GanZhiConfig.language == .english) ? "Relationships:" : "干支关系:"
    print(relTitle)
    for rel in chartRels {
        // Example of using the structured listing:
        let l = rel.listing
        // print("  \(rel.description)") // Old way
        print("  \(l.pillars) | \(l.characters) | \(l.type)")
    }
    print("--------------------------------------------------")
}

print("--------------------------------------------------")
let tb = pillars.thermalBalance
let tbTitle = (GanZhiConfig.language == .english) ? "Thermal Balance:" : "调候解析:"
print(tbTitle)

let tempLabel = (GanZhiConfig.language == .english) ? "  Temperature Score:" : "  寒暖分值:"
let moistLabel = (GanZhiConfig.language == .english) ? "  Moisture Score:   " : "  湿燥分值:"

print("\(tempLabel) \(String(format: "%.2f", tb.temperature))")

var moistOutput = "\(moistLabel) \(String(format: "%.2f", tb.moisture))"
if tb.isFrozen {
    moistOutput += (GanZhiConfig.language == .english) ? " [Frozen]" : " [冻]"
} else if tb.isVapor {
    moistOutput += (GanZhiConfig.language == .english) ? " [Vapor]" : " [气]"
}
print(moistOutput)

print("--------------------------------------------------")
print(L("fiveElements"))

// Use library's Five Element strength calculation
let elementScores = pillars.elementStrengths

// Use library's Ten God strength calculation
let tenGodScores = pillars.tenGodStrengths
let dayMasterScore = pillars.day.stem.energy

// Lunar Phase info
if let phase = pillars.lunarPhase {
    let moonLabel = (GanZhiConfig.language == .english) ? "Moon Phase" : "月相信息"
    let ageLabel = (GanZhiConfig.language == .english) ? "Age" : "月龄"
    let illumLabel = (GanZhiConfig.language == .english) ? "Illum" : "照亮"
    print("\n\(moonLabel): \(phase.phaseName) (\(ageLabel) \(String(format: "%.1f", phase.age)), \(illumLabel) \(String(format: "%.0f", phase.illumination * 100))%)")
}

let totalScore = elementScores.values.reduce(0, +)

for element in FiveElements.allCases {
    let score = elementScores[element, default: 0]
    let percentage = (totalScore > 0) ? (score / totalScore) * 100 : 0
    let barCount = Int(percentage / 2)  // 1 char per 2%
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

// Useful God Analysis
// Useful God Analysis
let methods: [UsefulGodMethod] = [.pattern, .wangShuai, .tiaoHou]
let usefulGodTitle =
    (GanZhiConfig.language == .english) ? "Useful God Analysis (Comparison):" : "用神分析 (对比):"
print(usefulGodTitle)

let yongShenLabel = (GanZhiConfig.language == .english) ? "Yong Shen (Useful):" : "建议用神:"
let jiShenLabel = (GanZhiConfig.language == .english) ? "Ji Shen (Avoid):" : "建议忌神:"
let favLabel = (GanZhiConfig.language == .english) ? "Fav Elements:" : "喜用五行:"
let unfavLabel = (GanZhiConfig.language == .english) ? "Unfav Elements:" : "忌讳五行:"

for method in methods {
    let result = pillars.calculateUsefulGod(method: method)
    var methodTitle = ""
    switch method {
    case .pattern: methodTitle = (GanZhiConfig.language == .english) ? "[Pattern Method]" : "[格局法]"
    case .wangShuai:
        methodTitle = (GanZhiConfig.language == .english) ? "[Wang Shuai Method]" : "[旺衰法]"
    case .tiaoHou: methodTitle = (GanZhiConfig.language == .english) ? "[Tiao Hou Method]" : "[调侯法]"
    }

    print("\n--- \(methodTitle) ---")
    print(result.description)

    // Only print detailed lists if not empty or specific method needs it
    if !result.yongShen.isEmpty || !result.jiShen.isEmpty || !result.favorableElements.isEmpty {
        print("\(yongShenLabel) \(result.yongShen.map { $0.name }.joined(separator: ", "))")
        print("\(jiShenLabel) \(result.jiShen.map { $0.name }.joined(separator: ", "))")
        print(
            "\(favLabel) \(result.favorableElements.map { $0.description }.joined(separator: ", "))"
        )
        print(
            "\(unfavLabel) \(result.unfavorableElements.map { $0.description }.joined(separator: ", "))"
        )
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
let globalSituationNames = pillars.allGlobalSituations
if !globalSituationNames.isEmpty {
    let title = (GanZhiConfig.language == .english) ? "Global Situations" : "全局局面"
    let situationsStr = globalSituationNames.joined(separator: " ")
    print("\(title): \(situationsStr)")
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

let birthYear = Calendar(identifier: .gregorian).component(.year, from: date)

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
    let sEnergyStr = String(format: "%.1f", sEnergy).padding(
        toLength: 8, withPad: " ", startingAt: 0)
    let bEnergyStr = String(format: "%.1f", bEnergy)

    print("\(pName)   | \(sEnergyStr)    | \(bEnergyStr)")
}
print("--------------------------------------------------")
