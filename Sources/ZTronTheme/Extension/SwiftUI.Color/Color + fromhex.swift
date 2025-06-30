import SwiftUI

extension Color {
    static func fromHex(_ hex: String, alpha: CGFloat? = nil) -> Color {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            while cString.count < 6 {
                cString.append(contentsOf: cString)
            }
            
            cString = String(
                cString.prefix(
                    upTo: cString.index(
                        cString.startIndex,
                        offsetBy: 6)
                )
            )
            
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return Color(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0
        )
        .opacity(
            (0...1.0).clamp(alpha ?? 1.0)
        )
    }
}
