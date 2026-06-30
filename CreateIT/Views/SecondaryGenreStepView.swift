import SwiftUI

struct SecondaryGenreStepView: View {
    @EnvironmentObject private var wizard: WizardState
    
    // Get secondary genres based on primary genre selection
    var availableSecondaryGenres: [String] {
        SampleListLoader.shared.getSecondaryGenres(for: wizard.primaryGenreTitle ?? "")
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
                subtitle: "This refines your sample film selection."
            )

            if availableSecondaryGenres.isEmpty {
                ContentUnavailableMessage(message: "Please select a primary genre first")
            } else {
                CardGrid(data: availableSecondaryGenres, columns: 3) { secondaryGenreName in
                    guard let genre = genre(from: secondaryGenreName) else { return }
                    
                    SelectionCard(
                        isSelected: wizard.secondaryGenre == genre,
                        action: {
                            withAnimation {
                                wizard.selectSecondaryGenre(genre)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                                if wizard.secondaryGenre == genre {
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
