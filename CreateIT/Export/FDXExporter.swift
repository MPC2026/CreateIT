import Foundation

/// How each beat should appear in the exported Final Draft document.
enum BeatElement: String, CaseIterable, Identifiable {
    /// Beats import as outline rows (Navigator / Beat Board friendly).
    case section = "Section Heading"
    /// Beats import as scenes (each becomes a slug line on the page).
    case scene = "Scene Heading"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .section: return "Beats as Outline Sections"
        case .scene:   return "Beats as Scenes"
        }
    }
}

/// Exports a CreateIT project to Final Draft's `.fdx` (Final Draft XML) format.
///
/// Each act and beat becomes a heading paragraph, and the writer's text (plus
/// optional guidance and sample) becomes `Action` paragraphs. Final Draft 13
/// reads these as an outline / beat structure in the Navigator.
enum FDXExporter {

    @MainActor
    static func export(
        from wizard: WizardState,
        beatElement: BeatElement = .section,
        includeGuidance: Bool = true
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
            // Scene headings read better in upper case as Final Draft slugs.
            let headingText = beatElement == .scene
                ? "\(beat.title.uppercased())\(timing)"
                : "\(beat.title)\(timing)"
            paragraph(beatElement.rawValue, headingText)

            if includeGuidance {
                paragraph("Action", "GUIDANCE: \(beat.purpose)", style: "Italic")
                if let sample = wizard.sampleMovie?.sample(for: beat.key) {
                    let name = wizard.sampleMovie?.title ?? "Sample"
                    paragraph("Action", "\(name.uppercased()) REFERENCE: \(sample)", style: "Italic")
                }
            }

            // The writer's own text, or the prompt if empty.
            let written = wizard.entries[beat.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if written.isEmpty {
                paragraph("Action", "[\(beat.placeholder)]")
            } else {
                paragraph("Action", written)
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
