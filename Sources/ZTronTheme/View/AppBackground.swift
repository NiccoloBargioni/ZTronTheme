import SwiftUI

public struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    private var injectedAppTheme: AnyZTronTheme? = nil
    
    public init(theme: AnyZTronTheme? = nil) {
        self.injectedAppTheme = theme
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
            let diagonal = sqrt(geo.size.width * geo.size.width + geo.size.height * geo.size.height)
            
            ZStack {
                LinearGradient(
                    colors: [
                        self.colorScheme == .light ?
                        Color.fromHex("#EAE9F9") : Color.fromHex("#0b0b0b"),
                        Color(self.theme, value: \.appBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                
                RadialGradient(
                    stops: [
                        Gradient.Stop(
                            color: Color(self.theme, value: \.appBackground),
                            location: 0
                        ),
                        Gradient.Stop(
                            color: Color(self.theme, value: \.appBackground).opacity(0),
                            location: 1
                        )
                    ],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: diagonal
                )
            }
        }
    }
}


#Preview {
    AppBackground()
}
