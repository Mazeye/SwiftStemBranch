# SwiftGanZhi (干支)

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Swiftで書かれた高精度な干支（四柱推命）暦ライブラリです。

従来の固定データテーブルに依存せず、**ジャン・メウス（Jean Meeus）の天文学アルゴリズム**に基づいて、正確な二十四節気の計算と真太陽時の補正を実装しています。iOS/macOS開発者に、最も科学的で正確な干支算出ツールを提供することを目的としています。

> [English](README.md) | [简体中文](README_CN.md) | [日本語](README_JP.md)

## ✨ 主な機能

*   **純粋なSwift実装**：依存関係なし、軽量、SPM完全対応。
*   **天文学的な精度**：簡略化されたVSOP87/Meeusアルゴリズムを内蔵し、太陽視黄経を計算することで、節入りの瞬間を分単位で正確に判定します。
*   **真太陽時（True Solar Time）補正**：経度と均時差（Equation of Time）に基づいて、四柱推命（特に時柱）の精度に不可欠な時間補正を自動的に行います。
*   **科学的な日柱計算**：ユリウス通日（Julian Day）アルゴリズムを使用し、タイムゾーンや閏年による日付のずれを排除します。
*   **モジュール設計**：明確な階層構造で、拡張が容易です。

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

グレゴリオ暦の日時から干支を取得する場合：

```swift
import GanZhi

// 日付の初期化 (グレゴリオ暦)
let date = LunarDate(y: 2024, m: 2, d: 4, h: 16, min: 30)

// 四柱（干支）を取得
let pillars = date.fourPillars

print(pillars.description) 
// 出力: 甲辰年 丙寅月 戊戌日 庚申時
// (立春の節入り時刻を自動判定し、2月4日当日でも正確に年柱を切り替えます)
```

### 2. 高度な使用法（真太陽時）

四柱推命では出生地の経度が重要です。本ライブラリは自動補正をサポートしています：

```swift
import GanZhi

// 出生地：ウルムチ (東経 87.6°)、時間：北京時間 10:00
let date = LunarDate(y: 2024, m: 6, d: 15, h: 10, min: 0)
let urumqi = Location(longitude: 87.6, timeZone: 8.0)

// 補正後の干支を取得
let pillars = date.fourPillars(at: urumqi)

print(pillars.hour.character)
// 本来 10:00 は巳（み）の刻 (09:00-11:00)
// 補正後は約 07:50 となり、辰（たつ）の刻 (07:00-09:00) になります
```

### 3. 基本型の操作

天干・地支の型を単独で使用して計算することも可能です：

```swift
let jiaZi = StemBranch.from(index: 0) // 甲子
print(jiaZi.next.character) // 乙丑
print(jiaZi.stem.character) // 甲
print(jiaZi.branch.character) // 子
```

## 📚 アルゴリズム解説

### 二十四節気の計算
古くなりやすく不正確な従来のデータテーブル方式とは異なり、本ライブラリは太陽視黄経（Apparent Solar Longitude）を計算して動的に節気を判定します。
*   **立春**: 太陽黄経 315°
*   **啓蟄**: 太陽黄経 345°
*   ...

### 日柱の基準点
本ライブラリは **2000年1月1日（戊午日）** を天文学的計算の基準点として採用し、ユリウス通日の連続性に基づいて推算することで、日柱の絶対的な正確性を保証しています。

## 📄 ライセンス

本プロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルをご覧ください。

