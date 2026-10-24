import XCTest
@testable import ZTronTheme
import SwiftUI
import UIKit

/// Regression tests for `UIColor.fromTheme(_:color:in:fallback:)`.
///
/// The function used to force-unwrap `UIColor(named:in:compatibleWith:)` against the package's
/// own asset catalog, so any `ZTronColor` whose names are not colour sets under
/// `assets.xcassets/Commander Theme` killed the process with "Unexpectedly found nil while
/// unwrapping an Optional value". These tests pin the replacement behaviour: unknown names
/// resolve to the fallback, the shipped Commander theme still resolves every colour from the
/// package catalog, the `in:` bundle is the catalog actually searched, and the function keeps
/// working off the main actor.
final class UIColorFromThemeTests: XCTestCase {

    /// All ten requirements of `ZTronColor`, so each test covers the whole colour set.
    private var allColors: [KeyPath<AnyZTronColor, String>] {
        [
            \.brand, \.label, \.appBackground, \.appBackgroundDark, \.appBackgroundLight,
            \.appBackgroundVoid, \.appBackgroundLavender, \.visitedMaterial, \.sunsetSky, \.disabled,
        ]
    }

    private let appearances: [UIUserInterfaceStyle] = [.light, .dark]

    /// A colour set as a host app would define it, naming colour sets in the app's own
    /// catalog. None of these names exists in the package catalog.
    private struct HostAppColors: ZTronColor {
        let brand = "host.brand"
        let label = "host.label"
        let appBackground = "host.app.background"
        let appBackgroundDark = "host.app.background.dark"
        let appBackgroundLight = "host.app.background.light"
        let appBackgroundVoid = "host.app.background.void"
        let appBackgroundLavender = "host.app.background.lavender"
        let visitedMaterial = "host.visited.material"
        let sunsetSky = "host.sunset.sky"
        let disabled = "host.disabled"
    }

    // MARK: - Unknown names

    /// Before the fix this test could not fail: the first iteration crashed the test run.
    func testUnknownNamesResolveToClearInsteadOfTrapping() {
        let theme = HostAppColors()
        for keyPath in allColors {
            let name = theme.erasedToAnyZTronColor()[keyPath: keyPath]
            XCTAssertNil(
                UIColor(named: name, in: .module, compatibleWith: .current),
                "precondition: '\(name)' must not be a colour set in the package catalog"
            )
            XCTAssertEqual(UIColor.fromTheme(theme, color: keyPath), .clear, name)
        }
    }

    func testUnknownNamesResolveToTheGivenFallback() {
        let theme = HostAppColors()
        XCTAssertEqual(UIColor.fromTheme(theme, color: \.label, fallback: .label), .label)
        XCTAssertEqual(UIColor.fromTheme(theme, color: \.brand, fallback: .systemPink), .systemPink)
    }

    // MARK: - Commander theme

    /// Every Commander colour is a colour set in the package catalog, and the lowest alpha in
    /// that catalog is 0.1, so a resolved alpha of 0 in either appearance would mean the
    /// fallback leaked through.
    func testCommanderThemeResolvesEveryColorFromThePackageCatalog() {
        let theme = ZTronCommanderTheme.Color()
        for keyPath in allColors {
            let name = theme.erasedToAnyZTronColor()[keyPath: keyPath]
            let color = UIColor.fromTheme(theme, color: keyPath)
            let expected = UIColor(named: name, in: .module, compatibleWith: .current)
            XCTAssertNotNil(expected, "precondition: '\(name)' is a colour set in the package catalog")
            for appearance in appearances {
                let traits = UITraitCollection(userInterfaceStyle: appearance)
                let resolved = color.resolvedColor(with: traits)
                XCTAssertEqual(resolved, expected?.resolvedColor(with: traits), "\(name), style \(appearance.rawValue)")
                XCTAssertGreaterThan(resolved.cgColor.alpha, 0, "\(name), style \(appearance.rawValue)")
            }
        }
    }

    // MARK: - Bundle argument

    /// The test bundle has no asset catalog, so a Commander name that resolves in the package
    /// bundle must not resolve there: `in:` selects the catalog that is searched.
    func testBundleArgumentSelectsTheCatalogSearched() {
        let theme = ZTronCommanderTheme.Color()
        let testBundle = Bundle(for: UIColorFromThemeTests.self)
        XCTAssertNil(
            UIColor(named: theme.brand, in: testBundle, compatibleWith: .current),
            "precondition: the test bundle has no '\(theme.brand)' colour set"
        )
        XCTAssertEqual(UIColor.fromTheme(theme, color: \.brand, in: testBundle), .clear)
        XCTAssertEqual(UIColor.fromTheme(theme, color: \.brand, in: testBundle, fallback: .label), .label)

        let fromPackage = UIColor.fromTheme(theme, color: \.brand, in: .module)
        XCTAssertGreaterThan(fromPackage.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).cgColor.alpha, 0)
    }

    // MARK: - Isolation

    /// The function is nonisolated and `UITraitCollection.current` is per thread, so it must
    /// work from a context that is not the main actor. As in `IsolationTests`, a regression
    /// here is not a soft failure but a trap.
    func testResolvesOffMainActor() async {
        await Task.detached {
            let brand = UIColor.fromTheme(ZTronCommanderTheme.Color(), color: \.brand)
            XCTAssertGreaterThan(brand.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).cgColor.alpha, 0)
            XCTAssertEqual(UIColor.fromTheme(HostAppColors(), color: \.brand), .clear)
        }.value
    }

    // MARK: - Parity with SwiftUI

    /// The `.clear` default mirrors SwiftUI: `Color(_:bundle:)` — hence the package's own
    /// `Color(_:value:)` — renders a missing name as fully transparent rather than trapping,
    /// so a theme degrades the same way whichever API resolves it.
    @MainActor
    func testFallbackMatchesWhatSwiftUIRendersForTheSameMissingName() throws {
        guard #available(iOS 16, *) else { throw XCTSkip("ImageRenderer needs iOS 16") }
        let theme = HostAppColors()
        XCTAssertEqual(try centerAlpha(of: Color(theme, value: \.brand)), 0, "SwiftUI renders the missing name as transparent")
        XCTAssertEqual(try centerAlpha(of: Color(uiColor: UIColor.fromTheme(theme, color: \.brand))), 0)

        // Same pipeline, a name that exists: proves the sampler sees opaque content.
        let commander = ZTronCommanderTheme.Color()
        XCTAssertEqual(try centerAlpha(of: Color(uiColor: UIColor.fromTheme(commander, color: \.brand))), 255)
    }

    /// Alpha (0...255) of the centre pixel of `view` rasterised at 200×200, scale 1.
    @available(iOS 16, *)
    @MainActor
    private func centerAlpha<V: View>(of view: V) throws -> UInt8 {
        let renderer = ImageRenderer(content: view.frame(width: 200, height: 200))
        renderer.scale = 1
        let image = try XCTUnwrap(renderer.uiImage, "ImageRenderer produced no image")
        let cg = try XCTUnwrap(image.cgImage)
        var bytes = [UInt8](repeating: 0, count: 4)
        try bytes.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(
                data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ))
            context.interpolationQuality = .none
            // Offset so that the centre pixel of the image lands on the 1×1 context.
            context.draw(cg, in: CGRect(x: -100, y: -(CGFloat(cg.height) - 1 - 100), width: CGFloat(cg.width), height: CGFloat(cg.height)))
        }
        return bytes[3]
    }
}
