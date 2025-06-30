import SwiftUI

public extension Color {
    init<C: ZTronColor>(_ ztron: C, value: KeyPath<C, String>) {
        self.init(ztron[keyPath: value], bundle: .module)
    }
    
    init<T: ZTronTheme>(_ ztron: T, value: KeyPath<T.C, String>) {
        self.init(ztron.colorSet[keyPath: value], bundle: .module)
    }
}
