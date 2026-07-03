import SwiftUI

struct FormatStepView: View {
    @EnvironmentObject private var wizard: WizardState

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepHeader(
                eyebrow: "Step 2",
                title: "Pick your format",
                subtitle: "What are you writing, and how long is it?")

            VStack(alignment: .leading, spacing: 12) {
                Text("Medium")
                    .font(.headline)
                CardGrid(data: Medium.allCases, columns: 2) { medium in
                    SelectionCard(
                        isSelected: wizard.medium == medium,
                        action: {
                            wizard.selectMedium(medium)
                            if medium == .movie {
                                wizard.forceNext()
                            }
                        }
                    ) {
                        HStack(spacing: 14) {
                            Image(systemName: medium.symbol)
                                .font(.system(size: 24))
                                .foregroundStyle(.tint)
                                .frame(width: 34)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(medium.rawValue)
                                    .font(.title3.weight(.bold))
                                Text(medium.blurb)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            if wizard.medium == medium {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }

            if let medium = wizard.medium {
                let options = Runtime.options(for: medium)
                VStack(alignment: .leading, spacing: 12) {
                    Text(medium == .movie ? "Length" : "Runtime")
                        .font(.headline)
                    if medium == .movie {
                        Text("Feature films use a standard ~120-page script.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    CardGrid(data: options, columns: 2) { runtime in
                        SelectionCard(
                            isSelected: wizard.runtime == runtime,
                            action: {
                                wizard.runtime = runtime
                            }
                        ) {
                            HStack(spacing: 14) {
                                Image(systemName: runtime.symbol)
                                    .font(.system(size: 24))
                                    .foregroundStyle(.tint)
                                    .frame(width: 34)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(runtime.label)
                                        .font(.title3.weight(.bold))
                                    Text(runtime.subtitle)
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if wizard.runtime == runtime {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
