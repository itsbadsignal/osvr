# Target shortlist: VD-10 first real bug hunt (Lane A library, Lane B network service)
Researched: 2026-11-10   Questions answered: 9/9   Feeds: VD-09, VD-10, CAP-01 lanes A and B (DR-0003)

## Query plan (answered below)
1. Which small C/C++ parsers/codecs are NOT in OSS-Fuzz and still active? (Lane A)
2. Which open-source network daemons / embedded web stacks run natively and are small enough to audit? (Lane B)
3. Per candidate: activity, size, OSS-Fuzz status, CVE history, security contact, CNA path, AI-report policy, build system, licence.
4. How crowded is each candidate right now (who else is reporting)?
5. How does a learner check a bug is novel? Which fetched references back the workflow?
6. How do suitability scores rank the candidates?
7. Which popular candidates should be excluded and why?
8. What did I not verify?
9. What does this change for VD-09/VD-10?

## Method and honesty notes
- Metrics were produced locally on 2026-11-10 from shallow clones (`git clone --depth 1`) of each upstream: last commit date, LOC (`*.c/*.cc/*.cpp/*.h/*.inl` line count, tests/fuzz/examples excluded; where I give a narrower "core" figure it is the named directory). LOC is a size estimate, not a complexity measure.
- OSS-Fuzz status: checked by listing `projects/` in a fresh sparse clone of `google/oss-fuzz` (1,403 project directories on 2026-11-10) and reading `project.yaml`. "Not in OSS-Fuzz" does not mean "never fuzzed": in-repo harnesses are reported separately.
- CVE counts: NVD CVE API 2.0 `keywordSearch` queried 2026-11-10. These are **keyword hits, noisy**: they include downstream products (e.g. D-Link firmware for GoAhead, OPNsense for dnsmasq) and sometimes CVEs filed against forks. Treat as order of magnitude. Counts "since 2023" use the NVD publish date.
- Nothing was built; every entry is `build: unverified`. The build system column comes from files present in the clone. The lab-engineer must verify before VD-10 content is written.
- GitHub REST API was rate-limited (60/h unauthenticated), so private-vulnerability-reporting status, release dates and issue counts were not queried; I use the SECURITY.md text and fetched pages instead.
- All scores are my judgement from the evidence cited; they are not measured time-to-first-bug data.

## Headline finding: the small-library space is being swept right now
Between 2026-10-07 and 2026-11-10 NVD published CVEs for exactly the sort of targets this shortlist would otherwise call "under-fuzzed": libxmp CVE-2026-111131, libmspack CVE-2026-110602 and CVE-2026-119602, tinyexr CVE-2026-110597, unarr CVE-2026-111273 and CVE-2026-111274, libsixel CVE-2026-110601 (all 2026-10-14 to 2026-10-30, mostly CNA `disclosure@vulncheck.com`), uhttpd CVE-2026-55612/55613/55614 (2026-10-30, GitHub CNA), dnsmasq CVE-2026-93009/93010/93011 (2026-10-29, Red Hat CNA), tinyproxy CVE-2026-125371 (published 2026-11-10 itself). Where a writeup is linked, the finder (an individual researcher, hackmd handle `haind-pwn`) says the unarr bugs came from manual source review confirmed with ASan, and that a 700 s run of the repo's own libFuzzer harness did not find them [unarr writeup, fetched]. I did not establish whether AI tooling was involved anywhere; treat that as unknown.
Implication: a first hunt on these targets will often find that the shallow bug was reported last month. This is a feature for VD-09 (novelty checks are a core skill) but it changes the success definition: negative-result reports and *variant analysis next to a fresh CVE* must be first-class outcomes of VD-10. A fresh CVE in a function is also a map of where the maintainer's earlier review was thin, and variants of it in sibling functions are the best-evidenced route to a novel bug.

## Lane A: small, under-fuzzed C/C++ libraries

Scores 1-5 (5 best) for: **F**uzz gap (less fuzzed), **R**esponsive maintainer/path, **S**mall reachable surface, **H**istory (recent bugs show bugs exist). Total /20. Contest column = recent third-party reporting.

| Rank | Project | F | R | S | H | Total |
|---|---|---|---|---|---|---|
| A1 | libmspack | 4 | 5 | 5 | 4 | 18 |
| A2 | libsixel | 4 | 4 | 4 | 5 | 17 |
| A3 | libde265 | 2 | 5 | 3 | 5 | 15 |
| A4 | unarr | 4 | 2 | 4 | 4 | 14 |
| A5 | tinyexr | 3 | 2 | 5 | 4 | 14 |
| A6 | libxmp | 4 | 2 | 3 | 4 | 13 (AI-policy flag) |
| A7 | libgsf | 4 | 3 | 4 | 3 | 14 |
| A8 | minizip-ng | 3 | 3 | 4 | 3 | 13 |
| A9 | libdeflate | 1 | 3 | 5 | 1 | 10 (negative control) |

Tie order (A4 to A8): by R then contest. R scores marked `unverified` where I could not see a maintainer reply.

### A1 libmspack (CAB/CHM/KWAJ/SZDD/LIT/HLP/OAB decompressors)
- Repo: https://github.com/kyz/libmspack (also bundled `cabextract`). Language C. Core `libmspack/mspack/` 10.8k LOC. Licence LGPL (COPYING.LIB in tree; no top-level LICENSE file).
- Activity: last commit 2026-07-21 (commit list fetched: UBSan casts, kwajd header pointer init 2026-06-15, salvage-mode fixes April 2026). Latest tag `v1.11` (git ls-remote). Debian tracker lists it as shipped (fetched).
- OSS-Fuzz: no `libmspack` directory in `projects/`; no fuzz dir in repo. Fuzzing coverage by the author or ClamAV (a heavy consumer) not established: `needs-lab-verification` / unknown.
- CVE history: NVD keyword hits 23 total, 2 since 2023. Recent: CVE-2026-110602 (uninitialized pointer free in `kwajd_open()`, 2026-10-14), CVE-2026-119602 (MS-ZIP uninitialized window disclosure, CWE-908, 2026-10-30, references issue kyz/libmspack#60, GHSA-xxh6-gw5r-86fm per that thread). Historic: 2015 and 2018 batches (Debian tracker lists CVE-2014-9556 through CVE-2019-1010305 as resolved).
- Disclosure/responsiveness: no SECURITY.md. Reports go to GitHub issues; issue #60 (opened 2026-10-21) got an owner reply on 2026-10-25 confirming the bug and planning a fix, and a CVE reservation noted 2026-11-03 [issue page, fetched]. Maintainer judged it low impact ("strictly a memory error"), so expect severity haggling.
- CNA: GitHub (GHSA) and VulnCheck have both assigned CVEs for it; otherwise MITRE CNA-LR.
- AI-report policy: none found in the repo.
- Build cost on laptop: low. Autotools (`autogen.sh`, `configure.ac`), no heavy deps. `build: unverified`.
- Why it ranks first: tiny, format-dense surface (Huffman/LZX/Quantum/MS-ZIP/LZSS decoders plus header parsers), a maintainer who answers within days, and a demonstrable stream of bugs, with obvious sibling-function variant work next to two 2026 fixes. Risk: two CVEs landed in October, so the cheap bugs in `kwajd`/`mszipd` are taken; the CHM/LIT/HLP/OAB/SZDD readers are the unexplored half.

### A2 libsixel (SIXEL image encoder/decoder)
- Repo: https://github.com/saitoha/libsixel. C. `src/` 29.7k LOC. Licence MIT-style (LICENSE and LICENSE.images in tree, text not read).
- Activity: last commit 2026-11-05. Latest tag `v1.8.7-r2` by tag sort (tags are irregular; treat as `unverified`).
- OSS-Fuzz: not in `projects/`. No in-repo fuzz dir.
- CVE history: 53 NVD keyword hits, 11 since 2023; GitHub Advisory Database search shows 46 libsixel advisories, newest 2026-10-14 (fetched). Examples: CVE-2026-110601 (gif_init_frame heap OOB write), CVE-2026-44636/44637/44638 (integer overflow and NULL-check bugs, GHSA, 2026-05-14).
- Security policy: SECURITY.md (read in full): use GitHub Private Vulnerability Reporting; include a PoC file (they may add it to the test suite unless you opt out); DoS, OOM, leaks, infinite loops and decode failures are explicitly NOT treated as vulnerabilities and go to public issues. Note the archived upstream fork `libsixel/libsixel` is separate: test the right repo.
- CNA: GitHub. AI policy: none found.
- Build: autotools (`autogen.sh`, `configure`). Image loaders pull optional deps (libpng, libjpeg, gdk-pixbuf, curl); build minimal to keep it cheap. `build: unverified`.
- Caveat: heavily reported (46 advisories). Many are memory-safety; the policy excludes DoS, which filters out the shallowest class.

### A3 libde265 (H.265/HEVC decoder)
- Repo: https://github.com/strukturag/libde265. C++. `libde265/` 57k LOC. Licence LGPL (COPYING).
- Activity: last commit 2026-09-30; latest tag `v1.1.3`.
- OSS-Fuzz: not in `projects/` (libheif, which embeds it, is), but the repo has `fuzzing/` with libFuzzer and AFL scripts (`scripts/fuzz-libfuzzer.sh`, `scripts/fuzz-afl.sh`).
- CVE history: 67 NVD hits, 33 since 2023, 12 since 2025. Recent: CVE-2026-45383 (WPP slice OOB read, GHSA-wg9q-ppqw-6q38), CVE-2026-54240/54241 (signed 32-bit arithmetic, 2026-09-11).
- Policy: SECURITY.md (read): private GitHub vulnerability reporting preferred, email `dirk.farin@gmail.com` alternative; only latest master supported; encoder out of scope; credit given. Responsive: maintainer publishes GHSAs.
- CNA: GitHub. AI policy: none found.
- Build: CMake. `build: unverified`.
- Caveat: the most contested of the A-lane (33 CVEs since 2023). Good for variant analysis and for learning to read a decoder; poor odds for a brand-new shallow bug. Larger, more stateful surface than A1.

### A4 unarr (RAR/ZIP/TAR/7z reader, selmf fork)
- Repo: https://github.com/selmf/unarr. C. 20.4k LOC. Licence LGPL (COPYING).
- Activity: last commit 2026-11-01; tag `v1.2.0`.
- OSS-Fuzz: not in `projects/`; in-repo `test/fuzzer.c` exists. The finder of CVE-2026-111273/111274 reports that the repo harness ran 700 s without hitting them [writeup, fetched], which is evidence that harness coverage is shallow.
- CVE history: 3 NVD hits, both 2026 CVEs on 2026-10-15 (off-by-one in `tar_get_name()`, OOB read in `zip_parse_extra_fields()`); other hit is a Go binding.
- Policy: no SECURITY.md. Responsiveness `unverified`. CNA: VulnCheck assigned the 2026 pair; otherwise GitHub or MITRE CNA-LR. AI policy: none found.
- Build: CMake. `build: unverified`.
- Caveat: the cheapest ZIP/TAR parser bugs are fresh CVEs; RAR and 7z (LZMA SDK) paths were not in the cited reports.

### A5 tinyexr (OpenEXR loader, single header)
- Repo: https://github.com/syoyo/tinyexr. C++11. `tinyexr.h` 11.7k LOC (clone total is inflated by bundled third-party code). Licence BSD (LICENSE, not read in detail).
- Activity: last commit 2026-11-09; tag `v3.4.0`.
- OSS-Fuzz: not as its own project (OpenEXR is). In-repo `test/fuzzer/` holds regression files from past issues (`issue176-heap-buffer-overflow` etc.).
- CVE history: 14 NVD hits, 1 since 2023 under that keyword; recent CVE-2026-110597 (multipart header stale-size OOB read, 2026-10-14, writeup on hackmd), older 2020 and 2022 OOB read/overflow bugs.
- Policy: no SECURITY.md. GitHub issues page showed 0 open issues when fetched (may mean quick closure or disabled issues; `unverified`). CNA: VulnCheck assigned the latest; otherwise MITRE CNA-LR. AI policy: none found.
- Build: CMake or Makefile; header-only so cheapest of all. `build: unverified`.
- Caveat: many EXR compression modes (PIZ, PXR24, B44, ZIP, RLE) give real variant surface; maintainer response unverified.

### A6 libxmp (tracker-module player)
- Repo: https://github.com/libxmp/libxmp. C. `src/` 99k LOC (hundreds of format loaders and depackers; scope to a subset). Licence in tree not read (no top-level LICENSE file in the clone listing).
- Activity: last commit 2026-11-04; version 4.7.4 in `configure.ac`; tags `libxmp-4.7.4`.
- OSS-Fuzz: not in `projects/`. In-repo `test-dev/` contains fuzzer-derived regression tests (`test_fuzzer_xm_*`), so the project does fuzz and keeps regressions.
- CVE history: 3 NVD hits: CVE-2026-111131 (P61A depacker, 2026-10-15), CVE-2025-47256 (`depack_pha` stack overflow, 2025-05-06), CVE-2013-1980.
- Policy: no SECURITY.md. **CONTRIBUTING.md prohibits issues, PRs or docs created with LLMs / "agent" tools** (section "LLM policy", read). A learner who drafts reports with an assistant would violate it. Responsiveness `unverified`.
- Build: autotools/CMake. `build: unverified`.
- Caveat: AI policy changes the VD-07 workflow: coach must tell the learner to write this report by hand.

### A7 libgsf (GNOME structured-file library: OLE2, ZIP, XML)
- Repo: https://gitlab.gnome.org/GNOME/libgsf. C (GObject). `gsf/` 27k LOC. Licence LGPL (COPYING).
- Activity: last commit 2026-10-14; tag `LIBGSF_1_14_60`.
- OSS-Fuzz: not in `projects/`; no fuzz dir.
- CVE history: 2 NVD keyword hits; the new one is CVE-2026-116124 (`ole_info_read_metabat`, up to 1.14.60, published 2026-10-26, CNA VulDB). Real history is bigger (used by AbiWord, Gnumeric, librsvg stack) but the keyword search under-counts: `needs-lab-verification`.
- Policy: BUGS file says to use GNOME GitLab issues (read). Public tracker; no SECURITY.md in tree. AI policy: none found in tree (GNOME-wide policy not checked). CNA: MITRE CNA-LR or the VulDB route used above.
- Build: autotools; needs glib and libxml2. `build: unverified`.

### A8 minizip-ng (ZIP library, zlib-ng project)
- Repo: https://github.com/zlib-ng/minizip-ng. C. ~19.6k LOC. Licence zlib-style (LICENSE).
- Activity: last commit 2026-11-09 ("strm_mem: prevent overflow when reopening smaller memory streams"); tag `4.2.2`.
- OSS-Fuzz: not its own project; in-repo `test/fuzz/` has `zip_fuzzer.c`, `unzip_fuzzer_seed_corpus` and a dictionary: fuzzed at least in CI.
- CVE history: 2 NVD hits (CVE-2023-48106/48107, MITRE-assigned, v4.0.2). Validity of those two is `unverified` (generic MITRE-style records).
- Policy: no SECURITY.md. The repo contains a `CLAUDE.md`, so maintainers use AI tooling; no policy on inbound reports read. CNA: GitHub (zlib-ng org) or MITRE CNA-LR.
- Build: CMake, optional deps (zlib, bzip2, lzma, zstd, openssl). `build: unverified`.
- Value: many sub-features (AES encryption, PKWARE crypt, split archives, memory streams, PPMd) beyond the basic ZIP reader.

### A9 libdeflate (negative control, not recommended as the first target)
- Repo: https://github.com/ebiggers/libdeflate. C. 18k LOC. Licence in tree is MIT-style (COPYING).
- Activity: last commit 2026-11-09; tag `v1.26`. In-repo libFuzzer harnesses (`scripts/libFuzzer/`). Not in OSS-Fuzz `projects/`. NVD keyword hits: 0. Included so VD-09 learners can see what a well-tested small library looks like (author-maintained fuzzing, no CVE record) and write a negative-result report with coverage evidence.

### Lane A excluded (reason)
- libarchive, libpng, libwebp, libtiff, libxml2, expat, zlib, zlib-ng, zstd, lz4, libyaml, cJSON, yyjson, jansson, miniz, stb, lodepng, libspng, libplist, libjxl, openjpeg, libheif, libvips, libraw, libsndfile, mpg123, flac, wavpack, opus, taglib, exiv2, ffmpeg: all have an OSS-Fuzz project directory (checked by `ls projects/`), meaning continuous fuzzing at scale; field-overview already ranks popular parsers as the most contested space [field-overview rank 2].
- libqrencode: last commit 2020-09-28, last tag v4.1.1 (stale; no one to disclose to).

## Lane B: open-source network services and embedded web stacks

Scores as above: **F** fuzz gap, **R** responsive, **S** small reachable surface, **H** history. Plus logic-bug richness noted in text (command injection, auth, smuggling, traversal), per DR-0003.

| Rank | Project | F | R | S | H | Total |
|---|---|---|---|---|---|---|
| B1 | tinyproxy | 5 | 5 | 5 | 5 | 20 |
| B2 | uhttpd (OpenWrt) | 5 | 4 | 5 | 4 | 18 |
| B3 | miniupnpd | 5 | 3 | 4 | 4 | 16 |
| B4 | BusyBox httpd/udhcp (official git) | 4 | 2 | 5 | 4 | 15 |
| B5 | GoAhead | 4 | 3 | 4 | 3 | 14 |
| B6 | Pure-FTPd | 5 | 3 | 4 | 2 | 14 |
| B7 | lwIP applications (SNMP/mDNS/etc.) | 3 | 2 | 4 | 4 | 13 |
| B8 | dnsmasq | 2 | 4 | 3 | 5 | 14 |
| B9 | CivetWeb | 2 | 3 | 3 | 4 | 12 |

Ordering within equal totals favours the smaller surface. B8 (dnsmasq) scores 14 but is placed below B5/B6 only on beginner-suitability grounds (see its entry).

### B1 tinyproxy (HTTP/HTTPS forward proxy)
- Repo: https://github.com/tinyproxy/tinyproxy. C. `src/` ~10k LOC. Licence GPL-2.0-or-later (COPYING, header not read; confirm).
- Activity: last commit 2026-11-10; latest tag `1.11.3`.
- OSS-Fuzz: not in `projects/`; no fuzz dir in repo.
- CVE history: 15 NVD hits, 8 since 2023, 7 since 2025. Recent: batch on 2026-06-17 with fix commits: CVE-2026-55202 (stathost Host header validation, fix 09312a1), CVE-2026-54388 (multiple differing Content-Length, fix 364cdb6), CVE-2026-54387 (CL plus chunked TE, fix ff45d3b); CVE-2026-125371 (ACL hostname suffix match without label boundary check, CWE-187, published 2026-11-10, fix 3991ac8). Fixes are named in NVD descriptions.
- Policy: SECURITY.md (read): **open a public GitHub issue**; maintainers promise a fix typically within a day; private contact only via IRC. It explicitly criticises coordinated email disclosure (names Talos). This is the exception to the usual private-first path: a learner needs the PRO-04 conversation about project-set disclosure terms. Responsiveness evidence: multiple fix commits tied to June 2026 CVEs.
- CNA: VulnCheck assigned the 2026 CVEs; MITRE CNA-LR otherwise.
- AI policy: none found.
- Build: autotools (`autogen.sh`, `configure.ac`). `build: unverified`; Docker feasible.
- Why first: tiny, one binary, parse-heavy (request line, headers, chunked encoding, ACLs, reverse proxy, upstream, basic auth), no memory-safety prerequisite for logic bugs (smuggling, ACL, header injection), runs on loopback. Risk: it is being picked over now (7 CVEs since 2025, one published today); novelty-check discipline is mandatory.

### B2 uhttpd (OpenWrt HTTP server, with ubus/ucode/Lua/CGI plugins)
- Repo: https://github.com/openwrt/uhttpd (clone from https://git.openwrt.org/project/uhttpd.git). C. Core ~7.6k LOC. Licence: not found in clone root (no LICENSE file); licence not established (`unverified`): read the source headers before publishing.
- Activity: last commit 2026-11-05; no tags (rolling snapshot).
- OSS-Fuzz: not in `projects/`; no fuzz dir.
- CVE history: 19 NVD hits (many are vendor firmware), 6 since 2023. Recent: CVE-2026-55612/55613/55614 (2026-10-30, GitHub CNA, GHSA-mcfg-c4r7-pjpf for the CWE-444 mixed-case `Transfer-Encoding` bug, with two fix commits). The CVE text says "In unpatched repository snapshots".
- Policy: advisories published through GitHub Security Advisories on `openwrt/uhttpd`. OpenWrt's own security page was blocked by an anti-bot page, so contact route `unverified`.
- CNA: GitHub. AI policy: none found.
- Build: CMake; depends on libubox, json-c, optionally ubus/ucode/Lua: build cost medium (dependency chain). `build: unverified`.
- Why: the exact class (embedded web stack) that appliances ship: request parsing, CGI environment, auth, ubus JSON-RPC, path traversal in file handling. Same caveat: just swept on 2026-10-30.

### B3 miniupnpd (UPnP IGD / NAT-PMP / PCP daemon)
- Repo: https://github.com/miniupnp/miniupnp (daemon in `miniupnpd/`). C. `miniupnpd/` 36.9k LOC. Licence BSD-3 style (LICENSE; not read in full).
- Activity: last commit 2026-11-10; tag `miniupnpd_2_3_11`.
- OSS-Fuzz: no `miniupnp` in `projects/` (`pupnp`, a different library, is). No fuzz dir.
- CVE history: 18 NVD hits, 4 since 2023 (mix with vendor router CVEs). Recent: CVE-2026-107159 (divide-by-zero in `ProcessSSDPData()` with `MX: 0`, built with `--strict`, 2026-10-07), CVE-2026-5720 (integer underflow in SOAPAction parsing, 2026-04-17).
- Policy: SECURITY.md (read): email `miniupnp@free.fr`, GPG key provided; only 2.3.x supported. No stated response SLA; responsiveness `unverified`.
- CNA: VulnCheck assigned the recent two; MITRE CNA-LR otherwise.
- AI policy: none found.
- Build: Makefile.linux / Makefile.linux_nft; needs iptables/nftables libs to build and root/netns to run properly: medium, Docker with `--cap-add=NET_ADMIN` is the natural lab. `build: unverified`.
- Why: SSDP (UDP multicast), SOAP/HTTP over TCP, XML-ish parsing: both memory-safety and logic classes; NVD shows 18 keyword hits including router-vendor CVEs. Lab parity with embedded targets is high.

### B4 BusyBox httpd, udhcpd/udhcpc, ntpd, telnetd applets
- Repo: official `https://git.busybox.net/busybox` (last commit 2026-11-10, tag `1_38_0`). **The GitHub mirror `mirror/busybox` is stale: last commit 2024-07-14 in my clone**; use the official git. C. `networking/httpd.c` 3.2k lines; `networking/udhcp/` 8.3k lines. Licence GPL-2.0.
- OSS-Fuzz: no `busybox` directory. No fuzz dir.
- CVE history: 97 NVD hits (noisy: many are downstream products), 50 since 2023; recent BusyBox-specific: CVE-2026-124747 (wget FTP resume, 2026-11-10, Red Hat), CVE-2026-88842 (dpkg applet, 2026-10-14, Red Hat), CVE-2026-92205 (libarchive symlink traversal, ZDI, 2026-10-21).
- Policy: `busybox.net/security.html` returned 404; no SECURITY.md. Contact route (mailing list/bugzilla) `unverified`: not confirmed by fetch.
- CNA: Red Hat has been assigning; MITRE CNA-LR otherwise.
- AI policy: unknown.
- Build: Kconfig; small custom `.config` keeps build cost low. `build: unverified`.
- Caveat: unresponsiveness risk and unclear private channel; but applets are small, and the code runs in QEMU user-mode trivially (VD-08 synergy).

### B5 GoAhead (Embedthis embedded web server)
- Repo: https://github.com/embedthis/goahead. C. `src/` 38.7k LOC. Licence: LICENSE.md present, text not read (`unverified`; Embedthis sells commercial editions, so check terms).
- Activity: last commit 2026-11-07; tag `v6.1.1`.
- OSS-Fuzz: not in `projects/`. Repo has a CGI fuzz-replay regression test only.
- CVE history: 59 NVD hits, 13 since 2023, but most are *vendor devices embedding GoAhead* (D-Link, MeiG), not GoAhead itself; earlier GoAhead-specific history was not fetched: `unverified`.
- Policy: SECURITY.md (read): private email `security@embedthis.com`; advisories as `GOAHEAD-SA-YYYY-NNNN` through GitHub Security Advisories; name a numbered release (evaluation edition is not triaged); only the current release is supported. Hardening guide in `SECURITY-DEPLOYMENT.md`.
- CNA: GitHub advisories (check coverage). AI policy: none found.
- Build: top-level Makefile using Embedthis `me`/`make` conventions. `build: unverified`.
- Why: designed to ship inside appliances; the learner audits route/auth/session/CGI/upload code for lane-B logic bugs. Disclosure contact is explicit.

### B6 Pure-FTPd
- Repo: https://github.com/jedisct1/pure-ftpd. C. ~33k LOC. Licence BSD-style (COPYING, not read).
- Activity: last commit 2026-11-04; tag `1.0.54`.
- OSS-Fuzz: no. No fuzz dir. NVD hits: 12 (3 recent-ish: CVE-2024-48208 `domlsd()` OOB read in `ls.c`, 1.0.52). One other hit is Froxlor misconfiguration, not the daemon.
- Policy: no SECURITY.md; pureftpd.org project page showed no security contact (fetched). Contact via maintainer on GitHub `unverified`.
- Build: autotools. Runs unprivileged on a high port in Docker. `build: unverified`.
- Value: stateful FTP command parsing (`ls` glob expansion, MLSD, quotas, TLS). Low recent history; good fuzz-gap, low expected yield.

### B7 lwIP (embedded TCP/IP stack and apps: SNMP, mDNS, SMTP, HTTPD, MQTT)
- Repo: https://github.com/lwip-tcpip/lwip (Savannah is the canonical home; GitHub is a mirror, `unverified`). C. `src/` 136k LOC, `src/apps/` 30k. Licence BSD-3 (COPYING, not read).
- Activity: last commit 2026-11-08. Releases tagged oddly; latest stable stated by NVD CVEs as 2.2.1.
- OSS-Fuzz: no. In-repo `test/fuzz/` has a harness with `inputs/` and `output_to_pcap.sh`: some fuzzing for the core stack.
- CVE history: 13 NVD hits, 10 since 2023, 9 since 2025. Recent: CVE-2026-119053 (SNMP agent `snmp_pbuf_stream_writeto()` OOB read, 2026-10-29), CVE-2026-112062 (mDNS `mdns_handle_response` stack OOB write, 2026-10-18), CVE-2026-15340 (SMTP client unchecked sizes, ICS-CERT, 2026-10-09). The three are separate CNAs (VulnCheck, CISA ICS-CERT), so multiple groups are active here.
- Policy: not found; Savannah bug tracker `unverified`. AI policy: none found.
- Build: CMake plus a Unix port (`contrib/ports/unix`); can run as a Linux userspace TCP/IP stack with tap. Build cost medium. `build: unverified`.
- Note: vendor SDKs (ESP-IDF CVE-2026-113783) fork lwIP, so ownership of a fix is ambiguous.

### B8 dnsmasq (DNS forwarder, DHCP, RA, TFTP)
- Repo: git://thekelleys.org.uk/dnsmasq.git (cloned over https from `https://thekelleys.org.uk/git/dnsmasq.git`). C. `src/` 47.9k LOC. Licence GPL-2.0 or GPL-3.0 (COPYING and COPYING-v3).
- Activity: last commit 2026-11-02; tags up to `v2.93test10` (2.93 released; CHANGELOG has a 2.94 section).
- OSS-Fuzz: **yes**, `projects/dnsmasq` (primary contact `simon@thekelleys.org.uk`, C, fuzzing engines configured).
- CVE history: 79 NVD hits (noisy), 37 since 2023, 35 since 2025. Recent: CVE-2026-93009 (DHCPv6 FQDN OOB read), CVE-2026-93010, CVE-2026-93011 (DNSSEC validator write past buffer), all 2026-10-29, CNA Red Hat. CHANGELOG itself credits outside finders and cites CNVD-C-2026-590208 and CVE-2026-12969.
- Policy: no SECURITY.md; project docs say mailing list `dnsmasq-discuss` first, or email the maintainer `simon@thekelleys.org.uk`; whether security reports should go private is not stated (fetched doc page). AI policy: none found.
- Build: Makefile, no heavy deps (`make`). `build: unverified`.
- Beginner suitability: low. In OSS-Fuzz and being swept (35 NVD hits since 2025). Keep as the "variant analysis on a hot target" option for learners who want hard mode.

### B9 CivetWeb (embeddable HTTP/WebSocket server)
- Repo: https://github.com/civetweb/civetweb. C. `src/civetweb.c` 23k lines (1.0M-line clone total is bundled third-party). Licence MIT (LICENSE.md).
- Activity: last commit 2026-04-19; latest tag `v1.16`. Slower cadence.
- OSS-Fuzz: **yes**, `projects/civetweb`; also `fuzztest/` in repo.
- CVE history: 9 NVD hits, 6 since 2023. Recent: CVE-2026-124040 (HTTP/2 UAF, `USE_HTTP2`, 2026-11-06), CVE-2026-29035 (WebSocket permessage-deflate overflow with `USE_ZLIB` plus experimental option, 2026-08-11, vulncheck.com advisory). Bugs concentrate in options the SECURITY.md labels experimental.
- Policy: SECURITY.md (read): defects fixed on head; releases get selected fixes; core files `civetweb.c` and `src/*.inl` get the strictest scrutiny; example and test folders explicitly out of scope. No private reporting channel stated in the part I read.
- Build: Makefile/CMake. `build: unverified`.
- Ranked low: OSS-Fuzz plus sweeps. Included to teach scoping (experimental features are in scope only if enabled by default: learners must read the policy).

### Lane B excluded (reason)
- Mongoose (cesanta): 38k-line single file, OSS-Fuzz project, SECURITY.md promises same-day response but a vendor-commercial disclosure ordering (eligible customers get a private fix one month before the CVE becomes public) and states AI-assisted PR review, 47 NVD hits. Good, but crowded and commercially entangled. Fine as a stretch target.
- Mosquitto (Eclipse): OSS-Fuzz project plus in-repo `fuzzing/`; Eclipse PSIRT is the CNA (Eclipse security page, fetched). Well-handled disclosure path, ideal for PRO-06 practice, but heavily audited. Fine as a stretch target.
- lighttpd, libmicrohttpd, dropbear, haproxy, ntpsec, proftpd, net-snmp, openssh: OSS-Fuzz projects (`ls projects/`).
- Vendor firmware / proprietary appliances: lane C, not here.
- Anything that suggests testing a live third-party host: excluded by D10. Shodan-style scanning is out of scope for this curriculum.

## Recommended default shortlist for VD-10 (research opinion, architect to decide)
- Lane A default: **libmspack (A1)** for a first hunt, **libsixel (A2)** as the alternative with GitHub-private-report workflow. Offer **unarr** or **tinyexr** where the learner wants decoder variety.
- Lane B default: **tinyproxy (B1)** (logic bugs, tiny, public-issue disclosure path) then **uhttpd (B2)**. **miniupnpd (B3)** for learners who want a daemon with real router history.
- Each learner picks via the VD-09 scorecard: the scorecard fields below come from what this research actually had to look up.

### VD-09 scorecard fields that proved necessary
1. Last commit date and release tag; local build time.
2. In OSS-Fuzz? (`projects/<name>/project.yaml`) and in-repo harness/corpus.
3. NVD keyword count and the *last 90 days* of CVEs (sweep detection).
4. SECURITY.md or contact; public-issue versus private; CNA path; response evidence (reply dates on a recent issue).
5. AI/LLM policy for inbound reports (libxmp forbids; mongoose mentions AI review; the rest silent).
6. Scope hints: experimental features, example code, test dirs (civetweb), unsupported branches (miniupnpd < 2.3, tinyproxy <= 1.10.x).
7. Fork identity (libsixel archived fork; unarr is a fork; lwIP forked into vendor SDKs).

## Novelty-check workflow (how to confirm a bug is not already fixed or reported)
Order to run before writing any report; each step is a source the learner can reproduce. All pages below were fetched on 2026-11-10 unless marked.
1. **Test on upstream HEAD, then on the latest release tag.** A bug that no longer reproduces on master is already fixed. Cite: commit lists fetched for libmspack show fixes landing between releases (https://github.com/kyz/libmspack/commits/master).
2. **Search the repo history**: `git log --all --grep=<function>` and `git log -S<symbol>` on the function; read CHANGELOG/NEWS (dnsmasq `CHANGELOG` lists recent fixes with credits and CVE numbers; checked in clone).
3. **Search the project issue tracker and advisories**: GitHub issues (example: kyz/libmspack#60 shows a bug reported, acknowledged and CVE-linked within days: https://github.com/kyz/libmspack/issues/60) and the repo's `security/advisories` page. GitHub Advisory Database search (https://github.com/advisories?query=libsixel).
4. **NVD CVE API / search by keyword and date**: `https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=<name>&pubStartDate=...` (response shape confirmed by calling it; the NVD docs pages `https://nvd.nist.gov/developers/vulnerabilities` and `/api-workflows` returned only a JS shell when fetched, so rate-limit rules are `unverified`; I observed requests succeeding at one per 7 to 8 seconds without a key).
5. **Distro trackers** for a source-package view of CVE status per release: Debian Security Tracker (https://security-tracker.debian.org/tracker/source-package/libmspack, example fetched). Ubuntu and Red Hat trackers: not fetched, `unverified`.
6. **oss-security archive** (https://www.openwall.com/lists/oss-security/; fetched; 35,126 messages as of fetch; browse by month, no on-page search): public disclosure announcements and distro discussion; use web search restricted to the domain for keyword search.
7. **OSS-Fuzz findings** for projects in OSS-Fuzz: issues become public 90 days after report or on fix (bug-disclosure policy, https://google.github.io/oss-fuzz/getting-started/bug-disclosure-guidelines/, 14-day grace extension). Reproducing a testcase and rebuilding fuzzers locally is documented at https://google.github.io/oss-fuzz/advanced-topics/reproducing/ (`helper.py reproduce`). The issue tracker UI at issues.oss-fuzz.com was not fetched (needs JS/login); the monorail host is gone from the docs link set, so `unverified` which tracker the docs currently reference. Embargoed OSS-Fuzz bugs are invisible until disclosure, so absence from the tracker is weak evidence.
8. **Writeup search**: independent researchers publish on hackmd/blogs before or after CVE assignment (e.g. https://hackmd.io/@haind-pwn/unarr-tar-zip-oob and `.../tinyexr-multipart-header-stale-size-oob-read`, the first fetched, the second only referenced from NVD).
9. **Compare on the exact function and version**: a duplicate is the same root cause, not the same symptom. If the maintainer's fix does not cover your input, you have a variant (report as such, citing the earlier CVE).
10. **CNA path if none exists**: ask the vendor first; GitHub is a CNA and can assign CVEs for repository security advisories unless another CNA already covers the project (https://docs.github.com/en/code-security/security-advisories/working-with-repository-security-advisories/about-repository-security-advisories); MITRE CNA-LR assigns for suppliers that are not CNAs and may take the discoverer's request if the supplier cannot be reached or declines (https://mitre.github.io/mitre-cve-roles/CNA-LR/; the request form is linked from https://mitre.github.io/mitre-cve-roles/); VulnCheck acts as a CNA for vulnerabilities reported to it that no other CNA covers (web search summary only; its own pages did not state the scope: `unverified`). CNA-LR will not publish a record for an undisclosed bug.
11. **Eclipse projects** (Mosquitto) use the Eclipse PSIRT and Eclipse's CNA (https://www.eclipse.org/security/).

## Open questions / unverified
- Time-to-first-bug on any listed target has no data; scores are judgement.
- Responsiveness `unverified`: unarr, tinyexr, libxmp, libgsf, minizip-ng, uhttpd, BusyBox, Pure-FTPd, lwIP, GoAhead (no maintainer reply observed).
- Licences read only by filename for most repos. The lab-engineer or builder must read each LICENSE before the module cites it.
- Whether the October 2026 reporting wave involves AI-assisted discovery: not established. Source for the "who" is the NVD references and one hackmd page.
- Build cost: all `build: unverified`. Verify in a throwaway container with ASan (`-fsanitize=address,undefined`) before module content is written.
- OpenWrt security reporting page blocked (anti-bot); BusyBox `/security.html` 404; NVD API doc pages and cve.org FAQ pages returned shells; vulncheck.com/cna 404. Manual fetch suggested: https://openwrt.org/docs/guide-developer/security, https://www.busybox.net/, https://www.vulncheck.com/vulnerability-disclosure-policy, https://www.cve.org/ResourcesSupport/FAQs.
- Frontier AI Researcher CNA pilot (https://www.cve.org/Resources/Roles/Cnas/FrontierAiResearcherCNAsPilot.pdf) appeared in search; PDF could not be parsed through WebFetch (binary saved locally by the tool). It may matter for DR-0002 (AI-assisted reporting). Needs manual reading.

## Sources (fetched 2026-11-10 unless stated)
- Local shallow clones of all listed repos and `google/oss-fuzz` (sparse `projects/`): commit dates, LOC, SECURITY/CONTRIBUTING texts, `project.yaml`, tags via `git ls-remote`.
- NVD CVE API 2.0 (keyword queries and per-CVE records), https://services.nvd.nist.gov/rest/json/cves/2.0
- https://github.com/google/oss-fuzz/tree/master/projects (listing page truncated; clone used)
- https://google.github.io/oss-fuzz/getting-started/bug-disclosure-guidelines/
- https://google.github.io/oss-fuzz/advanced-topics/reproducing/
- https://google.github.io/oss-fuzz/getting-started/accepting-new-projects/
- https://docs.github.com/en/code-security/security-advisories/working-with-repository-security-advisories/about-repository-security-advisories
- https://mitre.github.io/mitre-cve-roles/ and https://mitre.github.io/mitre-cve-roles/CNA-LR/
- https://www.vulncheck.com/advisories
- https://www.eclipse.org/security/
- https://www.openwall.com/lists/oss-security/
- https://github.com/kyz/libmspack/issues/60 and /commits/master
- https://hackmd.io/@haind-pwn/unarr-tar-zip-oob
- https://github.com/syoyo/tinyexr/issues (0 open shown; interpretation uncertain)
- https://security-tracker.debian.org/tracker/source-package/libmspack
- https://github.com/advisories?query=libsixel
- https://thekelleys.org.uk/dnsmasq/doc.html
- https://www.pureftpd.org/project/pure-ftpd/ (no security info)
- Failed or empty: https://openwrt.org/docs/guide-developer/security (anti-bot block), https://www.busybox.net/security.html (404), https://www.vulncheck.com/cna (404), https://nvd.nist.gov/developers/* and https://www.cve.org/ResourcesSupport/* (JS shells), https://cveform.mitre.org/ (redirect to mitre-cve-roles).
