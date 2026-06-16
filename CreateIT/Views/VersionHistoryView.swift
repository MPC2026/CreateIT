import SwiftUI
import AppKit

struct VersionHistoryView: View {
    @EnvironmentObject private var service: GitHubUpdateService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                sectionCard(title: "GitHub changelog") {
                    if service.releases.isEmpty {
                        Text("Release history will appear here after GitHub responds.")
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(service.releases) { release in
                                releaseCard(release)
                            }
                        }
                    }
                }

                sectionCard(title: "How it stays current") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This view is generated directly from the GitHub releases for MPC2026/CreateIT, so new release notes appear here automatically.")
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Publish a release on GitHub and the app will pick it up the next time it checks for updates.")
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(22)
            .frame(maxWidth: 760, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .task {
            if service.releases.isEmpty {
                await service.refreshReleasesOnly()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Version History")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                Text("Release notes grouped by tag, synced from GitHub.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Close") { dismiss() }
                .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor)))
    }

    private func releaseCard(_ release: GitHubUpdateService.Release) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(release.tagName)
                        .font(.headline)
                    if let name = release.name, !name.isEmpty {
                        Text(name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let publishedAt = release.publishedAt {
                    Text(publishedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let body = release.body?.trimmingCharacters(in: .whitespacesAndNewlines), !body.isEmpty {
                Text(.init(body))
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }

            Button {
                NSWorkspace.shared.open(release.htmlURL)
            } label: {
                Label("Open release", systemImage: "arrow.up.right.square")
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.6)))
    }
}
