import Foundation

/// Reads version metadata from the app bundle so the UI and exports can
/// display exactly which build is running.
enum AppInfo {
    static var shortVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// e.g. "v2.6b1" (matches GitHub release tag format)
    static var displayVersion: String {
        "v\(shortVersion)b\(buildNumber)"
    }
}
