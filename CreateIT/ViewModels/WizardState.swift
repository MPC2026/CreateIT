import Foundation
import SwiftUI

enum WizardStep: Int, CaseIterable {
    case structure
    case format
    case genre
    case sample
    case plot
    case template

    var title: String {
        switch self {
        case .structure: return "Structure"
        case .format:    return "Format"
        case .genre:     return "Genre"
        case .sample:    return "Sample"
        case .plot:      return "Plot"
        case .template:  return "Template"
        }
    }
}

@MainActor
final class WizardState: ObservableObject {
    @Published var step: WizardStep = .structure

    // Selections
    @Published var structure: ScriptStructure?
    @Published var medium: Medium?
    @Published var runtime: Runtime?
    @Published var genre: Genre?
    @Published var sampleMovie: SampleMovie?

    // Project details
    @Published var projectTitle: String = ""
    @Published var logline: String = ""
    @Published var plot: String = ""

    /// Writer's fill-in text, keyed by beat key.
    @Published var entries: [String: String] = [:]

    // MARK: Derived

    var beats: [BeatTemplate] {
        guard let structure, let medium else { return [] }
        return BeatLibrary.beats(for: structure, medium: medium)
    }

    var sampleMovies: [SampleMovie] {
        guard let genre else { return [] }
        return SampleLibrary.movies(for: genre)
    }

    /// Whether the user can advance from the current step.
    var canAdvance: Bool {
        switch step {
        case .structure: return structure != nil
        case .format:    return medium != nil && runtime != nil
        case .genre:     return genre != nil
        case .sample:    return sampleMovie != nil
        case .plot:      return !projectTitle.trimmingCharacters(in: .whitespaces).isEmpty
        case .template:  return false
        }
    }

    // MARK: Navigation

    func next() {
        guard canAdvance else { return }
        if let nextStep = WizardStep(rawValue: step.rawValue + 1) {
            withAnimation(.easeInOut(duration: 0.25)) { step = nextStep }
        }
    }

    func back() {
        if let prevStep = WizardStep(rawValue: step.rawValue - 1) {
            withAnimation(.easeInOut(duration: 0.25)) { step = prevStep }
        }
    }

    func go(to target: WizardStep) {
        guard target.rawValue <= step.rawValue else { return }
        withAnimation(.easeInOut(duration: 0.25)) { step = target }
    }

    func reset() {
        withAnimation(.easeInOut(duration: 0.25)) {
            step = .structure
            structure = nil
            medium = nil
            runtime = nil
            genre = nil
            sampleMovie = nil
            projectTitle = ""
            logline = ""
            plot = ""
            entries = [:]
        }
    }

    // When genre changes, clear an out-of-genre sample selection.
    func selectGenre(_ newGenre: Genre) {
        if genre != newGenre {
            genre = newGenre
            sampleMovie = nil
        }
    }

    // When medium changes, keep the runtime valid for that medium.
    // Movies always use the standard feature length.
    func selectMedium(_ newMedium: Medium) {
        medium = newMedium
        let options = Runtime.options(for: newMedium)
        if newMedium == .movie {
            runtime = .feature
        } else if let current = runtime, !options.contains(current) {
            runtime = nil
        }
    }

    // MARK: Export

    /// Builds a plain-text outline of the whole project.
    func exportText() -> String {
        var lines: [String] = []
        let title = projectTitle.isEmpty ? "Untitled" : projectTitle
        lines.append("CREATEIT OUTLINE")
        lines.append("================")
        lines.append("")
        lines.append("TITLE: \(title)")
        if let structure { lines.append("STRUCTURE: \(structure.title)") }
        if let medium, let runtime { lines.append("FORMAT: \(medium.rawValue) · \(runtime.label)") }
        if let genre { lines.append("GENRE: \(genre.title)") }
        if let sampleMovie { lines.append("SAMPLE STYLE: \(sampleMovie.title) (\(sampleMovie.year))") }
        if !logline.isEmpty {
            lines.append("")
            lines.append("LOGLINE: \(logline)")
        }
        if !plot.isEmpty {
            lines.append("")
            lines.append("PLOT:")
            lines.append(plot)
        }
        lines.append("")
        lines.append("----------------------------------------")
        lines.append("")

        var currentAct = -99
        for beat in beats {
            if beat.act != currentAct {
                currentAct = beat.act
                lines.append(beat.actLabel.uppercased())
                lines.append(String(repeating: "-", count: beat.actLabel.count))
            }
            let runtimeLabel = runtime.map { beat.timing(for: $0) } ?? ""
            lines.append("")
            lines.append("• \(beat.title)  [\(runtimeLabel)]")
            let written = entries[beat.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if written.isEmpty {
                lines.append("  (\(beat.placeholder))")
            } else {
                lines.append("  \(written)")
            }
        }
        lines.append("")
        return lines.joined(separator: "\n")
    }
}
