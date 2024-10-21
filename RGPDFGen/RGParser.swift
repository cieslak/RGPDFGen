import Foundation
import Yams

class RGParser {
    static func parse(filePath: String) -> RowsGarden? {
        let yamlString = try! String(contentsOfFile: filePath, encoding: .utf8)
        let yamlStringArray = yamlString.components(separatedBy: "\n")
        let correctedYAMLStringArray = yamlStringArray.map { line in
            var fixedLine = line
            if let colonMatch = fixedLine.firstMatch(of: /^( *[^:]+:)([^ ]..+)$/) {
                fixedLine = "\(colonMatch.1) \(colonMatch.2)"
            }
            if let escapeMatch = fixedLine.firstMatch(of: /^( *[^:]+: +)((?![>|]).+)$/) {
                var value = escapeMatch.2
                value = value.replacing(/"/, with: "\\\"")
                value = "\"\(value)\""
                fixedLine = "\(escapeMatch.1)\(value)"
            }
            return fixedLine
        }
        let correctedYAML = correctedYAMLStringArray.joined(separator: "\n")
        let decoder = YAMLDecoder()
        return try? decoder.decode(RowsGarden.self, from: correctedYAML)
    }
}
