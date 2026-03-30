# SwiftGanZhi (干支)

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

一个纯 Swift 编写的高精度干支（八字）历法库。

它不依赖任何查表数据，而是基于 **Jean Meeus 天文算法** 实现精确的节气计算，并直接扩展了标准 `Date` 类型以支持真太阳时修正。

> [English](README.md) | [简体中文](README_CN.md) | [日本語](README_JP.md)

## ✨ 核心特性

* **纯 Swift 扩展**：直接扩展 `Date` 类型，零依赖，无缝集成。
* **天文级精度**：内置简化版 VSOP87/Meeus 算法计算太阳视黄经，精确判定节气交接时刻。
* **真太阳时修正**：支持根据经度与均时差（Equation of Time）自动修正排盘时间。
* **科学的日柱计算**：使用儒略日（Julian Day）算法，消除时区和闰年造成的日期偏差。
* **动态能量体系**：基于月令旺衰（旺相休囚死：1.4/1.2/1.0/0.8/0.6）、通根强度（支持异性通根且能量减半）、距离衰减及地支刑冲会合（三三会/三合有力加成）等复合规则，动态计算五行与十神的精准强度。
* **高精细通根逻辑**：支持“格局从严、能量从宽”。通根不仅支持严格的本气匹配，也支持同五行异性支持（如丙火在午月丁火本气中获得 50% 能量支持），确保能量强弱更符合命理实战。
* **干支关系检测**：自动识别全盘的天干五合/相冲、地支六合/三合/三会/六冲/相刑/相害/相破（刑冲会合）。

## 📦 安装

### Swift Package Manager

在你的 `Package.swift` 文件中添加：

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/SwiftGanZhi.git", from: "1.0.0")
]
```

或者在 Xcode 中：`File` > `Add Packages...` > 输入仓库 URL。

> 提示：仓库当前提供两个 product：`GanZhi` 与 `GanZhiWasmBridge`。
> iOS / macOS 客户端只需继续选择 `GanZhi`，不会自动引入 `GanZhiWasmBridge` 的编译与链接。

### WebAssembly（可选）

仓库还提供了一个 wasm 运行时 target：`GanZhiWasmRuntime`，用于浏览器侧调用。

```bash
./scripts/build-wasm.sh
```

如果本机 Swift 工具链与 wasm SDK 版本不匹配，可显式指定 Swift 命令：

```bash
SWIFT_CMD="swiftly run swift +6.2.0" ./scripts/build-wasm.sh
```

构建成功后会在 `web-demo/dist/` 生成：

- `ganzhi.wasm`
- `ganzhi.wasm.gz`
- `ganzhi.wasm.br`

启动本地页面示例：

```bash
python3 -m http.server 8080
```

访问：`http://localhost:8080/web-demo/`

可配合示例页面 `web-demo/index.html` 使用（详见 `web-demo/README.md`）。

## 🚀 快速开始

### 1. 基础排盘（平太阳时）

如果你只需要根据公历时间获取八字：

```swift
import GanZhi

// 初始化日期 (使用提供的辅助构造器或标准方法)
let date = Date(year: 2024, month: 2, day: 4, hour: 16, minute: 30)!

// 直接从 Date 获取八字
let pillars = date.fourPillars()

print(pillars.description) 
// 输出: 甲辰年 丙寅月 戊戌日 庚申时
```

### 2. 高级排盘（真太阳时）

八字排盘非常讲究出生地的经度。本库支持自动修正：

```swift
import GanZhi

// 假设出生在乌鲁木齐 (东经 87.6°)，时间是北京时间 10:00
let date = Date(year: 2024, month: 6, day: 15, hour: 10, minute: 0)!
let urumqi = Location(longitude: 87.6, timeZone: 8.0)

// 获取修正后的八字
let pillars = date.fourPillars(at: urumqi)

print(pillars.hour.character)
// 原本 10:00 是巳时 (09:00-11:00)
// 修正后约 07:50，变为辰时 (07:00-09:00)
```

### 3. 十神分析

支持获取天干和地支（基于藏干本气）的十神关系：

```swift
let pillars = date.fourPillars()

// 获取天干十神
// 注意：现在 stem/branch 返回的是包装器。由于使用了 @dynamicMemberLookup，
// 您依然可以像以前一样直接访问其 character, fiveElement 等属性。
let stemTenGod = pillars.tenGod(for: pillars.year.stem)
print(stemTenGod.name) // 例如: "劫财"

// 获取能量系数
let energy = pillars.month.stem.energy
print("月干能量: \(energy)")

// 如果某些场景（如严格类型匹配或 pattern matching）需要原始枚举，请使用 .value
let rawStem: Stem = pillars.day.stem.value
```

### 4. 干支关系检测 (刑冲会合)

一键获取四柱中存在的所有天干地支互动关系。

```swift
let relationships = pillars.relationships

for rel in relationships {
    // 例如: "[月柱-日柱] 酉辰地支六合"
    print(rel.description)
}
```

支持检测：
- **天干**：五合、相冲。
- **地支**：六合、三合、三会、六冲、相害、相刑（三刑/自刑/二刑）、相破。

### 5. 藏干分析（本气、中气、余气）

支持获取地支的藏干详情及其对应的十神。

```swift
let pillars = date.fourPillars()

// 获取地支藏干及其十神
let hidden = pillars.hiddenTenGods(for: pillars.month.branch)

// 本气 (Stem, TenGods)
print("本气: \(hidden.benQi.stem.character) [\(hidden.benQi.tenGod.rawValue)]")

// 中气 (Optional<(Stem, TenGods)>)
if let zhong = hidden.zhongQi {
    print("中气: \(zhong.stem.character) [\(zhong.tenGod.rawValue)]")
}

// 余气 (Optional<(Stem, TenGods)>)
if let yu = hidden.yuQi {
    print("余气: \(yu.stem.character) [\(yu.tenGod.rawValue)]")
}
```

### 6. 八字格局判定 (GeJu)

根据传统规则（月令为重、透干优先、建禄/月刃/羊刃特殊处理等）自动判定八字格局。
**注意**：在判定“副格”时，如果主格为比劫类（建禄/羊刃/月刃），副格十神必须强于“日主集团”（比肩+劫财+日主能量）的总和才会被判定，确保了身强格判定的严谨性。

```swift
let pattern = pillars.determinePattern()

print("格局: \(pattern.description)")      // 例如: "正印格"
print("判定依据: \(pattern.method.rawValue)") // 例如: "月支本气"
print("核心十神: \(pattern.tenGod.rawValue)")  // 例如: "正印"
```

### 7. 大运与流年 (Luck Cycles & Annual Luck)

支持计算起运岁数、排出大运，并可推导每一年的流年干支。

```swift
let calculator = LuckCalculator(gender: .male, pillars: pillars, birthDate: date)

// 1. 获取起运岁数
let startAge = calculator.calculateStartAge()
print("起运岁数: \(startAge)")

// 2. 获取大运排盘 (默认 10 步大运)
let cycles = calculator.getMajorCycles()

for cycle in cycles {
    print(cycle.description) // 例如: "丙寅运 (起运: 3.4岁, 1987-1996)"
    
    // 3. 推导流年 (Yearly Luck)
    // 遍历大运期间的每一年
    for year in cycle.startYear...cycle.endYear {
        // 计算流年干支
        // 1984年是甲子年(索引0)，以此推算
        let offset = year - 1984
        var index = offset % 60
        if index < 0 { index += 60 }
        let yearSB = StemBranch.from(index: index)
        
        let age = year - Calendar.current.component(.year, from: date)
        print("  \(year) \(yearSB.character) (\(age)岁)")
    }
}
```

### 8. 神煞分析 (Shen Sha)

#### 8.1 地支神煞 (Branch-based Stars)

基于十二长生状态（Life Stages）和五行关系，计算地支中包含的常用神煞。

```swift
let branch = pillars.month.branch
let stars = pillars.shenSha(for: branch)

if !stars.isEmpty {
    // 使用 .name 获取本地化名称
    print("神煞: \(stars.map { $0.name }.joined(separator: " "))")
    // 例如: "神煞: 天乙贵人 驿马"
}
```

支持的神煞包括：天乙贵人、太极贵人、文昌贵人、驿马、桃花、禄神、羊刃、空亡等。

#### 7.2 全局局面 (Global Situations)

某些局面是基于全盘结构或特定柱位（如日柱、时柱）判定的，不依附于单一地支。这也包括了传统神煞中的“全局神煞”。

```swift
let globalSituations = pillars.allGlobalSituations

if !globalSituations.isEmpty {
    print("全局局面: \(globalSituations.joined(separator: " "))")
    // 例如: "全局局面: 三奇贵人 魁罡贵人"
}
```

内置支持：三奇贵人、魁罡贵人、金神格、十恶大败、天元一气、地支一气等。

#### 7.3 注册自定义局面 (Global Situation)

SwiftGanZhi 提供了灵活的注册机制，允许用户根据不同流派定义自己的局面或神煞规则。

```swift
// 注册一个“四柱纯阳”的规则
GlobalSituationRegistry.register("四柱纯阳") { pillars in
    let stems = [pillars.year.stem, pillars.month.stem, pillars.day.stem, pillars.hour.stem]
    let branches = [pillars.year.branch, pillars.month.branch, pillars.day.branch, pillars.hour.branch]
    
    return stems.allSatisfy { $0.yinYang == .yang } && 
           branches.allSatisfy { $0.yinYang == .yang }
}

// 之后调用 .allGlobalSituations 时会自动包含该规则的检查结果
```

### 8. 多语言支持 (i18n)

本库支持简体中文（默认）、繁体中文、日语和英语输出。

```swift
// 切换语言
GanZhiConfig.language = .english // 或 .japanese, .traditionalChinese

let stem = Stem.jia
print(stem.character) // 输出: "Jia"

let tenGod = TenGods.friend
print(tenGod.name)    // 输出: "Friend"
print(tenGod.rawValue) // 输出: "比肩" (保持兼容性，rawValue 始终为简中)
```

注意：为了支持多语言，请使用 `.name` 或 `.description` 属性替代 `.rawValue` 来获取显示文本。

### 9. 寒暖燥湿 (调候分析)

分析八字的寒暖燥湿平衡。

- **寒暖**: 依据火的强度（及十二长生状态）计算。
- **湿燥**: 依据水的强度（镜像火的算法）及土的含量计算。
- **特殊状态**: 自动检测 "冻" (寒暖分值 ≤ 0) 和 "气" (寒暖分值 > 100) 状态。

```swift
let tb = pillars.thermalBalance

print(String(format: "寒暖分值: %.2f", tb.temperature))
print(String(format: "湿燥分值: %.2f", tb.moisture))

if tb.isFrozen {
    print("状态: 冻")
} else if tb.isVapor {
    print("状态: 气")
}
```

### 10. 用神与忌神分析 (Useful God)

本库支持三种不同的取用神及其忌神判定的方法：

1. **格局法 (Ge Ju Fa)**：传统的子平格局法，依月令、透干定格，并结合通关、制化等逻辑取用。
2. **旺衰法 (Wang Shuai)**：依据日主强弱（身强/身弱/专旺/从格）进行扶抑或顺势取用。
3. **调侯法 (Climate)**：根据命局的寒暖燥湿，选取特定的天干（如丙火解冻、癸水滋润）作为用神。

```swift
// 1. 默认分析 (默认使用格局法)
let analysis = pillars.usefulGodAnalysis 

// 2. 显式指定方法
let patternResult = pillars.calculateUsefulGod(method: .pattern)   // 格局法
let strengthResult = pillars.calculateUsefulGod(method: .wangShuai) // 旺衰法
let climateResult = pillars.calculateUsefulGod(method: .tiaoHou)    // 调侯法

print("--- 格局法 ---")
print("建议用神: \(patternResult.yongShen.map { $0.name })")
print(patternResult.description)

print("--- 旺衰法 ---")
print("建议用神: \(strengthResult.yongShen.map { $0.name })")
print(strengthResult.description)

print("--- 调侯法 ---")
print("状态: \(climateResult.description)")
```

### 11. 动态关系分析 (通用)

支持任意两组干支之间的关系分析，常用于八字原局与动态运势柱（大运/流年）的对比分析。

支持检测：
- **重叠**: 伏吟 (Fu Yin)
- **相冲**: 反吟 (Fan Yin - 天克地冲)
- **常规**: 刑冲会合害破

```swift
// 1. 创建八字
let chart = FourPillars(date: Date())

// 2. 定义动态柱 (例如：2024 甲辰流年)
let grandLuck = StemBranch(stem: .jia, branch: .chen)

// 3. 分析关系 (例如：年柱 vs 流年)
let yearRels = Relationship.analyze(
    lhs: chart.year.value,
    rhs: grandLuck,
    lhsName: "年柱",
    rhsName: "流年"
)

// 打印结果
for rel in yearRels {
    // 方式 1: 直接打印描述 (旧方式)
    // print(rel.description)
    // [年柱-流年] 辰酉地支六合 六合
    
    // 方式 2: 获取结构化数据 (新方式)
    let info = rel.listing
    print("柱名: \(info.pillars)")     // "年柱-流年"
    print("干支: \(info.characters)")  // "辰酉"
    print("类型: \(info.type)")        // "地支六合"
}
```

## 📄 许可证

本项目基于 MIT 许可证开源。详见 [LICENSE](LICENSE) ファイル。
