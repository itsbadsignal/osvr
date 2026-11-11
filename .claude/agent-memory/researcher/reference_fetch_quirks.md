---
name: reference-fetch-quirks
description: Which sites block WebFetch, which interview/transcript sources yielded usable first-person content (expert-paths sweep 2026-11-10)
metadata:
  type: reference
---

- 403 to WebFetch: securityweek.com /amp/ URLs (non-amp works), malwaretech.com, darkreading.com, tech.yahoo.com, amara.org subtitles. web.archive.org is blocked by the tool.
- PDFs come back as binary with no extractor installed (no pdftotext/pypdf on this machine); WebFetch does not parse them. Saved in the tool-results dir.
- Usable transcript sources: darknetdiaries.com/transcript/N, criticalthinkingpodcast.io episode pages, rosetta.to mirrors of YouTube (LiveOverflow transcripts, auto-captions), thecyberwire.com transcripts, securityboulevard Hacker Mind posts.
- WebSearch is a fuzzy lead generator; its summaries invent details. Always confirm via fetch.
- Most "how I got in" interviews are silent on regrets, wasted time and first-paid. Expect `not stated`.
- Gap: no fetched native-code researcher who states no degree (only Bryant, web). Next try: other SecurityWeek Hacker Conversations, MalwareTech post by manual fetch.
