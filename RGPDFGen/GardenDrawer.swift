//

import Foundation
import CoreGraphics
import CoreText

struct GardenDrawer {
    static func drawGarden(context: CGContext, rect: CGRect) {
        let light = CGColor(gray: 1.0, alpha: 1.0)
        let medium = CGColor(gray: 0.9, alpha: 1.0)
        let dark = CGColor(gray: 0.8, alpha: 1.0)
        let stroke = CGColor(gray: 0.0, alpha: 1.0)
        let colors = [[],
                      [dark, dark, dark, medium, medium, medium, dark, dark, dark, medium, medium, medium, dark, dark, dark],
                      [dark, dark, dark, light, light, light, dark, dark, dark, light, light, light, dark, dark, dark, light, light, light],
                      [medium, medium, medium, light, light, light, medium, medium, medium, light, light, light, medium, medium, medium],
                      [medium, medium, medium, dark, dark, dark, medium, medium, medium, dark, dark, dark, medium, medium, medium],
                      [light, light, light, dark, dark, dark, light, light, light, dark, dark, dark, light, light, light],
                      [light, light, light, medium, medium, medium, light, light, light, medium, medium, medium, light, light, light]]
        let headers = ["H", "G", "F", "E", "D", "C", "B", "A"]
        context.setStrokeColor(stroke)
        context.setLineWidth(1.0)
        context.setLineJoin(.bevel)
        let w, h: CGFloat
        w = (rect.width - 2.0) / 9.0
        h = (sqrt(3) * w) / 2.0
        var x = rect.origin.x
        var y = rect.origin.y + (h * 0.1)

        context.setFillColor(stroke)
//        context.addRect(rect)
//        context.fillPath()
        for row in 0..<8 {
            let r = CGRect(x: x, y: y , width: w * 0.75, height: w * 0.75)
            let path = CGPath(ellipseIn: r, transform: nil)
            context.addPath(path)
            context.fillPath()
            let r2 = CGRect(x: x + (w * 0.25), y: y + (w * 0.25), width: rect.width - (w * 0.25), height: h * 0.25)
            let path2 = CGPath(rect: r2, transform: nil)
            context.addPath(path2)
            context.fillPath()
            let titleString = NSMutableAttributedString(string: headers[row], attributes: [:])
            let path3 = CGMutablePath()
            path3.addRect(r)
            let framesetter = CTFramesetterCreateWithAttributedString(titleString as CFAttributedString)
            let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: titleString.length), path3, nil)
            CTFrameDraw(frame, context)
            y = y + h
        }
        y = rect.origin.y
        for row in 0..<8 {
            if row == 0 {
                x = rect.origin.x + (w * 1.5) + 1.0 + w
                for i in 0..<3 {
                    let r = CGRect(x: x, y: y, width: w, height: h)
                    i % 2 == 0 ? trianglePath(context, in: r) : invertedTrianglePath(context, in: r)
                    context.setFillColor(medium)
                    context.fillPath()
                    i % 2 == 0 ? trianglePath(context, in: r) : invertedTrianglePath(context, in: r)
                    context.strokePath()
                    x = x + (w / 2.0)
                }
                x = rect.origin.x + (w * 4.5) + 1.0 + w
                for i in 0..<3 {
                    let r = CGRect(x: x, y: y, width: w, height: h)
                    i % 2 == 0 ? trianglePath(context, in: r) : invertedTrianglePath(context, in: r)
                    context.setFillColor(medium)
                    context.fillPath()
                    i % 2 == 0 ? trianglePath(context, in: r) : invertedTrianglePath(context, in: r)
                    context.strokePath()
                    x = x + (w / 2.0)
                }
                y = y + h
                x = rect.origin.x + 1.0 + w
                continue
            }
            if row == 7 {
                x = rect.origin.x + (w * 1.5) + 1.0 + w
                for i in 0..<3 {
                    let r = CGRect(x: x, y: y, width: w, height: h)
                    i % 2 == 0 ? invertedTrianglePath(context, in: r) : trianglePath(context, in: r)
                    context.setFillColor(medium)
                    context.fillPath()
                    i % 2 == 0 ? invertedTrianglePath(context, in: r) : trianglePath(context, in: r)
                    context.strokePath()
                    x = x + (w / 2.0)
                }
                x = rect.origin.x + (w * 4.5) + 1.0 + w
                for i in 0..<3 {
                    let r = CGRect(x: x, y: y, width: w, height: h)
                    i % 2 == 0 ? invertedTrianglePath(context, in: r) : trianglePath(context, in: r)
                    context.setFillColor(medium)
                    context.fillPath()
                    i % 2 == 0 ? invertedTrianglePath(context, in: r) : trianglePath(context, in: r)
                    context.strokePath()
                    x = x + (w / 2.0)
                }
                y = y + h
                x = rect.origin.x + 1.0 + w
                continue
            }
            for col in 0..<15 {
                let r = CGRect(x: x, y: y, width: w, height: h)
                let isInverted = row % 2 == 0
                if isInverted {
                    col % 2 == 0 ? invertedTrianglePath(context, in: r) : trianglePath(context, in: r)
                } else {
                    col % 2 == 0 ? trianglePath(context, in: r) : invertedTrianglePath(context, in: r)
                }
                context.setFillColor(colors[row][col])
                context.fillPath()
                if isInverted {
                    col % 2 == 0 ? invertedTrianglePath(context, in: r) : trianglePath(context, in: r)
                } else {
                    col % 2 == 0 ? trianglePath(context, in: r) : invertedTrianglePath(context, in: r)
                }
                context.strokePath()
                x = x + (w / 2.0)
            }
            y = y + h
            x = rect.origin.x + 1.0 + w
        }
        context.setFillColor(stroke)
        let d = w / 5.0
        y = rect.origin.y + h
        for row in 0..<7 {
            let hasThree = row % 2 != 0
            x = hasThree ? (rect.origin.x + w + 1.0) + w : (rect.origin.x + w * 2.5 + 1.0) + w
            var path = dotPath(diameter: d, x: x, y: y)
            context.addPath(path)
            context.fillPath()
            x = x + (w * 3)
            path = dotPath(diameter: d, x: x, y: y)
            context.addPath(path)
            context.fillPath()
            if hasThree {
                x = x + (w * 3)
                path = dotPath(diameter: d, x: x, y: y)
                context.addPath(path)
                context.fillPath()
            }
            y = y + h
        }
    }

    private static func dotPath(diameter: CGFloat, x: CGFloat, y: CGFloat) -> CGPath {
        let r = CGRect(x: x - diameter / 2.0, y: y - diameter / 2.0, width: diameter, height: diameter)
        let path = CGPath(ellipseIn: r, transform: nil)
        return path
    }

    private static func trianglePath(_ ctx: CGContext, in rect: CGRect) {
        ctx.beginPath()
        ctx.move(to: CGPoint(x: rect.midX, y: rect.minY))
        ctx.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        ctx.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
    }

    private static func invertedTrianglePath(_ ctx: CGContext, in rect: CGRect) {
        ctx.beginPath()
        ctx.move(to: CGPoint(x: rect.minX, y: rect.minY))
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        ctx.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        ctx.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
    }
}
