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

    @AppStorage("ai.baseURL") var baseURL: String = "http://127.0.0.1:11434"
    @AppStorage("ai.model") var model: String = ""
    @AppStorage("ai.temperature") var temperature: Double = 0.8
    @AppStorage("ai.serverType") var serverType: AIProvider = .lmStudio

    @Published var availableModels: [LMStudioClient.Model] = []
    
    // Persisted models for UI display when not connected
    private let persistedModelsKey = "ai.availableModels"
    
    @Published var connection: ConnectionState = .unknown
    /// Beat keys currently generating, so the UI can show per-beat spinners.
    @Published var generating: Set<String> = []
    @Published private(set) var lastOutlineResponse: String?

    enum OutlineError: LocalizedError {
        case noModelSelected
        case noBeatsAvailable
        case unparseableResponse(String)

        var errorDescription: String? {
            switch self {
            case .noModelSelected:
                return "Choose a model first."
            case .noBeatsAvailable:
                return "No beats are available for the current wizard selections."
            case .unparseableResponse(let preview):
                return
                    "LM Studio returned text the app could not parse as a story outline: \(preview)"
            }
        }
    }

    var isConfigured: Bool {
        if case .connected = connection { return !model.isEmpty }
        return false
    }

    // MARK: Connection

    func testConnection() async {
        connection = .connecting
        do {
            switch serverType {
            case .lmStudio:
                let lmModels = try await LMStudioClient(baseURL: baseURL).listModels()
                availableModels = lmModels
                model = lmModels.first?.id ?? ""
            case .ollama:
                let olModels = try await OllamaClient(baseURL: baseURL).listModels()
                // Convert Ollama Model to LMStudio Model (they have same structure)
                availableModels = olModels.map { LMStudioClient.Model(id: $0.id, displayName: $0.displayName) }
                model = olModels.first?.id ?? ""
            }
            connection = .connected(modelCount: availableModels.count)
            // Persist models for future use
            savePersistedModels()
        } catch {
            availableModels = []
            model = ""
            connection = .failed(error.localizedDescription)
        }
    }
    
    /// Load persisted models from UserDefaults
    func loadPersistedModels() {
        guard let data = UserDefaults.standard.data(forKey: persistedModelsKey),
              let models = try? JSONDecoder().decode([LMStudioClient.Model].self, from: data) else {
            return
        }
        availableModels = models
    }
    
    /// Save current models to UserDefaults
    func savePersistedModels() {
        guard let data = try? JSONEncoder().encode(availableModels) else { return }
        UserDefaults.standard.set(data, forKey: persistedModelsKey)
    }

    // Ollama now uses OpenAI-compatible API, so no conversion needed

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
        if let m = wizard.medium, let r = wizard.runtime {
            context += "Format: \(m.rawValue), \(r.label)\n"
        }
        if !wizard.selectedGenres.isEmpty { let genreList = wizard.selectedGenres.joined(separator: ", "); context += "Genre: (genreList)\n" }
        if !wizard.projectTitle.isEmpty { context += "Title: \(wizard.projectTitle)\n" }
        if !wizard.logline.isEmpty { context += "Logline: \(wizard.logline)\n" }
        if !wizard.plot.isEmpty { context += "Plot:\n\(wizard.plot)\n" }

        // Include any text the writer already started, to continue their voice.
        let existing =
            wizard.entries[beat.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let existingBlock =
            existing.isEmpty
            ? "" : "The writer's draft so far (build on this, keep their intent):\n\(existing)\n"

        let user = """
            \(context)
            Write the "\(beat.title)" beat.
            Purpose of this beat: \(beat.purpose)
            \(existingBlock)
            Return only the beat description.
            """

         // Use appropriate client based on server type
         switch serverType {
         case .lmStudio:
             let lmClient = LMStudioClient(baseURL: baseURL)
             do {
                 return try await lmClient.complete(
                     model: model,
                     system: system,
                     user: user,
                     temperature: temperature)
             } catch {
                 if Self.isCancellation(error) { return nil }
                 connection = .failed(error.localizedDescription)
                 return nil
             }
          case .ollama:
              let olClient = OllamaClient(baseURL: baseURL)
              do {
                 return try await olClient.complete(
                     model: model,
                     system: system,
                     user: user,
                     temperature: temperature)
             } catch {
                 if Self.isCancellation(error) { return nil }
                 connection = .failed(error.localizedDescription)
                 return nil
             }
         }
    }

    /// Expands a quick outline line into fuller beat prose.
    func expandBeatOutline(_ outline: String, beat: BeatTemplate, wizard: WizardState) async
        -> String?
    {
        guard !model.isEmpty else {
            connection = .failed("Choose a model first.")
            return nil
        }

        let trimmedOutline = outline.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedOutline.isEmpty else { return nil }

        generating.insert(beat.key)
        defer { generating.remove(beat.key) }

        let system = """
            You are a professional screenwriting assistant helping a writer turn a quick \
            beat outline into fuller beat prose. Expand the provided outline into 2–4 \
            present-tense sentences that feel concrete, cinematic, and specific to the \
            beat's dramatic purpose. Keep the writer's intent intact. Return prose only \
            with no heading, label, or commentary.
            """

        let context = projectContext(for: wizard)
        let reference = referenceContext(for: wizard, beatKey: beat.key)

        let user = """
            Project context:
            \(context)

            \(reference)
            Beat:
            - Title: \(beat.title)
            - Purpose: \(beat.purpose)
            - Timing: \(beat.timing(for: wizard.runtime ?? .feature))

            Quick outline:
            \(trimmedOutline)

            Expand this into full beat prose.
            """

         // Use appropriate client based on server type
         switch serverType {
         case .lmStudio:
             let lmClient = LMStudioClient(baseURL: baseURL)
             do {
                 return try await lmClient.complete(
                     model: model,
                     system: system,
                     user: user,
                     temperature: temperature,
                     maxTokens: 900)
             } catch {
                 if Self.isCancellation(error) { return nil }
                 connection = .failed(error.localizedDescription)
                 return nil
             }
          case .ollama:
              let olClient = OllamaClient(baseURL: baseURL)
              do {
                  return try await olClient.complete(
                      model: model,
                      system: system,
                      user: user,
                      temperature: temperature,
                      maxTokens: 900)
             } catch {
                 if Self.isCancellation(error) { return nil }
                 connection = .failed(error.localizedDescription)
                 return nil
             }
         }
    }

    /// Drafts a scene outline row from a beat's existing material.
    func draftSceneOutline(
        for beat: BeatTemplate,
        sceneID: UUID,
        sceneIndex: Int,
        sceneCount: Int,
        seedText: String,
        wizard: WizardState
    ) async -> String? {
        guard !model.isEmpty else {
            connection = .failed("Choose a model first.")
            return nil
        }

        let trimmedSeed = seedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSeed.isEmpty else { return nil }

        let sceneKey = "scene:\(sceneID.uuidString)"
        generating.insert(sceneKey)
        defer { generating.remove(sceneKey) }

        let system = """
            You are a professional screenwriting assistant helping a writer build a scene \
            outline from story beats. Turn the provided beat material into a concise scene \
            outline entry for one scene within the beat. Keep it specific, cinematic, and \
            easy to edit by hand. Return 1–3 present-tense sentences only, with no heading, \
            label, or commentary.
            
            IMPORTANT: Each scene must be unique and distinct from other scenes in the same beat. 
            Focus on creating a progressive sequence where each scene builds on the previous one.
            """

        let context = projectContext(for: wizard)

        let user = """
            Project context:
            \(context)

            Beat:
            - Title: \(beat.title)
            - Purpose: \(beat.purpose)
            - Timing: \(beat.timing(for: wizard.runtime ?? .feature))
            - Scene position: \(sceneIndex) of \(sceneCount)

            Beat material for this specific scene:
            \(trimmedSeed)

            Write a unique scene outline entry for this specific scene in the beat's sequence.
            Make sure this scene is different from other scenes in the same beat and contributes uniquely to the beat's progression.
            """

         // Use appropriate client based on server type
         switch serverType {
         case .lmStudio:
             let lmClient = LMStudioClient(baseURL: baseURL)
             do {
                 return try await lmClient.complete(
                     model: model,
                     system: system,
                     user: user,
                     temperature: temperature,
                     maxTokens: 500)
             } catch {
                 if Self.isCancellation(error) { return nil }
                 connection = .failed(error.localizedDescription)
                 return nil
             }
          case .ollama:
              let olClient = OllamaClient(baseURL: baseURL)
              do {
                  return try await olClient.complete(
                      model: model,
                      system: system,
                      user: user,
                      temperature: temperature,
                      maxTokens: 500)
             } catch {
                 if Self.isCancellation(error) { return nil }
                 connection = .failed(error.localizedDescription)
                 return nil
             }
         }
    }

    /// Generates a beat-by-beat story outline keyed by beat id.
    func createStoryOutline(wizard: WizardState) async throws -> [String: String] {
        guard !model.isEmpty else {
            connection = .failed("Choose a model first.")
            throw OutlineError.noModelSelected
        }

        let beats = wizard.beats
        guard !beats.isEmpty else {
            throw OutlineError.noBeatsAvailable
        }

        let system = """
            You are a professional screenwriting assistant helping a writer build a story \
            outline. Return only the final outline, not reasoning, analysis, or commentary. \
            Use the exact beat ids or exact beat titles provided by the app. Keep each beat \
            very short: one quick outline sentence, or at most two very short sentences. \
            The goal is to produce a compact beat-by-beat pass that can be expanded into full \
            beat prose later.
            """

        var context = ""
        if let s = wizard.structure { context += "Structure: \(s.title)\n" }
        if let m = wizard.medium, let r = wizard.runtime {
            context += "Format: \(m.rawValue), \(r.label)\n"
        }
        if !wizard.selectedGenres.isEmpty { let genreList = wizard.selectedGenres.joined(separator: ", "); context += "Genre: (genreList)\n" }
        if !wizard.projectTitle.isEmpty { context += "Title: \(wizard.projectTitle)\n" }
        if !wizard.logline.isEmpty { context += "Logline: \(wizard.logline)\n" }
        if !wizard.plot.isEmpty { context += "Plot:\n\(wizard.plot)\n" }

        var beatList = ""
        for beat in beats {
            beatList += """
                - \(beat.key): \(beat.title)
                  Purpose: \(beat.purpose)
                  Timing: \(beat.timing(for: wizard.runtime ?? .feature))
                """
            beatList += "\n"
        }

        let user = """
            Project context:
            \(context)

            Beat map:
            \(beatList)

            Existing beat drafts:
            \(existingDraftsContext(for: wizard))

            Return exactly one entry for each of these exact beats, in order.
            Keep each entry to a quick outline sentence.
            Do not skip any beats. Do not add preamble, explanation, or extra notes.
            \(beats.map { "- \($0.key): \($0.title)" }.joined(separator: "\n"))
            """

         // Use appropriate client based on server type
         switch serverType {
         case .lmStudio:
             let lmClient = LMStudioClient(baseURL: baseURL)
             do {
                 let response = try await lmClient.complete(
                     model: model,
                     system: system,
                     user: user,
                     temperature: min(temperature, 0.2),
                     maxTokens: 4096)
                 lastOutlineResponse = response
                 if let outline = Self.parseOutlineResponse(
                     response,
                     beats: beats)
                 {
                     return outline
                 }

                 return Self.fallbackOutline(from: response, beats: beats)
             } catch {
                 if Self.isCancellation(error) { throw CancellationError() }
                 connection = .failed(error.localizedDescription)
                 throw error
             }
          case .ollama:
              let olClient = OllamaClient(baseURL: baseURL)
              do {
                  let response = try await olClient.complete(
                      model: model,
                      system: system,
                      user: user,
                      temperature: min(temperature, 0.2),
                      maxTokens: 4096)
                 lastOutlineResponse = response
                 if let outline = Self.parseOutlineResponse(
                     response,
                     beats: beats)
                 {
                     return outline
                 }

                 return Self.fallbackOutline(from: response, beats: beats)
             } catch {
                 if Self.isCancellation(error) { throw CancellationError() }
                 connection = .failed(error.localizedDescription)
                 throw error
             }
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

         // Use appropriate client based on server type
         switch serverType {
         case .lmStudio:
             let lmClient = LMStudioClient(baseURL: baseURL)
             do {
                 return try await lmClient.complete(
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
                 if Self.isCancellation(error) { return nil }
                 connection = .failed(error.localizedDescription)
                 return nil
             }
          case .ollama:
              let olClient = OllamaClient(baseURL: baseURL)
              do {
                  return try await olClient.complete(
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
                 if Self.isCancellation(error) { return nil }
                 connection = .failed(error.localizedDescription)
                 return nil
             }
         }
    }

    private func projectContext(for wizard: WizardState) -> String {
        var context = ""
        if let s = wizard.structure { context += "Structure: \(s.title)\n" }
        if let m = wizard.medium, let r = wizard.runtime {
            context += "Format: \(m.rawValue), \(r.label)\n"
        }
        if !wizard.selectedGenres.isEmpty { let genreList = wizard.selectedGenres.joined(separator: ", "); context += "Genre: (genreList)\n" }
        if !wizard.projectTitle.isEmpty { context += "Title: \(wizard.projectTitle)\n" }
        if !wizard.logline.isEmpty { context += "Logline: \(wizard.logline)\n" }
        if !wizard.plot.isEmpty { context += "Plot:\n\(wizard.plot)\n" }
        if !wizard.scenes.isEmpty {
            context += "Scene outline:\n"
            for scene in wizard.scenes {
                let summary = scene.summary.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !summary.isEmpty else { continue }
                context += "- \(scene.title): \(summary)\n"
            }
        }
        if !wizard.entries.isEmpty {
            context += "Beat draft notes:\n"
            for beat in wizard.beats {
                let written =
                    wizard.entries[beat.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !written.isEmpty else { continue }
                context += "- \(beat.title): \(written)\n"
            }
        }
        return context.isEmpty ? "No project details have been entered yet." : context
    }

    // Note: referenceContext removed in v3.0b24 - no sample selection step
    private func referenceContext(for wizard: WizardState, beatKey: String?) -> String {
        ""  // No sample movie reference available
    }

    private static func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        if let urlError = error as? URLError, urlError.code == .cancelled { return true }
        return Task.isCancelled
    }

    private func existingDraftsContext(for wizard: WizardState) -> String {
        guard !wizard.entries.isEmpty else { return "No beat drafts yet." }

        var context = ""
        for beat in wizard.beats {
            let written =
                wizard.entries[beat.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !written.isEmpty else { continue }
            context += "- \(beat.key): \(written)\n"
        }
        return context.isEmpty ? "No beat drafts yet." : context
    }

    private static func parseOutlineResponse(_ text: String, beats: [BeatTemplate]) -> [String:
        String]?
    {
        let aliases = outlineAliases(for: beats)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let stripped = stripMarkdownFences(from: trimmed)

        let objectCandidates = jsonObjectCandidates(from: stripped)
        for candidate in objectCandidates {
            if let result = parseOutlineJSONObject(candidate, aliases: aliases), !result.isEmpty {
                return result
            }
        }

        if let result = parseOutlineKeyValueLines(stripped, aliases: aliases), !result.isEmpty {
            return result
        }

        if let result = parseOutlineHeadingSections(stripped, aliases: aliases), !result.isEmpty {
            return result
        }

        if let result = parseOutlineSequentially(stripped, beats: beats), !result.isEmpty {
            return result
        }

        return nil
    }

    private static func responsePreview(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 120 { return "\"\(trimmed)\"" }
        let index = trimmed.index(trimmed.startIndex, offsetBy: 120)
        return "\"\(trimmed[..<index])…\""
    }

    private static func parseOutlineJSONObject(_ text: String, aliases: [String: String])
        -> [String: String]?
    {
        guard let data = text.data(using: .utf8) else { return nil }
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        var result: [String: String] = [:]
        for (key, value) in object {
            guard let canonicalKey = canonicalBeatKey(from: key, aliases: aliases) else { continue }
            if let string = value as? String {
                let cleaned = string.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleaned.isEmpty { result[canonicalKey] = cleaned }
                continue
            }
            if let nested = value as? [String: Any] {
                if let string = nested["text"] as? String ?? nested["outline"] as? String ?? nested[
                    "content"] as? String
                {
                    let cleaned = string.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !cleaned.isEmpty { result[canonicalKey] = cleaned }
                }
            }
        }
        return result
    }

    private static func parseOutlineKeyValueLines(_ text: String, aliases: [String: String])
        -> [String: String]?
    {
        let lines = text.components(separatedBy: .newlines)
        var result: [String: String] = [:]
        var currentKey: String?

        for rawLine in lines {
            let line = stripBulletPrefix(rawLine.trimmingCharacters(in: .whitespacesAndNewlines))
            guard !line.isEmpty else { continue }

            if let colonIndex = line.firstIndex(of: ":") {
                let key = String(line[..<colonIndex]).trimmingCharacters(
                    in: .whitespacesAndNewlines)
                let value = String(line[line.index(after: colonIndex)...]).trimmingCharacters(
                    in: .whitespacesAndNewlines)
                if let canonicalKey = canonicalBeatKey(from: key, aliases: aliases), !value.isEmpty
                {
                    currentKey = canonicalKey
                    result[canonicalKey] = value
                    continue
                }
            }

            if let key = currentKey {
                let existing = result[key, default: ""]
                result[key] = existing.isEmpty ? line : "\(existing) \(line)"
            }
        }

        return result.isEmpty ? nil : result
    }

    private static func parseOutlineHeadingSections(_ text: String, aliases: [String: String])
        -> [String: String]?
    {
        let lines = text.components(separatedBy: .newlines)
        var result: [String: String] = [:]
        var currentKey: String?

        for rawLine in lines {
            let line = stripBulletPrefix(rawLine.trimmingCharacters(in: .whitespacesAndNewlines))
            guard !line.isEmpty else { continue }

            let heading = stripHeadingPrefix(line)
            if let canonicalKey = canonicalBeatKey(from: heading, aliases: aliases) {
                currentKey = canonicalKey
                if let colonIndex = line.firstIndex(of: ":") {
                    let value = String(line[line.index(after: colonIndex)...]).trimmingCharacters(
                        in: .whitespacesAndNewlines)
                    if !value.isEmpty {
                        result[canonicalKey] = value
                    }
                }
                continue
            }

            if let key = currentKey {
                let existing = result[key, default: ""]
                result[key] = existing.isEmpty ? line : "\(existing) \(line)"
            }
        }

        return result.isEmpty ? nil : result
    }

    private static func outlineAliases(for beats: [BeatTemplate]) -> [String: String] {
        var aliases: [String: String] = [:]
        for beat in beats {
            aliases[normalizeBeatLabel(beat.key)] = beat.key
            aliases[normalizeBeatLabel(beat.title)] = beat.key
        }
        return aliases
    }

    private static func canonicalBeatKey(from label: String, aliases: [String: String]) -> String? {
        aliases[normalizeBeatLabel(label)]
    }

    private static func normalizeBeatLabel(_ label: String) -> String {
        let lowered = label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return lowered.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }.map(
            String.init
        ).joined()
    }

    private static func stripMarkdownFences(from text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```") {
            cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
            cleaned = cleaned.replacingOccurrences(of: "```JSON", with: "")
            cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func jsonObjectCandidates(from text: String) -> [String] {
        var candidates: [String] = []
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if let start = trimmed.firstIndex(of: "{"), let end = trimmed.lastIndex(of: "}") {
            candidates.append(String(trimmed[start...end]))
        }
        if let start = trimmed.firstIndex(of: "["), let end = trimmed.lastIndex(of: "]") {
            candidates.append(String(trimmed[start...end]))
        }
        candidates.append(trimmed)
        candidates.append(trimmed.replacingOccurrences(of: ",\n}", with: "\n}"))
        candidates.append(trimmed.replacingOccurrences(of: ",}", with: "}"))
        return candidates
    }

    private static func stripBulletPrefix(_ line: String) -> String {
        var cleaned = line
        while cleaned.hasPrefix("-") || cleaned.hasPrefix("•") || cleaned.hasPrefix("–")
            || cleaned.hasPrefix("*")
        {
            cleaned.removeFirst()
            cleaned = cleaned.trimmingCharacters(in: .whitespaces)
        }

        if let dotIndex = cleaned.firstIndex(where: { $0 == "." }),
            cleaned[..<dotIndex].allSatisfy({ $0.isNumber })
        {
            cleaned = String(cleaned[cleaned.index(after: dotIndex)...]).trimmingCharacters(
                in: .whitespaces)
        }

        return cleaned
    }

    private static func stripHeadingPrefix(_ line: String) -> String {
        var cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
        while cleaned.hasPrefix("#") {
            cleaned.removeFirst()
            cleaned = cleaned.trimmingCharacters(in: .whitespaces)
        }

        if let colonIndex = cleaned.firstIndex(of: ":") {
            return String(cleaned[..<colonIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return cleaned
    }

    private static func parseOutlineSequentially(_ text: String, beats: [BeatTemplate]) -> [String:
        String]?
    {
        let paragraphs =
            text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { !isGenericOutlineNoise($0) }

        guard !paragraphs.isEmpty else { return nil }

        var result: [String: String] = [:]
        var paragraphIndex = 0

        for beat in beats {
            guard paragraphIndex < paragraphs.count else { break }
            let collected = collectParagraphs(from: paragraphs, startingAt: &paragraphIndex)
            if !collected.isEmpty {
                result[beat.key] = collected
            }
        }

        return result.isEmpty ? nil : result
    }

    private static func fallbackOutline(from text: String, beats: [BeatTemplate]) -> [String:
        String]
    {
        let paragraphs =
            text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let chunks: [String]
        if paragraphs.count > 1 {
            chunks = paragraphs
        } else {
            chunks = splitIntoSentences(text)
        }

        guard !beats.isEmpty else { return [:] }

        let usableChunks =
            chunks.isEmpty ? [text.trimmingCharacters(in: .whitespacesAndNewlines)] : chunks
        var result: [String: String] = [:]

        for (index, beat) in beats.enumerated() {
            let chunkIndex = min(index, usableChunks.count - 1)
            let chunk = usableChunks[chunkIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !chunk.isEmpty else { continue }
            result[beat.key] = chunk
        }

        return result
    }

    private static func splitIntoSentences(_ text: String) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let nsText = trimmed as NSString
        var sentences: [String] = []
        nsText.enumerateSubstrings(
            in: NSRange(location: 0, length: nsText.length),
            options: [.bySentences, .substringNotRequired]
        ) { _, range, _, _ in
            let sentence = nsText.substring(with: range).trimmingCharacters(
                in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                sentences.append(sentence)
            }
        }
        return sentences.isEmpty ? [trimmed] : sentences
    }

    private static func collectParagraphs(from paragraphs: [String], startingAt index: inout Int)
        -> String
    {
        guard index < paragraphs.count else { return "" }

        var pieces: [String] = []
        let first = paragraphs[index]
        pieces.append(first)
        index += 1

        while index < paragraphs.count {
            let paragraph = paragraphs[index]
            if looksLikeNewBeatHeading(paragraph) && !pieces.isEmpty {
                break
            }
            if paragraph.lowercased().hasPrefix("act ") || paragraph.lowercased().hasPrefix("beat ")
            {
                break
            }
            if paragraph.count > 220 && pieces.count > 0 {
                break
            }
            pieces.append(paragraph)
            index += 1
            if pieces.joined(separator: " ").count > 260 {
                break
            }
        }

        return pieces.joined(separator: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func looksLikeNewBeatHeading(_ line: String) -> Bool {
        let stripped = stripHeadingPrefix(stripBulletPrefix(line))
        return stripped.lowercased().hasPrefix("act ") || stripped.lowercased().hasPrefix("beat ")
    }

    private static func isGenericOutlineNoise(_ line: String) -> Bool {
        let lower = line.lowercased()
        return lower.hasPrefix("here is") || lower.hasPrefix("here's")
            || lower.hasPrefix("below is") || lower.hasPrefix("outline:")
            || lower.hasPrefix("story outline") || lower == "json" || lower == "markdown"
    }
}
