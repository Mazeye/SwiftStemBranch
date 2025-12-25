import Foundation

/// Represents the thermal and moisture balance of a BaZi chart.
public struct ThermalBalance {
    /// Temperature score (Han Nuan 寒暖). 
    /// Positive values represent Warm/Hot, negative represent Cool/Cold.
    public let temperature: Double
    
    /// Moisture score (Shi Zao 湿燥).
    /// Positive values represent Wet/Damp, negative represent Dry/Arid.
    public let moisture: Double
    
    /// Normalized temperature index (internal use for descriptions if needed).
    private var temperatureIndex: Double {
        return max(-1.0, min(1.0, temperature / 40.0))
    }
    
    /// Normalized moisture index (internal use for descriptions if needed).
    private var moistureIndex: Double {
        return max(-1.0, min(1.0, moisture / 40.0))
    }
    
    public var temperatureDescription: String {
        switch GanZhiConfig.language {
        case .simplifiedChinese:
            if temperatureIndex > 0.6 { return "极热" }
            if temperatureIndex > 0.2 { return "温热" }
            if temperatureIndex > -0.2 { return "中和" }
            if temperatureIndex > -0.6 { return "偏寒" }
            return "极寒"
        case .traditionalChinese:
            if temperatureIndex > 0.6 { return "極熱" }
            if temperatureIndex > 0.2 { return "溫熱" }
            if temperatureIndex > -0.2 { return "中和" }
            if temperatureIndex > -0.6 { return "偏寒" }
            return "極寒"
        case .japanese:
            if temperatureIndex > 0.6 { return "極熱" }
            if temperatureIndex > 0.2 { return "暖" }
            if temperatureIndex > -0.2 { return "中和" }
            if temperatureIndex > -0.6 { return "寒" }
            return "極寒"
        case .english:
            if temperatureIndex > 0.6 { return "Scalding" }
            if temperatureIndex > 0.2 { return "Warm" }
            if temperatureIndex > -0.2 { return "Neutral" }
            if temperatureIndex > -0.6 { return "Chilly" }
            return "Freezing"
        }
    }
    
    public var moistureDescription: String {
        switch GanZhiConfig.language {
        case .simplifiedChinese:
            if moistureIndex > 0.6 { return "极湿" }
            if moistureIndex > 0.2 { return "湿润" }
            if moistureIndex > -0.2 { return "中和" }
            if moistureIndex > -0.6 { return "干燥" }
            return "极燥"
        case .traditionalChinese:
            if moistureIndex > 0.6 { return "極濕" }
            if moistureIndex > 0.2 { return "濕潤" }
            if moistureIndex > -0.2 { return "中和" }
            if moistureIndex > -0.6 { return "乾燥" }
            return "極燥"
        case .japanese:
            if moistureIndex > 0.6 { return "極湿" }
            if moistureIndex > 0.2 { return "湿" }
            if moistureIndex > -0.2 { return "中和" }
            if moistureIndex > -0.6 { return "乾" }
            return "極乾"
        case .english:
            if moistureIndex > 0.6 { return "Soggy" }
            if moistureIndex > 0.2 { return "Moist" }
            if moistureIndex > -0.2 { return "Balanced" }
            if moistureIndex > -0.6 { return "Dry" }
            return "Parched"
        }
    }
}

extension Stem {
    /// Temperature weight for fire stems.
    /// Non-fire stems return 0.0 as temperature depends only on Fire.
    var fireTemperatureBase: Double {
        switch self {
        case .bing: return 10.0
        case .ding: return 6.0
        default:    return 0.0
        }
    }
    
    var moistureBase: Double {
        switch self {
        case .ren, .gui: return 3.0  // 水主湿
        case .bing, .ding: return -3.0 // 火主燥
        case .wu: return -2.0        // 燥土
        case .ji: return 1.0         // 湿土 (田园之土)
        case .jia, .yi: return 0.5   // 活木略带湿
        case .geng, .xin: return -0.5 // 金主干燥
        }
    }
}

extension Branch {
    /// Baseline temperature contribution for the month branch.
    public var thermalBaseline: Double {
        switch self {
        case .zi:   return -5
        case .chou: return -10
        case .yin:  return 1
        case .mao:  return 3
        case .chen: return 9
        case .si:   return 15
        case .wu:   return 20
        case .wei:  return 15
        case .shen: return 9
        case .you:  return 3
        case .xu:   return 1
        case .hai:  return -2
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
        case .si: return 8.0
        case .wu: return 10.0
        default:  return 0.0
        }
    }
    
    var moistureBase: Double {
        switch self {
        case .zi, .hai: return 3.0   // 水
        case .chen, .chou: return 2.0 // 湿土
        case .wu, .si: return -3.0   // 火
        case .xu, .wei: return -2.0   // 燥土
        case .shen, .you: return -1.0 // 金燥
        case .yin, .mao: return 0.5   // 木 (Contains water/fire)
        }
    }
}
