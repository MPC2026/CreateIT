import SwiftUI

struct GenreModeStepView: View {
    @EnvironmentObject private var wizard: WizardState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepHeader(
                eyebrow: "Step 3",
                title: "Choose your genre selection mode",
                subtitle: "Select how you want to choose genres for your story.")
            
            CardGrid(data: GenreSelectionMode.allCases, columns: 2) { mode in
                SelectionCard(
                    isSelected: wizard.genreMode == mode,
                    action: {
                        // Only select the mode - don't auto-advance yet
                        wizard.selectGenreMode(mode)
                        // User will manually advance after selecting mode
                    }
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: mode.symbol)
                                .font(.system(size: 22))
                                .foregroundStyle(.tint)
                            Spacer()
                            if wizard.genreMode == mode {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                            }
                        }
                        Text(mode.title)
                            .font(.title3.weight(.bold))
                        Text(mode.blurb)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

#Preview {
    GenreModeStepView()
        .environmentObject(WizardState())
}
