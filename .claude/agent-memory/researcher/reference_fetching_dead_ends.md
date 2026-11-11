---
name: reference-fetching-dead-ends
description: Which academic sources the fetch tool can and cannot reach, and the working workaround for abstracts
metadata:
  type: reference
---

WebFetch fails on PubMed/PMC (cookie/captcha wall), Springer article pages (303 to identity provider), SAGE/ACM PDFs (403), and cannot decode PDFs; no pdftotext/pip in sandbox.

Working route for abstracts (record-level verification): Europe PMC REST (`ebi.ac.uk/europepmc/webservices/rest/search?query=TITLE:"..."&resultType=core&format=json`) for Psych Bull/Psych Sci/PSPI; OpenAlex API (`api.openalex.org/works/doi:<doi>`, abstract_inverted_index) for most others; Semantic Scholar `/paper/search/match` for APA items. Springer-hosted abstracts (Educ Psych Rev) are often elided everywhere: mark verified: null.

**How to apply:** use curl/python via Bash with these APIs rather than WebFetch on publisher pages. Used in research/benchmarks/learning-science.md (2026-11-10).
