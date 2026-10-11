# Engine porting investigation

## Objective

Identify a technically feasible and legally permitted route toward a native iOS game runtime. The current SwiftUI app is only a build-system proof of concept; it is not the game engine.

## Gate 1: inspect candidate projects

Before copying or integrating code, record for each candidate:

- Repository and upstream maintainers.
- Explicit license and whether it covers the code and any bundled assets.
- Supported game edition and version.
- Current build instructions and whether a clean build can be reproduced.
- Required third-party libraries and their licenses.
- Existing platform-specific assumptions.
- Evidence that the code can run without proprietary files that we do not have permission to use.

A public repository is not automatically open source. If licensing or rights are unclear, treat the code and assets as unavailable for reuse until clarified.

## Gate 2: map platform dependencies

For any candidate whose use is permitted, classify dependencies into:

- **Core logic:** world data, gameplay rules, entities, inventory, and simulation.
- **Rendering:** graphics API, shaders, window and surface creation, GPU resource management.
- **Input:** touch, controller, keyboard, and pointer events.
- **Audio:** device output, mixing, streaming, and audio assets.
- **Storage:** saves, configuration, resource lookup, and writable directories.
- **Networking:** sockets, protocol code, platform APIs, and certificate handling.
- **Platform services:** lifecycle, pause/resume, memory warnings, and application events.

Do not assume a desktop or console renderer will work on iOS without adaptation.

## Gate 3: choose an integration boundary

Keep Swift responsible for iOS application lifecycle and native UI. If an eligible engine is written in C or C++, evaluate a small C-compatible interface that Swift can call through a bridging header. Keep platform-specific code behind narrow interfaces so Android can be considered later.

Do not introduce a large engine dependency until its license, build requirements, and platform assumptions are understood.

## Gate 4: prove one small milestone

The first engine-related milestone should be a minimal native rendering test on the iOS Simulator and then a real iPhone. It should demonstrate surface creation, frame updates, lifecycle handling, and clean shutdown before any attempt to load game content.

A simulator build does not prove that the same code will run correctly on a physical device.

## Current blockers

- No game engine is integrated.
- Candidate projects and their licenses still need a documented review.
- No game assets are included.
- The starter CI job verifies compilation only; it does not test runtime behavior or gameplay.

## Acceptance checklist

- [ ] Candidate source and asset rights reviewed.
- [ ] Dependency licenses recorded.
- [ ] Platform API and graphics requirements documented.
- [ ] Minimal native rendering proof built.
- [ ] Simulator and physical-device behavior tested.
- [ ] CI updated to build any newly introduced native components.
