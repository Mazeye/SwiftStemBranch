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
}

