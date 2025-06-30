import Foundation

public protocol ZTronTheme: Sendable {
    associatedtype C: ZTronColor
    associatedtype F: ZTronFont
    
    var colorSet: C { get }
    var fontSet: F { get }
}

public extension ZTronTheme {
    func erasedToAnyTheme() -> AnyZTronTheme {
        return AnyZTronTheme(self)
    }
}


public struct AnyZTronTheme : ZTronTheme {
    public var colorSet: AnyZTronColor { return self.base.colorSet.erasedToAnyZTronColor() }
    public var fontSet: AnyZTronFont { return self.base.fontSet.erasedToAnyZTronFont() }
    
    private var base: any ZTronTheme

    init(_ base: any ZTronTheme) {
        self.base = base
    }
}
