import SwiftUI

public extension View {
    func appBackground<T: ZTronTheme>(theme: T) -> some View {
        return self.background(Color(theme, value: \.appBackground))
    }
    
    func appBackground() -> some View {
        self.modifier(AppBackgroundViewModifier(value: \.appBackground))
    }
    
    func gradientAppBackground() -> some View {
        return self.background {
            AppBackground()
        }
    }
}


fileprivate struct AppBackgroundViewModifier: ViewModifier {
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    private let value: KeyPath<AnyZTronColor, String>
    
    fileprivate init(value: KeyPath<AnyZTronColor, String>) {
        self.value = value
    }
    
    public func body(content: Content) -> some View {
        return content.background {
            Color(themeProvider.getTheme().colorSet, value: self.value)
        }
    }
}
