import Foundation

extension FiveElements {
    /// Returns true if this element generates (produces) the other element.
    /// Wood -> Fire -> Earth -> Metal -> Water -> Wood
    public func generates(_ other: FiveElements) -> Bool {
        switch self {
        case .wood: return other == .fire
        case .fire: return other == .earth
        case .earth: return other == .metal
        case .metal: return other == .water
        case .water: return other == .wood
        }
    }
    
    /// Returns true if this element controls (overcomes) the other element.
    /// Wood -> Earth -> Water -> Fire -> Metal -> Wood
    public func controls(_ other: FiveElements) -> Bool {
        switch self {
        case .wood: return other == .earth
        case .earth: return other == .water
        case .water: return other == .fire
        case .fire: return other == .metal
        case .metal: return other == .wood
        }
    }
}

