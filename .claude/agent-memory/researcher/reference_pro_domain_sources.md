---
name: pro-domain-sources
description: Working and dead URLs and fetch tricks for disclosure/CVE/legal sources (PRO track research, 2026-11-10)
metadata:
  type: reference
---

Work: justice.gov/jm/jm-9-48000-computer-fraud (the "-and-abuse-act" slug 404s); committee.iso.org/standard/72311.html and 69725.html (www.iso.org gives 403); certcc.github.io/CERT-Guide-to-CVD/ (vuls.cert.org redirects); projectzero.google/... (blogspot redirects); mitre.github.io/mitre-cve-roles/CNA-LR/ and /cve-id-request; docs.kernel.org/process/{cve,security-bugs}.html; docs.hackerone.com safe-harbor pages; raw.githubusercontent.com for curl policy; eur-lex works with `offset` param for long acts; theyworkforyou.com mirrors Hansard committees.

Trick: WebFetch cannot read FlateDecode PDFs (cve.org CNA rules). The tool saves the PDF under ~/.claude/projects/.../tool-results/; a short python -I script that zlib-decompresses streams and joins TJ strings recovers readable text (works for Word-generated PDFs). No pdftotext/pypdf on this machine.

Dead/blank: cve.org HTML pages (FAQ, glossary, CNA rules landing) render title only (JS); bughunters.google.com blog pages JS; justice.gov OPA press release blank; GitHub CVE-request docs URL 404.

Do not: curl with a spoofed User-Agent is blocked by the auto-mode classifier.

Conflicts to recheck: curl policy file still says HackerOne despite 2026-01 bounty end; CNA Rules 4.2.1 date (Oct 14/20/21 2026 in different places).
