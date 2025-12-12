import Foundation

/// Represents the Twelve Life Stages (Shi Er Chang Sheng) in BaZi.
/// Describes the strength/state of a Heavenly Stem relative to an Earthly Branch.
public enum LifeStage: Int, CaseIterable, CustomStringConvertible {
    case changSheng = 1  // 长生 (Birth)
    case muYu            // 沐浴 (Bath)
    case guanDai         // 冠带 (Attire)
    case linGuan         // 临官 (Official/Lu)
    case diWang          // 帝旺 (Peak/Emperor)
    case shuai           // 衰   (Decline)
    case bing            // 病   (Sickness)
    case si              // 死   (Death)
    case mu              // 墓   (Grave/Storage)
    case jue             // 绝   (Extinction)
    case tai             // 胎   (Conception)
    case yang            // 养   (Nourishment)
    
    public var description: String {
        switch self {
        case .changSheng: return "长生"
        case .muYu: return "沐浴"
        case .guanDai: return "冠带"
        case .linGuan: return "临官"
        case .diWang: return "帝旺"
        case .shuai: return "衰"
        case .bing: return "病"
        case .si: return "死"
        case .mu: return "墓"
        case .jue: return "绝"
        case .tai: return "胎"
        case .yang: return "养"
        }
    }
}

extension Stem {
    
    /// Returns the Twelve Life Stages table for this Stem.
    /// Maps each Branch to its corresponding Life Stage.
    public var lifeStages: [Branch: LifeStage] {
        var result: [Branch: LifeStage] = [:]
        for branch in Branch.allCases {
            result[branch] = self.lifeStage(in: branch)
        }
        return result
    }
    
    /// Calculates the Life Stage of this Stem in relation to a specific Branch.
    public func lifeStage(in branch: Branch) -> LifeStage {
        let startBranch = self.changShengBranch
        let isForward = (self.yinYang == .yang)
        
        // Calculate distance
        // Yang: Clockwise (Branch - Start)
        // Yin: Counter-Clockwise (Start - Branch)
        
        let distance: Int
        if isForward {
            // (Target - Start + 12) % 12
            distance = (branch.rawValue - startBranch.rawValue + 12) % 12
        } else {
            // (Start - Target + 12) % 12
            distance = (startBranch.rawValue - branch.rawValue + 12) % 12
        }
        
        // Distance 0 -> ChangSheng (index 0 in 0-based list, but rawValue is 1-based)
        // LifeStage is 1-based Int enum
        // 0 -> 1 (ChangSheng)
        // 1 -> 2 (MuYu)
        return LifeStage(rawValue: distance + 1)!
    }
    
    /// The Branch where this Stem is in the "Chang Sheng" (Birth) stage.
    /// Based on the "Fire and Earth share the same palace" (Huo Tu Tong Gong) rule.
    private var changShengBranch: Branch {
        switch self {
        case .jia: return .hai  // 木长生在亥
        case .yi:  return .wu   // 乙木长生在午
            
        case .bing, .wu: return .yin // 火土长生在寅
        case .ding, .ji: return .you // 丁己长生在酉
            
        case .geng: return .si   // 金长生在巳
        case .xin:  return .zi   // 辛金长生在子
            
        case .ren:  return .shen // 水长生在申
        case .gui:  return .mao  // 癸水长生在卯
        }
    }
}
