import Foundation

// MARK: - Beat Template

/// A single structural beat in an outline. `key` is used to look up
/// matching sample text from a `SampleMovie`.
struct BeatTemplate: Identifiable {
    let key: String
    let act: Int
    let actLabel: String
    let title: String
    /// What this beat is for — the guidance shown to the writer.
    let purpose: String
    /// A short prompt that seeds the fill-in-the-blank editor.
    let placeholder: String
    /// Position in the story as a percentage of total runtime.
    let startPct: Double
    let endPct: Double

    var id: String { key }

    /// Human-readable timing for a given runtime, e.g. "min 0–3 · pg 1–3".
    func timing(for runtime: Runtime) -> String {
        let total = Double(runtime.rawValue)
        let startMin = Int((startPct / 100.0 * total).rounded())
        let endMin = Int((endPct / 100.0 * total).rounded())
        // ~1 script page per minute is the standard rule of thumb.
        let pages: String
        if startMin == endMin {
            pages = "pg \(max(1, startMin))"
        } else {
            pages = "pg \(max(1, startMin))–\(max(1, endMin))"
        }
        let minutes = startMin == endMin ? "min \(startMin)" : "min \(startMin)–\(endMin)"
        return "\(minutes) · \(pages)"
    }
}

// MARK: - Beat Library

enum BeatLibrary {

    /// Returns the ordered beats for a given structure and medium.
    static func beats(for structure: ScriptStructure, medium: Medium) -> [BeatTemplate] {
        switch structure {
        case .threeAct: return threeAct
        case .fiveAct:  return fiveAct(medium: medium)
        }
    }

    // MARK: 3-Act (15-beat) structure

    static let threeAct: [BeatTemplate] = [
        BeatTemplate(
            key: "openingImage", act: 1, actLabel: "Act I · Setup",
            title: "Opening Image",
            purpose: "A single snapshot that captures the tone and the hero's 'before' state. Set the mood and hint at the world we're about to upend.",
            placeholder: "Open on…",
            startPct: 0, endPct: 1),
        BeatTemplate(
            key: "themeStated", act: 1, actLabel: "Act I · Setup",
            title: "Theme Stated",
            purpose: "Someone (often not the hero) states what the story is really about. The lead won't understand it yet — that's the point.",
            placeholder: "A character hints at the lesson the hero must learn:",
            startPct: 5, endPct: 6),
        BeatTemplate(
            key: "setup", act: 1, actLabel: "Act I · Setup",
            title: "Setup",
            purpose: "Establish the hero's ordinary world, their flaw, and what's missing. Plant the things that will pay off later.",
            placeholder: "Show the hero's everyday life and what's broken in it:",
            startPct: 1, endPct: 10),
        BeatTemplate(
            key: "catalyst", act: 1, actLabel: "Act I · Setup",
            title: "Catalyst / Inciting Incident",
            purpose: "The knock on the door. A life-changing event that makes the old world impossible to stay in.",
            placeholder: "The event that disrupts everything:",
            startPct: 10, endPct: 12),
        BeatTemplate(
            key: "debate", act: 1, actLabel: "Act I · Setup",
            title: "Debate",
            purpose: "The hero hesitates. Should they go? This is the last gasp of the old world and raises the central question.",
            placeholder: "The hero resists the call because…",
            startPct: 12, endPct: 20),
        BeatTemplate(
            key: "breakIntoTwo", act: 2, actLabel: "Act II · Confrontation",
            title: "Break Into Two",
            purpose: "The hero makes a choice and steps into the new world. The adventure truly begins on their own terms.",
            placeholder: "The hero commits and crosses into the new world:",
            startPct: 20, endPct: 22),
        BeatTemplate(
            key: "bStory", act: 2, actLabel: "Act II · Confrontation",
            title: "B Story",
            purpose: "Introduce the relationship/subplot that carries the theme — often a mentor, love interest, or ally.",
            placeholder: "Introduce the relationship that teaches the lesson:",
            startPct: 22, endPct: 25),
        BeatTemplate(
            key: "funAndGames", act: 2, actLabel: "Act II · Confrontation",
            title: "Fun and Games",
            purpose: "The 'promise of the premise.' Deliver the set-pieces the audience came for as the hero explores the new world.",
            placeholder: "The promise of the premise plays out:",
            startPct: 22, endPct: 50),
        BeatTemplate(
            key: "midpoint", act: 2, actLabel: "Act II · Confrontation",
            title: "Midpoint",
            purpose: "A false victory or false defeat that raises the stakes. The hero's goal shifts from want to need.",
            placeholder: "The stakes spike — a big win or a big loss:",
            startPct: 50, endPct: 52),
        BeatTemplate(
            key: "badGuysCloseIn", act: 2, actLabel: "Act II · Confrontation",
            title: "Bad Guys Close In",
            purpose: "External pressure mounts and internal cracks show. The team frays; the antagonist gains ground.",
            placeholder: "Forces tighten around the hero:",
            startPct: 52, endPct: 75),
        BeatTemplate(
            key: "allIsLost", act: 2, actLabel: "Act II · Confrontation",
            title: "All Is Lost",
            purpose: "The lowest point. Often a 'whiff of death.' Whatever the hero gained at the midpoint is stripped away.",
            placeholder: "The hero hits rock bottom:",
            startPct: 75, endPct: 77),
        BeatTemplate(
            key: "darkNight", act: 2, actLabel: "Act II · Confrontation",
            title: "Dark Night of the Soul",
            purpose: "The hero sits in the loss. Out of this despair comes the realization that unlocks the climax.",
            placeholder: "In the despair, the hero finally realizes…",
            startPct: 77, endPct: 80),
        BeatTemplate(
            key: "breakIntoThree", act: 3, actLabel: "Act III · Resolution",
            title: "Break Into Three",
            purpose: "Thanks to the B story and a new understanding, the hero finds the solution and chooses to act.",
            placeholder: "Armed with a new truth, the hero acts:",
            startPct: 80, endPct: 82),
        BeatTemplate(
            key: "finale", act: 3, actLabel: "Act III · Resolution",
            title: "Finale",
            purpose: "The hero proves the lesson is learned by dismantling the problem and defeating the antagonist for good.",
            placeholder: "The hero executes the plan and wins (or loses) for real:",
            startPct: 82, endPct: 99),
        BeatTemplate(
            key: "finalImage", act: 3, actLabel: "Act III · Resolution",
            title: "Final Image",
            purpose: "A mirror of the opening image that shows how much has changed. Close the emotional loop.",
            placeholder: "Close on… (echo and invert the opening)",
            startPct: 99, endPct: 100)
    ]

    // MARK: 5-Act structure

    static func fiveAct(medium: Medium) -> [BeatTemplate] {
        var beats: [BeatTemplate] = []

        if medium == .tv {
            beats.append(BeatTemplate(
                key: "teaser", act: 0, actLabel: "Teaser / Cold Open",
                title: "Teaser",
                purpose: "A short hook before the titles. Pose the episode's question or drop us into a moment that demands we keep watching.",
                placeholder: "Hook the audience in the first minute:",
                startPct: 0, endPct: 8))
        }

        beats.append(contentsOf: [
            BeatTemplate(
                key: "exposition", act: 1, actLabel: "Act I · Exposition",
                title: "Exposition (Setup)",
                purpose: "Establish characters, world, and the status quo. Introduce the dramatic question and the first sign of trouble.",
                placeholder: "Establish the world and the inciting problem:",
                startPct: medium == .tv ? 8 : 0, endPct: 22),
            BeatTemplate(
                key: "risingAction", act: 2, actLabel: "Act II · Rising Action",
                title: "Rising Action (Complication)",
                purpose: "Complications stack up as the protagonist pursues the goal. Raise obstacles and deepen relationships.",
                placeholder: "Pile on complications and raise the stakes:",
                startPct: 22, endPct: 45),
            BeatTemplate(
                key: "climaxTurn", act: 3, actLabel: "Act III · Climax",
                title: "Climax (Turning Point)",
                purpose: "The peak of tension and the story's pivot. A decision or revelation changes the direction of everything.",
                placeholder: "The turning point that changes the trajectory:",
                startPct: 45, endPct: 62),
            BeatTemplate(
                key: "fallingAction", act: 4, actLabel: "Act IV · Falling Action",
                title: "Falling Action (Consequences)",
                purpose: "The fallout of the climax. Tension stays high as consequences play out and the ending becomes inevitable.",
                placeholder: "Show the consequences spiraling toward the end:",
                startPct: 62, endPct: 85),
            BeatTemplate(
                key: "resolution", act: 5, actLabel: "Act V · Resolution",
                title: "Resolution (Denouement)",
                purpose: "Resolve the dramatic question, settle the new normal, and land the emotional truth.",
                placeholder: "Resolve the question and reveal the new normal:",
                startPct: 85, endPct: 100)
        ])

        if medium == .tv {
            beats.append(BeatTemplate(
                key: "tag", act: 6, actLabel: "Tag / Button",
                title: "Tag",
                purpose: "A short final beat after the climax — a button that leaves a taste of what's next or a last emotional note.",
                placeholder: "Leave the audience with a final beat or hook:",
                startPct: 98, endPct: 100))
        }

        return beats
    }
}
