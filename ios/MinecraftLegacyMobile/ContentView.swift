import SwiftUI
import MetalKit
import OSLog
import simd
import UIKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var engineBridge = LegacyEngineBridge()
    @State private var frameCount = 0
    @State private var engineRunning = false
    @State private var isFirstPerson = false
    @State private var movementX: Float = 0
    @State private var movementY: Float = 0
    @State private var jumpRequest = 0
    private let lifecycleLogger = Logger(subsystem: "MinecraftLegacyMobile", category: "Lifecycle")

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 42))
                .accessibilityHidden(true)

            Text("MinecraftLegacyMobile")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("Terrain voxel • rendu Metal")
                .font(.headline)

            ZStack(alignment: .bottomLeading) {
                MetalPreview(
                    isActive: scenePhase == .active,
                    bridge: engineBridge,
                    isFirstPerson: isFirstPerson,
                    movementX: movementX,
                    movementY: movementY,
                    jumpRequest: jumpRequest
                )
                if isFirstPerson {
                    VirtualJoystick { x, y in
                        movementX = x
                        movementY = y
                    }
                    .padding(14)
                }
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(isFirstPerson ? "Joystick gauche pour avancer • glisse ailleurs pour regarder" : "Glisse pour tourner autour du terrain • pince pour zoomer")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if isFirstPerson {
                Button {
                    jumpRequest += 1
                } label: {
                    Label("Sauter", systemImage: "arrow.up")
                }
                .buttonStyle(.borderedProminent)
            }

            Button {
                isFirstPerson.toggle()
            } label: {
                Label(isFirstPerson ? "Revenir en vue extérieure" : "Passer en vue à la première personne", systemImage: isFirstPerson ? "view.3d" : "person.fill")
            }
            .buttonStyle(.borderedProminent)

            Text(engineBridge.statusMessage())
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 340)

            HStack {
                Label("\(engineBridge.meshVertexCount()) sommets", systemImage: "cube.transparent")
                Spacer()
                Label("\(engineBridge.meshIndexCount() / 3) triangles", systemImage: "triangle")
            }
            .font(.caption.monospacedDigit())
            .frame(maxWidth: 340)

            Text("Frames : \(frameCount)")
                .font(.headline)
                .monospacedDigit()

            Button {
                engineBridge.advanceFrame()
                frameCount = engineBridge.frameCount()
            } label: {
                Label("Tester une frame native", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!engineRunning)

            Text("Prototype de terrain voxel. Le moteur original de Minecraft Legacy Console Edition et les commandes de jeu restent à implémenter.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 340)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            updateEngineLifecycle(for: scenePhase)
        }
        .onChange(of: scenePhase) { phase in
            lifecycleLogger.info("Scene phase changed: \(String(describing: phase), privacy: .public)")
            updateEngineLifecycle(for: phase)
        }
        .onDisappear {
            engineBridge.stop()
            engineRunning = false
            lifecycleLogger.info("Content view disappeared; engine core stopped")
        }
    }

    private func updateEngineLifecycle(for phase: ScenePhase) {
        if phase == .active {
            engineBridge.start()
        } else {
            engineBridge.stop()
        }

        engineRunning = engineBridge.isRunning()
    }
}

private struct VirtualJoystick: View {
    let onChange: (Float, Float) -> Void
    @State private var offset: CGSize = .zero
    private let radius: CGFloat = 34

    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.28))
                .frame(width: 112, height: 112)
                .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 2))
            Circle()
                .fill(.white.opacity(0.82))
                .frame(width: 48, height: 48)
                .offset(offset)
        }
        .frame(width: 112, height: 112)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let dx = value.translation.width
                    let dy = value.translation.height
                    let distance = sqrt(dx * dx + dy * dy)
                    let scale = distance > radius ? radius / distance : 1
                    offset = CGSize(width: dx * scale, height: dy * scale)
                    onChange(Float(offset.width / radius), Float(-offset.height / radius))
                }
                .onEnded { _ in
                    offset = .zero
                    onChange(0, 0)
                }
        )
        .accessibilityLabel("Joystick de déplacement")
    }
}

private struct MetalPreview: UIViewRepresentable {
    let isActive: Bool
    let bridge: LegacyEngineBridge
    let isFirstPerson: Bool
    let movementX: Float
    let movementY: Float
    let jumpRequest: Int

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        view.delegate = context.coordinator
        view.clearColor = MTLClearColor(red: 0.43, green: 0.67, blue: 0.88, alpha: 1)
        view.colorPixelFormat = .bgra8Unorm
        view.depthStencilPixelFormat = .depth32Float
        view.clearDepth = 1
        view.preferredFramesPerSecond = 60
        view.isPaused = !isActive
        view.enableSetNeedsDisplay = false

        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Renderer.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Renderer.handlePinch(_:)))
        view.addGestureRecognizer(pinch)
        return view
    }

    func updateUIView(_ view: MTKView, context: Context) {
        view.isPaused = !isActive
        context.coordinator.setFirstPerson(isFirstPerson)
        context.coordinator.setMovement(x: movementX, forward: movementY)
        context.coordinator.requestJump(jumpRequest)
    }

    func makeCoordinator() -> Renderer {
        Renderer(bridge: bridge)
    }

    fileprivate final class Renderer: NSObject, MTKViewDelegate {
        private let device: MTLDevice?
        private let commandQueue: MTLCommandQueue?
        private let pipelineState: MTLRenderPipelineState?
        private let depthState: MTLDepthStencilState?
        private let vertexBuffer: MTLBuffer?
        private let indexBuffer: MTLBuffer?
        private let indexCount: Int
        private let bridge: LegacyEngineBridge
        private var cameraYaw: Float = 0.63
        private var cameraPitch: Float = 0.5
        private var cameraDistance: Float = 60
        private var isFirstPerson = false
        private var movementX: Float = 0
        private var movementForward: Float = 0
        private var playerPosition = SIMD3<Float>(16, 27, 16)
        private var verticalVelocity: Float = 0
        private var isGrounded = true
        private var lastFrameTime: CFTimeInterval = 0
        private var lastJumpRequest = 0

        fileprivate func setFirstPerson(_ enabled: Bool) {
            guard isFirstPerson != enabled else { return }
            isFirstPerson = enabled
            cameraPitch = 0
            movementX = 0
            movementForward = 0
            if !enabled {
                playerPosition = SIMD3<Float>(16, 27, 16)
                verticalVelocity = 0
                isGrounded = true
            } else {
                let surface = Float(bridge.surfaceHeightAt(16, z: 16))
                playerPosition = SIMD3<Float>(16, surface + 1.7, 16)
                verticalVelocity = 0
                isGrounded = true
            }
        }

        fileprivate func setMovement(x: Float, forward: Float) {
            movementX = min(max(x, -1), 1)
            movementForward = min(max(forward, -1), 1)
        }

        fileprivate func requestJump(_ request: Int) {
            guard request != lastJumpRequest else { return }
            lastJumpRequest = request
            if isFirstPerson && isGrounded {
                verticalVelocity = 8
                isGrounded = false
            }
        }

        init(bridge: LegacyEngineBridge) {
            self.bridge = bridge
            device = MTLCreateSystemDefaultDevice()
            commandQueue = device?.makeCommandQueue()
            indexCount = Int(bridge.meshIndexCount())

            var pipeline: MTLRenderPipelineState?
            var depth: MTLDepthStencilState?
            var vertices: MTLBuffer?
            var indices: MTLBuffer?

            if let device,
               let vertexData = bridge.meshVertexData() as Data?,
               let indexData = bridge.meshIndexData() as Data?,
               !vertexData.isEmpty,
               !indexData.isEmpty,
               let vertexBufferCreated = vertexData.withUnsafeBytes({ bytes in
                   bytes.baseAddress.flatMap {
                       device.makeBuffer(bytes: $0, length: vertexData.count, options: .storageModeShared)
                   }
               }),
               let indexBufferCreated = indexData.withUnsafeBytes({ bytes in
                   bytes.baseAddress.flatMap {
                       device.makeBuffer(bytes: $0, length: indexData.count, options: .storageModeShared)
                   }
               }) {
                vertices = vertexBufferCreated
                indices = indexBufferCreated

                let shaderSource = """
                #include <metal_stdlib>
                using namespace metal;

                struct VertexIn {
                    float3 position [[attribute(0)]];
                    float3 normal [[attribute(1)]];
                    float blockType [[attribute(2)]];
                };

                struct VertexOut {
                    float4 position [[position]];
                    float3 normal;
                    float blockType;
                };

                struct Uniforms {
                    float4x4 mvp;
                };

                vertex VertexOut terrainVertex(VertexIn input [[stage_in]],
                                               constant Uniforms& uniforms [[buffer(1)]]) {
                    VertexOut output;
                    output.position = uniforms.mvp * float4(input.position, 1.0);
                    output.normal = input.normal;
                    output.blockType = input.blockType;
                    return output;
                }

                fragment float4 terrainFragment(VertexOut input [[stage_in]]) {
                    float3 baseColor;
                    if (input.blockType > 2.5) {
                        baseColor = float3(0.22, 0.62, 0.18);
                    } else if (input.blockType > 1.5) {
                        baseColor = float3(0.42, 0.27, 0.14);
                    } else {
                        baseColor = float3(0.48, 0.49, 0.51);
                    }
                    float3 lightDirection = normalize(float3(-0.45, 0.85, 0.35));
                    float lighting = max(dot(normalize(input.normal), lightDirection), 0.0) * 0.65 + 0.35;
                    return float4(baseColor * lighting, 1.0);
                }
                """

                if let library = try? device.makeLibrary(source: shaderSource, options: nil),
                   let vertexFunction = library.makeFunction(name: "terrainVertex"),
                   let fragmentFunction = library.makeFunction(name: "terrainFragment") {
                    let descriptor = MTLRenderPipelineDescriptor()
                    descriptor.vertexFunction = vertexFunction
                    descriptor.fragmentFunction = fragmentFunction
                    descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
                    descriptor.depthAttachmentPixelFormat = .depth32Float

                    let vertexDescriptor = MTLVertexDescriptor()
                    vertexDescriptor.attributes[0].format = .float3
                    vertexDescriptor.attributes[0].offset = 0
                    vertexDescriptor.attributes[0].bufferIndex = 0
                    vertexDescriptor.attributes[1].format = .float3
                    vertexDescriptor.attributes[1].offset = 12
                    vertexDescriptor.attributes[1].bufferIndex = 0
                    vertexDescriptor.attributes[2].format = .float
                    vertexDescriptor.attributes[2].offset = 24
                    vertexDescriptor.attributes[2].bufferIndex = 0
                    vertexDescriptor.layouts[0].stride = 28
                    descriptor.vertexDescriptor = vertexDescriptor

                    pipeline = try? device.makeRenderPipelineState(descriptor: descriptor)
                }

                let depthDescriptor = MTLDepthStencilDescriptor()
                depthDescriptor.depthCompareFunction = .less
                depthDescriptor.isDepthWriteEnabled = true
                depth = device.makeDepthStencilState(descriptor: depthDescriptor)
            }

            vertexBuffer = vertices
            indexBuffer = indices
            pipelineState = pipeline
            depthState = depth
            super.init()
        }

        @objc fileprivate func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view)
            cameraYaw -= Float(translation.x) * 0.008
            let pitchDelta = Float(translation.y) * 0.008
            if isFirstPerson {
                cameraPitch = min(max(cameraPitch - pitchDelta, -1.2), 1.2)
            } else {
                cameraPitch = min(max(cameraPitch + pitchDelta, -0.05), 1.25)
            }
            gesture.setTranslation(.zero, in: gesture.view)
        }

        @objc fileprivate func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            cameraDistance = min(max(cameraDistance / Float(gesture.scale), 25), 120)
            gesture.scale = 1
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard
                let vertexBuffer,
                let indexBuffer,
                let pipelineState,
                let depthState,
                let descriptor = view.currentRenderPassDescriptor,
                let drawable = view.currentDrawable,
                let commandBuffer = commandQueue?.makeCommandBuffer(),
                let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else {
                return
            }

            let now = CACurrentMediaTime()
            let deltaTime = lastFrameTime == 0 ? 0 : min(Float(now - lastFrameTime), 0.05)
            lastFrameTime = now
            if isFirstPerson && deltaTime > 0 {
                let forward = SIMD3<Float>(sin(cameraYaw), 0, cos(cameraYaw))
                let right = SIMD3<Float>(cos(cameraYaw), 0, -sin(cameraYaw))
                let input = forward * movementForward + right * movementX
                let magnitude = simd_length(input)
                if magnitude > 0.01 {
                    let step = simd_normalize(input) * (5 * deltaTime)
                    let nextX = min(max(playerPosition.x + step.x, 1), 30)
                    let nextZ = min(max(playerPosition.z + step.z, 1), 30)
                    let nextSurface = Float(bridge.surfaceHeightAt(NSInteger(nextX.rounded()), z: NSInteger(nextZ.rounded())))
                    if nextSurface + 1.7 <= playerPosition.y + 0.55 {
                        playerPosition.x = nextX
                        playerPosition.z = nextZ
                    }
                }
                verticalVelocity -= 20 * deltaTime
                playerPosition.y += verticalVelocity * deltaTime
                let groundHeight = Float(bridge.surfaceHeightAt(NSInteger(playerPosition.x.rounded()), z: NSInteger(playerPosition.z.rounded()))) + 1.7
                if playerPosition.y <= groundHeight {
                    playerPosition.y = groundHeight
                    verticalVelocity = 0
                    isGrounded = true
                } else {
                    isGrounded = false
                }
            }

            let aspect = max(Float(view.drawableSize.width / max(view.drawableSize.height, 1)), 0.1)
            let projection = perspectiveMatrix(verticalFOV: 1.05, aspect: aspect, near: 0.1, far: 200)
            let eye: SIMD3<Float>
            let target: SIMD3<Float>
            if isFirstPerson {
                eye = playerPosition
                let lookDirection = SIMD3<Float>(
                    sin(cameraYaw) * cos(cameraPitch),
                    sin(cameraPitch),
                    cos(cameraYaw) * cos(cameraPitch)
                )
                target = eye + lookDirection
            } else {
                target = SIMD3<Float>(16, 14, 16)
                let horizontalDistance = cameraDistance * cos(cameraPitch)
                eye = target + SIMD3<Float>(
                    sin(cameraYaw) * horizontalDistance,
                    sin(cameraPitch) * cameraDistance,
                    cos(cameraYaw) * horizontalDistance
                )
            }
            let viewMatrix = lookAtMatrix(eye: eye, target: target, up: SIMD3<Float>(0, 1, 0))
            let mvp = projection * viewMatrix

            var uniforms = mvp
            encoder.setRenderPipelineState(pipelineState)
            encoder.setDepthStencilState(depthState)
            encoder.setCullMode(.none)
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            encoder.setVertexBytes(&uniforms, length: MemoryLayout<simd_float4x4>.stride, index: 1)
            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: indexCount,
                indexType: .uint32,
                indexBuffer: indexBuffer,
                indexBufferOffset: 0
            )
            encoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

        private func perspectiveMatrix(verticalFOV: Float, aspect: Float, near: Float, far: Float) -> simd_float4x4 {
            let yScale = 1 / tan(verticalFOV * 0.5)
            let xScale = yScale / aspect
            let zScale = far / (near - far)
            return simd_float4x4(columns: (
                SIMD4<Float>(xScale, 0, 0, 0),
                SIMD4<Float>(0, yScale, 0, 0),
                SIMD4<Float>(0, 0, zScale, -1),
                SIMD4<Float>(0, 0, near * zScale, 0)
            ))
        }

        private func lookAtMatrix(eye: SIMD3<Float>, target: SIMD3<Float>, up: SIMD3<Float>) -> simd_float4x4 {
            let forward = simd_normalize(target - eye)
            let right = simd_normalize(simd_cross(forward, up))
            let correctedUp = simd_cross(right, forward)
            return simd_float4x4(columns: (
                SIMD4<Float>(right.x, correctedUp.x, -forward.x, 0),
                SIMD4<Float>(right.y, correctedUp.y, -forward.y, 0),
                SIMD4<Float>(right.z, correctedUp.z, -forward.z, 0),
                SIMD4<Float>(-simd_dot(right, eye), -simd_dot(correctedUp, eye), simd_dot(forward, eye), 1)
            ))
        }
    }
}

#Preview {
    ContentView()
}
