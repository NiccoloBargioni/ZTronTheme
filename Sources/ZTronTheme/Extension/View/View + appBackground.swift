import SwiftUI

public extension View {
    func appBackground<T: ZTronTheme>(theme: T) -> some View {
        return self.background(Color(theme, value: \.appBackground))
    }

    // Defaults to ZTronThemeProvider.default() rather than reading @EnvironmentObject,
    // so this never crashes when no ZTronThemeProvider is injected (e.g. previews, sheets).
    func appBackground() -> some View {
        return self.appBackground(theme: ZTronThemeProvider.default().erasedToAnyTheme())
    }

    func gradientAppBackground<T: ZTronTheme>(theme: T = ZTronThemeProvider.default().erasedToAnyTheme()) -> some View {
        return self.background {
            AppBackground(theme: theme.erasedToAnyTheme())
                .ignoresSafeArea()
        }
    }
}
