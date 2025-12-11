import Foundation

/// Represents the Twelve Earthly Branches (Di Zhi).
public enum Branch: Int, CaseIterable, CyclicEnum {
    case zi = 1, chou, yin, mao, chen, si, wu, wei, shen, you, xu, hai
    
    /// The Chinese character representation of the Branch.
    public var character: String {
        switch self {
        case .zi: return "子"
        case .chou: return "丑"
        case .yin: return "寅"
        case .mao: return "卯"
        case .chen: return "辰"
        case .si: return "巳"
        case .wu: return "午"
        case .wei: return "未"
        case .shen: return "申"
        case .you: return "酉"
        case .xu: return "戌"
        case .hai: return "亥"
        }
    }
    
    public var fiveElement: FiveElements {
        switch self {
        case .yin, .mao:                return .wood
        case .si, .wu:                  return .fire
        case .chen, .xu, .chou, .wei:   return .earth
        case .shen, .you:               return .metal
        case .hai, .zi:                 return .water
        }
    }
    
    public var yinYang: YinYang {
        // Odd index is Yang, Even index is Yin (1-based rawValue)
        // Zi(1) -> Yang, Chou(2) -> Yin, etc.
        // Note: In some contexts (Zi-Wu-Mao-You), polarity might differ, 
        // but strictly by sequence order (Odd=Yang, Even=Yin):
        // Zi(1, Yang), Chou(2, Yin), Yin(3, Yang), Mao(4, Yin)...
        return self.rawValue % 2 != 0 ? .yang : .yin
    }
    
    /// The Hidden Stems (Cang Gan) contained within the Branch.
    /// The first element is always the Main Qi (Ben Qi).
    public var hiddenStems: [Stem] {
        switch self {
        case .zi:   return [.gui]                   // 癸
        case .chou: return [.ji, .gui, .xin]        // 己 癸 辛
        case .yin:  return [.jia, .bing, .wu]       // 甲 丙 戊
        case .mao:  return [.yi]                    // 乙
        case .chen: return [.wu, .yi, .gui]         // 戊 乙 癸
        case .si:   return [.bing, .geng, .wu]      // 丙 庚 戊
        case .wu:   return [.ding, .ji]             // 丁 己
        case .wei:  return [.ji, .ding, .yi]        // 己 丁 乙
        case .shen: return [.geng, .ren, .wu]       // 庚 壬 戊
        case .you:  return [.xin]                   // 辛
        case .xu:   return [.wu, .xin, .ding]       // 戊 辛 丁
        case .hai:  return [.ren, .jia]             // 壬 甲
        }
    }
    
    /// The Primary Qi (Ben Qi) of the Branch.
    public var mainQi: Stem {
        return hiddenStems[0]
    }
    
    // MARK: - Advanced Hidden Stems (Cang Gan)
    
    /// 本气 (Main Qi / Ben Qi)
    /// 代表地支最主要的五行力量
    public var benQi: Stem {
        return hiddenStems[0]
    }
    
    /// 中气 (Middle Qi / Zhong Qi)
    /// 包含长生之气或墓库之气
    public var zhongQi: Stem? {
        switch self {
        // 四长生 (Growth)
        case .yin: return .bing  // 寅中藏丙
        case .si:  return .geng  // 巳中藏庚
        case .shen: return .ren  // 申中藏壬
        case .hai: return .jia   // 亥中藏甲
            
        // 四库 (Grave) - 通常排在最后或中间，根据具体流派。
        // 根据您现有数组 [.wu, .yi, .gui] (辰)，第三个是癸(水库/中气)
        case .chen: return .gui  // 辰中藏癸 (水库)
        case .xu:   return .ding // 戌中藏丁 (火库)
        case .chou: return .xin  // 丑中藏辛 (金库)
        case .wei:  return .yi   // 未中藏乙 (木库)
            
        // 午火特殊，含丁己，己通常视为中气或余气，视作中气处理
        case .wu:   return .ji
            
        default: return nil
        }
    }
    
    /// 余气 (Residual Qi / Yu Qi)
    /// 代表上一季节延伸过来的力量
    public var yuQi: Stem? {
        switch self {
        // 四长生 (Growth) - 这里的土通常被视为余气
        case .yin: return .wu
        case .si:  return .wu
        case .shen: return .wu
        // 亥只有壬甲，无余气（或视甲为余气，但通常甲是长生/中气）
            
        // 四库 (Grave) - 这里的“余气”通常指上一季的五行
        // 您现有数组: 辰[.wu, .yi, .gui]，第二个乙木是春季余气
        case .chen: return .yi
        case .xu:   return .xin
        case .chou: return .gui
        case .wei:  return .ding
            
        default: return nil
        }
    }
}

