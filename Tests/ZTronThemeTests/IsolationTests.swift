import XCTest
@testable import ZTronTheme
import SwiftUI

/// Regression tests for the Swift 6 main-actor traps described in README,
/// "Internal note: Swift 6 isolation".
///
/// Every public view and modifier must be constructible from a context that is *not*
/// the main actor without trapping: no `MainActor.assumeIsolated` (nor any other
/// executor check) may remain on those paths. Before the fix, the first test below
/// killed the test process with `_dispatch_assert_queue_fail`, raised by
/// `MainActor.assumeIsolated` inside `AppBackground.init` — not by `.ignoresSafeArea()`
/// and not by the `View` conformance, as an earlier diagnosis claimed.
///
/// The off-main-actor tests cannot "fail" softly: a regression is a SIGTRAP that
/// XCTest reports as a crashed test run. That is intended — it is exactly what users of
/// the package would see.
///
/// The rendering tests then check that the restructured views still draw the theme:
/// they assert on sampled pixels, not merely on "did not crash".
final class IsolationTests: XCTestCase {

    // MARK: - Construction off the main actor

    func testAppBackgroundCanBeBuiltAndWrappedOffMainActor() async {
        await Task.detached {
            let view = AppBackground(theme: ZTronCommanderTheme().erasedToAnyTheme(), glowIntensity: .constant(1))
                .ignoresSafeArea()
            _ = view
        }.value
    }

    func testGlareCanBeBuiltOffMainActor() async {
        await Task.detached {
            let view = Glare(theme: ZTronCommanderTheme().erasedToAnyTheme())
                .alwaysDark()
                .ignoresSafeArea()
            _ = view
        }.value
    }

    func testSheetBackgroundCanBeBuiltOffMainActor() async {
        await Task.detached {
            let view = SheetBackground(theme: ZTronCommanderTheme().erasedToAnyTheme())
                .ignoresSafeArea()
            _ = view
        }.value
    }

    func testSecondaryActionMaterialCanBeBuiltOffMainActor() async {
        await Task.detached {
            let view = SecondaryActionMaterial(theme: ZTronCommanderTheme().erasedToAnyTheme())
                .ignoresSafeArea()
            _ = view
        }.value
    }

    /// The bare initializers read the `ZTronThemeProvider` from the environment, but only
    /// inside `body`; constructing them must not need the provider or the main actor.
    func testBareInitializersCanBeBuiltOffMainActor() async {
        await Task.detached {
            _ = AppBackground()
            _ = Glare()
            _ = SheetBackground()
            _ = SecondaryActionMaterial()
        }.value
    }

    /// The modifiers are `nonisolated`, like SwiftUI's own, so this compiles — and must
    /// not trap — from a detached task. (Against the previous, main-actor-isolated
    /// modifiers this test does not even compile.)
    func testModifiersCanBeAppliedOffMainActor() async {
        await Task.detached {
            _ = Color.clear.appBackground()
            _ = Color.clear.appBackground(theme: ZTronCommanderTheme())
            _ = Color.clear.gradientAppBackground()
            _ = Color.clear.gradientAppBackground(theme: ZTronCommanderTheme())
            _ = Color.clear.sheetBackground()
            _ = Color.clear.sheetBackground(theme: ZTronCommanderTheme())
        }.value
    }

    // MARK: - Rendering on the main actor
    //
    // `drawHierarchy(in:afterScreenUpdates:)` draws nothing inside a bare xctest host, so
    // solid-colour content is captured with `CALayer.render(in:)` from a live window (which
    // also exercises the `@EnvironmentObject` update path), and the gradient views through
    // `ImageRenderer`, SwiftUI's own rasterizer. Reference pixels come from rendering the
    // raw catalog colour through the same pipeline, so colour management cancels out.

    @MainActor
    func testSecondaryActionMaterialDrawsThemeColorsInBothSchemes() {
        let theme = ZTronCommanderTheme().erasedToAnyTheme()

        // Light mode is one solid catalog colour, so the check is equality with that colour
        // rendered through the same pipeline. Dark mode stacks a translucent `visited.material`
        // under `appBackground` at 90 % opacity, so it is not fully opaque by design.
        let light = WindowStage(SecondaryActionMaterial(theme: theme), scheme: .light).centerPixel()
        let expectedLight = WindowStage(Color(theme, value: \.appBackgroundDark), scheme: .light).centerPixel()
        XCTAssertGreaterThan(light.a, 0)
        XCTAssertEqual(light, expectedLight)

        let dark = WindowStage(SecondaryActionMaterial(theme: theme), scheme: .dark).centerPixel()
        XCTAssertGreaterThan(dark.a, 0)
        XCTAssertNotEqual(dark, light)
    }

    /// Bare init → `ThemeReader` → `@EnvironmentObject`: the view must follow
    /// `replaceTheme(with:)` live, so the replacement theme maps every colour to `brand`.
    @MainActor
    func testBareInitFollowsEnvironmentProviderAndReplaceTheme() {
        let commander = WindowStage(Color(ZTronCommanderTheme(), value: \.appBackgroundDark), scheme: .light).centerPixel()
        let brand = WindowStage(Color(ZTronCommanderTheme(), value: \.brand), scheme: .light).centerPixel()
        XCTAssertNotEqual(commander, brand, "precondition: the two catalog colours must differ")

        let provider = ZTronThemeProvider(initialValue: ZTronCommanderTheme())
        let stage = WindowStage(SecondaryActionMaterial().environmentObject(provider), scheme: .light)
        XCTAssertEqual(stage.centerPixel(), commander)

        provider.replaceTheme(with: BrandOnlyTheme())
        stage.settle()
        XCTAssertEqual(stage.centerPixel(), brand)
    }

    @MainActor
    func testGradientViewsRenderInBothSchemes() throws {
        guard #available(iOS 16, *) else { throw XCTSkip("ImageRenderer needs iOS 16") }
        let theme = ZTronCommanderTheme().erasedToAnyTheme()

        var app: [ColorScheme: Pixel] = [:]
        var sheet: [ColorScheme: Pixel] = [:]
        for scheme in [ColorScheme.light, .dark] {
            app[scheme] = try imagePixel(of: AppBackground(theme: theme, glowIntensity: .constant(1)), scheme: scheme)
            XCTAssertEqual(app[scheme]?.a, 255, "AppBackground is opaque in \(scheme)")

            sheet[scheme] = try imagePixel(of: SheetBackground(theme: theme), scheme: scheme)
            XCTAssertEqual(sheet[scheme]?.a, 255, "SheetBackground is opaque in \(scheme)")

            let glare = try imagePixel(of: Glare(theme: theme), scheme: scheme)
            XCTAssertTrue(glare.a > 0 && glare.a < 255, "Glare is a translucent gradient in \(scheme), got \(glare)")

            let alwaysDark = try imagePixel(of: Glare(theme: theme).alwaysDark(), scheme: scheme)
            XCTAssertTrue(alwaysDark.a > 0 && alwaysDark.a < 255, "Glare.alwaysDark() renders in \(scheme), got \(alwaysDark)")
        }
        XCTAssertNotEqual(app[.light], app[.dark], "AppBackground has distinct light/dark branches")
        XCTAssertNotEqual(sheet[.light], sheet[.dark], "SheetBackground has distinct light/dark branches")
    }

    @MainActor
    func testBareInitsAndModifiersRenderThroughThemeReader() throws {
        guard #available(iOS 16, *) else { throw XCTSkip("ImageRenderer needs iOS 16") }
        let provider = ZTronThemeProvider(initialValue: ZTronCommanderTheme())

        XCTAssertEqual(try imagePixel(of: AppBackground().environmentObject(provider), scheme: .dark).a, 255)
        XCTAssertEqual(try imagePixel(of: SheetBackground().environmentObject(provider), scheme: .dark).a, 255)
        XCTAssertGreaterThan(try imagePixel(of: SecondaryActionMaterial().environmentObject(provider), scheme: .dark).a, 0)
        let glare = try imagePixel(of: Glare().environmentObject(provider), scheme: .dark)
        XCTAssertTrue(glare.a > 0 && glare.a < 255, "got \(glare)")

        // The zero-argument modifiers resolve the default theme and need no provider.
        XCTAssertEqual(try imagePixel(of: Color.clear.gradientAppBackground(), scheme: .dark).a, 255)
        XCTAssertEqual(try imagePixel(of: Color.clear.sheetBackground(), scheme: .light).a, 255)
        XCTAssertEqual(try imagePixel(of: Color.clear.appBackground(), scheme: .light).a, 255)
    }

    // MARK: - Helpers

    @available(iOS 16, *)
    @MainActor
    private func imagePixel<V: View>(of view: V, scheme: ColorScheme) throws -> Pixel {
        let renderer = ImageRenderer(content: view.environment(\.colorScheme, scheme).frame(width: 200, height: 200))
        renderer.scale = 1
        let image = try XCTUnwrap(renderer.uiImage, "ImageRenderer produced no image")
        return try XCTUnwrap(Pixel(image: image, x: 100, y: 100))
    }
}

/// A live window hosting one SwiftUI view, captured through `CALayer.render(in:)`.
@MainActor
private final class WindowStage {
    private let window: UIWindow

    init<V: View>(_ content: V, scheme: ColorScheme) {
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        window.overrideUserInterfaceStyle = scheme == .dark ? .dark : .light
        window.backgroundColor = .clear
        let host = UIHostingController(rootView: content.environment(\.colorScheme, scheme).ignoresSafeArea())
        host.view.backgroundColor = .clear
        window.rootViewController = host
        window.makeKeyAndVisible()
        settle()
    }

    func settle() {
        window.rootViewController?.view.setNeedsLayout()
        window.rootViewController?.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.25))
    }

    func centerPixel() -> Pixel {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = false
        let image = UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { context in
            window.layer.render(in: context.cgContext)
        }
        return Pixel(image: image, x: 100, y: 100) ?? Pixel(r: 0, g: 0, b: 0, a: 0)
    }
}

private struct Pixel: Equatable, CustomStringConvertible {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8

    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        (self.r, self.g, self.b, self.a) = (r, g, b, a)
    }

    /// Reads one pixel (top-left origin, in image pixels) by drawing the image into a
    /// 1×1 RGBA8 context offset so that the wanted pixel lands on it.
    init?(image: UIImage, x: Int, y: Int) {
        guard let cg = image.cgImage else { return nil }
        var bytes = [UInt8](repeating: 0, count: 4)
        let drawn: Bool = bytes.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ) else { return false }
            context.interpolationQuality = .none
            let width = CGFloat(cg.width), height = CGFloat(cg.height)
            context.draw(cg, in: CGRect(x: -CGFloat(x), y: -(height - 1 - CGFloat(y)), width: width, height: height))
            return true
        }
        guard drawn else { return nil }
        self.init(r: bytes[0], g: bytes[1], b: bytes[2], a: bytes[3])
    }

    var description: String { String(format: "#%02X%02X%02X@%d", r, g, b, a) }
}

/// A theme whose every colour is the catalog's `brand`, so replacing the Commander theme
/// with it produces a visibly different pixel.
private struct BrandOnlyTheme: ZTronTheme {
    struct Colors: ZTronColor {
        let brand = "brand"
        let label = "brand"
        let appBackground = "brand"
        let appBackgroundDark = "brand"
        let appBackgroundLight = "brand"
        let appBackgroundVoid = "brand"
        let appBackgroundLavender = "brand"
        let visitedMaterial = "brand"
        let sunsetSky = "brand"
        let disabled = "brand"
    }

    var colorSet = Colors()
    var fontSet = ZTronCommanderTheme.Font()
}
