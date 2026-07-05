import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct OutlineStepView: View {
    @EnvironmentObject private var wizard: WizardState
    @EnvironmentObject private var ai: AIAssistant
    @Binding private var scrollTargetBeatKey: String?
    @State private var showCopiedToast = false
    @State private var isDraftingScenes = false
    @State private var sceneDraftStatus: String?
    @State private var sceneDraftError: String?
    @State private var draggedSceneID: UUID?
    @State private var hoveredSceneID: UUID?
    @State private var activeSceneID: UUID?
    @State private var activeSceneAIDraftID: UUID?
    @State private var beatElement: BeatElement = .card
    @State private var includeGuidance = true
    @State private var collapsedBeatKeys: Set<String> = []
    @State private var editingScene: SceneOutlineScene?

    init(scrollTargetBeatKey: Binding<String?> = .constant(nil)) {
        _scrollTargetBeatKey = scrollTargetBeatKey
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top, spacing: 16) {
                StepHeader(
                    eyebrow: "Step 6",
                    title: "Scenes",
                    subtitle: "Browse and edit individual scenes. Click a scene card to open it for editing.")
                Spacer(minLength: 16)
                scenesExportMenu
            }

            sceneProgressBar

            summaryChips

            HStack(spacing: 10) {
                Button {
                    draftScenesWithAI()
                } label: {
                    if isDraftingScenes {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text(sceneButtonLabel)
                        }
                    } else {
                        Label("Draft Scene List with AI", systemImage: "sparkles")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isDraftingScenes || !ai.isConfigured || wizard.beats.isEmpty)

                Button {
                    wizard.seedSceneOutlineFromBeats(replacing: true)
                    wizard.normalizeSceneOutline()
                    sceneDraftStatus = "Scene outline refreshed from beats."
                    sceneDraftError = nil
                } label: {
                    Label("Sync from Beats", systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(.bordered)
                .disabled(wizard.beats.isEmpty)

                Button {
                    addSceneToEnd()
                } label: {
                    Label("Add Scene", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                .disabled(wizard.beats.isEmpty)

                Spacer()
            }

            if let sceneDraftError {
                Text(sceneDraftError)
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else if let sceneDraftStatus {
                Text(sceneDraftStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if wizard.scenes.isEmpty {
                emptyState
            } else {
                boardSummary
                sceneBoard
            }
        }
        .onAppear {
            if wizard.scenes.isEmpty {
                wizard.seedSceneOutlineFromBeats()
            }
            wizard.normalizeSceneOutline()
        }
        .onChange(of: wizard.beats.map(\.key)) { _, _ in
            if wizard.scenes.isEmpty {
                wizard.seedSceneOutlineFromBeats()
            }
            wizard.normalizeSceneOutline()
        }
        .overlay(alignment: .bottom) {
            if showCopiedToast {
                Text("Outline copied to clipboard")
                    .font(.callout.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(.black.opacity(0.8)))
                    .foregroundStyle(.white)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 8)
            }
        }
        .sheet(item: $editingScene) { scene in
            EditSceneView(scene: scene) { updatedScene in
                if let index = wizard.scenes.firstIndex(where: { $0.id == scene.id }) {
                    wizard.scenes[index] = updatedScene
                }
            }
        }
    }

    private var summaryChips: some View {
        HStack(spacing: 8) {
            if let s = wizard.structure { chip(s.rawValue, "rectangle.split.3x1") }
            if let m = wizard.medium { chip(m.rawValue, m.symbol) }
            if let r = wizard.runtime { chip(r.label, "clock") }
            if !wizard.selectedGenres.isEmpty { let genreList = wizard.selectedGenres.joined(separator: ", "); chip(genreList, "tag") }
            Spacer()
        }
    }

    private func chip(_ text: String, _ symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(Color.accentColor.opacity(0.12)))
            .foregroundStyle(.tint)
    }

    private var scenesExportMenu: some View {
        Menu {
            Button {
                copyToClipboard()
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }

            Button {
                exportToFile()
            } label: {
                Label("Export…", systemImage: "square.and.arrow.up")
            }

            Divider()

            Picker("Beat style", selection: $beatElement) {
                ForEach(BeatElement.allCases) { element in
                    Text(element.label).tag(element)
                }
            }
            .pickerStyle(.inline)

            Toggle("Include guidance & references", isOn: $includeGuidance)

            Divider()

            Button {
                exportFDX()
            } label: {
                Label("Save .fdx…", systemImage: "square.and.arrow.down")
            }
        } label: {
            Label("Save / Export", systemImage: "film.stack")
        }
        .menuStyle(.borderlessButton)
        .buttonStyle(.borderedProminent)
    }

    private var sceneProgressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(scenesWithContentCount) of \(wizard.scenes.count) scenes drafted")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.18))
                    Capsule().fill(Color.accentColor)
                        .frame(width: geo.size.width * sceneProgressFraction)
                }
            }
            .frame(height: 8)
        }
    }

    private var scenesWithContentCount: Int {
        wizard.scenes.filter { scene in
            let summary = scene.summary.trimmingCharacters(in: .whitespacesAndNewlines)
            let title = scene.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let beatTitle = scene.beatKey.flatMap { key in wizard.beats.first(where: { $0.key == key })?.title } ?? ""
            return !summary.isEmpty || (!title.isEmpty && title != beatTitle)
        }.count
    }

    private var sceneProgressFraction: CGFloat {
        guard !wizard.scenes.isEmpty else { return 0 }
        return CGFloat(scenesWithContentCount) / CGFloat(wizard.scenes.count)
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
            Text("No scenes yet.")
                .font(.headline)
            Text("Use the beats to seed the scenes, then edit each scene line directly in the table or ask AI to draft them for you.")
                .font(.callout)
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                Button("Sync from Beats") {
                    wizard.seedSceneOutlineFromBeats(replacing: true)
                    sceneDraftStatus = "Scene outline refreshed from beats."
                    sceneDraftError = nil
                }
                .buttonStyle(.borderedProminent)

                Button("Add Scene") {
                    addSceneToEnd()
                }
                .buttonStyle(.bordered)
            }
            .disabled(wizard.beats.isEmpty)
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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(wizard.orderedScenes) { scene in
                    SceneCardView(
                        scene: scene,
                        beat: wizard.beat(for: scene.beatKey),
                        isSelected: editingScene?.id == scene.id,
                        laneColor: laneColor(for: scene.act)) {
                            selectScene(scene.id)
                        }
                }
            }
            .padding(.horizontal, 16)
        }
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
        let isActive = activeSceneID == scene.id
        let dividerOpacity = isLast ? 0 : 0.08

        return AnyView(
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(wizard.sceneNumberLabel(for: sceneID))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        HStack(spacing: 8) {
                            Image(systemName: "line.3.horizontal")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(laneColor)
                                .onDrag {
                                    draggedSceneID = scene.id
                                    return NSItemProvider(object: scene.id.uuidString as NSString)
                                }

                            Text("Drag to reorder within this beat")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            Spacer(minLength: 0)
                        }
                    }
                    .frame(width: 190, alignment: .leading)

                    VStack(alignment: .leading, spacing: 10) {
                        SceneSummaryTextEditor(text: sceneSummaryBinding(for: sceneID)) {
                            selectScene(scene.id)
                        }
                        .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isActive ? Color.accentColor.opacity(0.06) : Color(nsColor: .textBackgroundColor)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(isActive ? Color.accentColor.opacity(0.35) : laneColor.opacity(0.12), lineWidth: isActive ? 1.5 : 1))
                        .onChange(of: sceneSummaryBinding(for: sceneID).wrappedValue) { _, _ in
                            selectScene(scene.id)
                        }

                        HStack(spacing: 10) {
                            Button {
                                draftSceneWithAI(sceneID: scene.id, index: index)
                            } label: {
                                if activeSceneAIDraftID == scene.id {
                                    HStack(spacing: 6) {
                                        ProgressView().controlSize(.small)
                                        Text("Draft with AI")
                                    }
                                } else {
                                    Label("Draft with AI", systemImage: "sparkles")
                                }
                            }
                            .disabled(isDraftingScenes || activeSceneAIDraftID != nil || !ai.isConfigured)
                            .controlSize(.small)

                            if !ai.isConfigured {
                                Text("Connect a local LLM in the AI menu")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer(minLength: 0)
                        }
                    }

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
            .simultaneousGesture(TapGesture().onEnded {
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

    private func beatBoardSection(for group: BeatGroup) -> some View {
        let isCollapsed = collapsedBeatKeys.contains(group.beat.key)
        let planned = plannedSceneCount(for: group.beat)
        let current = group.sceneIDs.count
        let laneColor = laneColor(for: group.beat.act)

        return VStack(alignment: .leading, spacing: 12) {
            Button {
                toggleBeat(group.beat.key)
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(laneColor)
                        .frame(width: 6, height: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(group.beat.title)
                                .font(.title3.weight(.bold))
                            Text("\(group.sceneIDs.count) scenes")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.accentColor.opacity(0.16)))
                                .foregroundStyle(.tint)
                        }
                        HStack(spacing: 8) {
                            Text("Planned \(plannedSceneCount(for: group.beat))")
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                        beatProgress(current: current, planned: planned, tint: laneColor)
                    }
                    Spacer()
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if !isCollapsed {
                VStack(alignment: .leading, spacing: 16) {
                    Text(group.beat.purpose)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(group.sceneIDs, id: \.self) { sceneID in
                        sceneRow(for: sceneID)
                    }

                    Button {
                        addScene(toBeat: group.beat)
                    } label: {
                        Label("Add Scene in \(group.beat.title)", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.leading, 10)
                .padding(.top, 2)
            } else {
                HStack(spacing: 8) {
                    Text("Scenes hidden")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                    Text("\(current) / \(planned)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(laneColor)
                    GeometryReader { geo in
                        Capsule()
                            .fill(laneColor.opacity(0.12))
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(laneColor)
                                    .frame(width: geo.size.width * CGFloat(min(current, planned)) / CGFloat(max(planned, 1)))
                            }
                    }
                    .frame(width: 92, height: 6)
                }
                .padding(.leading, 10)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            laneColor.opacity(0.11),
                            Color(nsColor: .controlBackgroundColor)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(laneColor.opacity(0.16)))
        .id(group.beat.key)
    }

    private struct BeatGroup {
        let beat: BeatTemplate
        let sceneIDs: [UUID]
    }

    private var beatGroups: [BeatGroup] {
        wizard.beats.compactMap { beat in
            let sceneIDs = wizard.scenes.filter { $0.beatKey == beat.key }.map(\.id)
            guard !sceneIDs.isEmpty else { return nil }
            return BeatGroup(beat: beat, sceneIDs: sceneIDs)
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

    @ViewBuilder
    private func sceneRow(for sceneID: UUID) -> some View {
        if let index = sceneIndex(for: sceneID) {
            let scene = wizard.scenes[index]
            let laneColor = laneColor(for: scene.act)
            let isHovered = hoveredSceneID == scene.id
            let isDragged = draggedSceneID == scene.id
            let isActive = activeSceneID == scene.id
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(laneColor)
                        .frame(width: 6, height: 28)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(wizard.sceneNumberLabel(for: sceneID))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        SceneTitleTextField(text: sceneTitleBinding(for: sceneID)) {
                            selectScene(scene.id)
                        }
                        .font(.headline)
                        .frame(minHeight: 22)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isActive ? Color.accentColor.opacity(0.06) : Color.clear))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(isActive ? Color.accentColor : Color.primary.opacity(0.0), lineWidth: isActive ? 2 : 0))

                        HStack(spacing: 8) {
                            Image(systemName: "line.3.horizontal")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(laneColor)
                                .onDrag {
                                    draggedSceneID = scene.id
                                    return NSItemProvider(object: scene.id.uuidString as NSString)
                                }

                            Text("Drag to reorder within this beat")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            Spacer()
                        }
                    }
                    .contentShape(Rectangle())
                    .simultaneousGesture(TapGesture().onEnded {
                        selectScene(scene.id)
                    })
                }

                HStack {
                    Button {
                        draftSceneWithAI(sceneID: scene.id, index: index)
                    } label: {
                        if activeSceneAIDraftID == scene.id {
                            HStack(spacing: 6) {
                                ProgressView().controlSize(.small)
                                Text("Draft with AI")
                            }
                        } else {
                            Label("Draft with AI", systemImage: "sparkles")
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                    .disabled(isDraftingScenes || activeSceneAIDraftID != nil || !ai.isConfigured)

                    Spacer()
                }

                    SceneSummaryTextEditor(text: sceneSummaryBinding(for: sceneID)) {
                        selectScene(scene.id)
                    }
                    .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isActive ? Color.accentColor.opacity(0.06) : Color(nsColor: .textBackgroundColor)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isActive ? Color.accentColor : laneColor.opacity(0.12), lineWidth: isActive ? 2 : 1))
                    .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .simultaneousGesture(TapGesture().onEnded {
                        selectScene(scene.id)
                    })

                HStack(spacing: 10) {
                    Button {
                        insertBlankScene(after: index)
                    } label: {
                        Label("Add Below", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        removeScene(at: index)
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Text(sceneActLabel(for: scene))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(laneColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(laneColor.opacity(0.12)))

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
            }
            .padding(16)
            .scaleEffect(isHovered && draggedSceneID != nil ? 1.008 : 1.0)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                (isActive ? Color.accentColor.opacity(0.18) : (isHovered || isDragged ? laneColor.opacity(0.18) : laneColor.opacity(0.10))),
                                Color(nsColor: .controlBackgroundColor)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing)))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder((isActive ? Color.accentColor : (isHovered || isDragged ? laneColor.opacity(0.38) : laneColor.opacity(0.18))), lineWidth: isActive ? 4 : (isHovered || isDragged ? 1.5 : 1)))
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [laneColor.opacity(0.22), laneColor.opacity(0.08), .clear],
                            startPoint: .top,
                            endPoint: .bottom))
                    .frame(width: 6)
                    .padding(.vertical, 8)
                    .padding(.leading, 4)
            }
            .shadow(color: isActive ? Color.accentColor.opacity(0.22) : (isHovered ? laneColor.opacity(0.14) : .clear), radius: isActive ? 14 : 10, x: 0, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .simultaneousGesture(TapGesture().onEnded {
                selectScene(scene.id)
            })
            .onHover { hovering in
                if hovering {
                    hoveredSceneID = scene.id
                } else if hoveredSceneID == scene.id {
                    hoveredSceneID = nil
                }
            }
            .onDrop(of: [UTType.text], delegate: SceneReorderDropDelegate(
                beatKey: scene.beatKey,
                targetSceneID: scene.id,
                draggedSceneID: $draggedSceneID,
                scrollTargetBeatKey: $scrollTargetBeatKey,
                scenes: $wizard.scenes,
                normalize: { wizard.normalizeSceneOutline() }
            ))
        }
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
        if let scene = wizard.scenes.first(where: { $0.id == sceneID }) {
            editingScene = scene
        }
    }

    private func draftScenesWithAI() {
        isDraftingScenes = true
        sceneDraftError = nil
        sceneDraftStatus = "Drafting scenes from beats..."
        Task { @MainActor in
            defer { isDraftingScenes = false }

            do {
                guard !wizard.beats.isEmpty else { return }

                if wizard.scenes.isEmpty {
                    wizard.seedSceneOutlineFromBeats(replacing: true)
                }

                for (beatIndex, beat) in wizard.beats.enumerated() {
                    let beatScenes = wizard.scenes.indices.filter { wizard.scenes[$0].beatKey == beat.key }
                    guard !beatScenes.isEmpty else { continue }

                    for (scenePosition, sceneIndex) in beatScenes.enumerated() {
                        if Task.isCancelled { throw CancellationError() }
                        let scene = wizard.scenes[sceneIndex]
                        sceneDraftStatus = "Drafting \(beat.title) scene \(scenePosition + 1) of \(beatScenes.count)"
                        let seed = scene.summary.trimmingCharacters(in: .whitespacesAndNewlines)
                        let input = seed.isEmpty ? beat.purpose : seed
                        let summary = await ai.draftSceneOutline(
                            for: beat,
                            sceneID: scene.id,
                            sceneIndex: scene.beatSceneNumber,
                            sceneCount: beatScenes.count,
                            seedText: input,
                            wizard: wizard)
                        let cleaned = (summary ?? input).trimmingCharacters(in: .whitespacesAndNewlines)
                        wizard.scenes[sceneIndex].summary = cleaned
                        if wizard.scenes[sceneIndex].title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || wizard.scenes[sceneIndex].title == "New Scene" {
                            wizard.scenes[sceneIndex].title = "Scene \(scenePosition + 1)"
                        }
                    }

                    if beatIndex < wizard.beats.count - 1 {
                        sceneDraftStatus = "Finished \(beat.title). Moving to the next beat..."
                    }
                }

                wizard.normalizeSceneOutline()
                sceneDraftStatus = "Finished drafting scene lists from beats."
            } catch is CancellationError {
                sceneDraftStatus = nil
            } catch {
                sceneDraftError = error.localizedDescription
                sceneDraftStatus = nil
            }
        }
    }

    private func addSceneToEnd() {
        guard let beat = wizard.beats.last else { return }
        addScene(toBeat: beat)
    }

    private func addScene(toBeat beat: BeatTemplate) {
        let insertIndex = insertionIndex(for: beat.key)
        let newScene = SceneOutlineScene(
            act: beat.act,
            beatKey: beat.key,
            beatSceneNumber: wizard.nextSceneNumber(for: beat.key),
            title: "Scene \(wizard.nextSceneNumber(for: beat.key))",
            summary: "")
        wizard.scenes.insert(newScene, at: insertIndex)
        wizard.normalizeSceneOutline()
        sceneDraftStatus = "Added a new scene."
        sceneDraftError = nil
    }

    private func draftSceneWithAI(sceneID: UUID, index: Int) {
        guard wizard.scenes.indices.contains(index) else { return }
        guard let beatKey = wizard.scenes[index].beatKey,
              let beat = wizard.beats.first(where: { $0.key == beatKey }) else { return }

        activeSceneAIDraftID = sceneID
        sceneDraftError = nil
        sceneDraftStatus = "Drafting \(wizard.sceneNumberLabel(for: sceneID))..."

        Task { @MainActor in
            defer { activeSceneAIDraftID = nil }

            let scene = wizard.scenes[index]
            let seed = scene.summary.trimmingCharacters(in: .whitespacesAndNewlines)
            let input = seed.isEmpty ? beat.purpose : seed

            guard let summary = await ai.draftSceneOutline(
                for: beat,
                sceneID: sceneID,
                sceneIndex: scene.beatSceneNumber,
                sceneCount: wizard.scenes.filter { $0.beatKey == beat.key }.count,
                seedText: input,
                wizard: wizard)
            else {
                return
            }

            let cleaned = summary.trimmingCharacters(in: .whitespacesAndNewlines)
            if let updateIndex = sceneIndex(for: sceneID), wizard.scenes.indices.contains(updateIndex) {
                wizard.scenes[updateIndex].summary = cleaned
                if wizard.scenes[updateIndex].title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || wizard.scenes[updateIndex].title == "New Scene" {
                    wizard.scenes[updateIndex].title = "Scene \(wizard.scenes[updateIndex].beatSceneNumber)"
                }
                sceneDraftStatus = "Finished drafting \(wizard.sceneNumberLabel(for: sceneID))."
                sceneDraftError = nil
            }
        }
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
            title: "Scene \(beatKey.map { wizard.nextSceneNumber(for: $0) } ?? 1)",
            summary: "")
        wizard.scenes.insert(scene, at: index + 1)
        wizard.normalizeSceneOutline()
        sceneDraftStatus = "Inserted a new scene."
        sceneDraftError = nil
    }

    private func removeScene(at index: Int) {
        guard wizard.scenes.indices.contains(index) else { return }
        wizard.scenes.remove(at: index)
        wizard.normalizeSceneOutline()
        sceneDraftStatus = "Removed the scene."
        sceneDraftError = nil
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
        sceneDraftStatus = "Moved the scene to \(targetBeat.title)."
        sceneDraftError = nil
        draggedSceneID = nil
        hoveredSceneID = nil
        scrollTargetBeatKey = targetBeat.key
    }

    private func copyToClipboard() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(wizard.exportText(), forType: .string)
        withAnimation { showCopiedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { showCopiedToast = false }
        }
    }

    private func exportToFile() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        let safeTitle = wizard.projectTitle.isEmpty ? "CreateIT Outline" : wizard.projectTitle
        panel.nameFieldStringValue = "\(safeTitle).txt"
        panel.canCreateDirectories = true
        if panel.runModal() == .OK, let url = panel.url {
            try? wizard.exportText().write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private func exportFDX() {
        let panel = NSSavePanel()
        if let fdxType = UTType(filenameExtension: "fdx") {
            panel.allowedContentTypes = [fdxType]
        }
        let safeTitle = wizard.projectTitle.isEmpty ? "CreateIT" : wizard.projectTitle
        panel.nameFieldStringValue = "\(safeTitle).fdx"
        panel.canCreateDirectories = true
        if panel.runModal() == .OK, let url = panel.url {
            let fdx = FDXExporter.export(from: wizard, beatElement: beatElement, includeGuidance: includeGuidance)
            try? fdx.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private var sceneButtonLabel: String {
        sceneDraftStatus ?? "Creating..."
    }

    private func sceneIndex(for sceneID: UUID) -> Int? {
        wizard.scenes.firstIndex(where: { $0.id == sceneID })
    }

    private func tinyPill(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(tint.opacity(0.12)))
    }

    private func beatProgress(current: Int, planned: Int, tint: Color) -> some View {
        HStack(spacing: 8) {
            Text("\(current)/\(planned)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 38, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(tint.opacity(0.12))
                    Capsule().fill(tint)
                        .frame(width: geo.size.width * CGFloat(min(current, planned)) / CGFloat(max(planned, 1)))
                }
            }
            .frame(height: 5)
            .frame(maxWidth: 72)
        }
        .padding(.top, 2)
    }

    private func sceneActLabel(for scene: SceneOutlineScene) -> String {
        if let beatKey = scene.beatKey,
           let beat = wizard.beats.first(where: { $0.key == beatKey }) {
            return beat.actLabel
        }
        return "Act \(scene.act)"
    }

    private func laneColor(for act: Int) -> Color {
        switch act {
        case 1: return .blue
        case 2: return .orange
        case 3: return .green
        default: return .purple
        }
    }

    private func toggleBeat(_ beatKey: String) {
        if collapsedBeatKeys.contains(beatKey) {
            collapsedBeatKeys.remove(beatKey)
        } else {
            collapsedBeatKeys.insert(beatKey)
        }
    }
}

private struct SceneSummaryTextEditor: NSViewRepresentable {
    @Binding var text: String
    var onActivate: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onActivate: onActivate)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = SceneSummaryEditorScrollView()
        scrollView.onActivate = onActivate
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = .clear
        scrollView.focusRingType = .none

        let textView = SceneSummaryEditorTextView()
        textView.onActivate = onActivate
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.importsGraphics = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.drawsBackground = true
        textView.backgroundColor = .textBackgroundColor
        textView.font = NSFont.preferredFont(forTextStyle: .body)
        
        // Set left alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        textView.defaultParagraphStyle = paragraphStyle
        
        textView.string = text

        scrollView.documentView = textView
        context.coordinator.textView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = context.coordinator.textView else { return }
        if textView.string != text {
            textView.string = text
        }
        textView.backgroundColor = .textBackgroundColor
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        var onActivate: () -> Void
        weak var textView: SceneSummaryEditorTextView?

        init(text: Binding<String>, onActivate: @escaping () -> Void) {
            _text = text
            self.onActivate = onActivate
        }

        func textDidBeginEditing(_ notification: Notification) {
            onActivate()
        }

        func textDidChange(_ notification: Notification) {
            guard let textView else { return }
            text = textView.string
            onActivate()
        }
    }
}

private struct SceneTitleTextField: NSViewRepresentable {
    @Binding var text: String
    var onActivate: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onActivate: onActivate)
    }

    func makeNSView(context: Context) -> SceneTitleField {
        let field = SceneTitleField()
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

    func updateNSView(_ nsView: SceneTitleField, context: Context) {
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

private final class SceneSummaryEditorScrollView: NSScrollView {
    var onActivate: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        onActivate?()
        super.mouseDown(with: event)
    }
}

private final class SceneSummaryEditorTextView: NSTextView {
    var onActivate: (() -> Void)?

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result { onActivate?() }
        return result
    }

    override func mouseDown(with event: NSEvent) {
        onActivate?()
        super.mouseDown(with: event)
    }
}

private final class SceneTitleField: NSTextField {
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

private struct SceneReorderDropDelegate: DropDelegate {
    let beatKey: String?
    let targetSceneID: UUID
    @Binding var draggedSceneID: UUID?
    @Binding var scrollTargetBeatKey: String?
    @Binding var scenes: [SceneOutlineScene]
    let normalize: () -> Void

    func dropEntered(info: DropInfo) {
        guard let draggedSceneID, draggedSceneID != targetSceneID else { return }
        guard let fromIndex = scenes.firstIndex(where: { $0.id == draggedSceneID }),
              let toIndex = scenes.firstIndex(where: { $0.id == targetSceneID }) else { return }
        guard scenes[fromIndex].beatKey == beatKey, scenes[toIndex].beatKey == beatKey else { return }

        scrollTargetBeatKey = beatKey

        withAnimation(.easeInOut(duration: 0.18)) {
            let item = scenes.remove(at: fromIndex)
            let adjustedIndex = fromIndex < toIndex ? max(0, toIndex - 1) : toIndex
            scenes.insert(item, at: adjustedIndex)
            normalize()
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedSceneID = nil
        scrollTargetBeatKey = nil
        normalize()
        return true
    }
}
