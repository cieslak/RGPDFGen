//

import Foundation
import ArgumentParser
import CoreGraphics

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
        context.translateBy(x: 0.0, y: h)
        context.scaleBy(x: 1.0, y: -1.0)
        GardenDrawer.drawGarden(context: context, rect: CGRect(origin: CGPoint(x: 8, y: 8), size: CGSize(width: 612 - 16, height: 500)))
        context.endPDFPage()
        context.closePDF()



    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
}
