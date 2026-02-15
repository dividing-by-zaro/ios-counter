## Blip

A minimal, flip clock-style iOS counter app that supports lock screen widgets. Track macros, spending, or whatever with stylish cards that reset on your schedule.

<p align="center">
  <img src="screenshots/blip-1-counters-framed.png" width="200" />
  <img src="screenshots/blip-2-lock-framed.png" width="200" />
  <img src="screenshots/blip-3-multi-framed.png" width="200" />
</p>

### Features

- Multiple counters as colored cards with animated flip clock digits
- Auto-reset on a daily, weekly, or monthly schedule
- Optional goal tracking with progress display
- Lock screen widgets — single counter (circular/inline) and multi-counter (rectangular)

### Prerequisites

- A Mac (or anything that can run Xcode)
- An iPhone
- A cable to connect the two
- [Xcode](https://developer.apple.com/xcode/) installed
- An [Apple Developer account](https://developer.apple.com/) (free works, but app signatures expire after 7 days; $99/year for persistent apps)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

---

### Building & Sideloading onto Your Device

**1. Generate the Xcode project**

```bash
xcodegen generate
open Blip.xcodeproj
```

**2. Sign the app**

- Click on the top-level **Blip** project in the sidebar
- Go to **Signing & Capabilities**
- Check **Automatically manage signing**
- Set **Team** to your personal team (e.g. "Your Name (Personal Team)")
- Do this for both the **Blip** and **BlipWidgetExtension** targets

<img src="screenshots/sideloading-1-signing.png" width="600" />

**3. Connect your iPhone and build**

- Plug your iPhone into your Mac
- In the toolbar at the top of Xcode, select **Blip** and choose your phone from the device dropdown
- Click the play button (or press Cmd+R) to build and install

<img src="screenshots/sideloading-2-running.png" width="500" />

**4. Trust the developer profile on your phone**

The first time you sideload, iOS may block the app from opening. Go to **Settings > General > VPN & Device Management**, find your developer profile, and tap **Trust**.

---

### Building for Simulator

To build from the command line without a physical device:

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -project Blip.xcodeproj -scheme Blip \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```
