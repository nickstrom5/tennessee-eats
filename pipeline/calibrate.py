"""How often is a map listing a real, permitted food business? Measured where an official list exists -> data/tn/calibration*.json

Adapted from co-eats/pipeline/calibrate.py (via tx-eats and az-eats). Tennessee publishes one list: Metro Nashville's beer permits.
- Davidson County: against every active on-premises beer permit (on site, or on and off site). Only places that serve beer hold one
  (coffee shops, bakeries, most fast food and many family restaurants don't), so the share of listings found on it is a lower
  bound, useful for comparing kinds of listings with each other, not as a rate of real restaurants.
- The other direction (permits found among the open map listings) says how much of Nashville's beer-serving trade the listings hold.
A match is the same business name nearby, or the same street address with a distinctive name word in common.
"""
import json
import numpy as np, pandas as pd
from shapely.geometry import shape, Point
from shapely.prepared import prep
from common import TN
from listings_util import official_match

o = pd.read_pickle(f"{TN}/stage1.pkl")
F = pd.read_pickle(f"{TN}/official.pkl")
from shapely import STRtree
_CN = json.load(open(f"{TN}/tn_counties_detail.geojson"))
_NAMES = list(_CN)
_GEOMS = [shape(_CN[n]).buffer(0.0003) for n in _NAMES]
_TREE = STRtree(_GEOMS)


def county_of(la, lo):
    if la != la:
        return None
    p = Point(lo, la)
    for i in _TREE.query(p):
        if _GEOMS[i].contains(p):
            return _NAMES[i]
    return None


o["county"] = [county_of(la, lo) for la, lo in zip(o.lat, o.lon)]
# every list is one county's; a placed record keeps the county its point falls in only when that is its own county
OWN = {"nsh": "Davidson County"}
F["county"] = [OWN[j] for j in F.jur]
o.to_pickle(f"{TN}/stage1.pkl")
F.to_pickle(f"{TN}/official.pkl")
base = ~o.j_junk & ~o.j_outside
print("listings with a county:", int(o.county.notna().sum()), "of", len(o))


def groups(L, app=False):
    s = L.src.fillna("none")
    if app:
        conf = L.confidence.fillna(0)
        return np.select([L.ov_closed | L.j_closedname, (s == "meta") & (conf >= 0.95), (s == "meta") & (conf >= 0.9),
                          s.isin(["AllThePlaces", "DAC"]), (s == "BrightQuery") & (conf >= 0.95), s == "meta"],
                         ["closed per Overture/name", "meta_high", "meta_mid", "brand_feed", "bq_high", "meta_low"], "other_sources")
    return np.select([L.closed21, L.ov_closed, (s == "meta") & L.in21, s == "meta", s.isin(["AllThePlaces", "DAC"]) & L.in21,
                      s.isin(["AllThePlaces", "DAC"]), L.in21, s == "Foursquare", s == "BrightQuery", s == "Microsoft"],
                     ["Google 2021 says closed", "Overture says closed", "Meta + open in Google 2021", "Meta only",
                      "brand feed + Google 2021", "brand feed only", "Foursquare/BrightQuery/Microsoft + Google 2021",
                      "Foursquare only", "BrightQuery only", "Microsoft only"], "other")


AREAS = {"Davidson County (beer permits, on premises)": ("Davidson County", F.jur.eq("nsh") & F.active & F.kind.eq("food"), "nsh")}
res, app = {}, {}
for label, (cty, sel, own) in AREAS.items():
    L = o[base & (o.county == cty)].reset_index(drop=True)
    R = F[sel & (F.county == cty)].reset_index(drop=True)
    if not len(R):
        print(f"\n== {label}: no official records yet"); continue
    m = official_match(L, R)
    L["hit"] = L.index.map(lambda i: i in m)
    L["hit_food"] = L.index.map(lambda i: i in m and R.kind.iat[m[i]] == "food")
    for mode, store in ((False, res), (True, app)):
        L["grp"] = groups(L, mode)
        t = L.groupby("grp").agg(n=("id", "size"), official=("hit", "mean"), food=("hit_food", "mean")).sort_values("n", ascending=False)
        print(f"\n== {label} ({'app grouping' if mode else 'web grouping'}): {len(L)} listings, {len(R)} official records")
        print(t.assign(official=(t.official * 100).round(1), food=(t.food * 100).round(1)).to_string())
        store[label] = {"listings": int(len(L)), "official_records": int(len(R)),
                        "groups": {g: {"n": int(r.n), "official": round(float(r.official), 3), "food": round(float(r.food), 3)} for g, r in t.iterrows()}}
    # the other direction: how many official restaurants/bars do the (cleaned, open) map listings hold?
    keepish = ~(L.ov_closed | L.j_closedname | L.closed21)
    got = set(R.biz.iloc[[m[i] for i in L.index[keepish] if i in m]])
    Rr = R[(R.jur == own) & R.kind.isin(["restaurant", "bar", "food"])].drop_duplicates("biz")
    cover = float(np.mean([b in got for b in Rr.biz])) if len(Rr) else None
    print(f"{label}: official food businesses found among open map listings: {cover*100:.1f}% of {len(Rr)}")
    res[label]["coverage"] = round(cover, 3)
    res[label]["official_food"] = int(len(Rr))

per = o[base & o.county.notna() & ~o.ov_closed & ~o.j_closedname].groupby("county").size()
print("\n== open, cleaned listings per county\n" + per.sort_values(ascending=False).to_string())
json.dump({"areas": res, "per_county_listings": {c: int(n) for c, n in per.items()}}, open(f"{TN}/calibration.json", "w"), indent=1)
json.dump(app, open(f"{TN}/calibration_app.json", "w"), indent=1)
