import SwiftUI

public struct SecondaryActionMaterial {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    private var injectedAppTheme: AnyZTronTheme? = nil

    public init(theme: AnyZTronTheme? = nil) {
        self.injectedAppTheme = theme
        // EnvironmentObject's own default init is @MainActor-isolated. Constructing
        // a View value is always done on the main actor in practice (including
        // SwiftUI's internal async-render thread, which the dynamic isolation check
        // can't always prove statically) — assumeIsolated asserts that correctly via
        // the executor-aware check instead of leaving an unresolved static warning.
        self._themeProvider = MainActor.assumeIsolated {
            EnvironmentObject<ZTronThemeProvider>()
        }
    }

}

// `View` conformance lives in an extension so only `body` (the protocol
// requirement) is MainActor-isolated — not the whole type, including `init`.
// See README.md for why this matters under Swift 6's Dynamic Actor Isolation.
// `theme` lives here too since it calls the MainActor-isolated
// ZTronThemeProvider.getTheme().
extension SecondaryActionMaterial: View {
    @MainActor
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
