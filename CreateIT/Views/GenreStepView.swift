import SwiftUI

struct GenreStepView: View {
    @EnvironmentObject private var wizard: WizardState

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepHeader(
                eyebrow: "Step 3",
                title: "Choose a genre",
                subtitle: "This shapes the tone and the sample films you'll see.")

            CardGrid(data: Genre.allCases, columns: 3) { genre in
                SelectionCard(
                    isSelected: wizard.genre == genre,
                    action: { wizard.selectGenre(genre) }
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: genre.symbol)
                                .font(.system(size: 22))
                                .foregroundStyle(.tint)
                            Spacer()
                            if wizard.genre == genre {
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
