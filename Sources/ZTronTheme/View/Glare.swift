import SwiftUI


public struct Glare: View {
    internal var isAlwaysDark: Bool = false
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    private var injectedAppTheme: AnyZTronTheme? = nil

    public init(isAlwaysDark: Bool = false, theme: AnyZTronTheme? = nil) {
        self.isAlwaysDark = isAlwaysDark
        self.injectedAppTheme = theme
    }

    private var theme: AnyZTronTheme {
        self.injectedAppTheme ?? self.themeProvider.getTheme()
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
    
    public func alwaysDark() -> Self {
        var copy = self
        copy.isAlwaysDark = true
        return copy
    }
}

