import SwiftUI

struct ContentView: View {
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

            Text("La base iOS est en place. Le moteur du jeu n’est pas encore intégré.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 320)

            Label("Étape 1 : vérifier la compilation native", systemImage: "hammer")
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
