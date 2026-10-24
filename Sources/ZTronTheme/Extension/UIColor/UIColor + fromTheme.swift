import UIKit

public extension UIColor {
    /// Resolves one of `set`'s colours as a `UIColor`: the UIKit counterpart of
    /// `SwiftUI.Color.init(_:value:)`.
    ///
    /// A `ZTronColor` names colour sets in an asset catalog; `bundle` is the bundle whose
    /// catalog is searched. `nil`, the default, means the package's own bundle, where the
    /// `ZTronCommanderTheme` colours live (a default argument cannot name `Bundle.module`
    /// directly, since SwiftPM generates it as internal). A custom theme whose colour sets
    /// ship with the host app passes the bundle that holds them, typically `.main`.
    ///
    /// A name that is not a colour set in that bundle resolves to `fallback` — `.clear` unless
    /// specified — instead of trapping. This used to be a force unwrap, which crashed with
    /// "Unexpectedly found nil while unwrapping an Optional value" for every custom
    /// `ZTronColor` whose names are not in the package catalog, i.e. for every theme other
    /// than the shipped one. The return type deliberately stays non-optional: every existing
    /// call site keeps compiling, it follows the package's own convention for missing
    /// resources (`UIFont(name:size:) ?? .systemFont(ofSize:)` in `ZTronCommanderTheme.Font`),
    /// and it degrades the same way the SwiftUI side already does — `Color(_:bundle:)`, hence
    /// `Color(_:value:)`, renders a missing name as fully transparent rather than crashing.
    /// A caller that must tell "missing" from "resolved" can pass a sentinel `fallback`, or
    /// call `UIColor(named:in:compatibleWith:)` directly.
    ///
    /// Nonisolated on purpose (see README, "Internal note: Swift 6 isolation"):
    /// `UITraitCollection.current` is a per-thread value and UIKit declares neither it nor
    /// `UIColor` main-actor isolated, so this can be called from any context.
    static func fromTheme(
        _ `set`: any ZTronColor,
        color: KeyPath<AnyZTronColor, String>,
        in bundle: Bundle? = nil,
        fallback: UIColor = .clear
    ) -> UIColor {
        return UIColor(
            named: set.erasedToAnyZTronColor()[keyPath: color],
            in: bundle ?? .module,
            compatibleWith: .current
        ) ?? fallback
    }
}
