import SwiftUI
import AppKit

struct UpdateCenterView: View {
    @EnvironmentObject private var service: GitHubUpdateService
    @Environment(\.dismiss) private var dismiss
    @AppStorage("github.token") private var githubToken: String = ""
    @State private var isChecking = false
    @State private var showHistory = false
    @State private var didLoad = false
    @State private var showInstallConfirmation = false
    

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    statusCard

                    if service.isUpdateAvailable {
                        updateBanner
                    }

                    updateStateCard

                    // Download progress card (shown during download)
                    if case .downloading(let progress) = service.state, let progressValue = service.downloadProgress {
                        downloadProgressCard(progress: progressValue, fraction: progress)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("What's new")
                                .font(.headline)
                            Spacer()
                            Button("Version history") {
                                showHistory = true
                            }
                            .buttonStyle(.bordered)
                        }
                        releaseNotesBody
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent commits")
                            .font(.headline)

                        if service.commits.isEmpty {
                            Text("Commit history will appear here after GitHub responds.")
                                .foregroundStyle(.secondary)
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(service.commits) { commit in
                                    commitRow(commit)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("GitHub access")
                            .font(.headline)
                        Text("If you ever point CreateIT at a private repo again, paste a read-only GitHub token here. Public releases do not need one.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        SecureField("GitHub token", text: $githubToken)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 8)
            }
            .scrollIndicators(.visible)
            footer
        }
        .padding(16)
        .frame(minWidth: 450, minHeight: 380)
        .background(Color(nsColor: .windowBackgroundColor))
        .task {
            guard !didLoad else { return }
            didLoad = true
            await service.refresh()
        }
        .sheet(isPresented: $showHistory) {
            VersionHistoryView()
                .environmentObject(service)
        }
        .alert("Install Update?", isPresented: $showInstallConfirmation, actions: {
            Button("Cancel", role: .cancel) { }
            Button("Install") {
                Task { await startUpdateCheck() }
            }
        }, message: {
            if let release = service.latestRelease {
                Text("A new version (\(release.tagName)) is available. The app will close, install the update, and relaunch.")
            } else {
                Text("An update is available. The app will close, install the update, and relaunch.")
            }
        })
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Update Center")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                Text("\(AppInfo.displayVersion) • synced with GitHub")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var footer: some View {
        HStack(spacing: 10) {
            if let release = service.latestRelease {
                Button {
                    NSWorkspace.shared.open(release.htmlURL)
                } label: {
                    Label("View release", systemImage: "arrow.up.right.square")
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            Button("Close") { dismiss() }
                .buttonStyle(.bordered)

            Button {
                showInstallConfirmation = true
            } label: {
                if isChecking {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text("Updating…")
                    }
                } else {
                    Label("Check & Install", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!service.isUpdateAvailable)
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current build")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(AppInfo.displayVersion)
                        .font(.headline)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Latest release")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(service.latestRelease?.tagName ?? "Loading…")
                        .font(.headline)
                }
            }

            HStack(spacing: 12) {
                Label(
                    service.isUpdateAvailable ? "Update available" : "Up to date",
                    systemImage: service.isUpdateAvailable ? "arrow.down.circle.fill" : "checkmark.seal.fill"
                )
                .foregroundStyle(service.isUpdateAvailable ? .orange : .green)

                if let checked = service.lastChecked {
                    Text("Checked \(checked.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    NSWorkspace.shared.open(ReleaseNotes.repositoryURL)
                } label: {
                    Label("Open GitHub", systemImage: "arrow.up.right.square")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor)))
    }

    private var updateBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("New version available", systemImage: "sparkles")
                    .font(.headline)
                Spacer()
                Button {
                    showInstallConfirmation = true
                } label: {
                    if isChecking {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text("Updating…")
                        }
                    } else {
                        Text("Check & Install")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isChecking || !service.isUpdateAvailable)
            }

            if let release = service.latestRelease {
                Button("View release") {
                    NSWorkspace.shared.open(release.htmlURL)
                }
                .buttonStyle(.borderless)
            }

            Text("Your installed version is behind the latest GitHub release.")
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.orange.opacity(0.10)))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.orange.opacity(0.22)))
    }

    @ViewBuilder
    private var updateStateCard: some View {
        switch service.state {
        case .installing:
            HStack(spacing: 10) {
                ProgressView().controlSize(.small)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Installing update")
                        .font(.headline)
                    Text("CreateIT is downloading the new app and will relaunch when it finishes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.orange.opacity(0.10)))
        case .failed(let message):
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Update failed")
                        .font(.headline)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.orange.opacity(0.10)))
        default:
            EmptyView()
        }
    }

    private func downloadProgressCard(progress: GitHubUpdateService.DownloadProgress, fraction: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Downloading update")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f%%", fraction * 100))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: fraction)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Downloaded")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(formatBytes(progress.downloadedBytes))
                        .font(.callout)
                }
                
                if progress.totalBytes > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total size")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(formatBytes(progress.totalBytes))
                            .font(.callout)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.blue.opacity(0.10)))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.blue.opacity(0.22)))
    }

    private func formatBytes(_ bytes: Int64) -> String {
        if bytes >= 1_073_741_824 {
            return String(format: "%.2f GB", Double(bytes) / 1_073_741_824.0)
        } else if bytes >= 1_048_576 {
            return String(format: "%.2f MB", Double(bytes) / 1_048_576.0)
        } else if bytes >= 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024.0)
        } else {
            return "\(bytes) B"
        }
    }

    @ViewBuilder
    private var releaseNotesBody: some View {
        if let release = service.latestRelease {
            let preview = ReleasePreviewFormatter.markdown(for: release)
            VStack(alignment: .leading, spacing: 8) {
                Text("Latest release preview")
                    .font(.headline)
                Text(.init(preview))
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor)))
        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(ReleaseNotes.highlights, id: \.self) { note in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(note)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor)))
        }
    }

    private func commitRow(_ commit: GitHubUpdateService.Commit) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(commit.message.split(separator: "\n", maxSplits: 1).first.map(String.init) ?? commit.message)
                    .font(.callout.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text(commit.shortSHA)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                if let author = commit.authorName {
                    Text(author)
                }
                if let date = commit.date {
                    Text("•")
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                }
                Spacer()
                Button("Open") {
                    NSWorkspace.shared.open(commit.htmlURL)
                }
                .buttonStyle(.borderless)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor)))
    }

    private func startUpdateCheck() {
        Task { await service.checkForUpdatesAndInstall() }
    }
}
