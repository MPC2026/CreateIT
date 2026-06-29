    
    // MARK: - NEW Helper Methods
    
    private var newServerTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Server Type").font(.headline)
            
            Picker("AI Provider", selection: $selectedServerType) {
                ForEach(AIProvider.allCases, id: \.self) { provider in
                    Text(provider.displayName).tag(provider)
                 }
             }
             .pickerStyle(.segmented())   // Segmented controller style
            
            Text(selectedServerType.description)
                   .font(.caption)
                   .foregroundStyle(.secondary)
            
         }
     }
        
    private var defaultURLNote: String {
        switch selectedServerType {
        case .lmStudio:
            "LM Studio default: http://127.0.0.1:1234/v1"
        case .ollama:
            "Ollama default: http://localhost:11434"
         }
     }
    
    private func handleServerTypeChange(from _: AIProvider, to newType: AIProvider) {
        withAnimation {
            ai.baseURL = newType.defaultBaseURL
            ai.availableModels = []
            ai.model = ""
            ai.connection = .unknown
            
            Task { await ai.testConnection() }
         }
     }

#Preview("Server Selector Demo") {
    AISettingsView_UIOnly()
            .environmentObject(PreviewAIAssistant(provider: .lmStudio))
}

#Preview("Ollama Mode") {
    AISettingsView_UIOnly()
            .environmentObject(PreviewAIAssistant(provider: .ollama))
}

class PreviewAIAssistant: ObservableObject {
     @Published var availableModels: [LMStudioClient.Model] = []
     @Published var connection: AIAssistant.ConnectionState = .unknown
     
     @AppStorage("ai.baseURL") var baseURL: String = "http://127.0.0.1:1234/v1"
     @AppStorage("ai.model") var model: String = ""
     @AppStorage("ai.temperature") var temperature: Double = 0.8
     
    init(provider: AIProvider) {
        baseURL = provider.defaultBaseURL
        availableModels = [LMStudioClient.Model(id: "test", displayName: "Test Model", serverType: provider)]
        connection = .connected(modelCount: 1)
     }
    
    func testConnection() async { await Task.yield() }
}
