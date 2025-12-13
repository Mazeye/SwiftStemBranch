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
// Note: Use .value to get the raw Stem from the wrapper
let stemTenGod = pillars.tenGod(for: pillars.year.stem.value)
print(stemTenGod) // e.g., .robWealth

// Get Ten God for a Branch (Calculated based on Hidden Stem's Main Qi)
// e.g., Zi (Yang Water) contains Gui (Yin Water). For Jia Wood Day Master, it is Direct Resource.
let branchTenGod = pillars.tenGod(for: pillars.month.branch.value)
print(branchTenGod) // e.g., .directResource
```

### 7. Shen Sha Analysis (Stars/Gods)

Analyze common Shen Sha based on Life Stages and Five Elements relationships.

```swift
let branch = pillars.month.branch
let stars = pillars.shenSha(for: branch)

if !stars.isEmpty {
    // Use .name for localized output
    print("Stars: \(stars.map { $0.name }.joined(separator: " "))")
    // e.g., "Stars: Nobleman Traveling Horse" (in English mode)
}
```

### 8. Internationalization (i18n)

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

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
