## Blip

A minimal iOS counter app. Add multiple counters as colored cards, tap +/− to count, long-press to edit or delete.

### Features

- Multiple counters displayed as full-width colored cards
- Animated flip clock digits with configurable digit count (auto, 2, 3, or 4)
- 12 curated color presets (Tailwind-inspired palette) plus custom color picker
- Optional goal tracking with completion badge
- Last updated timestamp on each card
- Configurable step increment for +/− buttons
- Auto-reset (daily, weekly, monthly) with configurable reset value; timestamp shows reset boundary (e.g. 12:00am for daily)
- Data persistence with SwiftData
- Lock screen widgets (circular, rectangular, inline) via WidgetKit
- Multi-counter rectangular widget with goal progress display
- Dark theme

### Requirements

- iOS 17+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

### Setup

```bash
brew install xcodegen
xcodegen generate
open Blip.xcodeproj
```
