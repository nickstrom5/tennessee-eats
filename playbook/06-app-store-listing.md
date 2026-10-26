# App Store listing (ASO)

Written by `scripts/make-listing.py` from `site-numbers.json` (2026-10-24); re-run it after every data refresh, never hand-edit.
The machine copy is `app-store/listing.json` (read by `../scripts/asc_listing.py` once Nick creates the App Store Connect record and
adds `"com.tennesseeeats.ios": "tn-eats"` to its FOLDERS). The URLs assume tennessee.eatsranked.com is live; until Nick's CNAME
resolves, use https://nickstrom5.github.io/tennessee-eats/.

## Name (30 max)
`Tennessee Eats: Restaurants` (27)

## Subtitle (30 max)
`Hot Chicken, BBQ & Biscuits` (27)

Together they index: tennessee, eats, restaurants, hot, chicken, bbq, biscuits. Home Screen name: TN Eats.

## Keywords (100 max)
`nashville,memphis,knoxville,chattanooga,gatlinburg,pigeon forge,smokies,barbecue,meat and three,hog` (99)

- No word repeats the name or subtitle; no trademarks (no Prince's, Hattie B's, Dollywood, Grand Ole Opry), no "best", "top" or "#1".
- Towns are the biggest win; Franklin, Murfreesboro, Clarksville, Johnson City and Sevierville didn't fit. Rotate them in after a month of
  App Store Connect search-term data. Apple's public search can't be used for this research (itunes.apple.com's robots.txt blocks Claude).

## Promotional text (170 max, editable any time without review)
`16 hot chicken spots, 12 Memphis barbecue joints, whole hog pits and meat-and-threes, each checked by hand. Plus 14,000+ Tennessee restaurants near you.` (152)

## Description (2968 of 4,000)
```
Tennessee's restaurants, from a plate of Nashville hot chicken to a Memphis rack of dry-rub ribs.

Tennessee Eats is a free guide to eating in Tennessee: 16 hot chicken spots, 12 Memphis barbecue joints, 7 whole hog pits, 4 meat-and-threes, 8 biscuit and country ham places and 12 Smokies pancake houses we checked by hand, plus 14,862 restaurants, cafés, bars and bakeries in 404 towns, from Memphis and Nashville to Chattanooga, Knoxville and the Tri-Cities. No account, no ads.

TENNESSEE GUIDES
• Hot Chicken: Nashville's cayenne-fired fried chicken on white bread, from the shack that started it.
• Memphis Barbecue: dry-rub ribs, pulled pork and barbecue spaghetti.
• Whole Hog: the West Tennessee pits that still cook the whole hog.
• Meat-and-Threes: one meat, three sides, off a steam table.
• Biscuits & Country Ham: breakfast the Tennessee way.
• Smokies Pancake Houses: Gatlinburg and Pigeon Forge's pancake breakfasts.
• Oldest Places: 6 restaurants open at the same address since 1960 or earlier.
• MICHELIN & James Beard: the MICHELIN Guide's 3 one-star restaurants, 12 Bib Gourmands and Recommended places, and James Beard winners, nominees, semifinalists and America's Classics (49 places).

FIND IT FAST
• Sort by distance, or browse the map by guide.
• Search by name, town, street or dish: "nolensville pike", "hot chicken memphis".
• Filter by town or cuisine, show Bib Gourmands only, or hide chains.
• Save places, and find hand-checked places from iPhone search (Spotlight).

LIVE DETAILS FROM APPLE MAPS
Tap "Ratings, hours & photos" on any place to open Apple Maps' own place card, with current hours, photos, ratings and directions.

HOW THE LISTS ARE BUILT
Every guide place was checked by hand in October 2026 against a 2025 or 2026 source: the place's own site or menu, dated local news or an official tourism listing. The rest come from Overture Maps open data, checked against Metro Nashville's beer permits, which also say which 991 Davidson County places serve beer. Each place links to the Tennessee Department of Health's own inspection search. Website links are checked too. Nothing is ranked by star ratings, and the app computes no grades.

PRIVATE BY DESIGN
No account, no tracking, no ads. Your location, if you share it, only sorts lists on your device. Saved places stay on your device.

Places open and close, so check before you go. Spot a mistake? Email nick@eatsranked.com.

An independent app, not affiliated with any restaurant, chain or government agency (including the State of Tennessee, the Tennessee Department of Health and the Metropolitan Government of Nashville and Davidson County), or with the MICHELIN Guide or the James Beard Foundation. MICHELIN and the MICHELIN Guide are trademarks of Michelin. James Beard Foundation and James Beard Award are trademarks of the James Beard Foundation. Place data from Overture Maps Foundation (CDLA Permissive 2.0) and others; sources and licenses are on the About tab.
```

## What's New (1.0)
`First release: Nashville hot chicken, Memphis barbecue, whole hog, meat-and-threes and 14,000+ Tennessee restaurants.`

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
