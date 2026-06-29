import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// BackupManager handles the serialization and persistence of project data to disk.
/// It allows users to export their work as a .createit-backup file and restore it later.
final class BackupManager {
    static let shared = BackupManager()
    private let defaultFileName = "project_backup.createit-backup"

    private init() {}

    /// Returns the URL for the backup file in the application support directory.
    private var backupURL: URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent(defaultFileName)
    }

    // MARK: - Default Backup/Restore (Automatic)

    /// Saves the provided data to a file.
    func save(data: Data) throws {
        guard let url = backupURL else {
            throw BackupError.storageUnavailable
        }

        // Ensure directory exists
        let directory = url.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(
                at: directory, withIntermediateDirectories: true)
        }

        try data.write(to: url, options: .atomic)
    }

    /// Loads the state data from the backup file.
    func load() throws -> Data {
        guard let url = backupURL else {
            throw BackupError.storageUnavailable
        }

        return try Data(contentsOf: url)
    }

    /// Checks if a backup file currently exists on disk.
    var hasBackup: Bool {
        guard let url = backupURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    /// Deletes the existing backup file.
    func clearBackup() throws {
        guard let url = backupURL else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - User-Selected Backup/Restore (with File Dialog)

    /// Opens a save panel to let the user choose where to save the backup file.
    func saveAs(data: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "project.createit-backup"

        if let backupType = UTType(filenameExtension: "createit-backup") {
            panel.allowedContentTypes = [backupType]
        }

        let result = panel.runModal()
        switch result {
        case .OK:
            guard let url = panel.url else {
                completion(.failure(BackupError.userCancelled))
                return
            }
            do {
                try data.write(to: url, options: .atomic)
                completion(.success(url))
            } catch {
                completion(.failure(error))
            }
        default:
            completion(.failure(BackupError.userCancelled))
        }
    }

    /// Saves the provided state data to a specific URL.
    func save(data: Data, to url: URL) throws {
        // Ensure directory exists
        let directory = url.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(
                at: directory, withIntermediateDirectories: true)
        }

        try data.write(to: url, options: .atomic)
    }

    /// Opens a open panel to let the user choose a backup file to restore from.
    func load(
        from url: URL? = nil, completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        if let backupType = UTType(filenameExtension: "createit-backup") {
            panel.allowedContentTypes = [backupType]
        }

        // If a URL was provided, start from that location
        if let url = url {
            if url.hasDirectoryPath {
                panel.directoryURL = url
            } else {
                panel.directoryURL = url.deletingLastPathComponent()
            }
        }

        let result = panel.runModal()
        switch result {
        case .OK:
            guard let selectedURL = panel.url else {
                completion(.failure(BackupError.userCancelled))
                return
            }
            do {
                let data = try Data(contentsOf: selectedURL)
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        default:
            completion(.failure(BackupError.userCancelled))
        }
    }

    /// Restores state data from a specific backup file URL.
    func restore(from url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }

    // MARK: - DMG Creation

    /// Creates a DMG containing the backup file.
    func createDMG(from backupURL: URL, to dmgURL: URL) async throws {
        let temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString)
        try FileManager.default.createDirectory(
            at: temporaryDirectory, withIntermediateDirectories: true)

        // Copy the backup file to the temporary directory
        let copiedBackupURL = temporaryDirectory.appendingPathComponent("project.createit-backup")
        try FileManager.default.copyItem(at: backupURL, to: copiedBackupURL)

        let projectName = "CreateIT"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        process.arguments = [
            "create", temporaryDirectory.path, "-srcdir", temporaryDirectory.path, "-format",
            "UDZO", "-volname", projectName, dmgURL.path,
        ]

        try process.run()
        process.waitUntilExit()

        // Clean up temporary directory
        try FileManager.default.removeItem(at: temporaryDirectory)

        if process.terminationStatus != 0 {
            throw BackupError.dmgCreationFailed(
                "hdiutil exited with status \(process.terminationStatus)")
        }
    }

    enum BackupError: LocalizedError {
        case storageUnavailable
        case loadFailed
        case saveFailed
        case userCancelled
        case dmgCreationFailed(String)

        var errorDescription: String? {
            switch self {
            case .storageUnavailable:
                return "Could not access system storage."
            case .loadFailed:
                return "Failed to load the backup file."
            case .saveFailed:
                return "Failed to save the backup file."
            case .userCancelled:
                return "Operation cancelled by user."
            case .dmgCreationFailed(let message):
                return "DMG creation failed: \(message)"
            }
        }
    }
}
