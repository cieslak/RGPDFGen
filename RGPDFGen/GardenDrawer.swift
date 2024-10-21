//

import Foundation
import CoreGraphics

struct GardenDrawer {
    static func drawGarden(context: CGContext, rect: CGRect) {
        let light = CGColor(gray: 1.0, alpha: 1.0)
        let medium = CGColor(gray: 0.8, alpha: 1.0)
        let dark = CGColor(gray: 0.9, alpha: 1.0)
        let stroke = CGColor(gray: 0.0, alpha: 1.0)
        let colors = [[],
                      [light, light, light, medium, medium, medium, light, light, light, medium, medium, medium, light, light, light],
                      [light, light, light, dark, dark, dark, light, light, light, dark, dark, dark, light, light, light],
                      [medium, medium, medium, dark, dark, dark, medium, medium, medium, dark, dark, dark, medium, medium, medium],
                      [medium, medium, medium, light, light, light, medium, medium, medium, light, light, light, medium, medium, medium],
                      [dark, dark, dark, light, light, light, dark, dark, dark, light, light, light, dark, dark, dark, light, light, light],
                      [dark, dark, dark, medium, medium, medium, dark, dark, dark, medium, medium, medium, dark, dark, dark]]
        context.setStrokeColor(stroke)
        context.setLineWidth(1.0)
        context.setLineJoin(.bevel)
        let w, h: CGFloat
        w = (rect.width - 2.0) / 8.0
        h = (sqrt(3) * w) / 2.0
        var x = rect.origin.x
        var y = rect.origin.y
        for row in 0..<8 {
            if row == 0 {
                x = rect.origin.x + (w * 1.5) + 1.0
                for i in 0..<3 {
                    let r = CGRect(x: x, y: y, width: w, height: h)
                    i % 2 == 0 ? trianglePath(context, in: r) : invertedTrianglePath(context, in: r)
                    context.setFillColor(medium)
                    context.fillPath()
                    i % 2 == 0 ? trianglePath(context, in: r) : invertedTrianglePath(context, in: r)
                    context.strokePath()
                    x = x + (w / 2.0)
                }
                x = rect.origin.x + (w * 4.5) + 1.0
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
                x = rect.origin.x + 1.0
                continue
            }
            if row == 7 {
                x = rect.origin.x + (w * 1.5) + 1.0
                for i in 0..<3 {
                    let r = CGRect(x: x, y: y, width: w, height: h)
                    i % 2 == 0 ? invertedTrianglePath(context, in: r) : trianglePath(context, in: r)
                    context.setFillColor(medium)
                    context.fillPath()
                    i % 2 == 0 ? invertedTrianglePath(context, in: r) : trianglePath(context, in: r)
                    context.strokePath()
                    x = x + (w / 2.0)
                }
                x = rect.origin.x + (w * 4.5) + 1.0
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
                x = rect.origin.x + 1.0
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
            x = rect.origin.x + 1.0
        }
        context.setFillColor(stroke)
        let d = w / 5.0
        y = rect.origin.y + h
        for row in 0..<7 {
            let hasThree = row % 2 != 0
            x = hasThree ? (rect.origin.x + w + 1.0) : (rect.origin.x + w * 2.5 + 1.0)
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
