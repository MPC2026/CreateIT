import SwiftUI
import AppKit

struct UpdateCenterView: View {
    @EnvironmentObject private var service: GitHubUpdateService
    @Environment(\.dismiss) private var dismiss
    @State private var isChecking = false
    @State private var didLoad = false
    @State private var showHistory = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            statusCard

            if service.isUpdateAvailable {
                updateBanner
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

            Spacer(minLength: 0)

            HStack {
                Spacer()
                Button("Close") { dismiss() }
                    .buttonStyle(.bordered)
            }
        }
        .padding(22)
        .frame(minWidth: 620, minHeight: 500)
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

            Button {
                Task {
                    isChecking = true
                    defer { isChecking = false }
                    await service.checkForUpdates()
                }
            } label: {
                if isChecking {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text("Checking…")
                    }
                } else {
                    Label("Check for updates", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(.borderedProminent)
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
                if let release = service.latestRelease {
                    Button("View release") {
                        NSWorkspace.shared.open(release.htmlURL)
                    }
                    .buttonStyle(.borderedProminent)
                }
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
}
