---
name: re-tooling-fetch-tricks
description: Working ways to verify tool status, fix commits, OST2 courses and PDFs in the sandbox, and dead ends (found 2026-11-10)
metadata:
  type: reference
---

- GitHub API is unauthenticated, 60 req/h, and runs out fast (no `gh`). Fallback: `git clone --bare --filter=blob:none [--depth 1]` into the scratchpad, then `git log`/`show --stat`/`tag --contains`. Works for sudo, glibc, curl, libwebp (chromium.googlesource), polkit (gitlab.freedesktop.org), ltrace (gitlab.com/cespedes).
- NVD HTML is JS-only; `https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=...` works (sleep ~7s between calls); gives CWE and cisaExploitAdd. cveawg.mitre.org/api/cve/<id> also works.
- arXiv PDFs come back binary (no pdftotext/pypdf here); use `https://ar5iv.labs.arxiv.org/html/<id>` (WebFetch, paginates with offset). USENIX slide PDFs are unreadable the same way.
- OST2: `https://ost2.fyi/<CourseCode>` is a short-URL page whose og:description gives the exact title (curl + grep); real course `about` pages at p.ost2.fyi/courses/course-v1:... fetch OK, bodies need login. p.ost2.fyi/catalog 404. Learning-path pages are images.
- snapshot.debian.org/package/<src>/<ver>/ lists amd64 .deb and -dbgsym links: good for old/new binary pairs.
- sourceware gitweb is blocked by Anubis; use github.com/bminor/glibc clone. pwn.college /program-security/debugging-refresher/ 404s; /program-security/reverse-engineering/ works.
- Ghidra course slides are JS-rendered (only listing verifiable).
- Binary Ninja/IDA Free product pages fetch fine via WebFetch.
