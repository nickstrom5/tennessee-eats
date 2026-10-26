# Data requests to send (drafts for Nick; nothing has been sent)

Both are Nick's to send, from his own account, only if he wants them. Addresses are the ones in `12-sources.md`.

**Tennessee's Public Records Act (T.C.A. 10-7-503) opens records to Tennessee citizens.** Nick lives in Illinois, so an agency may
decline a formal request from him, and these drafts ask for the data as a courtesy rather than citing the Act. If either agency says it
only answers citizens' requests, stop there: don't ask anyone in Tennessee to file on the app's behalf without Nick deciding that.

The app is free, with no ads, purchases or resale.

## 1. Tennessee Department of Health, Environmental Health: inspection scores
To: geh.health@tn.gov. Subject: Request for food service inspection data (non-commercial restaurant guide)

> Hello. I build Tennessee Eats, a free restaurant guide for iPhone and the web, with no advertising, no purchases and no resale.
> Each place in it links to the Department's public inspection search, but we don't copy reports from the search.
>
> Would the Department share an electronic export (CSV or Excel) of food service establishment inspections for 2024 to the
> present, statewide and for the five contract counties if you hold theirs, with these fields where they exist: permit number,
> establishment name, address, city, ZIP, county, inspection date, inspection type (routine, follow-up and so on) and score?
> I don't need owner names or violation narratives. If there is a standard extract, or a fee, please let me know.
>
> We would show each score as the Department publishes it, with its date and a link to the full report, and compute no grade of
> our own. Thank you. Nick Soderstrom, nick@eatsranked.com

## 2. Tennessee Alcoholic Beverage Commission: liquor-by-the-drink licensees
To: TABC.PublicRecords@tn.gov. Subject: Request for a list of active liquor-by-the-drink licenses (non-commercial restaurant guide)

> Hello. I build Tennessee Eats, a free restaurant guide for iPhone and the web, with no advertising, no purchases and no resale.
>
> Would the Commission share an electronic list (CSV or Excel) of active liquor-by-the-drink licenses (restaurant, limited service
> restaurant, wine-only restaurant, hotel, club and similar), with license number, license type, status, business (DBA) name,
> premises address, city, ZIP, county, and issue and expiration dates? I don't need owner or agent names or home addresses. If
> there is a standard export, or a fee, please let me know.
>
> We would use it only to say whether a restaurant serves alcohol, citing the Commission and the date of the list. Thank you.
> Nick Soderstrom, nick@eatsranked.com

When either file arrives, save it in `data/raw/official/manual/` and tell the tn-eats session: `pipeline/official.py` gets a loader for
it, and the app shows inspection scores only as TDH publishes them (with the date and a link to the report).
