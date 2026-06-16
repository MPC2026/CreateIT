import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var wizard: WizardState
    @EnvironmentObject private var ai: AIAssistant
    @State private var showAISettings = false
    @State private var showUpdates = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                stepContent
                    .padding(28)
                    .frame(maxWidth: 920)
                    .frame(maxWidth: .infinity)
            }
            Divider()
            footer
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showAISettings) {
            AISettingsView()
        }
        .sheet(isPresented: $showUpdates) {
            UpdateCenterView()
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 14) {
            HStack(spacing: 8) {
                Image("Logo")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                Text("CreateIT")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
            }
            Spacer()
            StepIndicator()
            Spacer()
            Text(AppInfo.displayVersion)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .help("App version")
            Button {
                showAISettings = true
            } label: {
                Label("AI", systemImage: aiSymbol)
            }
            .help(aiHelp)
            .tint(aiConnected ? .green : nil)
            Button {
                showUpdates = true
            } label: {
                Label("Updates", systemImage: "clock.arrow.circlepath")
            }
            .help("View recent changes and the GitHub repo")
            Button {
                wizard.reset()
            } label: {
                Label("New", systemImage: "plus")
            }
            .help("Start a new script")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var aiConnected: Bool { ai.isConfigured }

    private var aiSymbol: String {
        aiConnected ? "brain.head.profile" : "brain"
    }

    private var aiHelp: String {
        aiConnected ? "Local AI connected — click to configure" : "Connect a local LLM (LM Studio)"
    }

    // MARK: Step content

    @ViewBuilder
    private var stepContent: some View {
        switch wizard.step {
        case .structure: StructureStepView()
        case .format:    FormatStepView()
        case .genre:     GenreStepView()
        case .sample:    SampleStepView()
        case .plot:      PlotStepView()
        case .template:  TemplateStepView()
        }
    }

    // MARK: Footer

    private var footer: some View {
        HStack {
            if wizard.step != .structure {
                Button {
                    wizard.back()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .keyboardShortcut(.leftArrow, modifiers: [.command])
            }
            Spacer()
            footerHint
            Spacer()
            if wizard.step != .template {
                Button {
                    wizard.next()
                } label: {
                    Label(wizard.step == .plot ? "Generate Template" : "Continue",
                          systemImage: "chevron.right")
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(!wizard.canAdvance)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var footerHint: some View {
        switch wizard.step {
        case .structure where wizard.structure == nil:
            Text("Pick a structure to begin").foregroundStyle(.secondary).font(.callout)
        case .format where !wizard.canAdvance:
            Text("Choose a medium and a runtime").foregroundStyle(.secondary).font(.callout)
        case .sample where wizard.sampleMovie == nil:
            Text("Choose a film whose shape inspires you").foregroundStyle(.secondary).font(.callout)
        case .plot where !wizard.canAdvance:
            Text("Add a title to continue").foregroundStyle(.secondary).font(.callout)
        default:
            EmptyView()
        }
    }
}
