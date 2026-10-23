# ZTronTheme

## Migration note: restoring prior visual behavior for background modifiers

The zero-argument convenience modifiers below used to resolve their theme by reading
the `ZTronThemeProvider` injected into the environment via `.environmentObject(_:)`.
That made them crash with a SwiftUI fatal error ("No ObservableObject of type
`ZTronThemeProvider` found") whenever no provider was injected on an ancestor view —
which happens by default inside `.sheet`/`.fullScreenCover`/`.popover` content and in
Xcode Previews, since those don't automatically inherit the presenting view's
environment objects.

To eliminate that crash, the zero-argument overloads now resolve to a static default
theme (`ZTronThemeProvider.default()`) instead of reading the environment:

- `View.appBackground()`
- `View.gradientAppBackground()`
- `View.sheetBackground()`

If your app injects a custom `ZTronThemeProvider` via `.environmentObject(_:)` and
relied on these zero-argument modifiers picking up that theme automatically, you will
now see the default theme instead. To restore the exact prior visual behavior, pass
the theme explicitly from a view that already holds the provider, so the modifier
keeps reacting to `replaceTheme(with:)` the same way it did before:

```swift
struct MyView: View {
    @EnvironmentObject private var themeProvider: ZTronThemeProvider

    var body: some View {
        ContentView()
            .gradientAppBackground(theme: themeProvider.getTheme())
            // same pattern for:
            // .appBackground(theme: themeProvider.getTheme())
            // .sheetBackground(theme: themeProvider.getTheme())
    }
}
```

This is unchanged — and still reactive via the environment by default — for:

- `Glare()` / `Glare(theme:)`
- `SecondaryActionMaterial()` / `SecondaryActionMaterial(theme:)`
- `AppBackground()` / `AppBackground(theme:)`
- `SheetBackground()` / `SheetBackground(theme:)`

These still read from `@EnvironmentObject` when no `theme:` override is passed, so if
you call them bare (no `theme:`), make sure a `ZTronThemeProvider` is injected on an
ancestor view, or pass `theme:` explicitly to avoid a crash.

## Internal note: why `View` conformance lives in an extension, not the base declaration

`AppBackground`, `SheetBackground`, `Glare`, and `SecondaryActionMaterial` all declare
`View` conformance in an `extension X: View { ... }` block rather than on the type's
base declaration (`struct X: View { ... }`). This is deliberate, and matters under
Swift 6 language mode.

SwiftUI's `View` protocol implicitly carries `@MainActor` isolation. When a type
conforms to it on its *base* declaration, that isolation spreads to the *whole type* —
including `init` and stored-property defaults — not just `body`. Swift 6's Dynamic
Actor Isolation then inserts a runtime check at every call site the compiler can't
statically prove is already on the main actor. SwiftUI's internal async-render thread
(used for building parts of the view graph off the literal main thread, more
aggressively under rapid/overlapping updates — animations, fast toggling, scroll +
animation overlap) is a valid construction context by SwiftUI's own contract, but it
isn't literally `dispatch_get_main_queue()`, and that runtime check can fail against it
— crashing at `libdispatch.dylib\`_dispatch_assert_queue_fail` on the
`com.apple.SwiftUI.AsyncRenderer` thread, even though nothing is actually unsafe.

Declaring the conformance in an extension instead means only `body` (the actual
protocol requirement) is `@MainActor`-isolated; `init` and plain stored properties are
`nonisolated`, so constructing these views never triggers that check. Any other member
that still needs to touch main-actor-isolated state (here: the `theme` computed
property and `AppBackground`'s `glow(in:)`, both of which call
`ZTronThemeProvider.getTheme()`) is explicitly annotated `@MainActor` and kept in the
same extension as `body` — conformance-in-extension does **not** implicitly isolate
non-requirement members, so this has to be opted into by hand per member.

One residual wrinkle: these views also declare `@EnvironmentObject private var
themeProvider: ZTronThemeProvider`. `EnvironmentObject`'s own default initializer is
itself `@MainActor`-isolated, so a `nonisolated init` can't rely on the compiler's
implicit default-value synthesis for that property — each `init` assigns it explicitly.
A plain `self._themeProvider = EnvironmentObject<ZTronThemeProvider>()` compiles (as a
warning, not an error — `EnvironmentObject` is `@preconcurrency`, so Swift downgrades
enforcement for callers outside its own module to a diagnostic only), but leaving that
warning in place isn't necessary: wrapping the call in `MainActor.assumeIsolated { ... }`
resolves it cleanly —

```swift
self._themeProvider = MainActor.assumeIsolated {
    EnvironmentObject<ZTronThemeProvider>()
}
```

`assumeIsolated` asserts (via the executor-aware `checkIsolated()` mechanism, not the
literal-main-queue comparison described above) that the current context really is the
main actor, which holds here: constructing one of these View values only ever happens
on the main thread or on SwiftUI's async-render thread, both of which are the main
actor by SwiftUI's own contract. This is a different, correctly-implemented check from
the one that caused the original crash, so it doesn't reintroduce that risk.
