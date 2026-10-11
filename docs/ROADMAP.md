# Roadmap

## Stage 0 — Reproducible iOS foundation

- [x] Add a minimal native SwiftUI app.
- [x] Configure automatic iOS Simulator builds on pushes to main and pull requests.
- [x] Add standalone C++ core tests to CI.
- [x] Record CI toolchain details: Xcode 16.4 (build 16F6), iOS Simulator SDK 18.5, deployment target iOS 16.0.
- [ ] Confirm a simulator install and app launch through CI.

## Stage 1 — Technical and rights audit

- [x] Record MCLCE-iOS as a technical reference and note its stated licensing uncertainty.
- [x] Document why console-specific platform layers are not directly portable to iOS.
- [ ] Obtain clear permission/license terms before reusing candidate engine code.
- [ ] Inventory dependencies and platform-specific APIs once an eligible source base is identified.
- [ ] Record licenses and provenance for every third-party component and asset.

## Stage 2 — Native bridge proof of concept

- [x] Add a minimal Objective-C++ wrapper containing a small C++ core.
- [x] Separate the placeholder C++ core from the Objective-C++ bridge in `Engine/Core/LegacyEngineCore.hpp`.
- [x] Test core start/stop behavior, frame counting, and restart behavior in CI.
- [x] Expose the wrapper to Swift through a bridging header.
- [x] Add an on-screen button that calls the C++ frame counter.
- [x] Add a MetalKit render-pass proof of concept that clears a native render surface.
- [x] Pause Metal rendering when the app is inactive and connect placeholder lifecycle to SwiftUI.
- [x] Add a CI step that boots an iPhone simulator, installs the app, and attempts to launch it.
- [ ] Confirm the simulator launch step succeeds.
- [ ] Test the counter and Metal surface on a simulator or physical device.

## Stage 3 — Select and integrate a permitted engine base

- [ ] Confirm applicable license or written permission for the engine source.
- [ ] Build the eligible upstream engine without game assets.
- [ ] Map its rendering, audio, input, storage, lifecycle, and networking interfaces.
- [ ] Integrate one subsystem at a time and keep CI reproducible.
- [ ] Load game content only from assets the user has rights to use.

## Later platforms

- Android ARM64 is a later target.
- Meta Quest 2 starts as an Android screen-mode target; stereoscopic VR and controller tracking are separate future work.
