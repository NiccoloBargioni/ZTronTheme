import SwiftUI

public struct SecondaryActionMaterial: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    private var injectedAppTheme: AnyZTronTheme? = nil

    public init(theme: AnyZTronTheme? = nil) {
        self.injectedAppTheme = theme
    }

    private var theme: AnyZTronTheme {
        self.injectedAppTheme ?? self.themeProvider.getTheme()
    }

    public var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color(self.theme, value: \.visitedMaterial)
                Color(self.theme, value: \.appBackground).opacity(0.9)
            } else {
                Color(self.theme, value: \.appBackgroundDark)
            }
        }
    }
}


#Preview {
    SecondaryActionMaterial(theme: ZTronCommanderTheme().erasedToAnyTheme())
}
