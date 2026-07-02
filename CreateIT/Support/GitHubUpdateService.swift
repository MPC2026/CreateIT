import Foundation
import AppKit

@MainActor
final class GitHubUpdateService: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case downloading(Double)
        case installing
        case failed(String)
    }

    struct DownloadProgress {
        let totalBytes: Int64
        let downloadedBytes: Int64
        
        var fractionCompleted: Double {
            guard totalBytes > 0 else { return 0 }
            return Double(downloadedBytes) / Double(totalBytes)
        }
    }

    struct ReleaseAsset: Decodable, Equatable {
        let name: String
        let browserDownloadURL: URL

        enum CodingKeys: String, CodingKey {
            case name
            case browserDownloadURL = "browser_download_url"
        }
    }

    struct Release: Decodable, Identifiable, Equatable {
        let id: Int
        let tagName: String
        let name: String?
        let body: String?
        let htmlURL: URL
        let publishedAt: Date?
        let assets: [ReleaseAsset]

        enum CodingKeys: String, CodingKey {
            case id
            case tagName = "tag_name"
            case name
            case body
            case htmlURL = "html_url"
            case publishedAt = "published_at"
            case assets
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
    @Published private(set) var showInstallConfirmation = false
    @Published private(set) var downloadProgress: DownloadProgress?

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
            isUpdateAvailable = isNewerReleaseAvailable(currentVersion: AppInfo.displayVersion, latestTag: release?.tagName)
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
            isUpdateAvailable = isNewerReleaseAvailable(currentVersion: AppInfo.displayVersion, latestTag: release?.tagName)
            lastChecked = Date()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func checkForUpdatesAndInstall() async {
        do {
            let release = try await fetchLatestRelease()
            latestRelease = release
            isUpdateAvailable = isNewerReleaseAvailable(currentVersion: AppInfo.displayVersion, latestTag: release?.tagName)
            lastChecked = Date()

            guard let release, isUpdateAvailable else { return }
            guard let asset = release.assets.first(where: { $0.name.lowercased().hasSuffix(".dmg") }) else {
                state = .failed("No DMG asset was found on the latest GitHub release.")
                return
            }

            // Download with progress first
            try await downloadWithProgress(asset: asset)
            
            // Transition to idle after download completes, then show install confirmation
            state = .idle
            showInstallConfirmation = true
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

    private func downloadWithProgress(asset: ReleaseAsset) async throws {
        let downloadURL = asset.browserDownloadURL
        
        // Use URLSession.shared.downloadTask - progress updates are limited but we can track completion
        downloadProgress = DownloadProgress(totalBytes: 0, downloadedBytes: 0)
        state = .downloading(0.0)
        
        do {
            let (tempURL, response) = try await URLSession.shared.download(from: downloadURL)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            // Update progress with total bytes (download completed at this point)
            let contentLength = httpResponse.expectedContentLength
            if contentLength > 0 {
                downloadProgress = DownloadProgress(
                    totalBytes: contentLength,
                    downloadedBytes: contentLength
                )
            }
            
            // File operations - update state to indicate progress
            state = .installing  // Transition to installing state for file operations
            
            let fileManager = FileManager.default
            let downloadsDirectory = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first
                ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Downloads", isDirectory: true)

            // Stage the DMG in Downloads like normal browser/system downloads.
            try fileManager.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true)

            var fileName = URL(fileURLWithPath: asset.name).lastPathComponent
            if fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fileName = "CreateIT-latest.dmg"
            }
            if !fileName.lowercased().hasSuffix(".dmg") {
                fileName += ".dmg"
            }

            let targetURL = downloadsDirectory.appendingPathComponent(fileName)

            if fileManager.fileExists(atPath: targetURL.path) {
                try fileManager.removeItem(at: targetURL)
            }

            do {
                try fileManager.moveItem(at: tempURL, to: targetURL)
            } catch {
                // Fall back to copy if move fails across volumes/filesystems.
                try fileManager.copyItem(at: tempURL, to: targetURL)
                if fileManager.fileExists(atPath: tempURL.path) {
                    try? fileManager.removeItem(at: tempURL)
                }
            }
            
            // Store the downloaded DMG path for installation
            self.downloadedDMGPath = targetURL.path
            state = .idle  // Back to idle after all operations complete
            
        } catch {
            state = .failed(error.localizedDescription)
            throw error
        }
    }

    func installUpdate() async {
        guard let dmgPath = downloadedDMGPath else {
            state = .failed("No downloaded DMG found")
            return
        }
        
        state = .installing
        
        do {
            // Get the target app path
            let fileManager = FileManager.default
            let bundle = Bundle.main
            guard let appURL = bundle.bundleURL as URL? else {
                state = .failed("Could not determine app location")
                return
            }
            
            // Get the parent directory of the app bundle (contains the app)
            let targetDirectory = appURL.deletingLastPathComponent()
            
            // Create the installation script
            let installScript = updateScript(dmgPath: dmgPath, targetAppPath: appURL.path, targetDirectoryPath: targetDirectory.path)
            
            // Write script to temporary file
            let scriptURL = FileManager.default.temporaryDirectory.appendingPathComponent("install_update.sh")
            try installScript.write(to: scriptURL, atomically: true, encoding: String.Encoding.utf8)
            
            // Make script executable using FileAttributeKey
            var attributes = try fileManager.attributesOfItem(atPath: scriptURL.path)
            attributes[.posixPermissions] = 0o755
            try fileManager.setAttributes(attributes, ofItemAtPath: scriptURL.path)
            
            // Run the installation script in background
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = [scriptURL.path]
            try process.run()
            
            // Wait a moment then quit the app to allow installation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NSApplication.shared.terminate(nil)
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func updateScript(dmgPath: String, targetAppPath: String, targetDirectoryPath: String) -> String {
        func shellQuote(_ value: String) -> String {
            "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
        }

        let dmg = shellQuote(dmgPath)
        let targetApp = shellQuote(targetAppPath)
        let targetDirectory = shellQuote(targetDirectoryPath)
        let mountPoint = shellQuote(FileManager.default.temporaryDirectory.appendingPathComponent("CreateITMount").path)

        return """
        #!/bin/zsh
        set -euo pipefail

        DMG_PATH=\(dmg)
        TARGET_APP=\(targetApp)
        TARGET_DIR=\(targetDirectory)
        MOUNT_POINT=\(mountPoint)

        rm -rf "$MOUNT_POINT"
        mkdir -p "$MOUNT_POINT"

        while pgrep -x CreateIT >/dev/null 2>&1; do
            sleep 1
        done

        hdiutil attach "$DMG_PATH" -nobrowse -quiet -mountpoint "$MOUNT_POINT"

        APP_SOURCE=$(find "$MOUNT_POINT" -maxdepth 1 -name "*.app" -print -quit)
        if [ -z "$APP_SOURCE" ]; then
            hdiutil detach "$MOUNT_POINT" -quiet || true
            exit 1
        fi

        UPDATED_APP="$TARGET_DIR/$(basename "$APP_SOURCE")"
        TMP_APP="$TARGET_DIR/.CreateIT.tmp"
        rm -rf "$TMP_APP"
        rm -rf "$UPDATED_APP"
        ditto "$APP_SOURCE" "$TMP_APP"
        mv "$TMP_APP" "$UPDATED_APP"
        hdiutil detach "$MOUNT_POINT" -quiet || true
        open "$UPDATED_APP"
        rm -rf "$DMG_PATH" "$MOUNT_POINT" "$0"
        """
    }

    private func isNewerReleaseAvailable(currentVersion: String, latestTag: String?) -> Bool {
        guard let latestTag else { return false }
        
        // Parse versions - extract only major.minor for comparison (ignore build numbers)
        let tagVersion = latestTag.hasPrefix("v") ? String(latestTag.dropFirst()) : latestTag
        let currentAppMajorMinor = extractMajorMinor(from: currentVersion)
        let latestTagMajorMinor = extractMajorMinor(from: tagVersion)
        
        // Compare major.minor versions first (element by element)
        if currentAppMajorMinor != latestTagMajorMinor {
            return isGreaterVersion(latestTagMajorMinor, than: currentAppMajorMinor)
        }
        
        // Versions are the same, compare build numbers
        // Extract build number from app version (e.g., "v2.5-build35" -> 35)
        let currentBuild = extractBuildNumber(from: currentVersion)
        // Extract build number from tag (e.g., "v2.5-build31" -> 31, or just "v2.5" -> 0)
        let tagBuild = extractBuildNumber(from: latestTag)
        
        return tagBuild > currentBuild
    }
    
    private func isGreaterVersion(_ lhs: [Int], than rhs: [Int]) -> Bool {
        // Compare element by element
        let count = max(lhs.count, rhs.count)
        for index in 0..<count {
            let left = index < lhs.count ? lhs[index] : 0
            let right = index < rhs.count ? rhs[index] : 0
            if left != right { return left > right }
        }
        return false
    }
    
    private func extractMajorMinor(from versionString: String) -> [Int] {
        // Extract only major.minor components (first two numbers)
        let digits = versionString.split { !$0.isNumber }.compactMap { Int($0) }
        return digits.count >= 2 ? Array(digits.prefix(2)) : digits
    }
    
    private func extractBuildNumber(from versionString: String) -> Int {
        // Look for pattern like "-buildNNN" or "bNNN" in the version string
        let components = versionString.split(separator: "-")
        for component in components {
            if component.starts(with: "build"), let buildNum = Int(String(component.dropFirst(5))) {
                return buildNum
            }
        }
        
        // Also check for 'b' followed by numbers (e.g., v2.6b3)
        if versionString.contains("b") {
            let parts = versionString.split(separator: "b")
            if parts.count > 1, let buildNum = Int(String(parts.last!)) {
                return buildNum
            }
        }
        
        return 0
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

    // MARK: - Private properties for download handling
    private var downloadedDMGPath: String?
}

// MARK: - GitHubDateParser
private final class GitHubDateParser {
    static let shared = GitHubDateParser()

    let fractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    let plainFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    func date(from string: String) -> Date? {
        fractionalFormatter.date(from: string) ?? plainFormatter.date(from: string)
    }
}
