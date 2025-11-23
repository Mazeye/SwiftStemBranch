import Foundation

/// Represents the Ten Heavenly Stems (Tian Gan).
public enum Stem: Int, CaseIterable, CyclicEnum {
    case jia = 1, yi, bing, ding, wu, ji, geng, xin, ren, gui
    
    /// The Chinese character representation of the Stem.
    public var character: String {
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
    }
}

