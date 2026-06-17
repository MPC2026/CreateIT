import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct FinalDraftStepView: View {
    @EnvironmentObject private var wizard: WizardState
    @State private var beatElement: BeatElement = .card
    @State private var includeGuidance = true
    @State private var statusMessage: String?
    @State private var statusIsError = false
    @State private var draftConflict: DraftConflict?
    @State private var activeSceneID: UUID?
    @FocusState private var focusedSceneID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepHeader(
                eyebrow: "Step 7",
                title: "Open Final Draft",
                subtitle: "Send the outline into Final Draft, or save the `.fdx` file first if you want to keep a copy.")

            HStack(spacing: 10) {
                Button {
                    openInFinalDraft()
                } label: {
                    Label("Open Final Draft", systemImage: "arrow.up.forward.app")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    saveFDX()
                } label: {
                    Label("Save .fdx…", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)

                Button {
                    saveBeatSheetPDF()
                } label: {
                    Label("Save Beat Sheet PDF…", systemImage: "doc.richtext")
                }
                .buttonStyle(.bordered)

                Menu {
                    Picker("Beat page style", selection: $beatElement) {
                        ForEach(BeatElement.allCases) { element in
                            Text(element.label).tag(element)
                        }
                    }
                    .pickerStyle(.inline)
                    Divider()
                    Toggle("Include guidance & references", isOn: $includeGuidance)
                } label: {
                    Label("Export Options", systemImage: "slider.horizontal.3")
                }
                .menuStyle(.borderlessButton)
                .buttonStyle(.bordered)

                Spacer()
            }

            Text("This exports beats to the beat board and scenes to the script pages, then opens the `.fdx` in the app associated with `.fdx` files.")
                .font(.callout)
                .foregroundStyle(.secondary)

            if !wizard.scenes.isEmpty {
                boardSummary
                Text("Scenes stay editable in the Scenes step, so Final Draft only shows the export summary here.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                emptyState
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(statusIsError ? .red : .secondary)
            }

            Spacer(minLength: 0)
        }
        .sheet(item: $draftConflict) { conflict in
            DraftConflictReviewView(conflict: conflict) { decision in
                handleConflictDecision(decision, for: conflict)
            }
            .padding(20)
            .frame(minWidth: 760, minHeight: 560)
        }
        .onChange(of: focusedSceneID) { _, value in
            activeSceneID = value
        }
    }

    private var boardSummary: some View {
        HStack(spacing: 10) {
            summaryTile(title: "\(wizard.beats.count)", subtitle: "Beats", systemImage: "square.grid.2x2")
            summaryTile(title: "\(wizard.scenes.count)", subtitle: "Scenes", systemImage: "text.badge.checkmark")
            summaryTile(title: "\(actSections.count)", subtitle: "Acts", systemImage: "rectangle.split.3x1")
            Spacer(minLength: 0)
        }
    }

    private func summaryTile(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tint)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.bold))
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(width: 130, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08)))
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No scene outline yet.")
                .font(.headline)
            Text("Go back to the outline step to seed scenes, then return here to preview and export the exact same editable layout.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08)))
    }

    private var sceneBoard: some View {
        LazyVStack(alignment: .leading, spacing: 18) {
            beatTableHeader

            ForEach(actSections) { section in
                VStack(alignment: .leading, spacing: 10) {
                    actHeader(section)

                    ForEach(section.beats) { beat in
                        beatSection(beat)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(nsColor: .controlBackgroundColor).opacity(0.92),
                                    Color(nsColor: .textBackgroundColor).opacity(0.78)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing)))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08)))
            }
        }
        .padding(.vertical, 2)
    }

    private var beatTableHeader: some View {
        HStack(spacing: 12) {
            Text("Scene")
                .frame(width: 64, alignment: .leading)
            Text("Beat")
                .frame(width: 220, alignment: .leading)
            Text("Description")
            Spacer(minLength: 0)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.9)))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08)))
    }

    private func actHeader(_ section: ActSection) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(laneColor(for: section.act))
                .frame(width: 6, height: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(section.label)
                    .font(.title3.weight(.bold))
                Text("\(section.beats.count) beats")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(section.mediumLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private func beatSection(_ beat: BeatTemplate) -> some View {
        let sceneIDs = sceneIDs(for: beat)
        let current = sceneIDs.count
        let planned = plannedSceneCount(for: beat)
        let laneColor = laneColor(for: beat.act)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(beat.title)
                            .font(.headline.weight(.bold))
                        tinyPill(beat.actLabel, tint: laneColor)
                    }
                    Text(beat.purpose)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(current) / \(planned)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(laneColor)
                    Text(beat.timing(for: wizard.runtime ?? .feature))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Button {
                    addScene(toBeat: beat)
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }

            if sceneIDs.isEmpty {
                emptyBeatPlaceholder(for: beat, tint: laneColor)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sceneIDs.enumerated()), id: \.element) { index, sceneID in
                        sceneLineRow(
                            sceneID: sceneID,
                            isLast: index == sceneIDs.count - 1)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(laneColor.opacity(0.10)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.55)))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(laneColor.opacity(0.12)))
    }

    private func emptyBeatPlaceholder(for beat: BeatTemplate, tint: Color) -> some View {
        HStack(spacing: 10) {
            Text("No scenes yet for this beat.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                addScene(toBeat: beat)
            } label: {
                Label("Add Scene", systemImage: "plus")
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(tint.opacity(0.06)))
    }

    private func sceneLineRow(
        sceneID: UUID,
        isLast: Bool
    ) -> some View {
        guard let index = sceneIndex(for: sceneID) else { return AnyView(EmptyView()) }
        let scene = wizard.scenes[index]
        let laneColor = laneColor(for: scene.act)
        let isActive = activeSceneID == scene.id || focusedSceneID == scene.id
        let dividerOpacity = isLast ? 0 : 0.08

        return AnyView(
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(wizard.sceneDisplayHeading(for: sceneID))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        FinalDraftSceneTitleTextField(text: sceneTitleBinding(for: sceneID)) {
                            selectScene(scene.id)
                        }
                        .font(.headline)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isActive ? Color.accentColor.opacity(0.06) : Color.clear))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(isActive ? Color.accentColor.opacity(0.35) : Color.primary.opacity(0.0), lineWidth: isActive ? 1.5 : 0))
                    }
                    .frame(width: 280, alignment: .leading)

                    TextEditor(text: sceneSummaryBinding(for: sceneID))
                        .font(.callout)
                        .frame(minHeight: 74)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isActive ? Color.accentColor.opacity(0.06) : Color(nsColor: .textBackgroundColor)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(isActive ? Color.accentColor.opacity(0.35) : laneColor.opacity(0.12), lineWidth: isActive ? 1.5 : 1))
                        .simultaneousGesture(TapGesture().onEnded {
                            selectScene(scene.id)
                        })

                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: 6) {
                            Button {
                                moveScene(index, toward: .previous)
                            } label: {
                                Image(systemName: "chevron.up")
                            }
                            .buttonStyle(.borderless)
                            .help("Move to previous beat")
                            .disabled(!canMoveScene(index, toward: .previous))

                            Button {
                                moveScene(index, toward: .next)
                            } label: {
                                Image(systemName: "chevron.down")
                            }
                            .buttonStyle(.borderless)
                            .help("Move to next beat")
                            .disabled(!canMoveScene(index, toward: .next))
                        }

                        HStack(spacing: 6) {
                            Button {
                                insertBlankScene(after: index)
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.borderless)
                            .help("Add below")

                            Button(role: .destructive) {
                                removeScene(at: index)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                            .help("Remove")
                        }
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                if !isLast {
                    Rectangle()
                        .fill(Color.primary.opacity(dividerOpacity))
                        .frame(height: 1)
                        .padding(.leading, 12)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isActive ? Color.accentColor.opacity(0.12) : Color(nsColor: .controlBackgroundColor).opacity(0.72)))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(isActive ? Color.accentColor : Color.primary.opacity(0.08), lineWidth: isActive ? 3 : 1))
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .highPriorityGesture(TapGesture().onEnded {
                selectScene(scene.id)
            })
        )
    }

    private func sceneIDs(for beat: BeatTemplate) -> [UUID] {
        wizard.scenes
            .indices
            .filter { wizard.scenes[$0].beatKey == beat.key }
            .map { wizard.scenes[$0].id }
    }

    private struct ActSection: Identifiable {
        let act: Int
        let label: String
        let mediumLabel: String
        let beats: [BeatTemplate]

        var id: Int { act }
    }

    private var actSections: [ActSection] {
        let grouped = Dictionary(grouping: wizard.beats, by: { $0.act })
        return grouped.keys.sorted().compactMap { act in
            guard let beats = grouped[act], let first = beats.first else { return nil }
            return ActSection(
                act: act,
                label: first.actLabel,
                mediumLabel: wizard.structure?.title ?? "Story structure",
                beats: beats)
        }
    }

    private func sceneIndex(for sceneID: UUID) -> Int? {
        wizard.scenes.firstIndex(where: { $0.id == sceneID })
    }

    private func sceneTitleBinding(for sceneID: UUID) -> Binding<String> {
        Binding(
            get: {
                guard let index = sceneIndex(for: sceneID) else { return "" }
                return wizard.scenes[index].title
            },
            set: { newValue in
                guard let index = sceneIndex(for: sceneID), wizard.scenes.indices.contains(index) else { return }
                wizard.scenes[index].title = newValue
                wizard.normalizeSceneOutline()
            }
        )
    }

    private func sceneSummaryBinding(for sceneID: UUID) -> Binding<String> {
        Binding(
            get: {
                guard let index = sceneIndex(for: sceneID) else { return "" }
                return wizard.scenes[index].summary
            },
            set: { newValue in
                guard let index = sceneIndex(for: sceneID), wizard.scenes.indices.contains(index) else { return }
                wizard.scenes[index].summary = newValue
            }
        )
    }

    private func selectScene(_ sceneID: UUID) {
        activeSceneID = sceneID
        focusedSceneID = sceneID
    }

    private func addScene(toBeat beat: BeatTemplate) {
        let insertIndex = insertionIndex(for: beat.key)
        let newScene = SceneOutlineScene(
            act: beat.act,
            beatKey: beat.key,
            beatSceneNumber: wizard.nextSceneNumber(for: beat.key),
            title: beat.title,
            summary: "")
        wizard.scenes.insert(newScene, at: insertIndex)
        wizard.normalizeSceneOutline()
        statusMessage = "Added a new scene."
        statusIsError = false
    }

    private func insertionIndex(for beatKey: String) -> Int {
        let indices = wizard.scenes.indices.filter { wizard.scenes[$0].beatKey == beatKey }
        return (indices.last.map { $0 + 1 }) ?? wizard.scenes.count
    }

    private func insertBlankScene(after index: Int) {
        guard wizard.scenes.indices.contains(index) else { return }
        let beatKey = wizard.scenes[index].beatKey
        let act = wizard.scenes[index].act
        let scene = SceneOutlineScene(
            act: act,
            beatKey: beatKey,
            beatSceneNumber: beatKey.map { wizard.nextSceneNumber(for: $0) } ?? 1,
            title: beatKey.flatMap { key in wizard.beats.first(where: { $0.key == key })?.title } ?? "Scene",
            summary: "")
        wizard.scenes.insert(scene, at: index + 1)
        wizard.normalizeSceneOutline()
        statusMessage = "Inserted a new scene."
        statusIsError = false
    }

    private func removeScene(at index: Int) {
        guard wizard.scenes.indices.contains(index) else { return }
        wizard.scenes.remove(at: index)
        wizard.normalizeSceneOutline()
        statusMessage = "Removed the scene."
        statusIsError = false
    }

    private enum SceneMoveDirection {
        case previous
        case next
    }

    private func canMoveScene(_ index: Int, toward direction: SceneMoveDirection) -> Bool {
        guard wizard.scenes.indices.contains(index) else { return false }
        guard let beatKey = wizard.scenes[index].beatKey,
              let beatIndex = wizard.beats.firstIndex(where: { $0.key == beatKey }) else { return false }
        switch direction {
        case .previous:
            return beatIndex > 0
        case .next:
            return beatIndex < wizard.beats.count - 1
        }
    }

    private func moveScene(_ index: Int, toward direction: SceneMoveDirection) {
        guard wizard.scenes.indices.contains(index) else { return }
        guard let beatKey = wizard.scenes[index].beatKey,
              let beatIndex = wizard.beats.firstIndex(where: { $0.key == beatKey }) else { return }

        let targetBeatIndex: Int
        switch direction {
        case .previous:
            guard beatIndex > 0 else { return }
            targetBeatIndex = beatIndex - 1
        case .next:
            guard beatIndex < wizard.beats.count - 1 else { return }
            targetBeatIndex = beatIndex + 1
        }

        let targetBeat = wizard.beats[targetBeatIndex]
        withAnimation(.easeInOut(duration: 0.22)) {
            let scene = wizard.scenes.remove(at: index)
            let insertIndex = insertionIndex(for: targetBeat.key)
            let movedScene = SceneOutlineScene(
                id: scene.id,
                act: targetBeat.act,
                beatKey: targetBeat.key,
                beatSceneNumber: wizard.nextSceneNumber(for: targetBeat.key),
                title: scene.title,
                summary: scene.summary
            )
            wizard.scenes.insert(movedScene, at: insertIndex)
            wizard.normalizeSceneOutline()
        }
        statusMessage = "Moved the scene to \(targetBeat.title)."
        statusIsError = false
    }

    private func tinyPill(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(tint.opacity(0.12)))
    }

    private func laneColor(for act: Int) -> Color {
        switch act {
        case 1: return .blue
        case 2: return .orange
        case 3: return .green
        default: return .purple
        }
    }

    private func plannedSceneCount(for beat: BeatTemplate) -> Int {
        switch beat.key {
        case "openingImage":   return 1
        case "themeStated":    return 1
        case "setup":          return 7
        case "catalyst":       return 2
        case "debate":         return 4
        case "breakIntoTwo":   return 1
        case "bStory":         return 2
        case "funAndGames":    return 10
        case "midpoint":       return 2
        case "badGuysCloseIn": return 8
        case "allIsLost":      return 2
        case "darkNight":      return 3
        case "breakIntoThree": return 1
        case "finale":         return 12
        case "finalImage":     return 1
        case "teaser":         return 1
        case "exposition":     return 7
        case "risingAction":   return 10
        case "climaxTurn":     return 2
        case "fallingAction":  return 8
        case "resolution":     return 12
        case "tag":            return 1
        default:               return max(1, wizard.scenes.filter { $0.beatKey == beat.key }.count)
        }
    }

    private func openInFinalDraft() {
        let panel = NSSavePanel()
        if let fdxType = UTType(filenameExtension: "fdx") {
            panel.allowedContentTypes = [fdxType]
        }
        let safeTitle = wizard.projectTitle.isEmpty ? "CreateIT" : wizard.projectTitle
        panel.nameFieldStringValue = "\(safeTitle).fdx"
        panel.canCreateDirectories = true
        panel.allowsOtherFileTypes = false
        panel.treatsFilePackagesAsDirectories = false
        panel.isExtensionHidden = false

        if panel.runModal() == .OK, let url = panel.url {
            performFDXExport(to: url, action: .open)
        }
    }

    private func saveFDX() {
        let panel = NSSavePanel()
        if let fdxType = UTType(filenameExtension: "fdx") {
            panel.allowedContentTypes = [fdxType]
        }
        let safeTitle = wizard.projectTitle.isEmpty ? "CreateIT" : wizard.projectTitle
        panel.nameFieldStringValue = "\(safeTitle).fdx"
        panel.canCreateDirectories = true

        if panel.runModal() == .OK, let url = panel.url {
            performFDXExport(to: url, action: .save)
        }
    }

    fileprivate enum FDXExportAction {
        case open
        case save
    }

    fileprivate enum ConflictResolution {
        case openExisting
        case replaceWithNew
        case cancel
    }

    fileprivate struct DraftConflict: Identifiable {
        let id = UUID()
        let url: URL
        let existingFDX: String
        let proposedFDX: String
        let action: FDXExportAction

        var diffSummary: [String] {
            let existingLines = normalizedLines(existingFDX)
            let proposedLines = normalizedLines(proposedFDX)
            let difference = proposedLines.difference(from: existingLines)

            let summary = difference.compactMap { change -> String? in
                switch change {
                case .insert(_, let element, _):
                    return "+ \(element)"
                case .remove(_, let element, _):
                    return "- \(element)"
                }
            }

            return summary.isEmpty ? ["No visible differences were found."] : Array(summary.prefix(24))
        }

        private func normalizedLines(_ text: String) -> [String] {
            text
                .split(whereSeparator: \.isNewline)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
    }

    private func performFDXExport(to url: URL, action: FDXExportAction) {
        let fdx = FDXExporter.export(
            from: wizard,
            beatElement: beatElement,
            includeGuidance: includeGuidance,
            includeSceneScript: true)

        if FileManager.default.fileExists(atPath: url.path),
           let existing = try? String(contentsOf: url, encoding: .utf8),
           existing != fdx {
            draftConflict = DraftConflict(
                url: url,
                existingFDX: existing,
                proposedFDX: fdx,
                action: action)
            return
        }

        writeFDX(fdx, to: url, action: action)
    }

    private func handleConflictDecision(_ decision: ConflictResolution, for conflict: DraftConflict) {
        defer { draftConflict = nil }

        switch decision {
        case .cancel:
            statusMessage = "Kept the existing \(conflict.url.lastPathComponent)."
            statusIsError = false
        case .openExisting:
            NSWorkspace.shared.open(conflict.url)
            statusMessage = "Opened the existing \(conflict.url.lastPathComponent)."
            statusIsError = false
        case .replaceWithNew:
            writeFDX(conflict.proposedFDX, to: conflict.url, action: conflict.action)
        }
    }

    private func writeFDX(_ fdx: String, to url: URL, action: FDXExportAction) {
        do {
            try fdx.write(to: url, atomically: true, encoding: .utf8)
            switch action {
            case .open:
                NSWorkspace.shared.open(url)
                statusMessage = "Opened \(url.lastPathComponent) in Final Draft."
            case .save:
                statusMessage = "Saved \(url.lastPathComponent)."
            }
            statusIsError = false
        } catch {
            statusMessage = error.localizedDescription
            statusIsError = true
        }
    }

    private func saveBeatSheetPDF() {
        let panel = NSSavePanel()
        if let pdfType = UTType(filenameExtension: "pdf") {
            panel.allowedContentTypes = [pdfType]
        }
        let safeTitle = wizard.projectTitle.isEmpty ? "CreateIT" : wizard.projectTitle
        panel.nameFieldStringValue = "\(safeTitle) Beat Sheet.pdf"
        panel.canCreateDirectories = true

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try BeatSheetPDFExporter.export(from: wizard, to: url)
                NSWorkspace.shared.open(url)
                statusMessage = "Saved \(url.lastPathComponent)."
                statusIsError = false
            } catch {
                statusMessage = error.localizedDescription
                statusIsError = true
            }
        }
    }
}

private struct FinalDraftSceneTitleTextField: NSViewRepresentable {
    @Binding var text: String
    var onActivate: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onActivate: onActivate)
    }

    func makeNSView(context: Context) -> FinalDraftSceneTitleField {
        let field = FinalDraftSceneTitleField()
        field.onActivate = onActivate
        field.delegate = context.coordinator
        field.isEditable = true
        field.isSelectable = true
        field.isBordered = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.lineBreakMode = .byTruncatingTail
        field.maximumNumberOfLines = 1
        field.font = NSFont.preferredFont(forTextStyle: .headline)
        field.stringValue = text
        return field
    }

    func updateNSView(_ nsView: FinalDraftSceneTitleField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        var onActivate: () -> Void

        init(text: Binding<String>, onActivate: @escaping () -> Void) {
            _text = text
            self.onActivate = onActivate
        }

        func controlTextDidBeginEditing(_ obj: Notification) {
            onActivate()
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            text = field.stringValue
            onActivate()
        }
    }
}

private final class FinalDraftSceneTitleField: NSTextField {
    var onActivate: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        onActivate?()
        super.mouseDown(with: event)
    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result { onActivate?() }
        return result
    }
}

private struct DraftConflictReviewView: View {
    let conflict: FinalDraftStepView.DraftConflict
    let onDecision: (FinalDraftStepView.ConflictResolution) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Same file name already exists")
                    .font(.title2.weight(.bold))
                Text(conflict.url.lastPathComponent)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text("Compare the existing Final Draft file with the new export below. Choose whether to open the current file or replace it with the newer CreateIT version.")
                .font(.callout)
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: 14) {
                infoCard(title: "Current file", subtitle: "Already on disk", icon: "doc.text")
                infoCard(title: "New export", subtitle: "About to be written", icon: "sparkles")
                infoCard(title: "Differences", subtitle: "\(conflict.diffSummary.count) line changes", icon: "arrow.triangle.2.circlepath")
            }

            GroupBox("Change preview") {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(conflict.diffSummary.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(.callout, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
                .frame(minHeight: 280)
            }

            HStack {
                Button("Cancel") {
                    onDecision(.cancel)
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Open Existing") {
                    onDecision(.openExisting)
                }
                .buttonStyle(.bordered)

                Button("Replace With New") {
                    onDecision(.replaceWithNew)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func infoCard(title: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08)))
    }
}
