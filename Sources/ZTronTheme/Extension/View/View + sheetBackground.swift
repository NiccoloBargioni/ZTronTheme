import SwiftUI

public extension View {
    func sheetBackground<T: ZTronTheme>(theme: T) -> some View {
        return self.background {
            SheetBackground(theme: theme.erasedToAnyTheme())
        }
    }

    func sheetBackground() -> some View {
        return self.background {
            SheetBackground()
        }
    }
}
