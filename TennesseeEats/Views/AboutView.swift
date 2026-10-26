import SwiftUI

struct AboutView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("TENNESSEE EATS").displayFont(32).foregroundStyle(Theme.green)
                    Text("A free guide to \(model.restaurantCount.formatted()) Tennessee restaurants, with MICHELIN and James Beard honors, Nashville's beer permits, and hand-checked lists of Tennessee's own food as they're checked. No account, no ads, no tracking.")
                        .font(.subheadline).foregroundStyle(Theme.ink2)
                    Text("Tennessee Eats is an independent app by Nicholas Soderstrom. It is not affiliated with, endorsed by or operated by the State of Tennessee, the Tennessee Department of Health, the Metropolitan Government of Nashville and Davidson County or its Beer Permit Board, any county health department, the MICHELIN Guide, the James Beard Foundation, Apple, or any restaurant or chain. Other names are trademarks of their owners.")
                        .font(.footnote).foregroundStyle(Theme.muted)
                }
                .padding(.vertical, 4)
            }
            Section("How the lists are built") {
                Text("Hand-checked lists (hot chicken, Memphis barbecue, whole hog, meat-and-threes, biscuits and country ham, Smokies pancake houses, oldest places) include only places checked against a 2025 or 2026 source (the place's own website or menu, local news or an official tourism listing), with the address checked. Founding years mean the year it opened at this address.")
                Text("Honors are the MICHELIN Guide American South's 2026 Tennessee selection (three one-star restaurants, Bib Gourmands and recommended places), James Beard Foundation winners, the 2026 nominee and semifinalists, and America's Classics.")
                Text("Tennessee publishes no list of its restaurants. This app starts from open map listings (Overture Maps) and keeps the kinds that proved reliable: checked against Nashville's beer permits, high-confidence listings held a permit far more often than the kinds left out. Metro Nashville's beer permits confirm Davidson County places, say which serve beer, and add ones the map data missed. Adult clubs are left out. Website links are checked, and any that no longer belong to the place are left out.")
                Text("The Tennessee Department of Health and the health departments of Davidson, Shelby, Knox, Hamilton and Madison counties post inspection reports, scored 0 to 100, in their own search. They aren't published as data, so this app shows no scores and computes no grade; each place links to the search.")
                Text("Ratings, reviews, hours and photos are Apple Maps' own, shown live in Apple's place card. This app doesn't store or rank by them.")
            }
            .font(.subheadline).foregroundStyle(Theme.ink2)
            Section("Sources") {
                source("Metro Nashville Beer Permit Board", "Beer Permit Locations, Nashville Open Data (data.nashville.gov), retrieved \(DayFormat.text(model.permitsUpdated) ?? model.permitsUpdated), modified for use in this app. Metro's terms: \u{201C}The Open Data should be used for informational purposes only. A user uses the Open Data at the user\u{2019}s own risk. The Open Data is made available \u{201C}as is\u{201D} without any warranties of any kind, including without limitation, implied warranties of merchantability, fitness for a particular purpose, workmanlike effort, and non-infringement. It is possible that the Open Data may contain errors, inaccuracies or typographical errors, which may be subsequently corrected.\u{201D} No approval by the Metropolitan Government is claimed.", Links.nashvillePermits.absoluteString)
                source("Tennessee Department of Health", "Inspection reports for all 95 counties, in the department's own search. Linked from each place; not copied.", Links.inspections.absoluteString)
                source("Overture Maps Foundation", "Restaurant listings and websites come from Overture Maps Foundation places data (overturemaps.org)\(model.overtureRelease.map { ", release \($0)" } ?? ""), filtered and reformatted for this app.\n• Data from Meta, Microsoft, DAC and BrightQuery. Available under CDLA Permissive 2.0.\n• Data from Foursquare. \(foursquareCopyright) Available under Apache 2.0. Foursquare data was transformed to the Overture schema; this app further filtered and reformatted it. See the NOTICE below.\n• Data from AllThePlaces. Available under CC0 1.0.\nResearched places are put on the map with Overture Maps addresses data (open address sources under permissive licenses, docs.overturemaps.org/attribution).", "https://overturemaps.org")
                source("Honors", "The MICHELIN Guide American South selection and James Beard Foundation awards, nominees, semifinalists and America's Classics are reported as facts and checked by hand against the official announcements. MICHELIN and the MICHELIN Guide are trademarks of Michelin. James Beard Foundation and James Beard Award are trademarks of the James Beard Foundation. Other names belong to their owners.", "https://guide.michelin.com/us/en/tennessee/restaurants")
                source("Maps", "Maps, place cards and directions by Apple Maps.", nil)
            }
            Section("Licenses") {
                NavigationLink("Community Data License Agreement – Permissive 2.0") { LicenseText(file: "CDLA-Permissive-2.0", title: "CDLA Permissive 2.0") }
                NavigationLink("Apache License 2.0") { LicenseText(file: "Apache-2.0", title: "Apache License 2.0") }
                NavigationLink("Foursquare OS Places NOTICE") { LicenseText(file: "Foursquare-NOTICE", title: "Foursquare NOTICE") }
            }
            Section("Privacy") {
                Text("The app collects nothing. Your location, if you allow it, only sorts lists by distance and shows where you are on the map, on this device. Saved places stay on this device.")
                    .font(.subheadline).foregroundStyle(Theme.ink2)
                DataUpdatesNote()
                    .font(.footnote).foregroundStyle(Theme.muted)
                Link("Privacy policy", destination: Links.privacy)
                Link("Terms of use", destination: Links.terms)
            }
            Section("Help") {
                Link("Report a missing or closed place", destination: Links.correctionEmail)
                Link("Email \(Links.supportEmail)", destination: URL(string: "mailto:\(Links.supportEmail)")!)
                Link("Website", destination: Links.site)
                Text("Data as of \(DayFormat.text(model.generated) ?? model.generated). Places open and close; check before you go. Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")")
                    .font(.footnote).foregroundStyle(Theme.muted)
            }
        }
        .navigationTitle("About")
        .tint(Theme.green)
    }

    /// the copyright line exactly as the bundled Foursquare NOTICE has it, so the two can't disagree
    private var foursquareCopyright: String {
        guard let url = Bundle.main.url(forResource: "Foursquare-NOTICE", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8),
              let line = text.split(separator: "\n").first(where: { $0.hasPrefix("©") }) else { return "© Foursquare Labs, Inc. All rights reserved." }
        return line.trimmingCharacters(in: .whitespaces)
    }

    @ViewBuilder
    private func source(_ name: String, _ detail: String, _ url: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let url, let u = URL(string: url) { Link(name, destination: u).font(.subheadline.weight(.semibold)) }
            else { Text(name).font(.subheadline.weight(.semibold)) }
            Text(detail).font(.caption).foregroundStyle(Theme.muted)
        }
    }
}

/// A bundled license text (Resources/Licenses), reflowed rather than shown as raw 80-column lines.
struct LicenseText: View {
    let file: String
    let title: String

    var body: some View {
        ScrollView {
            Text(text).font(.footnote).foregroundStyle(Theme.ink).textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading).padding()
        }
        .inlineTitle(title)
    }

    private var text: String {
        guard let url = Bundle.main.url(forResource: file, withExtension: "txt"),
              let raw = try? String(contentsOf: url, encoding: .utf8) else { return "License text missing." }
        // join hard-wrapped lines into paragraphs; keep blank lines and list items as breaks
        var out: [String] = []
        for para in raw.components(separatedBy: "\n\n") {
            let lines = para.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
            var joined = ""
            for l in lines where !l.isEmpty {
                let startsItem = l.hasPrefix("–") || l.hasPrefix("-") || l.range(of: #"^\(?[a-z0-9]{1,3}[.)]\s"#, options: .regularExpression) != nil
                joined += joined.isEmpty ? l : (startsItem ? "\n" + l : " " + l)
            }
            if !joined.isEmpty { out.append(joined) }
        }
        return out.joined(separator: "\n\n")
    }
}
