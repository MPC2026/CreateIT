import Foundation

enum ChangelogStore {
    static func loadMarkdown() -> String? {
        guard let url = Bundle.main.url(forResource: "CHANGELOG", withExtension: "md") else {
            return nil
        }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    static func loadAttributed() -> AttributedString? {
        guard let markdown = loadMarkdown() else { return nil }
        return try? AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        )
    }
}
