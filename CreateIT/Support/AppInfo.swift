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

    /// e.g. "v1.0 (5)"
    static var displayVersion: String {
        "v\(shortVersion) (\(buildNumber))"
    }
}
