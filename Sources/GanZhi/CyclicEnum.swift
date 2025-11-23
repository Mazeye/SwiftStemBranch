import Foundation

/// A protocol representing a cyclic enumeration, allowing for next/previous element retrieval.
/// This is useful for systems like Heavenly Stems and Earthly Branches.
public protocol CyclicEnum: CaseIterable, Equatable {
    /// Returns the next element in the cycle.
    var next: Self { get }
    
    /// Returns the previous element in the cycle.
    var previous: Self { get }
    
    /// Returns the element at a specific offset from the current one.
    /// - Parameter offset: The number of steps to move (can be negative).
    func next(_ offset: Int) -> Self
    
    /// Returns the element at a specific backward offset from the current one.
    /// - Parameter offset: The number of steps to move backward.
    func previous(_ offset: Int) -> Self
}

public extension CyclicEnum {
    /// The zero-based index of the element in `allCases`.
    var index: Int {
        let allCases = Array(Self.allCases)
        return allCases.firstIndex(of: self)!
    }

    /// Creates an instance from a zero-based index.
    /// The index is normalized to fit within the valid range of cases.
    ///
    /// - Parameter index: The index (can be negative or larger than count).
    /// - Returns: The corresponding enum case.
    static func from(index: Int) -> Self {
        let allCases = Array(Self.allCases)
        let count = allCases.count
        let normalizedIndex = (index % count + count) % count
        return allCases[normalizedIndex]
    }

    var next: Self {
        return next(1)
    }

    var previous: Self {
        return previous(1)
    }

    func next(_ offset: Int) -> Self {
        return Self.from(index: index + offset)
    }
    
    func previous(_ offset: Int) -> Self { 
        return Self.from(index: index - offset)
    }
}

