import Foundation

/// Represents common Shen Sha (Stars/Gods) in BaZi.
public enum ShenSha: String, CaseIterable, CustomStringConvertible {
    // MARK: - Gui Ren (Noblemen/Benefactors)
    case tianYi = "天乙贵人"
    case taiJi = "太极贵人"
    case wenChang = "文昌贵人"
    case tianDe = "天德贵人"
    case yueDe = "月德贵人"
    case tianDeHe = "天德合"
    case yueDeHe = "月德合"
    
    // MARK: - Character/Fate Stars
    case yiMa = "驿马"
    case taoHua = "桃花"
    case huaGai = "华盖"
    case jiangXing = "将星"
    case jinShen = "金神"
    
    // MARK: - Wealth/Power
    case luShen = "禄神"
    case jinYu = "金舆"
    
    // MARK: - Inauspicious/Mixed
    case yangRen = "羊刃"
    case feiRen = "飞刃"
    case kongWang = "空亡"
    case yuanChen = "元辰"
    case jieSha = "劫煞"
    case wangShen = "亡神"
    case guChen = "孤辰"
    case guaSu = "寡宿"
    
    /// Localized name based on GanZhiConfig.language.
    /// Default (Simplified Chinese) returns rawValue.
    public var name: String {
        switch GanZhiConfig.language {
        case .simplifiedChinese:
            return self.rawValue
        case .traditionalChinese:
            switch self {
            case .tianYi: return "天乙貴人"
            case .taiJi: return "太極貴人"
            case .wenChang: return "文昌貴人"
            case .tianDe: return "天德貴人"
            case .yueDe: return "月德貴人"
            case .tianDeHe: return "天德合"
            case .yueDeHe: return "月德合"
            case .yiMa: return "驛馬"
            case .taoHua: return "桃花"
            case .huaGai: return "華蓋"
            case .jiangXing: return "將星"
            case .jinShen: return "金神"
            case .luShen: return "祿神"
            case .jinYu: return "金輿"
            case .yangRen: return "羊刃"
            case .feiRen: return "飛刃"
            case .kongWang: return "空亡"
            case .yuanChen: return "元辰"
            case .jieSha: return "劫煞"
            case .wangShen: return "亡神"
            case .guChen: return "孤辰"
            case .guaSu: return "寡宿"
            }
        case .japanese:
            switch self {
            case .tianYi: return "天乙貴人"
            case .taiJi: return "太極貴人"
            case .wenChang: return "文昌貴人"
            case .tianDe: return "天徳貴人"
            case .yueDe: return "月徳貴人"
            case .tianDeHe: return "天徳合"
            case .yueDeHe: return "月徳合"
            case .yiMa: return "駅馬"
            case .taoHua: return "咸池"
            case .huaGai: return "華蓋"
            case .jiangXing: return "将星"
            case .jinShen: return "金神"
            case .luShen: return "建禄"
            case .jinYu: return "金輿"
            case .yangRen: return "羊刃"
            case .feiRen: return "飛刃"
            case .kongWang: return "空亡"
            case .yuanChen: return "元辰"
            case .jieSha: return "劫殺"
            case .wangShen: return "亡神"
            case .guChen: return "孤辰"
            case .guaSu: return "寡宿"
            }
        case .english:
            switch self {
            case .tianYi: return "Nobleman"
            case .taiJi: return "Tai Ji Nobleman"
            case .wenChang: return "Academic Star"
            case .tianDe: return "Heavenly Virtue"
            case .yueDe: return "Monthly Virtue"
            case .tianDeHe: return "Heavenly Virtue Combo"
            case .yueDeHe: return "Monthly Virtue Combo"
            case .yiMa: return "Traveling Horse"
            case .taoHua: return "Peach Blossom"
            case .huaGai: return "Elegant Seal"
            case .jiangXing: return "General Star"
            case .jinShen: return "Golden Spirit"
            case .luShen: return "Thriving Star"
            case .jinYu: return "Golden Carriage"
            case .yangRen: return "Goat Blade"
            case .feiRen: return "Flying Blade"
            case .kongWang: return "Void / Emptiness"
            case .yuanChen: return "Disaster Star"
            case .jieSha: return "Robbery Star"
            case .wangShen: return "Death God"
            case .guChen: return "Solitary Star"
            case .guaSu: return "Widow Star"
            }
        }
    }
    
    public var description: String {
        return name
    }
}

/// Represents Global Situations (Chart-wide Patterns/Features).
/// Previously "Global Shen Sha".
public enum GlobalSituation: String, CaseIterable, CustomStringConvertible {
    case sanQi = "三奇贵人"      // San Qi (Three Wonders)
    case kuiGang = "魁罡贵人"    // Kui Gang (Authoritarian)
    case jinShen = "金神格"      // Jin Shen (Golden Spirit Pattern)
    case shiEDaBai = "十恶大败"  // Shi E Da Bai (Ten Evils Big Failure)
    case tianYuanYiQi = "天元一气" // Tian Yuan Yi Qi (Heavenly Unity)
    case diZhiYiQi = "地支一气"    // Di Zhi Yi Qi (Earthly Unity)
    case tianGanLianRu = "天干连茹" // Tian Gan Lian Ru (Sequential Stems)
    case diZhiLianRu = "地支连茹"   // Di Zhi Lian Ru (Sequential Branches)
    
    public var name: String {
        switch GanZhiConfig.language {
        case .simplifiedChinese: return self.rawValue
        case .traditionalChinese:
            switch self {
            case .sanQi: return "三奇貴人"
            case .kuiGang: return "魁罡貴人"
            case .jinShen: return "金神格"
            case .shiEDaBai: return "十惡大敗"
            case .tianYuanYiQi: return "天元一氣"
            case .diZhiYiQi: return "地支一氣"
            case .tianGanLianRu: return "天干連茹"
            case .diZhiLianRu: return "地支連茹"
            }
        case .japanese:
            switch self {
            case .sanQi: return "三奇貴人"
            case .kuiGang: return "魁罡"
            case .jinShen: return "金神"
            case .shiEDaBai: return "十悪大敗"
            case .tianYuanYiQi: return "天元一気"
            case .diZhiYiQi: return "地支一気"
            case .tianGanLianRu: return "天干連茹"
            case .diZhiLianRu: return "地支連茹"
            }
        case .english:
            switch self {
            case .sanQi: return "Three Wonders"
            case .kuiGang: return "Kui Gang Nobleman"
            case .jinShen: return "Golden Spirit Pattern"
            case .shiEDaBai: return "Ten Evils Big Failure"
            case .tianYuanYiQi: return "Heavenly Unity"
            case .diZhiYiQi: return "Earthly Unity"
            case .tianGanLianRu: return "Sequential Stems"
            case .diZhiLianRu: return "Sequential Branches"
            }
        }
    }
    
    public var description: String { return name }
}

public extension FourPillars {
    
    /// Calculates Built-in Global Situations.
    var builtInGlobalSituations: [GlobalSituation] {
        var situations: [GlobalSituation] = []
        
        let yS = year.stem.value
        let mS = month.stem.value
        let dS = day.stem.value
        let hS = hour.stem.value
        
        let yB = year.branch.value
        let mB = month.branch.value
        let dB = day.branch.value
        let hB = hour.branch.value
        
        // 1. San Qi (Three Wonders)
        // Order: Year-Month-Day or Month-Day-Hour ? Usually requires adjacency.
        // Sky: Jia Wu Geng
        // Earth: Yi Bing Ding
        // Man: Ren Gui Xin
        if checkSanQi(s1: yS, s2: mS, s3: dS) || checkSanQi(s1: mS, s2: dS, s3: hS) {
            situations.append(.sanQi)
        }
        
        // 2. Kui Gang (Day Pillar)
        // Ren Chen, Geng Xu, Geng Chen, Wu Xu
        if (dS == .ren && dB == .chen) ||
           (dS == .geng && dB == .xu) ||
           (dS == .geng && dB == .chen) ||
           (dS == .wu && dB == .xu) {
            situations.append(.kuiGang)
        }
        
        // 3. Jin Shen (Hour Pillar + Day Stem)
        // Hour: Yi Chou, Ji Si, Gui You. Day Stem: Jia or Ji (some schools say only Jia/Ji, others broader).
        // Strict: Jia/Ji Day + Jin Shen Hour.
        if (dS == .jia || dS == .ji) {
            if (hS == .yi && hB == .chou) ||
               (hS == .ji && hB == .si) ||
               (hS == .gui && hB == .you) {
                situations.append(.jinShen)
            }
        }
        
        // 4. Shi E Da Bai (Day Pillar)
        // Jia Chen, Yi Si, Bing Shen, Ding Hai, Wu Xu, Ji Chou, Geng Chen, Xin Si, Ren Shen, Gui Hai
        // Year Branch relationship is checked? Usually fixed Pillars.
        // The definition is based on empty stems relative to year? No, usually fixed list of 10 days.
        let shiEList: [(Stem, Branch)] = [
            (.jia, .chen), (.yi, .si), (.bing, .shen), (.ding, .hai), (.wu, .xu),
            (.ji, .chou), (.geng, .chen), (.xin, .si), (.ren, .shen), (.gui, .hai)
        ]
        if shiEList.contains(where: { $0.0 == dS && $0.1 == dB }) {
            // Need to check if it matches the specific definition (Year Pillar relationship).
            // Simplified: often just checking the day pillar is considered a warning sign, 
            // but strict definition involves Lu being in Kong Wang of Year.
            // Let's use strict check: Day Lu is in Year's Kong Wang?
            // Actually Shi E Da Bai means "Day Lu is in Empty Branch (Kong Wang) relative to Year Stem".
            let luBranch = Branch.allCases.first(where: { dS.lifeStage(in: $0) == .linGuan })
            if let lu = luBranch, checkKongWang(stem: year.stem.value, branch: year.branch.value, target: lu) {
                situations.append(.shiEDaBai)
            }
        }
        
        // 5. Heavenly Unity (Tian Yuan Yi Qi)
        if yS == mS && mS == dS && dS == hS {
            situations.append(.tianYuanYiQi)
        }
        
        // 6. Earthly Unity (Di Zhi Yi Qi)
        if yB == mB && mB == dB && dB == hB {
            situations.append(.diZhiYiQi)
        }
        
        // 7. Sequential Stems (Lian Ru)
        // Check if stems are sequential (e.g. Jia Yi Bing Ding)
        if isSequential([yS, mS, dS, hS]) {
            situations.append(.tianGanLianRu)
        }
        
        // 8. Sequential Branches (Lian Ru)
        if isSequentialBranches([yB, mB, dB, hB]) {
            situations.append(.diZhiLianRu)
        }
        
        return situations
    }
    
    /// Calculates all Global Situations (Chart-wide Patterns/Features).
    /// Includes both built-in (e.g. San Qi) and user-registered custom situations.
    var allGlobalSituations: [String] {
        // 1. Get Built-in names
        var names = self.builtInGlobalSituations.map { $0.name }
        
        // 2. Get Custom Registered names
        let customRules = GlobalSituationRegistry.getAllRules()
        for rule in customRules {
            if rule.check(self) {
                names.append(rule.name)
            }
        }
        
        return names
    }
    
    // MARK: - Global Logic Helpers
    
    private func checkSanQi(s1: Stem, s2: Stem, s3: Stem) -> Bool {
        let set: Set<Stem> = [s1, s2, s3]
        if set.count != 3 { return false }
        
        // Heaven: Jia Wu Geng
        let heaven: Set<Stem> = [.jia, .wu, .geng]
        if set == heaven { return true }
        
        // Earth: Yi Bing Ding
        let earth: Set<Stem> = [.yi, .bing, .ding]
        if set == earth { return true }
        
        // Man: Ren Gui Xin
        let man: Set<Stem> = [.ren, .gui, .xin]
        if set == man { return true }
        
        return false
    }
    
    private func isSequential(_ stems: [Stem]) -> Bool {
        for i in 0..<stems.count - 1 {
            if stems[i+1] != stems[i].next(1) {
                return false
            }
        }
        return true
    }
    
    private func isSequentialBranches(_ branches: [Branch]) -> Bool {
        for i in 0..<branches.count - 1 {
            if branches[i+1] != branches[i].next(1) {
                return false
            }
        }
        return true
    }

    // ... (Existing Branch ShenSha methods) ...
    
    /// Calculates the Shen Sha (Stars) for a specific pillar's branch.
    func shenSha(for branch: Branch) -> [ShenSha] {
        var stars: [ShenSha] = []
        
        let dayStem = self.day.stem.value
        let yearStem = self.year.stem.value
        let yearBranch = self.year.branch.value
        let dayBranch = self.day.branch.value
        let monthBranch = self.month.branch.value
        
        // --- Based on Day Stem (Using Life Stages) ---
        
        // Lu Shen (Salary) - Day Stem "Lin Guan" (临官)
        if dayStem.lifeStage(in: branch) == .linGuan {
            stars.append(.luShen)
        }
        
        // Yang Ren (Goat Blade)
        if dayStem.yinYang == .yang {
            if dayStem.lifeStage(in: branch) == .diWang {
                stars.append(.yangRen)
            }
        } else {
            if dayStem.lifeStage(in: branch) == .guanDai {
                stars.append(.yangRen)
            }
        }
        
        // Fei Ren (Flying Blade)
        let yangRenBranch: Branch?
        if dayStem.yinYang == .yang {
            yangRenBranch = Branch.allCases.first { dayStem.lifeStage(in: $0) == .diWang }
        } else {
            yangRenBranch = Branch.allCases.first { dayStem.lifeStage(in: $0) == .guanDai }
        }
        
        if let yrb = yangRenBranch {
            if branch == yrb.next(6) {
                stars.append(.feiRen)
            }
        }
        
        // Jin Yu (Golden Carriage)
        if let luBranch = Branch.allCases.first(where: { dayStem.lifeStage(in: $0) == .linGuan }) {
             if branch == luBranch.next(2) {
                 stars.append(.jinYu)
             }
        }

        // --- Standard Lookups (Switch Case / Logic) ---
        
        // Tian Yi Gui Ren (Only Day Stem)
        if checkTianYi(stem: dayStem, branch: branch) {
            stars.append(.tianYi)
        }
        
        // Tai Ji Gui Ren (Only Day Stem)
        if checkTaiJi(stem: dayStem, branch: branch) {
            stars.append(.taiJi)
        }
        
        // Wen Chang (Only Day Stem)
        if checkWenChang(stem: dayStem, branch: branch) {
            stars.append(.wenChang)
        }
        
        // --- Based on Year Branch or Day Branch ---
        
        // Yi Ma (Only Day Branch)
        if checkYiMa(base: dayBranch, target: branch) {
            stars.append(.yiMa)
        }
        
        // Tao Hua (Only Day Branch)
        if checkTaoHua(base: dayBranch, target: branch) {
            stars.append(.taoHua)
        }
        
        // Hua Gai (Only Day Branch)
        if checkHuaGai(base: dayBranch, target: branch) {
            stars.append(.huaGai)
        }
        
        // Jiang Xing (Only Day Branch)
        if checkJiangXing(base: dayBranch, target: branch) {
            stars.append(.jiangXing)
        }
        
        // Jie Sha (Only Day Branch)
        if checkJieSha(base: dayBranch, target: branch) {
            stars.append(.jieSha)
        }
        
        // Wang Shen (Only Day Branch)
        if checkWangShen(base: dayBranch, target: branch) {
            stars.append(.wangShen)
        }
        
        // Gu Chen (Must use Year Branch)
        if checkGuChen(yearBranch: yearBranch, target: branch) {
            stars.append(.guChen)
        }
        
        // Gua Su (Must use Year Branch)
        if checkGuaSu(yearBranch: yearBranch, target: branch) {
            stars.append(.guaSu)
        }
        
        // Yuan Chen (Must use Year Stem/Branch)
        if checkYuanChen(yearStem: yearStem, yearBranch: yearBranch, target: branch) {
            stars.append(.yuanChen)
        }
        
        // --- Based on Month Branch ---
        
        // Tian De
        if checkTianDe(month: monthBranch, target: branch, targetStem: nil) {
             stars.append(.tianDe)
        }
        
        // Yue De
        if checkYueDeInBranch(month: monthBranch, target: branch) {
            stars.append(.yueDe)
        }
        
        // --- Based on Stem Cycle (Xun Kong) ---
        
        // Kong Wang (Only Day Pillar)
        if checkKongWang(stem: self.day.stem.value, branch: self.day.branch.value, target: branch) {
            stars.append(.kongWang)
        }
        
        return stars
    }
    
    func shenSha(for branchWrapper: Pillar.BranchWrapper) -> [ShenSha] {
        return shenSha(for: branchWrapper.value)
    }
    
    // MARK: - Logic Implementations
    
    private func checkTianYi(stem: Stem, branch: Branch) -> Bool {
        switch stem {
        case .jia, .wu: return branch == .chou || branch == .wei
        case .yi, .ji: return branch == .zi || branch == .shen
        case .bing, .ding: return branch == .hai || branch == .you
        case .ren, .gui: return branch == .mao || branch == .si
        case .geng, .xin: return branch == .wu || branch == .yin
        }
    }
    
    private func checkTaiJi(stem: Stem, branch: Branch) -> Bool {
        switch stem {
        case .jia, .yi: return branch == .zi || branch == .wu
        case .bing, .ding: return branch == .mao || branch == .you
        case .wu, .ji: return branch == .chen || branch == .xu || branch == .chou || branch == .wei
        case .geng, .xin: return branch == .yin || branch == .hai
        case .ren, .gui: return branch == .si || branch == .shen
        }
    }
    
    private func checkWenChang(stem: Stem, branch: Branch) -> Bool {
        switch stem {
        case .jia: return branch == .si
        case .yi: return branch == .wu
        case .bing, .wu: return branch == .shen
        case .ding, .ji: return branch == .you
        case .geng: return branch == .hai
        case .xin: return branch == .zi
        case .ren: return branch == .yin
        case .gui: return branch == .mao
        }
    }
    
    private func checkYiMa(base: Branch, target: Branch) -> Bool {
        switch base {
        case .shen, .zi, .chen: return target == .yin
        case .yin, .wu, .xu: return target == .shen
        case .si, .you, .chou: return target == .hai
        case .hai, .mao, .wei: return target == .si
        }
    }
    
    private func checkTaoHua(base: Branch, target: Branch) -> Bool {
        switch base {
        case .shen, .zi, .chen: return target == .you
        case .yin, .wu, .xu: return target == .mao
        case .si, .you, .chou: return target == .wu
        case .hai, .mao, .wei: return target == .zi
        }
    }
    
    private func checkHuaGai(base: Branch, target: Branch) -> Bool {
        switch base {
        case .shen, .zi, .chen: return target == .chen
        case .yin, .wu, .xu: return target == .xu
        case .si, .you, .chou: return target == .chou
        case .hai, .mao, .wei: return target == .wei
        }
    }
    
    private func checkJiangXing(base: Branch, target: Branch) -> Bool {
        switch base {
        case .shen, .zi, .chen: return target == .zi
        case .yin, .wu, .xu: return target == .wu
        case .si, .you, .chou: return target == .you
        case .hai, .mao, .wei: return target == .mao
        }
    }
    
    private func checkJieSha(base: Branch, target: Branch) -> Bool {
        switch base {
        case .shen, .zi, .chen: return target == .si
        case .yin, .wu, .xu: return target == .hai
        case .si, .you, .chou: return target == .yin
        case .hai, .mao, .wei: return target == .shen
        }
    }
    
    private func checkWangShen(base: Branch, target: Branch) -> Bool {
        switch base {
        case .shen, .zi, .chen: return target == .hai
        case .yin, .wu, .xu: return target == .si
        case .si, .you, .chou: return target == .shen
        case .hai, .mao, .wei: return target == .yin
        }
    }
    
    private func checkGuChen(yearBranch: Branch, target: Branch) -> Bool {
        switch yearBranch {
        case .hai, .zi, .chou: return target == .yin
        case .yin, .mao, .chen: return target == .si
        case .si, .wu, .wei: return target == .shen
        case .shen, .you, .xu: return target == .hai
        }
    }
    
    private func checkGuaSu(yearBranch: Branch, target: Branch) -> Bool {
        switch yearBranch {
        case .hai, .zi, .chou: return target == .xu
        case .yin, .mao, .chen: return target == .chou
        case .si, .wu, .wei: return target == .chen
        case .shen, .you, .xu: return target == .wei
        }
    }
    
    private func checkYuanChen(yearStem: Stem, yearBranch: Branch, target: Branch) -> Bool {
        let clash = yearBranch.next(6)
        if yearStem.yinYang == .yang {
            return target == clash.next(1)
        } else {
            return target == clash.previous(1)
        }
    }
    
    private func checkKongWang(stem: Stem, branch: Branch, target: Branch) -> Bool {
        let diffIdx = (branch.index - stem.index + 12) % 12
        let empty1 = (diffIdx + 10) % 12
        let empty2 = (diffIdx + 11) % 12
        return target.index == empty1 || target.index == empty2
    }
    
    private func checkTianDe(month: Branch, target: Branch, targetStem: Stem?) -> Bool {
        switch month {
        case .mao: return target == .shen
        case .wu: return target == .hai
        case .you: return target == .yin
        case .zi: return target == .si
        default: return false
        }
    }
    
    private func checkYueDeInBranch(month: Branch, target: Branch) -> Bool {
        var targetStem: Stem?
        switch month {
        case .yin, .wu, .xu: targetStem = .bing
        case .shen, .zi, .chen: targetStem = .ren
        case .hai, .mao, .wei: targetStem = .jia
        case .si, .you, .chou: targetStem = .geng
        }
        guard let ts = targetStem else { return false }
        return target.hiddenStems.contains(ts)
    }
}