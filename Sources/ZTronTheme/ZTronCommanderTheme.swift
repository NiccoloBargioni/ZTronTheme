import SwiftUI
import UIKit

public struct ZTronCommanderTheme: ZTronTheme {
    public var colorSet: Color = .init()
    public var fontSet: Font = .init()
    
    public typealias C = Self.Color
    public typealias F = Self.Font
    
    public init() {  }
    
    public struct Color: ZTronColor {
        public let brand = "brand"
        public let label = "global.background.inverted"
        public let appBackground = "global.background"
        public let appBackgroundDark = "global.background.dark"
        public let appBackgroundLight = "gradient.background"
        public let visitedMaterial = "visited.material"
        public let sunsetSky = "sunset.sky"
        public let disabled = "disabled"
    }
    
    public struct Font: ZTronFont {
        public let largeTitle: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 32)
        public let title: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 27)
        public let title2: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 22)
        public let title3: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 19.5)
        public let headline: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 17.5)
        public let body: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 17.0)
        public let callout: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 16.5)
        public let subheadline: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 14.5)
        public let footnote: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 13.5)
        public let caption: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 13.0)
        public let caption2: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 12.0)
        public let smaller: SwiftUI.Font = SwiftUI.Font.custom("SwitzerVariable-Regular", size: 10.0)
        
        
        
        public let uiLargeTitle: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 32) ?? UIFont.systemFont(ofSize: 32)
        public let uiTitle: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 27) ?? UIFont.systemFont(ofSize: 27)
        public let uiTitle2: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 22) ?? UIFont.systemFont(ofSize: 22)
        public let uiTitle3: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 19.5) ??
            UIFont.systemFont(ofSize: 19.5)
        public let uiHeadline: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 17.5) ?? UIFont.systemFont(ofSize: 17.5)
        public let uiBody: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 17) ??
            UIFont.systemFont(ofSize: 17)
        public let uiCallout: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 16.5) ??
            UIFont.systemFont(ofSize: 16.5)
        public let uiSubheadline: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 14.5) ??
            UIFont.systemFont(ofSize: 14.5)
        public let uiFootnote: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 13.5) ??         UIFont.systemFont(ofSize: 13.5)
        public let uiCaption: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        public let uiCaption2: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)
        public let uiSmaller: UIFont = UIFont(name: "SwitzerVariable-Regular", size: 10.0) ?? UIFont.systemFont(ofSize: 10.0)
        
        public func variable(size: CGFloat) -> SwiftUI.Font {
            return .custom("SwitzerVariable-Regular", size: size)
        }
        
        public func variable(size: CGFloat, weight: SwiftUI.Font.Weight) -> SwiftUI.Font {
            return .custom("SwitzerVariable-Regular", size: size).weight(weight)
        }
    }
}


