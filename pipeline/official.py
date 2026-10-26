"""Official records for Tennessee -> one table of permitted food and drink businesses.

Tennessee publishes no food-permit list or inspection data in bulk: the Department of Health (and its five contract counties,
Davidson, Shelby, Knox, Hamilton and Madison) keep inspections in a search-only portal whose robots.txt shuts out crawlers. The one
official list we can read (playbook/12-sources.md):
- "nsh": Metro Nashville Beer Permit Board, "Beer Permit Locations" (data.nashville.gov, ArcGIS item 44e9268cd0d548648980418dafdb42da,
         updated daily): every active beer permit in Davidson County with business name, address, a point and the permit subtype.
         "BB - On Site Sales" and "On & Off Site Sales" mean beer is served on the premises; "Off Site Sales" are stores. The list's
         Business_Owner field is never read. Terms: Metro's Open Data Executive Order 18 (informational use, as is, cite the
         retrieval date and URL; no claim of Metro approval).

load() returns: jur, lic (our id), name, keys (name keys), addr, city, zip, num, street, lat, lon, kind, active, ltype, sub.
kind: food (on-premises beer) | retail (off-site only) | other (wholesale, special events).
"""
import os, re, json, datetime
import numpy as np, pandas as pd
from common import norm_name, RAW, name_sim, _stems, GENERIC, canon_city

OFF = os.path.join(RAW, "official")
DIRS = {"N": "N", "S": "S", "E": "E", "W": "W", "NORTH": "N", "SOUTH": "S", "EAST": "E", "WEST": "W"}
TYPES = set("ST STREET AVE AV AVENUE BLVD BOULEVARD RD ROAD DR DRIVE LN LANE CT COURT PL PLACE PKWY PARKWAY TER TRL TRAIL WAY HWY CIR "
            "CIRCLE PLZ SQ MALL BND PASS XING RUN ROW WALK RDG LOOP FWY FREEWAY EXPY EXPRESSWAY PIKE PK PKE".split())


def road(a):
    """One spelling for numbered roads: 'US HIGHWAY 70' = 'US-70' = 'US 70'; 'STATE ROUTE 840' = 'SR 840' = 'TN-840' = 'SH 840';
    'N INTERSTATE 40' = 'I-40'; 'COUNTY ROAD 5' = 'CR 5'."""
    a = re.sub(r"(\d)\s*&\s*(\d)", r"\1-\2", a.upper())
    a = re.sub(r"\b(US|TN|SR|SH|CR|I|IH)-(\w)", r"\1 \2", a)
    a = re.sub(r"\b(?:INTERSTATE(?: HIGHWAY| HWY)?|IH|I H)\s*(?=\d)", "I ", a)
    a = re.sub(r"\b(?:US|U S)\s+(?:HIGHWAY|HWY)\b", "US", a)
    a = re.sub(r"\b(?:FARM[- ]TO[- ]MARKET(?: ROAD| RD)?|FARM (?:ROAD|RD)|F M)\b", "FM", a)
    a = re.sub(r"\b(?:RANCH[- ]TO[- ]MARKET(?: ROAD| RD)?|RANCH (?:ROAD|RD)|RR|RM)\b(?=\s*\d)", "RM", a)
    a = re.sub(r"\b(?:STATE (?:HIGHWAY|HWY|ROAD|RD|ROUTE|RTE)|SR|SH|TENNESSEE (?:HIGHWAY|HWY|STATE (?:HIGHWAY|ROUTE))|TN (?:HIGHWAY|HWY)|TN)\b(?=\s*\d)", "SH", a)
    a = re.sub(r"\b(?:HISTORIC )?(?:ROUTE|RT|RTE) 66\b", "US 66", a)
    a = re.sub(r"\b(?:COUNTY (?:HIGHWAY|HWY|ROAD|RD)|CO RD|CTY (?:HWY|RD)|CR)\b", "CR", a)
    a = re.sub(r"\bHIGHWAY\b", "HWY", a)
    return re.sub(r"\b(US|SH|CR|HWY|FM|RM|I) (\w+)\s*-\s*\w+", r"\1 \2", a)


ORD = {"FIRST": "1ST", "SECOND": "2ND", "THIRD": "3RD", "FOURTH": "4TH", "FIFTH": "5TH", "SIXTH": "6TH", "SEVENTH": "7TH",
       "EIGHTH": "8TH", "NINTH": "9TH", "TENTH": "10TH", "ELEVENTH": "11TH", "TWELFTH": "12TH"}


def street_key(a):
    """'2505 Monroe St' -> ('2505', 'MONROE'); '1000 OSAGE STREET' -> ('1000', 'OSAGE'); 'E Colfax Ave' keeps 'COLFAX'."""
    if not isinstance(a, str):
        return None, None
    a = re.sub(r"[.,#]", " ", road(a))
    m = re.match(r"^\s*(\d+)[A-Z]?(?:\s*-\s*\d+[A-Z]?)?\s+(.*)$", a)
    if not m:
        return None, None
    words = [w for w in m.group(2).split() if w]
    if len(words) > 1 and words[0] in DIRS:
        words = words[1:]
    core = []
    for w in words:
        if w in TYPES and core:
            break
        core.append(w)
    core = [ORD.get(w, w) for w in core]
    return m.group(1), " ".join(core[:3]) or None


def street_compat(a, b):
    """Same street, or one is a whole-word prefix of the other: Boulder's 2025 set sometimes truncates ("1206 CENTAUR" = Centaur Village Dr)."""
    if not isinstance(a, str) or not isinstance(b, str) or not a or not b:
        return False
    return a == b or a.startswith(b + " ") or b.startswith(a + " ")


def street_nums(a):
    """'157-159 W Main St' -> {'157', '159'}; '2505 Monroe St' -> {'2505'}."""
    if not isinstance(a, str):
        return set()
    a = road(a)
    m = re.match(r"^\s*(\d+)[A-Z]?(?:\s*-\s*(\d+)[A-Z]?)?\s", a.upper() + " ")
    if not m:
        return set()
    lo = int(m.group(1)); hi = int(m.group(2)) if m.group(2) else lo
    if hi < lo:   # "1500-02"
        hi = int(str(lo)[: len(str(lo)) - len(m.group(2))] + m.group(2)) if m.group(2) else lo
    return {str(x) for x in range(lo, hi + 1, 2 if (hi - lo) % 2 == 0 else 1)} if 0 <= hi - lo <= 12 else {str(lo)}


def _names(*vals):
    out = []
    for v in vals:
        if not isinstance(v, str):
            continue
        v = re.sub(r"\s*\((?:MOBILE|MOBILE UNIT|COMMISSARY|CATERING|SPECIAL EVENT|SPEC EVENT|TEMP(?:ORARY)? EVENT|CP|INSIDE [^)]*)\)\s*$", "", v, flags=re.I)
        for part in re.split(r"\s*/\s*|\s+\bdba\b\s+|\s+&\s+(?=[A-Z][a-z])", v, flags=re.I):
            k = norm_name(re.sub(r"\b(?:LLC|INC|CORP|CORPORATION|LTD|CO)\b\.?", "", part, flags=re.I))
            if k and k not in out:
                out.append(k)
    return out





LIST_DATE = None   # set by load(): the day the beer-permit list was fetched (the layer is edited daily)
ONPREM = ("ONSALES", "ONOFFSALES")
BEER_FILE = os.path.join(OFF, "nashville", "beer_permits.json")
BEER_ITEM = "https://data.nashville.gov/datasets/44e9268cd0d548648980418dafdb42da"


def liq_kind(t):
    """A beer permit subtype -> on-premises or retail."""
    if not isinstance(t, str):
        return None
    return "onprem" if t.startswith("Beer, on site") or t.startswith("Beer, on & off") else "retail" if t.startswith("Beer, off") else None


def _zip(z):
    z = re.sub(r"\D", "", str(int(z)) if isinstance(z, float) and z == z else str(z or ""))
    return z[:5] if len(z) >= 5 else ""


OTHER = re.compile(r"\b(?:SCHOOL|ELEMENTARY|ACADEMY|HOSPITAL|JAIL|DETENTION|SENIOR|NURSING|FOOD TRUCK|CATERING|CATERER|COMMISSARY|"
                   r"CONCESSION|CHURCH|PARISH|CAMP|CORRECTION(?:AL)?|CAMPUS|WAREHOUSE|COLLEGE|UNIVERSITY|DISTRIBUT\w*|WHOLESALE)\b", re.I)
RETAIL = re.compile(r"\b(?:KROGER|PUBLIX|WALMART|WAL MART|TARGET|COSTCO|SAMS CLUB|ALDI|FOOD LION|DOLLAR GENERAL|WALGREENS|CVS|MAPCO|"
                    r"TWICE DAILY|WEIGELS|SHELL|EXXON|MARATHON|BP|CIRCLE K|RACETRAC|SPEEDWAY|PILOT|MARKET|MART|GROCERY|LIQUOR|TOBACCO|"
                    r"SMOKE SHOP|VAPE|GAS|FUEL|FOOD STORE|BEER STORE)\b")
SUB = {"ONSALES": "Beer, on site", "ONOFFSALES": "Beer, on & off site", "OFFSALES": "Beer, off site (store)",
       "WHOLESALES": "Beer, wholesale", "SPECIAL": "Beer, special event"}


def _row(jur, lic, name, addr, city, z, la, lo, kind, active=True, ltype=None, holder=None):
    num, st = street_key(addr)
    if kind == "food" and OTHER.search(name or ""):
        kind = "other"
    return {"jur": jur, "lic": lic, "name": name, "dba": name, "holder": holder, "keys": _names(name), "addr": addr, "city": city,
            "zip": _zip(z), "num": num, "street": st, "lat": la, "lon": lo, "kind": kind, "active": active, "ltype": ltype}


def _addr(a):
    """'6688  Nolensville PIKE  105' -> '6688 Nolensville Pike 105' (the list pads fields with double spaces)."""
    a = re.sub(r"\s+", " ", a or "").strip()
    return re.sub(r"\b([A-Z]{2,})\b", lambda m: m.group(1).title() if m.group(1) not in ("NE", "NW", "SE", "SW") else m.group(1), a)


def load_nashville():
    global LIST_DATE
    d = json.load(open(BEER_FILE))
    LIST_DATE = d.get("fetched")
    rows = []
    for r in d["rows"]:
        st = r.get("Permit_Sub_Type")
        kind = "food" if st in ONPREM else "retail" if st == "OFFSALES" else "other"
        x = _row("nsh", "nsh-" + r["Permit__"], (r.get("Business_Name") or "").strip(), _addr(r.get("Address")), canon_city(r.get("City")),
                 r.get("ZIP"), r.get("Lat"), r.get("Lon"), kind, active=r.get("Status") in ("ISSUED", "TEMPORARY"), ltype=SUB.get(st, st))
        x["permit"] = r["Permit__"]
        x["temp"] = r.get("Status") == "TEMPORARY"
        x["issued"] = datetime.datetime.fromtimestamp(r["Date_Issued"] / 1000, datetime.UTC).date().isoformat() if r.get("Date_Issued") else None
        rows.append(x)
    return pd.DataFrame(rows)


def load():
    df = load_nashville()
    # one business can hold several records (two permits at one address under one name): same address and a name in common
    df["biz"] = np.arange(len(df))
    town = df.city.fillna("").str.upper().str.strip()
    for num, g in df[df.num.notna() & df.street.notna()].groupby("num"):
        idx = list(g.index)
        if len(idx) < 2 or len(idx) > 400:
            continue
        for x in range(len(idx)):
            for y in range(x + 1, len(idx)):
                a, b = idx[x], idx[y]
                if not street_compat(df.at[a, "street"], df.at[b, "street"]):
                    continue
                if not ((df.at[a, "zip"] and df.at[a, "zip"] == df.at[b, "zip"]) or (town[a] and town[a] == town[b])):
                    continue
                ka, kb = df.at[a, "keys"], df.at[b, "keys"]
                if not ka or not kb:
                    continue
                if any(name_sim(p, q) >= 85 or ((_stems(p) - GENERIC) & (_stems(q) - GENERIC)) for p in ka for q in kb):
                    old, new = df.at[b, "biz"], df.at[a, "biz"]
                    df.loc[df.biz == old, "biz"] = new
    df["county"] = "Davidson County"
    return df
