# MinecraftLegacyMobile

An independent project exploring a native iOS port of the Minecraft: Legacy Console Edition experience, with Android and Meta Quest 2 as possible later targets.

## Current status

**Stage 2 — Native bridge and Metal rendering proof of concept (CI build and simulator launch check configured)**

- [x] Create the native SwiftUI iOS app.
- [x] Confirm the original SwiftUI-only app builds in GitHub Actions.
- [x] Add a minimal Objective-C++ wrapper containing a small C++ frame counter.
- [x] Separate the placeholder C++ core into a platform-independent header under `Engine/Core`.
- [x] Add standalone C++ tests for start/stop behavior and frame counting.
- [x] Run the C++ tests in GitHub Actions before the iOS build.
- [x] Expose the wrapper to Swift through a bridging header.
- [x] Add a button that calls the native code and displays its frame count.
- [x] Add an initial MetalKit render-pass test that clears a native render surface.
- [x] Pause the Metal preview while the app is inactive and log scene lifecycle changes.
- [x] Add a placeholder C++ start/stop lifecycle tied to the app's active state.
- [ ] Confirm the app launches successfully in the iOS Simulator through CI.
- [ ] Manually test the Metal surface and native counter on a simulator or physical device.
- [ ] Complete source provenance, license, and dependency review before selecting an engine.

The CI workflow compiles and runs focused tests for the standalone C++ placeholder core, builds the app for the iOS Simulator, and now attempts to boot an available iPhone simulator, install the app, and launch it. The launch check is not considered passed until the workflow result confirms it. A successful build or launch does not prove gameplay works or that the Minecraft engine is integrated.

The C++ core is isolated from the Objective-C++ bridge in a header-only component. Its tests check stopped/running state, frame counting, and restart behavior. This is an architectural seam for future platform-independent code, not an integrated game engine. The bridge still only controls a placeholder frame counter. The Metal preview clears a render surface; it does not draw Minecraft graphics.

## Planned direction

1. **iOS first:** establish a reproducible build and simulator launch, then investigate a lawful route to engine integration.
2. **Engine integration:** proceed only when the code and dependencies needed for the chosen Legacy Console Edition base have clear reuse permissions.
3. **Android:** reuse genuinely platform-independent components where technically possible.
4. **Meta Quest 2:** first investigate running an Android build in a virtual screen; a full VR mode would be a separate, later engineering effort.

C++ can help share game logic across platforms, but platform-specific graphics, audio, input, filesystem, and networking code may need adaptation.

## Build

Open `ios/MinecraftLegacyMobile.xcodeproj` in Xcode on macOS and select the `MinecraftLegacyMobile` scheme. GitHub Actions runs the standalone C++ core tests, builds for the iOS Simulator, then attempts to install and launch the app in an available iPhone simulator.

## Legal and project status

This is an unofficial, independent project and is not affiliated with or endorsed by Mojang or Microsoft. The repository does not include leaked game source code or original Minecraft assets. Any future use or distribution of third-party code, game code, or assets must be assessed against the applicable rights and licenses before integration or release.

See [the legal notes](docs/LEGAL.md), [the roadmap](docs/ROADMAP.md), and [the engine porting audit](docs/ENGINE_PORTING.md).
