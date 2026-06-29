import Foundation
import SwiftUI

enum WizardStep: Int, CaseIterable, Codable {
    case structure
    case format
    case genre
    case sample
    case plot
    case template
    case outline
    case finalDraft

    var title: String {
        switch self {
        case .structure: return "Structure"
        case .format:    return "Format"
        case .genre:     return "Genre"
        case .sample:    return "Sample"
        case .plot:      return "Plot"
        case .template:  return "Beats"
        case .outline:   return "Scenes"
        case .finalDraft:return "Final Draft"
        }
    }
}

@MainActor
final class WizardState: ObservableObject {
    // MARK: - State Data Struct
    struct StateData: Codable {
        var step: WizardStep
        var structure: ScriptStructure?
        var medium: Medium?
        var runtime: Runtime?
        var genre: Genre?
        var sampleMovie: SampleMovie?
        var projectTitle: String
        var logline: String
        var plot: String
        var scenes: [SceneOutlineScene]
        var entries: [String: String]
    }

    @Published var step: WizardStep = .structure

    // Selections
    @Published var structure: ScriptStructure?
    @Published var medium: Medium?
    @Published var runtime: Runtime?
    @Published var genre: Genre?
    @Published var sampleMovie: SampleMovie?

    // Project details
    @Published var projectTitle: String = ""
    @Published var logline: String = ""
    @Published var plot: String = ""
    @Published var scenes: [SceneOutlineScene] = []

    /// Writer's fill-in text, keyed by beat key.
    @Published var entries: [String: String] = [:]

    // MARK: Derived

    var beats: [BeatTemplate] {
        guard let structure, let medium else { return [] }
        return BeatLibrary.beats(for: structure, medium: medium)
    }

    var sampleMovies: [SampleMovie] {
        guard let genre else { return [] }
        return SampleLibrary.movies(for: genre)
    }

    /// Whether the user can advance from the current step.
    var canAdvance: Bool {
        switch step {
        case .structure: return structure != nil
        case .format:    return medium != nil && runtime != nil
        case .genre:     return genre != nil
        case .sample:    return sampleMovie != nil
        case .plot:      return true
        case .template:  return !beats.isEmpty
        case .outline:   return false
        case .finalDraft:return false
        }
    }

    // MARK: Navigation

    func next() {
        guard canAdvance else { return }
        if let nextStep = WizardStep(rawValue: step.rawValue + 1) {
            withAnimation(.easeInOut(duration: 0.25)) { step = nextStep }
        }
    }

    func forceNext() {
        if let nextStep = WizardStep(rawValue: step.rawValue + 1) {
            withAnimation(.easeInOut(duration: 0.25)) { step = nextStep }
        }
    }

    func back() {
        if let prevStep = WizardStep(rawValue: step.rawValue - 1) {
            withAnimation(.easeInOut(duration: 0.25)) { step = prevStep }
        }
    }

    func go(to target: WizardStep) {
        let isCurrentOrEarlier = target.rawValue <= step.rawValue
        let isNextStep = target.rawValue == step.rawValue + 1 && canAdvance
        guard isCurrentOrEarlier || isNextStep else { return }
        withAnimation(.easeInOut(duration: 0.25)) { step = target }
    }

    func reset() {
        withAnimation(.easeInOut(duration: 0.25)) {
            step = .structure
            structure = nil
            medium = nil
            runtime = nil
            genre = nil
            sampleMovie = nil
            projectTitle = ""
            logline = ""
            plot = ""
            scenes = []
            entries = [:]
        }
    }

    // MARK: - Backup / Restore

    func snapshot() -> StateData {
        StateData(
            step: step,
            structure: structure,
            medium: medium,
            runtime: runtime,
            genre: genre,
            sampleMovie: sampleMovie,
            projectTitle: projectTitle,
            logline: logline,
            plot: plot,
            scenes: scenes,
            entries: entries
        )
    }

    func apply(data: StateData) {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.step = data.step
            self.structure = data.structure
            self.medium = data.medium
            self.runtime = data.runtime
            self.genre = data.genre
            self.sampleMovie = data.sampleMovie
            self.projectTitle = data.projectTitle
            self.logline = data.logline
            self.plot = data.plot
            self.scenes = data.scenes
            self.entries = data.entries
        }
    }

    // When genre changes, clear an out-of-genre sample selection.
    func selectGenre(_ newGenre: Genre) {
        if genre != newGenre {
            genre = newGenre
            sampleMovie = nil
        }
    }

    // When medium changes, keep the runtime valid for that medium.
    // Movies always use the standard feature length.
    func selectMedium(_ newMedium: Medium) {
        medium = newMedium
        let options = Runtime.options(for: newMedium)
        if newMedium == .movie {
            runtime = .feature
        } else if let current = runtime, !options.contains(current) {
            runtime = nil
        }
    }

    /// Seeds a scene outline from the current beats and any beat drafts.
    func seedSceneOutlineFromBeats(replacing existing: Bool = false) {
        guard !beats.isEmpty else {
            scenes = []
            return
        }

        if !existing, !scenes.isEmpty {
            return
        }

        scenes = beats.flatMap { beat in
            let count = defaultSceneCount(for: beat)
            return (1...count).map { index in
                SceneOutlineScene(
                    act: beat.act,
                    beatKey: beat.key,
                    beatSceneNumber: index,
                    title: defaultSceneTitle(for: beat, sceneNumber: index, sceneCount: count),
                    summary: sceneSeedText(for: beat, sceneNumber: index, sceneCount: count))
            }
        }

        normalizeSceneOutline()
    }

    func normalizeSceneOutline() {
        var counters: [String: Int] = [:]
        for index in scenes.indices {
            if let beatKey = scenes[index].beatKey {
                counters[beatKey, default: 0] += 1
                scenes[index].beatSceneNumber = counters[beatKey] ?? 1
            }
        }
    }

    func nextSceneNumber(for beatKey: String) -> Int {
        (scenes.filter { $0.beatKey == beatKey }.count) + 1
    }

    var orderedScenes: [SceneOutlineScene] {
        let beatOrder = Dictionary(uniqueKeysWithValues: beats.enumerated().map { ($1.key, $0) })
        return scenes.sorted {
            let lhsBeatIndex = beatOrder[$0.beatKey ?? ""] ?? Int.max
            let rhsBeatIndex = beatOrder[$1.beatKey ?? ""] ?? Int.max
            if lhsBeatIndex != rhsBeatIndex { return lhsBeatIndex < rhsBeatIndex }
            if $0.act != $1.act { return $0.act < $1.act }
            if $0.beatSceneNumber != $1.beatSceneNumber { return $0.beatSceneNumber < $1.beatSceneNumber }
            return $0.id.uuidString < $1.id.uuidString
        }
    }

    func displaySceneNumber(for sceneID: UUID) -> Int {
        orderedScenes.firstIndex(where: { $0.id == sceneID }).map { $0 + 1 } ?? 0
    }

    func sceneNumberLabel(for sceneID: UUID) -> String {
        guard let scene = scene(for: sceneID) else { return "Scene" }
        return "Act \(scene.act) - Scene \(displaySceneNumber(for: sceneID))"
    }

    func sceneDisplayHeading(for sceneID: UUID) -> String {
        guard scene(for: sceneID) != nil else { return "Scene" }
        let title = sceneTitleText(for: sceneID)
        return "\(sceneNumberLabel(for: sceneID)) - \(title)"
    }

    func sceneTitleText(for sceneID: UUID) -> String {
        guard let scene = scene(for: sceneID) else { return "Scene" }
        let trimmed = scene.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        if let beat = beat(for: scene.beatKey) {
            return beat.title
        }
        return "Scene"
    }

    private func scene(for sceneID: UUID) -> SceneOutlineScene? {
        scenes.first(where: { $0.id == sceneID })
    }

    private func beat(for beatKey: String?) -> BeatTemplate? {
        guard let beatKey else { return nil }
        return beats.first(where: { $0.key == beatKey })
    }

    private func defaultSceneCount(for beat: BeatTemplate) -> Int {
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
        default:
            let span = beat.endPct - beat.startPct
            switch span {
            case ..<7:  return 1
            case ..<16: return 2
            case ..<32: return 3
            default:    return 4
            }
        }
    }

    private func defaultSceneTitle(for beat: BeatTemplate, sceneNumber: Int, sceneCount: Int) -> String {
        "Act \(beat.act), \(beat.title), Scene \(sceneNumber)"
    }

    private func sceneSeedText(for beat: BeatTemplate, sceneNumber: Int, sceneCount: Int) -> String {
        let draft = entries[beat.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !draft.isEmpty {
            return draft
        }

        if sceneCount == 1 {
            return "Create a complete scene outline that covers the entire beat: \(beat.purpose)"
        }

        let positionDescription: String
        switch sceneNumber {
        case 1:
            positionDescription = "Start the beat by establishing the key situation and direction"
        case sceneCount:
            positionDescription = "Conclude this section of the beat to prepare for the next beat"
        default:
            positionDescription = "Develop the beat further by escalating tension and advancing the conflict"
        }
        
        return "\(positionDescription). Create a complete, self-contained scene outline that contributes to \(beat.purpose.lowercased())."
    }

    // MARK: Export

    /// Builds a plain-text outline of the whole project.
    func exportText() -> String {
        var lines: [String] = []
        let title = projectTitle.isEmpty ? "Untitled" : projectTitle
        lines.append("CREATEIT OUTLINE")
        lines.append("================")
        lines.append("")
        lines.append("TITLE: \(title)")
        if let structure { lines.append("STRUCTURE: \(structure.title)") }
        if let medium, let runtime { lines.append("FORMAT: \(medium.rawValue) · \(runtime.label)") }
        if let genre { lines.append("GENRE: \(genre.title)") }
        if let sampleMovie { lines.append("SAMPLE STYLE: \(sampleMovie.title) (\(sampleMovie.year))") }
        if !logline.isEmpty {
            lines.append("")
            lines.append("LOGLINE: \(logline)")
        }
        if !plot.isEmpty {
            lines.append("")
            lines.append("PLOT:")
            lines.append(plot)
        }

        if !scenes.isEmpty {
            lines.append("")
            lines.append("SCENE OUTLINE:")
            lines.append("")
            for beat in beats {
                let beatScenes = scenes.filter { $0.beatKey == beat.key }
                guard !beatScenes.isEmpty else { continue }

                lines.append("")
                lines.append("\(beat.title)".uppercased())
                lines.append(String(repeating: "-", count: beat.title.count))
                for scene in beatScenes.sorted(by: { $0.beatSceneNumber < $1.beatSceneNumber }) {
                    lines.append("")
                    lines.append("• \(scene.title) [\(scene.beatSceneNumber)]")
                    let summary = scene.summary.trimmingCharacters(in: .whitespacesAndNewlines)
                    if summary.isEmpty {
                        lines.append("  (No scene summary yet)")
                    } else {
                        lines.append("  \(summary)")
                    }
                }
            }
        }

        lines.append("")
        lines.append("----------------------------------------")
        lines.append("")

        var currentAct = -99
        for beat in beats {
            if beat.act != currentAct {
                currentAct = beat.act
                lines.append(beat.actLabel.uppercased())
                lines.append(String(repeating: "-", count: beat.actLabel.count))
            }
            let runtimeLabel = runtime.map { beat.timing(for: $0) } ?? ""
            lines.append("")
            lines.append("• \(beat.title)  [\(runtimeLabel)]")
            let written = entries[beat.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if written.isEmpty {
                lines.append("  (\(beat.placeholder))")
            } else {
                lines.append("  \(written)")
            }
        }
        lines.append("")
        return lines.joined(separator: "\n")
    }

    private func sceneActLabel(for scene: SceneOutlineScene) -> String {
        beats.first(where: { $0.act == scene.act })?.actLabel ?? "Act \(scene.act)"
    }
}
