# Engine porting investigation

## Objective

Identify a technically feasible and legally permitted route toward a native iOS game runtime. The current SwiftUI app and Objective-C++ bridge compile successfully, but the bridge only controls a test counter; it is not the game engine and does not run Minecraft.

## Current native boundary

The placeholder core lives in `Engine/Core/LegacyEngineCore.hpp`, a header-only C++ component with no Apple framework dependency. The Objective-C++ bridge includes it and exposes a narrow interface to Swift. This is a small architectural boundary, not proof that an existing console engine can be dropped into the app. Real engine code may require substantial platform adaptation, dependency work, and permission review.

## Candidate reference: MCLCE-iOS

Repository: https://github.com/dtentiion/MCLCE-iOS

Its public project description presents a native C++/CMake iOS port of TU19 Legacy Console Edition and describes a menu/runtime stack with Ruffle, wgpu/MetalANGLE, miniaudio, and Apple's GameController framework. Those are candidate-specific implementation details, not dependencies already installed in MinecraftLegacyMobile. Its public project description also says game assets are not included.

This is a valuable technical reference for understanding the scale of the porting work, but it is not automatically a reusable dependency. The candidate's contributing documentation has stated that the project-wide license is still to be decided. Do not copy or integrate its code unless the maintainers clarify the applicable license and permissions. The same provenance and rights review applies to every dependency and asset.

Sources:

- https://github.com/dtentiion/MCLCE-iOS
- https://github.com/dtentiion/MCLCE-iOS/blob/main/INSTALL.md
- https://github.com/dtentiion/MCLCE-iOS/blob/main/CONTRIBUTING.md

## Gate 1: inspect candidate projects

Before copying or integrating code, record for each candidate:

- Repository and upstream maintainers.
- Explicit license and whether it covers code and bundled assets.
- Supported game edition and version.
- Current build instructions and whether a clean build can be reproduced.
- Required third-party libraries and their licenses.
- Existing platform-specific assumptions.
- Evidence that the code can run without proprietary files that we do not have permission to use.

A public repository is not automatically open source. GitHub's own guidance notes that without a license, default copyright applies; a public repository being viewable or forkable is not the same as permission to reuse its contents. See https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository.

## Gate 2: map platform dependencies

For any candidate whose use is permitted, classify dependencies into:

- **Core logic:** world data, gameplay rules, entities, inventory, and simulation.
- **Rendering:** graphics API, shaders, window and surface creation, GPU resource management.
- **Input:** touch, controller, keyboard, and pointer events.
- **Audio:** device output, mixing, streaming, and audio assets.
- **Storage:** saves, configuration, resource lookup, and writable directories.
- **Networking:** sockets, protocol code, platform APIs, and certificate handling.
- **Platform services:** lifecycle, pause/resume, threads, timing, memory warnings, and application events.

Do not assume a desktop or console renderer will work on iOS without adaptation.

## Gate 3: choose an integration boundary

Keep Swift responsible for iOS application lifecycle and native UI. If an eligible engine is written in C or C++, evaluate a small C-compatible interface that Swift can call through a bridging header. Keep platform-specific code behind narrow interfaces so Android can be considered later.

The current `Engine/Core` component is only a placeholder showing where platform-independent C++ code can live. Do not introduce a large engine dependency until its license, build requirements, and platform assumptions are understood.

## Gate 4: prove one small milestone

The current CI workflow now compiles and runs the portable C++ tests, builds the app for the iOS Simulator, and attempts to boot an available iPhone simulator, install the app, and launch it. The new launch check must pass before we claim simulator launch validation. It still does not verify gameplay or prove the engine is integrated.

## Upstream source landscape

The public MCLCE organization describes `MinecraftConsoles` as a TU19-based community upstream intended to support further ports and forks. Its public repository metadata and documentation are useful for understanding the project structure, but public availability is not a license grant. Before any code is considered for this app, the upstream maintainers' terms and the provenance of the source must be clear.

A port or fork for a different console is useful as evidence of platform-specific adaptations, not as proof that its platform layer can be reused on iOS. Xbox UWP, Windows desktop, PlayStation, and iOS have different SDKs, graphics APIs, input and audio integrations, and packaging rules. The target should be a portable engine core with a separately implemented iOS platform layer, if the rights permit that approach.

## Current blockers

- No Legacy Console Edition engine is integrated; the current C++ code is only a frame counter.
- MCLCE-iOS is a technical reference, but its public contributing guide has stated that the project-wide license is still to be decided. Do not copy its code until its maintainers clarify permission.
- No game assets are included.
- Simulator launch is not yet confirmed by the new CI step.

## Initial subsystem inventory for the next eligible engine

- **Build:** CMake/toolchain, compiler standard, third-party packages, generated sources, and platform-specific build targets.
- **Lifecycle/platform:** startup, pause/resume, threads, timing, memory warnings, filesystem and save paths.
- **Graphics:** renderer API, shader formats, surface creation, GPU resources, and Metal compatibility.
- **UI:** menu runtime and its dependencies; keep original game assets separate from engine code.
- **Audio:** mixer/backend, streaming, codecs, and iOS audio-session interruptions.
- **Input:** controller mapping, touch controls, focus, and pause behavior.
- **Gameplay/world:** main loop, simulation ticks, entities, chunks, world loading, save compatibility, and client/server assumptions.
- **Networking:** socket APIs, multiplayer services, and platform-specific certificate handling.
- **Assets:** source and rights for every texture, sound, font, menu file, and other game resource.

This is a checklist for inspection, not a claim that the candidate engine has already been fully audited.

## Acceptance checklist

- [ ] Candidate source and asset rights reviewed.
- [ ] Dependency licenses recorded.
- [ ] Platform API and graphics requirements documented.
- [ ] Minimal native rendering proof built.
- [ ] Simulator and physical-device behavior tested.
- [ ] CI updated to build any newly introduced native components.
