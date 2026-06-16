import Foundation
import SwiftUI

/// Holds local-LLM connection settings and drives AI writing requests.
/// Settings persist in `UserDefaults` so the chosen endpoint and model
/// survive relaunches.
@MainActor
final class AIAssistant: ObservableObject {

    enum ConnectionState: Equatable {
        case unknown
        case connecting
        case connected(modelCount: Int)
        case failed(String)
    }

    @AppStorage("ai.baseURL") var baseURL: String = "http://127.0.0.1:1234/v1"
    @AppStorage("ai.model") var model: String = ""
    @AppStorage("ai.temperature") var temperature: Double = 0.8

    @Published var availableModels: [LMStudioClient.Model] = []
    @Published var connection: ConnectionState = .unknown
    /// Beat keys currently generating, so the UI can show per-beat spinners.
    @Published var generating: Set<String> = []

    var isConfigured: Bool {
        if case .connected = connection { return !model.isEmpty }
        return false
    }

    private var client: LMStudioClient { LMStudioClient(baseURL: baseURL) }

    // MARK: Connection

    func testConnection() async {
        connection = .connecting
        do {
            let models = try await client.listModels()
            availableModels = models
            if model.isEmpty, let first = models.first { model = first.id }
            connection = .connected(modelCount: models.count)
        } catch {
            availableModels = []
            connection = .failed(error.localizedDescription)
        }
    }

    // MARK: Generation

    /// Generates beat prose using the project context as guidance.
    func draftBeat(_ beat: BeatTemplate, wizard: WizardState) async -> String? {
        guard !model.isEmpty else {
            connection = .failed("Choose a model first.")
            return nil
        }
        generating.insert(beat.key)
        defer { generating.remove(beat.key) }

        let system = """
        You are a professional screenwriting assistant helping a writer outline a \
        script. You write concise, vivid beat descriptions in present tense. You \
        follow the writer's plot and the structural purpose of the requested beat. \
        Use the provided reference film only as a structural guide for pacing and \
        function — never copy its plot, characters, or lines. Respond with 2–4 \
        sentences of outline prose only, no headings or preamble.
        """

        var context = ""
        if let s = wizard.structure { context += "Structure: \(s.title)\n" }
        if let m = wizard.medium, let r = wizard.runtime { context += "Format: \(m.rawValue), \(r.label)\n" }
        if let g = wizard.genre { context += "Genre: \(g.title)\n" }
        if !wizard.projectTitle.isEmpty { context += "Title: \(wizard.projectTitle)\n" }
        if !wizard.logline.isEmpty { context += "Logline: \(wizard.logline)\n" }
        if !wizard.plot.isEmpty { context += "Plot:\n\(wizard.plot)\n" }

        var reference = ""
        if let movie = wizard.sampleMovie {
            reference += "Reference film for structural guidance only: \(movie.title) (\(movie.year)).\n"
            if let sample = movie.sample(for: beat.key) {
                reference += "How that film handles this beat (for pacing/function, do not copy): \(sample)\n"
            }
        }

        // Include any text the writer already started, to continue their voice.
        let existing = wizard.entries[beat.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let existingBlock = existing.isEmpty ? "" : "The writer's draft so far (build on this, keep their intent):\n\(existing)\n"

        let user = """
        \(context)
        \(reference)
        Write the "\(beat.title)" beat.
        Purpose of this beat: \(beat.purpose)
        \(existingBlock)
        Return only the beat description.
        """

        do {
            return try await client.complete(
                model: model,
                system: system,
                user: user,
                temperature: temperature)
        } catch {
            connection = .failed(error.localizedDescription)
            return nil
        }
    }

    /// Answers a free-form prompt using the current project as context.
    /// When a beat is provided, the answer is tailored to that beat.
    func answerPrompt(_ prompt: String, beat: BeatTemplate?, wizard: WizardState) async -> String? {
        guard !model.isEmpty else {
            connection = .failed("Choose a model first.")
            return nil
        }

        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else { return nil }

        let context = projectContext(for: wizard)
        let reference = referenceContext(for: wizard, beatKey: beat?.key)
        let beatInstructions: String
        if let beat {
            beatInstructions = """
            Target beat:
            - Title: \(beat.title)
            - Purpose: \(beat.purpose)
            - Timing: \(beat.timing(for: wizard.runtime ?? .feature))
            """
        } else {
            beatInstructions = "Target beat: none specified."
        }

        do {
            return try await client.complete(
                model: model,
                system: """
                You are a professional screenwriting assistant helping a writer shape an \
                outline. Use the provided project context and target beat to answer the \
                writer's prompt with practical, specific guidance. Keep the tone concise \
                and useful. If a target beat is provided, focus on that beat and write in \
                outline prose. Do not add headings unless the user explicitly asks for them.
                """,
                user: """
                Project context:
                \(context)

                \(reference)
                \(beatInstructions)

                Writer prompt:
                \(trimmedPrompt)

                Respond directly to the prompt.
                """,
                temperature: temperature,
                maxTokens: 600)
        } catch {
            connection = .failed(error.localizedDescription)
            return nil
        }
    }

    private func projectContext(for wizard: WizardState) -> String {
        var context = ""
        if let s = wizard.structure { context += "Structure: \(s.title)\n" }
        if let m = wizard.medium, let r = wizard.runtime { context += "Format: \(m.rawValue), \(r.label)\n" }
        if let g = wizard.genre { context += "Genre: \(g.title)\n" }
        if !wizard.projectTitle.isEmpty { context += "Title: \(wizard.projectTitle)\n" }
        if !wizard.logline.isEmpty { context += "Logline: \(wizard.logline)\n" }
        if !wizard.plot.isEmpty { context += "Plot:\n\(wizard.plot)\n" }
        if !wizard.entries.isEmpty {
            context += "Beat draft notes:\n"
            for beat in wizard.beats {
                let written = wizard.entries[beat.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !written.isEmpty else { continue }
                context += "- \(beat.title): \(written)\n"
            }
        }
        return context.isEmpty ? "No project details have been entered yet." : context
    }

    private func referenceContext(for wizard: WizardState, beatKey: String?) -> String {
        guard let movie = wizard.sampleMovie else { return "" }
        var reference = "Reference film for structural guidance only: \(movie.title) (\(movie.year)).\n"
        if let beatKey, let sample = movie.sample(for: beatKey) {
            reference += "How that film handles this beat (for pacing/function, do not copy): \(sample)\n"
        }
        return reference
    }
}
