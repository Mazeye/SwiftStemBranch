# SwiftGanZhi

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A high-precision Chinese Gan-Zhi (Stem-Branch) calendar library for Swift.

It features **astronomical-grade accuracy** for solar terms calculation (based on Jean Meeus algorithms) and supports **True Solar Time** correction directly on the standard `Date` type.

> [English](README.md) | [简体中文](README_CN.md) | [日本語](README_JP.md)

## ✨ Features

* **Pure Swift Extension**: Directly extends `Date` for seamless integration.
* **High Precision**: Uses simplified VSOP87/Meeus algorithms to calculate Apparent Solar Longitude for precise solar term determination.
* **True Solar Time**: Automatically corrects time based on longitude and Equation of Time (EoT).
* **Scientific Day Calculation**: Uses Julian Day algorithms to eliminate timezone and leap year drifts.
* **Dynamic Energy System**: Precise strength calculation for Five Elements and Ten Gods using seasonal coefficients (1.4/1.2/1.0/0.8/0.6), rooting strength (supports heterogeneous roots at 50%), distance decay, and branch interaction (San He/San Hui) bonuses.
* **Mixed Rooting Logic**: Accurate energy support matching both strict characters and same-element different-polarity stems (e.g., Bing Fire sitting on Ding Fire gets 50% support), keeping energy levels realistic while maintaining strict pattern analysis.
* **Relationship Detection**: Automatically detects combinations, clashes, harms, punishments, and destructions (刑冲会合).

## 📦 Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/SwiftGanZhi.git", from: "1.0.0")
]
```

Or in Xcode: `File` > `Add Packages...` > Enter repository URL.

## 🚀 Quick Start

### 1. Basic Usage (Mean Solar Time)

```swift
import GanZhi

// Initialize a Date (using the provided helper or standard methods)
let date = Date(year: 2024, month: 2, day: 4, hour: 16, minute: 30)!

// Get Four Pillars directly from Date
let pillars = date.fourPillars()

print(pillars.description) 
// Output: 甲辰年 丙寅月 戊戌日 庚申时
```

### 2. Advanced Usage (True Solar Time)

Location matters. The library can adjust the time column based on longitude.

```swift
import GanZhi

// Birthplace: Urumqi (Longitude 87.6°), Time: Beijing Time 10:00
let date = Date(year: 2024, month: 6, day: 15, hour: 10, minute: 0)!
let urumqi = Location(longitude: 87.6, timeZone: 8.0)

// Get corrected pillars
let pillars = date.fourPillars(at: urumqi)

print(pillars.hour.character)
// Original 10:00 is Si Hour (Snake)
// Corrected time is approx 07:50, which is Chen Hour (Dragon)
```

### 3. Ten Gods Analysis

Calculate the Ten Gods (Shi Shen) relationships for Stems and Branches (based on Hidden Stems/Main Qi):

```swift
let pillars = date.fourPillars()

// Get Ten God for a Stem
// Note: Stem/Branch are now wrappers. Property access is transparent.
let stemTenGod = pillars.tenGod(for: pillars.year.stem)
print(stemTenGod.name) // e.g., "Rob Wealth"

// Accessing energy
let energy = pillars.month.stem.energy
print("Month Stem Energy: \(energy)")

// In some cases (e.g., matching or strict type passing), use .value for the raw enum
let rawStem: Stem = pillars.day.stem.value

### 4. Relationship Detection (刑冲会合)

Detect all interactions between pillars, including celestial and earthly interactions.

```swift
let relationships = pillars.relationships

for rel in relationships {
    // e.g., "[Year-Month] Zi-Wu Branch Clash"
    print(rel.description)
}
```

Support detection:
- **Stem**: Combination (五合), Clash (相冲).
- **Branch**: Six Harmony (六合), Triple Harmony (三合), Directional (三会), Clash (六冲), Harm (六害), Punishment (相刑), Destruction (相破).
```

### 5. Hidden Stems Analysis (Main, Middle, Residual Qi)

Access the detailed hidden stems and their corresponding Ten Gods for any branch.

```swift
let pillars = date.fourPillars()

// Get hidden stems and their Ten Gods
let hidden = pillars.hiddenTenGods(for: pillars.month.branch)

// Main Qi (Stem, TenGods)
print("Main Qi: \(hidden.benQi.stem.character) [\(hidden.benQi.tenGod.name)]")

// Middle Qi (Optional<(Stem, TenGods)>)
if let zhong = hidden.zhongQi {
    print("Middle Qi: \(zhong.stem.character) [\(zhong.tenGod.name)]")
}

// Residual Qi (Optional<(Stem, TenGods)>)
if let yu = hidden.yuQi {
    print("Residual Qi: \(yu.stem.character) [\(yu.tenGod.name)]")
}
```

### 6. GeJu (Pattern) Determination

Automatically determine the chart pattern based on traditional rules (Month Qi priority, Stem penetration, etc.). For auxiliary pattern detection in Peer-type charts (Jian Lu, Yang Ren), the auxiliary must dominate the entire "Self Group" (combined energy of Day Master, Friend, and Rob Wealth) for increased rigor.

```swift
let pattern = pillars.determinePattern()

print("Pattern: \(pattern.description)")      // e.g., "Direct Resource Pattern"
print("Basis: \(pattern.method.description)") // e.g., "Month Branch Main Qi"
print("Core Ten God: \(pattern.tenGod.name)")  // e.g., "Direct Resource"
```

### 7. Luck Cycles & Annual Luck (Da Yun & Liu Nian)

Calculate the Start Age, Major Luck Cycles (Da Yun), and derive Annual Luck (Liu Nian).

```swift
let calculator = LuckCalculator(gender: .male, pillars: pillars, birthDate: date)

// 1. Get Start Age
let startAge = calculator.calculateStartAge()
print("Start Age: \(startAge)")

// 2. Get Major Cycles (Default: 10 cycles)
let cycles = calculator.getMajorCycles()

for cycle in cycles {
    print(cycle.description) // e.g. "Bing-Yin Cycle (Start: 3.4 yrs, 1987-1996)"
    
    // 3. Derive Annual Luck (Liu Nian)
    // Iterate through years in the cycle
    for year in cycle.startYear...cycle.endYear {
        // Calculate Stem-Branch for the year
        // 1984 is Jia-Zi (Index 0)
        let offset = year - 1984
        var index = offset % 60
        if index < 0 { index += 60 }
        let yearSB = StemBranch.from(index: index)
        
        let age = year - Calendar.current.component(.year, from: date)
        print("  \(year) \(yearSB.character) (Age: \(age))")
    }
}
```

### 8. Shen Sha Analysis (Stars/Gods)

#### 8.1 Branch-based Stars

Analyze common Shen Sha based on Life Stages and Five Elements relationships within specific branches.

```swift
let branch = pillars.month.branch
let stars = pillars.shenSha(for: branch)

if !stars.isEmpty {
    // Use .name for localized output
    print("Stars: \(stars.map { $0.name }.joined(separator: " "))")
    // e.g., "Stars: Nobleman Traveling Horse"
}
```

#### 8.2 Global Situations (Chart-wide Patterns)

Analyze patterns that apply to the entire chart or specific pillar combinations (e.g., San Qi, Kui Gang).

```swift
let globalSituations = pillars.allGlobalSituations

if !globalSituations.isEmpty {
    print("Global Situations: \(globalSituations.joined(separator: " "))")
    // e.g., "Global Situations: Three Wonders Kui Gang Nobleman"
}
```

Built-in support: Three Wonders (San Qi), Kui Gang, Golden Spirit, Ten Evils Big Failure, Heavenly Unity, etc.

#### 8.3 Register Custom Situation

SwiftGanZhi allows you to define custom rules to support different schools of thought.

```swift
// Register a "Pure Yang" rule
GlobalSituationRegistry.register("Pure Yang") { pillars in
    let stems = [pillars.year.stem, pillars.month.stem, pillars.day.stem, pillars.hour.stem]
    let branches = [pillars.year.branch, pillars.month.branch, pillars.day.branch, pillars.hour.branch]
    
    return stems.allSatisfy { $0.yinYang == .yang } && 
           branches.allSatisfy { $0.yinYang == .yang }
}

// The rule will be automatically checked when calling .allGlobalSituations
```

### 9. Internationalization (i18n)

Supports Simplified Chinese (Default), Traditional Chinese, Japanese, and English.

```swift
// Switch language
GanZhiConfig.language = .english

let stem = Stem.jia
print(stem.character) // Output: "Jia"

let tenGod = TenGods.friend
print(tenGod.name)    // Output: "Friend"
```

Note: Use `.name` or `.description` properties instead of `.rawValue` to get localized strings.

### 10. Thermal Balance (Temperature & Moisture)

Analyze the "Han Nuan Zao Shi" (Cold/Warm/Dry/Wet) balance of the chart.

- **Temperature**: Calculated based on Fire element strength (and Life Stages).
- **Moisture**: Calculated based on Water (mirroring Fire logic) and Earth content.
- **States**: Automatically detects "Frozen" (Temp ≤ 0) and "Vapor" (Temp > 100) states.

```swift
let tb = pillars.thermalBalance

print(String(format: "Temperature: %.2f", tb.temperature))
print(String(format: "Moisture: %.2f", tb.moisture))

if tb.isFrozen {
    print("Status: Frozen")
} else if tb.isVapor {
    print("Status: Vapor")
}
```

### 11. Useful God Analysis (Yong Shen)

Determine the "Useful God" (Yong Shen) and "Ji God" (Negative God) using three different methods:

1. **Pattern Method (Ge Ju Fa)**: Traditional approach based on chart structure and Ten Gods patterns (e.g., Officer Pattern, Wealth Pattern).
2. **Wang Shuai Method (Strength)**: Balances the chart based on the strength of the Day Master (Weak/Strong/Follow).
3. **Tiao Hou Method (Climate)**: Adjusts temperature and moisture (Cold/Warm/Dry/Wet) using specific stems.

```swift
// 1. Default Analysis (Pattern Method)
let analysis = pillars.usefulGodAnalysis 

// 2. Specify Method Explicitly
let patternResult = pillars.calculateUsefulGod(method: .pattern)
let strengthResult = pillars.calculateUsefulGod(method: .wangShuai)
let climateResult = pillars.calculateUsefulGod(method: .tiaoHou)

print("--- Pattern Method ---")
print("Useful Gods: \(patternResult.yongShen.map { $0.name })")
print(patternResult.description)

print("--- Wang Shuai Method ---")
print("Useful Gods: \(strengthResult.yongShen.map { $0.name })")
print(strengthResult.description)

print("--- Climate Method ---")
print("status: \(climateResult.description)")
```

### 12. Dynamic Relationship Analysis (Generic)

Analyze relationships between *any* two Stem-Branch pairs, useful for comparing the Chart against Dynamic Pillars (Grand Luck / Annual Luck / "Liu Nian").

It supports detection of:
- **Duplicates**: Fu Yin (伏吟)
- **Clashes**: Fan Yin (反吟 - Heaven Clash & Earth Clash)
- **Standard**: Combinations, Clashes, Harm, Punishment, Destruction

```swift
// 1. Create a Chart
let chart = FourPillars(date: Date())

// 2. Define a Dynamic Pillar (e.g., Grand Luck "Jia-Chen")
let grandLuck = StemBranch(stem: .jia, branch: .chen)

// 3. Analyze Relationships (e.g., Year Pillar vs. Grand Luck)
let yearRels = Relationship.analyze(
    lhs: chart.year.value,
    rhs: grandLuck,
    lhsName: "Year",
    rhsName: "Grand Luck"
)

// Print results
for rel in yearRels {
    print(rel.description)
}
// Example Output: 
// [Year-Grand Luck] 辰酉地支六合Six Harmony
// [Year-Grand Luck] 伏吟Fu Yin
```

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
