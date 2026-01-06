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

/// A decoupled service to calculate the Useful God (Yong Shen) and Ji Shen.
public struct UsefulGodCalculator {
    
    /// Analyzes the Four Pillars to determine the Useful God based on Custom User Logic.
    ///
    /// Logic Steps:
    /// 1. Calculate weighted Five Element energies (same logic as Sample/main.swift).
    /// 2. Determine Support (Same + Parent) vs Consumption (Child + Controlled + Controller).
    /// 3. Compare Support vs Consumption:
    ///    - If Consumption > 2 * Support: Too Weak. Useful = Resource (Parent). Ji = Wealth (Controlled).
    ///    - If Support > 2 * Consumption: Too Strong. Useful = Output (Child) + Wealth (Controlled). Ji = Resource (Parent).
    ///    - Else (Balanced): Useful = Pattern element. Ji = Element controlling Pattern element.
    public static func analyze(_ chart: FourPillars) -> UsefulGodResult {
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
        
        let parent = getParent(dmElement)       // Resource (生我)
        let child = getChild(dmElement)         // Output (我生)
        let controlled = getControlled(dmElement) // Wealth (我克)
        // Officer (克我) is implicitly part of consumption calc but variable not needed explicitly for logic
        
        // 1. Calculate Energies
        let energies = chart.elementStrengths
        
        // 2. Calculate Support vs Consumption
        // Support (生扶) = DM Element + Parent Element
        let supportEnergy = (energies[dmElement] ?? 0) + (energies[parent] ?? 0)
        
        // Consumption (消耗) = Total - Support
        let totalEnergy = energies.values.reduce(0, +)
        let consumptionEnergy = totalEnergy - supportEnergy
        
        reasons.append("Five Element Energies: \(energies.map { "\($0.key.description):\($0.value)" }.joined(separator: ", "))")
        reasons.append("Support (Self+Resource): \(String(format: "%.2f", supportEnergy))")
        reasons.append("Consumption (Output+Wealth+Officer): \(String(format: "%.2f", consumptionEnergy))")
        
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

        // 3. Logic Branching
        
        // Check for Cong Ge (Follow Pattern)
        // Criteria:
        // 1. Day Master is Yin.
        // 2. Day Master is Rootless (Stem not in Branch Hidden Stems).
        // 3. Pattern is Wealth, Officer/Killing, or Output (Eating/Hurting).
        // 4. Pattern Element Energy > 3.5 * Support Energy.
        
        let isYinDM = (dmStem.yinYang == .yin)
        
        var isRootless = true
        let branches = [chart.year.branch, chart.month.branch, chart.day.branch, chart.hour.branch]
        for branch in branches {
            let hidden = branch.hiddenStems
            if hidden.contains(dmStem) {
                isRootless = false
                break
            }
        }
        
        let pattern = chart.determinePattern()
        let patternTenGod = pattern.tenGod
        let validCongGeTypes: Set<TenGods> = [
            .directWealth, .indirectWealth,
            .directOfficer, .sevenKillings,
            .eatingGod, .hurtingOfficer
        ]
        let isCongGeType = validCongGeTypes.contains(patternTenGod)
        
        let patternElement = elementOf(patternTenGod, relativeTo: dmElement)
        let patternEnergy = energies[patternElement] ?? 0
        
        // user specified "3.5 times" logic
        // "格局主神所在五行的力量是生扶力量的3.5倍以上"
        let isDominantPattern = patternEnergy > 3.5 * supportEnergy
        
        if isYinDM && isRootless && isCongGeType && isDominantPattern {
            reasons.append("Status: Cong Ge (Follow Pattern)")
            reasons.append("Criteria Met: Yin DM, Rootless, Pattern \(pattern.tenGod.name), Energy > 3.5x Support")
            
            // Useful: Create Pattern Element (Source) and Pattern Element itself.
            // Ji: Controls Pattern Element.
            
            let usefulSource = getParent(patternElement)
            let usefulSelf = patternElement
            let jiController = getController(patternElement) // Controls pattern
            
            reasons.append("Useful God: Source of Pattern [\(usefulSource.description)] & Pattern Element [\(usefulSelf.description)]")
            reasons.append("Ji God: Controller of Pattern [\(jiController.description)]")
            
            favElements.insert(usefulSource)
            favElements.insert(usefulSelf)
            unfavElements.insert(jiController)
            
        } else if consumptionEnergy > 2 * supportEnergy {
            reasons.append("Status: Too Weak (Consumption > 2 * Support)")
            reasons.append("Useful God: Resource (生我者) [\(parent.description)]")
            reasons.append("Ji God: Wealth (我克者) [\(controlled.description)]")
            
            favElements.insert(parent)
            unfavElements.insert(controlled)
            
        } else if supportEnergy > 2 * consumptionEnergy {
            reasons.append("Status: Too Strong (Support > 2 * Consumption)")
            reasons.append("Useful God: Output (我生者) [\(child.description)] & Wealth (我克者) [\(controlled.description)]")
            reasons.append("Ji God: Resource (生我者) [\(parent.description)]")
            
            favElements.insert(child)
            favElements.insert(controlled)
            unfavElements.insert(parent)
            
        } else {
            reasons.append("Status: Balanced (Neither Extreme)")
            reasons.append("Pattern: \(pattern.description)")
            
            // Refined Logic for Balanced Case
            
            let pTenGod = pattern.tenGod
            let pMethod = pattern.method
            
            // 1. Yang Ren (Goat Blade)
            if pMethod == .yangRen {
                reasons.append("Type: Yang Ren (Goat Blade)")
                
                // Useful: Controlled by Officer/Killings (Controller of DM)
                // Ji: Friend/Rob Wealth (Same as DM)
                
                let usefulElm = getController(dmElement) // Officer/Seven Killings
                let usefulChild = getChild(dmElement) // Officer/Seven Killings
                let jiElm = dmElement // Friend/Rob
                
                reasons.append("Useful God: Officer/Killings (Control Blade) [\(usefulElm.description)]")
                reasons.append("Ji God: Peer (Strengthen Blade) [\(jiElm.description)]")
                
                favElements.insert(usefulElm)
                favElements.insert(usefulChild)
                unfavElements.insert(jiElm)
                
            } 
            // 2. Jian Lu (Thriving) or Yue Jie (Monthly Rob Wealth)
            // Jian Lu is .friend usually. Yue Jie is .robWealth (specifically .yueRen or general)
            else if pMethod == .jianLu || pMethod == .yueRen || pTenGod == .friend || pTenGod == .robWealth {
                 reasons.append("Type: Jian Lu / Yue Jie (Thriving/Monthly Rob)")
                 
                 // Useful: Wealth (Controlled by DM)
                 // Ji: Peer (Same as DM)
                 
                 let usefulElm = getControlled(dmElement) // Wealth
                 let jiElm = dmElement // Friend/Rob
                 
                 reasons.append("Useful God: Wealth (Use to nourish) [\(usefulElm.description)]")
                 reasons.append("Ji God: Peer (Competition) [\(jiElm.description)]")
                 
                 favElements.insert(usefulElm)
                 unfavElements.insert(jiElm)
            }
            // 3. Three Evil Gods (Xiao, Sha, Shang)
            // Indirect Resource, Seven Killings, Hurting Officer
            else if [.indirectResource, .sevenKillings, .hurtingOfficer].contains(pTenGod) {
                reasons.append("Type: Evil God (Xiao/Sha/Shang)")
                
                // Useful: Control the Evil God (Controller of Pattern Element)
                // Ji: Strengthen the Evil God (Source/Parent of Pattern Element)
                
                let patternElm = elementOf(pTenGod, relativeTo: dmElement)
                let usefulElm = getController(patternElm) // Controls Pattern
                let jiElm = getParent(patternElm) // Births Pattern
                
                reasons.append("Useful God: Control Evil Pattern [\(usefulElm.description)]")
                reasons.append("Ji God: Strength Evil Pattern [\(jiElm.description)]")
                
                favElements.insert(usefulElm)
                unfavElements.insert(jiElm)
            }
            // 4. Others (Good Gods: Officer, Wealth, Resource, Eating)
            else {
                reasons.append("Type: Good God (Officer/Wealth/Resource/Eating)")
                
                // Useful: Pattern Element + Source
                // Ji: Controller
                
                let usefulElm = elementOf(pTenGod, relativeTo: dmElement)
                let usefulParent = getParent(usefulElm)
                let jiElm = getController(usefulElm)
                
                reasons.append("Useful God: Pattern [\(usefulElm.description)] + Source [\(usefulParent.description)]")
                reasons.append("Ji God: Control Pattern [\(jiElm.description)]")
                
                favElements.insert(usefulElm)
                favElements.insert(usefulParent)
                unfavElements.insert(jiElm)
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
        
        // Final Adjustments based on User Feedback:
        // 1. Eating God Pattern: Do not suggest Indirect Resource (Owl).
        if patternTenGod == .eatingGod {
            if favGods.contains(.indirectResource) {
                // reasons.append("Exclusion: Eating God Pattern avoids Indirect Resource (Xiao).")
                favGods.remove(.indirectResource)
            }
        }
        
        // 2. Hurting Officer Pattern: Do not suggest Direct Officer.
        if patternTenGod == .hurtingOfficer {
            if favGods.contains(.directOfficer) {
                // reasons.append("Exclusion: Hurting Officer Pattern avoids Direct Officer.")
                favGods.remove(.directOfficer)
            }
        }
        
        // 3. Direct Officer Pattern: Do not suggest Hurting Officer.
        if patternTenGod == .directOfficer {
            if favGods.contains(.hurtingOfficer) {
                favGods.remove(.hurtingOfficer)
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
    /// Performs a Useful God (Yong Shen) analysis on this chart.
    public var usefulGodAnalysis: UsefulGodResult {
        return UsefulGodCalculator.analyze(self)
    }
}
