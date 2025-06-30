import SwiftUI


public struct Glare: View {
    internal var isAlwaysDark: Bool = false
    @EnvironmentObject private var themeProver: ZTronThemeProvider
    
    public init(isAlwaysDark: Bool = false) {
        self.isAlwaysDark = isAlwaysDark
    }

    public var body: some View {
        GeometryReader { geo in
            RadialGradient(
                colors: [
                    Color(self.themeProver.getTheme(), value: \.brand),
                    Color(self.themeProver.getTheme(), value:
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

