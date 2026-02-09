## Blip — iOS Counter App

### Build & Run
- Xcode project generated via `xcodegen` from `project.yml`
- Regenerate after adding/removing files: `xcodegen generate`
- Build: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Blip.xcodeproj -scheme Blip -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -quiet build`
- Bundle ID: `com.izaro.blip`
- Target: iOS 17+, SwiftUI lifecycle, SwiftData persistence

### Architecture
- MVVM-light: SwiftData `@Model` + SwiftUI views with `@Query`
- No navigation stack — flat layout with sheets for editing
- Counters displayed as colored cards with flip clock digits
- App Group (`group.com.izaro.blip`) for shared data access between app and widget extension
- SwiftData store lives in the App Group container (`Shared/SharedModelContainer.swift`); single cached `ModelContainer` shared across app and widget extension

### Data Model (`Counter.swift`)
- `@Model` with: id, title, value, stepIncrement, goal?, colorName, resetValue, resetFrequency, lastResetDate, createdAt, sortOrder, digitCount, lastUpdatedDate
- `ResetFrequency` enum: never, daily, weekly, monthly
- Adding/removing model properties requires uninstalling the app (no migration configured)

### Key Components
- `FlipClockView` — Animated flip clock digits adapted from elpassion/FlipClock-SwiftUI approach. Takes `value: Int` and `digitCount: Int`, pads with leading zeros.
- `ColorHelper` — 12 ultra-modern Tailwind-inspired color presets (coral, tangerine, amber, emerald, teal, sky, cobalt, indigo, violet, fuchsia, slate, zinc) defined via hex values. Supports custom hex colors (`#RRGGBB`), legacy name mapping for old system colors, `Color(hex:)` initializer, and `.hexString` computed property.
- `BlipApp` — Auto-reset logic runs on launch, checking reset boundaries per counter. Sets `lastUpdatedDate` to the reset boundary (midnight for daily, start of week/month for weekly/monthly). Includes one-time migration from default store to App Group location.
- `WidgetReloader` — Debounced wrapper around `WidgetCenter.shared.reloadAllTimelines()` with 0.5s coalescing. All views use `WidgetReloader.requestReload()` instead of calling WidgetKit directly.

### Widget Extension (`BlipWidget/`)
- WidgetKit lock screen widgets using `AppIntentConfiguration`
- Two widgets in `BlipWidgetBundle`:
  - **Blip Counter** (`BlipWidget`) — single counter, supports `accessoryCircular` and `accessoryInline`
  - **Blip Counters** (`BlipMultiWidget`) — multi-counter picker, supports `accessoryRectangular` (up to 3 counters)
- `SelectCounterIntent` / `SelectCountersIntent` — AppIntents for counter selection via `CounterEntityQuery`
- `BlipWidgetProvider` / `BlipMultiWidgetProvider` — timeline providers with 30-minute refresh
- Views trigger debounced widget reloads via `WidgetReloader.requestReload()`
- Widget bundle ID: `com.izaro.blip.widget`

### Simulator Workflow
```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcrun simctl boot "iPhone 17 Pro"
xcrun simctl install "iPhone 17 Pro" "$(find ~/Library/Developer/Xcode/DerivedData/Blip-*/Build/Products/Debug-iphonesimulator -name 'Blip.app' -maxdepth 1)"
xcrun simctl launch "iPhone 17 Pro" com.izaro.blip
```
