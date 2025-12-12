# SwiftGanZhi (干支)

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Swiftで書かれた高精度な干支（四柱推命）暦ライブラリです。

従来の固定データテーブルに依存せず、**ジャン・メウス（Jean Meeus）の天文学アルゴリズム**に基づいて、正確な二十四節気の計算を行います。標準の `Date` 型を直接拡張し、真太陽時の補正もサポートしています。

> [English](README.md) | [简体中文](README_CN.md) | [日本語](README_JP.md)

## ✨ 主な機能

* **純粋なSwift拡張**：`Date` 型を直接拡張し、依存関係がなく、統合が容易です。
* **天文学的な精度**：簡略化されたVSOP87/Meeusアルゴリズムを内蔵し、太陽視黄経を計算することで、節入りの瞬間を正確に判定します。
* **真太陽時（True Solar Time）補正**：経度と均時差（Equation of Time）に基づいて、四柱推命に不可欠な時間補正を自動的に行います。
* **科学的な日柱計算**：ユリウス通日（Julian Day）アルゴリズムを使用し、タイムゾーンや閏年による日付のずれを排除します。

## 📦 インストール

### Swift Package Manager

`Package.swift` に以下を追加してください：

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/SwiftGanZhi.git", from: "1.0.0")
]
```

またはXcodeで：`File` > `Add Packages...` > リポジトリのURLを入力。

## 🚀 クイックスタート

### 1. 基本的な使用法（平均太陽時）

```swift
import GanZhi

// 日付の初期化 (提供されたヘルパーまたは標準メソッドを使用)
let date = Date(year: 2024, month: 2, day: 4, hour: 16, minute: 30)!

// Dateから直接干支を取得
let pillars = date.fourPillars()

print(pillars.description) 
// 出力: 甲辰年 丙寅月 戊戌日 庚申時
```

### 2. 高度な使用法（真太陽時）

四柱推命では出生地の経度が重要です。本ライブラリは自動補正をサポートしています：

```swift
import GanZhi

// 出生地：ウルムチ (東経 87.6°)、時間：北京時間 10:00
let date = Date(year: 2024, month: 6, day: 15, hour: 10, minute: 0)!
let urumqi = Location(longitude: 87.6, timeZone: 8.0)

// 補正後の干支を取得
let pillars = date.fourPillars(at: urumqi)

print(pillars.hour.character)
// 本来 10:00 は巳（み）の刻 (09:00-11:00)
// 補正後は約 07:50 となり、辰（たつ）の刻 (07:00-09:00) になります
```

### 3. 通変星（十神）の分析

天干および地支（蔵干の通根に基づく）の通変星関係を取得できます：

```swift
let pillars = date.fourPillars()

// 天干の通変星を取得
// 注意: ラッパーから元の天干を取得するには .value を使用してください
let stemTenGod = pillars.tenGod(for: pillars.year.stem.value)
print(stemTenGod) // 例: .robWealth (劫財)

// 地支の通変星を取得（蔵干の本気に自動的に基づく）
// 例：子（陽水）の蔵干は癸（陰水）。甲木の日主に対しては、偏印ではなく正印となります。
let branchTenGod = pillars.tenGod(for: pillars.month.branch.value)
print(branchTenGod) // 例: .directResource (印綬)
```

### 4. 蔵干分析（本気、中気、余気）

地支に含まれる蔵干（本気、中気、余気）の詳細と、それに対応する通変星を取得できます。

```swift
let pillars = date.fourPillars()

// 地支の蔵干と通変星を取得
let hidden = pillars.hiddenTenGods(for: pillars.month.branch)

// 本気
print("本気: \(hidden.benQi.stem.character) [\(hidden.benQi.tenGod.rawValue)]")

// 中気
if let zhong = hidden.zhongQi {
    print("中気: \(zhong.stem.character) [\(zhong.tenGod.rawValue)]")
}

// 余気
if let yu = hidden.yuQi {
    print("余気: \(yu.stem.character) [\(yu.tenGod.rawValue)]")
}
```

### 5. 格局判定 (GeJu)

標準的な規則（月支優先、透干優先、建禄/羊刃などの特殊処理）に基づいて、八字の格局を自動的に判定します。

```swift
let pattern = pillars.determinePattern()

print("格局: \(pattern.description)")      // 例: "正印格"
print("判定根拠: \(pattern.method.rawValue)") // 例: "月支本気"
print("中心通変星: \(pattern.tenGod.rawValue)")  // 例: "正印"
```

### 6. 十二運 (Twelve Life Stages)

天干の地支に対する強さ（十二運）を計算します。

```swift
let dayStem = pillars.day.stem
let monthBranch = pillars.month.branch

// 特定の地支における十二運を取得
let stage = dayStem.lifeStage(in: monthBranch)
print("十二運: \(stage.description)") // 例: "臨官"

// その天干の十二運表全体を取得
let allStages = dayStem.lifeStages
print(allStages[.zi]) // 例: "沐浴"
```

## 📄 ライセンス

本プロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルをご覧ください。
