import Foundation

enum ReleasePreviewFormatter {
    static func markdown(title: String, published: String, body: String, url: String) -> String {
        let template = loadTemplate()
        return template
            .replacingOccurrences(of: "{{title}}", with: title)
            .replacingOccurrences(of: "{{published}}", with: published)
            .replacingOccurrences(of: "{{body}}", with: body.isEmpty ? "GitHub release notes are available on the Releases page." : body)
            .replacingOccurrences(of: "{{url}}", with: url)
    }

    static func markdown(for release: GitHubUpdateService.Release) -> String {
        markdown(
            title: release.name ?? release.tagName,
            published: release.publishedAt?.formatted(date: .long, time: .omitted) ?? "recently",
            body: release.body?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            url: release.htmlURL.absoluteString
        )
    }

    private static func loadTemplate() -> String {
        guard let url = Bundle.main.url(forResource: "ReleasePreviewTemplate", withExtension: "md"),
              let template = try? String(contentsOf: url, encoding: .utf8) else {
            return """
            **{{title}}** was published on {{published}}.

            {{body}}

            See the full release on [GitHub Releases]({{url}}).
            """
        }
        return template
    }
}
