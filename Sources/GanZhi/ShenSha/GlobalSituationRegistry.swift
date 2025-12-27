import Foundation

/// Defines a custom Global Situation rule (e.g., custom pattern or chart configuration).
public struct CustomGlobalSituation {
    /// The name of the situation (e.g., "Full Yin", "Five Tigers").
    public let name: String
    /// The logic to determine if the situation is present.
    public let check: (FourPillars) -> Bool
    
    public init(name: String, check: @escaping (FourPillars) -> Bool) {
        self.name = name
        self.check = check
    }
}

/// Registry for managing user-defined Global Situations (Global Patterns).
public class GlobalSituationRegistry {
    /// Storage for registered rules.
    private static var rules: [CustomGlobalSituation] = []
    
    /// Registers a new custom Global Situation rule.
    /// - Parameters:
    ///   - name: The name of the situation.
    ///   - check: A closure that takes FourPillars and returns true if the situation matches.
    public static func register(_ name: String, check: @escaping (FourPillars) -> Bool) {
        let rule = CustomGlobalSituation(name: name, check: check)
        rules.append(rule)
    }
    
    /// Clears all registered rules.
    public static func clear() {
        rules.removeAll()
    }
    
    /// Returns all registered rules.
    internal static func getAllRules() -> [CustomGlobalSituation] {
        return rules
    }
}

