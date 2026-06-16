import SwiftUI

/// Configuration panel for connecting CreateIT to a local LLM server
/// (LM Studio by default).
struct AISettingsView: View {
    @EnvironmentObject private var ai: AIAssistant
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.tint)
                Text("Local AI Assistant")
                    .font(.title2.weight(.bold))
                Spacer()
            }

            Text("CreateIT talks to a local OpenAI-compatible server such as LM Studio. "
                 + "In LM Studio, load a model and start the server (Developer → Start Server).")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                Text("Server URL").font(.headline)
                TextField("http://127.0.0.1:1234/v1", text: $ai.baseURL)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                Text("LM Studio default is http://127.0.0.1:1234/v1")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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

            VStack(alignment: .leading, spacing: 8) {
                Text("Model").font(.headline)
                if ai.availableModels.isEmpty {
                    Text("Connect to load the list of available models.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Model", selection: $ai.model) {
                        ForEach(ai.availableModels) { model in
                            Text(model.id).tag(model.id)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Creativity").font(.headline)
                    Spacer()
                    Text(String(format: "%.1f", ai.temperature))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Slider(value: $ai.temperature, in: 0...1.2, step: 0.1) {
                    Text("Temperature")
                } minimumValueLabel: {
                    Text("Focused").font(.caption2)
                } maximumValueLabel: {
                    Text("Wild").font(.caption2)
                }
            }

            Spacer()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 460, height: 440)
        .task {
            if case .unknown = ai.connection { await ai.testConnection() }
        }
    }

    @ViewBuilder
    private var connectionStatus: some View {
        switch ai.connection {
        case .unknown:
            EmptyView()
        case .connecting:
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text("Connecting…").foregroundStyle(.secondary)
            }
            .font(.callout)
        case .connected(let count):
            Label("Connected · \(count) model\(count == 1 ? "" : "s")", systemImage: "checkmark.circle.fill")
                .font(.callout)
                .foregroundStyle(.green)
        case .failed(let message):
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundStyle(.orange)
                .lineLimit(2)
        }
    }
}
