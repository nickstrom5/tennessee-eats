#!/usr/bin/env python3
"""Writes the App Store listing and the App Review reply from the build's own counts (playbook/site-numbers.json, which
scripts/make-site.py rewrites on every run), so the copy never drifts from the data. Ported from mi-eats (modeled on wa-eats/playbook/06
and 13).

Usage (from tn-eats/): .venv/bin/python scripts/make-listing.py   (after make-site.py)
Writes playbook/06-app-store-listing.md, playbook/13-app-review-reply.md and playbook/app-store/listing.json (what
../scripts/asc_listing.py uploads once Nick creates the App Store Connect record and its FOLDERS line is added).
Checks before writing anything: Apple's length limits, no keyword repeating a name/subtitle word, no "best"/"top"/"#1", no price
claim outside the description's plain "free guide", the reply under 4,000 characters.
"""
import json, os, re, sys

ROOT = os.path.join(os.path.dirname(__file__), "..")
N = json.load(open(os.path.join(ROOT, "playbook", "site-numbers.json")))
R, T, LIC, HON, BEER = N["restaurants"], N["towns"], N["on_an_official_list"], N["honors"], N["serves_beer_nashville"]
MI, JBF = N["michelin"], N["james_beard"]
G = {k[6:]: v for k, v in N.items() if k.startswith("guide_") and isinstance(v, int)}
OLD = N["oldest"]
FLOOR = R // 1000 * 1000   # "14,000+": promo text and What's New outlive small data changes
SITE = "https://tennessee.eatsranked.com/"   # until the CNAME resolves: https://nickstrom5.github.io/tennessee-eats/

NAME = "Tennessee Eats: Restaurants"
SUB = "Hot Chicken, BBQ & Biscuits"
# no word from the name or subtitle; towns are the biggest search win (rotate after a month of App Store Connect search-term data)
KW = "nashville,memphis,knoxville,chattanooga,gatlinburg,pigeon forge,smokies,barbecue,meat and three,hog"
PROMO = (f"{G['hotchicken']} hot chicken spots, {G['bbq']} Memphis barbecue joints, whole hog pits and meat-and-threes, each checked "
         f"by hand. Plus {FLOOR:,}+ Tennessee restaurants near you.")
WHATS_NEW = f"First release: Nashville hot chicken, Memphis barbecue, whole hog, meat-and-threes and {FLOOR:,}+ Tennessee restaurants."

DESC = f"""Tennessee's restaurants, from a plate of Nashville hot chicken to a Memphis rack of dry-rub ribs.

Tennessee Eats is a free guide to eating in Tennessee: {G['hotchicken']} hot chicken spots, {G['bbq']} Memphis barbecue joints, {G['wholehog']} whole hog pits, {G['meat3']} meat-and-threes, {G['biscuits']} biscuit and country ham places and {G['pancakes']} Smokies pancake houses we checked by hand, plus {R:,} restaurants, cafés, bars and bakeries in {T} towns, from Memphis and Nashville to Chattanooga, Knoxville and the Tri-Cities. No account, no ads.

TENNESSEE GUIDES
• Hot Chicken: Nashville's cayenne-fired fried chicken on white bread, from the shack that started it.
• Memphis Barbecue: dry-rub ribs, pulled pork and barbecue spaghetti.
• Whole Hog: the West Tennessee pits that still cook the whole hog.
• Meat-and-Threes: one meat, three sides, off a steam table.
• Biscuits & Country Ham: breakfast the Tennessee way.
• Smokies Pancake Houses: Gatlinburg and Pigeon Forge's pancake breakfasts.
• Oldest Places: {OLD} restaurants open at the same address since 1960 or earlier.
• MICHELIN & James Beard: the MICHELIN Guide's {MI.get('1 MICHELIN Star', 0)} one-star restaurants, {MI.get('Bib Gourmand', 0)} Bib Gourmands and Recommended places, and James Beard winners, nominees, semifinalists and America's Classics ({HON} places).

FIND IT FAST
• Sort by distance, or browse the map by guide.
• Search by name, town, street or dish: "nolensville pike", "hot chicken memphis".
• Filter by town or cuisine, show Bib Gourmands only, or hide chains.
• Save places, and find hand-checked places from iPhone search (Spotlight).

LIVE DETAILS FROM APPLE MAPS
Tap "Ratings, hours & photos" on any place to open Apple Maps' own place card, with current hours, photos, ratings and directions.

HOW THE LISTS ARE BUILT
Every guide place was checked by hand in October 2026 against a 2025 or 2026 source: the place's own site or menu, dated local news or an official tourism listing. The rest come from Overture Maps open data, checked against Metro Nashville's beer permits, which also say which {BEER:,} Davidson County places serve beer. Each place links to the Tennessee Department of Health's own inspection search. Website links are checked too. Nothing is ranked by star ratings, and the app computes no grades.

PRIVATE BY DESIGN
No account, no tracking, no ads. Your location, if you share it, only sorts lists on your device. Saved places stay on your device.

Places open and close, so check before you go. Spot a mistake? Email nick@eatsranked.com.

An independent app, not affiliated with any restaurant, chain or government agency (including the State of Tennessee, the Tennessee Department of Health and the Metropolitan Government of Nashville and Davidson County), or with the MICHELIN Guide or the James Beard Foundation. MICHELIN and the MICHELIN Guide are trademarks of Michelin. James Beard Foundation and James Beard Award are trademarks of the James Beard Foundation. Place data from Overture Maps Foundation (CDLA Permissive 2.0) and others; sources and licenses are on the About tab."""

REPLY = f"""Thank you. Here is the information requested. A screen recording from an iPhone running the latest iOS is attached. It starts at launch and shows the full flow.

1. Screen recording: attached. There is no account, login, user-generated content or paid content.

2. Purpose and audience: Tennessee Eats is a free guide to restaurants in Tennessee. Its focus is the state's food traditions: {G['hotchicken']} Nashville hot chicken spots, {G['bbq']} Memphis barbecue joints, {G['wholehog']} whole hog pits, {G['meat3']} meat-and-threes, {G['biscuits']} biscuit and country ham places and {G['pancakes']} Smokies pancake houses, each checked by hand in October 2026 against a 2025 or 2026 source, plus the MICHELIN Guide and James Beard honorees. It also lists {R:,} restaurants, cafés and bars statewide from open map data, checked against Metro Nashville's beer permit list. It is for Tennessee residents and visitors deciding where to eat, with no ads, account or tracking.

3. How to use it (no login, no setup, no sample files needed):
- Home → Hot Chicken (or Memphis Barbecue, Whole Hog, Meat-and-Threes, Biscuits & Country Ham, Smokies Pancake Houses, MICHELIN & James Beard, Oldest Places, Near Me) → tap any place.
- On a place, tap "Ratings, hours & photos" to open Apple Maps' own place card through MapKit. Directions, Call and Website are below it; further down, a link opens the Tennessee Department of Health's inspection search in Safari.
- Search from the Home search box by name, town, street or dish ("nolensville pike", "hot chicken memphis").
- The Map tab shows each guide as pins. "My location" and the Nearest sort use location only if allowed, on the device.
- The heart saves a place on the device, under the Saved tab. The About tab lists the data sources, licenses and the independence statement.
- On iPad, a sidebar replaces the tabs; a place opens in the right-hand column.
- Location: if you're outside Tennessee (as App Review usually is), the map says so and stays on Tennessee, and distance sorting still works from where you are.
- "TN Eats" is the short Home Screen name of "Tennessee Eats: Restaurants".

4. External services and data:
- Apple MapKit: maps, local search to find a place's Apple Maps listing, and Apple's place card for live hours, photos and ratings.
- Core Location: optional, on-device only, for distance sorting.
- Core Spotlight: on-device indexing so places appear in iPhone search.
- No backend, accounts, analytics, advertising, payments or AI services. The restaurant data is bundled in the app.
- Bundled data sources: Overture Maps Foundation open place data (CDLA Permissive 2.0, with Foursquare-sourced records under Apache 2.0 and AllThePlaces under CC0; license texts are in the app); Metro Nashville's Beer Permit Locations open data (data.nashville.gov, provided "as is"); MICHELIN Guide and James Beard Foundation honors (facts only); and our own research of public websites and local news. Inspection reports are not copied: each place links to the Department of Health's own public search.
- The website with the privacy policy and support page is static and hosted on GitHub Pages: {SITE}

5. Regional differences: none. The content covers Tennessee; the app is offered in the United States and works the same everywhere.

6. Regulated or protected material: the app is not in a regulated industry and includes no protected third-party material. The data is open-licensed or public record, with attribution and licenses on the About tab. Ratings, hours and photos are shown only inside Apple's own place card through MapKit; the app stores no ratings or reviews. The app shows no inspection scores and computes no grades. Every website link was checked before release, and adult venues are excluded. The app is independent and not affiliated with any restaurant, agency, the MICHELIN Guide or the James Beard Foundation.

Support: nick@eatsranked.com"""

# ---------------- checks (nothing is written unless all pass)
problems = []
for label, text, limit in (("name", NAME, 30), ("subtitle", SUB, 30), ("keywords", KW, 100), ("promotional text", PROMO, 170),
                           ("What's New", WHATS_NEW, 4000), ("description", DESC, 4000), ("review notes", REPLY, 4000)):
    if len(text) > limit:
        problems.append(f"{label}: {len(text)} characters, limit {limit}")
title_words = set(re.findall(r"[a-z]+", (NAME + " " + SUB).lower()))
for kw in KW.split(","):
    if kw != kw.strip() or not kw:
        problems.append(f"keyword {kw!r}: no spaces around commas, no empty entries")
    if set(kw.split()) & title_words:
        problems.append(f"keyword {kw!r} repeats a word from the name or subtitle")
for text, label in ((KW, "keywords"), (PROMO, "promotional text"), (SUB, "subtitle"), (WHATS_NEW, "What's New")):
    for bad in (r"\bbest\b", r"\btop\b", r"#1", r"\bfree\b", r"\bevery\b"):
        if re.search(bad, text, re.I):
            problems.append(f"{label}: contains {bad!r}")
if re.search(r"\bevery (?:restaurant|place)\b|\ball [\d,]+ ", DESC + REPLY, re.I):
    problems.append("description/reply: an 'every restaurant' or 'all N' claim the data can't back")
if problems:
    sys.exit("not written:\n  " + "\n  ".join(problems))

listing = {"bundleId": "com.tennesseeeats.ios", "name": NAME, "subtitle": SUB, "privacyPolicyUrl": SITE + "privacy.html",
           "primaryCategory": "FOOD_AND_DRINK", "secondaryCategory": "TRAVEL", "description": DESC, "keywords": KW,
           "promotionalText": PROMO, "supportUrl": SITE, "marketingUrl": SITE, "reviewNotes": REPLY}
os.makedirs(os.path.join(ROOT, "playbook", "app-store"), exist_ok=True)
json.dump(listing, open(os.path.join(ROOT, "playbook", "app-store", "listing.json"), "w"), indent=1, ensure_ascii=False)

open(os.path.join(ROOT, "playbook", "06-app-store-listing.md"), "w").write(f"""# App Store listing (ASO)

Written by `scripts/make-listing.py` from `site-numbers.json` ({N['generated']}); re-run it after every data refresh, never hand-edit.
The machine copy is `app-store/listing.json` (read by `../scripts/asc_listing.py` once Nick creates the App Store Connect record and
adds `"com.tennesseeeats.ios": "tn-eats"` to its FOLDERS). The URLs assume tennessee.eatsranked.com is live; until Nick's CNAME
resolves, use https://nickstrom5.github.io/tennessee-eats/.

## Name (30 max)
`{NAME}` ({len(NAME)})

## Subtitle (30 max)
`{SUB}` ({len(SUB)})

Together they index: tennessee, eats, restaurants, hot, chicken, bbq, biscuits. Home Screen name: TN Eats.

## Keywords (100 max)
`{KW}` ({len(KW)})

- No word repeats the name or subtitle; no trademarks (no Prince's, Hattie B's, Dollywood, Grand Ole Opry), no "best", "top" or "#1".
- Towns are the biggest win; Franklin, Murfreesboro, Clarksville, Johnson City and Sevierville didn't fit. Rotate them in after a month of
  App Store Connect search-term data. Apple's public search can't be used for this research (itunes.apple.com's robots.txt blocks Claude).

## Promotional text (170 max, editable any time without review)
`{PROMO}` ({len(PROMO)})

## Description ({len(DESC)} of 4,000)
```
{DESC}
```

## What's New (1.0)
`{WHATS_NEW}`

## Screenshots
Framed by `scripts/appstore-screenshots.py`: `app-store/iphone/` (8, 1320x2868, the 6.9" slot) and `app-store/ipad/` (6, 2064x2752, the
13" slot). Upload one file at a time in file order and check the order after a reload. No negative board appears in any image, and
captions name no award body.

## Category and age rating
Primary Food & Drink, secondary Travel. Age rating: alcohol references "Infrequent" (bars, honky-tonks, beer permits) → 13+; everything
else None/No. Pricing $0.00, available in the United States. Content rights: yes, third-party content, with the rights (open data, public
records, Apple's place card). Untick "Sign-in required".

## App Review
Reply and recording script: `13-app-review-reply.md`. Put the reply in App Review Information → Notes from the start.
""")

open(os.path.join(ROOT, "playbook", "13-app-review-reply.md"), "w").write(f"""# App Review: prepared before submitting (Guideline 2.1 "Information Needed")

Written by `scripts/make-listing.py` ({N['generated']}). Wisconsin's new-developer review asked for a screen recording from a physical
device, starting at launch, plus answers to six questions; Tennessee Eats should expect the same. Put the reply below in **App Review
Information → Notes** from the start ({len(REPLY):,} of 4,000 characters), and record the video before submitting. If Apple raises
Guideline 4.3(a), answer with Tennessee's own guides and sources (hot chicken, Memphis barbecue, whole hog, meat-and-threes, Smokies
pancake houses, the MICHELIN Guide American South, Metro Nashville's beer permits, the TDH inspection search); never compare with the
other state apps in the Notes.

## Screen recording (Nick, on his iPhone, latest iOS, 60–120 seconds, no sound)

Install from TestFlight first (the internal tester's email must be the Apple ID under Settings › your name › Media & Purchases on the
phone, or TestFlight says "not available"). Record with Control Center → Screen Recording:

1. Start on the Home Screen and tap **TN Eats**. The recording must begin with the launch.
2. Home: scroll the cards a little.
3. Tap **Hot Chicken**, then **Prince's Hot Chicken Shack**.
4. Tap **Ratings, hours & photos**; Apple's place card opens. Close it, then scroll to the Health inspections section.
5. Tap the **heart** (Save), then go back to Home.
6. Tap the search box and type `hot chicken memphis`. Open one result.
7. Tap the **Map** tab, then **Tennessee picks**, then a pin and its name.
8. Tap the **Saved** tab, where the saved place shows. Then tap **About** and scroll to the sources.

## Reply text

```
{REPLY}
```
""")
print(f"wrote listing.json, 06-app-store-listing.md, 13-app-review-reply.md | keywords {len(KW)}/100, promo {len(PROMO)}/170, "
      f"description {len(DESC):,}/4,000, reply {len(REPLY):,}/4,000")
