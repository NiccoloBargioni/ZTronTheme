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

## Migration note: `UIColor.fromTheme` no longer traps on unknown colour names

`UIColor.fromTheme(_:color:)` used to force-unwrap `UIColor(named:in:compatibleWith:)` against
the package's own asset catalog. That is fine for `ZTronCommanderTheme`, whose ten colour
names are all colour sets under `assets.xcassets/Commander Theme`, and a deterministic crash
("Unexpectedly found nil while unwrapping an Optional value") for every other `ZTronColor`:
a custom theme names colour sets that live in the host app's catalog, which this function
never searched.

The signature is now

```swift
static func fromTheme(
    _ set: any ZTronColor,
    color: KeyPath<AnyZTronColor, String>,
    in bundle: Bundle? = nil,     // nil: the package's own catalog, as before
    fallback: UIColor = .clear
) -> UIColor
```

- Existing calls such as `UIColor.fromTheme(theme.colorSet, color: \.brand)` compile unchanged
  and, for the Commander theme, return exactly what they did.
- A theme whose colour sets ship with the app passes the bundle that holds them:
  `UIColor.fromTheme(MyColors(), color: \.brand, in: .main)`. (`nil` rather than a
  `.module` default because SwiftPM generates `Bundle.module` as internal, which a public
  default argument may not reference.) The SwiftUI side, `Color(_:value:)`, still looks in
  the package catalog only.
- A name that is not a colour set in that bundle returns `fallback` (`.clear` by default)
  instead of crashing. `.clear` is what `Color(_:value:)` already renders for the same missing
  name, so a misnamed colour shows up the same way through both APIs: as nothing. Pass
  `fallback:` for a visible stand-in, or a sentinel to detect the miss. If you relied on the
  crash to catch typos in colour names during development, that signal is gone;
  `Tests/ZTronThemeTests/UIColorFromThemeTests.swift` shows how to assert that every name of
  a theme resolves.

The function stays `nonisolated`: `UITraitCollection.current` is a per-thread value and UIKit
marks neither it nor `UIColor` main-actor isolated (see the next note).

## Internal note: Swift 6 isolation (why `init` is nonisolated and `@EnvironmentObject` lives in `ThemeReader`)

This package compiles in Swift 6 language mode. Two kinds of runtime main-actor checks can
end up in a SwiftUI module built that way. In a process linked against the iOS 18 SDK or
newer, a failed check kills the process: `swift_task_isCurrentExecutor` cannot return
`false` there, it hands over to `swift_task_checkIsolated`, which for the main actor is
`dispatch_assert_queue(main)` and traps in `libdispatch _dispatch_assert_queue_fail`
("Block was expected to execute on queue [com.apple.main-thread]"); newer runtimes may
surface the same failure as an "unexpected executor" abort instead. On iOS 17 the same
entry point returns `false`.

1. **Explicit checks** — `MainActor.assumeIsolated`, `assertIsolated`,
   `preconditionIsolated`. An earlier revision called `MainActor.assumeIsolated` inside
   each view's `init` to build its `@EnvironmentObject` storage. That traps whenever a view
   is constructed off the main actor, on every iOS version (iOS 17 reports it as
   `Fatal error: Incorrect actor executor assumption`). The trap is in `init` — not in
   `.ignoresSafeArea()` and not in the `View` conformance, as this note previously
   claimed. `Tests/ZTronThemeTests/IsolationTests.swift` constructs every view from a
   detached task to keep it from coming back.
2. **Compiler-inserted checks** — a closure literal written in a main-actor context is
   inferred `@MainActor`. Such contexts are `body`, any `@MainActor` helper, and members
   of a *protocol* extension `extension View { … }`, which inherit `View`'s `@MainActor`
   unless marked `nonisolated` (the modifiers in `View + appBackground.swift` were this
   case). Members of `extension AppBackground: View` other than `body` are *not*
   isolated. SwiftUI is compiled in Swift 5 language mode, so when such a literal is
   passed to one of its un-annotated closure parameters — `GeometryReader { }`,
   `ZStack { }`, `.background { }` — the compiler emits `swift_task_isCurrentExecutor` +
   `swift_task_reportUnexpectedExecutor` at the closure's entry (SE-0423). This happens
   for every such literal, regardless of what it captures and regardless of whether the
   `View` conformance is on the type or in an extension. On iOS 17 a failed check only
   logs `warning: data race detected`; on iOS 18 and later it traps as described above.

Why this matters in practice: SwiftUI does not always evaluate view code on the main
thread. Field crash reports and Apple's WWDC25 session 266 ("Explore concurrency in
SwiftUI") show `ForEach` row closures in lazy containers, `ViewThatFits` candidates, whole
`body` getters during animations, `Layout`, `Shape.path(in:)` and animation interpolation
running on `com.apple.SwiftUI.AsyncRenderer`. A host-app row evaluated there constructs its
child views there — including `Glare()`, `AppBackground()` and whatever
`.gradientAppBackground()` builds — so a check in `init` or in a `body` closure of this
package is a crash waiting for the right animation.

The current design removes both kinds of check from the module entirely:

- `AppBackground`, `SheetBackground`, `Glare` and `SecondaryActionMaterial` declare
  `View` conformance in an extension, so only `body` is main-actor isolated. Their
  initializers store plain values and are nonisolated: they can be created from any
  context, exactly like SwiftUI's own views (`GeometryReader`, `ZStack`, … are
  `nonisolated struct`s in the SDK).
- `body` — the one place SwiftUI promises the main actor — is where the theme is
  resolved: the injected `theme:`, or, through the internal `ThemeReader` view, the one
  held by the `ZTronThemeProvider` in the environment. `ThemeReader` is the only type
  holding an `@EnvironmentObject`; it declares `View` on the type itself, so its
  initializer is main-actor isolated, and it is only ever created inside a `body`.
- The drawing itself (`layers(theme:)`, `glow(theme:in:)`) is declared outside the
  `View` extension, hence nonisolated, and receives the theme as a value. The
  `GeometryReader`/`ZStack` closures created there inherit no isolation, so no check is
  emitted for them.
- The `View` modifiers (`appBackground`, `gradientAppBackground`, `sheetBackground`) are
  explicitly `nonisolated`, like SwiftUI's own modifiers, for the same reason.
- `UIColor.fromTheme(_:color:in:fallback:)` is nonisolated for the same reason. It reads
  `UITraitCollection.current`, which UIKit's header documents as affecting only the current
  thread and does not mark `NS_SWIFT_UI_ACTOR` (nor is `UIColor`), so no `@MainActor` is
  needed and no check is emitted. `UIColorFromThemeTests` calls it from a detached task.
- `#Preview` blocks sit under `#if DEBUG`. The preview macro's closures are the only
  checked closures left; they exist only in debug builds and run only under Xcode.

`Scripts/check-no-executor-checks.sh` compiles the module to SIL with `DEBUG` undefined
(so the `#if DEBUG` previews are excluded), at both `-Onone` and `-O`, and fails if any of
these checks appears in any function body, compiler-generated thunks included. The GitHub
Actions workflow `.github/workflows/ci.yml` (job "Isolation check and tests") runs it on
every push and pull request as its own step ahead of `xcodebuild test`, so a reintroduced
check fails CI with the demangled names of the offending functions; also run it locally
after touching any `View` in this package. The unit tests cannot catch this class: in the
test host SwiftUI evaluates `body` on the main thread, so a reintroduced check passes there.

Two compiler facts this relies on, verified against Swift 6.4 / the iOS 27 SDK: members
declared inside `extension X: View` other than `body` are *not* main-actor isolated; and
`View.ignoresSafeArea`, `View.background(content:)`, `GeometryReader.init` and
`ZStack.init` are all `nonisolated` in the SDK, so calling them off the main actor is fine
by itself. With the iOS 18.0–18.2 SDKs (Xcode 16.0–16.2), `GeometryReader` and `ZStack`
were not yet declared `nonisolated`; there the calls from `layers(theme:)` are expected to
compile with preconcurrency warnings rather than errors, and still without any runtime
check. This was not verified locally (only Xcode 27 is installed).
