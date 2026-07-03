import SwiftUI

struct PlotStepView: View {
    @EnvironmentObject private var wizard: WizardState
    @EnvironmentObject private var ai: AIAssistant
    @State private var isDraftingStoryline = false
    @State private var storylineError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepHeader(
                eyebrow: "Step 5",
                title: "Describe your story",
                subtitle: "Give us a title and your plot. Then choose whether to draft the storyline with AI or move ahead manually.")

            ViewThatFits(in: .horizontal) {
                twoColumnLayout
                oneColumnLayout
            }
        }
    }

    private var twoColumnLayout: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 18) {
                primaryColumn
                sampleDetailsSection
            }
            secondaryColumn
                .frame(width: 300, alignment: .topLeading)
        }
    }

    private var oneColumnLayout: some View {
        VStack(alignment: .leading, spacing: 20) {
            summaryChips
            primaryColumn
            sampleDetailsSection
            secondaryColumn
        }
    }

    private var primaryColumn: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.headline)
                TextField("Working title", text: $wizard.projectTitle)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Logline")
                        .font(.headline)
                    Text("optional")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                TextField("One sentence: who wants what, and what's in the way?", text: $wizard.logline)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Plot")
                        .font(.headline)
                    Spacer()
                    Text("This seeds the guidance for each beat.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                TextEditor(text: $wizard.plot)
                    .font(.body)
                    .frame(minHeight: 260)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(nsColor: .textBackgroundColor)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.primary.opacity(0.1)))
                    .overlay(alignment: .topLeading) {
                        if wizard.plot.isEmpty {
                            Text("Type out your story in a few sentences or paragraphs…")
                                .foregroundStyle(.secondary)
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
    }

    private var sampleDetailsSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.tint)
                    Text("Sample movie selection has been removed. You can now proceed directly to plot.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var secondaryColumn: some View {
        VStack(alignment: .leading, spacing: 16) {
            summaryPanel
            actionPanel
        }
    }

    private var summaryPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Project")
                .font(.headline)
            summaryChips
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08)))
    }

    private var actionPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next")
                .font(.headline)
            Text("When the plot feels ready, draft the storyline with AI or jump into beats.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                draftStorylineWithAI()
            } label: {
                if isDraftingStoryline {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text("Drafting…")
                    }
                } else {
                    Label("Draft Storyline with AI", systemImage: "sparkles")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isDraftingStoryline || !ai.isConfigured)

            Button {
                wizard.forceNext()
            } label: {
                Label("Continue to Beats", systemImage: "arrow.right")
            }
            .buttonStyle(.borderedProminent)

            if let storylineError {
                Text(storylineError)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08)))
    }

    private var summaryChips: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                if let s = wizard.structure { chip(s.rawValue, "rectangle.split.3x1") }
                if let m = wizard.medium { chip(m.rawValue, m.symbol) }
                if let r = wizard.runtime { chip(r.label, "clock") }
                if !wizard.selectedGenres.isEmpty { let genreList = wizard.selectedGenres.joined(separator: ", "); chip(genreList, "tag") }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                if let s = wizard.structure { chip(s.rawValue, "rectangle.split.3x1") }
                if let m = wizard.medium { chip(m.rawValue, m.symbol) }
                if let r = wizard.runtime { chip(r.label, "clock") }
                if !wizard.selectedGenres.isEmpty { let genreList = wizard.selectedGenres.joined(separator: ", "); chip(genreList, "tag") }
            }
        }
    }

    private func chip(_ text: String, _ symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(Color.accentColor.opacity(0.12)))
            .foregroundStyle(.tint)
    }

    private func draftStorylineWithAI() {
        isDraftingStoryline = true
        storylineError = nil
        Task { @MainActor in
            defer { isDraftingStoryline = false }
            do {
                let outline = try await ai.createStoryOutline(wizard: wizard)

                for (beatKey, text) in outline {
                    wizard.entries[beatKey] = text
                }
                wizard.forceNext()
            } catch is CancellationError {
                return
            }
            catch {
                storylineError = error.localizedDescription
            }
        }
    }
}
