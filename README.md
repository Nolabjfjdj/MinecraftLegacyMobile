# MinecraftLegacyMobile

An independent project exploring a native iOS port of the Minecraft: Legacy Console Edition experience, with Android and Meta Quest 2 as possible later targets.

## Current status

**Stage 2 — Native bridge and Metal rendering proof of concept (CI build passed; simulator runtime test pending)**

- [x] Create the native SwiftUI iOS app.
- [x] Confirm the original SwiftUI-only app builds in GitHub Actions.
- [x] Add a minimal Objective-C++ wrapper containing a small C++ frame counter.
- [x] Expose the wrapper to Swift through a bridging header.
- [x] Add a button that calls the native code and displays its frame count.
- [x] Confirm the native bridge build passes.
- [x] Add an initial MetalKit render-pass test that clears a native render surface.
- [x] Verify the MetalKit code compiles in GitHub Actions.
- [x] Pause the Metal preview while the app is inactive and log scene lifecycle changes.
- [x] Add a placeholder C++ start/stop lifecycle tied to the app's active state.
- [x] Stop the placeholder core if its SwiftUI view disappears.
- [x] Record an initial technical and licensing assessment of the MCLCE-iOS reference.
- [ ] Run the app and test the Metal surface and native counter in the iOS Simulator or on a device.
- [ ] Complete source provenance, license, and dependency review before selecting an engine.

The latest CI build passed with Xcode 16.4 (build 16F6) and iOS Simulator SDK 18.5. The project targets iOS 16.0 or later. A successful compile does not yet confirm runtime behavior on a simulator or device.

The bridge and Metal preview are integration tests only. The C++ lifecycle is a placeholder, not the actual game engine. They do not contain the Minecraft engine, gameplay, or original game assets. The Metal preview clears a render surface; it does not draw Minecraft graphics.

## Planned direction

1. **iOS first:** maintain a reproducible native build and investigate a lawful route to engine integration.
2. **Android:** reuse genuinely platform-independent components where technically possible.
3. **Meta Quest 2:** first investigate running an Android build in a virtual screen; a full VR mode would be a separate, later engineering effort.

C++ can help share game logic across platforms, but platform-specific graphics, audio, input, filesystem, and networking code may need adaptation.

## Build

Open `ios/MinecraftLegacyMobile.xcodeproj` in Xcode on macOS and select the `MinecraftLegacyMobile` scheme. GitHub Actions builds the project for the iOS Simulator on pushes to `main`, pull requests, and manual runs.

## Legal and project status

This is an unofficial, independent project and is not affiliated with or endorsed by Mojang or Microsoft. The repository does not include leaked game source code or original Minecraft assets. Any future use or distribution of third-party code, game code, or assets must be assessed against the applicable rights and licenses before integration or release.

See [the legal notes](docs/LEGAL.md), [the roadmap](docs/ROADMAP.md), and [the engine porting audit](docs/ENGINE_PORTING.md).
