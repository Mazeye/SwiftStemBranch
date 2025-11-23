# SwiftGanZhi

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A high-precision Chinese Gan-Zhi (Stem-Branch) calendar library for Swift.

It features **astronomical-grade accuracy** for solar terms calculation (based on Jean Meeus algorithms) and supports **True Solar Time** correction, making it ideal for professional BaZi (Four Pillars of Destiny) applications.

> [English](README.md) | [简体中文](README_CN.md) | [日本語](README_JP.md)

## ✨ Features

*   **Pure Swift**: Zero dependencies, supports SPM.
*   **High Precision**: Uses simplified VSOP87/Meeus algorithms to calculate Apparent Solar Longitude for precise solar term determination (accurate to the minute).
*   **True Solar Time**: Automatically corrects time based on longitude and Equation of Time (EoT).
*   **Scientific Day Calculation**: Uses Julian Day algorithms to eliminate timezone and leap year drifts.
*   **Modular Design**: Clean architecture with deep modules.

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

// Initialize with Gregorian date
let date = LunarDate(y: 2024, m: 2, d: 4, h: 16, min: 30)

// Get Four Pillars
let pillars = date.fourPillars

print(pillars.description) 
// Output: 甲辰年 丙寅月 戊戌日 庚申时
```

### 2. Advanced Usage (True Solar Time)

Location matters. The library can adjust the time column based on longitude.

```swift
import GanZhi

// Birthplace: Urumqi (Longitude 87.6°), Time: Beijing Time 10:00
let date = LunarDate(y: 2024, m: 6, d: 15, h: 10, min: 0)
let urumqi = Location(longitude: 87.6, timeZone: 8.0)

// Get corrected pillars
let pillars = date.fourPillars(at: urumqi)

print(pillars.hour.character)
// Original 10:00 is Si Hour (Snake)
// Corrected time is approx 07:50, which is Chen Hour (Dragon)
```

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

