import SwiftUI

/// Reusable server selection component for switching between LM Studio and Ollama
struct ServerSelectionView: View {
    @Binding var selectedServerType: AIProvider
    @Binding var serverURL: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("AI Provider", selection: $selectedServerType) {
                ForEach(AIProvider.allCases, id: \.self) { provider in
                    Text(provider.displayName).tag(provider)
                }
            }
            .pickerStyle(.segmented)

            Text(selectedServerType.description)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                TextField("Server URL", text: $serverURL)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))

                Button("Auto") {
                    serverURL = selectedServerType.defaultBaseURL
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
}

#Preview {
    ServerSelectionView(
        selectedServerType: .constant(.lmStudio),
        serverURL: .constant(AIProvider.lmStudio.defaultBaseURL)
    )
    .padding()
}
