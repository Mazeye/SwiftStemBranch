import Foundation

/// Represents the Ten Heavenly Stems (Tian Gan).
public enum Stem: Int, CaseIterable, CyclicEnum {
    case jia = 1, yi, bing, ding, wu, ji, geng, xin, ren, gui
    
    /// The character representation of the Stem.
    /// Returns localized character based on GanZhiConfig.language.
    public var character: String {
        switch GanZhiConfig.language {
        case .simplifiedChinese, .traditionalChinese, .japanese:
            // Standard Characters
            switch self {
            case .jia: return "甲"
            case .yi: return "乙"
            case .bing: return "丙"
            case .ding: return "丁"
            case .wu: return "戊"
            case .ji: return "己"
            case .geng: return "庚"
            case .xin: return "辛"
            case .ren: return "壬"
            case .gui: return "癸"
            }
        case .english:
            // Pinyin/Translation
            switch self {
            case .jia: return "Jia"
            case .yi: return "Yi"
            case .bing: return "Bing"
            case .ding: return "Ding"
            case .wu: return "Wu"
            case .ji: return "Ji"
            case .geng: return "Geng"
            case .xin: return "Xin"
            case .ren: return "Ren"
            case .gui: return "Gui"
            }
        }
    }
    
    public var fiveElement: FiveElements {
        switch self {
        case .jia, .yi:      return .wood
        case .bing, .ding:   return .fire
        case .wu, .ji:       return .earth
        case .geng, .xin:    return .metal
        case .ren, .gui:     return .water
        }
    }
    
    public var yinYang: YinYang {
        // Odd index is Yang, Even index is Yin (1-based rawValue)
        // Jia(1) -> Yang, Yi(2) -> Yin, etc.
        return self.rawValue % 2 != 0 ? .yang : .yin
    }
}
