import SwiftUI

struct StructureStepView: View {
    @EnvironmentObject private var wizard: WizardState

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepHeader(
                eyebrow: "Step 1",
                title: "Choose your structure",
                subtitle: "How do you want to shape the story?")

            CardGrid(data: ScriptStructure.allCases, columns: 2) { structure in
                SelectionCard(
                    isSelected: wizard.structure == structure,
                    action: {
                        wizard.structure = structure
                    }
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: structure.symbol)
                                .font(.system(size: 26))
                                .foregroundStyle(.tint)
                            Spacer()
                            if wizard.structure == structure {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.tint)
                            }
                        }
                        Text(structure.title)
                            .font(.title2.weight(.bold))
                        Text(structure.subtitle)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.tint)
                        Text(structure.blurb)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
