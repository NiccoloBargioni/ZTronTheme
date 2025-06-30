import SwiftUI

public struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeProvider: ZTronThemeProvider
    
    public init() {  }
    
    public var body: some View {
        GeometryReader { geo in
            let diagonal = sqrt(geo.size.width * geo.size.width + geo.size.height * geo.size.height)
            
            ZStack {
                LinearGradient(
                    colors: [
                        self.colorScheme == .light ?
                        Color.fromHex("#F5F5F5") : Color.fromHex("#0b0b0b"),
                        Color(self.themeProvider.getTheme(), value: \.appBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                
                RadialGradient(
                    stops: [
                        Gradient.Stop(
                            color: Color(self.themeProvider.getTheme(), value: \.appBackground),
                            location: 0
                        ),
                        Gradient.Stop(
                            color: Color(self.themeProvider.getTheme(), value: \.appBackground).opacity(0),
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
