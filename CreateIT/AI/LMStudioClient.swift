import Foundation

/// Minimal client for LM Studio's native API (default endpoint `http://localhost:1234/api/v1`)
/// or Ollama's OpenAI-compatible API.
struct LMStudioClient {

    struct Model: Identifiable, Hashable, Decodable, Encodable {
        let id: String
        let displayName: String
    }

    enum ClientError: LocalizedError {
        case badURL
        case server(String)
        case empty

        var errorDescription: String? {
            switch self {
            case .badURL: return "The server URL is invalid."
            case .server(let msg): return msg
            case .empty: return "The model returned an empty response."
            }
        }
    }

    /// Base URL, e.g. "http://127.0.0.1:1234/v1".
    var baseURL: String

    private func endpoint(_ path: String) throws -> URL {
        let trimmed = baseURL.trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: trimmed + path) else { throw ClientError.badURL }
        return url
    }

    private func apiEndpoint(_ path: String) throws -> URL {
        let trimmed = baseURL.trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        // LM Studio native API uses /api/v1 endpoint
        var apiBase = trimmed
        if !apiBase.hasSuffix("/api/v1") {
            if apiBase.hasSuffix("/v1") {
                apiBase = String(apiBase.dropLast(3)) + "/api/v1"
            } else {
                apiBase = trimmed + "/api/v1"
            }
        }
        guard let url = URL(string: apiBase + path) else { throw ClientError.badURL }
        return url
    }

    // MARK: Models

    /// Lists loaded models exposed by LM Studio (`GET /api/v1/models`).
    func listModels() async throws -> [Model] {
        let url = try apiEndpoint("/models")
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        let (data, response) = try await URLSession.shared.data(for: request)
        try Self.validate(response, data)

        struct ModelsResponse: Decodable {
            struct Entry: Decodable {
                struct LoadedInstance: Decodable {
                    let id: String
                }

                let key: String
                let display_name: String
                let loaded_instances: [LoadedInstance]
            }
            let models: [Entry]
        }
        let decoded = try JSONDecoder().decode(ModelsResponse.self, from: data)
        return decoded.models.flatMap { model in
            model.loaded_instances.map {
                Model(id: $0.id, displayName: model.display_name)
            }
        }
    }

    // MARK: Chat

    /// Sends a chat completion request and returns the assistant's text.
    func complete(
        model: String,
        system: String,
        user: String,
        temperature: Double = 0.8,
        maxTokens: Int = 700
    ) async throws -> String {
        let url = try apiEndpoint("/chat/completions")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        let payload: [String: Any] = [
            "model": model,
            "temperature": temperature,
            "max_tokens": maxTokens,
            "stream": false,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user],
            ],
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try Self.validate(response, data)
        if let text = Self.extractText(from: data)?.trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty
        {
            return text
        }
        throw ClientError.empty
    }

    // MARK: Helpers

    private static func validate(_ response: URLResponse, _ data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw ClientError.server("Server returned \(http.statusCode). \(body)")
        }
    }

    private static func extractText(from data: Data) -> String? {
        if let plain = String(data: data, encoding: .utf8) {
            let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.first != "{", trimmed.first != "[" {
                return trimmed
            }
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return String(data: data, encoding: .utf8)
        }

        return extractText(from: json)
    }

    private static func extractText(from object: Any) -> String? {
        if let string = object as? String {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        if let array = object as? [Any] {
            for item in array {
                if let text = extractText(from: item) {
                    return text
                }
            }
            return nil
        }

        guard let dict = object as? [String: Any] else { return nil }

        if let choices = dict["choices"] as? [Any] {
            for choice in choices {
                if let text = extractChoiceText(choice) {
                    return text
                }
            }
        }

        if let message = dict["message"] {
            if let text = extractMessageText(message) {
                return text
            }
        }

        if let text = preferredText(in: dict) {
            return text
        }

        return nil
    }

    private static func extractChoiceText(_ object: Any) -> String? {
        guard let dict = object as? [String: Any] else {
            return extractText(from: object)
        }

        if let message = dict["message"], let text = extractMessageText(message) {
            return text
        }

        if let delta = dict["delta"], let text = extractMessageText(delta) {
            return text
        }

        if let text = preferredText(in: dict) {
            return text
        }

        return nil
    }

    private static func extractMessageText(_ object: Any) -> String? {
        guard let dict = object as? [String: Any] else {
            return extractText(from: object)
        }

        if let text = preferredText(in: dict) {
            return text
        }

        return nil
    }

    private static func preferredText(in dict: [String: Any]) -> String? {
        let prioritizedKeys = [
            "content",
            "text",
            "output_text",
            "reasoning_content",
        ]

        for key in prioritizedKeys {
            if let value = value(for: key, in: dict), let text = extractText(from: value) {
                return text
            }
        }

        for (key, value) in dict {
            let normalized = normalizeKey(key)
            if normalized == "content" || normalized == "text" || normalized == "outputtext"
                || normalized == "reasoningcontent"
            {
                if let text = extractText(from: value) {
                    return text
                }
            }
        }

        return nil
    }

    private static func value(for key: String, in dict: [String: Any]) -> Any? {
        if let value = dict[key] { return value }
        let normalized = normalizeKey(key)
        return dict.first(where: { normalizeKey($0.key) == normalized })?.value
    }

    private static func normalizeKey(_ key: String) -> String {
        key
            .lowercased()
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
}

// MARK: - Ollama Client

/// Ollama client using OpenAI-compatible API (same as LM Studio)
/// Ollama supports `/v1/models` and `/v1/chat/completions`.
struct OllamaClient {

    struct Model: Identifiable, Hashable {
        let id: String
        let displayName: String
    }

    enum ClientError: LocalizedError {
        case badURL
        case server(String)
        case empty

        var errorDescription: String? {
            switch self {
            case .badURL: return "The server URL is invalid."
            case .server(let msg): return msg
            case .empty: return "The model returned an empty response."
            }
        }
    }

    /// Base URL, e.g. "http://localhost:11434/v1".
    var baseURL: String

    private func apiEndpoint(_ path: String) throws -> URL {
        let trimmed = baseURL.trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let apiBase: String
        if trimmed.hasSuffix("/v1") {
            apiBase = trimmed
        } else {
            apiBase = trimmed + "/v1"
        }
        guard let url = URL(string: apiBase + path) else { throw ClientError.badURL }
        return url
    }

    // MARK: Models

    /// Lists available models from Ollama (`GET /v1/models`).
    func listModels() async throws -> [Model] {
        let url = try apiEndpoint("/models")
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        let (data, response) = try await URLSession.shared.data(for: request)
        try Self.validate(response, data)

        // Ollama OpenAI-compatible API returns {"data": [{"id": "...", ...}]}
        struct ModelsResponse: Decodable {
            struct ModelInfo: Decodable {
                let id: String
                let object: String?
                let created: Int64?
                let owned_by: String?
            }
            let data: [ModelInfo]
        }

        let decoded = try JSONDecoder().decode(ModelsResponse.self, from: data)
        return decoded.data.map { model in
            Model(id: model.id, displayName: model.id)
        }
    }

    // MARK: Chat

    /// Sends a chat completion request and returns the assistant's text.
    func complete(
        model: String,
        system: String,
        user: String,
        temperature: Double = 0.8,
        maxTokens: Int = 700
    ) async throws -> String {
        let url = try apiEndpoint("/chat/completions")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        let payload: [String: Any] = [
            "model": model,
            "temperature": temperature,
            "max_tokens": maxTokens,
            "stream": false,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user],
            ],
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try Self.validate(response, data)
        
        if let text = Self.extractText(from: data)?.trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty
        {
            return text
        }
        throw ClientError.empty
    }

    // MARK: Helpers

    private static func validate(_ response: URLResponse, _ data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw ClientError.server("Server returned \(http.statusCode). \(body)")
        }
    }

    private static func extractText(from data: Data) -> String? {
        if let plain = String(data: data, encoding: .utf8) {
            let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.first != "{", trimmed.first != "[" {
                return trimmed
            }
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return String(data: data, encoding: .utf8)
        }

        return extractText(from: json)
    }

    private static func extractText(from object: Any) -> String? {
        if let string = object as? String {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        if let array = object as? [Any] {
            for item in array {
                if let text = extractText(from: item) {
                    return text
                }
            }
            return nil
        }

        guard let dict = object as? [String: Any] else { return nil }

        // Ollama OpenAI-compatible returns {"choices": [{"message": {"content": "..."}}]}
        if let choices = dict["choices"] as? [Any] {
            for choice in choices {
                if let text = extractChoiceText(choice) {
                    return text
                }
            }
        }

        if let message = dict["message"], let text = extractMessageText(message) {
            return text
        }

        if let text = preferredText(in: dict) {
            return text
        }

        return nil
    }

    private static func extractChoiceText(_ object: Any) -> String? {
        guard let dict = object as? [String: Any] else {
            return extractText(from: object)
        }

        if let message = dict["message"], let text = extractMessageText(message) {
            return text
        }

        if let delta = dict["delta"], let text = extractMessageText(delta) {
            return text
        }

        return nil
    }

    private static func extractMessageText(_ object: Any) -> String? {
        guard let dict = object as? [String: Any] else {
            return extractText(from: object)
        }

        if let text = preferredText(in: dict) {
            return text
        }

        return nil
    }

    private static func preferredText(in dict: [String: Any]) -> String? {
        let prioritizedKeys = [
            "content",
            "text",
            "output_text",
            "reasoning_content",
        ]

        for key in prioritizedKeys {
            if let value = value(for: key, in: dict), let text = extractText(from: value) {
                return text
            }
        }

        for (key, value) in dict {
            let normalized = normalizeKey(key)
            if normalized == "content" || normalized == "text" || normalized == "outputtext"
                || normalized == "reasoningcontent"
            {
                if let text = extractText(from: value) {
                    return text
                }
            }
        }

        return nil
    }

    private static func value(for key: String, in dict: [String: Any]) -> Any? {
        if let value = dict[key] { return value }
        let normalized = normalizeKey(key)
        return dict.first(where: { normalizeKey($0.key) == normalized })?.value
    }

    private static func normalizeKey(_ key: String) -> String {
        key
            .lowercased()
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
}

// MARK: - AI Provider Enum

/// AI Provider enum representing different local LLM servers
public enum AIProvider: String, CaseIterable, Identifiable {
    case lmStudio = "LM Studio"
    case ollama = "Ollama"

    public var id: String { rawValue }

    /// Display name for UI elements
    public var displayName: String {
        switch self {
        case .lmStudio: return "LM Studio"
        case .ollama: return "Ollama"
        }
    }

    /// Default base URL for the provider's API
public var defaultBaseURL: String {
    switch self {
    case .lmStudio: return "http://127.0.0.1:1234"
    case .ollama: return "http://127.0.0.1:11434"
    }
}

    /// Description of the provider for UI display
    public var description: String {
        switch self {
        case .lmStudio:
            return "Local server with OpenAI-compatible API (default port 1234)"
        case .ollama:
            return "Open-source LLM runner with its own API (default port 11434)"
        }
    }
}

// MARK: - Client Protocol

/// Protocol defining common interface for both LM Studio and Ollama clients
protocol ClientProtocol {
    associatedtype ModelType: Identifiable & Hashable
    var baseURL: String { get }
    func listModels() async throws -> [ModelType]
    func complete(model: String, system: String, user: String, temperature: Double, maxTokens: Int) async throws -> String
}

extension LMStudioClient: ClientProtocol {
    typealias ModelType = LMStudioClient.Model
}

extension OllamaClient: ClientProtocol {
    typealias ModelType = OllamaClient.Model
}