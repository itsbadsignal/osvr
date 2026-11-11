---
name: job-posting-apis
description: Working primary-source JSON endpoints for fetching job postings (Greenhouse, Workable, Workday, Microsoft, Google, Teamtailor) and dead ends, found 2026-11-10
metadata:
  type: reference
---

Working (curl from sandbox, no auth):
- Greenhouse: `https://boards-api.greenhouse.io/v1/boards/<token>/jobs` and `/jobs/<id>`; `content` is HTML-escaped (html.unescape before stripping tags). Tokens that worked: anthropic, cloudflare, okta, stripe, robinhood, coinbase, elastic, gitlab, mongodb, huntress, vulncheck, wizinc, zscaler, bugcrowd.
- Workable (Trail of Bits): `https://apply.workable.com/api/v1/widget/accounts/trailofbits?details=true`.
- Workday CxS: POST `https://<tenant>.wdN.myworkdayjobs.com/wday/cxs/<tenant>/<site>/jobs` with `{"searchText":..,"limit":20,"offset":0}`; detail via GET same path + externalPath. Worked: NVIDIA (NVIDIAExternalCareerSite), CrowdStrike (crowdstrikecareers). Arm returned 422.
- Microsoft: `https://apply.careers.microsoft.com/api/pcsx/search?domain=microsoft.com&query=...` and `/api/pcsx/position_details?position_id=..&domain=microsoft.com`; rate-limits (429) after ~3 calls, sleep 20-30 s.
- Google Careers detail pages: raw HTML embeds posting text (search for "Minimum qualifications", unicode-escaped); dead IDs return a generic search page.
- Teamtailor: `<co>.teamtailor.com/jobs` lists hrefs; detail pages are server-rendered. Taleez needs `curl --compressed`.

Dead ends: Ashby posting-api (all tokens 404), Lever (few tokens exist), grsecurity page (HTTP 500), careers.nccgroup.com (unreachable), Apple jobs (JS), Intel (JS), Palo Alto via Getro (403), Quarkslab careers-jobs (404).

Shell gotchas: zsh treats a bare `=====` as a command; pass args to Python scripts as separate argv, not a quoted "a b" string.
