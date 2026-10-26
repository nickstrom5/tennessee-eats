// Tennessee Eats icon concepts for Nick's pick, in the shared Eats Ranked icon style (state-prompts/ICON-STYLE.md v1):
// one flat, level, centred food on a plain background; no scenery, tilt, texture, gloss or gradients.
// Usage (from tn-eats/): swift scripts/icon-concepts.swift   -> playbook/brand/concept-{a,b,c}-1024.png and -512, -180, -60 copies
//   A  Nashville hot chicken: a cayenne-red fried drumstick with pickle chips on a slice of white bread, on flag navy
//   B  Memphis dry-rub ribs: a short rack with its bone ends showing, on flag navy
//   C  country-ham biscuit: a split biscuit with a slice of country ham, on flag red
// Palette (the prompt's flag option): navy #002D72, red #C8102E. Food-only tones are listed per concept.
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let NAVY: UInt32 = 0x002D72, RED: UInt32 = 0xC8102E

// MARK: A, hot chicken on white bread (front view of the slice; a drumstick lies level across it). CoreGraphics y-up.
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

// MARK: B, dry-rub ribs (long food: side elevation). Slab 0.72 wide, taller at the left; bone ends below; seams between bones.
func ribs(_ c: CGContext, _ s: CGFloat) {
    let up: CGFloat = 0.03   // the bone ends hang below the slab, so the whole rack sits a little higher to keep the box centred
    func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: (y + up) * s) }
    func R(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect { CGRect(x: x * s, y: (y + up) * s, width: w * s, height: h * s) }
    let xs: [CGFloat] = [0.245, 0.375, 0.505, 0.635, 0.755]
    // bone ends first, so the slab's lower edge sits over them
    c.setFillColor(rgb(0xF4E7C9))
    for x in xs {
        let b = CGPath(roundedRect: R(x - 0.032, 0.25, 0.064, 0.16), cornerWidth: 0.032 * s, cornerHeight: 0.032 * s, transform: nil)
        c.addPath(b); c.fillPath()
    }
    let slab = CGMutablePath()
    slab.move(to: P(0.21, 0.35))
    slab.addLine(to: P(0.80, 0.37))
    slab.addQuadCurve(to: P(0.86, 0.43), control: P(0.86, 0.37))
    slab.addLine(to: P(0.86, 0.55))
    slab.addQuadCurve(to: P(0.80, 0.61), control: P(0.86, 0.61))
    slab.addLine(to: P(0.21, 0.66))
    slab.addQuadCurve(to: P(0.14, 0.59), control: P(0.14, 0.66))
    slab.addLine(to: P(0.14, 0.42))
    slab.addQuadCurve(to: P(0.21, 0.35), control: P(0.14, 0.35))
    slab.closeSubpath()
    c.setFillColor(rgb(0xB0532A)); c.addPath(slab); c.fillPath()
    // the bark on top: a lighter up-facing plane over the upper half, hard edge
    c.saveGState(); c.addPath(slab); c.clip()
    c.setFillColor(rgb(0xCE7238)); c.fill(R(0, 0.52, 1, 1))
    c.restoreGState()
    // seams between the bones: four darker round-cap strokes
    c.setStrokeColor(rgb(0x7E3518)); c.setLineWidth(0.036 * s); c.setLineCap(.round)
    for k in 0..<4 {
        let x = (xs[k] + xs[k + 1]) / 2
        c.move(to: P(x, 0.42)); c.addLine(to: P(x, 0.56)); c.strokePath()
    }
}

// MARK: C, country-ham biscuit (front elevation): straight-sided, flat-topped halves (a dome would read as a burger bun), a flaky
// layer line on the top half, a slice of country ham between. 0.70 wide.
func hamBiscuit(_ c: CGContext, _ s: CGFloat) {
    func R(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect { CGRect(x: x * s, y: y * s, width: w * s, height: h * s) }
    func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
    // bottom half: base tone over a darker baked bottom band (the seam tone)
    let bottom = CGPath(roundedRect: R(0.15, 0.255, 0.70, 0.16), cornerWidth: 0.045 * s, cornerHeight: 0.045 * s, transform: nil)
    c.setFillColor(rgb(0xF0BC62)); c.addPath(bottom); c.fillPath()
    c.saveGState(); c.addPath(bottom); c.clip()
    c.setFillColor(rgb(0xD4963A)); c.fill(R(0, 0, 1, 0.30))
    c.restoreGState()
    // country ham: a rose slice, a little wider than the biscuit, rounded ends
    let ham = CGPath(roundedRect: R(0.135, 0.41, 0.73, 0.07), cornerWidth: 0.035 * s, cornerHeight: 0.035 * s, transform: nil)
    c.setFillColor(rgb(0xE07A66)); c.addPath(ham); c.fillPath()
    // top half: straight sides, flat top with soft corners; a lighter up-facing top plane
    let top = CGPath(roundedRect: R(0.15, 0.475, 0.70, 0.265), cornerWidth: 0.07 * s, cornerHeight: 0.07 * s, transform: nil)
    c.setFillColor(rgb(0xF0BC62)); c.addPath(top); c.fillPath()
    c.saveGState(); c.addPath(top); c.clip()
    c.setFillColor(rgb(0xF8D894)); c.fill(R(0, 0.665, 1, 1))
    c.restoreGState()
    // a flaky layer line across the top half (one round-cap stroke in the seam tone)
    c.setStrokeColor(rgb(0xD4963A)); c.setLineWidth(0.036 * s); c.setLineCap(.round)
    c.move(to: P(0.24, 0.57)); c.addLine(to: P(0.76, 0.57)); c.strokePath()
}

// MARK: - main
let root = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent().deletingLastPathComponent().path
let out = root + "/playbook/brand"
try? FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)
func canvas(_ n: Int) -> CGContext {
    let c = CGContext(data: nil, width: n, height: n, bitsPerComponent: 8, bytesPerRow: 0,
                      space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    c.setAllowsAntialiasing(true); c.setShouldAntialias(true); c.interpolationQuality = .high
    return c
}
func save(_ img: CGImage, _ name: String) {
    let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out + "/" + name) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, nil)
    guard CGImageDestinationFinalize(dest) else { fatalError("could not write \(name)") }
}
for (key, bg, draw) in [("a", NAVY, hotChicken), ("b", NAVY, ribs), ("c", RED, hamBiscuit)] as [(String, UInt32, (CGContext, CGFloat) -> Void)] {
    let c = canvas(1024)
    c.setFillColor(rgb(bg)); c.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
    draw(c, 1024)
    let full = c.makeImage()!
    save(full, "concept-\(key)-1024.png")
    for n in [512, 180, 60] {
        let sm = canvas(n); sm.draw(full, in: CGRect(x: 0, y: 0, width: n, height: n)); save(sm.makeImage()!, "concept-\(key)-\(n).png")
    }
    print("wrote concept-\(key)")
}
