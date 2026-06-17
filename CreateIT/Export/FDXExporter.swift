import Foundation

/// How each beat should appear in the exported Final Draft document.
enum BeatElement: String, CaseIterable, Identifiable {
    /// Beats import as outline rows (Navigator / Beat Board friendly).
    case section = "Section Heading"
    /// Beats import as Beat Board cards with synopsis text.
    case card = "Synopsis"
    /// Beats import as scenes (each becomes a slug line on the page).
    case scene = "Scene Heading"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .section: return "Beat Board Sections"
        case .card:    return "Beat Board Cards"
        case .scene:   return "Scene Script Pages"
        }
    }
}

/// Exports a CreateIT project to Final Draft's `.fdx` (Final Draft XML) format.
///
/// Each act and beat becomes a heading paragraph. In beat-board mode, beats are
/// exported as `Scene Heading` paragraphs followed by `Synopsis` paragraphs so
/// Final Draft can treat them as cards with card text. The writer's text (plus
/// optional guidance and sample) becomes `Action` paragraphs in the other modes.
enum FDXExporter {

    @MainActor
    static func export(
        from wizard: WizardState,
        beatElement: BeatElement = .section,
        includeGuidance: Bool = true,
        includeSceneScript: Bool = false
    ) -> String {
        var body = ""

        func paragraph(_ type: String, _ text: String, style: String? = nil) {
            let textTag: String
            if let style {
                textTag = "<Text Style=\"\(style)\">\(escape(text))</Text>"
            } else {
                textTag = "<Text>\(escape(text))</Text>"
            }
            body += """
                <Paragraph Type="\(type)">
                  \(textTag)
                </Paragraph>

            """
        }

        // Optional logline up top.
        if !wizard.logline.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            paragraph("Action", "LOGLINE: \(wizard.logline)", style: "Italic")
        }

        var currentAct = Int.min
        for beat in wizard.beats {
            // Act divider as its own section heading.
            if beat.act != currentAct {
                currentAct = beat.act
                paragraph("Section Heading", beat.actLabel.uppercased())
            }

            // Beat heading with timing.
            let timing = wizard.runtime.map { " — \(beat.timing(for: $0))" } ?? ""
            let headingText = beatElement == .section
                ? beat.title
                : beat.title.uppercased()
            paragraph(beatElement == .card ? "Scene Heading" : beatElement.rawValue, "\(headingText)\(timing)")

            let written = wizard.entries[beat.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if beatElement == .card {
                let cardText = written.isEmpty ? beat.purpose : written
                paragraph("Synopsis", cardText)
            } else {
                if includeGuidance {
                    paragraph("Action", "GUIDANCE: \(beat.purpose)", style: "Italic")
                    if let sample = wizard.sampleMovie?.sample(for: beat.key) {
                        let name = wizard.sampleMovie?.title ?? "Sample"
                        paragraph("Action", "\(name.uppercased()) REFERENCE: \(sample)", style: "Italic")
                    }
                }

                if written.isEmpty {
                    paragraph("Action", "[\(beat.placeholder)]")
                } else {
                    paragraph("Action", written)
                }
            }
        }

        if includeSceneScript, !wizard.scenes.isEmpty {
            paragraph("Section Heading", "SCENE SCRIPT")

            var currentSceneAct = Int.min
            for scene in wizard.orderedScenes {
                guard let beatKey = scene.beatKey,
                      let beat = wizard.beats.first(where: { $0.key == beatKey }) else {
                    continue
                }

                if beat.act != currentSceneAct {
                    currentSceneAct = beat.act
                    paragraph("Section Heading", beat.actLabel.uppercased())
                }

                paragraph("Scene Heading", wizard.sceneDisplayHeading(for: scene.id))

                let summary = scene.summary.trimmingCharacters(in: .whitespacesAndNewlines)
                if !summary.isEmpty {
                    paragraph("Action", summary)
                }
            }
        }

        let title = wizard.projectTitle.isEmpty ? "Untitled" : wizard.projectTitle
        let credit = creditLine(for: wizard)

        return """
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <FinalDraft DocumentType="Script" Template="No" Version="5">
          <Content>
        \(body)  </Content>
          <TitlePage>
            <Content>
              <Paragraph Alignment="Center">
                <Text></Text>
              </Paragraph>
              <Paragraph Alignment="Center">
                <Text Style="Bold">\(escape(title))</Text>
              </Paragraph>
              <Paragraph Alignment="Center">
                <Text></Text>
              </Paragraph>
              <Paragraph Alignment="Center">
                <Text>\(escape(credit))</Text>
              </Paragraph>
            </Content>
          </TitlePage>
        </FinalDraft>
        """
    }

    @MainActor
    private static func creditLine(for wizard: WizardState) -> String {
        var parts: [String] = []
        if let s = wizard.structure { parts.append(s.title) }
        if let m = wizard.medium, let r = wizard.runtime { parts.append("\(m.rawValue) · \(r.label)") }
        if let g = wizard.genre { parts.append(g.title) }
        return parts.joined(separator: "  ·  ")
    }

    /// Escapes characters that are illegal in XML text nodes.
    private static func escape(_ s: String) -> String {
        var out = s
        out = out.replacingOccurrences(of: "&", with: "&amp;")
        out = out.replacingOccurrences(of: "<", with: "&lt;")
        out = out.replacingOccurrences(of: ">", with: "&gt;")
        out = out.replacingOccurrences(of: "\"", with: "&quot;")
        out = out.replacingOccurrences(of: "'", with: "&apos;")
        return out
    }
}
