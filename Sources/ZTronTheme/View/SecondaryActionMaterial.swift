import SwiftUI

public struct SecondaryActionMaterial {
    @Environment(\.colorScheme) private var colorScheme
    private let injectedAppTheme: AnyZTronTheme?

    /// Nonisolated: `View` conformance lives in an extension below, and nothing in here
    /// touches main-actor state, so this view can be created from any context.
    public init(theme: AnyZTronTheme? = nil) {
        self.injectedAppTheme = theme
    }

    // Deliberately nonisolated (declared outside the `View` extension): built only from
    // plain values, so the ZStack closure carries no executor check.
    // See README, "Swift 6 isolation".
    private func layers(theme: AnyZTronTheme) -> some View {
        ZStack {
            if colorScheme == .dark {
                Color(theme, value: \.visitedMaterial)
                Color(theme, value: \.appBackground).opacity(0.9)
            } else {
                Color(theme, value: \.appBackgroundDark)
            }
        }
    }
}

// `View` conformance lives in an extension so that only `body` is main-actor isolated —
// not `init`. `body` is where the environment's theme provider is read.
extension SecondaryActionMaterial: View {
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
    SecondaryActionMaterial(theme: ZTronCommanderTheme().erasedToAnyTheme())
}
#endif
