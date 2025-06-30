import Foundation


public protocol ZTronColor: Sendable {
    var brand: String { get }
    var label: String { get }
    var appBackground: String { get }
    var appBackgroundDark: String { get }
    var appBackgroundLight: String { get }
    var visitedMaterial: String { get }
    var sunsetSky: String { get }
    var disabled: String { get }
}

public extension ZTronColor {
    func erasedToAnyZTronColor() -> AnyZTronColor {
        return AnyZTronColor(self)
    }
}



public struct AnyZTronColor : ZTronColor {
    public var brand: String { return base.brand }
    public var label: String { return base.label }
    public var appBackground: String { return base.appBackground }
    public var appBackgroundDark: String { return base.appBackgroundDark }
    public var appBackgroundLight: String { return base.appBackgroundLight }
    public var visitedMaterial: String { return base.visitedMaterial }
    public var sunsetSky: String { return base.sunsetSky }
    public var disabled: String { return base.disabled }
    
    private let base: any ZTronColor
    
    init(_ base: any ZTronColor) {
        self.base = base
    }
}

