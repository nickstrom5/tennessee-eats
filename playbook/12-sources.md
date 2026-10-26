# Tennessee sources (checked 2026-10-24)

Every host below was robots-checked with `pipeline/check_sources.py` (ClaudeBot, Claude-User, anthropic-ai; RFC 9309 matcher) or with
a plain `robots.txt` request in its own step, before any other request. User agent on every scripted request:
`TennesseeEatsBuild/1.0 (+nick@eatsranked.com)`. Raw files are in `data/raw/official/` (git-ignored, never public).

Tennessee publishes **no food-permit list and no inspection data in bulk**. The one official list we can read is Metro Nashville's
beer permits. Everything else statewide comes from map listings, honors and our own hand-checked research.

## Official records

| Source | What | Terms | Cadence | Status |
|---|---|---|---|---|
| **Metro Nashville Beer Permit Board**, "Beer Permit Locations" (data.nashville.gov; ArcGIS item `44e9268cd0d548648980418dafdb42da`, layer `services2.arcgis.com/HdTo6HJqh92wn4D8/.../Beer_Permit_Locations_Feature_Layer_view/FeatureServer/0`), read through the documented REST API, 1,000 rows a request, `Business_Owner` never requested | 2,122 active permits on 2026-10-24 (2,067 issued, 55 temporary): permit number, status, subtype, dates, business name, address, ZIP, point. Subtypes: **On Site** 1,259, **On & Off Site** 244 (both = beer served on the premises), Off Site (stores) 580, Wholesale 24, Special Events 15. Davidson County only | Metro's Open Data Executive Order 18 (Mayor O'Connell): informational use, as is, no warranty, no claim of Metro's approval; cite the retrieval date and the URL | Daily (layer last edited 2026-10-24) | **used**: confirms Davidson listings (1,006 matched), "serves beer" (1,010 places), and adds 72 on-premises permit holders whose names say they're a place to eat or drink |
| **Tennessee Department of Health**, Environmental Health (Rule 1200-23-01, revised June 2026; five contract counties run their own programs under it: Davidson, Shelby, Knox, Hamilton, Madison) | Inspection scores 0–100 per report | — | — | **not used**. `inspections.myhealthdepartment.com/tennessee` answers our honest agent 403, robots.txt included (the prompt saw `User-agent: * Disallow: /`). Search-only portal, no export. Never scraped. Each place links the portal home instead. `www.tn.gov` answers both our script and Claude's web fetcher with 403 (AWS ELB), so TDH pages were read only through search results; `publications.tnsosfiles.com` (the rule PDF) answers 403 "Request blocked" (CloudFront). A data request to TDH Environmental Health (geh.health@tn.gov) needs Nick's yes (draft: `playbook/records-requests.md`) |
| healthdata.tn.gov (Socrata; robots allow the catalog API) | Catalog searched for food, inspection, restaurant | — | — | No dataset: only the "Environmental Health Program" story page |
| data.nashville.gov, data.memphistn.gov (ArcGIS Hub), ArcGIS Online search | Searched for inspections, food, restaurants, beer, liquor, business licenses (Knoxville, Chattanooga, Memphis, Murfreesboro, Clarksville) | — | — | Only Nashville's beer permits. Memphis's hub has no food, license or alcohol layer |
| Knox County (knoxcounty.org) | — | robots.txt disallows ClaudeBot, Claude-Web, anthropic-ai | — | not used |
| Shelby County (shelbycountytn.gov) | — | 403 to robots.txt | — | not used. shelbytnhealth.com robots allow, no bulk data found |
| Hamilton County Health (health.hamiltontn.gov) | — | robots allow (Cloudflare content signals, none set) | — | no bulk inspection data found |
| **Alcohol**: TABC liquor-by-the-drink licenses | Restaurant, limited-service, wine-only, club, hotel licenses ("do not authorize the sale of beer") | — | — | **not used**: the public PDF lists skip LBD and the licensing portal has no public search. A records request to TABC.PublicRecords@tn.gov needs Nick's yes. Beer is permitted by each town's or county's beer board; only Nashville publishes. Wet/dry is local option, so "no license found" is shown as "—", never "No" |
| **Property values**: Comptroller parcels (ArcGIS `e356f1a241844d6f9025f2fa4e977df3`) | 86 counties; leaves out Davidson, Shelby, Knox, Hamilton, Rutherford, Williamson, Montgomery, Chester, Hickman; "not intended for commercial use" | — | monthly | **not used** (no building-value board) |

## Statewide base

| Source | What | Terms | Cadence | Rows |
|---|---|---|---|---|
| Overture Maps places `2026-10-21.0` (newest release) | Map listings, state and county outlines (land areas, so the Mississippi border follows the bank), address points | CDLA-Permissive-2.0 / Apache-2.0 + Foursquare NOTICE | Monthly | 31,985 Tennessee eating/drinking listings (`region = 'TN'`); 383,955 places in the state; 3.93 M address points; 95 counties |
| UCSD Google Local 2021 (`meta-Tennessee.json.gz`, mcauleylab.ucsd.edu, 24.5 MB) | 2021 ratings, reviews, price: **web leaderboard only, never the app** | research dataset | frozen Sep 2021 | 18,550 food listings (2,193 closed by 2021); 14,056 matched to Overture listings |
| Census County Business Patterns 2023 (from the prompt; api.census.gov answers our agent "Request Rejected") | NAICS 722 establishments: 13,713 statewide; Davidson 2,262, Shelby 1,819, Knox 1,081, Hamilton 857, Sevier 406. QCEW 2025 average 14,324 | public | yearly | benchmark only |

Spillover towns (Southaven MS, West Memphis AR, Rossville GA, Bristol VA, Oak Grove KY) are clipped three ways: Overture's own
`region = 'TN'`, a Tennessee ZIP (370xx–385xx), and the state outline with a 100 m buffer (Bristol's State Street is the line).

## Calibration (2026-10-24, `data/tn/calibration*.json`)
Only Davidson County has an official list, and it lists only places that serve beer (coffee shops, bakeries, most fast food and
many family restaurants hold no permit). So the share of listings found on it is a **floor for comparing kinds of listings**, not a
rate of real restaurants. Statewide, the share Google 2021 still showed open is the second check (Idaho's and Hawaii's method).

| Kind of listing | Davidson, on an on-premises beer permit | Independent sit-down only | Open in Google 2021 (statewide) |
|---|---|---|---|
| Meta + open in Google 2021 | 36.1% of 1,426 | | |
| Meta only | 24.3% of 1,529 | | |
| Brand feed only (chain store lists) | 12.7% of 63 | | |
| Foursquare only | 6.0% of 434 | | |
| BrightQuery only | 3.9% of 648 | | |
| Microsoft only | 3.8% of 182 | | |
| App grouping: Meta ≥ 0.95 | 38.4% of 2,004 | 51.9% | 68.6% of 12,082 |
| App grouping: Meta 0.90–0.95 with a website | 13.6% of 272 | 19.5% | 45.2% of 2,652 |
| App grouping: Meta 0.90–0.95, no website | 7.1% of 85 | 6.7% | 17.3% of 1,024 |
| App grouping: Meta < 0.90 | 12.4% of 613 | 14.4% | 4.4% of 4,325 |
| App grouping: other sources | 5.2% of 1,948 | 6.1% | 27.3% of 9,572 |

Same order as Colorado, Texas, Idaho and Arizona, so the same keep rules: web = Meta and chain store lists (plus official and
hand-checked), minus what Google showed closed in 2021; app = Meta ≥ 0.95, Meta 0.90–0.95 with a website, chain store lists, official,
hand-checked. Coverage the other way: the open map listings hold **65.3%** of Davidson's 1,399 on-premises permit businesses; plainly
named restaurants and bars among the rest are added from the list (72 in the first web build).

## Honors (data/research)
- **MICHELIN Guide American South 2026** (revealed 2026-10-21 in Nashville). guide.michelin.com answers curl with an empty 202 (bot
  challenge, never retried); read 2026-10-24 with Claude's web fetcher. Tennessee: **45 restaurants: 3 One Star** (Bastion, The Catbird
  Seat, Locust), **12 Bib Gourmand** (Hog & Hominy, Sho Pizza Bar, St. Vito Focacceria, Peninsula, Little Coyote, Uzbegim, S.S. Gai,
  Maiz de la Vida, Bao Toan Kitchen & Bar, A Dopo, Kisser, Redheaded Stranger; confirmed on the guide's Bib filter page), 30 Recommended,
  no Green Stars. The prompt's September list (35) was the 2025 selection. Each restaurant page read for its address and cuisine
  (`michelin.json`). The **Bib Gourmand filter** applies (BIB-GOURMAND-FILTER.md).
- **James Beard** (`jbf.json`, jamesbeard.org and Wikipedia's list, both robots-allowed): America's Classics Arnold's Country Kitchen
  (2009) and Prince's Hot Chicken Shack (2013; honored at the Ewing Drive shack, now carried by the South location, 5814 Nolensville Pike);
  Best Chef: Southeast Tandy Wilson, City House (2016) and Jake Howell, Peninsula (2025); 2026 Outstanding Restaurant nominee The Catbird
  Seat; 2026 semifinalists Joseph Lenn (J.C. Holdway, Outstanding Chef), Niedlov's Bakery & Cafe (Outstanding Bakery), Tailor (Outstanding
  Hospitality), and for Best Chef: Southeast Khaled AlBanna (Calliope), Laurence Faber (Potchke Deli), Jimmy Gentry (The Lobbyist), Philip
  Krajeck (Rolf & Daughters). No Tennessee winners in 2026. Joseph Lenn's 2013 win at The Barn at Blackberry Farm waits on confirming the
  resort's dining room takes outside guests (LEADS.md).

## Press and tourism hosts (robots-checked 2026-10-24)
- **Usable:** jamesbeard.org, en.wikipedia.org, nashvillescene.com, nashtoday.6amcity.com, nashvillego.com, newschannel5.com, wpln.org,
  williamsonsource.com, thelocalpalate.com, wbir.com, localmemphis.com, memphisflyer.com, knoxmercury.com, visitknoxville.com,
  choosechatt.com, chattanoogafun.com, gatlinburg.com, mypigeonforge.com, tnvacation.com, timesnews.net, johnsoncitypress.com,
  aristopr.com, and the restaurants' own sites checked so far (princeshotchicken.com, cityhousenashville.com, arnoldscountrykitchen.com,
  blackberryfarm.com).
- **Blocked (never cited):** tennessean.com, commercialappeal.com, knoxnews.com, timesfreepress.com, jacksonsun.com (robots disallow all
  three Claude agents); wkrn.com, wsmv.com, fox17.com, actionnews5.com, wreg.com, wate.com, wjhl.com, wvlt.tv, wbbjtv.com,
  memphismagazine.com (robots disallow ClaudeBot and anthropic-ai); southernliving.com, eater.com (robots); visitmusiccity.com,
  memphistravel.com, atlasobscura.com (bot check).

## Adult venues
`data/research/adult_venues.json`: checked addresses (The Trimble / "Skyhaus Bar", 69 Trimble St, Nashville: SkyHaus Entertainment's
late-night venue and home of a male burlesque show, per aristopr.com; 3096 Lamar Ave, Memphis, which Overture lists both as "Mariscos
El Gallo Giro" in the adult category and as "Elgallogiro_gentlemansclub"), plus `not_adult`: Overture adult-category listings that are
plainly something else (a Beale Street patio, a phone store, a ministry, a neighborhood, people's names), so their names never remove a
place. Overture's adult category also covers the downtown Nashville male revues and drag-brunch shows; their plain words ("Black",
"Diamond", "Show") are ignored when matching (Black Tap Craft Burgers & Beer was wrongly removed once).
