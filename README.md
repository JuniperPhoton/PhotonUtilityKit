# PhotonUtilityKit

A Swift Package shared among my apps — including MyerList, MyerTidy, MyerSplash and Photon AI Translator — providing common helpers and SwiftUI components for iOS, macOS, watchOS and tvOS.

## Requirements

- Swift 5.7+
- iOS 16 / macOS 13 / watchOS 9 / tvOS 16 or later

## Installation

Add the package via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/JuniperPhoton/PhotonUtilityKit.git", branch: "main")
]
```

Three library products are available, all containing the same targets — pick the linkage you need:

| Product | Linkage |
| --- | --- |
| `PhotonUtilityKit` | Automatic |
| `PhotonUtilityKit-Static` | Static |
| `PhotonUtilityKit-Dynamic` | Dynamic |

Then import the modules you use:

```swift
import PhotonUtility
import PhotonUtilityView
import PhotonLegacyCompat
```

## Modules

### PhotonUtility

Foundation-level utilities with no UI components of their own:

- **Extensions** — for `Array`, `Collection`, `Date`, `Color`, `URL`, `UserDefaults`, `View` and more.
- **Compat helpers** — availability-gated wrappers for newer APIs (`onChange`, geometry group, hover effects, `UIImageReader`, WidgetCenter, login items, etc.) so callers don't have to sprinkle `#available` checks.
- **App services** — pasteboard access (`AppPasteboard`), orientation locking (`AppOrientationLocker`), screen-lock timer, keyboard frame observing, window/screenshot services on macOS, haptic/sound feedback (`AppFeedback`).
- **Misc** — easing functions, grid calculation, link detection, text extraction, file IO helpers, security-scoped URL access (`ScopedURLContent`), logging (`LibLogger`), and a minimal Supabase REST client (`PhotonSupabaseClient`).

### PhotonUtilityView

Reusable SwiftUI components built on top of `PhotonUtility`:

- `Toast` / `AppToast` — toast presentation driven by an observable controller.
- `FullscreenPresentation` — present arbitrary fullscreen content over a root view with custom transitions.
- `AppSegmentTabBar` — customizable segmented tab bar.
- `ActionButton`, `AnimatedNumberView`, `IndicatorView`, `MenuPicker`, `BottomSheet`, `StickyHeaderFooterScrollView`, `UnevenRoundedRectangle` and more.
- Platform bridges: `UIPageView` (iOS), `NSPageView` (macOS), `BridgedPageView`, `ScrollViewBridge`, and text view compatibility wrappers.

### PhotonLegacyCompat

Compatibility layer for adopting OS 26 Liquid Glass APIs while still supporting older OS versions — `liquidGlassIfAvailable`, glass button/container helpers, toolbar item, scroll edge effect and symbol helpers that gracefully fall back on earlier systems.

## Demo

The `PhotonUtilityKitDemo` app (in `PhotonUtilityKit.xcworkspace`) showcases the components on iOS and macOS. Open the workspace in Xcode and run the `PhotonUtilityKitDemo` scheme.
