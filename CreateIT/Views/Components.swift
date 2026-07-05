import SwiftUI

// MARK: - Selection Card

/// A large tappable card used throughout the wizard for choices.
struct SelectionCard<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? Color.accentColor.opacity(0.14) : Color(nsColor: .controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color.accentColor : Color.primary.opacity(hovering ? 0.18 : 0.08),
                            lineWidth: isSelected ? 2 : 1)
                )
                .shadow(color: .black.opacity(hovering ? 0.08 : 0), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.15), value: hovering)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Step Header

struct StepHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tint)
                .tracking(1.2)
            Text(title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Step Indicator

struct StepIndicator: View {
    @EnvironmentObject private var wizard: WizardState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(WizardStep.allCases, id: \.rawValue) { item in
                    let isActive = item == wizard.step
                    let isDone = item.rawValue < wizard.step.rawValue
                    Button {
                        wizard.go(to: item)
                    } label: {
                        VStack(spacing: 3) {
                            ZStack {
                                Circle()
                                    .fill(isActive || isDone ? Color.accentColor : Color.secondary.opacity(0.25))
                                    .frame(width: 18, height: 18)
                                if isDone {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.white)
                                } else {
                                    Text("\(item.rawValue + 1)")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(isActive ? .white : .secondary)
                                }
                            }

                            Text(item.title)
                                .font(.system(size: 9, weight: isActive ? .semibold : .regular))
                                .foregroundStyle(isActive ? .primary : .secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(width: 46, alignment: .center)
                        }
                        .frame(width: 52)
                        .padding(.vertical, 2)
                    }
                    .buttonStyle(.plain)
                    .disabled(item.rawValue > wizard.step.rawValue + 1 || (item.rawValue == wizard.step.rawValue + 1 && !wizard.canAdvance))

                    if item != WizardStep.allCases.last {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.18))
                            .frame(width: 10, height: 1)
                    }
                }
            }
        }
    }
}

// MARK: - Flow layout for chips/grids

/// A simple two/three column grid helper.
struct CardGrid<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let columns: Int
    @ViewBuilder let content: (Data.Element) -> Content

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: columns),
            spacing: 14
        ) {
            ForEach(data) { item in
                content(item)
            }
        }
    }
}

// MARK: - Scene Card

/// A reusable view showing scene details in card format with act, beat, scene number, and text preview.
struct SceneCardView: View {
    let scene: SceneOutlineScene
    let beat: BeatTemplate?
    let isSelected: Bool
    let laneColor: Color
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Lane color indicator
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(laneColor)
                    .frame(width: 6, height: .infinity)

                // Scene details
                VStack(alignment: .leading, spacing: 4) {
                    // Header: Act X - Beat Name - Scene Y
                    HStack(spacing: 6) {
                        Text("ACT \(scene.act)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        if let beatTitle = beat?.title {
                            Text("• \(beatTitle)")
                                .font(.caption.weight(.regular))
                                .foregroundStyle(.primary)
                        }
                        Text("• Scene \(scene.beatSceneNumber)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    // Title
                    if !scene.title.isEmpty {
                        Text(scene.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(isSelected ? Color.accentColor : .primary)
                    }

                    // Summary preview
                    if !scene.summary.isEmpty {
                        Text(scene.summary)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                }

                Spacer()
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isSelected ? Color.accentColor : Color.primary.opacity(hovering ? 0.18 : 0.08),
                    lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: .black.opacity(hovering ? 0.08 : 0), radius: 6, y: 2)
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.15), value: hovering)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}
