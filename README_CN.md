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

## 📦 安装

### Swift Package Manager

在你的 `Package.swift` 文件中添加：

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/SwiftGanZhi.git", from: "1.0.0")
]
```

或者在 Xcode 中：`File` > `Add Packages...` > 输入仓库 URL。

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
// 注意：需使用 .value 从包装器中获取原始天干
let stemTenGod = pillars.tenGod(for: pillars.year.stem.value)
print(stemTenGod) // 例如: .robWealth (劫财)

// 获取地支十神（自动基于藏干本气计算）
// 例如：子水(阳) 藏干为癸水(阴)，对于甲木日主，为正印而非偏印
let branchTenGod = pillars.tenGod(for: pillars.month.branch.value) 
print(branchTenGod) // 例如: .directResource (正印)
```

### 4. 藏干分析（本气、中气、余气）

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

### 5. 八字格局判定 (GeJu)

根据传统规则（月令为重、透干优先、建禄/月刃/羊刃特殊处理等）自动判定八字格局。

```swift
let pattern = pillars.determinePattern()

print("格局: \(pattern.description)")      // 例如: "正印格"
print("判定依据: \(pattern.method.rawValue)") // 例如: "月支本气"
print("核心十神: \(pattern.tenGod.rawValue)")  // 例如: "正印"
```

### 7. 神煞分析 (Shen Sha)

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

支持的神煞包括：
*   **贵人**: 天乙、太极、文昌、天德、月德
*   **性格**: 驿马、桃花、华盖、将星、金神
*   **禄命**: 禄神（基于临官）、金舆、羊刃（基于帝旺/冠带）、飞刃
*   **凶煞**: 空亡、元辰、劫煞、亡神、孤辰、寡宿

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

## 📄 许可证

本项目基于 MIT 许可证开源。详见 [LICENSE](LICENSE) ファイル。
