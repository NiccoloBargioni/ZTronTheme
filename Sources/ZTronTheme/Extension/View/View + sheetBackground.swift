import SwiftUI

public extension View {
    func sheetBackground<T: ZTronTheme>(theme: T) -> some View {
        return self.background {
            SheetBackground(theme: theme.erasedToAnyTheme())
        }
    }

    // Defaults to ZTronThemeProvider.default() rather than SheetBackground()'s own
    // @EnvironmentObject fallback, so this never crashes when no ZTronThemeProvider
    // is injected (e.g. previews, sheets presented without re-injecting the environment).
    func sheetBackground() -> some View {
        return self.sheetBackground(theme: ZTronThemeProvider.default().erasedToAnyTheme())
    }
}
