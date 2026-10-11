import SwiftUI
import MetalKit

struct ContentView: View {
    @State private var engineBridge = LegacyEngineBridge()
    @State private var frameCount = 0

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 52))
                .accessibilityHidden(true)

            Text("MinecraftLegacyMobile")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("Prototype iOS")
                .font(.headline)

            Text(engineBridge.statusMessage())
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 320)

            VStack(alignment: .leading, spacing: 8) {
                Text("Test de rendu Metal")
                    .font(.headline)

                if MTLCreateSystemDefaultDevice() != nil {
                    MetalPreview()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text("Surface Metal active. Aucun contenu Minecraft n’est rendu.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Metal n’est pas disponible sur cet appareil.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 360, alignment: .leading)

            VStack(spacing: 8) {
                Text("Frames de test : \(frameCount)")
                    .font(.headline)
                    .monospacedDigit()

                Button {
                    engineBridge.advanceFrame()
                    frameCount = engineBridge.frameCount()
                } label: {
                    Label("Simuler une frame native", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            Text("Ce prototype valide le pont Swift/C++ et prépare le rendu natif. Le moteur et les ressources Minecraft ne sont pas intégrés.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 320)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MetalPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        view.delegate = context.coordinator
        view.clearColor = MTLClearColor(red: 0.025, green: 0.045, blue: 0.09, alpha: 1)
        view.colorPixelFormat = .bgra8Unorm
        view.preferredFramesPerSecond = 60
        view.isPaused = false
        view.enableSetNeedsDisplay = false
        return view
    }

    func updateUIView(_ view: MTKView, context: Context) {}

    func makeCoordinator() -> Renderer {
        Renderer()
    }

    private final class Renderer: NSObject, MTKViewDelegate {
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard
                let descriptor = view.currentRenderPassDescriptor,
                let drawable = view.currentDrawable,
                let commandQueue = view.device?.makeCommandQueue(),
                let commandBuffer = commandQueue.makeCommandBuffer(),
                let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else {
                return
            }

            encoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

#Preview {
    ContentView()
}
