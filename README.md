# MinecraftLegacyMobile

An independent project exploring a native iOS port of the Minecraft: Legacy Console Edition experience, with Android and Meta Quest 2 as possible later targets.

## Current status

**Stage 2 — Native bridge proof of concept (build verification pending)**

- [x] Create the native SwiftUI iOS app.
- [x] Confirm the original SwiftUI-only app builds in GitHub Actions.
- [x] Add a minimal Objective-C++ wrapper containing a small C++ frame counter.
- [x] Expose the wrapper to Swift through a bridging header.
- [x] Add a button that calls the native code and displays its frame count.
- [ ] Confirm the updated build passes in GitHub Actions.
- [ ] Audit candidate engine projects, dependencies, and applicable licenses.
- [ ] Establish a lawful and technically viable route to engine integration.

The native bridge is only an integration test. It does not contain the Minecraft engine, gameplay, or original game assets.

## Planned direction

1. **iOS first:** maintain a reproducible native build and investigate a lawful route to engine integration.
2. **Android:** reuse genuinely platform-independent components where technically possible.
3. **Meta Quest 2:** first investigate running an Android build in a virtual screen; a full VR mode would be a separate, later engineering effort.

C++ can help share game logic across platforms, but platform-specific graphics, audio, input, filesystem, and networking code may need adaptation.

## Build

Open `ios/MinecraftLegacyMobile.xcodeproj` in Xcode on macOS and select the `MinecraftLegacyMobile` scheme. GitHub Actions builds the project for the iOS Simulator on pushes to `main`, pull requests, and manual runs.

## Legal and project status

This is an unofficial, independent project and is not affiliated with or endorsed by Mojang or Microsoft. The repository does not include leaked game source code or original Minecraft assets. Any future use or distribution of third-party code, game code, or assets must be assessed against the applicable rights and licenses before integration or release.

See [the legal notes](docs/LEGAL.md), [the roadmap](docs/ROADMAP.md), and [the engine porting notes](docs/ENGINE_PORTING.md).
