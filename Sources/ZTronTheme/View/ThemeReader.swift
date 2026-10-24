import SwiftUI

/// Resolves the current theme from the `ZTronThemeProvider` injected in the environment
/// and hands it to `content`.
///
/// This is the only place in the package that stores an `@EnvironmentObject`. The type
/// declares its `View` conformance on the declaration itself, so the whole type —
/// initializer included — is main-actor isolated, and it is only ever created inside
/// another view's `body`, where SwiftUI guarantees the main actor. That lets the public
/// views keep a `nonisolated` initializer with no `@EnvironmentObject` storage of their
/// own, so constructing them never touches main-actor state (see README, "Swift 6
/// isolation").
struct ThemeReader<Content: View>: View {
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    private let content: @MainActor (AnyZTronTheme) -> Content

    init(@ViewBuilder content: @escaping @MainActor (AnyZTronTheme) -> Content) {
        self.content = content
    }

    var body: some View {
        content(themeProvider.getTheme())
    }
}
