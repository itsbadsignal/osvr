---
name: target-research-apis
description: What worked/failed when gathering OSS target metrics (NVD API, GitHub API, OSS-Fuzz listing, clones) on 2026-11-10
metadata:
  type: reference
---

- GitHub REST API unauthenticated limit (60/h) is exhausted fast; use `git clone --depth 1`, `git ls-remote --tags`, and WebFetch of github.com pages instead. `gh` is not installed.
- OSS-Fuzz status: `git clone --depth 1 --filter=blob:none --sparse https://github.com/google/oss-fuzz` then `sparse-checkout set projects`; `ls projects | grep`. 1,403 dirs on 2026-11-10.
- NVD CVE API 2.0 (`services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=` or `cveId=`) works with curl, no key, about 1 request per 7s is OK. Keyword counts are noisy (downstream products).
- WebFetch returns only JS shells for nvd.nist.gov/developers and cve.org pages; openwrt.org blocked by Anubis; busybox.net/security.html 404. mitre.github.io/mitre-cve-roles works.
- GitHub `mirror/busybox` is stale (2024); use git.busybox.net.
- Finding: Oct 2026 saw a wave of VulnCheck/GHSA/Red Hat CVEs on small libs (libxmp, libmspack, unarr, tinyexr, libsixel, uhttpd, dnsmasq, tinyproxy); output in research/targets/VD.md.
