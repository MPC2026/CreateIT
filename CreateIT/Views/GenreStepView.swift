import SwiftUI

struct GenreStepView: View {
    @EnvironmentObject private var wizard: WizardState
    @State private var showingSelectionAlert = false
    
    // Get available genres based on selected mode
    var availableGenres: [Genre] {
        Genre.allCases
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepHeader(
                eyebrow: "Step 3",
                title: wizard.genreMode == .primaryOnly ? "Choose a primary genre" : "Choose your genres",
                subtitle: wizard.genreMode == .primaryOnly 
                    ? "Select one primary genre for your story." 
                    : "Select two genres. First is Primary, second is Secondary."
            )

            CardGrid(data: availableGenres, columns: 3) { genre in
                SelectionCard(
                    isSelected: wizard.selectedGenres.contains(genre.title),
                    action: {
                        // Add or remove genre from selection
                        if let mode = wizard.genreMode, mode == .primaryOnly {
                            // For Primary Only, only allow one genre
                            wizard.addSelectedGenre(genre.title)
                            // Auto-advance after selecting genre (1 click) when canAdvance is true
                            if wizard.canAdvance {
                                wizard.next()
                            }
                        } else {
                            // For Primary & Secondary, toggle selection (max 2)
                            if wizard.selectedGenres.contains(genre.title) {
                                // Remove genre
                                if let idx = wizard.selectedGenres.firstIndex(of: genre.title) {
                                    var newSelections = wizard.selectedGenres
                                    newSelections.remove(at: idx)
                                    wizard.selectedGenres = newSelections
                                    // Rebuild primary/secondary from remaining selections
                                    if newSelections.count >= 1 {
                                        wizard.primaryGenreTitle = newSelections[0]
                                    } else {
                                        wizard.primaryGenreTitle = nil
                                    }
                                    if newSelections.count >= 2 {
                                        wizard.secondaryGenreTitle = newSelections[1]
                                    } else {
                                        wizard.secondaryGenreTitle = nil
                                    }
                                }
                            } else {
                                // Add genre (max 2)
                                if wizard.selectedGenres.count < 2 {
                                    wizard.addSelectedGenre(genre.title)
                                    
                                    // If we have 2 genres selected, show confirmation alert
                                    if wizard.selectedGenres.count == 2 {
                                        showingSelectionAlert = true
                                    }
                                }
                            }
                        }
                    }
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: genre.symbol)
                                .font(.system(size: 22))
                                .foregroundStyle(.tint)
                            Spacer()
                            if wizard.selectedGenres.contains(genre.title) {
                                // Show Primary or Secondary label based on selection order
                                if let idx = wizard.selectedGenres.firstIndex(of: genre.title), idx == 0 {
                                    Text("Primary")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.tint)
                                } else if let idx = wizard.selectedGenres.firstIndex(of: genre.title), idx == 1 {
                                    Text("Secondary")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.secondary)
                                }
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
            
            // Show current selection status
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Selection:")
                    .font(.headline)
                if wizard.selectedGenres.count >= 1 {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .foregroundStyle(.tint)
                        Text("Primary: \(wizard.primaryGenreTitle ?? "")")
                            .font(.subheadline)
                    }
                }
                if wizard.selectedGenres.count >= 2 {
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .foregroundStyle(.secondary)
                        Text("Secondary: \(wizard.secondaryGenreTitle ?? "")")
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color.primary.opacity(0.1))
            .cornerRadius(8)
            
            // Continue button - only enabled when we have at least 1 genre
            Button(action: {
                if wizard.selectedGenres.count >= 1 && wizard.canAdvance {
                    // For Primary Only mode, just advance
                    if wizard.genreMode == .primaryOnly {
                        wizard.next()
                    } else if wizard.genreMode == .primarySecondary {
                        // For Primary & Secondary mode, show alert if we have 2 genres
                        if wizard.selectedGenres.count == 2 {
                            showingSelectionAlert = true
                        }
                    }
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(wizard.selectedGenres.count >= 1 ? Color.blue : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(wizard.selectedGenres.count < 1)
        }
        .alert("Genre Selection", isPresented: $showingSelectionAlert) {
            Button("Continue") {
                if wizard.canAdvance {
                    wizard.next()
                }
            }
            if wizard.genreMode == .primarySecondary && wizard.selectedGenres.count >= 2 {
                // Show option to swap primary/secondary
                Button("Swap & Continue") {
                    // Swap the genres in selectedGenres
                    if wizard.selectedGenres.count >= 2 {
                        var newSelections = wizard.selectedGenres
                        let temp = newSelections[0]
                        newSelections[0] = newSelections[1]
                        newSelections[1] = temp
                        wizard.selectedGenres = newSelections
                        // Also update primary/secondary titles directly to ensure sample list refreshes
                        wizard.primaryGenreTitle = newSelections[0]
                        wizard.secondaryGenreTitle = newSelections[1]
                        wizard.forceNext()
                    }
                }
            }
            Button("Change Selection", role: .cancel) { }
        } message: {
            // Always show the current order from wizard state
            if let primary = wizard.primaryGenreTitle, let secondary = wizard.secondaryGenreTitle {
                Text("You've selected:\nPrimary: \(primary)\nSecondary: \(secondary)")
            } else {
                Text("You've selected \(wizard.selectedGenres.count) genre(s). First is Primary, second is Secondary.")
            }
        }
    }
}

#Preview {
    GenreStepView()
        .environmentObject(WizardState())
}
