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
            // Note: Day Master itself is typically excluded from "Ten Gods" in some contexts, 
            // but for "pattern" comparison, we might need its strength if it's Bi Jian.
            // In determinePattern, we compare with Bi Jian/Rob Wealth.
            if type == .day {
                scores[.friend, default: 0] += stem.energy
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
            let element: FiveElements
            switch rel.characters {
            case "寅卯辰": element = .wood
            case "巳午未": element = .fire
            case "申酉戌": element = .metal
            case "亥子丑": element = .water
            default: continue
            }
            
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
            let element: FiveElements
            switch rel.characters {
            case "寅卯辰": element = .wood
            case "巳午未": element = .fire
            case "申酉戌": element = .metal
            case "亥子丑": element = .water
            default: continue
            }
            
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
        
        return scores
    }
}
