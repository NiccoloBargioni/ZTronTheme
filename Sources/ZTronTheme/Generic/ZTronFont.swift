import SwiftUI

public protocol ZTronFont: Sendable {
    var largeTitle: SwiftUI.Font { get }
    var title: SwiftUI.Font { get }
    var title2: SwiftUI.Font { get }
    var title3: SwiftUI.Font { get }
    var headline: SwiftUI.Font { get }
    var body: SwiftUI.Font { get }
    var callout: SwiftUI.Font { get }
    var subheadline: SwiftUI.Font { get }
    var footnote: SwiftUI.Font { get }
    var caption: SwiftUI.Font { get }
    var caption2: SwiftUI.Font { get }
    var smaller: SwiftUI.Font { get }
    
    var uiLargeTitle: UIFont { get }
    var uiTitle: UIFont { get }
    var uiTitle2: UIFont { get }
    var uiTitle3: UIFont { get }
    var uiHeadline: UIFont { get }
    var uiBody: UIFont { get }
    var uiCallout: UIFont { get }
    var uiSubheadline: UIFont { get }
    var uiFootnote: UIFont { get }
    var uiCaption: UIFont { get }
    var uiCaption2: UIFont { get }
    var uiSmaller: UIFont { get }
    
    func variable(size: CGFloat) -> SwiftUI.Font
    func variable(size: CGFloat, weight: SwiftUI.Font.Weight) -> SwiftUI.Font
}

public extension ZTronFont {
    func erasedToAnyZTronFont() -> AnyZTronFont {
        return AnyZTronFont(self)
    }
}

public struct AnyZTronFont : ZTronFont {
    
    public var largeTitle: SwiftUI.Font { return base.largeTitle }
    public var title: SwiftUI.Font { return base.title }
    public var title2: SwiftUI.Font { return base.title2 }
    public var title3: SwiftUI.Font { return base.title3 }
    public var headline: SwiftUI.Font { return base.headline }
    public var body: SwiftUI.Font { return base.body }
    public var callout: SwiftUI.Font { return base.callout }
    public var subheadline: SwiftUI.Font { return base.subheadline }
    public var footnote: SwiftUI.Font { return base.footnote }
    public var caption: SwiftUI.Font { return base.caption }
    public var caption2: SwiftUI.Font { return base.caption2 }
    public var smaller: SwiftUI.Font { return base.smaller }
    
    public var uiLargeTitle: UIFont { return base.uiLargeTitle }
    public var uiTitle: UIFont { return base.uiTitle }
    public var uiTitle2: UIFont { return base.uiTitle2 }
    public var uiTitle3: UIFont { return base.uiTitle3 }
    public var uiHeadline: UIFont { return base.uiHeadline }
    public var uiBody: UIFont { return base.uiBody }
    public var uiCallout: UIFont { return base.uiCallout }
    public var uiSubheadline: UIFont { return base.uiSubheadline }
    public var uiFootnote: UIFont { return base.uiFootnote }
    public var uiCaption: UIFont { return base.uiCaption }
    public var uiCaption2: UIFont { return base.uiCaption2 }
    public var uiSmaller: UIFont { return base.uiSmaller }


    
    public func variable(size: CGFloat) -> SwiftUI.Font {
        return self.base.variable(size: size)
    }
    
    public func variable(size: CGFloat, weight: SwiftUI.Font.Weight) -> SwiftUI.Font {
        return self.base.variable(size: size, weight: weight)
    }

    private let base: any ZTronFont
    
    init(_ base: any ZTronFont) {
        self.base = base
    }
}

