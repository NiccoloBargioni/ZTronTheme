import SwiftUI

public struct SheetBackground {
    @Environment(\.colorScheme) private var colorScheme
    private let injectedAppTheme: AnyZTronTheme?

    private let baseEnd    = UnitPoint(x: 0.50, y: 0.31)
    private let glowCenter = UnitPoint(x: 0.50, y: 0.47)
    private let glowOpacity: Double = 0.10

    /// Nonisolated: `View` conformance lives in an extension below, and nothing in here
    /// touches main-actor state, so this view can be created from any context.
    public init(theme: AnyZTronTheme? = nil) {
        self.injectedAppTheme = theme
    }

    // Deliberately nonisolated (declared outside the `View` extension): built only from
    // plain values, so the GeometryReader / ZStack closures carry no executor check.
    // See README, "Swift 6 isolation".
    private func layers(theme: AnyZTronTheme) -> some View {
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

// `View` conformance lives in an extension so that only `body` is main-actor isolated —
// not `init`. `body` is where the environment's theme provider is read.
extension SheetBackground: View {
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

#if DEBUG
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
#endif
