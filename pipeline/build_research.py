"""Writes data/research/app/*.json (hand-checked Tennessee guides) from the compact lists below. Ported from mi-eats.

Each entry cites the 2025-26 page that names it (robots-checked host: check_sources.py). Every page below is dated on its face. The
address comes from the map listing we already hold for that name in that town (site/tennessee.json), never from memory; a name that
isn't found exactly once in its town (or at the street number given) is left out and listed in data/research/app/LEADS.md. A place
the map data lacks is added only when the dated page prints its street address (ADDR).
Usage: ../.venv/bin/python build_research.py   (then tennessee.py)"""
import json, os, re
from brands import brand_of
from common import norm_name
ROOT = os.path.join(os.path.dirname(__file__), "..")
R = os.path.join(ROOT, "data", "research")
d = json.load(open(os.path.join(ROOT, "site", "tennessee.json")))
C, M = d["cols"], d["meta"]
norm = lambda s: re.sub(r"\s+", " ", re.sub(r"[^a-z0-9 ]", " ", (s or "").lower().replace("'", "").replace("’", ""))).strip()

# Tennessee Department of Tourist Development (tnvacation.com), each dated on the page
TN_HOT = "https://www.tnvacation.com/trip-inspiration/articles/nashville-hot-chicken"           # published 2025-08-06, updated 2026-04-06
TN_MEM = "https://www.tnvacation.com/trip-inspiration/articles/bbq-places-memphis"              # published 2025-10-13, updated 2026-05-08
TN_BBQ = "https://www.tnvacation.com/trip-inspiration/articles/made-tennessee-bucket-list-barbecue-spots"   # published 2025-10-15
TN_PAN = "https://www.tnvacation.com/trip-inspiration/articles/pancake-smoky-mountains"         # published 2025-08-01, updated 2026-07-31
TN_FOOD = "https://www.tnvacation.com/trip-inspiration/articles/food-tn-known"                  # published 2025-08-06, updated 2026-08-05
TN_BLACK = "https://www.tnvacation.com/trip-inspiration/articles/black-owned-restaurants-tennessee"   # published 2026-02-18, updated 2026-10-14
TN_BEALE = "https://www.tnvacation.com/articles/beale-street-food-guide"                        # published 2025-07-21, updated 2026-08-11
TN_NEW = "https://press.tnvacation.com/whats-new"                                                # release dated 2025-12-02
MARTINS = "https://www.martinsbbqjoint.com/visit"   # the restaurant's own locations page: six Tennessee locations with hours (2026-10)
MICH_ARNOLDS = "https://guide.michelin.com/us/en/tennessee/nashville_2790527/restaurant/arnold-s-country-kitchen"   # 2026 selection

# (name as the source writes it, town, street number to pick the location (or None), note, founded, founded_note, [sources])
GUIDES = {
 "hot chicken": [
  ("Prince's Hot Chicken Shack", "Nashville", "5814", "The family's South location on Nolensville Pike. Thornton Prince's hot chicken dates to the 1940s; the original shack was on Ewing Drive.", None, None, [TN_HOT, TN_BLACK]),
  ("Prince's Hot Chicken", "Nashville", "5055", "Prince's counter in Assembly Food Hall downtown.", None, None, [TN_HOT, TN_BLACK]),
  ("Prince's Hot Chicken", "Antioch", "4060", "Prince's at Tanger Outlets.", None, None, [TN_HOT, TN_BLACK]),
  ("Hattie B's Hot Chicken", "Nashville", "112", "Hattie B's on 19th Ave S in Midtown (the location the MICHELIN Guide lists).", None, None, [TN_HOT, TN_FOOD]),
  ("Hattie B's Hot Chicken", "Nashville", "2222", "Hattie B's in Melrose, 8th Ave S.", None, None, [TN_HOT, TN_FOOD]),
  ("Hattie B's Hot Chicken", "Nashville", "5209", "Hattie B's in The Nations, Charlotte Ave.", None, None, [TN_HOT, TN_FOOD]),
  ("Hattie B's Hot Chicken", "Nashville", "1206", "Hattie B's in East Nashville, Gallatin Ave.", None, None, [TN_HOT, TN_FOOD]),
  ("Hattie B's Hot Chicken", "Memphis", "596", "Hattie B's in Cooper-Young.", None, None, [TN_FOOD]),
  ("Bolton's Spicy Chicken & Fish", "Nashville", "624", "East Nashville; a dry rub instead of the usual oil-based paste.", None, None, [TN_HOT, TN_FOOD]),
  ("Pepperfire Hot Chicken", "Nashville", "5104", "Started in 2010 by Isaac Beard.", None, None, [TN_HOT]),
  ("Party Fowl", "Nashville", "2620", "Party Fowl in Donelson.", None, None, [TN_HOT]),
  ("Party Fowl", "Nashville", "2031", "Party Fowl near Vanderbilt.", None, None, [TN_HOT]),
  ("Helen's Hot Chicken", "Nashville", "1801", "Began as a small trailer; now on Jefferson Street.", None, None, [TN_HOT]),
  ("400 Degrees", "Nashville", "3704", "On Clarksville Pike.", None, None, [TN_HOT]),
  ("Lilly's Hot Chicken", "Nashville", "900", "Inside the Nashville Farmers' Market.", None, None, [TN_HOT]),
  ("Red's Hot Chicken", "Nashville", "115", "Family-owned.", None, None, [TN_HOT]),
 ],
 "memphis bbq": [
  ("Charlie Vergos' Rendezvous", "Memphis", "52", "Charcoal-grilled, dry-rub ribs in a basement off the alley across from the Peabody.", 1948, "Open since 1948 in its downtown basement (Tennessee Department of Tourist Development, 2025).", [TN_MEM, TN_BBQ, TN_BEALE]),
  ("Central BBQ", "Memphis", "2249", "The original Central BBQ (2002), known for pulled pork and barbecue nachos.", None, None, [TN_MEM, TN_BBQ, TN_BEALE]),
  ("Central BBQ", "Memphis", "4375", "Central BBQ on Summer Ave.", None, None, [TN_MEM, TN_BBQ]),
  ("Central BBQ", "Memphis", "147", "Central BBQ downtown, by the National Civil Rights Museum.", None, None, [TN_MEM, TN_BEALE]),
  ("Cozy Corner", "Memphis", "735", "Ribs and smoked Cornish hens.", None, None, [TN_MEM, TN_BBQ, TN_BLACK]),
  ("Payne's Bar-B-Que", "Memphis", "1762", "Chopped pork sandwiches with mustard slaw, ribs and smoked sausage.", None, None, [TN_MEM]),
  ("A&R Bar-B-Que", "Memphis", "1802", "Ribs, smoked sausage and barbecue spaghetti.", None, None, [TN_MEM, TN_BBQ]),
  ("The Bar-B-Q Shop", "Memphis", "1782", "Barbecue spaghetti and ribs with Dancing Pigs sauce.", None, None, [TN_MEM, TN_BBQ, TN_FOOD, TN_BLACK]),
  ("Jim Neely's Interstate Bar-B-Que", "Memphis", "2265", "The Neely family's original on South Third.", None, None, [TN_BBQ]),
  ("Corky's Ribs & BBQ", "Memphis", "5259", "Dry and wet ribs; the Poplar Ave original.", None, None, [TN_MEM]),
  ("BallHoggerz BBQ", "Memphis", "1404", "A newer spot: ribs, wings and brisket with its own dry rubs.", None, None, [TN_MEM]),
  ("Bain Barbecue", "Memphis", "993", "In Cooper-Young: brisket, ribs and pulled pork.", None, None, [TN_MEM]),
 ],
 "whole hog": [
  ("B.E. Scott's BBQ", "Lexington", "10880", "West Tennessee whole hog, hickory smoked.", None, None, [TN_BBQ]),
  ("Martin's Bar-B-Que Joint", "Nolensville", None, "Pat Martin's original. West Tennessee-style whole hog; a fresh hog goes on the pit each day.", None, None, [TN_BBQ, MARTINS]),
  ("Martin's Bar-B-Que Joint", "Nashville", "410", "Martin's downtown. West Tennessee-style whole hog.", None, None, [MARTINS]),
  ("Martin's Bar-B-Que Joint", "Nashville", "3108", "Martin's on Belmont Blvd. West Tennessee-style whole hog.", None, None, [MARTINS]),
  ("Martin's Bar-B-Que Joint", "Nashville", "2400", "Martin's in Midtown. West Tennessee-style whole hog.", None, None, [MARTINS]),
  ("Martin's Bar-B-Que Joint", "Mt. Juliet", "200", "West Tennessee-style whole hog.", None, None, [MARTINS]),
  ("Martin's Bar-B-Que Joint", "Spring Hill", "2076", "West Tennessee-style whole hog.", None, None, [MARTINS]),
 ],
 "meat and three": [
  ("Swett's", "Nashville", "2725", "Family-run soul food and meat-and-three on Clifton Ave.", 1954, "Serving since 1954 (Tennessee Department of Tourist Development, 2026).", [TN_BLACK]),
  ("Arnold's Country Kitchen", "Nashville", "605", "A classic meat-and-three, opened in 1982 by Jack and Rose Arnold.", None, None, [MICH_ARNOLDS]),
  ("Brooks Shaw's Old Country Store", "Jackson", "56", "The meat-and-three at Casey Jones Village.", None, None, [TN_FOOD]),
  ("Alcenia's", "Memphis", "317", "Soul-food plate lunches downtown.", None, None, [TN_FOOD]),
 ],
 "biscuits": [
  ("Loveless Cafe", "Nashville", "8400", "Biscuits with homemade preserves and country ham on Highway 100.", 1951, "Opened in 1951; 75 years in 2026 (Tennessee Department of Tourist Development, Dec 2025).", [TN_FOOD, TN_NEW]),
  ("Biscuit Love", "Nashville", "316", "Biscuit Love in the Gulch, which began as a food truck.", None, None, [TN_FOOD]),
  ("Biscuit Love", "Nashville", "2001", "Biscuit Love in Hillsboro Village.", None, None, [TN_FOOD]),
  ("Cumberland Biscuit Company", "McMinnville", "114", None, None, None, [TN_FOOD]),
  ("Aretha Frankensteins", "Chattanooga", "518", "Biscuits and pancakes on the North Shore.", None, None, [TN_FOOD]),
  ("Wellington's Restaurant", "Johnson City", "1216", None, None, None, [TN_FOOD]),
 ],
 "country ham": [
  ("Nick and J's Cafe", "Knoxville", "1526", "Country ham breakfasts in West Knoxville.", None, None, [TN_FOOD]),
  ("Stan's Country Restaurant", "Columbia", "1555", "Country ham and biscuits.", None, None, [TN_FOOD]),
 ],
 "pancakes": [
  ("Pancake Pantry", "Gatlinburg", "628", "Billed as Tennessee's first pancake house.", 1960, "Open since 1960 (Tennessee Department of Tourist Development, 2025).", [TN_PAN, TN_FOOD]),
  ("Log Cabin Pancake House", "Gatlinburg", "327", None, None, None, [TN_PAN, TN_FOOD]),
  ("Sawyer's Farmhouse Breakfast", "Pigeon Forge", "2831", None, None, None, [TN_PAN]),
  ("Flapjack's Pancake Cabin", "Gatlinburg", "146", None, None, None, [TN_PAN]),
  ("Flapjack's Pancake Cabin", "Gatlinburg", "478", None, None, None, [TN_PAN]),
  ("Flapjack's Pancake Cabin", "Gatlinburg", "956", None, None, None, [TN_PAN]),
  ("Flapjack's Pancake Cabin", "Pigeon Forge", "2734", None, None, None, [TN_PAN]),
  ("Flapjack's Pancake Cabin", "Sevierville", "1016", None, None, None, [TN_PAN]),
  ("Smoky Mountain Pancake House", "Pigeon Forge", "4050", None, None, None, [TN_PAN]),
  ("Five Oaks Farm Kitchen", "Sevierville", "1638", None, None, None, [TN_PAN]),
  ("Smoky's Pancake Cabin", "Pigeon Forge", "4235", "On the Parkway in Pigeon Forge.", None, None, [TN_PAN]),
  ("Elvira's Cafe", "Sevierville", "4143", None, None, None, [TN_FOOD]),
 ],
 "oldest": [   # a founding year the dated page ties to the place as it stands; relocated places (Leonard's, Dyer's) are left out
  ("Bozo's Hot Pit Bar-B-Q", "Mason", "342", "West Tennessee barbecue on Highway 70 in Mason.", 1923, "Since 1923 (Tennessee Department of Tourist Development, 2025).", [TN_BBQ]),
  ("The Four Way", "Memphis", "998", "Soul food on Mississippi Blvd in Soulsville.", 1946, "Serving since 1946 (Tennessee Department of Tourist Development, 2026).", [TN_BLACK]),
 ],
}
# street addresses as the dated page prints them, for places the map data lacks
ADDR = {"Lilly's Hot Chicken": "900 Rosa L Parks Blvd", "Martin's Bar-B-Que Joint": "7223 Nolensville Rd"}
KINDS = {"hot chicken": ["hot chicken"], "memphis bbq": ["memphis bbq"], "whole hog": ["whole hog"], "meat and three": ["meat and three"],
         "biscuits": ["biscuits"], "country ham": ["country ham"], "pancakes": ["pancakes"], "oldest": ["oldest"]}


def key(s):
    """The name key without a leading "the": "Loveless Cafe" is our "The Loveless Cafe"."""
    return re.sub(r"^the ", "", norm(s))


def find(name, town, num):
    k = key(name)
    hits = [i for i, n in enumerate(C["name"]) if C["city"][i] is not None and M["cities"][C["city"][i]] == town
            and (key(n) == k or key(n).startswith(k + " ") or k.startswith(key(n) + " ") or key(n).replace(" ", "") == k.replace(" ", "")
                 or (key(n).split()[:2] == k.split()[:2] and len(k.split()) >= 2))]
    if num:
        hits = [i for i in hits if (C["addr"][i] or "").split(" ")[0] == num]
    return hits


leads, n_out = [], {}
for kind, rows in GUIDES.items():
    out = []
    for name, town, num, note, founded, fnote, srcs in rows:
        hits = find(name, town, num)
        if not hits and name in ADDR:
            out.append({"name": name, "address": ADDR[name], "city": town, "zip": None, "kinds": KINDS[kind], "dishes": [], "note": note,
                        "founded": founded, "founded_note": fnote, "website": None, "open": True, "evidence_date": "2026-10",
                        "sources": srcs, "match_names": []})
            continue
        if len(hits) != 1:
            leads.append(f"- {kind}: {name} ({town}{', ' + num if num else ''}) — {len(hits)} matches in our data; not added"); continue
        i = hits[0]
        out.append({"name": C["name"][i], "address": C["addr"][i], "city": town, "zip": str(C["zip"][i]) if C["zip"][i] else None,
                    "kinds": KINDS[kind], "dishes": [], "note": note, "founded": founded, "founded_note": fnote, "website": None, "open": True,
                    "evidence_date": "2026-10", "sources": srcs, "match_names": [name.upper()] if norm(name) != norm(C["name"][i]) else []})
        if brand_of(norm_name(name)):   # a chain shows under its own spelling at every branch ("Hattie B's Hot Chicken"), whatever the listing says
            out[-1]["display"] = name
    fn = re.sub(r"[^a-z]+", "_", kind).strip("_")
    json.dump(out, open(f"{R}/app/{fn}.json", "w"), indent=1, ensure_ascii=False)
    n_out[kind] = len(out)

open(f"{R}/app/LEADS.md", "w").write("# Tennessee research leads (not yet verified)\n\nWritten by pipeline/build_research.py.\n\n" + "\n".join(leads) + """

## Waiting for a 2025-26 source we may use
- The Barn at Blackberry Farm (Walland): Joseph Lenn's 2013 Best Chef: Southeast win. A resort dining room: confirm on blackberryfarm.com
  whether people who aren't staying can book before listing the honor there (Lenn now runs J.C. Holdway, which carries his 2026
  semifinalist line).
- Helen's Bar-B-Q (Brownsville), Scott's-Parker's (Lexington; B.E. Scott's is in), Leonard's Pit Barbecue (Memphis, 1922 but moved; our
  data's Germantown Pkwy listing may be stale), Monell's (Germantown) and Silver Sands Cafe (meat-and-threes): only pre-2025 sources found.
- The Arcade (Memphis, 540 S Main St): "Memphis' oldest cafe" on a 2025 state page, but its 1919 founding is only in 2019 press.
- Chandler's (Knoxville meat-and-three) and Porcellino's Craft Butcher (Memphis country ham) aren't in our map data as places to eat.
- Varallo's (Nashville's oldest, a chili parlor since 1907) has moved; Dyer's Burgers (1912) moved to Beale St in 2004.
- Smokies pancake houses beyond the state's list (Little House of Pancakes, Crockett's Breakfast Camp, Reagan's House of Pancakes) need a
  dated source; gatlinburg.com listing pages carry only a copyright year.
- tennessean.com, commercialappeal.com, knoxnews.com, timesfreepress.com, eater.com and most TV station sites block Claude: never cited.
""")
print(n_out, "| leads:", len(leads))
