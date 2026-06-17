import AppKit
import Foundation

enum BeatSheetPDFExporter {
    private static let pageSize = CGSize(width: 1224, height: 792)
    private static let marginX: CGFloat = 44.64
    private static let marginTop: CGFloat = 43.2
    private static let marginBottom: CGFloat = 39.6
    private static let cardWidth: CGFloat = 345.44
    private static let cardHeight: CGFloat = 111.5
    private static let columnStep: CGFloat = 386.64
    private static let rowStep: CGFloat = 135.936
    private static let cardsPerPage = 15

    private static let titleFont = NSFont.systemFont(ofSize: 30, weight: .bold)
    private static let subtitleFont = NSFont.systemFont(ofSize: 14, weight: .regular)
    private static let cardTitleFont = NSFont.systemFont(ofSize: 22, weight: .bold)
    private static let cardSceneFont = NSFont.systemFont(ofSize: 13, weight: .bold)
    private static let cardBodyFont = NSFont.systemFont(ofSize: 10, weight: .bold)
    private static let cardCountFont = NSFont.systemFont(ofSize: 11, weight: .regular)
    private static let footerFont = NSFont.systemFont(ofSize: 9, weight: .regular)

    @MainActor
    static func export(from wizard: WizardState, to url: URL) throws {
        let consumer = CGDataConsumer(url: url as CFURL)
        var mediaBox = CGRect(origin: .zero, size: pageSize)
        guard let consumer,
              let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw CocoaError(.fileWriteUnknown)
        }

        let nsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = nsContext
        defer {
            NSGraphicsContext.restoreGraphicsState()
            context.closePDF()
        }

        let beats = wizard.beats
        let totalPages = max(1, Int(ceil(Double(beats.count) / Double(cardsPerPage))))

        for pageIndex in 0..<totalPages {
            context.beginPDFPage([:] as CFDictionary)
            drawPageBackground(in: context)
            drawGrid(in: context)
            drawHeader(in: context, title: pdfTitle(for: wizard.projectTitle), subtitle: pdfSubtitle)

            let pageBeats = Array(beats.dropFirst(pageIndex * cardsPerPage).prefix(cardsPerPage))
            for (index, beat) in pageBeats.enumerated() {
                drawCard(in: context, beat: beat, slotIndex: index)
            }

            if totalPages > 1 {
                drawFooter(in: context, pageNumber: pageIndex + 1, totalPages: totalPages)
            } else {
                drawFooter(in: context, pageNumber: nil, totalPages: nil)
            }
            context.endPDFPage()
        }
    }

    private static var pdfSubtitle: String {
        "Typical scene-count beats laid out as color blocks"
    }

    private static func pdfTitle(for projectTitle: String) -> String {
        let title = projectTitle.isEmpty ? "Final Draft Beat Sheet" : "\(projectTitle) Beat Sheet"
        return title
    }

    private static func drawPageBackground(in context: CGContext) {
        context.setFillColor(NSColor(calibratedRed: 0.094, green: 0.094, blue: 0.094, alpha: 1).cgColor)
        context.fill(CGRect(origin: .zero, size: pageSize))
    }

    private static func drawGrid(in context: CGContext) {
        context.setStrokeColor(NSColor(calibratedWhite: 0.2, alpha: 1).cgColor)
        context.setLineWidth(0.7)

        var x: CGFloat = 0
        while x <= pageSize.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: pageSize.height))
            x += 54
        }

        var y: CGFloat = 0
        while y <= pageSize.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: pageSize.width, y: y))
            y += 54
        }

        context.strokePath()
    }

    private static func drawHeader(in context: CGContext, title: String, subtitle: String) {
        let titleRect = CGRect(x: 43.2, y: 738, width: 1000, height: 40)
        let subtitleRect = CGRect(x: 44.64, y: 716, width: 980, height: 20)
        drawText(title, in: titleRect, font: titleFont, color: .white, alignment: .left)
        drawText(subtitle, in: subtitleRect, font: subtitleFont, color: NSColor(white: 0.741, alpha: 1), alignment: .left)
    }

    private static func drawFooter(in context: CGContext, pageNumber: Int?, totalPages: Int?) {
        let note = "PDF beat board with color blocks - editable source supplied separately as .fdx"
        drawText(note, in: CGRect(x: 869.2, y: 14, width: 330, height: 16), font: footerFont, color: NSColor(white: 0.604, alpha: 1), alignment: .left)
        if let pageNumber, let totalPages, totalPages > 1 {
            drawText("Page \(pageNumber) of \(totalPages)", in: CGRect(x: 44.64, y: 14, width: 160, height: 16), font: footerFont, color: NSColor(white: 0.604, alpha: 1), alignment: .left)
        }
    }

    private static func drawCard(in context: CGContext, beat: BeatTemplate, slotIndex: Int) {
        let column = slotIndex % 3
        let rowFromTop = slotIndex / 3
        let rowFromBottom = 4 - rowFromTop
        let x = marginX + CGFloat(column) * columnStep
        let y = marginBottom + CGFloat(rowFromBottom) * rowStep
        let cardFrame = CGRect(x: x, y: y, width: cardWidth, height: cardHeight)
        let shadowFrame = cardFrame.offsetBy(dx: -5, dy: -5)

        let shadowPath = CGPath(roundedRect: shadowFrame, cornerWidth: 5, cornerHeight: 5, transform: nil)
        context.setFillColor(NSColor(calibratedWhite: 0, alpha: 0.28).cgColor)
        context.addPath(shadowPath)
        context.fillPath()

        let cardPath = CGPath(roundedRect: cardFrame, cornerWidth: 5, cornerHeight: 5, transform: nil)
        context.setFillColor(beatColor(for: beat).cgColor)
        context.addPath(cardPath)
        context.fillPath()

        let bottomStripHeight: CGFloat = 23.76
        let stripFrame = CGRect(x: cardFrame.minX, y: cardFrame.minY, width: cardFrame.width, height: bottomStripHeight)
        context.setFillColor(NSColor.white.withAlphaComponent(0.055).cgColor)
        context.addRect(stripFrame)
        context.fillPath()

        context.setStrokeColor(NSColor.white.withAlphaComponent(0.18).cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: cardFrame.minX + 12, y: cardFrame.minY + 30))
        context.addLine(to: CGPoint(x: cardFrame.maxX - 12, y: cardFrame.minY + 30))
        context.strokePath()

        let title = wrappedBeatTitle(beat.title)
        drawText(
            title,
            in: CGRect(x: cardFrame.minX + 12, y: cardFrame.minY + 82, width: cardFrame.width - 24, height: 34),
            font: cardTitleFont,
            color: NSColor(white: 1, alpha: 1),
            alignment: .left)

        drawText(
            "Scenes: \(sceneCountLabel(for: beat))",
            in: CGRect(x: cardFrame.minX + 212, y: cardFrame.minY + 79, width: 120, height: 22),
            font: cardSceneFont,
            color: NSColor(white: 0.941, alpha: 1),
            alignment: .right)

        drawText(
            "Body",
            in: CGRect(x: cardFrame.minX + 12, y: cardFrame.minY + 54, width: 180, height: 18),
            font: cardBodyFont,
            color: NSColor(white: 1, alpha: 1),
            alignment: .left)

        drawText(
            "Typical scene count: \(sceneCountLabel(for: beat))",
            in: CGRect(x: cardFrame.minX + 12, y: cardFrame.minY + 34, width: cardFrame.width - 24, height: 16),
            font: cardCountFont,
            color: NSColor(white: 1, alpha: 1),
            alignment: .left)
    }

    private static func drawText(_ text: String, in rect: CGRect, font: NSFont, color: NSColor, alignment: NSTextAlignment) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        text.draw(in: rect, withAttributes: attributes)
    }

    private static func wrappedBeatTitle(_ title: String) -> String {
        title.replacingOccurrences(of: " / ", with: " /")
    }

    private static func beatColor(for beat: BeatTemplate) -> NSColor {
        switch beat.key {
        case "openingImage":   return NSColor(red: 0.247059, green: 0.301961, blue: 0.388235, alpha: 1)
        case "themeStated":    return NSColor(red: 0.352941, green: 0.270588, blue: 0.407843, alpha: 1)
        case "setup":          return NSColor(red: 0.309804, green: 0.372549, blue: 0.262745, alpha: 1)
        case "catalyst":       return NSColor(red: 0.439216, green: 0.317647, blue: 0.239216, alpha: 1)
        case "debate":         return NSColor(red: 0.392157, green: 0.266667, blue: 0.301961, alpha: 1)
        case "breakIntoTwo":   return NSColor(red: 0.192157, green: 0.364706, blue: 0.403922, alpha: 1)
        case "bStory":         return NSColor(red: 0.403922, green: 0.309804, blue: 0.211765, alpha: 1)
        case "funAndGames":    return NSColor(red: 0.333333, green: 0.305882, blue: 0.439216, alpha: 1)
        case "midpoint":       return NSColor(red: 0.282353, green: 0.384314, blue: 0.337255, alpha: 1)
        case "badGuysCloseIn": return NSColor(red: 0.427451, green: 0.247059, blue: 0.247059, alpha: 1)
        case "allIsLost":      return NSColor(red: 0.290196, green: 0.337255, blue: 0.439216, alpha: 1)
        case "darkNight":      return NSColor(red: 0.368627, green: 0.352941, blue: 0.219608, alpha: 1)
        case "breakIntoThree": return NSColor(red: 0.243137, green: 0.356863, blue: 0.309804, alpha: 1)
        case "finale":         return NSColor(red: 0.376471, green: 0.243137, blue: 0.384314, alpha: 1)
        case "finalImage":     return NSColor(red: 0.294118, green: 0.294118, blue: 0.294118, alpha: 1)
        default:               return NSColor(calibratedWhite: 0.32, alpha: 1)
        }
    }

    private static func sceneCountLabel(for beat: BeatTemplate) -> String {
        switch beat.key {
        case "openingImage": return "1"
        case "themeStated": return "1"
        case "setup": return "5-8"
        case "catalyst": return "1-2"
        case "debate": return "3-5"
        case "breakIntoTwo": return "1"
        case "bStory": return "1-2"
        case "funAndGames": return "8-12"
        case "midpoint": return "1-2"
        case "badGuysCloseIn": return "6-10"
        case "allIsLost": return "1-2"
        case "darkNight": return "2-4"
        case "breakIntoThree": return "1"
        case "finale": return "8-15"
        case "finalImage": return "1"
        default:
            return "1"
        }
    }
}
