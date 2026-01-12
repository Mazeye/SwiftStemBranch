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

        // 3. Logic Branching

        switch method {
        case .pattern:
            // Check for Cong Ge (Follow Pattern)
            // Criteria:
            // 1. Day Master is Yin.
            // 2. Day Master is Rootless (Stem not in Branch Hidden Stems).
            // 3. Pattern is Wealth, Officer/Killing, or Output (Eating/Hurting).
            // 4. Pattern Element Energy > 3.5 * Support Energy.

            let dmStem = chart.day.stem.value
            let isYinDM = (dmStem.yinYang == .yin)

            var isRootless = true
            let branches = [
                chart.year.branch, chart.month.branch, chart.day.branch, chart.hour.branch,
            ]
            for branch in branches {
                let hidden = branch.hiddenStems
                if hidden.contains(dmStem) {
                    isRootless = false
                    break
                }
            }

            let validCongGeTypes: Set<TenGods> = [
                .directWealth, .indirectWealth,
                .directOfficer, .sevenKillings,
                .eatingGod, .hurtingOfficer,
            ]
            let isCongGeType = validCongGeTypes.contains(patternTenGod)

            let patternElement = elementOf(patternTenGod, relativeTo: dmElement)
            let patternEnergy = energies[patternElement] ?? 0

            // user specified "3.5 times" logic
            let isDominantPattern = patternEnergy > 3.5 * supportEnergy

            if isYinDM && isRootless && isCongGeType && isDominantPattern {
                reasons.append("Status: Cong Ge (Follow Pattern)")
                reasons.append(
                    "Criteria Met: Yin DM, Rootless, Pattern \(pattern.tenGod.name), Energy > 3.5x Support"
                )

                let usefulSource = getParent(patternElement)
                let usefulSelf = patternElement
                let jiController = getController(patternElement)

                reasons.append(
                    "Useful God: Source of Pattern [\(usefulSource.description)] & Pattern Element [\(usefulSelf.description)]"
                )
                reasons.append("Ji God: Controller of Pattern [\(jiController.description)]")

                favElements.insert(usefulSource)
                favElements.insert(usefulSelf)
                unfavElements.insert(jiController)
                // If Cong Ge is found, we return the result immediately.
                // The rest of the pattern logic should not apply.
                return UsefulGodResult(
                    yongShen: [],  // Ten Gods not specifically assigned for Cong Ge in this scope
                    jiShen: [],
                    favorableElements: Array(favElements),
                    unfavorableElements: Array(unfavElements),
                    description: reasons.joined(separator: "\n")
                )
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

            // Case 1: Resource > 50%
            if pctResource > 0.5 {
                reasons.append("Status: Resource Dominant (>50%)")
                reasons.append("Ji God: Resource [\(parent.description)]")
                unfavElements.insert(parent)

                if pctConsumption > pctSelf {
                    // Consumption > Self -> Useful: Self (Friend/Rob)
                    reasons.append(
                        "Useful God: Self (Consumption > Self) [\(dmElement.description)]")
                    favElements.insert(dmElement)
                } else {
                    // Self > Consumption -> Useful: More of Output vs Officer
                    if eOutput >= eOfficer {
                        reasons.append(
                            "Useful God: Output (Output >= Officer) [\(child.description)]")
                        favElements.insert(child)
                    } else {
                        reasons.append(
                            "Useful God: Officer (Officer > Output) [\(getController(dmElement).description)]"
                        )
                        favElements.insert(getController(dmElement))
                    }
                }
            }
            // Case 2: Self > 50%
            else if pctSelf > 0.5 {
                reasons.append("Status: Self Dominant (>50%)")
                reasons.append("Ji God: Self [\(dmElement.description)]")
                unfavElements.insert(dmElement)

                // Pattern Logic
                if pMethod == .yangRen || pMethod == .jianLu || pMethod == .yueRen
                    || [.directResource, .indirectResource, .directOfficer, .sevenKillings]
                        .contains(pTenGod)
                {
                    // "印格用官杀，官杀格用官杀，羊刃建禄用官杀"
                    let officer = getController(dmElement)
                    reasons.append(
                        "Useful God: Officer (Pattern Requirement) [\(officer.description)]")
                    favElements.insert(officer)
                } else if [.eatingGod, .hurtingOfficer].contains(pTenGod) {
                    // "食伤格用食伤"
                    reasons.append(
                        "Useful God: Output (Pattern Requirement) [\(child.description)]")
                    favElements.insert(child)
                } else {
                    // Fallback for Wealth or others not strictly listed: Max of Consumption
                    // Assuming Wealth checks Wealth
                    if [.directWealth, .indirectWealth].contains(pTenGod) {
                        reasons.append(
                            "Useful God: Wealth (Pattern Requirement) [\(controlled.description)]")
                        favElements.insert(controlled)
                    } else {
                        reasons.append("Useful God: Max Consumption (Fallback)")
                        // Simple fallback: Pick max of Output/Wealth/Officer
                        let maxCons = [
                            (child, eOutput), (controlled, eWealth),
                            (getController(dmElement), eOfficer),
                        ]
                        .max(by: { $0.1 < $1.1 })!.0
                        favElements.insert(maxCons)
                    }
                }
            }
            // Case 3: Balanced / Others
            else {
                let selfTotalPct = pctSelf + pctResource
                reasons.append(
                    "Status: Normal/Balanced (Self+Res: \(String(format: "%.1f%%", selfTotalPct*100)))"
                )
                reasons.append("Pattern: \(pattern.description)")

                // 3.1 Resource Pattern
                if [.directResource, .indirectResource].contains(pTenGod) {
                    // Refined Logic Check: compare Resource, Self, Consumption
                    // If Resource matches the strongest part, use Output, Ji Resource.

                    let parts = [
                        ("Resource", pctResource), ("Self", pctSelf),
                        ("Consumption", pctConsumption),
                    ]
                    let strongestPart = parts.max(by: { $0.1 < $1.1 })!.0
                    let weakestPart = parts.min(by: { $0.1 < $1.1 })!.0

                    if strongestPart == "Resource" && weakestPart == "Consumption" {
                        reasons.append(
                            "Useful God: Output (Resource is strongest part) [\(child.description)]"
                        )
                        favElements.insert(child)
                        reasons.append("Ji God: Resource (Strongest part) [\(parent.description)]")
                        unfavElements.insert(parent)
                    } else {
                        // Original Logic
                        // Useful: Stronger of Officer / Output
                        // Ji: Controller of Useful
                        let target: FiveElements
                        if eOfficer >= eOutput {
                            target = getController(dmElement)
                            reasons.append(
                                "Useful God: Officer (Officer >= Output) [\(target.description)]")
                        } else {
                            target = child
                            reasons.append(
                                "Useful God: Output (Output > Officer) [\(target.description)]")
                        }
                        favElements.insert(target)
                        unfavElements.insert(getController(target))
                        reasons.append(
                            "Ji God: Controller of Useful [\(getController(target).description)]")
                    }
                }
                // 3.2 Wealth Pattern
                else if [.directWealth, .indirectWealth].contains(pTenGod) {
                    // If Cons > SelfTotal -> Useful: Peer, Ji: Officer
                    // Else -> Useful: Min(Wealth, Output), Ji: Resource

                    if pctConsumption > selfTotalPct {
                        reasons.append(
                            "Useful God: Peer (Cons > Self+Res) [\(dmElement.description)]")
                        reasons.append("Ji God: Officer [\(getController(dmElement).description)]")
                        favElements.insert(dmElement)
                        unfavElements.insert(getController(dmElement))
                    } else {
                        // Smaller of Wealth vs Output
                        let target: FiveElements
                        if eWealth <= eOutput {
                            target = controlled
                            reasons.append(
                                "Useful God: Wealth (Wealth <= Output) [\(target.description)]")
                        } else {
                            target = child
                            reasons.append(
                                "Useful God: Output (Output < Wealth) [\(target.description)]")
                        }
                        favElements.insert(target)
                        reasons.append("Ji God: Resource [\(parent.description)]")
                        unfavElements.insert(parent)
                    }
                }
                // 3.3 Officer Pattern
                else if [.directOfficer, .sevenKillings].contains(pTenGod) {
                    // Useful: Max(Output, Peer, Resource)
                    // Ji: Controller of Useful
                    let candidates = [
                        (child, eOutput),
                        (dmElement, eSelf),
                        (parent, eResource),
                    ]
                    let winner = candidates.max(by: { $0.1 < $1.1 })!.0
                    reasons.append(
                        "Useful God: Max(Output, Peer, Resource) [\(winner.description)]")
                    favElements.insert(winner)

                    let ji = getController(winner)
                    reasons.append("Ji God: Controller of Useful [\(ji.description)]")
                    unfavElements.insert(ji)
                }
                // 3.4 Output Pattern
                else if [.eatingGod, .hurtingOfficer].contains(pTenGod) {
                    // If Cons > 2 * SelfTotal -> Useful: Resource, Peer. Ji: Max(Consumption)
                    // Else -> Useful: Max(Wealth, Officer). Ji: Controller of Useful

                    if pctConsumption > 2 * selfTotalPct {
                        reasons.append("Useful God: Resource & Peer (Cons > 2*(Self+Res))")
                        favElements.insert(parent)
                        favElements.insert(dmElement)

                        // Ji: Max(Consumption)
                        let maxCons = [
                            (child, eOutput), (controlled, eWealth),
                            (getController(dmElement), eOfficer),
                        ]
                        .max(by: { $0.1 < $1.1 })!.0
                        reasons.append("Ji God: Max Consumption [\(maxCons.description)]")
                        unfavElements.insert(maxCons)
                    } else {
                        // Useful: Max(Wealth, Officer)
                        let winner: FiveElements
                        if eWealth >= eOfficer {
                            winner = controlled
                            reasons.append(
                                "Useful God: Wealth (Wealth >= Officer) [\(winner.description)]")
                        } else {
                            winner = getController(dmElement)
                            reasons.append(
                                "Useful God: Officer (Officer > Wealth) [\(winner.description)]")
                        }
                        favElements.insert(winner)

                        let ji = getController(winner)
                        reasons.append("Ji God: Controller of Useful [\(ji.description)]")
                        unfavElements.insert(ji)
                    }
                }
                // 3.5 Blade/Luck/Others
                else {
                    // "羊刃月刃和建禄的情况，忌神为比劫，用神为消耗里面最大的那个"
                    // Also covers default fallback
                    reasons.append("Status: Blade/Luck/Other")
                    reasons.append("Ji God: Peer [\(dmElement.description)]")
                    unfavElements.insert(dmElement)

                    let maxCons = [
                        (child, eOutput), (controlled, eWealth),
                        (getController(dmElement), eOfficer),
                    ]
                    .max(by: { $0.1 < $1.1 })!.0
                    reasons.append("Useful God: Max Consumption [\(maxCons.description)]")
                    favElements.insert(maxCons)
                }
            }

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

        // Convert Elements to Representative Ten Gods for Output
        var favGods: Set<TenGods> = []
        var unfavGods: Set<TenGods> = []

        func godsOf(_ element: FiveElements) -> [TenGods] {
            var list: [TenGods] = []
            for god in TenGods.allCases {
                if elementOf(god, relativeTo: dmElement) == element {
                    list.append(god)
                }
            }
            return list
        }

        for elm in favElements {
            favGods.formUnion(godsOf(elm))
        }
        for elm in unfavElements {
            unfavGods.formUnion(godsOf(elm))
        }

        // Final Adjustments based on User Feedback (APPLIES TO BOTH METHODS FOR CONSISTENCY, OR ONLY PATTERN?)
        // User request for Wang Shuai #1-5 didn't mention exclusions.
        // Existing exclusions were: "Eating God Pattern avoids Indirect Resource".
        // These are Pattern-specific "Method specific exclusions".
        // Wang Shuai logic is purely elemental.
        // So I will APPLY exclusions ONLY if method == .pattern.

        if method == .pattern {
            // 1. Eating God Pattern: Do not suggest Indirect Resource (Owl).
            if patternTenGod == .eatingGod {
                if favGods.contains(.indirectResource) {
                    favGods.remove(.indirectResource)
                }
            }

            // 2. Hurting Officer Pattern: Do not suggest Direct Officer.
            if patternTenGod == .hurtingOfficer {
                if favGods.contains(.directOfficer) {
                    favGods.remove(.directOfficer)
                }
            }

            // 3. Direct Officer Pattern: Do not suggest Hurting Officer.
            if patternTenGod == .directOfficer {
                if favGods.contains(.hurtingOfficer) {
                    favGods.remove(.hurtingOfficer)
                }
            }
        }

        return UsefulGodResult(
            yongShen: Array(favGods).sorted(by: { $0.rawValue < $1.rawValue }),
            jiShen: Array(unfavGods).sorted(by: { $0.rawValue < $1.rawValue }),
            favorableElements: Array(favElements).sorted(by: { $0.rawValue < $1.rawValue }),
            unfavorableElements: Array(unfavElements).sorted(by: { $0.rawValue < $1.rawValue }),
            description: reasons.joined(separator: "\n")
        )
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
