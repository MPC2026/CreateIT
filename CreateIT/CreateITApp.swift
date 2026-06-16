import SwiftUI

@main
struct CreateITApp: App {
    @StateObject private var wizard = WizardState()
    @StateObject private var ai = AIAssistant()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(wizard)
                .environmentObject(ai)
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
