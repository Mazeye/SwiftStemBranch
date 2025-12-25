import Foundation

/// Represents the thermal and moisture balance of a BaZi chart.
public struct ThermalBalance {
    /// Temperature score (Han Nuan 寒暖). 
    /// Positive values represent Warm/Hot, negative represent Cool/Cold.
    public let temperature: Double
    
    /// Moisture score (Shi Zao 湿燥).
    /// Positive values represent Wet/Damp, negative represent Dry/Arid.
    public let moisture: Double
    
    /// Status: Frozen (Temp <= 0)
    public var isFrozen: Bool {
        return temperature <= 0
    }
    
    /// Status: Vapor/Gas (Temp > 100)
    public var isVapor: Bool {
        return temperature > 100
    }
}

extension Stem {
    /// Temperature weight for fire stems.
    /// Non-fire stems return 0.0 as temperature depends only on Fire.
    var fireTemperatureBase: Double {
        switch self {
        case .bing: return 9
        case .ding: return 3
        default:    return 0.0
        }
    }
    
    /// Moisture weight for water stems.
    /// Gui (癸) mirrors Bing (丙) = 9
    /// Ren (壬) mirrors Ding (丁) = 3
    var waterMoistureBase: Double {
        switch self {
        case .gui: return 9
        case .ren: return 3
        default:   return 0.0
        }
    }
    
    /// Moisture weight for earth stems.
    var earthMoistureBase: Double {
        switch self {
        case .ji: return 1.0  // Wet Earth
        case .wu: return -2.0 // Dry Earth
        default:  return 0.0
        }
    }
}

extension Branch {
    /// Baseline temperature contribution for the month branch.
    public var thermalBaseline: Double {
        switch self {
        case .zi:   return -5
        case .chou: return -3
        case .yin:  return 1
        case .mao:  return 5
        case .chen: return 9
        case .si:   return 15
        case .wu:   return 20
        case .wei:  return 18
        case .shen: return 9
        case .you:  return 3
        case .xu:   return 5
        case .hai:  return 0
        }
    }
    
    /// Monthly multiplier for Bing Fire (丙火) based on the 12 Life Stages.
    public var bingFireCoefficient: Double {
        switch Stem.bing.lifeStage(in: self) {
        case .changSheng: return 1.2
        case .muYu:       return 1.3
        case .guanDai:    return 1.5
        case .linGuan:    return 1.8
        case .diWang:     return 2.0
        case .shuai:      return 1.0
        case .bing:       return 0.8
        case .si:         return 0.5
        case .mu:         return 0.6
        case .jue:        return 0.5
        case .tai:        return 0.7
        case .yang:       return 0.9
        }
    }

    /// Temperature contribution for fire branches.
    var fireTemperatureBase: Double {
        switch self {
        case .si: return 2.0
        case .wu: return 4.0
        default:  return 0.0
        }
    }
    
    /// Moisture contribution for water branches.
    /// Zi (子) mirrors Si (巳) = 2
    /// Hai (亥) mirrors Wu (午) = 4
    var waterMoistureBase: Double {
        switch self {
        case .zi: return 2.0
        case .hai: return 4.0
        default:  return 0.0
        }
    }
    
    /// Moisture contribution for earth branches.
    var earthMoistureBase: Double {
        switch self {
        case .chen, .chou: return 2.0 // Wet Earth
        case .xu, .wei:    return -2.0 // Dry Earth
        default:           return 0.0
        }
    }
}
