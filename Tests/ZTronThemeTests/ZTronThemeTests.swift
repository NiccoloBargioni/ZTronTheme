import XCTest
@testable import ZTronTheme
import SwiftUI

final class ZTronThemeTests: XCTestCase {
    func testExample() throws {
        let colors = ZTronCommanderTheme.Color()
        let someColor = Color(colors, value: \.brand)
        
        let font = ZTronCommanderTheme.Font()
        let someFont = Text("Bella zio").font(ztron: font, font: \.callout, weight: .black)
    }
}
