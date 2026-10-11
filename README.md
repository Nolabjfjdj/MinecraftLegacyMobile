# MinecraftLegacyMobile

An independent project exploring a native iOS port of the Minecraft: Legacy Console Edition experience, with Android and Meta Quest 2 as possible later targets.

## Current status

**Stage 0 — iOS foundation**

- [x] Create the repository and initial project structure.
- [ ] Verify the native iOS starter app builds in GitHub Actions.
- [ ] Audit available porting projects, their licenses, dependencies, and technical status.
- [ ] Establish what code and assets may lawfully be reused.
- [ ] Evaluate the original engine's platform-specific dependencies before attempting integration.

The initial app is only a build-system proof of concept. It does not contain the Minecraft engine, gameplay, or original game assets.

## Planned direction

1. **iOS first:** establish a reproducible native build and investigate a lawful route to engine integration.
2. **Android:** reuse genuinely platform-independent components where technically possible.
3. **Meta Quest 2:** first investigate running an Android build in a virtual screen; a full VR mode would be a separate, later engineering effort.

C++ can help share game logic across platforms, but platform-specific graphics, audio, input, filesystem, and networking code may need adaptation.

## Build

Open `ios/MinecraftLegacyMobile.xcodeproj` in Xcode on macOS and select the `MinecraftLegacyMobile` scheme. The GitHub Actions workflow also checks that the starter app builds for the iOS Simulator.

## Legal and project status

This is an unofficial, independent project and is not affiliated with or endorsed by Mojang or Microsoft. The repository does not include leaked game source code or original Minecraft assets. Any future use or distribution of third-party code, game code, or assets must be assessed against the applicable rights and licenses before integration or release.

See [the legal notes](docs/LEGAL.md) and [the roadmap](docs/ROADMAP.md).
