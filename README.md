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
