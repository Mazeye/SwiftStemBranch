# SwiftGanZhi (干支)

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

一个纯 Swift 编写的高精度干支（八字）历法库。

它不依赖任何查表数据，而是基于 **Jean Meeus 天文算法** 实现精确的节气计算和真太阳时修正，旨在为 iOS/macOS 开发者提供最科学、最准确的八字排盘工具。

> [English](README.md) | [简体中文](README_CN.md) | [日本語](README_JP.md)

## ✨ 核心特性

*   **纯 Swift 实现**：零依赖，轻量级，支持 SPM。
*   **天文级精度**：内置简化版 VSOP87/Meeus 算法计算太阳视黄经，精确判定节气交接时刻（精确到分）。
*   **真太阳时修正**：支持根据经度与均时差（Equation of Time）自动修正排盘时间，这对于精确排盘（特别是时柱）至关重要。
*   **科学的日柱计算**：使用儒略日（Julian Day）算法，消除时区和闰年造成的日期偏差。
*   **模块化设计**：分层清晰，易于扩展。

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

// 初始化日期 (公历)
let date = LunarDate(y: 2024, m: 2, d: 4, h: 16, min: 30)

// 获取八字
let pillars = date.fourPillars

print(pillars.description) 
// 输出: 甲辰年 丙寅月 戊戌日 庚申时
// (自动处理立春节点，即使在2月4日当天也能根据具体时间判定年柱)
```

### 2. 高级排盘（真太阳时）

八字排盘非常讲究出生地的经度。本库支持自动修正：

```swift
import GanZhi

// 假设出生在乌鲁木齐 (东经 87.6°)，时间是北京时间 10:00
let date = LunarDate(y: 2024, m: 6, d: 15, h: 10, min: 0)
let urumqi = Location(longitude: 87.6, timeZone: 8.0)

// 获取修正后的八字
let pillars = date.fourPillars(at: urumqi)

print(pillars.hour.character)
// 原本 10:00 是巳时 (09:00-11:00)
// 修正后约 07:50，变为辰时 (07:00-09:00)
```

### 3. 基础类型操作

你也可以单独使用天干地支类型进行计算：

```swift
let jiaZi = StemBranch.from(index: 0) // 甲子
print(jiaZi.next.character) // 乙丑
print(jiaZi.stem.character) // 甲
print(jiaZi.branch.character) // 子
```

## 📚 算法说明

### 节气计算
不同于传统的查表法（容易过时且不准），本库通过计算太阳视黄经（Apparent Solar Longitude）来动态判定节气。
*   **立春**: 太阳黄经 315°
*   **惊蛰**: 太阳黄经 345°
*   ...

### 日柱基准
本库采用 **2000年1月1日 (戊午日)** 作为天文计算基准点，通过儒略日连续性推导，确保了日柱的绝对准确性。

## 📄 许可证

本项目基于 MIT 许可证开源。详见 [LICENSE](LICENSE) 文件。

