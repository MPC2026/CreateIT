import Foundation

enum ReleaseNotes {
    static let repositoryURL = URL(string: "https://github.com/MPC2026/CreateIT")!
    static let repositoryOwner = "MPC2026"
    static let repositoryName = "CreateIT"

    static let highlights: [String] = [
        "Beats now hand off to a dedicated Outline step with editable scene cards.",
        "You can seed the outline from beats, draft it with AI, or add and remove scenes manually.",
        "Beat targeting now follows the card you are actively editing.",
        "The AI prompt auto-fills with the selected beat's purpose, timing, and current draft.",
        "AI suggestions now appear inline with a merge preview before you apply them.",
        "Sentence-by-sentence merging keeps your draft structure intact while rewriting only the changed parts."
    ]
}
