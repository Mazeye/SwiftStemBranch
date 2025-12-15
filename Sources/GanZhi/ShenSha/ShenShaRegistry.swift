import Foundation

/// Defines a custom Shen Sha rule.
public struct CustomShenSha {
    /// The name of the Shen Sha rule.
    public let name: String
    /// The logic to determine if the rule is met.
    public let check: (FourPillars) -> Bool
    
    public init(name: String, check: @escaping (FourPillars) -> Bool) {
        self.name = name
        self.check = check
    }
}

/// Registry for managing user-defined Shen Sha rules.
public class ShenShaRegistry {
    /// Storage for registered rules.
    private static var rules: [CustomShenSha] = []
    
    /// Registers a new custom Shen Sha rule.
    /// - Parameters:
    ///   - name: The name of the Shen Sha (e.g., "Five Tigers").
    ///   - check: A closure that takes FourPillars and returns true if the Shen Sha is present.
    public static func register(_ name: String, check: @escaping (FourPillars) -> Bool) {
        let rule = CustomShenSha(name: name, check: check)
        rules.append(rule)
    }
    
    /// Clears all registered rules.
    public static func clear() {
        rules.removeAll()
    }
    
    /// Returns all registered rules.
    internal static func getAllRules() -> [CustomShenSha] {
        return rules
    }
}

