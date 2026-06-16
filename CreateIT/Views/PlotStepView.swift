import SwiftUI

struct PlotStepView: View {
    @EnvironmentObject private var wizard: WizardState

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepHeader(
                eyebrow: "Step 5",
                title: "Describe your story",
                subtitle: "Give us a title and your plot. We'll turn it into a fill-in-the-blank outline.")

            summaryChips

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
                    .frame(minHeight: 180)
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

    private var summaryChips: some View {
        HStack(spacing: 8) {
            if let s = wizard.structure { chip(s.rawValue, "rectangle.split.3x1") }
            if let m = wizard.medium { chip(m.rawValue, m.symbol) }
            if let r = wizard.runtime { chip(r.label, "clock") }
            if let g = wizard.genre { chip(g.title, g.symbol) }
            if let movie = wizard.sampleMovie { chip(movie.title, "film") }
            Spacer()
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
}
