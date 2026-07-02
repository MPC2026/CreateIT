import SwiftUI
import AppKit

@main
struct CreateITApp: App {
    @StateObject private var wizard = WizardState()
    @StateObject private var ai = AIAssistant()
    @StateObject private var updates = GitHubUpdateService()
    @StateObject private var templateLibrary = TemplateLibraryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(wizard)
                .environmentObject(ai)
                .environmentObject(updates)
                .environmentObject(templateLibrary)
        }
        .defaultSize(width: 860, height: 620)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Script") { templateLibrary.startNewDraft(with: wizard) }
                    .keyboardShortcut("n", modifiers: [.command])
            }
        }
    }
}
