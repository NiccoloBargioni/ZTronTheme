import SwiftUI

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
        
        public func variable(size: CGFloat) -> SwiftUI.Font {
            return .custom("SwitzerVariable-Regular", size: size)
        }
        
        public func variable(size: CGFloat, weight: SwiftUI.Font.Weight) -> SwiftUI.Font {
            return .custom("SwitzerVariable-Regular", size: size).weight(weight)
        }
    }
}


