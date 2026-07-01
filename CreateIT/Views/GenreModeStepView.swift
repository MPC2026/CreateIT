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
                        wizard.selectGenreMode(mode)
                        
                        // Navigate based on mode
                        if mode == .primaryOnly {
                            // For Primary Only, go directly to genre selection (which will auto-advance after one selection)
                            wizard.forceNext()
                        } else {
                            // For Primary & Secondary, go to genre selection where user can pick two
                            wizard.forceNext()
                        }
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
