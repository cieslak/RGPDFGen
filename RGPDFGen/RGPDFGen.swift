//

import Foundation
import ArgumentParser
import CoreGraphics
import CoreText
import AppKit
import MarkdownKit

@main
struct RGPDFGen: ParsableCommand {
    @Option(name: [.short, .customLong("input")], help: "Input file path") var inputFile: String
    @Option(name: [.short, .customLong("output")], help: "Output file path") var outputFile: String
    @Option(name: [.short, .customLong("easy")], help: "Is easy level puzzle") var easy: Bool = true

    mutating func run() throws {
        let expandedInput = (inputFile as NSString).expandingTildeInPath
        guard let garden = RGParser.parse(filePath: expandedInput) else {
            throw RuntimeError("Couldn't parse '\(expandedInput)'")
        }
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
            let framesetter = CTFramesetterCreateWithAttributedString(titleString as CFAttributedString)
            let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
            CTFrameDraw(frame, context)

            let boldAttrs = [
                NSAttributedString.Key.font : NSFont(name: "HelveticaNeue-Bold", size: 12)!
            ]
            let leftPath = CGMutablePath()
            leftPath.addRect(CGRect(x: 32, y: 64, width: (w - 64) / 2 , height: 360 - 32).insetBy(dx: 8, dy: 0))
            let rightPath = CGMutablePath()
            rightPath.addRect(CGRect(x: 32 + ((w - 64) / 2), y: 64, width: (w - 64) / 2 , height: 360 - 32).insetBy(dx: 8, dy: 0))

            let md = MarkdownParser(font: NSFont(name: "HelveticaNeue", size: 12)!)
            let rowsIndent = NSMutableParagraphStyle()
            rowsIndent.headIndent = 22
            let rowsIndentAttrs = [ NSAttributedString.Key.paragraphStyle: rowsIndent]

            let rowsHeaders = ["A", "B", "C", "D", "E", "F", "G", "H"]
            let rowsString = NSMutableAttributedString(string: "ROWS\n", attributes: boldAttrs)
            for (i, row) in garden.rows.enumerated() {
                for (j, entry) in row.enumerated() {
                    let header = NSAttributedString(string: "\(rowsHeaders[i])\(j + 1). ", attributes: boldAttrs)
                    let clue = md.parse("\(entry.clue)\n")
                    rowsString.append(header)
                    rowsString.append(clue)
                }
            }
            rowsString.addAttributes(rowsIndentAttrs, range: NSRange(location: 0, length: rowsString.length))

            let bloomsIndent = NSMutableParagraphStyle()
            bloomsIndent.headIndent = 8
            let bloomsIndentAttrs = [ NSAttributedString.Key.paragraphStyle: bloomsIndent]

            let bloomsString = NSMutableAttributedString(string: "\nLIGHT\n", attributes: boldAttrs)
            let light = sortHard(garden.light)
            for clue in light {
                let parsed = NSMutableAttributedString(attributedString: md.parse("• \(clue)\n"))
                parsed.addAttributes(bloomsIndentAttrs, range: NSRange(location: 0, length: parsed.length))
                bloomsString.append(parsed)
            }
            bloomsString.append(NSAttributedString(string: "\nMEDIUM\n", attributes: boldAttrs))
            let medium = sortHard(garden.medium)
            for clue in medium {
                let parsed = NSMutableAttributedString(attributedString: md.parse("• \(clue)\n"))
                parsed.addAttributes(bloomsIndentAttrs, range: NSRange(location: 0, length: parsed.length))
                bloomsString.append(parsed)
            }
            bloomsString.append(NSAttributedString(string: "\nDARK\n", attributes: boldAttrs))
            let dark = sortHard(garden.dark)
            for clue in dark {
                let parsed = NSMutableAttributedString(attributedString: md.parse("• \(clue)\n"))
                parsed.addAttributes(bloomsIndentAttrs, range: NSRange(location: 0, length: parsed.length))
                bloomsString.append(parsed)
            }

            rowsString.append(bloomsString)
            let rowsFramesetter = CTFramesetterCreateWithAttributedString(rowsString as CFAttributedString)
            let rowsFrame = CTFramesetterCreateFrame(rowsFramesetter, CFRange(location: 0, length: 0), leftPath, nil)
            CTFrameDraw(rowsFrame, context)
            let frameRange = CTFrameGetVisibleStringRange(rowsFrame)
            let bloomsFrame = CTFramesetterCreateFrame(rowsFramesetter, CFRange(location: frameRange.length, length: 0), rightPath, nil)
            CTFrameDraw(bloomsFrame, context)
            context.endPDFPage()
            context.closePDF()
        }
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
