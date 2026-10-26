import Foundation
import CoreLocation
import UIKit

/// `-screenshot <name>` opens one screen with fixed state for App Store screenshots (scripts/capture-screenshots.sh).
/// Names: home, hot_chicken, bbq, honors, oldest, detail, map, saved, about.
enum ScreenshotMode {
    /// Debug builds only: an App Store build ignores the launch argument, so no one can reach seeded screens or fake locations.
    static var name: String? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screenshot"), i + 1 < args.count else { return nil }
        return args[i + 1]
        #else
        return nil
        #endif
    }
    static var isActive: Bool { name != nil }

    @MainActor
    static func apply(to model: AppModel) {
        guard let name, model.isLoaded else { return }
        model.filters = Filters()
        // downtown Nashville (Broadway at 2nd Ave), so "nearest" lists have distances without a permission prompt
        model.screenshotLocation = CLLocation(latitude: 36.1612, longitude: -86.7757)
        // by name and town, ignoring case, so a rebuild with a slightly different casing still finds the place; the hand-checked one first
        let pick = { (n: String, town: String?) -> Place? in
            let hits = model.places.filter { $0.name.caseInsensitiveCompare(n) == .orderedSame && (town == nil || $0.city == town) }
            return hits.first(where: \.handChecked) ?? hits.first
        }
        for p in [pick("Arnold's Country Kitchen", "Nashville"), pick("Peninsula", "Nashville"), pick("Hog & Hominy", "Memphis")]
            .compactMap({ $0 }) where !model.isSaved(p) {
            model.toggleSaved(p)
        }
        let open = { (g: Guide) in model.tab = .guides; model.selectedGuide = g; model.guidesPath = [.guide(g)] }
        switch name {
        case "hot_chicken": open(.hotChicken)
        case "bbq":
            // from downtown Memphis (Beale St at 2nd St)
            model.screenshotLocation = CLLocation(latitude: 35.1394, longitude: -90.0522)
            open(.bbq)
        case "honors": open(.honors)
        case "oldest": open(.oldest)
        case "detail":
            // Prince's on Nolensville Pike: hand-checked, an America's Classic, with its note
            open(.hotChicken)
            if let p = pick("Prince's Hot Chicken Shack", "Nashville") ?? pick("Arnold's Country Kitchen", "Nashville") ?? model.places.first {
                model.selectedPlace = p; model.guidesPath.append(.place(p))
            }
        case "map": model.tab = .map
        case "saved": model.tab = .saved
        case "about": model.tab = .about
        default: model.tab = .guides; model.selectedGuide = nil
        }
        // iPad shows the place column next to every list, so give each shot a place instead of "Pick a place": a different
        // honored or hand-checked one per shot.
        guard UIDevice.current.userInterfaceIdiom == .pad, model.selectedPlace == nil else { return }
        let place: Place? = switch name {
        case "home": pick("Arnold's Country Kitchen", "Nashville")
        case "hot_chicken": pick("Prince's Hot Chicken Shack", "Nashville")
        case "bbq": pick("Charlie Vergos' Rendezvous", "Memphis")
        case "map": pick("Peninsula", "Nashville")
        case "honors": pick("The Catbird Seat", "Nashville")
        case "saved": pick("Hog & Hominy", "Memphis")
        case "about": nil
        default: pick("Locust", "Nashville")
        }
        model.selectedPlace = place
    }
}
