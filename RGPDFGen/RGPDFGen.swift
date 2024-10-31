//

import Foundation
import ArgumentParser
import CoreGraphics
import CoreText

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
        GardenDrawer.drawGarden(context: context, rect: CGRect(origin: CGPoint(x: 50, y: h - 500), size: CGSize(width: 612 - 100, height: 500)))
        var x = 8.0
        var y = 8.0
        if let title = garden.title {
            var titleString = NSAttributedString(string: title)
            let path = CGMutablePath()
            path.addRect(CGRect(x: 16, y: 200, width: w - 16, height: 40))
            let framesetter = CTFramesetterCreateWithAttributedString(titleString as CFAttributedString)
            let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: titleString.length), path, nil)
            CTFrameDraw(frame, context)
            context.endPDFPage()
            context.closePDF()
        }
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
}
