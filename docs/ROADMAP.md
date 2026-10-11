# Roadmap

## Stage 0 — Reproducible iOS foundation

- [x] Add a minimal native SwiftUI app.
- [x] Confirm the initial SwiftUI-only app builds in GitHub Actions.
- [x] Configure automatic iOS Simulator builds on pushes to main and pull requests.
- [ ] Verify the updated build after adding the native bridge.
- [ ] Document the exact Xcode and SDK versions reported by CI.

## Stage 1 — Technical and rights audit

- [x] Record MCLCE-iOS as a technical reference and note its stated licensing uncertainty.
- [ ] Review candidate porting repositories and their licenses in detail.
- [ ] Inventory engine dependencies and platform-specific APIs.
- [ ] Identify graphics, audio, input, storage, and networking boundaries.
- [ ] Determine which code and assets can be used with appropriate permission.
- [ ] Choose a supported graphics path for iOS only after reviewing the actual engine.

## Stage 2 — Native bridge proof of concept

- [x] Add a minimal Objective-C++ wrapper containing a small C++ core.
- [x] Expose the wrapper to Swift through an Objective-C bridging header.
- [x] Add an on-screen button that calls the C++ frame counter.
- [ ] Confirm the updated project compiles in GitHub Actions.
- [ ] Test the counter in a running app on the iOS Simulator or a physical device.
- [ ] Add lifecycle handling and logging before integrating any eligible engine.

## Later platforms

- Android ARM64 is a later target.
- Meta Quest 2 starts as an Android screen-mode target; stereoscopic VR and controller tracking are separate future work.
