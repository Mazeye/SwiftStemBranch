import Foundation

/// Represents common Shen Sha (Stars/Gods) in BaZi.
public enum ShenSha: String, CaseIterable {
    // MARK: - Gui Ren (Noblemen/Benefactors)
    case tianYi = "天乙贵人"      // Tian Yi Gui Ren (Nobleman)
    case taiJi = "太极贵人"       // Tai Ji Gui Ren
    case wenChang = "文昌贵人"    // Wen Chang Gui Ren (Academic Star)
    case tianDe = "天德贵人"      // Tian De Gui Ren (Heavenly Virtue)
    case yueDe = "月德贵人"       // Yue De Gui Ren (Monthly Virtue)
    case tianDeHe = "天德合"      // Tian De Combination
    case yueDeHe = "月德合"       // Yue De Combination
    
    // MARK: - Character/Fate Stars
    case yiMa = "驿马"           // Yi Ma (Traveling Horse)
    case taoHua = "桃花"         // Tao Hua (Peach Blossom)
    case huaGai = "华盖"         // Hua Gai (Elegant Seal/Arts)
    case jiangXing = "将星"      // Jiang Xing (General Star)
    case jinShen = "金神"        // Jin Shen (Golden Spirit)
    
    // MARK: - Wealth/Power
    case luShen = "禄神"         // Lu Shen (Thriving/Salary)
    case jinYu = "金舆"          // Jin Yu (Golden Carriage)
    
    // MARK: - Inauspicious/Mixed
    case yangRen = "羊刃"        // Yang Ren (Goat Blade)
    case feiRen = "飞刃"         // Fei Ren (Flying Blade)
    case kongWang = "空亡"       // Kong Wang (Void/Emptiness)
    case yuanChen = "元辰"       // Yuan Chen (Original Spirit/Disaster)
    case jieSha = "劫煞"         // Jie Sha (Robbery Star)
    case wangShen = "亡神"       // Wang Shen (Death God)
    case guChen = "孤辰"         // Gu Chen (Solitary Star)
    case guaSu = "寡宿"          // Gua Su (Widow Star)
}

public extension FourPillars {
    
    /// Calculates the Shen Sha (Stars) for a specific pillar's branch.
    /// - Parameter branch: The branch to check.
    /// - Parameter pillarLocation: The location of the branch (year, month, day, hour).
    /// - Returns: A list of Shen Sha present in this branch.
    func shenSha(for branch: Branch) -> [ShenSha] {
        var stars: [ShenSha] = []
        
        let dayStem = self.day.stem
        let yearStem = self.year.stem
        let yearBranch = self.year.branch
        let dayBranch = self.day.branch
        let monthBranch = self.month.branch
        
        // --- Based on Day Stem (Using Life Stages) ---
        
        // 4. Lu Shen (Salary) - Day Stem "Lin Guan" (临官)
        // 禄神：甲禄在寅，乙禄在卯... 即临官位。
        if dayStem.lifeStage(in: branch) == .linGuan {
            stars.append(.luShen)
        }
        
        // 5. Yang Ren (Goat Blade) - Day Stem "Di Wang" (帝旺) - Mainly for Yang Stems
        // 阳刃：甲刃在卯，丙戊刃在午... 即帝旺位。
        // 对于阴干，各流派不一（有的说是帝旺，有的说是冠带，有的说无刃）。
        // 这里采用常见定义：阳干之刃在帝旺。阴干如乙刃在辰（冠带），丁己刃在未（冠带）。
        // 为保持简洁且符合主流“阳刃”定义，此处主要处理阳干。
        // 如果采用广义羊刃（阴阳皆有），则需特殊处理阴干。
        // 修正：常用法中，阴干之刃常指“冠带”位（如乙在辰），或者“帝旺”前一位。
        // 使用 LifeStage 简化判断：
        if dayStem.yinYang == .yang {
            if dayStem.lifeStage(in: branch) == .diWang {
                stars.append(.yangRen)
            }
        } else {
            // 阴干刃：乙在辰(冠带), 丁己在未(冠带), 辛在戌(冠带), 癸在丑(冠带)
            if dayStem.lifeStage(in: branch) == .guanDai {
                stars.append(.yangRen)
            }
        }
        
        // 6. Fei Ren (Flying Blade) - Clash with Yang Ren
        // 飞刃：羊刃对冲之支。
        // 既然已经有 Yang Ren 的逻辑，飞刃就是 Yang Ren 所在支的对冲支。
        // 为了不重复计算，这里直接判断逻辑：
        // 阳干：帝旺对冲（即“胎”位？不完全对应）。
        // 最好还是直接查对冲。
        let yangRenBranch: Branch?
        if dayStem.yinYang == .yang {
            // 阳干刃在帝旺
            // 反向查找哪个地支是帝旺有点麻烦，不如直接遍历
            yangRenBranch = Branch.allCases.first { dayStem.lifeStage(in: $0) == .diWang }
        } else {
            // 阴干刃在冠带
            yangRenBranch = Branch.allCases.first { dayStem.lifeStage(in: $0) == .guanDai }
        }
        
        if let yrb = yangRenBranch {
            // 对冲：index + 6
            if branch == yrb.next(6) {
                stars.append(.feiRen)
            }
        }
        
        // 7. Jin Yu (Golden Carriage) - Lu Shen + 2 positions
        // 禄前二位。禄是临官。
        // 临官 -> 帝旺 -> 衰 (前两位是衰？)
        // 寅(1)->辰(5) (1->2->3->4->5?? No. Index 2->4)
        // 甲禄寅(2), 金舆辰(4). 差2.
        // 乙禄卯(3), 金舆巳(5). 差2.
        // 所以金舆是 临官位 + 2 (Branch Index + 2)
        // 或者直接用 LifeStage 映射？
        // 甲(寅-临官) -> 辰(衰).
        // 乙(卯-临官) -> 巳(沐浴? 乙长生午, 逆行. 午(长生)->巳(沐浴)). 确实是沐浴.
        // 统一逻辑比较难，直接用 Branch Index 计算比较准。
        // Jin Yu = Lu Branch + 2 (Clockwise)
        if let luBranch = Branch.allCases.first(where: { dayStem.lifeStage(in: $0) == .linGuan }) {
             if branch == luBranch.next(2) {
                 stars.append(.jinYu)
             }
        }

        // --- Standard Lookups (Switch Case / Logic) ---
        
        // 1. Tian Yi Gui Ren (Nobleman) - Day Stem / Year Stem
        if checkTianYi(stem: dayStem, branch: branch) || checkTianYi(stem: yearStem, branch: branch) {
            stars.append(.tianYi)
        }
        
        // 2. Tai Ji Gui Ren - Day Stem / Year Stem
        if checkTaiJi(stem: dayStem, branch: branch) || checkTaiJi(stem: yearStem, branch: branch) {
            stars.append(.taiJi)
        }
        
        // 3. Wen Chang (Academic) - Day Stem / Year Stem
        if checkWenChang(stem: dayStem, branch: branch) || checkWenChang(stem: yearStem, branch: branch) {
            stars.append(.wenChang)
        }
        
        // --- Based on Year Branch or Day Branch ---
        
        // 8. Yi Ma (Traveling Horse)
        if checkYiMa(base: yearBranch, target: branch) || checkYiMa(base: dayBranch, target: branch) {
            stars.append(.yiMa)
        }
        
        // 9. Tao Hua (Peach Blossom)
        if checkTaoHua(base: yearBranch, target: branch) || checkTaoHua(base: dayBranch, target: branch) {
            stars.append(.taoHua)
        }
        
        // 10. Hua Gai (Arts)
        if checkHuaGai(base: yearBranch, target: branch) || checkHuaGai(base: dayBranch, target: branch) {
            stars.append(.huaGai)
        }
        
        // 11. Jiang Xing (General)
        if checkJiangXing(base: yearBranch, target: branch) || checkJiangXing(base: dayBranch, target: branch) {
            stars.append(.jiangXing)
        }
        
        // 12. Jie Sha (Robbery)
        if checkJieSha(base: yearBranch, target: branch) || checkJieSha(base: dayBranch, target: branch) {
            stars.append(.jieSha)
        }
        
        // 13. Wang Shen (Death God)
        if checkWangShen(base: yearBranch, target: branch) || checkWangShen(base: dayBranch, target: branch) {
            stars.append(.wangShen)
        }
        
        // 14. Gu Chen (Solitary) - Year Branch only
        if checkGuChen(yearBranch: yearBranch, target: branch) {
            stars.append(.guChen)
        }
        
        // 15. Gua Su (Widow) - Year Branch only
        if checkGuaSu(yearBranch: yearBranch, target: branch) {
            stars.append(.guaSu)
        }
        
        // 16. Yuan Chen (Disaster) - Year Branch (Sexagenary)
        // Note: Simplified check based on Year Branch relationship
        if checkYuanChen(yearStem: yearStem, yearBranch: yearBranch, target: branch) {
            stars.append(.yuanChen)
        }
        
        // --- Based on Month Branch ---
        
        // 17. Tian De (Heavenly Virtue)
        if checkTianDe(month: monthBranch, target: branch, targetStem: nil) { // Only checking branch match here
             stars.append(.tianDe)
        }
        
        // 18. Yue De (Monthly Virtue)
        if checkYueDeInBranch(month: monthBranch, target: branch) {
            stars.append(.yueDe)
        }
        
        // --- Based on Stem Cycle (Xun Kong) ---
        
        // 19. Kong Wang (Void) - Day Pillar / Year Pillar
        if checkKongWang(stem: self.day.stem, branch: self.day.branch, target: branch) ||
           checkKongWang(stem: self.year.stem, branch: self.year.branch, target: branch) {
            stars.append(.kongWang)
        }
        
        return stars
    }
    
    // MARK: - Logic Implementations
    
    private func checkTianYi(stem: Stem, branch: Branch) -> Bool {
        // 甲戊并牛羊, 乙己鼠猴乡, 丙丁猪鸡位, 壬癸兔蛇藏, 庚辛逢马虎
        switch stem {
        case .jia, .wu: return branch == .chou || branch == .wei
        case .yi, .ji: return branch == .zi || branch == .shen
        case .bing, .ding: return branch == .hai || branch == .you
        case .ren, .gui: return branch == .mao || branch == .si
        case .geng, .xin: return branch == .wu || branch == .yin
        }
    }
    
    private func checkTaiJi(stem: Stem, branch: Branch) -> Bool {
        // 甲乙生人子午中, 丙丁鸡兔定亨通, 戊己两干临四季, 庚辛寅亥禄丰隆, 壬癸巳申偏喜美
        switch stem {
        case .jia, .yi: return branch == .zi || branch == .wu
        case .bing, .ding: return branch == .mao || branch == .you
        case .wu, .ji: return branch == .chen || branch == .xu || branch == .chou || branch == .wei
        case .geng, .xin: return branch == .yin || branch == .hai
        case .ren, .gui: return branch == .si || branch == .shen
        }
    }
    
    private func checkWenChang(stem: Stem, branch: Branch) -> Bool {
        // 甲乙巳午报君知, 丙戊申宫丁己鸡, 庚猪辛鼠壬逢虎, 癸人见兔入云梯
        // 其实文昌位就是食神之临官位（针对阳干）？
        // 甲(木)食神丙(火), 丙临官在巳. (Match)
        // 丙(火)食神戊(土), 戊临官在巳. (No, 丙戊申宫 -> 申. 丙的文昌是申. 丙火长生在寅, 临官在巳. 申是病位?)
        // 文昌查法比较固定，依然用查表。
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
        // 申子辰马在寅, 寅午戌马在申, 巳酉丑马在亥, 亥卯未马在巳
        switch base {
        case .shen, .zi, .chen: return target == .yin
        case .yin, .wu, .xu: return target == .shen
        case .si, .you, .chou: return target == .hai
        case .hai, .mao, .wei: return target == .si
        }
    }
    
    private func checkTaoHua(base: Branch, target: Branch) -> Bool {
        // 申子辰在酉, 寅午戌在卯, 巳酉丑在午, 亥卯未在子
        // 实际上是三合局的“沐浴”位 (LifeStage: Bath)
        // 水局(申子辰) 长生申 -> 沐浴酉.
        // 火局(寅午戌) 长生寅 -> 沐浴卯.
        // 金局(巳酉丑) 长生巳 -> 沐浴午.
        // 木局(亥卯未) 长生亥 -> 沐浴子.
        // 所以桃花也可以用长生状态计算：三合五行之沐浴。
        switch base {
        case .shen, .zi, .chen: return target == .you
        case .yin, .wu, .xu: return target == .mao
        case .si, .you, .chou: return target == .wu
        case .hai, .mao, .wei: return target == .zi
        }
    }
    
    private func checkHuaGai(base: Branch, target: Branch) -> Bool {
        // 申子辰在辰... 三合局之墓库 (LifeStage: Grave/Storage)
        switch base {
        case .shen, .zi, .chen: return target == .chen
        case .yin, .wu, .xu: return target == .xu
        case .si, .you, .chou: return target == .chou
        case .hai, .mao, .wei: return target == .wei
        }
    }
    
    private func checkJiangXing(base: Branch, target: Branch) -> Bool {
        // 三合局之中神 (帝旺)
        switch base {
        case .shen, .zi, .chen: return target == .zi
        case .yin, .wu, .xu: return target == .wu
        case .si, .you, .chou: return target == .you
        case .hai, .mao, .wei: return target == .mao
        }
    }
    
    private func checkJieSha(base: Branch, target: Branch) -> Bool {
        // 三合局之绝位 (LifeStage: Extinction)
        // 水局(申子辰) 绝在巳.
        // 火局(寅午戌) 绝在亥.
        // 金局(巳酉丑) 绝在寅.
        // 木局(亥卯未) 绝在申.
        switch base {
        case .shen, .zi, .chen: return target == .si
        case .yin, .wu, .xu: return target == .hai
        case .si, .you, .chou: return target == .yin
        case .hai, .mao, .wei: return target == .shen
        }
    }
    
    private func checkWangShen(base: Branch, target: Branch) -> Bool {
        // 亡神: 申子辰水局见亥 (临官). 
        // 寅午戌火局见巳 (临官).
        // 巳酉丑金局见申 (临官).
        // 亥卯未木局见寅 (临官).
        // 实际上是三合五行的临官位.
        switch base {
        case .shen, .zi, .chen: return target == .hai
        case .yin, .wu, .xu: return target == .si
        case .si, .you, .chou: return target == .shen
        case .hai, .mao, .wei: return target == .yin
        }
    }
    
    private func checkGuChen(yearBranch: Branch, target: Branch) -> Bool {
        // 进一角
        switch yearBranch {
        case .hai, .zi, .chou: return target == .yin
        case .yin, .mao, .chen: return target == .si
        case .si, .wu, .wei: return target == .shen
        case .shen, .you, .xu: return target == .hai
        }
    }
    
    private func checkGuaSu(yearBranch: Branch, target: Branch) -> Bool {
        // 退一角
        switch yearBranch {
        case .hai, .zi, .chou: return target == .xu
        case .yin, .mao, .chen: return target == .chou
        case .si, .wu, .wei: return target == .chen
        case .shen, .you, .xu: return target == .wei
        }
    }
    
    private func checkYuanChen(yearStem: Stem, yearBranch: Branch, target: Branch) -> Bool {
        let clash = yearBranch.next(6) // 冲
        
        if yearStem.yinYang == .yang {
            // 阳年: 冲 + 1
            return target == clash.next(1)
        } else {
            // 阴年: 冲 - 1
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

