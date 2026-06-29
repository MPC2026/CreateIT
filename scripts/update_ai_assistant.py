import json

# Read the file
with open('/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT/CreateIT/AI/AIAssistant.swift', 'r') as f:
    lines = f.readlines()

# Find and modify specific sections
new_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    
    # After temperature line, add provider
    if '@AppStorage("ai.temperature") var temperature: Double = 0.8' in line:
        new_lines.append(line)
        new_lines.append('\n')
        new_lines.append('     @AppStorage("ai.provider") var provider: AIProvider = .lmStudio\n')
        i += 1
        continue
    
    # Change availableModels type
    if '@Published var availableModels: [LMStudioClient.Model] = []' in line:
        new_lines.append('     @Published var availableModels: [AIProviderModel] = []\n')
        i += 1
        continue
    
    # Before OutlineError enum, add connection and AIProviderModel struct
    if '    enum OutlineError: LocalizedError {' in line:
        new_lines.append('\n')
        new_lines.append('     @Published var connection: ConnectionState = .unknown\n')
        new_lines.append('\n')
        new_lines.append('           /// Wrapper that holds a model from either provider\n')
        new_lines.append('     struct AIProviderModel: Identifiable, Hashable {\n')
        new_lines.append('         let id: String\n')
        new_lines.append('         let displayName: String\n')
        new_lines.append('         let serverType: AIProvider\n')
        new_lines.append('        }\n')
        new_lines.append('\n')
        new_lines.append('      // MARK: Client Factory\n')
        new_lines.append('\n')
        new_lines.append('     private func makeClient() -> AnyListModelClient {\n')
        new_lines.append('         switch provider {\n')
        new_lines.append('         case .lmStudio:\n')
        new_lines.append('             return LMStudioListModelClient(baseURL: baseURL)\n')
        new_lines.append('         case .ollama:\n')
        new_lines.append('             return OllamaListModelClient(baseURL: baseURL)\n')
        new_lines.append('          }\n')
        new_lines.append('     }\n')
        new_lines.append('\n')
    
    # Update client property reference in testConnection
    if 'let models = try await client.listModels()' in line:
        new_lines.append('            let client = makeClient()\n')
        new_lines.append('            let models = try await client.listModels()\n')
        i += 1
        continue
    
    # Update availableModels assignment for model list
    if 'availableModels = models' in line and 'let models = try await client.listModels()' in lines[i-2]:
        new_lines.append('            availableModels = models.map { AIProviderModel(id: $0.id, displayName: $0.displayName, serverType: $0.serverType) }\n')
        i += 1
        continue
    
    new_lines.append(line)
    i += 1

# Write the modified content
with open('/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT/CreateIT/AI/AIAssistant.swift', 'w') as f:
    f.writelines(new_lines)

print("AIAssistant.swift updated successfully")
