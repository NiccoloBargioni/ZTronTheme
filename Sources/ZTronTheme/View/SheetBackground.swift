import SwiftUI

public struct SheetBackground {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    private var injectedAppTheme: AnyZTronTheme? = nil

    private let baseEnd    = UnitPoint(x: 0.50, y: 0.31)
    private let glowCenter = UnitPoint(x: 0.50, y: 0.47)
    private let glowOpacity: Double = 0.10

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
extension SheetBackground: View {
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
            let size = geo.size
            let baseStart = colorScheme == .dark ? UnitPoint(x: 1.07, y: 1.61)
                                                 : UnitPoint(x: 1.07, y: 1.60)
            let glowRX: CGFloat = colorScheme == .dark ? 0.68 : 0.33
            let glowRY: CGFloat = colorScheme == .dark ? 0.38 : 0.53


            let baseColors: [Color] = colorScheme == .dark
                ? [Color(theme, value: \.appBackgroundVoid), Color(theme, value: \.appBackgroundDark)]
                : [Color(theme, value: \.appBackground),     Color(theme, value: \.appBackgroundLavender)]

            ZStack {
                LinearGradient(colors: baseColors, startPoint: baseStart, endPoint: baseEnd)

                EllipticalGradient(
                    colors: [Color(theme, value: \.brand), Color(theme, value: \.brand).opacity(0)],
                    center: .center,
                    startRadiusFraction: 0,
                    endRadiusFraction: 0.5
                )
                .frame(width: size.width * glowRX * 2, height: size.height * glowRY * 2)
                .position(x: size.width * glowCenter.x, y: size.height * glowCenter.y)
                .opacity(glowOpacity)
            }
            .clipped()
        }
    }
}

#Preview {
    SheetBackground(theme: ZTronCommanderTheme().erasedToAnyTheme())
        .frame(width: 430, height: 774)
        .preferredColorScheme(.dark)
}

#Preview {
    SheetBackground(theme: ZTronCommanderTheme().erasedToAnyTheme())
        .frame(width: 430, height: 338)
        .preferredColorScheme(.light)
}
