import Foundation
import CoreLocation

/// The lists the app is built around. Each is a filter plus an order; none uses ratings (the app only publishes data it may).
enum Guide: String, CaseIterable, Identifiable, Hashable {
    case hotChicken, bbq, wholeHog, meatAndThree, biscuits, pancakes, honors, oldest, nearMe, all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hotChicken: "Hot Chicken"
        case .bbq: "Memphis Barbecue"
        case .wholeHog: "Whole Hog"
        case .meatAndThree: "Meat-and-Threes"
        case .biscuits: "Biscuits & Country Ham"
        case .pancakes: "Smokies Pancake Houses"
        case .honors: "MICHELIN & James Beard"
        case .oldest: "Oldest Places"
        case .nearMe: "Near Me"
        case .all: "All Restaurants"
        }
    }

    var subtitle: String {
        switch self {
        case .hotChicken: "Hand-checked Nashville hot chicken"
        case .bbq: "Hand-checked dry-rub ribs and barbecue spaghetti"
        case .wholeHog: "Hand-checked West Tennessee whole-hog pits"
        case .meatAndThree: "Hand-checked steam tables: one meat, three sides"
        case .biscuits: "Hand-checked biscuits and country ham"
        case .pancakes: "Hand-checked pancake houses in the Smokies"
        case .honors: "MICHELIN Guide and James Beard honorees"
        case .oldest: "Founding years checked at the same address, oldest first"
        case .nearMe: "Everything around you, closest first"
        case .all: "Restaurants, cafés, bars and bakeries statewide"
        }
    }

    var systemImage: String {
        switch self {
        case .hotChicken: "flame"
        case .bbq: "smoke"
        case .wholeHog: "fireplace"
        case .meatAndThree: "square.grid.2x2"
        case .biscuits: "sun.horizon"
        case .pancakes: "circle.circle"
        case .honors: "star.circle"
        case .oldest: "clock.arrow.circlepath"
        case .nearMe: "location"
        case .all: "fork.knife"
        }
    }

    /// The hand-checked Tennessee guides get the red card on Home.
    var isTennessee: Bool { tag != nil }

    /// Guides whose order is a ranking worth numbering.
    var isRanked: Bool { [.oldest].contains(self) }

    var sortOptions: [SortOrder] {
        switch self {
        case .hotChicken, .bbq, .wholeHog, .meatAndThree, .biscuits, .pancakes: [.featured, .nearest, .name]
        case .honors: [.iconic, .nearest]
        case .oldest: [.oldest]
        case .nearMe: [.nearest]
        case .all: [.name, .nearest]
        }
    }

    var defaultSort: SortOrder { sortOptions[0] }

    /// The tag behind a hand-checked guide.
    var tag: PlaceTags? {
        switch self {
        case .hotChicken: .hotChicken
        case .bbq: .bbq
        case .wholeHog: .wholeHog
        case .meatAndThree: .meatAndThree
        case .biscuits: .biscuits
        case .pancakes: .pancakes
        default: nil
        }
    }

    func includes(_ p: Place) -> Bool {
        if let tag {   // the guides that promise "hand-checked" list only places checked open with a 2025–26 source
            return p.handChecked && p.tags.contains(tag)
        }
        switch self {
        case .honors: return p.michelin != .none || p.jamesBeard != nil
        case .oldest: return p.founded != nil && p.tags.contains(.oldest)
        default: return true
        }
    }
}

enum SortOrder: String, CaseIterable, Identifiable {
    case featured, nearest, oldest, name, iconic
    var id: String { rawValue }
    var label: String {
        switch self {
        case .featured: "Featured first"
        case .nearest: "Nearest"
        case .oldest: "Oldest first"
        case .name: "A to Z"
        case .iconic: "MICHELIN, then James Beard"
        }
    }
}

/// Filters shared by every list. Search text lives with each list.
struct Filters: Equatable, Codable {
    var town: String?
    var cuisine: String?
    var hideChains = false
    var confirmedOnly = false
    var includeNonRestaurants = false
    var bibGourmand = false          // MICHELIN Bib Gourmand only: a fact from the Guide, not a rating

    var activeCount: Int {
        [town != nil, cuisine != nil, hideChains, confirmedOnly, includeNonRestaurants, bibGourmand].filter { $0 }.count
    }

    func allows(_ p: Place) -> Bool {
        if !includeNonRestaurants && p.isVenue { return false }
        if let town, p.city != town { return false }
        if let cuisine, p.cuisine != cuisine { return false }
        if hideChains && p.isChain { return false }
        if confirmedOnly && p.tier == .listing { return false }
        if bibGourmand && p.michelin != .bib { return false }
        return true
    }
}

extension Filters {
    /// Filters saved by an older build have no bibGourmand key: read what's there instead of dropping them all.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(town: try c.decodeIfPresent(String.self, forKey: .town),
                  cuisine: try c.decodeIfPresent(String.self, forKey: .cuisine),
                  hideChains: try c.decodeIfPresent(Bool.self, forKey: .hideChains) ?? false,
                  confirmedOnly: try c.decodeIfPresent(Bool.self, forKey: .confirmedOnly) ?? false,
                  includeNonRestaurants: try c.decodeIfPresent(Bool.self, forKey: .includeNonRestaurants) ?? false,
                  bibGourmand: try c.decodeIfPresent(Bool.self, forKey: .bibGourmand) ?? false)
    }
}

enum Ranking {
    static func sort(_ places: [Place], by order: SortOrder, from here: CLLocation?) -> [Place] {
        // Keys come from fields made once at load: a localized compare, or a new CLLocation per comparison, made a 16,000-place
        // sort take most of a second (AR-13). sortKey is the normalized name, so case, accents and punctuation don't change the order.
        func name(_ a: Place, _ b: Place) -> Bool { a.sortKey != b.sortKey ? a.sortKey < b.sortKey : a.id < b.id }
        switch order {
        case .nearest where here != nil:
            // each distance once, not four times per comparison
            let from = here!
            return places.map { p in (p, p.location.map { $0.distance(from: from) } ?? .greatestFiniteMagnitude) }
                .sorted { $0.1 != $1.1 ? $0.1 < $1.1 : name($0.0, $1.0) }
                .map(\.0)
        case .featured, .nearest:
            // honored places first, then verified founding year, then name
            return places.sorted {
                let a = $0.iconicPoints ?? -1, b = $1.iconicPoints ?? -1
                if a != b { return a > b }
                let fa = $0.founded ?? 9999, fb = $1.founded ?? 9999
                return fa != fb ? fa < fb : name($0, $1)
            }
        case .oldest:
            return places.sorted { ($0.founded ?? 9999) != ($1.founded ?? 9999) ? ($0.founded ?? 9999) < ($1.founded ?? 9999) : name($0, $1) }
        case .name:
            return places.sorted(by: name)
        case .iconic:
            // an order anyone can check: MICHELIN distinction, then the James Beard honor (America's Classic, winner, finalist, semifinalist), then name
            func jb(_ p: Place) -> Int { p.honorFlags & 1 != 0 ? 4 : p.honorFlags & 2 != 0 ? 3 : p.honorFlags & 4 != 0 ? 2 : p.honorFlags & 8 != 0 ? 1 : 0 }
            return places.sorted {
                if $0.michelin.rawValue != $1.michelin.rawValue { return $0.michelin.rawValue > $1.michelin.rawValue }
                if jb($0) != jb($1) { return jb($0) > jb($1) }
                return name($0, $1)
            }
        }
    }
}
