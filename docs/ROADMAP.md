# Roadmap

## Stage 0 — Reproducible iOS foundation

- [x] Add a minimal native SwiftUI app.
- [x] Confirm the initial SwiftUI-only app builds in GitHub Actions.
- [x] Configure automatic iOS Simulator builds on pushes to main and pull requests.
- [x] Verify the updated native bridge build (confirmed by the project owner).
- [x] Record CI toolchain details: Xcode 16.4 (build 16F6), iOS Simulator SDK 18.5, deployment target iOS 16.0.

## Stage 1 — Technical and rights audit

- [x] Record MCLCE-iOS as a technical reference and note its stated licensing uncertainty.
- [x] Record an initial review of the public MCLCE-iOS README, install guide, and contributing/licensing notes.
- [x] Document the public upstream source landscape and why console-specific platform layers are not directly portable to iOS.
- [ ] Inventory the selected engine's dependencies and platform-specific APIs after source rights are clear.
- [ ] Identify graphics, audio, input, storage, and networking boundaries.
- [ ] Determine which code and assets can be used with appropriate permission; no engine source has been copied.
- [ ] Choose a supported graphics path for iOS only after reviewing the actual engine and its permitted dependencies.

## Stage 2 — Native bridge proof of concept

- [x] Add a minimal Objective-C++ wrapper containing a small C++ core.
- [x] Expose the wrapper to Swift through an Objective-C bridging header.
- [x] Add an on-screen button that calls the C++ frame counter.
- [x] Confirm the updated project compiles.
- [ ] Test the counter in a running app on the iOS Simulator or a physical device.
- [x] Add an initial MetalKit render-pass proof of concept that clears a native render surface.
- [x] Confirm the Metal proof of concept compiles in CI.
- [x] Pause Metal rendering when the app is inactive and log scene lifecycle changes.
- [x] Add start/stop lifecycle handling to the placeholder C++ core and connect it to the SwiftUI scene phase.
- [x] Stop the placeholder core when its owning SwiftUI view disappears.
- [ ] Run the Metal proof of concept on the iOS Simulator or a physical device.
- [ ] Add engine-specific lifecycle handling only after an eligible engine and its license are identified.

## Later platforms

- Android ARM64 is a later target.
- Meta Quest 2 starts as an Android screen-mode target; stereoscopic VR and controller tracking are separate future work.
