//

import Foundation
import ArgumentParser
import CoreGraphics
import CoreText
import AppKit
import MarkdownKit

@main
struct RGPDFGen: ParsableCommand {
    @Option(name: [.short, .customLong("input")], help: "Input file path.") var inputFile: String
    @Option(name: [.short, .customLong("output")], help: "Output file path.") var outputFile: String
    @Flag(name: [.short, .customLong("easy")], help: "Sort clues in easy mode.") var easy = false
    @Option(name: [.short, .customLong("fontsize")], help: "Clue font size.") var fontSize: String = "12"
    static var configuration = CommandConfiguration(commandName: "rgpdfgen")

    mutating func run() throws {
        let expandedInput = (inputFile as NSString).expandingTildeInPath
        guard let garden = RGParser.parse(filePath: expandedInput) else {
            throw RuntimeError("Couldn't parse '\(expandedInput)'")
        }
        guard let fontAsDouble = Double(fontSize) else {
            throw RuntimeError("Invalid font size")
        }
        let clueFontSize = CGFloat(fontAsDouble)
        let outURL = URL(fileURLWithPath: (outputFile as NSString).expandingTildeInPath)
        try? FileManager.default.removeItem(at: outURL)
        let w = 612.0,
            h = 792.0
        var pageRect = CGRect(x: 0, y: 0, width: w, height: h)
        guard let context = CGContext(outURL as CFURL, mediaBox: &pageRect, nil) else {
            throw RuntimeError("Couldn't create CGContext")
        }
        context.beginPDFPage(nil)
        GardenDrawer.drawGarden(context: context, rect: CGRect(origin: CGPoint(x: 100, y: h - 380), size: CGSize(width: 612 - 200, height: 500)))
        if let title = garden.title {
            var header = title
            if let author = garden.author {
                header.append(" by \(author)")
            }
            if let date = garden.created {
                header.append(" • \(date)")
            }
            if easy {
                header.append(" • Light Edition")
            } else {
                header.append(" • Full-Bodied Edition")
            }
            let titleAttrs = [
                NSAttributedString.Key.font : NSFont(name: "HighwayGothic", size: 16)!,
            ]
            let headerSize = header.size(withAttributes: titleAttrs)
            let titleString = NSAttributedString(string: header, attributes: titleAttrs)
            let path = CGMutablePath()
            path.addRect(CGRect(x: (w - headerSize.width) / 2, y: h - 70, width: w - 32, height: 40))
            let titleFramesetter = CTFramesetterCreateWithAttributedString(titleString as CFAttributedString)
            let titleFrame = CTFramesetterCreateFrame(titleFramesetter, CFRange(location: 0, length: 0), path, nil)
            CTFrameDraw(titleFrame, context)
        }

        let boldAttrs = [
            NSAttributedString.Key.font : NSFont(name: "HelveticaNeue-Bold", size: clueFontSize)!
        ]
        let italicAttrs = [
            NSAttributedString.Key.font : NSFont(name: "HelveticaNeue-Italic", size: clueFontSize)!
        ]
        let leftPath = CGMutablePath()
        leftPath.addRect(CGRect(x: 32, y: 64, width: (w - 64) / 2 , height: 360 - 32).insetBy(dx: 8, dy: 0))
        let rightPath = CGMutablePath()
        rightPath.addRect(CGRect(x: 32 + ((w - 64) / 2), y: 64, width: (w - 64) / 2 , height: 360 - 32).insetBy(dx: 8, dy: 0))

        let md = MarkdownParser(font: NSFont(name: "HelveticaNeue", size: clueFontSize)!)
        let rowsIndent = NSMutableParagraphStyle()
        rowsIndent.headIndent = 24
        rowsIndent.tabStops = [NSTextTab(type: .leftTabStopType, location: 24)]
        let rowsIndentAttrs = [NSAttributedString.Key.paragraphStyle: rowsIndent]

        let rowsHeaders = ["A", "B", "C", "D", "E", "F", "G", "H"]
        let cluesString = NSMutableAttributedString()
        if let notes = garden.notes {
            cluesString.append(NSAttributedString(string: "Note: \(notes)\n\n", attributes: italicAttrs))
        }
        let rowsString = NSMutableAttributedString()
        rowsString.append(NSMutableAttributedString(string: "ROWS\n", attributes: boldAttrs))
        for (i, row) in garden.rows.enumerated() {
            for (j, entry) in row.enumerated() {
                var expandedClue = entry.expandClue().clue
                expandedClue = expandedClue.replacingOccurrences(of: "_*", with: "_\u{115F}*")
                expandedClue = expandedClue.replacingOccurrences(of: "*_", with: "*\u{115F}_")
                let header = NSAttributedString(string: "\(rowsHeaders[i])\(j + 1).\t", attributes: boldAttrs)
                let clue = md.parse("\(expandedClue)\n")
                rowsString.append(header)
                rowsString.append(clue)
            }
        }
        rowsString.addAttributes(rowsIndentAttrs, range: NSRange(location: 0, length: rowsString.length))

        let bloomsIndent = NSMutableParagraphStyle()
        bloomsIndent.headIndent = 10
        bloomsIndent.tabStops = [NSTextTab(type: .leftTabStopType, location: 10)]
        let bloomsIndentAttrs = [NSAttributedString.Key.paragraphStyle: bloomsIndent]

        let bloomsString = NSMutableAttributedString(string: "\nLIGHT\n", attributes: boldAttrs)
        let light = sortHard(garden.light.map { $0.expandClue() })
        for clue in light {
            var expandedClue = clue
            // Add an invisible character to parse markdown correctly
            expandedClue = expandedClue.replacingOccurrences(of: "_*", with: "_\u{115F}*")
            expandedClue = expandedClue.replacingOccurrences(of: "*_", with: "*\u{115F}_")
            let parsed = NSMutableAttributedString(attributedString: md.parse("•\t\(expandedClue)\n"))
            bloomsString.append(parsed)
        }
        bloomsString.append(NSAttributedString(string: "\nMEDIUM\n", attributes: boldAttrs))
        let medium = sortHard(garden.medium.map { $0.expandClue() })
        for clue in medium {
            var expandedClue = clue
            expandedClue = expandedClue.replacingOccurrences(of: "_*", with: "_\u{115F}*")
            expandedClue = expandedClue.replacingOccurrences(of: "*_", with: "*\u{115F}_")
            let parsed = NSMutableAttributedString(attributedString: md.parse("•\t\(expandedClue)\n"))
            bloomsString.append(parsed)
        }
        bloomsString.append(NSAttributedString(string: "\nDARK\n", attributes: boldAttrs))
        let dark = sortHard(garden.dark.map { $0.expandClue() })
        for clue in dark {
            var expandedClue = clue
            expandedClue = expandedClue.replacingOccurrences(of: "_*", with: "_\u{115F}*")
            expandedClue = expandedClue.replacingOccurrences(of: "*_", with: "*\u{115F}_")
            let parsed = NSMutableAttributedString(attributedString: md.parse("•\t\(expandedClue)\n"))
            bloomsString.append(parsed)
        }
        bloomsString.addAttributes(bloomsIndentAttrs, range: NSRange(location: 0, length: bloomsString.length))
        cluesString.append(rowsString)
        cluesString.append(bloomsString)
        let cluesFramesetter = CTFramesetterCreateWithAttributedString(cluesString as CFAttributedString)
        let leftFrame = CTFramesetterCreateFrame(cluesFramesetter, CFRange(location: 0, length: 0), leftPath, nil)
        CTFrameDraw(leftFrame, context)
        let frameRange = CTFrameGetVisibleStringRange(leftFrame)
        let rightFrame = CTFramesetterCreateFrame(cluesFramesetter, CFRange(location: frameRange.length, length: 0), rightPath, nil)
        CTFrameDraw(rightFrame, context)

        context.endPDFPage()
        context.closePDF()

    }

    func sortHard(_ array: [RowsGarden.Entry]) -> [String] {
        let sorted: [String]
        if !easy {
            sorted = array.sorted(by: { lhs, rhs in
                let l = lhs.clue.trimmingCharacters(in: .alphanumerics.inverted)
                let r = rhs.clue.trimmingCharacters(in: .alphanumerics.inverted)
                return l < r
            }).map { $0.clue }
        } else {
            sorted = array.map { $0.clue }
        }
        return sorted
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
}

extension RowsGarden.Entry {
    func expandClue() -> RowsGarden.Entry {
        var expanded = clue
        let answerArray = answer.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
        if answerArray.count > 1 {
            expanded += " (\(answerArray.count) wds."
            if answer.contains("-") {
                expanded += ", hyph.)"
            } else {
                expanded += ")"
            }
        } else if answer.contains("-") {
            expanded += " (hyph.)"
        }
        return RowsGarden.Entry(clue: expanded, answer: answer)
    }
}
