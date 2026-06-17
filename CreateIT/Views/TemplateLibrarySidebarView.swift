import SwiftUI

struct TemplateLibrarySidebarView: View {
    @EnvironmentObject private var wizard: WizardState
    @EnvironmentObject private var library: TemplateLibraryStore
    @State private var deleteCandidate: SavedTemplate?
    @State private var recentlyLoadedTemplateID: UUID?
    @State private var showLoadedToast = false
    @State private var loadedToastTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if let selected = library.selectedTemplate {
                Text("Current draft: \(selected.displayTitle)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 2)
            }

            Divider()

            if library.templates.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(library.templates) { template in
                            templateRow(template)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(minWidth: 240, idealWidth: 260, maxWidth: 280)
        .confirmationDialog(
            "Delete this beat?",
            isPresented: Binding(
                get: { deleteCandidate != nil },
                set: { if !$0 { deleteCandidate = nil } }
            ),
            presenting: deleteCandidate
        ) { template in
            Button("Delete", role: .destructive) {
                library.delete(template)
                deleteCandidate = nil
            }
        } message: { template in
            Text("This removes \"\(template.displayTitle)\" from your saved projects. Your current draft stays open.")
        }
        .overlay(alignment: .bottom) {
            if showLoadedToast {
                Text("Loaded \(loadedToastTitle)")
                    .font(.callout.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.black.opacity(0.82)))
                    .foregroundStyle(.white)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 8)
            }
        }
        .onChange(of: library.projectOpenToken) { _, _ in
            guard let template = library.selectedTemplate else { return }
            loadedToastTitle = template.displayTitle
            recentlyLoadedTemplateID = template.id
            withAnimation(.easeInOut(duration: 0.2)) {
                showLoadedToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showLoadedToast = false
                    recentlyLoadedTemplateID = nil
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Saved Projects")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("\(library.templates.count)")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.accentColor.opacity(0.16)))
                    .foregroundStyle(.tint)
            }
            Text("Save projects here, reopen them later, and remove them only when you're sure.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Button {
                    library.startNewDraft(with: wizard)
                } label: {
                    Label("New Project", systemImage: "plus")
                }
                .buttonStyle(.bordered)

                Button {
                    library.saveCurrent(from: wizard)
                } label: {
                    Label(library.selectedTemplateID == nil ? "Save Project" : "Save Changes",
                          systemImage: "tray.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "tray")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No saved projects yet")
                .font(.headline)
            Text("Work on a story, then save it here to keep it handy for later.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(BrandPalette.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(BrandPalette.softBorder))
    }

    private func templateRow(_ template: SavedTemplate) -> some View {
        Button {
            library.open(template, into: wizard)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(template.displayTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    if library.selectedTemplateID == template.id {
                        Text("Open")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.accentColor.opacity(0.18)))
                            .foregroundStyle(.tint)
                    }
                }

                Text(template.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Text("\(template.beatCount) beats")
                    Spacer()
                    Text(template.updatedAt.formatted(date: .abbreviated, time: .shortened))
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(library.selectedTemplateID == template.id ? BrandPalette.sidebarAccent.opacity(0.12) : BrandPalette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        library.selectedTemplateID == template.id
                        ? BrandPalette.sidebarAccent.opacity(recentlyLoadedTemplateID == template.id ? 0.38 : 0.18)
                        : BrandPalette.softBorder
                    )
            )
            .scaleEffect(recentlyLoadedTemplateID == template.id ? 1.01 : 1.0)
            .shadow(color: recentlyLoadedTemplateID == template.id ? BrandPalette.sidebarAccent.opacity(0.14) : .clear, radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Open") {
                library.open(template, into: wizard)
            }
            Button(role: .destructive) {
                deleteCandidate = template
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
