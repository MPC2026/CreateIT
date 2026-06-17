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
            HStack(spacing: 8) {
                ForEach(WizardStep.allCases, id: \.rawValue) { item in
                    let isActive = item == wizard.step
                    let isDone = item.rawValue < wizard.step.rawValue
                    Button {
                        wizard.go(to: item)
                    } label: {
                        VStack(spacing: 5) {
                            ZStack {
                                Circle()
                                    .fill(isActive || isDone ? Color.accentColor : Color.secondary.opacity(0.25))
                                    .frame(width: 22, height: 22)
                                if isDone {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                } else {
                                    Text("\(item.rawValue + 1)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(isActive ? .white : .secondary)
                                }
                            }

                            Text(item.title)
                                .font(.caption2.weight(isActive ? .semibold : .regular))
                                .foregroundStyle(isActive ? .primary : .secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(width: 60, alignment: .center)
                        }
                        .frame(width: 68)
                        .padding(.vertical, 3)
                    }
                    .buttonStyle(.plain)
                    .disabled(item.rawValue > wizard.step.rawValue + 1 || (item.rawValue == wizard.step.rawValue + 1 && !wizard.canAdvance))

                    if item != WizardStep.allCases.last {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.18))
                            .frame(width: 14, height: 1)
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
