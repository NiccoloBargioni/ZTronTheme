import SwiftUI

@MainActor
public final class ZTronThemeProvider: ObservableObject {
    @Published private var theme: AnyZTronTheme

    public init(initialValue: any ZTronTheme) {
        self.theme = initialValue.erasedToAnyTheme()
    }

    public final func getTheme() -> AnyZTronTheme {
        return self.theme
    }

    public final func replaceTheme(with other: any ZTronTheme) {
        self.theme = other.erasedToAnyTheme()
    }

    // Stateless and used as a default-parameter expression from nonisolated call sites.
    public nonisolated static func `default`() -> any ZTronTheme {
        return ZTronCommanderTheme()
    }

}
