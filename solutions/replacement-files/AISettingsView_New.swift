import SwiftUI

/// CreateIT AI Settings with enhanced server selection capability
struct AISettingsView_New: View {
    @EnvironmentObject private var ai: AIAssistant
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedServerType: AIProvider = .lmStudio
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    serverTypeSection
                    serverURLSection
                    testConnectionSection
                    modelSelectionSection
                    temperatureSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
                .padding(.top, 8)
            
            footerButtons
        }
        .padding(24)
        .frame(width: 500)
        .frame(minHeight: 580)
        .task {
            if case .unknown = ai.connection {
                selectedServerType = .lmStudio
                await ai.testConnection()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.tint)
                Text("Local AI Assistant")
                    .font(.title2.weight(.bold))
                Spacer()
            }
            
            Text("Select your local AI server provider. CreateIT supports LM Studio (OpenAI-compatible API) and Ollama (native API).")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    
    private var serverTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Server Type").font(.headline)
            
            Picker("AI Provider", selection: $selectedServerType) {
                ForEach(AIProvider.allCases, id: \.self) { provider in
                    Text(provider.displayName).tag(provider)
                }
             }
             .pickerStyle(.segmented())
             .onChange(of: selectedServerType) { _, newValue in
                handleServerTypeChange(from: $0, to: newValue)
             }
            
            Text(selectedServerType.description)
                 .font(.caption)
                 .foregroundStyle(.secondary)
         }
     }
    
    private var serverURLSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Server URL").font(.headline)
                Spacer()
                Button("Auto") {
                    ai.baseURL = selectedServerType.defaultBaseURL
                 }
                 .buttonStyle(.bordered())
             }
            
            TextField("Server URL", text: $ai.baseURL)
                 .textFieldStyle(.roundedBorder())
                 .font(.system(.body, design: .monospaced))
            
            Text(defaultURLNote)
                 .font(.caption)
                 .foregroundStyle(.secondary)
         }
     }
    
    private var defaultURLNote: String {
        switch selectedServerType {
        case .lmStudio:
    
    private var testConnectionSection: some View {
        HStack {
            Button {
                Task { await ai.testConnection() }
              } label: {
                Label("Test Connection", systemImage: "antenna.radiowaves.left.and.right")
              }
              .buttonStyle(.borderedProminent())
            
            connectionStatus
            
    
    private var modelSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Model").font(.headline)
                Spacer()
                Button {
                    Task { await ai.testConnection() }
                  } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                  }
                  .buttonStyle(.bordered())
               }
            
            if ai.availableModels.isEmpty {
    
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
    
    private var setupInstructions: String {
        switch selectedServerType {
        case .lmStudio:
            return """
            In LM Studio:
             1. Load a model from the library
             2. Click "Start Server" (Developer menu)
             3. Ensure port 1234 is active
            
"""
        case .ollama:
            return """
            To set up Ollama:
             1. Install from ollama.ai
             2. Run: ollama pull llama3
             3. Start: ollama run llama3
             4. Keep it running in background
            
"""
        }
    }
    
    private var modelList: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let selected = ai.availableModels.first(where: {$0.id == ai.model}) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                          .foregroundStyle(.green)
                    Text("Selected: \(selected.displayName)")
                          .font(.callout.weight(.medium))
                    Spacer()
                    Label("Provider: \(selected.serverType.rawValue)", systemImage: "server.rack")
                          .font(.caption)
                          .foregroundStyle(.secondary)
                }
            }
            
    
    private var temperatureSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Creativity").font(.headline)
                Spacer()
                Text(String(format: "%.1f", ai.temperature))
                      .font(.caption.monospacedDigit())
                      .foregroundStyle(.secondary)
              }
    
    private var footerButtons: some View {
        HStack {
            Spacer()
            Button("Done") { dismiss() }
                  .keyboardShortcut(.defaultAction)
          }
          .padding(.top, 16)
      }
    
    private func handleServerTypeChange(from oldValue: AIProvider, to newValue: AIProvider) {
        withAnimation {
            ai.baseURL = newValue.defaultBaseURL
            ai.availableModels = []
            ai.model = ""
            ai.connection = .unknown
            
            Task {
                await ai.testConnection()
            }
        }
     }
    
    @ViewBuilder
    private var connectionStatus: some View {
        switch ai.connection {
        case .unknown:
            EmptyView()
            
        case .connecting:
            HStack(spacing: 6) {
                ProgressView()
                      .controlSize(.small)
                Text("Connecting...").foregroundStyle(.secondary)
              }
              .font(.callout)
              
        case .connected(let count):
            Label(
                "Connected · \(count) model\(count == 1 ? "" : "s")",
                systemImage: "checkmark.circle.fill"
            )
                  .font(.callout)
                  .foregroundStyle(.green)
                  
        case .failed(let message):
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                      .foregroundStyle(.orange)
                Text(message)
                      .font(.caption)
                      .foregroundStyle(.orange)
                     .lineLimit(2)
              }
           }
       }
}

// MARK: - Previews

#Preview("LM Studio Mode") {
    AISettingsView_New()
          .environmentObject(PreviewAIAssistant(provider: .lmStudio))
}

#Preview("Ollama Mode") {
    AISettingsView_New()
          .environmentObject(PreviewAIAssistant(provider: .ollama))
}

// MARK: - Preview Helper Class

class PreviewAIAssistant: ObservableObject {
      @Published var availableModels: [LMStudioClient.Model] = []
      @Published var connection: AIAssistant.ConnectionState = .unknown
      @Published var generating: Set<String> = []
     
      @AppStorage("ai.baseURL") var baseURL: String = "http://127.0.0.1:1234/v1"
      @AppStorage("ai.model") var model: String = ""
      @AppStorage("ai.temperature") var temperature: Double = 0.8
     
    init(provider: AIProvider) {
        self.selectedServerType = provider
        self.baseURL = provider.defaultBaseURL
        
          // Simulate connected state with sample models
        self.availableModels = [
            LMStudioClient.Model(
                id: "llama-3-8b",
                displayName: "Llama 3 8B",
                serverType: provider
             ),
            LMStudioClient.Model(
                id: "mistral-7b",
                displayName: "Mistral 7B",
                serverType: provider
             )
        ]
        self.connection = .connected(modelCount: 2)
    }
    
    func testConnection() async {
          await Task.yield()
      }
}

            
            Slider(value: $ai.temperature, in: 0...1.2, step: 0.1) {
                    Text("Temperature")
                  } minimumValueLabel: {
                    Text("Focused").font(.caption2)
                  } maximumValueLabel: {
                    Text("Wild").font(.caption2)
                  }
          }
      }

            if ai.availableModels.count > 1 {
                List(ai.availableModels, id: \.id) { model in
                    Button(action: {ai.model = model.id}) {
                        HStack {
                            Text(model.displayName)
                            Spacer()
                            if model.id == ai.model {
                                Label("Selected", systemImage: "checkmark")
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(.green)
                                }
                            }
                        }
                        .buttonStyle(.plain())
                    }
                } else if !ai.availableModels.isEmpty {
                    Text(ai.availableModels.first?.displayName ?? "")
                            .font(.callout())
                            .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }
    
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                      .fill(Color.orange.opacity(0.1))
            )
       }
      
    private var emptyModelsMessage: String {
        switch selectedServerType {
        case .lmStudio:
            return "No models found in LM Studio"
        case .ollama:
            return "No models found in Ollama"
           }
       }
      
                emptyModelState
              } else {
                modelList
              }
          }
      }
      
            Spacer()
          }
      }
      
            return "LM Studio default: http://127.0.0.1:1234/v1"
        case .ollama:
            return "Ollama default: http://localhost:11434"
         }
     }
    }