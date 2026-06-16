import SwiftUI

@main
struct CreateITApp: App {
    @StateObject private var wizard = WizardState()
    @StateObject private var ai = AIAssistant()
    @StateObject private var updates = GitHubUpdateService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(wizard)
                .environmentObject(ai)
                .environmentObject(updates)
                .frame(minWidth: 960, minHeight: 680)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Script") { wizard.reset() }
                    .keyboardShortcut("n", modifiers: [.command])
            }
        }
    }
}
