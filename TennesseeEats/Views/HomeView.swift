import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var lastRandom: String?
    private let columns = [GridItem(.adaptive(minimum: 158), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                Button { model.openGuide(.all) } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").fontWeight(.bold).foregroundStyle(Theme.ink)
                        Text("Search by name, town or street").foregroundStyle(Theme.muted)
                        Spacer()
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 16).padding(.vertical, 13)
                    .background(Capsule().fill(Theme.surface))
                    .overlay(Capsule().strokeBorder(Theme.ink, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Search every restaurant")
                LazyVGrid(columns: columns, spacing: 12) {
                    // a guide with nothing in it yet (the hand-checked research lands guide by guide) gets no card
                    ForEach([Guide.hotChicken, .bbq, .wholeHog, .meatAndThree, .biscuits, .pancakes, .honors, .oldest, .nearMe]
                        .filter { $0 == .nearMe || model.count($0) > 0 }) { g in
                        Button { model.openGuide(g) } label: { GuideCard(guide: g, count: model.count(g)) }
                            .buttonStyle(.plain)
                    }
                }
                surpriseButton
                Text("Ratings, hours and photos come live from Apple Maps on each place. Lists are built from open map data, Metro Nashville's beer permits, the MICHELIN Guide, James Beard honors and hand-checked research. Inspection reports stay in the Department of Health's own search, linked on each place. See About for sources.")
                    .font(.footnote).foregroundStyle(Theme.muted)
            }
            .padding(16)
        }
        .background(Theme.sand)
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
    }

    /// A show poster: a small "Volunteer State" eyebrow, the title compressed and heavy with a hard red shadow, and the Grand Divisions
    /// band under it.
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill").font(.caption.weight(.bold)).foregroundStyle(Theme.gold)
                Text("THE VOLUNTEER STATE").monoFont(12).tracking(0.5).foregroundStyle(Theme.green)
            }
            .accessibilityHidden(true)
            Text("TENNESSEE EATS")
                .displayFont(72)
                .foregroundStyle(Theme.green)
                .lineLimit(1).minimumScaleFactor(0.6)
                .shadow(color: Theme.gold, radius: 0, x: 3, y: 3)
                .accessibilityLabel("Tennessee Eats")
                .accessibilityAddTraits(.isHeader)
            Stripes().padding(.bottom, 2)
            Text("HOT CHICKEN, BBQ & BISCUITS")
                .displayFont(23, weight: .heavy).foregroundStyle(Theme.ink)
            Text("MICHELIN and James Beard honors and \(model.restaurantCount.formatted()) restaurants in \(model.towns.count.formatted()) towns, from Memphis to Bristol.")
                .font(.subheadline).foregroundStyle(Theme.ink2)
        }
        .padding(.top, 8)
    }

    private var surpriseButton: some View {
        Button {
            if let p = model.randomClassic(excluding: lastRandom) {
                lastRandom = p.id
                // iPhone pushes it; iPad shows it in the place column (a growing stack there would resurface after a size change)
                if sizeClass != .regular { model.guidesPath.append(.place(p)) }
                model.selectedPlace = p
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "dice").font(.title3.weight(.semibold)).foregroundStyle(Theme.ink)
                    .frame(width: 44, height: 44).background(Circle().fill(Theme.goldSoft))
                Text("Surprise me with a Tennessee classic").font(.subheadline.weight(.bold))
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.green, style: StrokeStyle(lineWidth: 2, dash: [6, 4])))
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.ink)
    }
}

/// A guide as a color block: the count big in the monospaced face, the name compressed and heavy. The hand-checked Tennessee food guides
/// are flag red, the honors and oldest flag navy; the utility guides (near me, everything) stay white with an ink outline.
struct GuideCard: View {
    let guide: Guide
    let count: Int

    private var colors: (fill: Color, text: Color, number: Color) {
        switch guide {
        case .hotChicken, .bbq, .wholeHog, .meatAndThree, .biscuits, .pancakes: (Theme.gold, .white, .white)
        case .honors, .oldest: (Theme.green, .white, .white)
        default: (Theme.surface, Theme.ink, Theme.green)
        }
    }

    var body: some View {
        let c = colors
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                if guide != .nearMe && guide != .all {   // "All" would just repeat the total in the header; Near Me has no fixed count
                    Text(count.formatted()).monoFont(30).foregroundStyle(c.number)
                } else {
                    Image(systemName: guide.systemImage).font(.title2.weight(.semibold)).foregroundStyle(c.number)
                }
                Spacer()
            }
            Spacer(minLength: 4)
            Text(guide.title.uppercased()).displayFont(20, weight: .heavy).foregroundStyle(c.text).fixedSize(horizontal: false, vertical: true)
            Text(guide.subtitle).font(.caption.weight(.medium)).foregroundStyle(c.text.opacity(0.9)).fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 18).fill(c.fill))
        .overlay { if c.fill == Theme.surface { RoundedRectangle(cornerRadius: 18).strokeBorder(Theme.ink, lineWidth: 2) } }
        // one reading of the count, after the title ("Hot Chicken. Hand-checked …", "47 places")
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(guide.title). \(guide.subtitle)")
        .accessibilityValue(guide != .nearMe && guide != .all ? "\(count) \(count == 1 ? "place" : "places")" : "")
    }
}
