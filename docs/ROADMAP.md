# Roadmap

## Stage 0 — Reproducible iOS foundation

- [x] Add a minimal native SwiftUI app.
- [ ] Run the iOS Simulator build in GitHub Actions.
- [ ] Fix any build errors found by CI.
- [ ] Document the exact Xcode and SDK versions used by CI.

## Stage 1 — Technical and rights audit

- [ ] Review candidate porting repositories and their licenses.
- [ ] Inventory engine dependencies and platform-specific APIs.
- [ ] Identify graphics, audio, input, storage, and networking boundaries.
- [ ] Determine which code and assets can be used with appropriate permission.
- [ ] Choose a supported graphics path for iOS only after reviewing the actual engine.

## Stage 2 — Engine feasibility prototype

- [ ] Build a small native C++ library independently of game code.
- [ ] Connect the library to the iOS app.
- [ ] Validate app lifecycle, logging, and input handling.
- [ ] Only then plan lawful integration of an engine.

## Later platforms

- Android ARM64 is a later target.
- Meta Quest 2 starts as an Android screen-mode target; stereoscopic VR and controller tracking are separate future work.
