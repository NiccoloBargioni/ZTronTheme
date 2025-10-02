import SwiftUI

public extension Text {
    func font<F: ZTronFont>(ztron: F, font: KeyPath<F, SwiftUI.Font>) -> Text {
        return self.font(ztron[keyPath: font])
    }
    
    func font(source: ZTronThemeProvider, font: KeyPath<AnyZTronFont, SwiftUI.Font>) -> Text {
        return self.font(source.getTheme().fontSet[keyPath: font])
    }
    
    func font<F: ZTronFont>(ztron: F, font: KeyPath<F, SwiftUI.Font>, weight: Font.Weight) -> Text {
        return self.font(ztron[keyPath: font].weight(weight))
    }
    
    func font(source: ZTronThemeProvider, font: KeyPath<AnyZTronFont, SwiftUI.Font>, weight: Font.Weight) -> Text {
        return self.font(source.getTheme().fontSet[keyPath: font].weight(weight))
    }
    
    func font<T: ZTronTheme>(theme: T, font: KeyPath<T.F, SwiftUI.Font>) -> Text {
        return self.font(theme.fontSet[keyPath: font])
    }
    
    func font<T: ZTronTheme>(theme: T, font: KeyPath<T.F, SwiftUI.Font>, weight: Font.Weight) -> Text {
        return self.font(theme.fontSet[keyPath: font].weight(weight))
    }
}


