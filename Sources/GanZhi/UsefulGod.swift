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
        var reasons: [String] = []

        let dmStem = chart.day.stem.value
        let dmElement = dmStem.fiveElement

        let allElements = FiveElements.allCases

        func getParent(_ e: FiveElements) -> FiveElements {
            // Wood(0) <- Water(4)
            let index = allElements.firstIndex(of: e)!
            let targetIndex = (index - 1 + 5) % 5
            return allElements[targetIndex]
        }
        func getChild(_ e: FiveElements) -> FiveElements {
            // Wood(0) -> Fire(1)
            let index = allElements.firstIndex(of: e)!
            let targetIndex = (index + 1) % 5
            return allElements[targetIndex]
        }
        func getControlled(_ e: FiveElements) -> FiveElements {
            // Wood(0) -> Earth(2)
            let index = allElements.firstIndex(of: e)!
            let targetIndex = (index + 2) % 5
            return allElements[targetIndex]
        }
        func getController(_ e: FiveElements) -> FiveElements {
            // Wood(0) <- Metal(3)
            let index = allElements.firstIndex(of: e)!
            let targetIndex = (index - 2 + 5) % 5
            return allElements[targetIndex]
        }

        let parent = getParent(dmElement)  // Resource (生我)
        let child = getChild(dmElement)  // Output (我生)
        let controlled = getControlled(dmElement)  // Wealth (我克)
        // Officer (克我) is implicitly part of consumption calc but variable not needed explicitly for logic

        // 1. Calculate Energies
        let energies = chart.elementStrengths

        // 2. Calculate Support vs Consumption
        // Support (生扶) = DM Element + Parent Element
        let supportEnergy = (energies[dmElement] ?? 0) + (energies[parent] ?? 0)

        // Consumption (消耗) = Total - Support
        let totalEnergy = energies.values.reduce(0, +)
        let consumptionEnergy = totalEnergy - supportEnergy

        reasons.append("Method: \(method == .pattern ? "Pattern (Ge Ju)" : "Wang Shuai")")
        reasons.append(
            "Five Element Energies: \(energies.map { "\($0.key.description):\($0.value)" }.joined(separator: ", "))"
        )
        reasons.append("Support (Self+Resource): \(String(format: "%.2f", supportEnergy))")
        reasons.append(
            "Consumption (Output+Wealth+Officer): \(String(format: "%.2f", consumptionEnergy))")

        var favElements: Set<FiveElements> = []
        var unfavElements: Set<FiveElements> = []

        func elementOf(_ god: TenGods, relativeTo dm: FiveElements) -> FiveElements {
            switch god {
            case .friend, .robWealth: return dm
            case .eatingGod, .hurtingOfficer: return getChild(dm)
            case .directWealth, .indirectWealth: return getControlled(dm)
            case .directOfficer, .sevenKillings: return getController(dm)
            case .directResource, .indirectResource: return getParent(dm)
            }
        }

        // Shared Fu Yi Logic (Too Weak / Too Strong)
        // Returns true if handled
        func applyFuYiLogic() -> Bool {
            if consumptionEnergy > 2 * supportEnergy {
                reasons.append("Status: Too Weak (Consumption > 2 * Support)")
                reasons.append("Useful God: Resource (生我者) [\(parent.description)]")
                reasons.append("Ji God: Wealth (我克者) [\(controlled.description)]")

                favElements.insert(parent)
                unfavElements.insert(controlled)
                return true

            } else if supportEnergy > 2 * consumptionEnergy {
                reasons.append("Status: Too Strong (Support > 2 * Consumption)")
                reasons.append(
                    "Useful God: Output (我生者) [\(child.description)] & Wealth (我克者) [\(controlled.description)]"
                )
                reasons.append("Ji God: Resource (生我者) [\(parent.description)]")

                favElements.insert(child)
                favElements.insert(controlled)
                unfavElements.insert(parent)
                return true
            }
            return false
        }

        // Determine Pattern (Commonly needed but maybe only for Pattern Method)
        let pattern = chart.determinePattern()
        let patternTenGod = pattern.tenGod

        func createResult(reasons: [String], fav: Set<FiveElements>, unfav: Set<FiveElements>, dm: FiveElements) -> UsefulGodResult {
            var favGods: Set<TenGods> = []
            var unfavGods: Set<TenGods> = []

            func godsOf(_ element: FiveElements) -> [TenGods] {
                var list: [TenGods] = []
                for god in TenGods.allCases {
                    if elementOf(god, relativeTo: dm) == element {
                        list.append(god)
                    }
                }
                return list
            }

            for elm in fav {
                favGods.formUnion(godsOf(elm))
            }
            for elm in unfav {
                unfavGods.formUnion(godsOf(elm))
            }

            // Method-specific exclusions (Pattern Method)
            if method == .pattern {
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
                favorableElements: Array(fav).sorted(by: { $0.rawValue < $1.rawValue }),
                unfavorableElements: Array(unfav).sorted(by: { $0.rawValue < $1.rawValue }),
                description: reasons.joined(separator: "\n")
            )
        }

        // 3. Logic Branching

        switch method {
        case .pattern:
            let officer = getController(dmElement)
            
            if pattern.method == .followSevenKillings {
                reasons.append("Status: Follow Seven Killings (从杀格)")
                favElements.insert(controlled)
                favElements.insert(officer)
                unfavElements.insert(child)
                unfavElements.insert(parent)
                
                reasons.append("Useful God: Wealth & Officer [\(controlled.description), \(officer.description)]")
                reasons.append("Ji God: Output & Resource [\(child.description), \(parent.description)]")
                
                return createResult(reasons: reasons, fav: favElements, unfav: unfavElements, dm: dmElement)
            } else if pattern.method == .followWealth {
                reasons.append("Status: Follow Wealth (从财格)")
                favElements.insert(child)
                favElements.insert(controlled)
                favElements.insert(officer)
                unfavElements.insert(dmElement)
                unfavElements.insert(parent)
                
                reasons.append("Useful God: Output, Wealth & Officer [\(child.description), \(controlled.description), \(officer.description)]")
                reasons.append("Ji God: Peer & Resource [\(dmElement.description), \(parent.description)]")
                
                return createResult(reasons: reasons, fav: favElements, unfav: unfavElements, dm: dmElement)
            } else if pattern.method == .followChild {
                reasons.append("Status: Follow Child (从儿格)")
                favElements.insert(controlled)
                favElements.insert(child)
                favElements.insert(dmElement)
                unfavElements.insert(parent)
                unfavElements.insert(officer)
                
                reasons.append("Useful God: Wealth, Output & Peer [\(controlled.description), \(child.description), \(dmElement.description)]")
                reasons.append("Ji God: Resource & Officer [\(parent.description), \(officer.description)]")
                
                return createResult(reasons: reasons, fav: favElements, unfav: unfavElements, dm: dmElement)
            } else if pattern.method == .quZhi || pattern.method == .yanShang || pattern.method == .jiaSe || pattern.method == .congGe {
                reasons.append("Status: Special Pattern (\(pattern.method.description))")
                favElements.insert(child)        // Output / 食伤
                favElements.insert(dmElement)   // Peer / 比劫
                favElements.insert(parent)      // Resource / 印
                unfavElements.insert(officer)  // Officer / 官杀
                unfavElements.insert(controlled) // Wealth / 财星
                
                reasons.append("Useful God: Output, Peer & Resource [\(child.description), \(dmElement.description), \(parent.description)]")
                reasons.append("Ji God: Officer & Wealth [\(officer.description), \(controlled.description)]")
                
                return createResult(reasons: reasons, fav: favElements, unfav: unfavElements, dm: dmElement)
            } else if pattern.method == .runXia {
                reasons.append("Status: Special Pattern (润下格)")
                favElements.insert(child)        // Output / 食伤
                favElements.insert(controlled)  // Wealth / 财星
                favElements.insert(parent)      // Resource / 印
                unfavElements.insert(officer)  // Officer / 官杀
                
                reasons.append("Useful God: Output, Wealth & Resource [\(child.description), \(controlled.description), \(parent.description)]")
                reasons.append("Ji God: Officer [\(officer.description)]")
                
                return createResult(reasons: reasons, fav: favElements, unfav: unfavElements, dm: dmElement)
            }

            // --- New Logic Start ---

            // 1. Calculate Percentages
            let eResource = energies[parent] ?? 0
            let eSelf = energies[dmElement] ?? 0
            let eOutput = energies[child] ?? 0
            let eWealth = energies[controlled] ?? 0
            let eOfficer = energies[getController(dmElement)] ?? 0  // Controller

            let pctResource = totalEnergy > 0 ? eResource / totalEnergy : 0
            let pctSelf = totalEnergy > 0 ? eSelf / totalEnergy : 0
            let eConsumption = eOutput + eWealth + eOfficer
            let pctConsumption = totalEnergy > 0 ? eConsumption / totalEnergy : 0

            reasons.append(
                "Energy Division: Resource \(String(format: "%.1f%%", pctResource*100)), Self \(String(format: "%.1f%%", pctSelf*100)), Consumption \(String(format: "%.1f%%", pctConsumption*100))"
            )

            let pTenGod = patternTenGod  // Use existing variable name
            let pMethod = pattern.method

            func getElementsFor(pTenGod: TenGods, pMethod: Pattern.DeterminationMethod) -> (fav: Set<FiveElements>, unfav: Set<FiveElements>, reasons: [String]) {
                var fav: Set<FiveElements> = []
                var unfav: Set<FiveElements> = []
                var r: [String] = []

                if pctResource > 0.5 {
                    r.append("Pattern Logic (\(pTenGod.description)): Resource Dominant (>50%)")
                    unfav.insert(parent)
                    if pctConsumption > pctSelf {
                        r.append("Useful God: Self (Consumption > Self) [\(dmElement.description)]")
                        fav.insert(dmElement)
                    } else {
                        if eOutput >= eOfficer {
                            r.append("Useful God: Output (Output >= Officer) [\(child.description)]")
                            fav.insert(child)
                        } else {
                            r.append("Useful God: Officer (Officer > Output) [\(getController(dmElement).description)]")
                            fav.insert(getController(dmElement))
                        }
                    }
                } else if pctSelf > 0.5 {
                    r.append("Pattern Logic (\(pTenGod.description)): Self Dominant (>50%)")
                    unfav.insert(dmElement)
                    if pMethod == .yangRen || pMethod == .jianLu || pMethod == .yueRen
                        || [.directResource, .indirectResource, .directOfficer, .sevenKillings]
                            .contains(pTenGod)
                    {
                        let officer = getController(dmElement)
                        r.append("Useful God: Officer (Pattern Requirement) [\(officer.description)]")
                        fav.insert(officer)
                    } else if [.eatingGod, .hurtingOfficer].contains(pTenGod) {
                        r.append("Useful God: Output (Pattern Requirement) [\(child.description)]")
                        fav.insert(child)
                    } else {
                        if [.directWealth, .indirectWealth].contains(pTenGod) {
                            r.append("Useful God: Wealth (Pattern Requirement) [\(controlled.description)]")
                            fav.insert(controlled)
                        } else {
                            r.append("Useful God: Max Consumption (Fallback)")
                            let maxCons = [
                                (child, eOutput), (controlled, eWealth),
                                (getController(dmElement), eOfficer),
                            ]
                            .max(by: { $0.1 < $1.1 })!.0
                            fav.insert(maxCons)
                        }
                    }
                } else {
                    let selfTotalPct = pctSelf + pctResource
                    r.append("Pattern Logic (\(pTenGod.description)): Normal/Balanced (Self+Res: \(String(format: "%.1f%%", selfTotalPct*100)))")
                    if [.directResource, .indirectResource].contains(pTenGod) {
                        let parts = [
                            ("Resource", pctResource), ("Self", pctSelf),
                            ("Consumption", pctConsumption),
                        ]
                        let strongestPart = parts.max(by: { $0.1 < $1.1 })!.0
                        let weakestPart = parts.min(by: { $0.1 < $1.1 })!.0
                        if strongestPart == "Resource" && weakestPart == "Consumption" {
                            r.append("Useful God: Output (Resource is strongest part) [\(child.description)]")
                            fav.insert(child)
                            r.append("Ji God: Resource (Strongest part) [\(parent.description)]")
                            unfav.insert(parent)
                        } else {
                            let target: FiveElements
                            if eOfficer >= eOutput {
                                target = getController(dmElement)
                                r.append("Useful God: Officer (Officer >= Output) [\(target.description)]")
                            } else {
                                target = child
                                r.append("Useful God: Output (Output > Officer) [\(target.description)]")
                            }
                            fav.insert(target)
                            unfav.insert(getController(target))
                            r.append("Ji God: Controller of Useful [\(getController(target).description)]")
                        }
                    } else if [.directWealth, .indirectWealth].contains(pTenGod) {
                        if pctConsumption > selfTotalPct {
                            r.append("Useful God: Peer (Cons > Self+Res) [\(dmElement.description)]")
                            r.append("Ji God: Officer [\(getController(dmElement).description)]")
                            fav.insert(dmElement)
                            unfav.insert(getController(dmElement))
                        } else {
                            let target: FiveElements
                            if eWealth <= eOutput {
                                target = controlled
                                r.append("Useful God: Wealth (Wealth <= Output) [\(target.description)]")
                            } else {
                                target = child
                                r.append("Useful God: Output (Output < Wealth) [\(target.description)]")
                            }
                            fav.insert(target)
                            r.append("Ji God: Resource [\(parent.description)]")
                            unfav.insert(parent)
                        }
                    } else if [.directOfficer, .sevenKillings].contains(pTenGod) {
                        let candidates = [(child, eOutput), (dmElement, eSelf), (parent, eResource)]
                        let winner = candidates.max(by: { $0.1 < $1.1 })!.0
                        r.append("Useful God: Max(Output, Peer, Resource) [\(winner.description)]")
                        fav.insert(winner)
                        let ji = getController(winner)
                        r.append("Ji God: Controller of Useful [\(ji.description)]")
                        unfav.insert(ji)
                    } else if [.eatingGod, .hurtingOfficer].contains(pTenGod) {
                        if pctConsumption > 2 * selfTotalPct {
                            r.append("Useful God: Resource & Peer (Cons > 2*(Self+Res))")
                            fav.insert(parent)
                            fav.insert(dmElement)
                            let maxCons = [
                                (child, eOutput), (controlled, eWealth),
                                (getController(dmElement), eOfficer),
                            ]
                            .max(by: { $0.1 < $1.1 })!.0
                            r.append("Ji God: Max Consumption [\(maxCons.description)]")
                            unfav.insert(maxCons)
                        } else {
                            let winner: FiveElements
                            if eWealth >= eOfficer {
                                winner = controlled
                                r.append("Useful God: Wealth (Wealth >= Officer) [\(winner.description)]")
                            } else {
                                winner = getController(dmElement)
                                r.append("Useful God: Officer (Officer > Wealth) [\(winner.description)]")
                            }
                            fav.insert(winner)
                            let ji = getController(winner)
                            r.append("Ji God: Controller of Useful [\(ji.description)]")
                            unfav.insert(ji)
                        }
                    } else {
                        r.append("Status: Blade/Luck/Other")
                        r.append("Ji God: Peer [\(dmElement.description)]")
                        unfav.insert(dmElement)
                        let maxCons = [
                            (child, eOutput), (controlled, eWealth),
                            (getController(dmElement), eOfficer),
                        ]
                        .max(by: { $0.1 < $1.1 })!.0
                        r.append("Useful God: Max Consumption [\(maxCons.description)]")
                        fav.insert(maxCons)
                    }
                }
                return (fav, unfav, r)
            }

            var (primaryFav, primaryUnfav, primaryReasons) = getElementsFor(pTenGod: pTenGod, pMethod: pMethod)
            reasons.append(contentsOf: primaryReasons)
            
            if let auxTenGod = pattern.auxiliaryTenGod, let auxMethod = pattern.auxiliaryMethod {
                reasons.append("--- Auxiliary Pattern detected: \(auxTenGod.description) ---")
                let (auxFav, auxUnfav, auxReasons) = getElementsFor(pTenGod: auxTenGod, pMethod: auxMethod)
                reasons.append(contentsOf: auxReasons)
                
                primaryFav.formUnion(auxFav)
                primaryUnfav.formUnion(auxUnfav)
                
                let intersection = primaryFav.intersection(primaryUnfav)
                if !intersection.isEmpty {
                    reasons.append("Conflicting elements removed: \(intersection.map { $0.description }.joined(separator: ", "))")
                    primaryFav.subtract(intersection)
                    primaryUnfav.subtract(intersection)
                }
            }
            
            favElements = primaryFav
            unfavElements = primaryUnfav

        case .wangShuai:
            // 1. Calculate Percentages
            // 2. Check for Dominant (>55%)
            // 3. Check for Conflict (Two opposing both 35-50%)
            // 4. Fu Yi
            // 5. Empty

            var dominantElement: FiveElements? = nil
            var conflictPair: (FiveElements, FiveElements)? = nil  // (Attacker, Defender)

            // Check Dominant
            for e in allElements {
                let eEnergy = energies[e] ?? 0
                let percentage = eEnergy / totalEnergy
                if percentage > 0.55 {
                    dominantElement = e
                    break
                }
            }

            // If no dominant, check Conflict
            if dominantElement == nil {
                for e1 in allElements {
                    let p1 = (energies[e1] ?? 0) / totalEnergy
                    guard p1 >= 0.35 && p1 <= 0.50 else { continue }

                    let e2 = getControlled(e1)  // e1 controls e2
                    let p2 = (energies[e2] ?? 0) / totalEnergy

                    if p2 >= 0.35 && p2 <= 0.50 {
                        conflictPair = (e1, e2)
                        break
                    }
                }
            }

            if let dom = dominantElement {
                reasons.append("Status: Dominant Element (Zhuan Wang)")
                reasons.append("Dominant: \(dom.description) (>55%)")

                let usefulSelf = dom
                let usefulSource = getParent(dom)
                let jiController = getController(dom)  // Controls Dominant

                reasons.append(
                    "Useful God: Dominant [\(usefulSelf.description)] & Source [\(usefulSource.description)]"
                )
                reasons.append("Ji God: Controller [\(jiController.description)]")

                favElements.insert(usefulSelf)
                favElements.insert(usefulSource)
                unfavElements.insert(jiController)

            } else if let (attacker, defender) = conflictPair {
                reasons.append("Status: Conflict / Tong Guan (Bridge needed)")
                reasons.append(
                    "Conflict: \(attacker.description) controls \(defender.description) (Both 35-50%)"
                )

                let bridge = getChild(attacker)  // Bridge between Attacker and Defender (Attacker -> Bridge -> Defender)
                // e.g. Wood -> Fire -> Earth. Wood controls Earth. Bridge is Fire.

                let jiElm = getController(bridge)  // Controls the bridge

                reasons.append("Useful God: Bridge [\(bridge.description)]")
                reasons.append("Ji God: Controller of Bridge [\(jiElm.description)]")

                favElements.insert(bridge)
                unfavElements.insert(jiElm)

            } else if applyFuYiLogic() {
                // Handled by shared logic
            } else {
                reasons.append("Status: Balanced / Other")
                reasons.append("Advise: No specific Useful/Ji God found by Wang Shuai method.")
                // No useful/ji gods set (Empty)
            }

        case .tiaoHou:
            // 1. Get Thermal Balance
            let tb = chart.thermalBalance
            let currentTemp = tb.temperature
            let currentMoist = tb.moisture

            reasons.append("Method: Tiao Hou (Climate Adjustment)")
            reasons.append(
                "Current: Temp \(String(format: "%.2f", currentTemp)), Humid \(String(format: "%.2f", currentMoist))"
            )

            // 2. Configuration for Ideal Climate by Day Master Stem
            struct IdealClimate {
                let tempRange: ClosedRange<Double>
                let moistRange: ClosedRange<Double>
            }

            // TODO: User to fill in optimal ranges for each Day Master
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
                // 3. Logic Check

                // Temperature
                if currentTemp > ideal.tempRange.upperBound {
                    // Too Hot -> Fire is Ji
                    reasons.append(
                        "Temp Too High (> \(ideal.tempRange.upperBound)): Fire is Ji God")
                    unfavElements.insert(.fire)
                } else if currentTemp < ideal.tempRange.lowerBound {
                    // Too Cold -> Fire is Useful
                    reasons.append(
                        "Temp Too Low (< \(ideal.tempRange.lowerBound)): Fire is Useful God")
                    favElements.insert(.fire)
                }

                // Moisture
                if currentMoist > ideal.moistRange.upperBound {
                    // Too Wet -> Water is Ji
                    reasons.append(
                        "Moist Too High (> \(ideal.moistRange.upperBound)): Water is Ji God")
                    unfavElements.insert(.water)
                } else if currentMoist < ideal.moistRange.lowerBound {
                    // Too Dry -> Water is Useful
                    reasons.append(
                        "Moist Too Low (< \(ideal.moistRange.lowerBound)): Water is Useful God")
                    favElements.insert(.water)
                }

                if favElements.isEmpty && unfavElements.isEmpty {
                    reasons.append("Status: Climate Ideal")
                }

            } else {
                reasons.append("Error: No configuration found for Day Master \(dmStem.character)")
            }
        }

        return createResult(reasons: reasons, fav: favElements, unfav: unfavElements, dm: dmElement)
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
