import SwiftUI
import UIKit
import CoreText

/// Tennessee flag palette (Nick's pick, 2026-10-24), light only: flag navy #002D72 (13.0:1 on white) for titles, tint and accents;
/// flag red #C8102E (5.9:1 on white, white on it 5.9:1) for the hand-checked Tennessee guide cards under white text and for MICHELIN
/// chips; amber #E8A33D only as a pin and card fill under dark text (never text). No team colors (UT orange, Memphis blue, Vanderbilt
/// gold, Titans, Predators). The names `green`/`gold` are kept from Wisconsin Eats so the shared views read the same; here `green` is
/// the flag navy and `gold` the flag red.
enum Theme {
    static let green = Color(hex: 0x002D72)      // flag navy: titles, tint, primary text accents
    static let green2 = Color(hex: 0x1D4A91)
    static let gold = Color(hex: 0xC8102E)       // flag red: card fills under white text, chips
    static let goldSoft = Color(hex: 0xF7DCE1)   // soft red
    static let lime = Color(hex: 0xE8A33D)       // amber, fills only (hand-checked pins), under dark text
    static let limeSoft = Color(hex: 0xFBEBC8)
    static let sand = Color(hex: 0xF3F5FA)       // the Home background, a cool off-white
    static let red = Color(hex: 0xC8102E)        // MICHELIN chips
    static let ink = Color(hex: 0x0F1B33)
    static let ink2 = Color(hex: 0x28375A)
    static let muted = Color(hex: 0x566079)
    static let surface = Color.white
    static let surface2 = Color(hex: 0xF2F4F8)
    static let surface3 = Color(hex: 0xE1E6EF)
    static let rule = Color(hex: 0xDCE2EC)
    static let rule2 = Color(hex: 0xB5C0D3)
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

/// A small uppercase label: "STONE CRAB", "1 MICHELIN STAR".
struct Chip: View {
    enum Style { case gold, green, red, plain, dashed }
    let text: String
    var style: Style = .plain

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(0.4)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .foregroundStyle(style == .green || style == .red ? Color.white : style == .dashed ? Theme.muted : style == .gold ? Theme.ink : Theme.green)
            .background {
                RoundedRectangle(cornerRadius: 5).fill(style == .gold ? Theme.goldSoft : style == .green ? Theme.green : style == .red ? Theme.red
                                                       : style == .dashed ? .clear : Theme.surface2)
            }
            .overlay {
                if style == .dashed { RoundedRectangle(cornerRadius: 5).strokeBorder(Theme.rule2, style: StrokeStyle(lineWidth: 1, dash: [3, 2])) }
            }
            .accessibilityLabel(text)
    }
}

/// Tennessee Eats' lettering: the system face drawn compressed and heavy for titles and guide names (like a show poster), and the
/// system monospaced face for numbers, dates and small labels. No bundled fonts.
struct DisplayFont: ViewModifier {
    let size: CGFloat
    var weight: Font.Weight = .black
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content.font(.system(size: size * min(scale, 1.6), weight: weight).width(.compressed))
    }
}

/// Numbers, dates and small labels in the system monospaced face, scaled like DisplayFont.
struct MonoFont: ViewModifier {
    let size: CGFloat
    var weight: Font.Weight = .semibold
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content.font(.system(size: size * min(scale, 1.6), weight: weight, design: .monospaced))
    }
}

extension View {
    func displayFont(_ size: CGFloat, weight: Font.Weight = .black) -> some View {
        modifier(DisplayFont(size: size, weight: weight))
    }

    func monoFont(_ size: CGFloat, weight: Font.Weight = .semibold) -> some View {
        modifier(MonoFont(size: size, weight: weight))
    }
}

/// The band under the Home title: the Grand Divisions, West, Middle and East Tennessee, as three navy bands split by red rules (the
/// flag's three stars stand for them), with a red rule along the top.
struct Stripes: View {
    var height: CGFloat = 6

    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height, top = max(2, h * 0.18), rule = max(2, w * 0.004)
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: top)), with: .color(Theme.red))
            for (k, c) in [Theme.green, Theme.green2, Color(hex: 0x3F67A8)].enumerated() {
                let x0 = w * CGFloat(k) / 3 + (k == 0 ? 0 : rule / 2), x1 = w * CGFloat(k + 1) / 3 - (k == 2 ? 0 : rule / 2)
                ctx.fill(Path(CGRect(x: x0, y: top, width: x1 - x0, height: h - top)), with: .color(c))
            }
            for k in 1...2 {
                ctx.fill(Path(CGRect(x: w * CGFloat(k) / 3 - rule / 2, y: top, width: rule, height: h - top)), with: .color(Theme.red))
            }
        }
        .frame(height: height * 3.4)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .accessibilityHidden(true)
    }
}

extension View {
    /// An inline navigation title in the display type. UINavigationBar.appearance() didn't reach every SwiftUI bar on iOS 27
    /// (the Map title went from compressed blue to plain black after a push and pop; place titles were always plain), so the
    /// title is our own view in the bar. The navigation title is still set, for the back button and VoiceOver.
    func inlineTitle(_ title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title).displayFont(19, weight: .heavy).foregroundStyle(Theme.green)
                        .lineLimit(1).minimumScaleFactor(0.7)
                        .accessibilityAddTraits(.isHeader)
                }
            }
    }
}
