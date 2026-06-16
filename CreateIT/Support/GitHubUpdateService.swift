import Foundation

@MainActor
final class GitHubUpdateService: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    struct Release: Decodable, Identifiable, Equatable {
        let id: Int
        let tagName: String
        let name: String?
        let body: String?
        let htmlURL: URL
        let publishedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id
            case tagName = "tag_name"
            case name
            case body
            case htmlURL = "html_url"
            case publishedAt = "published_at"
        }
    }

    struct Commit: Decodable, Identifiable, Equatable {
        let sha: String
        let message: String
        let authorName: String?
        let date: Date?
        let htmlURL: URL

        var id: String { sha }
        var shortSHA: String { String(sha.prefix(7)) }

        enum CodingKeys: String, CodingKey {
            case sha
            case commit
            case htmlURL = "html_url"
        }

        enum CommitKeys: String, CodingKey {
            case message
            case author
        }

        enum AuthorKeys: String, CodingKey {
            case name
            case date
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            sha = try container.decode(String.self, forKey: .sha)
            htmlURL = try container.decode(URL.self, forKey: .htmlURL)

            let commit = try container.nestedContainer(keyedBy: CommitKeys.self, forKey: .commit)
            message = try commit.decode(String.self, forKey: .message)

            if commit.contains(.author) {
                let author = try commit.nestedContainer(keyedBy: AuthorKeys.self, forKey: .author)
                authorName = try author.decodeIfPresent(String.self, forKey: .name)
                date = try author.decodeIfPresent(Date.self, forKey: .date)
            } else {
                authorName = nil
                date = nil
            }
        }
    }

    @Published private(set) var state: LoadState = .idle
    @Published private(set) var latestRelease: Release?
    @Published private(set) var commits: [Commit] = []
    @Published private(set) var releases: [Release] = []
    @Published private(set) var lastChecked: Date?
    @Published private(set) var isUpdateAvailable = false

    func refresh() async {
        state = .loading

        do {
            async let releaseTask = fetchLatestRelease()
            async let commitsTask = fetchRecentCommits()
            async let releasesTask = fetchReleases()

            let release = try await releaseTask
            let commitList = try await commitsTask
            let releaseList = try await releasesTask

            latestRelease = release
            commits = commitList
            releases = releaseList
            isUpdateAvailable = isNewerReleaseAvailable(currentVersion: AppInfo.shortVersion, latestTag: release?.tagName)
            lastChecked = Date()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func checkForUpdates() async {
        do {
            let release = try await fetchLatestRelease()
            latestRelease = release
            isUpdateAvailable = isNewerReleaseAvailable(currentVersion: AppInfo.shortVersion, latestTag: release?.tagName)
            lastChecked = Date()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func refreshReleasesOnly() async {
        do {
            releases = try await fetchReleases()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func fetchLatestRelease() async throws -> Release? {
        let url = URL(string: "https://api.github.com/repos/\(ReleaseNotes.repositoryOwner)/\(ReleaseNotes.repositoryName)/releases/latest")!
        let (data, response) = try await request(url: url)

        guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        if httpResponse.statusCode == 404 { return nil }
        guard (200..<300).contains(httpResponse.statusCode) else { throw URLError(.badServerResponse) }

        return try decoder.decode(Release.self, from: data)
    }

    private func fetchRecentCommits() async throws -> [Commit] {
        let url = URL(string: "https://api.github.com/repos/\(ReleaseNotes.repositoryOwner)/\(ReleaseNotes.repositoryName)/commits?per_page=8")!
        let (data, response) = try await request(url: url)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode([Commit].self, from: data)
    }

    private func fetchReleases() async throws -> [Release] {
        let url = URL(string: "https://api.github.com/repos/\(ReleaseNotes.repositoryOwner)/\(ReleaseNotes.repositoryName)/releases?per_page=12")!
        let (data, response) = try await request(url: url)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode([Release].self, from: data)
    }

    private func request(url: URL) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("CreateIT/1.0", forHTTPHeaderField: "User-Agent")
        return try await URLSession.shared.data(for: request)
    }

    private func isNewerReleaseAvailable(currentVersion: String, latestTag: String?) -> Bool {
        guard let latestTag else { return false }
        return Version(latestTag) > Version(currentVersion)
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = GitHubDateParser.shared.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date string")
        }
        return decoder
    }
}

private struct Version: Comparable {
    let components: [Int]

    init(_ rawValue: String) {
        let digits = rawValue.split { !$0.isNumber }.compactMap { Int($0) }
        components = digits.isEmpty ? [0] : digits
    }

    static func < (lhs: Version, rhs: Version) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)
        for index in 0..<count {
            let left = index < lhs.components.count ? lhs.components[index] : 0
            let right = index < rhs.components.count ? rhs.components[index] : 0
            if left != right { return left < right }
        }
        return false
    }
}

private final class GitHubDateParser {
    static let shared = GitHubDateParser()

    private let fractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private let plainFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    func date(from string: String) -> Date? {
        fractionalFormatter.date(from: string) ?? plainFormatter.date(from: string)
    }
}
