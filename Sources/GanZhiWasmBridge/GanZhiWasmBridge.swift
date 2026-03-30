import Foundation
import GanZhi

public enum GanZhiWasmBridge {
    public static func analyze(requestJSON: String) -> String {
        guard let requestData = requestJSON.data(using: .utf8) else {
            return encodeError(code: "INVALID_UTF8", message: "Request string is not valid UTF-8.")
        }

        let response = analyze(requestData: requestData)
        return String(data: response, encoding: .utf8) ?? "{\"success\":false,\"error\":{\"code\":\"ENCODE_FAILED\",\"message\":\"Failed to encode response as UTF-8.\"}}"
    }

    public static func analyze(requestData: Data) -> Data {
        do {
            let decoder = JSONDecoder()
            let request = try decoder.decode(Request.self, from: requestData)
            let previousLanguage = GanZhiConfig.language
            defer { GanZhiConfig.language = previousLanguage }

            applyLanguage(request.language)
            let result = try evaluate(request)
            let payload = Response(success: true, result: result, error: nil)

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            return try encoder.encode(payload)
        } catch let error as BridgeError {
            return encodeResponse(Response(success: false, result: nil, error: .init(code: error.code, message: error.message)))
        } catch {
            return encodeResponse(Response(success: false, result: nil, error: .init(code: "UNEXPECTED", message: error.localizedDescription)))
        }
    }

    private static func evaluate(_ request: Request) throws -> Result {
        let tzHours = request.timeZone ?? 0
        guard let timeZone = TimeZone(secondsFromGMT: Int(tzHours * 3600)) else {
            throw BridgeError(code: "INVALID_TIMEZONE", message: "Invalid timeZone offset: \(tzHours)")
        }

        guard let date = Date(
            year: request.year,
            month: request.month,
            day: request.day,
            hour: request.hour,
            minute: request.minute,
            timeZone: timeZone
        ) else {
            throw BridgeError(code: "INVALID_DATE", message: "Failed to construct date from components.")
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let pillars: FourPillars
        if request.useTrueSolarTime {
            guard let longitude = request.longitude else {
                throw BridgeError(code: "MISSING_LONGITUDE", message: "longitude is required when useTrueSolarTime is true.")
            }
            pillars = date.fourPillars(at: Location(longitude: longitude, timeZone: tzHours), calendar: calendar)
        } else {
            pillars = date.fourPillars(calendar: calendar)
        }

        let relationships: [RelationshipItem]?
        if request.includeRelationships {
            relationships = pillars.relationships.map {
                RelationshipItem(
                    pillars: $0.pillars,
                    characters: $0.characters,
                    type: $0.type.name,
                    isAffectionate: $0.isAffectionate
                )
            }
        } else {
            relationships = nil
        }

        let pattern: PatternItem?
        if request.includePattern {
            let p = pillars.determinePattern()
            pattern = PatternItem(
                name: p.description,
                tenGod: p.tenGod.name,
                method: p.method.description,
                methodDescription: p.methodDescription
            )
        } else {
            pattern = nil
        }

        let thermalBalance: ThermalBalanceItem?
        if request.includeThermalBalance {
            let tb = pillars.thermalBalance
            thermalBalance = ThermalBalanceItem(
                temperature: tb.temperature,
                moisture: tb.moisture,
                isFrozen: tb.isFrozen,
                isVapor: tb.isVapor
            )
        } else {
            thermalBalance = nil
        }

        let usefulGod: UsefulGodItem?
        if request.includeUsefulGod {
            let result = UsefulGodCalculator.analyze(pillars, method: .pattern)
            usefulGod = UsefulGodItem(
                yongShen: result.yongShen.map { $0.name },
                jiShen: result.jiShen.map { $0.name },
                favorableElements: result.favorableElements.map { $0.name },
                unfavorableElements: result.unfavorableElements.map { $0.name },
                description: result.description
            )
        } else {
            usefulGod = nil
        }

        let luck: LuckItem?
        if request.includeLuck {
            guard let gender = parseGender(request.gender) else {
                throw BridgeError(code: "INVALID_GENDER", message: "gender is required when includeLuck is true. Use male/female (or 男/女).")
            }

            let calculator = LuckCalculator(gender: gender, pillars: pillars, birthDate: date)
            let startAge = calculator.calculateStartAge()
            let limit = max(1, min(request.luckCycleLimit ?? 10, 12))
            let cycles = calculator.getMajorCycles(limit: limit)
            let birthYear = request.year

            luck = LuckItem(
                startAge: startAge,
                majorCycles: cycles.map { cycle in
                    let yearlyLuck: [YearlyLuckItem]?
                    if request.includeYearlyLuck {
                        yearlyLuck = (cycle.startYear...cycle.endYear).map { year in
                            let offset = year - 1984
                            var index = offset % 60
                            if index < 0 {
                                index += 60
                            }
                            let stemBranch = StemBranch.from(index: index)
                            return YearlyLuckItem(
                                year: year,
                                age: year - birthYear,
                                stemBranch: stemBranch.character
                            )
                        }
                    } else {
                        yearlyLuck = nil
                    }

                    return MajorCycleItem(
                        stemBranch: cycle.stemBranch.character,
                        startAge: cycle.startAge,
                        startYear: cycle.startYear,
                        endYear: cycle.endYear,
                        yearlyLuck: yearlyLuck
                    )
                }
            )
        } else {
            luck = nil
        }

        return Result(
            pillars: PillarsItem(
                year: pillars.year.character,
                month: pillars.month.character,
                day: pillars.day.character,
                hour: pillars.hour.character,
                summary: pillars.description
            ),
            lunarPhase: pillars.lunarPhase.map { phase in
                LunarPhaseItem(age: phase.age, illumination: phase.illumination, phaseName: phase.phaseName)
            },
            fiveElements: mapFiveElements(pillars.fiveElementCounts),
            yinYang: mapYinYang(pillars.yinYangCounts),
            relationships: relationships,
            pattern: pattern,
            thermalBalance: thermalBalance,
            usefulGod: usefulGod,
            luck: luck
        )
    }

    private static func parseGender(_ value: String?) -> Gender? {
        guard let value = value?.lowercased() else {
            return nil
        }

        switch value {
        case "male", "man", "m", "男":
            return .male
        case "female", "woman", "f", "女":
            return .female
        default:
            return nil
        }
    }

    private static func applyLanguage(_ value: String?) {
        guard let value = value?.lowercased() else {
            return
        }

        switch value {
        case "zh", "zh-cn", "zh-hans", "simplified", "simplifiedchinese":
            GanZhiConfig.language = .simplifiedChinese
        case "zh-hant", "zh-tw", "traditional", "traditionalchinese":
            GanZhiConfig.language = .traditionalChinese
        case "ja", "jp", "japanese":
            GanZhiConfig.language = .japanese
        case "en", "en-us", "en-gb", "english":
            GanZhiConfig.language = .english
        default:
            break
        }
    }

    private static func mapFiveElements(_ counts: [FiveElements: Int]) -> [String: Int] {
        return [
            "wood": counts[.wood, default: 0],
            "fire": counts[.fire, default: 0],
            "earth": counts[.earth, default: 0],
            "metal": counts[.metal, default: 0],
            "water": counts[.water, default: 0],
        ]
    }

    private static func mapYinYang(_ counts: [YinYang: Int]) -> [String: Int] {
        return [
            "yin": counts[.yin, default: 0],
            "yang": counts[.yang, default: 0],
        ]
    }

    private static func encodeError(code: String, message: String) -> String {
        let response = Response(success: false, result: nil, error: .init(code: code, message: message))
        let data = encodeResponse(response)
        return String(data: data, encoding: .utf8) ?? "{\"success\":false,\"error\":{\"code\":\"ENCODE_FAILED\",\"message\":\"Failed to encode error response.\"}}"
    }

    private static func encodeResponse(_ response: Response) -> Data {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            return try encoder.encode(response)
        } catch {
            return Data("{\"success\":false,\"error\":{\"code\":\"ENCODE_FAILED\",\"message\":\"Failed to encode bridge response.\"}}".utf8)
        }
    }
}

private struct BridgeError: Error {
    let code: String
    let message: String
}

public struct Request: Codable {
    public let year: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    public let timeZone: Double?
    public let longitude: Double?
    public let useTrueSolarTime: Bool
    public let language: String?
    public let includeRelationships: Bool
    public let includePattern: Bool
    public let includeThermalBalance: Bool
    public let includeUsefulGod: Bool
    public let includeLuck: Bool
    public let includeYearlyLuck: Bool
    public let gender: String?
    public let luckCycleLimit: Int?

    public init(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        timeZone: Double? = nil,
        longitude: Double? = nil,
        useTrueSolarTime: Bool = false,
        language: String? = nil,
        includeRelationships: Bool = true,
        includePattern: Bool = true,
        includeThermalBalance: Bool = false,
        includeUsefulGod: Bool = false,
        includeLuck: Bool = false,
        includeYearlyLuck: Bool = false,
        gender: String? = nil,
        luckCycleLimit: Int? = nil
    ) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.timeZone = timeZone
        self.longitude = longitude
        self.useTrueSolarTime = useTrueSolarTime
        self.language = language
        self.includeRelationships = includeRelationships
        self.includePattern = includePattern
        self.includeThermalBalance = includeThermalBalance
        self.includeUsefulGod = includeUsefulGod
        self.includeLuck = includeLuck
        self.includeYearlyLuck = includeYearlyLuck
        self.gender = gender
        self.luckCycleLimit = luckCycleLimit
    }

    enum CodingKeys: String, CodingKey {
        case year
        case month
        case day
        case hour
        case minute
        case timeZone
        case longitude
        case useTrueSolarTime
        case language
        case includeRelationships
        case includePattern
        case includeThermalBalance
        case includeUsefulGod
        case includeLuck
        case includeYearlyLuck
        case gender
        case luckCycleLimit
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        year = try container.decode(Int.self, forKey: .year)
        month = try container.decode(Int.self, forKey: .month)
        day = try container.decode(Int.self, forKey: .day)
        hour = try container.decode(Int.self, forKey: .hour)
        minute = try container.decode(Int.self, forKey: .minute)
        timeZone = try container.decodeIfPresent(Double.self, forKey: .timeZone)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        useTrueSolarTime = try container.decodeIfPresent(Bool.self, forKey: .useTrueSolarTime) ?? false
        language = try container.decodeIfPresent(String.self, forKey: .language)
        includeRelationships = try container.decodeIfPresent(Bool.self, forKey: .includeRelationships) ?? true
        includePattern = try container.decodeIfPresent(Bool.self, forKey: .includePattern) ?? true
        includeThermalBalance = try container.decodeIfPresent(Bool.self, forKey: .includeThermalBalance) ?? false
        includeUsefulGod = try container.decodeIfPresent(Bool.self, forKey: .includeUsefulGod) ?? false
        includeLuck = try container.decodeIfPresent(Bool.self, forKey: .includeLuck) ?? false
        includeYearlyLuck = try container.decodeIfPresent(Bool.self, forKey: .includeYearlyLuck) ?? false
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        luckCycleLimit = try container.decodeIfPresent(Int.self, forKey: .luckCycleLimit)
    }
}

public struct Response: Codable {
    public let success: Bool
    public let result: Result?
    public let error: ErrorItem?
}

public struct ErrorItem: Codable {
    public let code: String
    public let message: String
}

public struct Result: Codable {
    public let pillars: PillarsItem
    public let lunarPhase: LunarPhaseItem?
    public let fiveElements: [String: Int]
    public let yinYang: [String: Int]
    public let relationships: [RelationshipItem]?
    public let pattern: PatternItem?
    public let thermalBalance: ThermalBalanceItem?
    public let usefulGod: UsefulGodItem?
    public let luck: LuckItem?
}

public struct PillarsItem: Codable {
    public let year: String
    public let month: String
    public let day: String
    public let hour: String
    public let summary: String
}

public struct LunarPhaseItem: Codable {
    public let age: Double
    public let illumination: Double
    public let phaseName: String
}

public struct RelationshipItem: Codable {
    public let pillars: [String]
    public let characters: String
    public let type: String
    public let isAffectionate: Bool
}

public struct PatternItem: Codable {
    public let name: String
    public let tenGod: String
    public let method: String
    public let methodDescription: String
}

public struct ThermalBalanceItem: Codable {
    public let temperature: Double
    public let moisture: Double
    public let isFrozen: Bool
    public let isVapor: Bool
}

public struct UsefulGodItem: Codable {
    public let yongShen: [String]
    public let jiShen: [String]
    public let favorableElements: [String]
    public let unfavorableElements: [String]
    public let description: String
}

public struct LuckItem: Codable {
    public let startAge: Double
    public let majorCycles: [MajorCycleItem]
}

public struct MajorCycleItem: Codable {
    public let stemBranch: String
    public let startAge: Double
    public let startYear: Int
    public let endYear: Int
    public let yearlyLuck: [YearlyLuckItem]?
}

public struct YearlyLuckItem: Codable {
    public let year: Int
    public let age: Int
    public let stemBranch: String
}
