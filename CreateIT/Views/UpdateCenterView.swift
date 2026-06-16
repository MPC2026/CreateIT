import SwiftUI
import AppKit

struct UpdateCenterView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            VStack(alignment: .leading, spacing: 8) {
                Text("What's new")
                    .font(.headline)

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

            VStack(alignment: .leading, spacing: 10) {
                Text("GitHub")
                    .font(.headline)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Repo")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(ReleaseNotes.repositoryURL.absoluteString)
                            .font(.callout)
                            .textSelection(.enabled)
                    }

                    Spacer()

                    Button {
                        NSWorkspace.shared.open(ReleaseNotes.repositoryURL)
                    } label: {
                        Label("Open", systemImage: "arrow.up.right.square")
                    }
                    .buttonStyle(.borderedProminent)
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
        .frame(minWidth: 560, minHeight: 420)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Update Center")
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text("\(AppInfo.displayVersion) • synced with GitHub")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
