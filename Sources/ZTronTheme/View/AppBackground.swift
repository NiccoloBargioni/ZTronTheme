import SwiftUI

public struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    private var injectedAppTheme: AnyZTronTheme? = nil

    private let washCenter = UnitPoint(x: 0.82, y: 0.03)
    private let washEdge   = UnitPoint(x: 0.00, y: 1.00)

    private var glowTopInset: CGFloat
    @Binding private var glowIntensity: CGFloat

    private let glowRadiusX: CGFloat = 0.37
    private let glowRadiusY: CGFloat = 0.10
    private let glowOpacity: Double  = 0.10

    public init(theme: AnyZTronTheme? = nil, glowTopInset: CGFloat = 67.0 / 920.0, glowIntensity: Binding<CGFloat> = .constant(0)) {
        self.injectedAppTheme = theme
        self.glowTopInset = glowTopInset
        self._glowIntensity = glowIntensity
    }

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

                glow(in: size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Layers

    /// Elliptical magenta glow aligned to the top edge of a bottom-anchored rect.
    /// `glowIntensity` scales the ellipse radii from 0 (invisible) to 1 (full Figma spec).
    ///
    /// In Figma only the dark page has this layer, and there it also carries a 10 %
    /// `appBackgroundVoid` wash over everything outside the ellipse. The light page has
    /// no such layer, so in light mode the ellipse fades to transparent and there is
    /// no wash — at intensity 0 nothing is drawn, matching Figma.
    private func glow(in size: CGSize) -> some View {
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


#Preview {
    AppBackground(theme: ZTronCommanderTheme().erasedToAnyTheme(), glowIntensity: .constant(1))
        .preferredColorScheme(.dark)
}

#Preview {
    AppBackground(theme: ZTronCommanderTheme().erasedToAnyTheme())
        .preferredColorScheme(.light)
}
