import SwiftUI

enum BrandPalette {
    static let sidebarBackgroundTop = Color(red: 0.08, green: 0.10, blue: 0.14)
    static let sidebarBackgroundBottom = Color(red: 0.10, green: 0.16, blue: 0.20)
    static let sidebarAccent = Color(red: 0.23, green: 0.64, blue: 0.60)

    static let headerBackgroundTop = Color(red: 0.10, green: 0.12, blue: 0.16)
    static let headerBackgroundBottom = Color(red: 0.14, green: 0.16, blue: 0.21)

    static let surface = Color.white.opacity(0.04)
    static let surfaceBorder = Color.white.opacity(0.08)
    static let softBorder = Color.white.opacity(0.06)
}

struct ContentView: View {
    @EnvironmentObject private var wizard: WizardState
    @EnvironmentObject private var ai: AIAssistant
    @EnvironmentObject private var updates: GitHubUpdateService
    @EnvironmentObject private var templateLibrary: TemplateLibraryStore
    @State private var showAISettings = false
    @State private var showUpdates = false
    @State private var didBootstrapUpdates = false
    @State private var showTemplatePanel = true
    @State private var showProjectLoadedToast = false
    @State private var loadedProjectTitle = ""
    @State private var showProjectLoadedPulse = false
    @State private var outlineScrollTargetBeatKey: String?

    var body: some View {
        VStack(spacing: 0) {
            topNavigationHeader
                .frame(maxWidth: .infinity)

            Divider()

            HStack(spacing: 0) {
                if showTemplatePanel {
                    expandedSidebarRail
                        .frame(width: 320)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    collapsedSidebarRail
                        .frame(width: 64)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }

                Divider()
                    .transition(.opacity)

                mainContent
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .animation(.easeInOut(duration: 0.24), value: showTemplatePanel)
        .sheet(isPresented: $showAISettings) {
            AISettingsView()
        }
        .sheet(isPresented: $showUpdates) {
            UpdateCenterView()
        }
        .overlay(alignment: .bottom) {
            if showProjectLoadedToast {
                Text("Loaded \(loadedProjectTitle)")
                    .font(.callout.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(.black.opacity(0.84)))
                    .foregroundStyle(.white)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 14)
            }
        }
        .onChange(of: templateLibrary.projectOpenToken) { _, _ in
            guard let template = templateLibrary.selectedTemplate else { return }
            loadedProjectTitle = template.displayTitle
            withAnimation(.easeInOut(duration: 0.2)) {
                showProjectLoadedToast = true
                showProjectLoadedPulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showProjectLoadedToast = false
                    showProjectLoadedPulse = false
                }
            }
        }
        .task {
            guard !didBootstrapUpdates else { return }
            didBootstrapUpdates = true
            await updates.refresh()
        }
    }

    private var topNavigationHeader: some View {
        HStack(alignment: .center, spacing: 18) {
            HStack(spacing: 14) {
                Image("CreateITLogoV2")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 66, height: 66)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.26), radius: 14, x: 0, y: 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text("CreateIT")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                    Text("Story workspace")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 240, alignment: .leading)

            Spacer(minLength: 24)

            StepIndicator()
                .fixedSize(horizontal: true, vertical: false)

            Spacer(minLength: 56)

            VStack(alignment: .trailing, spacing: 8) {
                Button {
                    showAISettings = true
                } label: {
                    Label("AI", systemImage: aiSymbol)
                }
                .help(aiHelp)
                .tint(aiConnected ? .green : nil)

                Button {
                    templateLibrary.startNewDraft(with: wizard)
                } label: {
                    Label("New", systemImage: "plus")
                }
                .help("Start a new script")
            }
            .padding(.horizontal, 50)
            .fixedSize(horizontal: true, vertical: false)
            .buttonStyle(.bordered)
            .padding(.top, 1)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [
                    BrandPalette.headerBackgroundTop,
                    BrandPalette.headerBackgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        )
        .overlay(
            Divider()
                .opacity(0.0)
        )
        .overlay(
            Rectangle()
                .fill(BrandPalette.softBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var expandedSidebarRail: some View {
        VStack(alignment: .leading, spacing: 10) {
            sidebarHeader(expanded: true)

            TemplateLibrarySidebarView()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    BrandPalette.sidebarBackgroundTop,
                                    BrandPalette.sidebarBackgroundBottom
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(BrandPalette.surfaceBorder)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)

            sidebarUpdatesCard(expanded: true)

            Spacer(minLength: 0)
        }
        .padding(.top, 12)
        .padding(.horizontal, 10)
        .padding(.bottom, 12)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var collapsedSidebarRail: some View {
        VStack(spacing: 8) {
            sidebarHeader(expanded: false)

            VStack(spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.24)) {
                        showTemplatePanel = true
                    }
                } label: {
                        sidebarIconTile(
                            systemImage: "sidebar.left",
                            title: "Open",
                            subtitle: "Projects",
                            compact: true,
                            isSelected: false)
                }
                .buttonStyle(.plain)

                Button {
                    templateLibrary.startNewDraft(with: wizard)
                } label: {
                    sidebarIconTile(
                        systemImage: "plus",
                        title: "New",
                        subtitle: "Draft",
                        compact: true,
                        isSelected: false)
                }
                .buttonStyle(.plain)
            }

            Divider()

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(templateLibrary.templates) { template in
                        Button {
                            templateLibrary.open(template, into: wizard)
                        } label: {
                            sidebarIconTile(
                                systemImage: "doc.text",
                                title: template.initials,
                                subtitle: template.displayTitle,
                                compact: true,
                                isSelected: templateLibrary.selectedTemplateID == template.id)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }

            Divider()

            VStack(spacing: 8) {
                Button {
                    showUpdates = true
                } label: {
                    sidebarIconTile(
                        systemImage: "clock.arrow.circlepath",
                        title: "Updates",
                        subtitle: updates.isUpdateAvailable ? "New available" : "Release notes",
                        compact: true,
                        isSelected: updates.isUpdateAvailable)
                }
                .buttonStyle(.plain)

                Text("Version \(AppInfo.displayVersion)")
                    .font(.caption2.weight(.regular))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 12)
        .padding(.horizontal, 6)
        .padding(.bottom, 12)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            LinearGradient(
                colors: [
                    BrandPalette.sidebarBackgroundTop,
                    BrandPalette.sidebarBackgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        )
        .overlay(
            Rectangle()
                .fill(BrandPalette.surfaceBorder)
                .frame(width: 1),
            alignment: .trailing
        )
    }

    private func sidebarHeader(expanded: Bool) -> some View {
        VStack(alignment: .leading, spacing: expanded ? 8 : 6) {
            HStack {
                if expanded {
                    Text("Projects")
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                } else {
                    Image(systemName: "sidebar.left")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 18)
                }
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.24)) {
                        showTemplatePanel.toggle()
                    }
                } label: {
                    Image(systemName: expanded ? "chevron.left" : "chevron.right")
                        .font(.caption.weight(.bold))
                }
                .buttonStyle(.borderless)
            }

            if expanded {
                Text("Keep saved outlines handy without giving up space.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, expanded ? 4 : 2)
        .padding(.top, expanded ? 2 : 0)
        .padding(.bottom, expanded ? 4 : 0)
    }

    private var mainContent: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        stepContent
                            .padding(28)
                            .frame(maxWidth: 920)
                            .frame(maxWidth: .infinity)
                    }
                    .onChange(of: outlineScrollTargetBeatKey) { _, value in
                        guard let value else { return }
                        withAnimation(.easeInOut(duration: 0.22)) {
                            proxy.scrollTo(value, anchor: .top)
                        }
                        DispatchQueue.main.async {
                            outlineScrollTargetBeatKey = nil
                        }
                    }
                }
                Divider()
                footer
            }
            if showProjectLoadedPulse {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                BrandPalette.sidebarAccent.opacity(0.10),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .center))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(BrandPalette.sidebarAccent.opacity(0.28), lineWidth: 1.5)
                    )
                    .padding(12)
                    .allowsHitTesting(false)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showProjectLoadedPulse)
    }

    private func sidebarIconTile(systemImage: String, title: String, subtitle: String, compact: Bool, isSelected: Bool) -> some View {
        VStack(spacing: compact ? 5 : 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? BrandPalette.sidebarAccent.opacity(0.22) : BrandPalette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(isSelected ? BrandPalette.sidebarAccent.opacity(0.55) : BrandPalette.surfaceBorder)
                    )

                Image(systemName: systemImage)
                    .font(.system(size: compact ? 15 : 18, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }
            .frame(width: compact ? 34 : 40, height: compact ? 34 : 40)

            if compact {
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
            } else {
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, compact ? 6 : 8)
        .padding(.horizontal, compact ? 4 : 6)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: compact ? 16 : 18, style: .continuous)
                .fill(isSelected ? BrandPalette.sidebarAccent.opacity(0.10) : Color.clear)
        )
    }

    private func sidebarUpdatesCard(expanded: Bool) -> some View {
        Button {
            showUpdates = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(updates.isUpdateAvailable ? BrandPalette.sidebarAccent.opacity(0.20) : BrandPalette.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(updates.isUpdateAvailable ? BrandPalette.sidebarAccent.opacity(0.55) : BrandPalette.surfaceBorder)
                            )

                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(updates.isUpdateAvailable ? Color.accentColor : Color.secondary)
                    }
                    .frame(width: 34, height: 34)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("Updates")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            if updates.isUpdateAvailable {
                                Text("NEW")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.orange.opacity(0.18)))
                                    .foregroundStyle(.orange)
                            }
                        }

                        Text("See recent changes and release notes")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                Text("Version \(AppInfo.displayVersion)")
                    .font(.caption2.weight(.regular))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, expanded ? 14 : 10)
            .padding(.vertical, expanded ? 12 : 10)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(BrandPalette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(BrandPalette.surfaceBorder)
            )
        }
        .buttonStyle(.plain)
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
        case .outline:   OutlineStepView(scrollTargetBeatKey: $outlineScrollTargetBeatKey)
        case .finalDraft: FinalDraftStepView()
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
            if wizard.step == .plot {
                Button {
                    wizard.forceNext()
                } label: {
                    Label("Generate Beats", systemImage: "chevron.right")
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            } else if wizard.step == .template {
                Button {
                    wizard.next()
                } label: {
                    Label("Continue to Scenes", systemImage: "chevron.right")
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            } else if wizard.step == .outline {
                Button {
                    wizard.forceNext()
                } label: {
                    Label("Open Final Draft", systemImage: "chevron.right")
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
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
        case .template where wizard.beats.isEmpty:
            Text("Create beats before moving on").foregroundStyle(.secondary).font(.callout)
        case .template:
            Text("Move into Scenes once the beats feel right").foregroundStyle(.secondary).font(.callout)
        case .outline:
            Text("Edit scenes, add new ones, then open Final Draft when you're ready").foregroundStyle(.secondary).font(.callout)
        case .finalDraft:
            Text("Export or open your Final Draft file from here").foregroundStyle(.secondary).font(.callout)
        default:
            EmptyView()
        }
    }

}
