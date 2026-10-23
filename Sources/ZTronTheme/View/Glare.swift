import SwiftUI


public struct Glare {
    internal var isAlwaysDark: Bool = false
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    private var injectedAppTheme: AnyZTronTheme? = nil

    public init(isAlwaysDark: Bool = false, theme: AnyZTronTheme? = nil) {
        self.isAlwaysDark = isAlwaysDark
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

    public func alwaysDark() -> Self {
        var copy = self
        copy.isAlwaysDark = true
        return copy
    }
}

// `View` conformance lives in an extension so only `body` (the protocol
// requirement) is MainActor-isolated — not the whole type, including `init`.
// See README.md for why this matters under Swift 6's Dynamic Actor Isolation.
// `theme` lives here too since it calls the MainActor-isolated
// ZTronThemeProvider.getTheme().
extension Glare: View {
    @MainActor
    private var theme: AnyZTronTheme {
        if let injectedAppTheme = self.injectedAppTheme {
            return injectedAppTheme
        } else {
            return self.themeProvider.getTheme()
        }
    }

    public var body: some View {
        GeometryReader { geo in
            RadialGradient(
                colors: [
                    Color(self.theme, value: \.brand),
                    Color(self.theme, value:
                            self.isAlwaysDark ? \.appBackground : \.appBackgroundDark
                    )
                    .opacity(0)
                ],
                center: .center,
                startRadius: .zero,
                endRadius: min(geo.size.width, geo.size.height) * 0.95
            )
            .opacity(0.16)
        }
    }
}

