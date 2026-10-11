import SwiftUI

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

            Text("Ce test valide le pont Swift/C++. Aucun moteur ni contenu Minecraft n’est intégré.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 320)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
