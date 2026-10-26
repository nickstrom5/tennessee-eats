import XCTest
import CoreLocation
@testable import TennesseeEats

@MainActor
final class TennesseeEatsTests: XCTestCase {

    /// A tiny core file and two region detail files with the same shape as Resources/places.json and Resources/detail-*.json.
    private func sampleModel() async throws -> AppModel {
        let json = """
        {"v":1,"generated":"2026-10-24","overture_release":"2026-10-21.0","permits_updated":"2026-10-24",
         "permits_url":"https://data.nashville.gov/datasets/44e9268cd0d548648980418dafdb42da",
         "cities":["Nashville","Memphis","Chattanooga","Knoxville","Gatlinburg","Nolensville"],
         "cuisines":["Chicken & Wings","BBQ","Soul & Southern","Burgers","Breakfast & Diner","Italian","German & European","American & Other"],
         "brands":["Krystal"],"counties":["Davidson County","Shelby County","Hamilton County","Knox County","Sevier County","Williamson County"],
         "regions":["Nashville & Middle Tennessee","Memphis & West Tennessee","Knoxville & the Smokies","Chattanooga & Southeast Tennessee","Tri-Cities & Northeast Tennessee"],
         "srcs":["official","meta","AllThePlaces","DAC","research"],
         "count":9,"count_restaurants":8,
         "calibration":{"Davidson County (beer permits, on premises)":{"listings":5303,"groups":{"meta_high":{"n":2004,"official":0.384}}}},
         "places":[
          {"id":"a","n":"Arnold's Country Kitchen","c":0,"co":0,"rg":0,"cu":2,"t":2,"s":1,"hc":1,"g":8,"a":"605 8th Ave S","z":"37203","la":36.1503,"lo":-86.7801,
           "h":1,"mi":1,"ip":76,"jbf":"America's Classic 2009","dish":"banana pudding; roast beef"},
          {"id":"b","n":"Prince's Hot Chicken Shack","c":0,"co":0,"rg":0,"cu":0,"t":1,"s":1,"hc":1,"g":1,"h":1,"jbf":"America's Classic 2013","a":"5814 Nolensville Pike","la":36.0700,"lo":-86.7240,
           "dish":"hot chicken"},
          {"id":"c","n":"Krystal","c":2,"co":2,"rg":3,"cu":3,"t":1,"s":2,"b":0,"ch":60,"la":35.05,"lo":-85.31},
          {"id":"d","n":"Charlie Vergos' Rendezvous","c":1,"co":1,"rg":1,"cu":1,"t":1,"s":1,"hc":1,"g":66,"f":1948,"a":"52 S 2nd St","la":35.1430,"lo":-90.0520},
          {"id":"e","n":"Weigel's","c":3,"co":3,"rg":2,"cu":7,"t":1,"s":1,"v":1,"la":35.96,"lo":-83.92},
          {"id":"f","n":"Hog & Hominy","c":1,"co":1,"rg":1,"cu":5,"t":1,"s":1,"hc":1,"mi":2,"ip":36,"a":"707 W Brookhaven Cir","la":35.1060,"lo":-89.8810},
          {"id":"g","n":"Peninsula","c":0,"co":0,"rg":0,"cu":6,"t":2,"s":1,"hc":1,"mi":2,"h":2,"liq":1,"ip":62,"jbf":"Best Chef: Southeast winner 2025 (Jake Howell)","a":"1035 W Eastland Ave","la":36.1810,"lo":-86.7430},
          {"id":"h","n":"Pancake Pantry","c":4,"co":4,"rg":2,"cu":4,"t":1,"s":1,"hc":1,"g":32,"a":"628 Parkway","la":35.7120,"lo":-83.5150},
          {"id":"i","n":"Nolensville Pizza Co","c":5,"co":5,"rg":0,"cu":7,"t":1,"s":1,"la":35.95,"lo":-86.67}
         ]}
        """
        let middle = """
        {"a":{"lic":[["Metro Nashville beer permit","07-18646"]],"ph":"(615) 256-4455","w":"arnoldscountrykitchen.com"},
         "b":{"w":"javascript:alert(1)"},
         "g":{"lic":[["Metro Nashville beer permit","17-25124"]]}}
        """
        let west = """
        {"f":{"w":"https://hogandhominy.com/"}}
        """
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("tn-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("places.json")
        try json.data(using: .utf8)!.write(to: url)
        try middle.data(using: .utf8)!.write(to: dir.appendingPathComponent("detail-nashville-middle-tennessee.json"))
        try west.data(using: .utf8)!.write(to: dir.appendingPathComponent("detail-memphis-west-tennessee.json"))
        let model = AppModel(defaults: UserDefaults(suiteName: "test-\(UUID().uuidString)")!)
        await model.load(from: url, detailFolder: dir)
        XCTAssertTrue(model.isLoaded, model.loadError ?? "")
        return model
    }

    func testDecodesAndHidesNonRestaurantsByDefault() async throws {
        let m = try await sampleModel()
        XCTAssertEqual(m.places.count, 9)
        XCTAssertEqual(m.restaurantCount, 8)
        XCTAssertFalse(m.list(.all, sort: .name, search: "", here: nil).contains { $0.name == "Weigel's" }, "a gas-station counter is hidden by default")
        m.filters.includeNonRestaurants = true
        XCTAssertTrue(m.list(.all, sort: .name, search: "", here: nil).contains { $0.name == "Weigel's" })
        XCTAssertEqual(m.permitsUpdated, "2026-10-24")
    }

    func testGuidesListOnlyWhatTheyPromise() async throws {
        let m = try await sampleModel()
        XCTAssertEqual(m.list(.hotChicken, sort: .name, search: "", here: nil).map(\.name), ["Prince's Hot Chicken Shack"])
        XCTAssertEqual(m.list(.bbq, sort: .name, search: "", here: nil).map(\.name), ["Charlie Vergos' Rendezvous"])
        XCTAssertEqual(m.list(.meatAndThree, sort: .name, search: "", here: nil).map(\.name), ["Arnold's Country Kitchen"])
        XCTAssertEqual(m.list(.pancakes, sort: .name, search: "", here: nil).map(\.name), ["Pancake Pantry"])
        XCTAssertEqual(m.list(.oldest, sort: .oldest, search: "", here: nil).map(\.name), ["Charlie Vergos' Rendezvous"])
        XCTAssertEqual(m.list(.honors, sort: .iconic, search: "", here: nil).map(\.name),
                       ["Peninsula", "Hog & Hominy", "Arnold's Country Kitchen", "Prince's Hot Chicken Shack"])
        XCTAssertEqual(m.list(.wholeHog, sort: .name, search: "", here: nil), [], "a guide with nothing hand-checked yet is empty, not padded")
    }

    /// "Serves beer" comes only from an on-site Metro Nashville permit; elsewhere it's unknown, never "no".
    func testServesBeerOnlyFromNashvillePermits() async throws {
        let m = try await sampleModel()
        XCTAssertTrue(m.place(id: "g")!.servesBeer)
        XCTAssertFalse(m.place(id: "a")!.servesBeer, "a beer permit that isn't on-site says nothing about serving beer")
        XCTAssertEqual(m.beerPermitCount, 1)
    }

    func testDatesAreCalendarDays() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let d = DayFormat.date("2026-06-16")!
        XCTAssertEqual(utc.dateComponents([.year, .month, .day], from: d), DateComponents(year: 2026, month: 6, day: 16))
        XCTAssertTrue(DayFormat.monthYear("2025-09-01")!.contains("2025"))
        XCTAssertNil(DayFormat.date("2026-13-01"))
        XCTAssertEqual(DayFormat.text("soon"), "soon", "a value that isn't a date is shown as it is")
    }

    func testRegionDetailsLoadOnDemand() async throws {
        let m = try await sampleModel()
        let v = await m.detail(for: m.place(id: "a")!)
        XCTAssertEqual(v?.licenses.first?.id, "07-18646")
        XCTAssertEqual(v?.licenses.first?.source, "Metro Nashville beer permit")
        XCTAssertEqual(v?.website?.absoluteString, "https://arnoldscountrykitchen.com", "a bare host gets https://")
        let b = await m.detail(for: m.place(id: "b")!)
        XCTAssertNil(b?.website, "a javascript: link never becomes a website button")
        let f = await m.detail(for: m.place(id: "f")!)
        XCTAssertEqual(f?.website?.host, "hogandhominy.com")
        XCTAssertEqual(AppModel.regionSlug("Knoxville & the Smokies"), "knoxville-the-smokies")
        let missing = await m.detail(for: m.place(id: "h")!)
        XCTAssertNil(missing, "a region with no detail file reads as no detail, not a crash")
    }

    func testSearchWordStartsTownsAndGuides() async throws {
        let m = try await sampleModel()
        XCTAssertEqual(m.list(.all, sort: .name, search: "prince", here: nil).map(\.name), ["Prince's Hot Chicken Shack"])
        XCTAssertEqual(m.list(.all, sort: .name, search: "memphis", here: nil).map(\.name), ["Charlie Vergos' Rendezvous", "Hog & Hominy"], "a town narrows to it")
        XCTAssertEqual(m.list(.all, sort: .name, search: "banana pudding", here: nil).map(\.name), ["Arnold's Country Kitchen"], "a dish finds who serves it")
        XCTAssertEqual(m.list(.all, sort: .name, search: "🍕", here: nil), [], "an emoji finds nothing, not everything")
        XCTAssertEqual(m.list(.all, sort: .name, search: "hot chicken", here: nil).map(\.name), ["Prince's Hot Chicken Shack"], "a guide word means the guide")
        XCTAssertEqual(m.list(.all, sort: .name, search: "nolensville pike", here: nil).map(\.name), ["Prince's Hot Chicken Shack"],
                       "a pike is a street: \u{201C}nolensville pike\u{201D} isn't the town of Nolensville")
        XCTAssertEqual(m.list(.all, sort: .name, search: "nolensville pk", here: nil).map(\.name), ["Prince's Hot Chicken Shack"], "Pk = Pike")
        XCTAssertEqual(m.list(.all, sort: .name, search: "nolensville", here: nil).map(\.name), ["Nolensville Pizza Co"], "the town alone is the town")
        XCTAssertEqual(m.list(.all, sort: .name, search: "vergos", here: nil).map(\.name), ["Charlie Vergos' Rendezvous"], "apostrophes don't matter")
    }

    func testOutsideTennesseeUsesTheOutline() {
        func inside(_ la: Double, _ lo: Double) -> Bool { TennesseeOutline.contains(CLLocationCoordinate2D(latitude: la, longitude: lo)) }
        XCTAssertTrue(inside(36.16, -86.78), "Nashville"); XCTAssertTrue(inside(35.15, -90.05), "Memphis"); XCTAssertTrue(inside(35.96, -83.92), "Knoxville")
        XCTAssertTrue(inside(35.05, -85.31), "Chattanooga"); XCTAssertTrue(inside(36.59, -82.19), "Bristol"); XCTAssertTrue(inside(36.47, -81.80), "Mountain City")
        XCTAssertTrue(inside(35.71, -83.51), "Gatlinburg"); XCTAssertTrue(inside(36.43, -89.06), "Union City")
        XCTAssertFalse(inside(33.75, -84.39), "Atlanta"); XCTAssertFalse(inside(38.25, -85.76), "Louisville"); XCTAssertFalse(inside(34.73, -86.59), "Huntsville")
        XCTAssertFalse(inside(34.26, -88.70), "Tupelo"); XCTAssertFalse(inside(35.60, -82.55), "Asheville"); XCTAssertFalse(inside(34.75, -92.29), "Little Rock")
        XCTAssertFalse(inside(37.33, -122.03), "Cupertino")
    }

    func testBundledData() async throws {
        let m = AppModel(defaults: UserDefaults(suiteName: "bundle-\(UUID().uuidString)")!)
        await m.load()
        XCTAssertTrue(m.isLoaded, m.loadError ?? "")
        XCTAssertGreaterThan(m.restaurantCount, 14_000)
        XCTAssertGreaterThanOrEqual(m.count(.honors), 45)
        XCTAssertEqual(m.bibCount, 12, "Tennessee's twelve Bib Gourmands (MICHELIN Guide American South 2026)")
        XCTAssertEqual(m.places.filter { $0.michelin == .oneStar }.map(\.name).sorted(), ["Bastion", "Locust", "The Catbird Seat"])
        // Germantown is a town, but "north germantown" also means N Germantown Pkwy, most of which runs through Cordova and Memphis
        let onParkway = m.places.filter { !$0.isVenue && Search.normalizeAddress($0.address ?? "").contains("n germantown") }
        let found = Set(m.list(.all, sort: .name, search: "north germantown", here: nil).map(\.id))
        XCTAssertGreaterThan(onParkway.filter { $0.city != "Germantown" }.count, 20)
        XCTAssertTrue(onParkway.allSatisfy { found.contains($0.id) }, "north germantown misses N Germantown Pkwy places")
        XCTAssertGreaterThan(m.beerPermitCount, 900, "Nashville's on-site beer permits")
        XCTAssertTrue(m.places.filter(\.servesBeer).allSatisfy { $0.county == "Davidson County" }, "beer permits are Davidson County's only")
        XCTAssertEqual(Set(m.places.map(\.id)).count, m.places.count, "ids are unique")
        for g in Guide.allCases where g.tag != nil {
            XCTAssertTrue(m.places.filter(g.includes).allSatisfy(\.handChecked), "\(g.title) lists only hand-checked places")
        }
        XCTAssertTrue(m.places.contains { $0.name == "Arnold's Country Kitchen" && $0.jamesBeardLabel == "America's Classic" })
        // the 2013 America's Classic belongs to the family's own South location, not the food-hall, airport or outlet-mall counters
        let princes = m.places.filter { $0.name.hasPrefix("Prince's Hot Chicken") && $0.jamesBeardLabel == "America's Classic" }
        XCTAssertEqual(princes.compactMap(\.address).map { $0.hasPrefix("5814 Nolensville") }, [true])
        // no Google-derived data: the data file has no rating, review or price fields at all
        let raw = try String(contentsOf: Bundle.main.url(forResource: "places", withExtension: "json")!, encoding: .utf8)
        for key in ["\"rating\"", "\"reviews\"", "\"price\"", "\"gmap_id\""] { XCTAssertFalse(raw.contains(key), "\(key) must not ship") }
    }

    /// Stable ids: md5(name + ~100 m cell)[:12], never a row number; every bundled region detail file decodes and its ids are core ids.
    func testIdsAndBundledDetailFiles() async throws {
        let m = AppModel(defaults: UserDefaults(suiteName: "ids-\(UUID().uuidString)")!)
        await m.load()
        XCTAssertTrue(m.places.allSatisfy { $0.id.count >= 12 && $0.id.prefix(12).allSatisfy(\.isHexDigit) && $0.id.dropFirst(12).allSatisfy { $0 == "x" } })
        let ids = Set(m.places.map(\.id))
        var permitted = 0
        for region in Set(m.places.compactMap(\.region)) {
            let url = try XCTUnwrap(Bundle.main.url(forResource: "detail-" + AppModel.regionSlug(region), withExtension: "json"), region)
            let d = try JSONDecoder().decode([String: PlaceDetail].self, from: Data(contentsOf: url))
            XCTAssertTrue(Set(d.keys).isSubset(of: ids), "\(region) detail ids are core ids")
            permitted += d.values.filter { $0.licenses.contains { $0.source == "Metro Nashville beer permit" && $0.id != nil } }.count
        }
        XCTAssertGreaterThan(permitted, 900, "Nashville places carry their beer permit number")
    }

    func testBundledDataGuards() async throws {
        let m = AppModel(defaults: UserDefaults(suiteName: "guards-\(UUID().uuidString)")!)
        await m.load()
        XCTAssertTrue(m.isLoaded, m.loadError ?? "")
        XCTAssertEqual(DataGuards.adultVenues(m.places), [], "no strip club under its name")
        XCTAssertEqual(DataGuards.badWebsites(try DataGuards.bundledLinks(m.places)), [], "no directory, Google or news page as a restaurant's website")
        XCTAssertEqual(DataGuards.badNames(m.places), [], "no visible name ending in \u{201C} the\u{201D} or \u{201C} of\u{201D}, or just \u{201C}The\u{201D}")
        XCTAssertEqual(DataGuards.legalNames(m.places), [], "no license holder entity name (\u{201C}… LLC\u{201D}) shown as a place's name")
        XCTAssertEqual(DataGuards.nonRestaurants(m.places), [], "no nail salon, senior home, gun store or gas station among the restaurants")
    }

    /// Each guard above fires on a copy of the bundled data broken the way QA found it elsewhere: a guard that can't fail guards nothing.
    func testGuardsCatchABrokenCopy() async throws {
        let raw = try Data(contentsOf: Bundle.main.url(forResource: "places", withExtension: "json")!)
        var file = try XCTUnwrap(JSONSerialization.jsonObject(with: raw) as? [String: Any])
        var places = try XCTUnwrap(file["places"] as? [[String: Any]])
        let idx = places.indices.filter { places[$0]["v"] == nil }.prefix(6).map { $0 }
        places[idx[2]]["n"] = "Baby Dolls Gentlemen's Club"
        places[idx[3]]["n"] = "Kitchen the"
        places[idx[4]]["n"] = "VOLUNTEER STATE HOSPITALITY GROUP LLC"
        places[idx[5]]["n"] = "Tipsy Nails & Spa"
        file["places"] = places
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("places-broken.json")
        try JSONSerialization.data(withJSONObject: file).write(to: url)
        let m = AppModel(defaults: UserDefaults(suiteName: "broken-\(UUID().uuidString)")!)
        await m.load(from: url)
        XCTAssertTrue(m.isLoaded, m.loadError ?? "")
        let id = idx.map { places[$0]["id"] as? String }
        func caught(_ found: [String], _ i: Int, _ what: String) {
            XCTAssertTrue(found.contains { $0.contains("[\(id[i] ?? "?")]") }, "the guard missed \(what)")
        }
        let links = [(name: "A", id: "x1", url: "https://www.yelp.com/biz/some-place"), (name: "B", id: "x2", url: "https://www.tennessean.com/story/entertainment/dining/a-story/"),
                     (name: "C", id: "x3", url: "https://smart.com/menu")]
        XCTAssertEqual(DataGuards.badWebsites(links).count, 2, "the guard catches a Yelp page and a news story, and not smart.com")
        caught(DataGuards.adultVenues(m.places), 2, "a gentlemen's club")
        caught(DataGuards.badNames(m.places), 3, "\u{201C}Kitchen the\u{201D}")
        caught(DataGuards.legalNames(m.places), 4, "a license holder's entity name")
        caught(DataGuards.nonRestaurants(m.places), 5, "a nail salon shown as a restaurant")
    }
}

/// Checks on the bundled data, written as functions so testGuardsCatchABrokenCopy can prove each one fires.
enum DataGuards {
    /// directories, Google and news sites: matched on the link's host, so "smart.com" isn't "rt.com"
    static let badHosts = #"^https?://([^/?#]*\.)?(yelp\.com|business\.site|google\.com|groupon\.com|yellowpages\.com|tripadvisor\.com|tennessean\.com|commercialappeal\.com|knoxnews\.com|timesfreepress\.com|nashvillescene\.com|memphisflyer\.com|wkrn\.com|wsmv\.com|newschannel5\.com|eater\.com|rt\.com)([:/?#]|$)"#

    static func badWebsites(_ links: [(name: String, id: String, url: String)]) -> [String] {
        links.compactMap { l in
            guard l.url.range(of: badHosts, options: [.regularExpression, .caseInsensitive]) != nil else { return nil }
            return "\(l.name) [\(l.id)]: \(l.url)"
        }
    }

    /// every website link in the bundled region detail files, with its place's name
    static func bundledLinks(_ places: [Place]) throws -> [(name: String, id: String, url: String)] {
        let names = Dictionary(places.map { ($0.id, $0.name) }, uniquingKeysWith: { a, _ in a })
        var out: [(name: String, id: String, url: String)] = []
        for region in Set(places.compactMap(\.region)) {
            guard let url = Bundle.main.url(forResource: "detail-" + AppModel.regionSlug(region), withExtension: "json") else { continue }
            for (id, d) in try JSONDecoder().decode([String: PlaceDetail].self, from: Data(contentsOf: url)) {
                if let w = d.website?.absoluteString { out.append((names[id] ?? "?", id, w)) }
            }
        }
        return out
    }

    static let adultNames = #"gentlem[ae]n['’]?s club|strip club|exotic dancer|\bmen['’]?s club|rick['’]?s cabaret|xtc cabaret|baby dolls|spearmint rhino|bikini bar|pt['’]?s showclub|showgirls|centerfolds|treasures? gentlem"#

    /// every permit or license number in the bundled region detail files, by place id
    static func bundledLicenses(_ places: [Place]) throws -> [String: [String]] {
        var out: [String: [String]] = [:]
        for region in Set(places.compactMap(\.region)) {
            guard let url = Bundle.main.url(forResource: "detail-" + AppModel.regionSlug(region), withExtension: "json") else { continue }
            for (id, d) in try JSONDecoder().decode([String: PlaceDetail].self, from: Data(contentsOf: url)) where !d.licenses.isEmpty {
                out[id] = d.licenses.compactMap(\.id)
            }
        }
        return out
    }

    static func adultVenues(_ places: [Place]) -> [String] {
        places.filter { $0.name.range(of: adultNames, options: [.regularExpression, .caseInsensitive]) != nil }.map { "\($0.name) [\($0.id)]" }
    }

    /// a name cut off after "the" or "of" ("Kitchen the", "Wines of") or nothing but "The", among the places shown by default
    static func badNames(_ places: [Place]) -> [String] {
        places.filter { p in
            let n = p.name.trimmingCharacters(in: .whitespaces).lowercased()
            return !p.isVenue && (n.hasSuffix(" the") || n.hasSuffix(" of") || n == "the")
        }.map { "\($0.name) [\($0.id)]" }
    }

    /// a license holder (owner) is never shown; a business name that's still a legal entity shouldn't be either
    static let legalSuffix = #"\b(llc|l\.l\.c|inc|corp|corporation)\.?$"#

    static func legalNames(_ places: [Place]) -> [String] {
        places.filter { !$0.isVenue && $0.name.range(of: legalSuffix, options: [.regularExpression, .caseInsensitive]) != nil }
            .map { "\($0.name) [\($0.id)]" }
    }

    /// businesses that aren't places to eat, among the places shown by default
    static let nonRestaurantNames = #"\bnails?\b|assisted living|gun (?:club|range|shop|store)|shooting range|firearms|petroleum|\bauto (?:repair|parts)\b"#

    static func nonRestaurants(_ places: [Place]) -> [String] {
        places.filter { !$0.isVenue && $0.name.range(of: nonRestaurantNames, options: [.regularExpression, .caseInsensitive]) != nil }
            .map { "\($0.name) [\($0.id)]" }
    }
}

/// pipeline/website_blocklist.json (hacked, taken-over, expired or another business's sites, confirmed by hand in the link sweeps):
/// no link on it may ship in any field of any JSON file the app bundles. The 2026-10-19 QA found the export had only filtered the
/// website field, or nothing, so hijacked links were still in the bundle. Read from the repo, so a new entry needs no code change.
final class LinkBlocklistTests: XCTestCase {
    func testNoBlocklistedLinkInBundledData() throws {
        let entries = try LinkBlocklist.entries()
        XCTAssertFalse(entries.isEmpty, "the blocklist is missing or empty")
        let files = LinkBlocklist.bundledJSON()
        XCTAssertFalse(files.isEmpty, "no bundled JSON found")
        var hits: [String] = []
        for url in files {
            let text = try String(contentsOf: url, encoding: .utf8)
            hits += LinkBlocklist.hits(in: text, entries).map { "\(url.lastPathComponent): \($0)" }
        }
        XCTAssertEqual(hits, [], "blocklisted links in the app's bundled data")
    }

    /// The guard fires on a copy of the bundled data broken three ways: a blocklisted domain, its subdomain, and a "url" entry.
    func testBlocklistGuardCatchesABrokenCopy() throws {
        let entries = try LinkBlocklist.entries()
        let file = try XCTUnwrap(LinkBlocklist.bundledJSON().max { (try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) ?? 0 < (try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) ?? 0 })
        let text = try String(contentsOf: file, encoding: .utf8)
        let domain = try XCTUnwrap(entries.first { ($0["match"] as? String ?? "domain") == "domain" }?["domain"] as? String)
        let fake: [[String: Any]] = entries + [["match": "url", "url": "https://example.org/hacked-page"]]
        let before = LinkBlocklist.hits(in: text, fake).count
        let broken = text + "{\"w\":\"https://www.\(domain)/menu\"}{\"src\":\"http://shop.\(domain)/\"}{\"w\":\"https://example.org/hacked-page/\"}"
        XCTAssertEqual(LinkBlocklist.hits(in: broken, fake).count, before + 3, "a domain, a subdomain and a url entry are all caught")
        XCTAssertEqual(LinkBlocklist.hits(in: "{\"w\":\"https://not\(domain)/\"}", entries), [], "a host that only ends with the domain's letters isn't it")
    }
}

enum LinkBlocklist {
    static func entries() throws -> [[String: Any]] {
        let url = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("pipeline/website_blocklist.json")
        return try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [[String: Any]])
    }

    /// every .json file in the app bundle, subfolders included
    static func bundledJSON() -> [URL] {
        let root = Bundle.main.bundleURL
        let all = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)?.allObjects as? [URL] ?? []
        return all.filter { $0.pathExtension == "json" && !$0.path.contains("/PlugIns/") }
    }

    private static func host(_ u: URLComponents) -> String {
        var h = (u.host ?? "").lowercased()
        if h.hasSuffix(".") { h.removeLast() }
        return h.hasPrefix("www.") ? String(h.dropFirst(4)) : h
    }

    private static func trimmedPath(_ p: String) -> String { p.hasSuffix("/") ? String(p.dropLast()) : p }

    /// the links in a JSON text that an entry covers: a "domain" entry its domain and subdomains, a "url" entry that page only
    static func hits(in text: String, _ entries: [[String: Any]]) -> [String] {
        let t = text.replacingOccurrences(of: "\\/", with: "/")
        let rx = try! NSRegularExpression(pattern: #"https?://[^"\s\\]+"#, options: [.caseInsensitive])
        return rx.matches(in: t, range: NSRange(t.startIndex..., in: t)).compactMap { m -> String? in
            let s = String(t[Range(m.range, in: t)!])
            guard let u = URLComponents(string: s) else { return nil }
            let h = host(u)
            for e in entries {
                if (e["match"] as? String ?? "domain") == "url" {
                    guard let v = URLComponents(string: e["url"] as? String ?? "") else { continue }
                    if !h.isEmpty && h == host(v) && trimmedPath(u.path) == trimmedPath(v.path) { return s }
                } else {
                    var d = (e["domain"] as? String ?? "").lowercased()
                    if let r = d.range(of: "://") { d = String(d[r.upperBound...]) }
                    d = String(d.split(separator: "/").first ?? "")
                    if d.hasPrefix("www.") { d = String(d.dropFirst(4)) }
                    if !d.isEmpty && (h == d || h.hasSuffix("." + d)) { return s }
                }
            }
            return nil
        }
    }
}

/// QA 2026-10-19, P1 3a: the support address is nick@eatsranked.com (Nick, 2026-10-12). The old Gmail address must not come back
/// anywhere in the app's source or bundled files.
final class SupportEmailTests: XCTestCase {
    func testSupportEmailIsEatsRanked() {
        XCTAssertEqual(Links.supportEmail, "nick@eatsranked.com")
    }

    func testNoGmailInAppSource() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("TennesseeEats")
        XCTAssertGreaterThan(SupportEmailScan.textFiles(under: root).count, 5, "the app's source folder wasn't found")
        XCTAssertEqual(SupportEmailScan.hits(under: root), [], "the app's source still has a Gmail address")
    }

    /// The guard fires on a broken copy: a folder with one planted Gmail address.
    func testGmailGuardCatchesABrokenCopy() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir.appendingPathComponent("App"), withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        try "static let supportEmail = \"someone@GMAIL.com\"\n".write(to: dir.appendingPathComponent("App/Links.swift"), atomically: true, encoding: .utf8)
        try "{\"ok\": \"nick@eatsranked.com\"}".write(to: dir.appendingPathComponent("App/data.json"), atomically: true, encoding: .utf8)
        XCTAssertEqual(SupportEmailScan.hits(under: dir), ["App/Links.swift"])
    }
}

enum SupportEmailScan {
    static let textExtensions: Set<String> = ["swift", "plist", "json", "strings", "xcstrings", "xcprivacy", "md", "txt", "html", "entitlements"]

    static func textFiles(under root: URL) -> [URL] {
        let all = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)?.allObjects as? [URL] ?? []
        return all.filter { textExtensions.contains($0.pathExtension.lowercased()) }
    }

    /// paths (relative to root) of text files that mention gmail.com, in any case
    static func hits(under root: URL) -> [String] {
        let base = root.resolvingSymlinksInPath().path + "/"
        return textFiles(under: root).compactMap { url in
            guard let text = try? String(contentsOf: url, encoding: .utf8),
                  text.range(of: "gmail.com", options: .caseInsensitive) != nil else { return nil }
            return url.resolvingSymlinksInPath().path.replacingOccurrences(of: base, with: "")
        }.sorted()
    }
}

/// QA 2026-10-19, P1 #13: outbound links ship without tracking tags (ref=google, referrer=google_food_ordering, cn_channel, utm_* …).
/// pipeline/tracking_params.py strips them in the export; these are the same rules.
final class TrackingParamTests: XCTestCase {
    func testNoTrackingParametersInBundledLinks() throws {
        let files = TrackingParams.bundledJSON()
        XCTAssertFalse(files.isEmpty, "no bundled JSON found")
        var hits: [String] = []
        for url in files {
            let text = try String(contentsOf: url, encoding: .utf8)
            hits += TrackingParams.tracked(in: text).map { "\(url.lastPathComponent): \($0)" }
        }
        XCTAssertEqual(hits, [], "links with tracking parameters in the app's bundled data")
    }

    /// The guard fires on a broken copy (four kinds of tracking tag, one in escaped JSON) and leaves a store's own parameters alone.
    func testTrackingGuardCatchesABrokenCopy() {
        let broken = #"[{"w":"https:\/\/places.example.com\/menu?ref=google"},{"w":"https://a.example/?utm_source=gmb&store=4"},"#
            + #"{"w":"https://b.example/x?referrer=google_food_ordering"},{"w":"https://c.example/order/1?cn_channel=cn_google"}]"#
        XCTAssertEqual(TrackingParams.tracked(in: broken).count, 4)
        let clean = #"[{"w":"https://order.example.com/menu?restaurantId=51&location=7"},{"w":"https://shop.example.com/?cid=12&ref=gs"}]"#
        XCTAssertEqual(TrackingParams.tracked(in: clean), [])
    }
}

enum TrackingParams {
    /// tracking by name, whatever the value
    static let keys = try! NSRegularExpression(pattern: #"^(?:utm[_-].*|gclid|gbraid|wbraid|dclid|fbclid|msclkid|mc_cid|mc_eid|_ga|_gl|igsh|"#
        + #"igshid|mibextid|srsltid|cn_channel|y_source|rwg_token|olonwp|ost_redirect_attribution|cmpid|yext_?.*)$"#, options: [.caseInsensitive])
    /// tracking only with these values
    static let values: [String: String] = ["ref": #"^(?:google|gmb|gbp|yext|bookmarks)\b"#, "referrer": "^google",
                                           "source": #"^(?:google|gmb|gbp|yext)\b"#, "cid": "^RF:YXT", "cmp": "^OKC-"]

    /// every .json file in the app bundle, subfolders included
    static func bundledJSON() -> [URL] {
        let all = FileManager.default.enumerator(at: Bundle.main.bundleURL, includingPropertiesForKeys: nil)?.allObjects as? [URL] ?? []
        return all.filter { $0.pathExtension == "json" && !$0.path.contains("/PlugIns/") }
    }

    static func isTracking(_ key: String, _ value: String) -> Bool {
        let k = key.trimmingCharacters(in: .whitespaces)
        if keys.firstMatch(in: k, range: NSRange(k.startIndex..., in: k)) != nil { return true }
        guard let pattern = values[k.lowercased()] else { return false }
        return value.trimmingCharacters(in: .whitespaces).range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// links in a JSON text whose query carries a tracking parameter
    static func tracked(in text: String) -> [String] {
        let t = text.replacingOccurrences(of: "\\/", with: "/")
        let rx = try! NSRegularExpression(pattern: #"https?://[^\s"'<>\\]+"#)
        return rx.matches(in: t, range: NSRange(t.startIndex..., in: t)).compactMap { m -> String? in
            let s = String(t[Range(m.range, in: t)!])
            guard let q = s.split(separator: "?", maxSplits: 1).dropFirst().first else { return nil }
            let query = q.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false).first ?? ""
            for part in query.split(separator: "&") {
                let kv = part.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
                let k = String(kv[0]).replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? String(kv[0])
                let v = kv.count > 1 ? (String(kv[1]).replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? String(kv[1])) : ""
                if isTracking(k, v) { return s }
            }
            return nil
        }
    }
}
