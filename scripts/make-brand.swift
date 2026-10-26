// Tennessee Eats brand: the app icon (Nick's pick 2026-10-24: concept A of scripts/icon-concepts.swift, Nashville hot chicken, a
// cayenne-red fried drumstick with pickle chips on a slice of white bread, on flag navy; the shared Eats Ranked icon style,
// state-prompts/ICON-STYLE.md, no backing shape).
// Usage, from tn-eats/: swift scripts/make-brand.swift   -> TennesseeEats/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png,
// docs/ favicons and touch icons, docs/og.png. scripts/make-site.py draws the same mark as its inline SVG: change both together.
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let NAVY: UInt32 = 0x002D72, RED: UInt32 = 0xC8102E

/// Nashville hot chicken on white bread (front view of the slice; a drumstick lies level across it, pickle chips on top). CoreGraphics y-up.
func hotChicken(_ c: CGContext, _ s: CGFloat) {
    func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
    // a slice of white bread: a square body under a wider domed top, at 92% about the centre so coverage stays under 36%.
    // Crust #D99A52 shows as a band around the crumb.
    func slice(_ i: CGFloat) -> CGPath {
        func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: (0.5 + (x - 0.5) * 0.92) * s, y: (0.5 + (y - 0.5) * 0.92) * s) }
        let p = CGMutablePath()
        p.move(to: P(0.29 + i, 0.17 + i))
        p.addLine(to: P(0.71 - i, 0.17 + i))
        p.addQuadCurve(to: P(0.77 - i, 0.23 + i), control: P(0.77 - i, 0.17 + i))
        p.addLine(to: P(0.77 - i, 0.53))
        p.addCurve(to: P(0.50, 0.83 - i), control1: P(0.87 - i, 0.60), control2: P(0.80 - i, 0.83 - i))
        p.addCurve(to: P(0.23 + i, 0.53), control1: P(0.20 + i, 0.83 - i), control2: P(0.13 + i, 0.60))
        p.addLine(to: P(0.23 + i, 0.23 + i))
        p.addQuadCurve(to: P(0.29 + i, 0.17 + i), control: P(0.23 + i, 0.17 + i))
        p.closeSubpath()
        return p
    }
    c.setFillColor(rgb(0xD99A52)); c.addPath(slice(0)); c.fillPath()
    c.setFillColor(rgb(0xFFF8EC)); c.addPath(slice(0.04)); c.fillPath()
    // a fried drumstick, meaty end left, lying level across the slice: cayenne red with a darker underside band (light from
    // above), a cream bone with a two-knob end reaching past the bread. 13 px navy ring round the bone, which crosses the pale crumb.
    let meat = CGMutablePath()
    meat.move(to: P(0.70, 0.505))
    meat.addCurve(to: P(0.33, 0.625), control1: P(0.58, 0.55), control2: P(0.47, 0.625))
    meat.addCurve(to: P(0.14, 0.475), control1: P(0.21, 0.625), control2: P(0.14, 0.56))
    meat.addCurve(to: P(0.33, 0.325), control1: P(0.14, 0.39), control2: P(0.21, 0.325))
    meat.addCurve(to: P(0.70, 0.445), control1: P(0.47, 0.325), control2: P(0.58, 0.40))
    meat.closeSubpath()
    let bone = CGMutablePath()
    bone.addRoundedRect(in: CGRect(x: 0.64 * s, y: 0.448 * s, width: 0.18 * s, height: 0.054 * s), cornerWidth: 0.027 * s, cornerHeight: 0.027 * s)
    bone.addEllipse(in: CGRect(x: 0.775 * s, y: 0.468 * s, width: 0.083 * s, height: 0.083 * s))
    bone.addEllipse(in: CGRect(x: 0.775 * s, y: 0.400 * s, width: 0.083 * s, height: 0.083 * s))
    c.setStrokeColor(rgb(NAVY)); c.setLineWidth(0.026 * s); c.setLineJoin(.round); c.addPath(bone); c.strokePath()
    c.setFillColor(rgb(0xFFF8EC)); c.addPath(bone); c.fillPath()   // the crumb's cream: the ring keeps them apart
    c.setFillColor(rgb(0xC0391B)); c.addPath(meat); c.fillPath()
    c.saveGState(); c.addPath(meat); c.clip()
    c.setFillColor(rgb(0x8E2511)); c.fill(CGRect(x: 0, y: 0, width: s, height: 0.425 * s))
    c.restoreGState()
    // three pickle chips on the meaty end (one kind of mark, one colour, 0.10 across)
    c.setFillColor(rgb(0x8DB33A))
    for (x, y) in [(0.26, 0.52), (0.38, 0.545), (0.50, 0.52)] as [(CGFloat, CGFloat)] {
        c.fillEllipse(in: CGRect(x: (x - 0.05) * s, y: (y - 0.05) * s, width: 0.10 * s, height: 0.10 * s))
    }
}

func render(_ n: Int, _ path: String, background: Bool) {
    let ctx = CGContext(data: nil, width: n, height: n, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: background ? CGImageAlphaInfo.noneSkipLast.rawValue : CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setShouldAntialias(true)
    if background { ctx.setFillColor(rgb(NAVY)); ctx.fill(CGRect(x: 0, y: 0, width: n, height: n)) }
    hotChicken(ctx, CGFloat(n))
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
render(1024, "TennesseeEats/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png", background: true)
try? FileManager.default.createDirectory(atPath: "docs", withIntermediateDirectories: true)
for (n, name) in [(512, "icon-512.png"), (192, "icon-192.png"), (180, "apple-touch-icon.png"), (32, "favicon-32.png")] {
    render(n, "docs/" + name, background: true)
}

/// The share image (1200 x 630): flag navy, the hot chicken at the left, the name and tagline at the right, a red rule over three
/// navy bands along the bottom (the Grand Divisions band from the app's Home screen).
func og(_ path: String) {
    let W = 1200, H = 630
    let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setShouldAntialias(true)
    ctx.setFillColor(rgb(NAVY)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    for (k, hex) in [0x1D4A91, 0x2F5A9F, 0x3F67A8].enumerated() as EnumeratedSequence<[UInt32]> {
        ctx.setFillColor(rgb(hex)); ctx.fill(CGRect(x: CGFloat(k) * 400, y: 0, width: 400, height: 30))
    }
    ctx.setFillColor(rgb(RED)); ctx.fill(CGRect(x: 0, y: 30, width: W, height: 10))
    ctx.fill(CGRect(x: 398, y: 0, width: 4, height: 30)); ctx.fill(CGRect(x: 798, y: 0, width: 4, height: 30))
    ctx.saveGState(); ctx.translateBy(x: 30, y: 60); hotChicken(ctx, 540); ctx.restoreGState()
    let ns = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = ns
    let title = NSFont(name: "AvenirNextCondensed-Heavy", size: 84) ?? NSFont.boldSystemFont(ofSize: 76)
    let sub = NSFont(name: "AvenirNextCondensed-DemiBold", size: 38) ?? NSFont.boldSystemFont(ofSize: 34)
    NSAttributedString(string: "TENNESSEE EATS", attributes: [.font: title, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 560, y: 330))
    NSAttributedString(string: "HOT CHICKEN, BBQ & BISCUITS", attributes: [.font: sub, .foregroundColor: NSColor(srgbRed: 0.969, green: 0.863, blue: 0.882, alpha: 1)]).draw(at: NSPoint(x: 564, y: 272))
    NSGraphicsContext.restoreGraphicsState()
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
og("docs/og.png")
