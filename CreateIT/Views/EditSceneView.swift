import SwiftUI

struct EditSceneView: View {
    @Environment(\.dismiss) private var dismiss
    
    let scene: SceneOutlineScene
    let onSave: (SceneOutlineScene) -> Void
    
    @State private var title: String
    @State private var summary: String
    
    init(scene: SceneOutlineScene, onSave: @escaping (SceneOutlineScene) -> Void) {
        self.scene = scene
        self.onSave = onSave
        _title = State(initialValue: scene.title)
        _summary = State(initialValue: scene.summary)
    }
    
    var body: some View {
        NavigationView {
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
                
                Spacer()
                
                // Save button
                Button("Save Scene") {
                    save()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding(20)
            .frame(width: 500, height: 400)
        }
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
}

#Preview {
    EditSceneView(
        scene: SceneOutlineScene(act: 1, beatKey: "catalyst", beatSceneNumber: 1, title: "", summary: ""),
        onSave: { _ in }
    )
}
