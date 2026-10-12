# MinecraftLegacyMobile

An independent mobile voxel-game prototype exploring a native iOS-first route toward the Minecraft: Legacy Console Edition experience. Android is now included as an early OpenGL ES prototype.

## Current status

**Prototype stage — iOS Metal terrain demo and Android OpenGL ES terrain demo**

- [x] Native SwiftUI iOS application and Objective-C++ bridge.
- [x] Portable C++ placeholder core and standalone unit tests.
- [x] iOS Metal rendering of a generated voxel-style terrain.
- [x] iOS touch controls for camera movement and first-person navigation.
- [x] GitHub Actions workflow that builds the iOS Simulator app and an unsigned device IPA.
- [x] Initial native Android application using OpenGL ES 2.0.
- [x] Android terrain rendering with touch-based camera look and movement.
- [x] GitHub Actions workflow that builds and uploads a debug APK.
- [ ] Confirm both workflows complete successfully on GitHub Actions.
- [ ] Test the iOS IPA on a physical iPhone after signing it for installation.
- [ ] Test the Android APK on a physical Android device.
- [ ] Add block interaction, world editing, persistence, inventory, menus, audio, and more complete gameplay.
- [ ] Finish source provenance, license, and dependency review before integrating any third-party engine code.

## Important distinction

This repository is **not yet a complete Minecraft Legacy Console Edition port**. The current applications render a small procedurally generated voxel-style landscape and provide basic touch navigation. The original Legacy Console Edition engine, its menus, full gameplay systems, save compatibility, multiplayer, and original assets are not integrated.

The project does not include leaked game source code or original Minecraft assets. Any future engine integration must use code and assets with clear reuse permissions.

## Build artifacts

GitHub Actions runs on pushes to main, pull requests, and manual workflow dispatches.

- **iOS:** the iOS build workflow builds for the iOS Simulator, builds the device app without code signing, packages an unsigned IPA, and attempts to install and launch the app in an available iPhone simulator.
- **Android:** the Android build workflow compiles the Android prototype and uploads app-debug.apk.

To download a build, open the repository's Actions tab, select a successful workflow run, and download its artifact. Artifacts are retained for 14 days.

An unsigned IPA is a build package, not a ready-to-install signed application. It must be signed using an appropriate signing method before it can be installed on an iPhone. The Android debug APK is debug-signed by the Android build tools and is intended for testing, not store distribution.

## Architecture and next steps

- **iOS:** SwiftUI application lifecycle, Metal rendering, Objective-C++ bridge, and portable C++ components.
- **Android:** Kotlin activity and OpenGL ES 2.0 renderer. This is an initial platform prototype; the Android renderer does not yet share the iOS renderer or a complete game engine.
- **Next:** validate the CI artifacts, test on devices, then implement interaction and persistence before integrating any eligible third-party engine.

C++ can help share game logic across platforms, but graphics, audio, input, filesystem, and networking code still require platform-specific work.

## Legal and project status

This is an unofficial, independent project and is not affiliated with or endorsed by Mojang or Microsoft. Any future use or distribution of third-party code, game code, or assets must be assessed against the applicable rights and licenses before integration or release.

See the legal notes, roadmap, and engine porting audit in the docs directory.
