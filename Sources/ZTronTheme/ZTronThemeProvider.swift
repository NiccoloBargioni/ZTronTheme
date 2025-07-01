import SwiftUI

public final class ZTronThemeProvider: ObservableObject {
    @Published private var theme: AnyZTronTheme
    
    public init(initialValue: any ZTronTheme) {
        self.theme = initialValue.erasedToAnyTheme()
    }
    
    public final func getTheme() -> AnyZTronTheme {
        return self.theme
    }
    
    public final func replaceTheme(with other: any ZTronTheme) {
        self.theme = other.erasedToAnyTheme()
    }
    
    public static func `default`() -> any ZTronTheme {
        return ZTronCommanderTheme()
    }
    
}
