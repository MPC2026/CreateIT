import SwiftUI

struct SecondaryGenreStepView: View {
    @EnvironmentObject private var wizard: WizardState
    
    // Get secondary genres based on primary genre selection
    struct GenreOption: Identifiable {
        let id = UUID()
        let name: String
        let genre: Genre?
    }
    
    var availableSecondaryGenres: [GenreOption] {
        guard let primary = wizard.primaryGenreTitle else { return [] }
        
        // All genres except the primary one can be secondary
        return Genre.allCases
            .filter { $0.title != primary }
            .map { genre in
                GenreOption(name: genre.title, genre: genre)
            }
    }
    
    // Map string genre names to Genre enum
    func genre(from name: String) -> Genre? {
        switch name {
        case "Action": return .action
        case "Comedy": return .comedy
        case "Drama": return .drama
        case "Horror": return .horror
        case "Sci-Fi", "SciFi": return .sciFi
        case "Thriller": return .thriller
        case "Romance": return .romance
        case "Fantasy": return .fantasy
        case "Crime": return .crime
        case "Adventure": return .adventure
        default: return nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepHeader(
                eyebrow: "Step 3.5",
                title: "Choose a secondary genre",
                subtitle: nil
            )

            if availableSecondaryGenres.isEmpty {
                ContentUnavailableMessage(message: "Please select a primary genre first")
            } else {
                CardGrid(data: availableSecondaryGenres, columns: 3) { genreOption in
                    if let genre = genreOption.genre {
                        SelectionCard(
                            isSelected: wizard.secondaryGenreTitle == genre.title,
                            action: {
                                // Add secondary genre to selection
                                if !wizard.selectedGenres.contains(genre.title) {
                                    wizard.addSelectedGenre(genre.title)
                                }
                                
                                // Show alert to confirm primary/secondary assignment
                                withAnimation {
                                    wizard.next()
                                }
                            }
                        ) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: genre.symbol)
                                        .font(.system(size: 22))
                                        .foregroundStyle(.tint)
                                    Spacer()
                                    if wizard.secondaryGenreTitle == genre.title {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                                    }
                                }
                                Text(genre.title)
                                    .font(.title3.weight(.bold))
                                Text(genre.blurb)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct ContentUnavailableMessage: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "questionmark.diamond")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

#Preview {
    SecondaryGenreStepView()
        .environmentObject(WizardState())
}
