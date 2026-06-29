import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct SampleMovieReference: Codable, Equatable {
    let title: String
    let year: Int
    let genre: Genre

    func resolve() -> SampleMovie? {
        SampleLibrary.all.first {
            $0.title == title && $0.year == year && $0.genre == genre
        }
    }
}

struct SavedTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var projectTitle: String
    var logline: String
    var plot: String
    var structure: ScriptStructure?
    var medium: Medium?
    var runtime: Runtime?
    var genre: Genre?
    var sampleMovie: SampleMovieReference?
    var entries: [String: String]
    var scenes: [SceneOutlineScene]
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, projectTitle, logline, plot, structure, medium, runtime, genre, sampleMovie, entries, scenes, createdAt, updatedAt
    }

    init(
        id: UUID = UUID(),
        projectTitle: String,
        logline: String,
        plot: String,
        structure: ScriptStructure?,
        medium: Medium?,
        runtime: Runtime?,
        genre: Genre?,
        sampleMovie: SampleMovieReference?,
        entries: [String: String],
        scenes: [SceneOutlineScene] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.projectTitle = projectTitle
        self.logline = logline
        self.plot = plot
        self.structure = structure
        self.medium = medium
        self.runtime = runtime
        self.genre = genre
        self.sampleMovie = sampleMovie
        self.entries = entries
        self.scenes = scenes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        projectTitle = try container.decode(String.self, forKey: .projectTitle)
        logline = try container.decode(String.self, forKey: .logline)
        plot = try container.decode(String.self, forKey: .plot)
        structure = try container.decodeIfPresent(ScriptStructure.self, forKey: .structure)
        medium = try container.decodeIfPresent(Medium.self, forKey: .medium)
        runtime = try container.decodeIfPresent(Runtime.self, forKey: .runtime)
        genre = try container.decodeIfPresent(Genre.self, forKey: .genre)
        sampleMovie = try container.decodeIfPresent(SampleMovieReference.self, forKey: .sampleMovie)
        entries = try container.decodeIfPresent([String: String].self, forKey: .entries) ?? [:]
        scenes = try container.decodeIfPresent([SceneOutlineScene].self, forKey: .scenes) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? .now
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? .now
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(projectTitle, forKey: .projectTitle)
        try container.encode(logline, forKey: .logline)
        try container.encode(plot, forKey: .plot)
        try container.encodeIfPresent(structure, forKey: .structure)
        try container.encodeIfPresent(medium, forKey: .medium)
        try container.encodeIfPresent(runtime, forKey: .runtime)
        try container.encodeIfPresent(genre, forKey: .genre)
        try container.encodeIfPresent(sampleMovie, forKey: .sampleMovie)
        try container.encode(entries, forKey: .entries)
        try container.encode(scenes, forKey: .scenes)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }

    @MainActor
    init(from wizard: WizardState) {
        self.init(
            projectTitle: wizard.projectTitle,
            logline: wizard.logline,
            plot: wizard.plot,
            structure: wizard.structure,
            medium: wizard.medium,
            runtime: wizard.runtime,
            genre: wizard.genre,
            sampleMovie: wizard.sampleMovie.map {
                SampleMovieReference(title: $0.title, year: $0.year, genre: $0.genre)
            },
            entries: wizard.entries,
            scenes: wizard.scenes
        )
    }

    @MainActor
    mutating func update(from wizard: WizardState) {
        projectTitle = wizard.projectTitle
        logline = wizard.logline
        plot = wizard.plot
        structure = wizard.structure
        medium = wizard.medium
        runtime = wizard.runtime
        genre = wizard.genre
        sampleMovie = wizard.sampleMovie.map {
            SampleMovieReference(title: $0.title, year: $0.year, genre: $0.genre)
        }
        entries = wizard.entries
        scenes = wizard.scenes
        updatedAt = .now
    }

    var displayTitle: String {
        let trimmed = projectTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled Beat" : trimmed
    }

    var initials: String {
        let words = displayTitle
            .split(whereSeparator: { $0.isWhitespace || $0 == "-" })
            .prefix(2)

        let letters = words.compactMap { $0.first }.map(String.init)
        let joined = letters.joined()
        return joined.isEmpty ? "UT" : joined.uppercased()
    }

    var subtitle: String {
        var parts: [String] = []
        if let structure { parts.append(structure.rawValue) }
        if let medium { parts.append(medium.rawValue) }
        if let runtime { parts.append(runtime.label) }
        if let genre { parts.append(genre.title) }
        if parts.isEmpty { parts.append("No selections yet") }
        return parts.joined(separator: " · ")
    }

    var beatCount: Int {
        entries.values.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
}

@MainActor
final class TemplateLibraryStore: ObservableObject {
    @Published private(set) var templates: [SavedTemplate] = []
    @Published var selectedTemplateID: UUID?
    @Published var projectOpenToken = UUID()

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    init() {
        load()
    }

    var selectedTemplate: SavedTemplate? {
        guard let selectedTemplateID else { return nil }
        return templates.first(where: { $0.id == selectedTemplateID })
    }

    func saveCurrent(from wizard: WizardState) {
        if let selectedTemplateID, let index = templates.firstIndex(where: { $0.id == selectedTemplateID }) {
            templates[index].update(from: wizard)
        } else {
            let saved = SavedTemplate(from: wizard)
            templates.insert(saved, at: 0)
            selectedTemplateID = saved.id
        }
        sortTemplates()
        persist()
    }

    func open(_ template: SavedTemplate, into wizard: WizardState) {
        selectedTemplateID = template.id
        projectOpenToken = UUID()
        wizard.step = template.scenes.isEmpty ? .template : .outline
        wizard.structure = template.structure
        wizard.medium = template.medium
        wizard.runtime = template.runtime
        wizard.genre = template.genre
        wizard.sampleMovie = template.sampleMovie?.resolve()
        wizard.projectTitle = template.projectTitle
        wizard.logline = template.logline
        wizard.plot = template.plot
        wizard.entries = template.entries
        wizard.scenes = template.scenes
    }

    func startNewDraft(with wizard: WizardState) {
        selectedTemplateID = nil
        wizard.reset()
    }

    func delete(_ template: SavedTemplate) {
        templates.removeAll { $0.id == template.id }
        if selectedTemplateID == template.id {
            selectedTemplateID = nil
        }
        persist()
    }

    func deleteSelected() {
        guard let selectedTemplate else { return }
        delete(selectedTemplate)
    }

    private func load() {
        guard let url = storageURL, let data = try? Data(contentsOf: url) else {
            templates = []
            return
        }

        do {
            templates = try decoder.decode([SavedTemplate].self, from: data)
            sortTemplates()
        } catch {
            templates = []
        }
    }

    private func persist() {
        guard let url = storageURL else { return }
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try encoder.encode(templates)
            try data.write(to: url, options: [.atomic])
        } catch {
            // Intentionally ignore persistence failures for local drafts.
        }
    }

    private func sortTemplates() {
        templates.sort { $0.updatedAt > $1.updatedAt }
    }

    private var storageURL: URL? {
        let fm = FileManager.default
        guard let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return base.appendingPathComponent("CreateIT", isDirectory: true)
            .appendingPathComponent("templates.json")
    }

    /// Saves the current wizard state to a backup file selected by the user
    @MainActor
    func saveBackup(from wizard: WizardState) async -> (success: Bool, message: String) {
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
                    return (false, "Save cancelled")
                }
                do {
                    try data.write(to: url, options: .atomic)
                    return (true, "Project state saved successfully to:\n\(url.path)")
                } catch {
                    return (false, "Save failed: \(error.localizedDescription)")
                }
            default:
                // User cancelled
                return (false, "Save cancelled")
            }
        } catch {
            return (false, "Encoding failed: \(error.localizedDescription)")
        }
    }

    /// Restores wizard state from a backup file selected by the user
    @MainActor
    func restoreBackup(into wizard: WizardState) async -> (success: Bool, message: String) {
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
                    return (false, "No file selected")
                }
                do {
                    let data = try Data(contentsOf: selectedURL)
                    let decoder = JSONDecoder()
                    let stateData = try decoder.decode(
                        WizardState.StateData.self, from: data)
                    wizard.apply(data: stateData)
                    return (true, "Project state restored successfully!")
                } catch {
                    return (false, "Restore failed: \(error.localizedDescription)")
                }
            default:
                // User cancelled
                return (false, "No file selected")
            }
        } catch {
            return (false, "Error: \(error.localizedDescription)")
        }
    }
}
