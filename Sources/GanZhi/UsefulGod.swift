import Foundation

/// Represents the result of a Useful God (Yong Shen) analysis.
public struct UsefulGodResult: CustomStringConvertible {
    /// The Useful Gods (Yong Shen). Theoretically checking against these Ten Gods is beneficial.
    public let yongShen: [TenGods]

    /// The Negative Gods (Ji Shen). Theoretically these should be avoided.
    public let jiShen: [TenGods]

    /// Favorable Five Elements based on the analysis.
    public let favorableElements: [FiveElements]

    /// Unfavorable Five Elements based on the analysis.
    public let unfavorableElements: [FiveElements]

    /// A human-readable analysis description explaining the reasoning.
    public let description: String
}

/// Enum defining the method used for Useful God analysis.
public enum UsefulGodMethod {
    /// The traditional Pattern method (Ge Ju Fa).
    case pattern
    /// The Wang Shuai method based on element strength percentages.
    case wangShuai
    /// The Tiao Hou method (Climate Adjustment) - Placeholder.
    case tiaoHou
}

/// A decoupled service to calculate the Useful God (Yong Shen) and Ji Shen.
public struct UsefulGodCalculator {

    /// Analyzes the Four Pillars to determine the Useful God based on the selected method.
    public static func analyze(_ chart: FourPillars, method: UsefulGodMethod = .pattern)
        -> UsefulGodResult
    {
        let context = AnalysisContext(chart: chart, method: method)
        
        // 1. Log Initial Energy State
        logEnergyState(context)
        
        // 2. Logic Dispatch
        switch method {
        case .pattern:
            analyzePatternMethod(context)
        case .wangShuai:
            analyzeWangShuaiMethod(context)
        case .tiaoHou:
            analyzeTiaoHouMethod(context)
        }
        
        return createResult(context)
    }
    
    // MARK: - Sub-routines
    
    private static func logEnergyState(_ ctx: AnalysisContext) {
        ctx.addReason("Method: \(ctx.method == .pattern ? "Pattern (Ge Ju)" : "Wang Shuai")")
        ctx.addReason(
            "Five Element Energies: \(ctx.energies.map { "\($0.key.description):\($0.value)" }.joined(separator: ", "))"
        )
        ctx.addReason("Support (Self+Resource): \(String(format: "%.2f", ctx.supportEnergy))")
        ctx.addReason("Consumption (Output+Wealth+Officer): \(String(format: "%.2f", ctx.consumptionEnergy))")
    }
    
    private static func createResult(_ ctx: AnalysisContext) -> UsefulGodResult {
        var favGods: Set<TenGods> = []
        var unfavGods: Set<TenGods> = []

        func godsOf(_ element: FiveElements) -> [TenGods] {
            var list: [TenGods] = []
            for god in TenGods.allCases {
                if TenGodRelations.elementOf(god, relativeTo: ctx.dmElement) == element {
                    list.append(god)
                }
            }
            return list
        }

        for elm in ctx.favElements {
            favGods.formUnion(godsOf(elm))
        }
        for elm in ctx.unfavElements {
            unfavGods.formUnion(godsOf(elm))
        }

        // Method-specific exclusions (Pattern Method)
        if ctx.method == .pattern {
            let patternTenGod = ctx.chart.determinePattern().tenGod
            if patternTenGod == .eatingGod {
                favGods.remove(.indirectResource)
            }
            if patternTenGod == .hurtingOfficer {
                favGods.remove(.directOfficer)
            }
            if patternTenGod == .directOfficer {
                favGods.remove(.hurtingOfficer)
            }
        }

        return UsefulGodResult(
            yongShen: Array(favGods).sorted(by: { $0.rawValue < $1.rawValue }),
            jiShen: Array(unfavGods).sorted(by: { $0.rawValue < $1.rawValue }),
            favorableElements: Array(ctx.favElements).sorted(by: { $0.rawValue < $1.rawValue }),
            unfavorableElements: Array(ctx.unfavElements).sorted(by: { $0.rawValue < $1.rawValue }),
            description: ctx.reasons.joined(separator: "\n")
        )
    }
    
    // MARK: - Pattern Method Logic
    
    private static func analyzePatternMethod(_ ctx: AnalysisContext) {
        let pattern = ctx.chart.determinePattern()
        
        // 1. Check Special Patterns
        if handleSpecialPattern(ctx, pattern: pattern) {
            return
        }
        
        // 2. Normal Pattern Logic (Percentage based)
        calculateNormalPattern(ctx, pattern: pattern)
    }
    
    private static func handleSpecialPattern(_ ctx: AnalysisContext, pattern: Pattern) -> Bool {
        let child = ctx.child
        let parent = ctx.parent
        let controlled = ctx.controlled
        let officer = ctx.controller
        let dm = ctx.dmElement
        
        switch pattern.method {
        case .followSevenKillings:
            ctx.addReason("Status: Follow Seven Killings (从杀格)")
            ctx.addFav(controlled)
            ctx.addFav(officer)
            ctx.addUnfav(child)
            ctx.addUnfav(parent)
            
            ctx.addReason("Useful God: Wealth & Officer [\(controlled.description), \(officer.description)]")
            ctx.addReason("Ji God: Output & Resource [\(child.description), \(parent.description)]")
            return true
            
        case .followWealth:
            ctx.addReason("Status: Follow Wealth (从财格)")
            ctx.addFav(child)
            ctx.addFav(controlled)
            ctx.addFav(officer)
            ctx.addUnfav(dm)
            ctx.addUnfav(parent)
            
            ctx.addReason("Useful God: Output, Wealth & Officer [\(child.description), \(controlled.description), \(officer.description)]")
            ctx.addReason("Ji God: Peer & Resource [\(dm.description), \(parent.description)]")
            return true
            
        case .followChild:
            ctx.addReason("Status: Follow Child (从儿格)")
            ctx.addFav(controlled)
            ctx.addFav(child)
            ctx.addFav(dm)
            ctx.addUnfav(parent)
            ctx.addUnfav(officer)
            
            ctx.addReason("Useful God: Wealth, Output & Peer [\(controlled.description), \(child.description), \(dm.description)]")
            ctx.addReason("Ji God: Resource & Officer [\(parent.description), \(officer.description)]")
            return true
            
        case .quZhi, .yanShang, .jiaSe, .congGe:
            ctx.addReason("Status: Special Pattern (\(pattern.method.description))")
            ctx.addFav(child)        // Output
            ctx.addFav(dm)           // Peer
            ctx.addFav(parent)       // Resource
            ctx.addUnfav(officer)    // Officer
            ctx.addUnfav(controlled) // Wealth
            
            ctx.addReason("Useful God: Output, Peer & Resource [\(child.description), \(dm.description), \(parent.description)]")
            ctx.addReason("Ji God: Officer & Wealth [\(officer.description), \(controlled.description)]")
            return true
            
        case .runXia:
            ctx.addReason("Status: Special Pattern (润下格)")
            ctx.addFav(child)        // Output
            ctx.addFav(controlled)   // Wealth
            ctx.addFav(parent)       // Resource
            ctx.addUnfav(officer)    // Officer
            
            ctx.addReason("Useful God: Output, Wealth & Resource [\(child.description), \(controlled.description), \(parent.description)]")
            ctx.addReason("Ji God: Officer [\(officer.description)]")
            return true
            
        default:
            return false
        }
    }
    
    private static func calculateNormalPattern(_ ctx: AnalysisContext, pattern: Pattern) {
        // Calculate Percentages
        let eResource = ctx.energies[ctx.parent] ?? 0
        let eSelf = ctx.energies[ctx.dmElement] ?? 0
        let eOutput = ctx.energies[ctx.child] ?? 0
        let eWealth = ctx.energies[ctx.controlled] ?? 0
        let eOfficer = ctx.energies[ctx.controller] ?? 0
        let total = ctx.totalEnergy

        let pctResource = total > 0 ? eResource / total : 0
        let pctSelf = total > 0 ? eSelf / total : 0
        let eConsumption = eOutput + eWealth + eOfficer
        let pctConsumption = total > 0 ? eConsumption / total : 0

        ctx.addReason(
            "Energy Division: Resource \(String(format: "%.1f%%", pctResource*100)), Self \(String(format: "%.1f%%", pctSelf*100)), Consumption \(String(format: "%.1f%%", pctConsumption*100))"
        )
        
        // Inner function to process a specific pattern context (Main or Auxiliary)
        func processPatternFocus(pTenGod: TenGods, pMethod: Pattern.DeterminationMethod) -> (fav: Set<FiveElements>, unfav: Set<FiveElements>, reasons: [String]) {
            var fav: Set<FiveElements> = []
            var unfav: Set<FiveElements> = []
            var r: [String] = []
            
            // Helper closure to add result
            func addRes(_ text: String, f: FiveElements? = nil, u: FiveElements? = nil) {
                r.append(text)
                if let f = f { fav.insert(f) }
                if let u = u { unfav.insert(u) }
            }

            if pctResource > 0.5 {
                r.append("Pattern Logic (\(pTenGod.description)): Resource Dominant (>50%)")
                unfav.insert(ctx.parent)
                if pctConsumption > pctSelf {
                    addRes("Useful God: Self (Consumption > Self) [\(ctx.dmElement.description)]", f: ctx.dmElement)
                } else {
                    if eOutput >= eOfficer {
                        addRes("Useful God: Output (Output >= Officer) [\(ctx.child.description)]", f: ctx.child)
                    } else {
                        addRes("Useful God: Officer (Officer > Output) [\(ctx.controller.description)]", f: ctx.controller)
                    }
                }
            } else if pctSelf > 0.5 {
                r.append("Pattern Logic (\(pTenGod.description)): Self Dominant (>50%)")
                unfav.insert(ctx.dmElement)
                
                let protectionPatterns: Set<Pattern.DeterminationMethod> = [.yangRen, .jianLu, .yueRen]
                let officerPatterns: Set<TenGods> = [.directResource, .indirectResource, .directOfficer, .sevenKillings]
                
                if protectionPatterns.contains(pMethod) || officerPatterns.contains(pTenGod) {
                    addRes("Useful God: Officer (Pattern Requirement) [\(ctx.controller.description)]", f: ctx.controller)
                } else if [.eatingGod, .hurtingOfficer].contains(pTenGod) {
                    addRes("Useful God: Output (Pattern Requirement) [\(ctx.child.description)]", f: ctx.child)
                } else {
                    if [.directWealth, .indirectWealth].contains(pTenGod) {
                         addRes("Useful God: Wealth (Pattern Requirement) [\(ctx.controlled.description)]", f: ctx.controlled)
                    } else {
                        r.append("Useful God: Max Consumption (Fallback)")
                        let maxCons = [(ctx.child, eOutput), (ctx.controlled, eWealth), (ctx.controller, eOfficer)]
                            .max(by: { $0.1 < $1.1 })!.0
                        fav.insert(maxCons)
                    }
                }
            } else {
                let selfTotalPct = pctSelf + pctResource
                r.append("Pattern Logic (\(pTenGod.description)): Normal/Balanced (Self+Res: \(String(format: "%.1f%%", selfTotalPct*100)))")
                
                if [.directResource, .indirectResource].contains(pTenGod) {
                    let parts = [("Resource", pctResource), ("Self", pctSelf), ("Consumption", pctConsumption)]
                    let strongest = parts.max(by: { $0.1 < $1.1 })!.0
                    let weakest = parts.min(by: { $0.1 < $1.1 })!.0
                    
                    if strongest == "Resource" && weakest == "Consumption" {
                        addRes("Useful God: Output (Resource is strongest) [\(ctx.child.description)]", f: ctx.child, u: ctx.parent)
                        r.append("Ji God: Resource (Strongest part) [\(ctx.parent.description)]")
                    } else {
                        let target = (eOfficer >= eOutput) ? ctx.controller : ctx.child
                        let reason = (eOfficer >= eOutput) ? "Officer (Officer >= Output)" : "Output (Output > Officer)"
                        addRes("Useful God: \(reason) [\(target.description)]", f: target, u: TenGodRelations.getController(target))
                        r.append("Ji God: Controller of Useful [\(TenGodRelations.getController(target).description)]")
                    }
                } else if [.directWealth, .indirectWealth].contains(pTenGod) {
                    if pctConsumption > selfTotalPct {
                        addRes("Useful God: Peer (Cons > Self+Res) [\(ctx.dmElement.description)]", f: ctx.dmElement, u: ctx.controller)
                        r.append("Ji God: Officer [\(ctx.controller.description)]")
                    } else {
                        let target = (eWealth <= eOutput) ? ctx.controlled : ctx.child
                        let reason = (eWealth <= eOutput) ? "Wealth (Wealth <= Output)" : "Output (Output < Wealth)"
                        addRes("Useful God: \(reason) [\(target.description)]", f: target, u: ctx.parent)
                        r.append("Ji God: Resource [\(ctx.parent.description)]")
                    }
                } else if [.directOfficer, .sevenKillings].contains(pTenGod) {
                    let candidates = [(ctx.child, eOutput), (ctx.dmElement, eSelf), (ctx.parent, eResource)]
                    let winner = candidates.max(by: { $0.1 < $1.1 })!.0
                    addRes("Useful God: Max(Output, Peer, Resource) [\(winner.description)]", f: winner, u: TenGodRelations.getController(winner))
                    r.append("Ji God: Controller of Useful [\(TenGodRelations.getController(winner).description)]")
                } else if [.eatingGod, .hurtingOfficer].contains(pTenGod) {
                    if pctConsumption > 2 * selfTotalPct {
                        r.append("Useful God: Resource & Peer (Cons > 2*(Self+Res))")
                        fav.insert(ctx.parent); fav.insert(ctx.dmElement)
                        let maxCons = [(ctx.child, eOutput), (ctx.controlled, eWealth), (ctx.controller, eOfficer)]
                            .max(by: { $0.1 < $1.1 })!.0
                        addRes("Ji God: Max Consumption [\(maxCons.description)]", u: maxCons)
                    } else {
                         let winner = (eWealth >= eOfficer) ? ctx.controlled : ctx.controller
                         let reason = (eWealth >= eOfficer) ? "Wealth (Wealth >= Officer)" : "Officer (Officer > Wealth)"
                         addRes("Useful God: \(reason) [\(winner.description)]", f: winner, u: TenGodRelations.getController(winner))
                         r.append("Ji God: Controller of Useful [\(TenGodRelations.getController(winner).description)]")
                    }
                } else {
                    r.append("Status: Blade/Luck/Other")
                    r.append("Ji God: Peer [\(ctx.dmElement.description)]")
                    unfav.insert(ctx.dmElement)
                    let maxCons = [(ctx.child, eOutput), (ctx.controlled, eWealth), (ctx.controller, eOfficer)]
                        .max(by: { $0.1 < $1.1 })!.0
                    addRes("Useful God: Max Consumption [\(maxCons.description)]", f: maxCons)
                }
            }
            return (fav, unfav, r)
        }
        
        // Execute Logic
        let pTenGod = pattern.tenGod
        let pMethod = pattern.method
        
        var (primaryFav, primaryUnfav, primaryReasons) = processPatternFocus(pTenGod: pTenGod, pMethod: pMethod)
        ctx.reasons.append(contentsOf: primaryReasons)
        
        // Auxiliary Pattern Logic
        if let auxTenGod = pattern.auxiliaryTenGod, let auxMethod = pattern.auxiliaryMethod {
            ctx.addReason("--- Auxiliary Pattern detected: \(auxTenGod.description) ---")
            let (auxFav, auxUnfav, auxReasons) = processPatternFocus(pTenGod: auxTenGod, pMethod: auxMethod)
            ctx.reasons.append(contentsOf: auxReasons)
            
            primaryFav.formUnion(auxFav)
            primaryUnfav.formUnion(auxUnfav)
            
            let intersection = primaryFav.intersection(primaryUnfav)
            if !intersection.isEmpty {
                ctx.addReason("Conflicting elements removed: \(intersection.map { $0.description }.joined(separator: ", "))")
                primaryFav.subtract(intersection)
                primaryUnfav.subtract(intersection)
            }
        }
        
        ctx.favElements = primaryFav
        ctx.unfavElements = primaryUnfav
    }

    // MARK: - Wang Shuai Method Logic
    
    private static func analyzeWangShuaiMethod(_ ctx: AnalysisContext) {
        // 1. Check Dominant
        if let dom = findDominantElement(ctx) {
            ctx.addReason("Status: Dominant Element (Zhuan Wang)")
            ctx.addReason("Dominant: \(dom.description) (>55%)")

            let usefulSelf = dom
            let usefulSource = TenGodRelations.getParent(dom)
            let jiController = TenGodRelations.getController(dom)

            ctx.addReason("Useful God: Dominant [\(usefulSelf.description)] & Source [\(usefulSource.description)]")
            ctx.addReason("Ji God: Controller [\(jiController.description)]")

            ctx.addFav(usefulSelf)
            ctx.addFav(usefulSource)
            ctx.addUnfav(jiController)
            return
        }

        // 2. Check Conflict
        if let (attacker, defender) = findConflictPair(ctx) {
            ctx.addReason("Status: Conflict / Tong Guan (Bridge needed)")
            ctx.addReason("Conflict: \(attacker.description) controls \(defender.description) (Both 35-50%)")

            let bridge = TenGodRelations.getChild(attacker)
            let jiElm = TenGodRelations.getController(bridge)

            ctx.addReason("Useful God: Bridge [\(bridge.description)]")
            ctx.addReason("Ji God: Controller of Bridge [\(jiElm.description)]")

            ctx.addFav(bridge)
            ctx.addUnfav(jiElm)
            return
        }
        
        // 3. Fu Yi (Shared Logic)
        if applyFuYiLogic(ctx) {
            return
        }
        
        ctx.addReason("Status: Balanced / Other")
        ctx.addReason("Advise: No specific Useful/Ji God found by Wang Shuai method.")
    }
    
    private static func findDominantElement(_ ctx: AnalysisContext) -> FiveElements? {
        let total = ctx.totalEnergy
        for e in FiveElements.allCases {
            let eEnergy = ctx.energies[e] ?? 0
            if total > 0 && (eEnergy / total > 0.55) {
                return e
            }
        }
        return nil
    }
    
    private static func findConflictPair(_ ctx: AnalysisContext) -> (FiveElements, FiveElements)? {
        let total = ctx.totalEnergy
        guard total > 0 else { return nil }
        
        for e1 in FiveElements.allCases {
            let p1 = (ctx.energies[e1] ?? 0) / total
            guard p1 >= 0.35 && p1 <= 0.50 else { continue }

            let e2 = TenGodRelations.getControlled(e1)
            let p2 = (ctx.energies[e2] ?? 0) / total

            if p2 >= 0.35 && p2 <= 0.50 {
                return (e1, e2)
            }
        }
        return nil
    }

    private static func applyFuYiLogic(_ ctx: AnalysisContext) -> Bool {
        if ctx.consumptionEnergy > 2 * ctx.supportEnergy {
            ctx.addReason("Status: Too Weak (Consumption > 2 * Support)")
            ctx.addReason("Useful God: Resource (生我者) [\(ctx.parent.description)]")
            ctx.addReason("Ji God: Wealth (我克者) [\(ctx.controlled.description)]")

            ctx.addFav(ctx.parent)
            ctx.addUnfav(ctx.controlled)
            return true

        } else if ctx.supportEnergy > 2 * ctx.consumptionEnergy {
            ctx.addReason("Status: Too Strong (Support > 2 * Consumption)")
            ctx.addReason("Useful God: Output (我生者) [\(ctx.child.description)] & Wealth (我克者) [\(ctx.controlled.description)]")
            ctx.addReason("Ji God: Resource (生我者) [\(ctx.parent.description)]")

            ctx.addFav(ctx.child)
            ctx.addFav(ctx.controlled)
            ctx.addUnfav(ctx.parent)
            return true
        }
        return false
    }
    
    // MARK: - Tiao Hou Method Logic
    
    private static func analyzeTiaoHouMethod(_ ctx: AnalysisContext) {
        let tb = ctx.chart.thermalBalance
        let currentTemp = tb.temperature
        let currentMoist = tb.moisture

        ctx.addReason("Method: Tiao Hou (Climate Adjustment)")
        ctx.addReason("Current: Temp \(String(format: "%.2f", currentTemp)), Humid \(String(format: "%.2f", currentMoist))")

        // Configuration (Ideally moved to external config)
        struct IdealClimate {
            let tempRange: ClosedRange<Double>
            let moistRange: ClosedRange<Double>
        }
        
        let dmStem = ctx.chart.day.stem.value
        let idealClimates: [Stem: IdealClimate] = [
            .jia: IdealClimate(tempRange: 12...65, moistRange: 3...90),
            .yi: IdealClimate(tempRange: 8...60, moistRange: 5...80),
            .bing: IdealClimate(tempRange: 10...1500, moistRange: 1...100),
            .ding: IdealClimate(tempRange: 0...1500, moistRange: 1...100),
            .wu: IdealClimate(tempRange: 5...150, moistRange: 1...110),
            .ji: IdealClimate(tempRange: 5...130, moistRange: 10...120),
            .geng: IdealClimate(tempRange: 1...200, moistRange: 1...100),
            .xin: IdealClimate(tempRange: 0...120, moistRange: 3...150),
            .ren: IdealClimate(tempRange: 7...99, moistRange: 15...1000),
            .gui: IdealClimate(tempRange: 3...130, moistRange: 10...1000),
        ]

        if let ideal = idealClimates[dmStem] {
            if currentTemp > ideal.tempRange.upperBound {
                ctx.addReason("Temp Too High (> \(ideal.tempRange.upperBound)): Fire is Ji God")
                ctx.addUnfav(.fire)
            } else if currentTemp < ideal.tempRange.lowerBound {
                ctx.addReason("Temp Too Low (< \(ideal.tempRange.lowerBound)): Fire is Useful God")
                ctx.addFav(.fire)
            }

            if currentMoist > ideal.moistRange.upperBound {
                ctx.addReason("Moist Too High (> \(ideal.moistRange.upperBound)): Water is Ji God")
                ctx.addUnfav(.water)
            } else if currentMoist < ideal.moistRange.lowerBound {
                ctx.addReason("Moist Too Low (< \(ideal.moistRange.lowerBound)): Water is Useful God")
                ctx.addFav(.water)
            }

            if ctx.favElements.isEmpty && ctx.unfavElements.isEmpty {
                ctx.addReason("Status: Climate Ideal")
            }
        } else {
            ctx.addReason("Error: No configuration found for Day Master \(dmStem.character)")
        }
    }
}

// MARK: - Internal Helper Structs

private struct TenGodRelations {
     static let allElements = FiveElements.allCases

     static func getParent(_ e: FiveElements) -> FiveElements {
         let index = allElements.firstIndex(of: e)!
         let targetIndex = (index - 1 + 5) % 5
         return allElements[targetIndex]
     }
     static func getChild(_ e: FiveElements) -> FiveElements {
         let index = allElements.firstIndex(of: e)!
         let targetIndex = (index + 1) % 5
         return allElements[targetIndex]
     }
     static func getControlled(_ e: FiveElements) -> FiveElements {
         let index = allElements.firstIndex(of: e)!
         let targetIndex = (index + 2) % 5
         return allElements[targetIndex]
     }
     static func getController(_ e: FiveElements) -> FiveElements {
         let index = allElements.firstIndex(of: e)!
         let targetIndex = (index - 2 + 5) % 5
         return allElements[targetIndex]
     }
     
     static func elementOf(_ god: TenGods, relativeTo dm: FiveElements) -> FiveElements {
         switch god {
         case .friend, .robWealth: return dm
         case .eatingGod, .hurtingOfficer: return getChild(dm)
         case .directWealth, .indirectWealth: return getControlled(dm)
         case .directOfficer, .sevenKillings: return getController(dm)
         case .directResource, .indirectResource: return getParent(dm)
         }
     }
}

private class AnalysisContext {
    let chart: FourPillars
    let dmElement: FiveElements
    let method: UsefulGodMethod
    
    let energies: [FiveElements: Double]
    let totalEnergy: Double
    let supportEnergy: Double
    let consumptionEnergy: Double
    
    // Relationships
    let parent: FiveElements    // Resource
    let child: FiveElements     // Output
    let controlled: FiveElements // Wealth
    let controller: FiveElements // Officer
    
    // State
    var reasons: [String] = []
    var favElements: Set<FiveElements> = []
    var unfavElements: Set<FiveElements> = []
    
    init(chart: FourPillars, method: UsefulGodMethod) {
        self.chart = chart
        self.method = method
        self.dmElement = chart.day.stem.value.fiveElement
        
        // Standard Relations
        self.parent = TenGodRelations.getParent(dmElement)
        self.child = TenGodRelations.getChild(dmElement)
        self.controlled = TenGodRelations.getControlled(dmElement)
        self.controller = TenGodRelations.getController(dmElement)
        
        // Energies
        self.energies = chart.elementStrengths
        self.totalEnergy = energies.values.reduce(0, +)
        self.supportEnergy = (energies[dmElement] ?? 0) + (energies[parent] ?? 0)
        self.consumptionEnergy = totalEnergy - supportEnergy
    }
    
    func addReason(_ text: String) {
        reasons.append(text)
    }
    
    func addFav(_ e: FiveElements) {
        favElements.insert(e)
    }
    
    func addUnfav(_ e: FiveElements) {
        unfavElements.insert(e)
    }
}

extension FourPillars {
    /// Performs a Useful God (Yong Shen) analysis on this chart using the Pattern method.
    public var usefulGodAnalysis: UsefulGodResult {
        return UsefulGodCalculator.analyze(self, method: .pattern)
    }

    /// Performs a Useful God (Yong Shen) analysis on this chart using the specified method.
    public func calculateUsefulGod(method: UsefulGodMethod) -> UsefulGodResult {
        return UsefulGodCalculator.analyze(self, method: method)
    }
}
