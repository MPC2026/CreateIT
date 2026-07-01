import SwiftUI
import UniformTypeIdentifiers

struct BackupRestoreView: View {
    @EnvironmentObject private var wizard: WizardState
    @Environment(\.dismiss) private var dismiss
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "archivebox.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.accentColor)

                Text("Project Backup")
                    .font(.title.weight(.heavy))

                Text(
                    "Save your current progress to a backup file or restore from a previously saved state."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            }
            .padding(.top, 24)

            Divider()

            VStack(spacing: 16) {
                Button {
                    Task { await performBackup() }
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.title2)
                        Text("Save Backup")
                            .fontWeight(.semibold)
                    }
                    .frame(width: 160, height: 80)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)

                if isProcessing {
                    ProgressView("Processing...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }

                Button {
                    Task { await performRestore() }
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.up.doc.fill")
                            .font(.title2)
                        Text("Restore Backup")
                            .fontWeight(.semibold)
                    }
                    .frame(width: 160, height: 80)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
            }

            Divider()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .padding(32)
        .frame(minWidth: 400, minHeight: 320)
        .alert("Backup System", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
        .overlay(
            Group {
                if isProcessing {
                    Color.black.opacity(0.2).ignoresSafeArea()
                        .onTapGesture {
                            // Optional: dismiss when clicking outside
                        }
                }
            }
        )
    }

    private func performBackup() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(wizard.snapshot())

            // Show save panel
            let panel = NSSavePanel()
            panel.canCreateDirectories = true
            panel.nameFieldStringValue = "project.createit-backup"

            if let backupType = UTType(filenameExtension: "createit-backup") {
                panel.allowedContentTypes = [backupType]
            }

            let result = panel.runModal()
            switch result {
            case .OK:
                guard let url = panel.url else {
                    alertMessage = "Save cancelled"
                    await MainActor.run { showAlert = true }
                    return
                }
                do {
                    try data.write(to: url, options: .atomic)
                    alertMessage = "Project state saved successfully to:\n\(url.path)"
                } catch {
                    alertMessage = "Save failed: \(error.localizedDescription)"
                }
            default:
                // User cancelled
                return
            }
            await MainActor.run { showAlert = true }
        } catch {
            alertMessage = "Encoding failed: \(error.localizedDescription)"
            await MainActor.run { showAlert = true }
        }
    }

    private func performRestore() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            // Show open panel
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false

            if let backupType = UTType(filenameExtension: "createit-backup") {
                panel.allowedContentTypes = [backupType]
            }

            let result = panel.runModal()
            switch result {
            case .OK:
                guard let selectedURL = panel.url else {
                    alertMessage = "No file selected"
                    await MainActor.run { showAlert = true }
                    return
                }
                do {
                    let data = try Data(contentsOf: selectedURL)
                    let decoder = JSONDecoder()
                    let stateData = try decoder.decode(
                        WizardState.StateData.self, from: data)
                    wizard.apply(data: stateData)
                    alertMessage = "Project state restored successfully!"
                } catch {
                    alertMessage = "Restore failed: \(error.localizedDescription)"
                }
            default:
                // User cancelled
                return
            }
            await MainActor.run { showAlert = true }
        } catch {
            alertMessage = "Error: \(error.localizedDescription)"
            await MainActor.run { showAlert = true }
        }
    }

    private func createDMG() async {
        isProcessing = true
        defer { isProcessing = false }

        // First, save the backup to a temporary location
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(wizard.snapshot())

        guard let backupData = data else {
            alertMessage = "Failed to encode project data"
            await MainActor.run { showAlert = true }
            return
        }

        // Save to temp location first
        let temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString)
        try? FileManager.default.createDirectory(
            at: temporaryDirectory, withIntermediateDirectories: true)

        let backupURL = temporaryDirectory.appendingPathComponent("project.createit-backup")
        try? backupData.write(to: backupURL, options: .atomic)

        // Now create DMG
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "project.dmg"

        if let dmgType = UTType(filenameExtension: "dmg") {
            panel.allowedContentTypes = [dmgType]
        }

        let result = panel.runModal()
        switch result {
        case .OK:
            guard let dmgURL = panel.url else {
                try? FileManager.default.removeItem(at: temporaryDirectory)
                return
            }
            do {
                // Copy backup to temp dir for DMG creation
                let tmpDirForDMG = FileManager.default.temporaryDirectory
                    .appendingPathComponent(
                        UUID().uuidString)
                try FileManager.default.createDirectory(
                    at: tmpDirForDMG, withIntermediateDirectories: true)

                let copiedBackupURL = tmpDirForDMG.appendingPathComponent(
                    "project.createit-backup")
                try FileManager.default.copyItem(at: backupURL, to: copiedBackupURL)

                // Create DMG using hdiutil
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
                process.arguments = [
                    "create", tmpDirForDMG.path, "-srcdir", tmpDirForDMG.path,
                    "-format",
                    "UDZO", "-volname", "CreateIT", dmgURL.path,
                ]

                try process.run()
                process.waitUntilExit()

                // Clean up temp directories
                try? FileManager.default.removeItem(at: tmpDirForDMG)
                try? FileManager.default.removeItem(at: temporaryDirectory)

                if process.terminationStatus == 0 {
                    alertMessage = "DMG created successfully:\n\(dmgURL.path)"
                } else {
                    alertMessage =
                        "DMG creation failed with status \(process.terminationStatus)"
                }
            } catch {
                // Clean up on error
                try? FileManager.default.removeItem(at: temporaryDirectory)
                alertMessage = "DMG creation failed: \(error.localizedDescription)"
            }
        default:
            // User cancelled
            try? FileManager.default.removeItem(at: temporaryDirectory)
            return
        }
        await MainActor.run { showAlert = true }
    }
}
