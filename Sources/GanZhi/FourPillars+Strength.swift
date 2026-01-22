import Foundation

extension FourPillars {
    
    /// Calculates the strength (weight) of each Ten God in the Four Pillars.
    /// This includes contributions from Heavenly Stems, Hidden Stems in Branches,
    /// and bonuses from Branch Relationships (like Directional Harmony).
    public var tenGodStrengths: [TenGods: Double] {
        var scores: [TenGods: Double] = [
            .friend: 0, .robWealth: 0, .eatingGod: 0, .hurtingOfficer: 0,
            .directWealth: 0, .indirectWealth: 0, .directOfficer: 0, .sevenKillings: 0,
            .directResource: 0, .indirectResource: 0
        ]
        
        let pillars = [self.year, self.month, self.day, self.hour]
        
        for (index, pillar) in pillars.enumerated() {
            let type = PillarType.allCases[index]
            let stem = pillar.stem
            let branch = pillar.branch
            
            // 1. Stem contribution
            // Note: Day Master itself is typically excluded from "Ten Gods" (it is the reference "Me").
            // So we do NOT add its energy to .friend or any other Ten God.
            if type == .day {
                // Do nothing for Ten God score
            } else {
                let sTenGod = self.tenGod(for: stem)
                scores[sTenGod, default: 0] += stem.energy
            }
            
            // 2. Branch hidden stems contribution
            let branchEnergy = branch.energy
            let hidden = self.hiddenTenGods(for: branch.value)
            
            // Ben Qi (1.0)
            scores[hidden.benQi.tenGod, default: 0] += branchEnergy * 1.0
            
            // Zhong Qi (0.6)
            if let zhong = hidden.zhongQi {
                scores[zhong.tenGod, default: 0] += branchEnergy * 0.6
            }
            
            // Yu Qi (0.3)
            if let yu = hidden.yuQi {
                scores[yu.tenGod, default: 0] += branchEnergy * 0.3
            }
        }
        
        // 3. Bonuses from Branch Relationships
        // Directional Harmony (San Hui) bonus
        for rel in self.relationships where rel.type == .branchDirectional {
            // Find which Ten God this element corresponds to
            guard let element = rel.relatedElement else { continue }
            
            // Calculate Ten God for this element relative to Day Master
            // Note: We use the Day Master's YinYang to determine the exact Ten God.
            // Since San Hui is an element-wide bonus, it might affect both Ten Gods of that element.
            // Usually, it's assigned to the one matching the Main Qi or just distributed.
            // In the Sample code, it was only added to elementScores.
            // If we want TenGod scores, we need to decide how to distribute it.
            // Let's assume it boosts both proportional to their existing presence or just use a default.
            
            // For simplicity and matching Sample's spirit (if it were to do Ten Gods):
            // We'll calculate which Ten God(s) this element represents.
            let tgYang = TenGods.calculate(dayMaster: self.day.stem.value, targetElement: element, targetYinYang: .yang)
            let tgYin = TenGods.calculate(dayMaster: self.day.stem.value, targetElement: element, targetYinYang: .yin)
            
            // Add bonus to both? Or just the primary one?
            // Let's distribute the bonus.
            for pType in rel.pillars {
                let bonus = (pType == .month) ? 3.0 : 1.0
                scores[tgYang, default: 0] += bonus * 0.5
                scores[tgYin, default: 0] += bonus * 0.5
            }
            
            // Continuity bonus
            let sortedIndices = rel.pillars.map { $0.rawValue }.sorted()
            if sortedIndices.count == 3 {
                if sortedIndices[1] == sortedIndices[0] + 1 && sortedIndices[2] == sortedIndices[1] + 1 {
                    scores[tgYang, default: 0] += 0.5
                    scores[tgYin, default: 0] += 0.5
                }
            }
        }
        
        // 3.1 Half San Hui (Half Directional) - Ten Gods
        var fullSanHuiElementsTG: Set<FiveElements> = []
        for rel in self.relationships where rel.type == .branchDirectional {
             if let element = rel.relatedElement {
                 fullSanHuiElementsTG.insert(element)
             }
        }
        
        let directions: [FiveElements: Set<String>] = [
            .wood: ["寅", "卯", "辰"],
            .fire: ["巳", "午", "未"],
            .metal: ["申", "酉", "戌"],
            .water: ["亥", "子", "丑"]
        ]
        
        for (element, chars) in directions {
            if fullSanHuiElementsTG.contains(element) { continue }
            
            var involvedIndices: [Int] = []
            for (index, pillar) in pillars.enumerated() {
                if chars.contains(pillar.branch.value.character) {
                    involvedIndices.append(index)
                }
            }
            
            if involvedIndices.count >= 2 {
                 // Calculate Ten Gods for this element
                 let tgYang = TenGods.calculate(dayMaster: self.day.stem.value, targetElement: element, targetYinYang: .yang)
                 let tgYin = TenGods.calculate(dayMaster: self.day.stem.value, targetElement: element, targetYinYang: .yin)
                
                for index in involvedIndices {
                    let branchEnergy: Double = (index == 1) ? 3.0 : 1.0
                    let bonus = branchEnergy * 0.5
                    
                    // Distribute half bonus for Ten Gods
                    scores[tgYang, default: 0] += bonus * 0.5
                    scores[tgYin, default: 0] += bonus * 0.5
                }
            }
        }
        
        // 3.2 San He (Triple Harmony) & Ban San He
        // Map: Set -> MiddleBranch
        let tripleSetsTG: [(Set<Branch>, Branch)] = [
            ([.shen, .zi, .chen], .zi),
            ([.hai, .mao, .wei], .mao),
            ([.yin, .wu, .xu], .wu),
            ([.si, .you, .chou], .you)
        ]

        let chartBranchesTG = pillars.map { $0.branch.value }
        let uniqueBranchesTG = Set(chartBranchesTG)

        for (set, middle) in tripleSetsTG {
            let intersection = set.intersection(uniqueBranchesTG)
            
            var bonus: Double = 0.0
            if intersection.count == 3 {
                bonus = 2.0
            } else if intersection.count == 2 {
                bonus = 1.0
            }
            
            if bonus > 0 {
                // Add to Ten God of the Middle Branch
                // Use Ben Qi of Middle Branch
                let tg = self.tenGod(for: middle)
                scores[tg, default: 0] += bonus
            }
        }
        
        return scores
    }
    
    /// Calculates the strength (weight) of each Five Element in the Four Pillars.
    public var elementStrengths: [FiveElements: Double] {
        var scores: [FiveElements: Double] = [
            .wood: 0, .fire: 0, .earth: 0, .metal: 0, .water: 0
        ]
        
        let pillars = [self.year, self.month, self.day, self.hour]
        for pillar in pillars {
            let stem = pillar.stem
            let branch = pillar.branch
            
            // 1. Stem contribution
            scores[stem.fiveElement, default: 0] += stem.energy
            
            // 2. Branch hidden stems contribution
            let branchEnergy = branch.energy
            let hidden = self.hiddenTenGods(for: branch.value)
            
            // Ben Qi (1.0)
            scores[hidden.benQi.stem.fiveElement, default: 0] += branchEnergy * 1.0
            
            // Zhong Qi (0.6)
            if let zhong = hidden.zhongQi {
                scores[zhong.stem.fiveElement, default: 0] += branchEnergy * 0.6
            }
            
            // Yu Qi (0.3)
            if let yu = hidden.yuQi {
                scores[yu.stem.fiveElement, default: 0] += branchEnergy * 0.3
            }
        }
        
        // 3. Bonuses from Branch Relationships
        for rel in self.relationships where rel.type == .branchDirectional {
            guard let element = rel.relatedElement else { continue }
            
            for pType in rel.pillars {
                let bonus: Double = (pType == .month) ? 3.0 : 1.0
                scores[element, default: 0] += bonus
            }
            
            let sortedIndices = rel.pillars.map { $0.rawValue }.sorted()
            if sortedIndices.count == 3 {
                if sortedIndices[1] == sortedIndices[0] + 1 && sortedIndices[2] == sortedIndices[1] + 1 {
                    scores[element, default: 0] += 1.0
                }
            }
        }
        
        // 3.1 Half San Hui (Half Directional)
        var fullSanHuiElements: Set<FiveElements> = []
        for rel in self.relationships where rel.type == .branchDirectional {
             if let element = rel.relatedElement {
                 fullSanHuiElements.insert(element)
             }
        }
        
        let directions: [FiveElements: Set<String>] = [
            .wood: ["寅", "卯", "辰"],
            .fire: ["巳", "午", "未"],
            .metal: ["申", "酉", "戌"],
            .water: ["亥", "子", "丑"]
        ]
        
        for (element, chars) in directions {
            if fullSanHuiElements.contains(element) { continue }
            
            var involvedIndices: [Int] = []
            for (index, pillar) in pillars.enumerated() {
                if chars.contains(pillar.branch.value.character) {
                    involvedIndices.append(index)
                }
            }
            
            if involvedIndices.count >= 2 {
                for index in involvedIndices {
                    // Month (index 1) gets 3.0, others 1.0
                    let branchEnergy: Double = (index == 1) ? 3.0 : 1.0
                    // Half energy bonus
                    scores[element, default: 0] += branchEnergy * 0.5
                }
            }
        }
        
        // 3.2 San He (Triple Harmony) & Ban San He
        let tripleSets: [(Set<Branch>, FiveElements)] = [
            ([.shen, .zi, .chen], .water),
            ([.hai, .mao, .wei], .wood),
            ([.yin, .wu, .xu], .fire),
            ([.si, .you, .chou], .metal)
        ]

        let chartBranchesStr = pillars.map { $0.branch.value }
        let uniqueBranches = Set(chartBranchesStr)

        for (set, element) in tripleSets {
            let intersection = set.intersection(uniqueBranches)
            
            if intersection.count == 3 {
                // Full San He: +2.0
                scores[element, default: 0] += 2.0
            } else if intersection.count == 2 {
                // Half San He: +1.0
                scores[element, default: 0] += 1.0
            }
        }
        
        return scores
    }
}
