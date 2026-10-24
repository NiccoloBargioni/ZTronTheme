import SwiftUI

// All of these are `nonisolated`, like SwiftUI's own `View` modifiers: they only build
// view values from plain data, so they can be applied from any context and the
// `.background { }` closures they create carry no main-actor executor check.
// See README, "Swift 6 isolation".
public extension View {
    nonisolated func appBackground<T: ZTronTheme>(theme: T) -> some View {
        return self.background(Color(theme, value: \.appBackground))
    }

    // Defaults to ZTronThemeProvider.default() rather than reading @EnvironmentObject,
    // so this never crashes when no ZTronThemeProvider is injected (e.g. previews, sheets).
    nonisolated func appBackground() -> some View {
        return self.appBackground(theme: ZTronThemeProvider.default().erasedToAnyTheme())
    }

    nonisolated func gradientAppBackground<T: ZTronTheme>(theme: T = ZTronThemeProvider.default().erasedToAnyTheme()) -> some View {
        return self.background {
            AppBackground(theme: theme.erasedToAnyTheme())
                .ignoresSafeArea()
        }
    }
}
