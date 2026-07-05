import SwiftUI

struct EditSceneView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var ai: AIAssistant
    @EnvironmentObject private var wizard: WizardState
    
    let scene: SceneOutlineScene
    let onSave: (SceneOutlineScene) -> Void
    
    @State private var title: String
    @State private var summary: String
    @State private var isDraftingWithAI = false
    @State private var draftStatus: String?
    
    init(scene: SceneOutlineScene, onSave: @escaping (SceneOutlineScene) -> Void) {
        self.scene = scene
        self.onSave = onSave
        _title = State(initialValue: scene.title)
        _summary = State(initialValue: scene.summary)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Scene header
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(laneColor(for: scene.act))
                    .frame(width: 6, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scene \(scene.beatSceneNumber)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    
                    if let beatKey = scene.beatKey {
                        HStack(spacing: 4) {
                            Text("Beat:")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.primary)
                            Text(beatKey)
                                .font(.caption.weight(.regular))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Text("Act \(scene.act)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Title field
            VStack(alignment: .leading, spacing: 6) {
                Text("Title")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                TextField("Scene title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, 8)
            }
            
            // Summary field
            VStack(alignment: .leading, spacing: 6) {
                Text("Summary")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                TextEditor(text: $summary)
                    .frame(minHeight: 120)
                    .font(.callout)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.primary.opacity(0.12)))
            }
            
            // AI Assistant section
            if ai.isConfigured {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    HStack(spacing: 10) {
                        Button {
                            draftSceneWithAI()
                        } label: {
                            if isDraftingWithAI {
                                HStack(spacing: 6) {
                                    ProgressView().controlSize(.small)
                                    Text("Drafting with AI...")
                                }
                            } else {
                                Label("Draft Scene with AI", systemImage: "sparkles")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isDraftingWithAI || !ai.isConfigured)
                        
                        Spacer()
                    }
                    
                    if let draftStatus {
                        Text(draftStatus)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Divider()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                        Text("Connect a local LLM in the AI menu to use AI assistance")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Save button
            Button("Save Scene") {
                save()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .frame(minWidth: 500, minHeight: 400)
    }
    
    private func laneColor(for act: Int) -> Color {
        switch act {
        case 1: return .blue
        case 2: return .orange
        case 3: return .green
        default: return .purple
        }
    }
    
    private func save() {
        var updatedScene = scene
        updatedScene.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedScene.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(updatedScene)
        dismiss()
    }
    
    private func draftSceneWithAI() {
        isDraftingWithAI = true
        draftStatus = "Drafting scene with AI..."
        
        Task { @MainActor in
            defer { isDraftingWithAI = false }
            
            do {
                // Get the beat for this scene to provide context
                let beatKey = scene.beatKey ?? ""
                let beat = wizard.beats.first(where: { $0.key == beatKey })
                
                guard let beat else {
                    draftStatus = "No beat found for this scene"
                    return
                }
                
                // Draft the scene summary using AI
                let draft = await ai.draftSceneOutline(
                    for: beat,
                    sceneID: scene.id,
                    sceneIndex: scene.beatSceneNumber,
                    sceneCount: 1,
                    seedText: summary.trimmingCharacters(in: .whitespacesAndNewlines),
                    wizard: wizard
                )
                
                if let cleaned = draft?.trimmingCharacters(in: .whitespacesAndNewlines), !cleaned.isEmpty {
                    summary = cleaned
                    draftStatus = "Scene summary updated with AI assistance"
                } else {
                    draftStatus = "AI could not generate scene content"
                }
            } catch {
                draftStatus = "Error drafting with AI: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    EditSceneView(
        scene: SceneOutlineScene(act: 1, beatKey: "catalyst", beatSceneNumber: 1, title: "", summary: ""),
        onSave: { _ in }
    )
}
