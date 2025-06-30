import SwiftUI

public struct SecondaryActionMaterial: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    
    public init() { }
    
    public var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color(self.themeProvider.getTheme(), value: \.visitedMaterial)
                Color(self.themeProvider.getTheme(), value: \.appBackground).opacity(0.9)
            } else {
                Color(self.themeProvider.getTheme(), value: \.appBackgroundDark)
            }
        }
    }
}


#Preview {
    SecondaryActionMaterial()
}
