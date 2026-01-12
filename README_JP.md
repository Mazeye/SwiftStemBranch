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
* **動的なエネルギー体系**：月令の旺衰（旺相休囚死係数：1.4/1.2/1.0/0.8/0.6）、通根の強度（異性通根による50%支持）、距離減衰、および地支の刑冲会合（三合・三会の強力な加算）などの複合規則に基づき、五行と通変星の正確な強度を計算します。
* **高精度な通根ロジック**：「格局は厳格に、エネルギーは寛容に」という原則をサポート。通根は厳密な文字一致だけでなく、同じ五行の異性支持（例：午月の丙火が、本気の丁火から50%のエネルギー支持を得る）も考慮し、より現実に即したエネルギー計算を可能にします。
* **干支の関係検出（刑冲会合）**：天干の五合・相剋、地支の六合・三合・三会・六沖・相害・相刑・相破を自動的に識別します。

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
// 注意：現在 stem/branch はラッパーを返します。@dynamicMemberLookup により、
// 以前と同様に直接 character, fiveElement などのプロパティにアクセス可能です。
let stemTenGod = pillars.tenGod(for: pillars.year.stem)
print(stemTenGod.name) // 例: "劫財"

// エネルギー係数の取得
let energy = pillars.month.stem.energy
print("月干のエネルギー: \(energy)")

// 厳密な型一致やパターンマッチングが必要な場合は、.value で元の列挙型を取得できます
let rawStem: Stem = pillars.day.stem.value

### 4. 干支の関係検出 (刑冲会合)

四柱間のあらゆる干支の相互作用を一括で取得できます。

```swift
let relationships = pillars.relationships

for rel in relationships {
    // 例: "[月柱-日柱] 酉辰地支六合"
    print(rel.description)
}
```

サポートされている検出：
- **天干**：五合、相剋（相冲）。
- **地支**：六合、三合、三会（方合）、六沖、相害、相刑（三刑/自刑/二刑）、相破。
```

### 5. 蔵干分析（本気、中気、余気）

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

### 6. 格局判定 (GeJu)

標準的な規則（月支優先、透干優先、建禄/羊刃などの特殊処理）に基づいて、八字の格局を自動的に判定します。
**注意**：建禄・羊刃・月刃などの比劫系格局において「副格」を判定する際、副格となる通変星は「日主グループ」（比肩・劫財・日主の合計エネルギー）より強力である必要があり、身強格の判定における厳格さを確保しています。

```swift
let pattern = pillars.determinePattern()

print("格局: \(pattern.description)")      // 例: "正印格"
print("判定根拠: \(pattern.method.rawValue)") // 例: "月支本気"
print("中心通変星: \(pattern.tenGod.rawValue)")  // 例: "正印"
```

### 7. 大運と流年 (Luck Cycles & Annual Luck)

立運（大運の開始年齢）や大運（10年ごとの運気）を計算し、各年の流年（年運）を導き出すことができます。

```swift
let calculator = LuckCalculator(gender: .male, pillars: pillars, birthDate: date)

// 1. 立運（開始年齢）を取得
let startAge = calculator.calculateStartAge()
print("立運: \(startAge)歳")

// 2. 大運を取得 (デフォルト: 10サイクル)
let cycles = calculator.getMajorCycles()

for cycle in cycles {
    print(cycle.description) // 例: "丙寅運 (立運: 3.4歳, 1987-1996)"
    
    // 3. 流年 (年運) を導出
    // 大運期間中の各年を反復処理
    for year in cycle.startYear...cycle.endYear {
        // 年の干支を計算
        // 1984年は甲子年(インデックス0)
        let offset = year - 1984
        var index = offset % 60
        if index < 0 { index += 60 }
        let yearSB = StemBranch.from(index: index)
        
        let age = year - Calendar.current.component(.year, from: date)
        print("  \(year) \(yearSB.character) (\(age)歳)")
    }
}
```

### 8. 神煞分析 (Shen Sha)

#### 8.1 地支神煞 (Branch-based Stars)

十二運と五行关系に基づいて、地支に含まれる一般的な神煞（吉凶星）を分析します。

```swift
let branch = pillars.month.branch
let stars = pillars.shenSha(for: branch)

if !stars.isEmpty {
    // .name を使用してローカライズされた名前を取得
    print("神煞: \(stars.map { $0.name }.joined(separator: " "))")
    // 例: "神煞: 天乙貴人 駅馬"
}
```

#### 8.2 全局局面 (Global Situations)

命式全体の構造や特定の柱に基づく局面（三奇貴人、魁罡など）を分析します。これには伝統的な「全局神煞」も含まれます。

```swift
let globalSituations = pillars.allGlobalSituations

if !globalSituations.isEmpty {
    print("全局局面: \(globalSituations.joined(separator: " "))")
    // 例: "全局局面: 三奇貴人 魁罡"
}
```

内蔵サポート：三奇貴人、魁罡、金神、十惡大敗、天元一氣など。

#### 8.3 カスタム局面の登録

SwiftGanZhi は柔軟な登録メカニズムを提供しており、流派に応じて独自の局面や神煞ルールを定義できます。

```swift
// 「四柱純陽」ルールを登録
GlobalSituationRegistry.register("四柱純陽") { pillars in
    let stems = [pillars.year.stem, pillars.month.stem, pillars.day.stem, pillars.hour.stem]
    let branches = [pillars.year.branch, pillars.month.branch, pillars.day.branch, pillars.hour.branch]
    
    return stems.allSatisfy { $0.yinYang == .yang } && 
           branches.allSatisfy { $0.yinYang == .yang }
}

// .allGlobalSituations を呼び出す際に自動的にチェックされます
```

### 9. 多国語対応 (i18n)

簡体字中国語（デフォルト）、繁体字中国語、日本語、英語をサポートしています。

```swift
// 言語を切り替える
GanZhiConfig.language = .japanese

let stem = Stem.jia
print(stem.character) // 出力: "甲"

let tenGod = TenGods.friend
print(tenGod.name)    // 出力: "比肩"
```

注意：ローカライズされた文字列を取得するには、`.rawValue` の代わりに `.name` または `.description` プロパティを使用してください。

### 10. 寒暖燥湿 (調候分析)

命式の寒暖燥湿バランスを分析します。

- **寒暖**: 火の強さ（および十二運）に基づいて計算されます。
- **湿燥**: 水の強さ（火の論理を反映）および土の含有量に基づいて計算されます。
- **特殊状態**: "凍" (寒暖スコア ≤ 0) および "気" (寒暖スコア > 100) の状態を自動検出します。

```swift
let tb = pillars.thermalBalance

print(String(format: "寒暖スコア: %.2f", tb.temperature))
print(String(format: "湿燥スコア: %.2f", tb.moisture))

if tb.isFrozen {
    print("状態: 凍")
} else if tb.isVapor {
    print("状態: 気")
}
```

### 11. 用神・忌神分析

3つの異なる方法で「用神（喜神）」と「忌神（凶神）」を判定できます：

1. **格局法 (Ge Ju Fa)**：月令や透干に基づく伝統的な格局（正官格、偏財格など）を用い、通関や制化の論理を組み合わせて判定します。
2. **旺衰法 (Wang Shuai)**：日主の強弱（身強/身弱/専旺/従格）に基づき、扶抑（バランスを取る）または順勢（勢いに従う）によって判定します。
3. **調候法 (Tiao Hou)**：命式の寒暖燥湿（温度や湿度）に基づき、気候を調整する特定の干（丙火で解凍、癸水で滋潤など）を用神とします。

```swift
// 1. デフォルト分析 (格局法を使用)
let analysis = pillars.usefulGodAnalysis 

// 2. 方法を明示的に指定
let patternResult = pillars.calculateUsefulGod(method: .pattern)   // 格局法
let strengthResult = pillars.calculateUsefulGod(method: .wangShuai) // 旺衰法
let climateResult = pillars.calculateUsefulGod(method: .tiaoHou)    // 調候法

print("--- 格局法 ---")
print("用神: \(patternResult.yongShen.map { $0.name })")
print(patternResult.description)

print("--- 旺衰法 ---")
print("用神: \(strengthResult.yongShen.map { $0.name })")
print(strengthResult.description)

print("--- 調候法 ---")
print("状態: \(climateResult.description)")
```

## 📄 ライセンス

本プロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルをご覧ください。
