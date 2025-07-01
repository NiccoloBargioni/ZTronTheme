import UIKit

public extension UIColor {
    static func fromTheme(_ `set`: any ZTronColor, color: KeyPath<AnyZTronColor, String>) -> UIColor {
        return UIColor(named: set.erasedToAnyZTronColor()[keyPath: color], in: .module, compatibleWith: .current)!
    }
}
