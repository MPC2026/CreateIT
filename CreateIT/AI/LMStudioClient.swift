import Foundation

/// Minimal client for an OpenAI-compatible local server such as LM Studio
/// (default endpoint `http://localhost:1234/v1`) or Ollama's compat API.
struct LMStudioClient {

    struct Model: Identifiable, Hashable {
        let id: String
    }

    enum ClientError: LocalizedError {
        case badURL
        case server(String)
        case empty

        var errorDescription: String? {
            switch self {
            case .badURL:           return "The server URL is invalid."
            case .server(let msg):  return msg
            case .empty:            return "The model returned an empty response."
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

    // MARK: Models

    /// Lists models exposed by the server (`GET /models`).
    func listModels() async throws -> [Model] {
        let url = try endpoint("/models")
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        let (data, response) = try await URLSession.shared.data(for: request)
        try Self.validate(response, data)

        struct ModelsResponse: Decodable {
            struct Entry: Decodable { let id: String }
            let data: [Entry]
        }
        let decoded = try JSONDecoder().decode(ModelsResponse.self, from: data)
        return decoded.data.map { Model(id: $0.id) }
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
        let url = try endpoint("/chat/completions")
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
                ["role": "user", "content": user]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try Self.validate(response, data)

        struct ChatResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { let content: String }
                let message: Message
            }
            let choices: [Choice]
        }
        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let text = decoded.choices.first?.message.content,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ClientError.empty
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: Helpers

    private static func validate(_ response: URLResponse, _ data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw ClientError.server("Server returned \(http.statusCode). \(body)")
        }
    }
}
