# Tennessee Eats (tn-eats) — notes for Claude Code sessions

Started 2026-10-24 from `../state-prompts/TENNESSEE_PROMPT.md` and `../STATE_EATS_PLAYBOOK.md` (read both). Pipeline and app ported from
`../az-eats/`; never modify another state's folder. Leaderboard artifact link in `LOCAL.md` (v3 published 2026-10-24).

- Brand (Nick, 2026-10-24, `playbook/05-naming.md`): "Tennessee Eats: Restaurants", subtitle "Hot Chicken, BBQ & Biscuits", Home Screen
  "TN Eats", bundle `com.tennesseeeats.ios`; hot-chicken icon on flag navy (`scripts/make-brand.swift`, passes icon-style check); palette
  navy #002D72 + red #C8102E; Grand Divisions band.
- Sources: `playbook/12-sources.md`. No bulk inspections (TDH portal linked, never scraped or fetched: its robots.txt disallows all
  agents, so the link was not opened by us either); only official list = Metro Nashville beer permits. MICHELIN American South 2026:
  3 stars, 12 Bib Gourmands (Bib filter in the app and web app). Share sends `explore/#p=<id>` (SHARE-LINK.md); venues, which the web
  app leaves out, share the web app's front page (`Links.onWeb`).
- Chain names use the chain's own spelling at every branch: `brands.py` canonical names, and `build_research.py` writes `display` for a
  research entry whose name is a brand ("Hattie B's Hot Chicken", from hattieb.com). princeshotchicken.com robots-blocks AI agents, so
  Prince's names stay as listed.
- Rebuild: `cd pipeline && ../.venv/bin/python listings.py && ../.venv/bin/python geocode_official.py && ../.venv/bin/python calibrate.py &&
  ../.venv/bin/python build_research.py && ../.venv/bin/python tennessee.py && TN_APP=1 ../.venv/bin/python tennessee.py`, then
  `cp data/app/places.json data/app/detail-*.json TennesseeEats/Resources/`, `.venv/bin/python scripts/make-leaderboard.py`,
  `.venv/bin/python scripts/make-site.py`, `.venv/bin/python scripts/make-listing.py`.
- Links: `check_websites.py` ran 2026-10-24 (7,638 ok of 12,368; 126 gambling/adult/hacked dropped). ~750 connection errors and ~230
  429s from a loaded Mac were dropped, not retried (this checker has no retry option); re-run before submission.

## Website (generated `docs/`, never hand-edited)
`scripts/make-site.py` (21 pages: six guides, honors, oldest, the TDH inspections explainer, six city pages + index, the web app at
/explore/ from `scripts/explore.js`, privacy, terms, 404). Until tennessee.eatsranked.com resolves it lives at
nickstrom5.github.io/tennessee-eats/ (`App/Links.swift`). `scripts/qa-site.py` (ported 2026-10-24; static checks mutation-tested):
full run OK 2026-10-24 (375 and 1280 px, web app, dark mode, landing screenshots).
Search: a direction word before a town name also matches that street ("north germantown" = N Germantown Pkwy as well as Germantown),
in both `Models/Search.swift` and `explore.js`; unit-tested and mutation-checked.

## App
- `xcodegen generate`; build with `DEVELOPER_DIR="/Applications/Xcode 1.app/Contents/Developer"`, `-derivedDataPath DerivedData`.
- Own simulators in `.simulators`: "TN Eats 6.9" (iPhone 17 Pro Max) and "TN Eats iPad 13" (iPad Pro 13-inch M5), iOS 27.0. One at a
  time; shut each down after use; check `uptime` and `ps -u $(id -u) | wc -l` first.
- `TennesseeEatsTests`: 29/29 pass (2026-10-24). `TennesseeEatsUITests` (ported 2026-10-24): all pass on iPhone and iPad (tour, Everything
  layer, my location, outside Tennessee, Bib Gourmand on iPhone, accessibility audit). `testLaunchIsQuick` skipped both times under load
  (5.3 s iPhone, 5.4 s iPad; limit 6 s): re-measure on a quiet Mac. Audit notes: the family's display-font size cap and Apple Maps'
  "Legal" link, plus "Contrast failed" on ink-on-white text (#0F1B33 on white, about 17:1): an audit artifact, not a real failure.
- Screens: `-screenshot <home|hot_chicken|bbq|honors|oldest|detail|map|saved|about>` (DEBUG; downtown Nashville, Memphis for bbq).
  `scripts/capture-screenshots.sh <udid>`, then `scripts/site-images.sh`, then make-site again. App Store frames (2026-10-24, git-ignored):
  `OUT=$PWD/playbook/app-store/raw/<iphone|ipad> SLEEP=14 bash scripts/capture-screenshots.sh <udid> ...` (map: SLEEP=20), then
  `scripts/appstore-screenshots.py` → `playbook/app-store/iphone/` (8, 1320x2868) and `ipad/` (6, 2064x2752).
- App Store copy: `scripts/make-listing.py` → `playbook/06-app-store-listing.md`, `13-app-review-reply.md`, `app-store/listing.json`.

## Still to do
1. Before submission: re-run `check_websites.py` on a quiet Mac (connection errors from load were dropped) and `testLaunchIsQuick`.
2. Nick: repo/Pages, Cloudflare CNAME tennessee, ASC record, USPTO confirmation, the two data requests in `playbook/records-requests.md`
   (drafts; Tennessee's records act is for citizens, so they're courtesy asks). Nothing committed or pushed.
