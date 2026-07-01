import Foundation

// MARK: - Story Structure

enum ScriptStructure: String, CaseIterable, Identifiable, Codable {
    case threeAct = "3-Act"
    case fiveAct = "5-Act"

    var id: String { rawValue }

    var title: String { "\(rawValue) Structure" }

    var subtitle: String {
        switch self {
        case .threeAct: return "Setup · Confrontation · Resolution"
        case .fiveAct:  return "Exposition · Rising · Climax · Falling · Resolution"
        }
    }

    var blurb: String {
        switch self {
        case .threeAct:
            return "The classic feature-film shape built on 15 story beats. Great for movies and tightly plotted episodes."
        case .fiveAct:
            return "The dramatic arc used across most television. Maps cleanly onto act breaks and commercial timing."
        }
    }

    var symbol: String {
        switch self {
        case .threeAct: return "rectangle.split.3x1"
        case .fiveAct:  return "rectangle.split.3x3"
        }
    }
}

// MARK: - Medium

enum Medium: String, CaseIterable, Identifiable, Codable {
    case movie = "Movie"
    case tv = "TV Show"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .movie: return "film"
        case .tv:    return "tv"
        }
    }

    var blurb: String {
        switch self {
        case .movie: return "A self-contained feature with a single dramatic arc."
        case .tv:    return "An episode with a teaser and act breaks built for serialized storytelling."
        }
    }
}

// MARK: - Runtime

enum Runtime: Int, CaseIterable, Identifiable, Codable {
    case thirty = 30
    case sixty = 60
    case feature = 120

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .feature: return "Feature"
        default:       return "\(rawValue) min"
        }
    }

    var subtitle: String {
        switch self {
        case .thirty:  return "Half-hour format · ~30 script pages"
        case .sixty:   return "Hour-long format · ~60 script pages"
        case .feature: return "Standard feature · ~120 script pages"
        }
    }

    var symbol: String {
        switch self {
        case .feature: return "film"
        default:       return "clock"
        }
    }

    /// The runtime options that make sense for a given medium.
    static func options(for medium: Medium) -> [Runtime] {
        switch medium {
        case .movie: return [.feature]
        case .tv:    return [.thirty, .sixty]
        }
    }
}

// MARK: - Genre Selection Mode

enum GenreSelectionMode: String, CaseIterable, Identifiable, Codable {
    case primaryOnly = "Primary Only"
    case primarySecondary = "Primary & Secondary"

    var id: String { rawValue }

    var title: String { rawValue }

    var symbol: String {
        switch self {
        case .primaryOnly: return "123"
        case .primarySecondary: return "AB"
        }
    }

    var blurb: String {
        switch self {
        case .primaryOnly:
            return "Select one primary genre. Simple and focused."
        case .primarySecondary:
            return "Select two genres - primary and secondary for more nuanced samples."
        }
    }
}

// MARK: - Genre

enum Genre: String, CaseIterable, Identifiable, Codable {
    case action
    case comedy
    case drama
    case horror
    case sciFi
    case thriller
    case romance
    case fantasy
    case crime
    case adventure

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sciFi: return "Sci-Fi"
        default:     return rawValue.capitalized
        }
    }

    var symbol: String {
        switch self {
        case .action:    return "flame"
        case .comedy:    return "face.smiling"
        case .drama:     return "theatermasks"
        case .horror:    return "moon.stars"
        case .sciFi:     return "atom"
        case .thriller:  return "bolt.heart"
        case .romance:   return "heart"
        case .fantasy:   return "wand.and.stars"
        case .crime:     return "magnifyingglass"
        case .adventure: return "map"
        }
    }

    var blurb: String {
        switch self {
        case .action:    return "Momentum, set-pieces, and a hero pushed to the limit."
        case .comedy:    return "A flawed lead, escalating misunderstandings, and earned heart."
        case .drama:     return "Character under pressure, real stakes, emotional truth."
        case .horror:    return "Dread, escalation, and a monster that means something."
        case .sciFi:     return "A big idea that forces the world (and us) to change."
        case .thriller:  return "Tightening tension where every choice has a cost."
        case .romance:   return "Two people, an obstacle, and the risk of being known."
        case .fantasy:   return "A new world with rules, wonder, and a worthy quest."
        case .crime:     return "Codes, consequences, and the line characters won't cross."
        case .adventure: return "A journey into the unknown with a goal worth the danger."
        }
    }
}
