---
name: glibc-bx-sources
description: Working routes for glibc/kernel/distro mitigation research (tag-by-tag malloc.c, ftp.gnu.org tarballs, podman probes, distro APIs) and dead ends, 2026-11-10
metadata:
  type: reference
---

Works (no auth):
- glibc source per tag: `raw.githubusercontent.com/bminor/glibc/glibc-X.YY/<path>` (tags, not `release/X.YY/master`, which is the stable branch with backports). The bminor mirror is stale (last commit 2026-01, no 2.43 tag): get 2.43/2.44 from `ftp.gnu.org/gnu/glibc/glibc-2.4X.tar.xz` and `tar -xJf ... glibc-X/NEWS glibc-X/malloc/malloc.c`. glibc CVE advisories with Fix-Commit lines: `bminor/glibc/master/advisories/GLIBC-SA-*`.
- Scan every tag's `malloc_printerr("...")` strings in Python to date each integrity check (reproducible, T1).
- how2heap: raw README.md (version column, patch links) and `api.github.com/repos/shellphish/how2heap/contents/glibc_2.NN` for which files exist per version.
- Distro versions: Arch `archlinux.org/packages/core/x86_64/glibc/json/`; Debian `sources.debian.org/api/src/glibc/`; Ubuntu Launchpad `getPublishedSources`; Fedora `mdapi.fedoraproject.org/f45/pkg/glibc` (no f33 record); NVD `services.nvd.nist.gov/rest/json/cves/2.0?cveId=`.
- Kernel docs/source via `raw.githubusercontent.com/torvalds/linux/master/...` (shstk doc is `Documentation/arch/x86/shstk.rst`).
- podman works on this host (docker absent): `podman run --rm -v DIR:/probe:Z docker.io/library/<debian:trixie|ubuntu:26.04|fedora:45|archlinux:latest> sh /probe/x.sh apt|dnf|pacman`; ~1 min each, can run in parallel. Host CPU has user_shstk and ibt, so CET behaviour can be tested for real.

Dead ends: GitHub REST API rate limit 60/h unauthenticated (burned quickly by commit lookups; use `github.com/<org>/<repo>/commit/<sha>.patch` via curl instead); no `gh` CLI; thekelleys.org.uk dnsmasq gitweb = anti-scraper login wall; wiki.ubuntu.com ToolChain/CompilerFlags 404 to curl; mdapi f33 missing; WebFetch of security.googleblog.com returns no article body; `rm` of scratch output via cd+glob is blocked by the safety check (write to a fresh dir instead).

Shell gotchas: zsh does not word-split `set -- $spec`, and `==`/`=====` in echo are parsed as commands; use functions with positional args.
