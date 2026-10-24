import SwiftUI


public struct Glare {
    internal var isAlwaysDark: Bool = false
    private let injectedAppTheme: AnyZTronTheme?

    /// Nonisolated: `View` conformance lives in an extension below, and nothing in here
    /// touches main-actor state, so this view can be created from any context.
    public init(isAlwaysDark: Bool = false, theme: AnyZTronTheme? = nil) {
        self.isAlwaysDark = isAlwaysDark
        self.injectedAppTheme = theme
    }

    public func alwaysDark() -> Self {
        var copy = self
        copy.isAlwaysDark = true
        return copy
    }

    // Deliberately nonisolated (declared outside the `View` extension): built only from
    // plain values, so the GeometryReader closure carries no executor check.
    // See README, "Swift 6 isolation".
    private func layers(theme: AnyZTronTheme) -> some View {
        GeometryReader { geo in
            RadialGradient(
                colors: [
                    Color(theme, value: \.brand),
                    Color(theme, value:
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

// `View` conformance lives in an extension so that only `body` is main-actor isolated —
// not `init`. `body` is where the environment's theme provider is read.
extension Glare: View {
    public var body: some View {
        if let injectedAppTheme {
            layers(theme: injectedAppTheme)
        } else {
            ThemeReader { theme in
                layers(theme: theme)
            }
        }
    }
}
