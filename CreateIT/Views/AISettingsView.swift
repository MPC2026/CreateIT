import SwiftUI

/// View for configuring AI server settings (LM Studio or Ollama).
struct AISettingsView: View {
    @EnvironmentObject private var ai: AIAssistant
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Provider Selection
    
    /// The currently selected provider.
    @State private var selectedProvider: AIProvider = .lmStudio
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.tint)
                Text("Local AI Assistant")
                    .font(.title2.weight(.bold))
                Spacer()
                
                // Close button with model selection indicator
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        if !ai.model.isEmpty && ai.connection == .connected(modelCount: 0) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.green)
                        }
                        Text("Select Server & Model")
                            .font(.callout.weight(.medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(ai.model.isEmpty || ai.connection == .connected(modelCount: 0) ? Color.secondary.opacity(0.2) : Color.green.opacity(0.2))
                    )
                    .foregroundStyle(ai.model.isEmpty || ai.connection == .connected(modelCount: 0) ? Color.secondary : Color.green)
                }
                .buttonStyle(.plain)
            }
            
            Text("Select your local server provider. Supports LM Studio and Ollama.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Provider picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Server Type")
                    .font(.headline)
                Picker("AI Provider", selection: $selectedProvider) {
                    ForEach(AIProvider.allCases, id: \.self) { p in
                        Text(p.displayName).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedProvider) { _, newValue in
                    // Update the base URL and server type when switching providers
                    ai.baseURL = newValue.defaultBaseURL
                    ai.serverType = newValue
                }
                Text(selectedProvider.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Server URL field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Server URL")
                        .font(.headline)
                    Spacer()
                    Button("Auto") { ai.baseURL = selectedProvider.defaultBaseURL }
                        .buttonStyle(.bordered)
                }
                TextField("Server URL", text: $ai.baseURL)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                Text(defaultURLNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Test connection button
            HStack {
                Button {
                    Task { await ai.testConnection() }
                } label: {
                    Label("Test Connection", systemImage: "antenna.radiowaves.left.and.right")
                }
                .buttonStyle(.borderedProminent)
                
                connectionStatus
                
                Spacer()
            }
            
            // Model selection
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Model").font(.headline)
                    Spacer()
                    Button {
                        Task { await ai.testConnection() }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                }
                
                if ai.availableModels.isEmpty {
                    emptyModelState
                } else {
                    Picker("Model", selection: $ai.model) {
                        ForEach(ai.availableModels, id: \.id) { model in
                            Text(model.displayName).tag(model.id)
                        }
                    }
                }
            }
            
            // Temperature control
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Temperature").font(.headline)
                    Spacer()
                    Text(String(format: "%.2f", ai.temperature))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $ai.temperature, in: 0...2, step: 0.1)
                    .padding(.horizontal, 4)
            }
        }
        .padding(24)
        .onAppear {
            // Initialize the base URL and provider from AIAssistant state
            selectedProvider = ai.serverType
            if ai.baseURL.isEmpty {
                ai.baseURL = selectedProvider.defaultBaseURL
            }
            // Load any persisted models for display
            ai.loadPersistedModels()
        }
    }
    
    // MARK: - Helpers
    
    private var connectionStatus: some View {
        Group {
            switch ai.connection {
            case .unknown:
                Text("Not tested").foregroundColor(.secondary)
            case .connecting:
                HStack { ProgressView(); Text("Testing...") }
            case .connected(let modelCount):
                Text("Connected ✓ (\(modelCount) models)").foregroundColor(.green)
            case .failed(let msg):
                Text("Failed: \(msg)").foregroundColor(.red)
            }
        }
    }
    
    private var defaultURLNote: String {
        switch selectedProvider {
        case .lmStudio:
            return "Default LM Studio URL (\(selectedProvider.defaultBaseURL))"
        case .ollama:
            return "Default Ollama URL (\(selectedProvider.defaultBaseURL))"
        }
    }
    
    private var emptyModelState: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                Text(emptyModelsMessage)
                    .font(.callout.weight(.medium))
            }
            
            Text(setupInstructions)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    private var emptyModelsMessage: String {
        switch selectedProvider {
        case .lmStudio:
            return "No models loaded. Load a model in LM Studio and start the server."
        case .ollama:
            return "No models available. Run 'ollama pull <model>' to add models."
        }
    }
    
    private var setupInstructions: String {
        switch selectedProvider {
        case .lmStudio:
            return """
            In LM Studio:
             1. Load a model from the library
             2. Click "Start Server" (Developer menu)
             3. Ensure port \(selectedProvider.defaultBaseURL) is active
            """
        case .ollama:
            return """
            To set up Ollama:
             1. Install from ollama.ai
             2. Run: ollama pull llama3
             3. Server runs on port \(selectedProvider.defaultBaseURL)
            """
        }
    }
}

// MARK: - Server Configuration Subview

/// Simple view containing a text field for editing the base URL.
struct ServerConfigurationView: View {
    @Binding var baseURL: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Base URL")
                .font(.headline)
            TextField(
                "e.g., http://localhost:1234",
                text: $baseURL
            )
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

// MARK: - Preview

struct AISettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AISettingsView()
    }
}