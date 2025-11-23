import Foundation

/// A pair consisting of a Heavenly Stem and an Earthly Branch.
/// There are 60 possible combinations (Sexagenary cycle).
public struct StemBranch {
    public let stem: Stem
    public let branch: Branch
    
    public init(stem: Stem, branch: Branch) {
        self.stem = stem
        self.branch = branch
    }

    /// Creates a StemBranch from a zero-based index in the 60-year cycle (0-59).
    /// - Parameter index: The index in the cycle (e.g., 0 for Jia-Zi, 59 for Gui-Hai).
    public static func from(index: Int) -> StemBranch {
        return StemBranch(stem: Stem.from(index: index), branch: Branch.from(index: index))
    }

    /// The zero-based index of this pair in the 60-year cycle (0-59).
    public var index: Int {
        let s = stem.index
        let b = branch.index
        // Algorithm: I = (6S - 5B + 60) mod 60
        return (6 * s - 5 * b + 60) % 60
    }

    /// The Chinese character representation (e.g., "甲子").
    public var character: String {
        return stem.character + branch.character
    }
    
    public var next: Self {
        return next(1)
    }
    
    public var previous: Self {
        return previous(1)
    }
    
    public func next(_ offset: Int) -> StemBranch {
        return StemBranch(stem: stem.next(offset), branch: branch.next(offset))
    }

    public func previous(_ offset: Int) -> StemBranch {
        return StemBranch(stem: stem.previous(offset), branch: branch.previous(offset))
    }
}

