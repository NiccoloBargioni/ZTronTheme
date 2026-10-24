import SwiftUI

public struct AppBackground {
    @Environment(\.colorScheme) private var colorScheme
    private let injectedAppTheme: AnyZTronTheme?

    private let washCenter = UnitPoint(x: 0.82, y: 0.03)
    private let washEdge   = UnitPoint(x: 0.00, y: 1.00)

    private let glowTopInset: CGFloat
    @Binding private var glowIntensity: CGFloat

    private let glowRadiusX: CGFloat = 0.37
    private let glowRadiusY: CGFloat = 0.10
    private let glowOpacity: Double  = 0.10

    /// Nonisolated: `View` conformance lives in an extension below, and nothing in here
    /// touches main-actor state, so this view can be created from any context.
    public init(theme: AnyZTronTheme? = nil, glowTopInset: CGFloat = 67.0 / 920.0, glowIntensity: Binding<CGFloat> = .constant(0)) {
        self.injectedAppTheme = theme
        self.glowTopInset = glowTopInset
        self._glowIntensity = glowIntensity
    }

    // MARK: - Layers
    //
    // Deliberately nonisolated (declared outside the `View` extension). `body` resolves
    // the theme on the main actor and passes it down as a plain value, so the
    // GeometryReader / ZStack closures created here inherit *no* main-actor isolation and
    // the compiler emits no executor check for them — whichever thread SwiftUI evaluates
    // them on, they cannot trap. See README, "Swift 6 isolation".

    private func layers(theme: AnyZTronTheme) -> some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                if colorScheme == .dark {
                    LinearGradient(
                        colors: [Color(theme, value: \.appBackgroundVoid), Color(theme, value: \.appBackgroundDark)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    RadialGradient(
                        colors: [Color(theme, value: \.appBackgroundDark), Color(theme, value: \.appBackgroundVoid).opacity(0)],
                        center: washCenter,
                        startRadius: 0,
                        endRadius: distance(washCenter, washEdge, in: size)
                    )
                } else {

                    LinearGradient(
                        colors: [Color(theme, value: \.appBackground), Color(theme, value: \.appBackgroundLavender)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    RadialGradient(
                        colors: [Color(theme, value: \.appBackgroundLavender), Color(theme, value: \.appBackgroundLavender).opacity(0)],
                        center: washCenter,
                        startRadius: 0,
                        endRadius: distance(washCenter, washEdge, in: size)
                    )
                }

                glow(theme: theme, in: size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .ignoresSafeArea()
    }

    /// Elliptical magenta glow aligned to the top edge of a bottom-anchored rect.
    /// `glowIntensity` scales the ellipse radii from 0 (invisible) to 1 (full Figma spec).
    ///
    /// In Figma only the dark page has this layer, and there it also carries a 10 %
    /// `appBackgroundVoid` wash over everything outside the ellipse. The light page has
    /// no such layer, so in light mode the ellipse fades to transparent and there is
    /// no wash — at intensity 0 nothing is drawn, matching Figma.
    private func glow(theme: AnyZTronTheme, in size: CGSize) -> some View {
        let intensity = max(0, min(1, glowIntensity))
        let height = max(size.height * (1 - glowTopInset), 0)
        let rx = size.width * glowRadiusX * intensity
        let ry = height * glowRadiusY * intensity

        let brand = Color(theme, value: \.brand)
        let wash: Color? = colorScheme == .dark ? Color(theme, value: \.appBackgroundVoid) : nil

        return ZStack {
            if let wash = wash {
                wash
            }
            EllipticalGradient(
                colors: [brand, wash ?? brand.opacity(0)],
                center: .center,
                startRadiusFraction: 0,
                endRadiusFraction: 0.5
            )
            .frame(width: rx * 2, height: ry * 2)
            .position(x: size.width / 2, y: 0)
        }
        .frame(width: size.width, height: height)
        .clipped()
        .compositingGroup()
        .opacity(glowOpacity)
    }

    private func distance(_ a: UnitPoint, _ b: UnitPoint, in size: CGSize) -> CGFloat {
        hypot((b.x - a.x) * size.width, (b.y - a.y) * size.height)
    }
}

// `View` conformance lives in an extension so that only `body` (the protocol
// requirement) is main-actor isolated — not the whole type, and in particular not
// `init`. `body` is the one place SwiftUI guarantees the main actor, so it is where the
// environment's theme provider is read; everything else is built from plain values.
extension AppBackground: View {
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
    AppBackground(theme: ZTronCommanderTheme().erasedToAnyTheme(), glowIntensity: .constant(1))
        .preferredColorScheme(.dark)
}

#Preview {
    AppBackground(theme: ZTronCommanderTheme().erasedToAnyTheme())
        .preferredColorScheme(.light)
}
#endif
