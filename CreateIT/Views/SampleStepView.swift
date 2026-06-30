import SwiftUI

struct SampleStepView: View {
    @EnvironmentObject private var wizard: WizardState

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepHeader(
                eyebrow: "Step 4",
                title: "Pick a sample film",
                subtitle: "We'll use its structure as a guide — for inspiration, never to copy.")

            if wizard.sampleMovies.isEmpty {
                ContentUnavailableMessage()
            } else {
                CardGrid(data: wizard.sampleMovies, columns: 2) { movie in
                    SelectionCard(
                        isSelected: wizard.sampleMovie?.id == movie.id,
                        action: {
                            // Use withAnimation to ensure UI updates before navigation
                            withAnimation {
                                wizard.sampleMovie = movie
                            }
                            // Small delay to ensure state is committed before advancing
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                wizard.next()
                            }
                        }
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(movie.title)
                                    .font(.title3.weight(.bold))
                                Text("(\(String(movie.year)))")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                if wizard.sampleMovie?.id == movie.id {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                                }
                            }
                            Text(movie.logline)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            Label("Samples are original paraphrased summaries used purely as structural guidance.",
                  systemImage: "info.circle")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ContentUnavailableMessage: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "film.stack")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Choose a genre first to see sample films.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}
