# Domain map: Reverse engineering (RE-01 to RE-04)
Researched: 2026-11-10   Questions answered: 9/11 fully, 2/11 partially (see Q status)
Mode: BUILD / metalearning. Author: researcher agent. Every figure below was read from a page fetched on 2026-11-10 unless marked `unverified` or `needs-lab-verification`. Tool versions and dates are as of that day.

## Question plan (written before searching)
- Q1 What are current releases, licences and maintenance status of Ghidra, Binary Ninja Free, IDA Free, Cutter, rizin, radare2?  ANSWERED
- Q2 Dynamic RE tooling status: gdb and its front-ends, Frida, ltrace/strace, rr, DynamoRIO, Intel Pin?  ANSWERED (strace not separately checked)
- Q3 Patch-diff tooling: BinDiff availability, Diaphora, Ghidra Version Tracking, ghidriff?  ANSWERED
- Q4 Structure and protocol recovery tooling (Kaitai, ImHex, Netzob, Ghidra types, Wireshark)?  PARTIAL (maintenance checked, no field-practice source reached)
- Q5 How do reverse engineers actually work (task analysis, Votipka et al.)?  ANSWERED
- Q6 How reliable are decompilers (what must the learner be taught to distrust)?  PARTIAL (one T1 paper fetched; a second lead unverified)
- Q7 What free courses and wargames exist for RE and how are they structured?  ANSWERED
- Q8 What do experts say is the rate-determining step in each module?  PARTIAL (derived from Votipka and the patch-diff writeups; no direct expert quote on structure recovery)
- Q9 Real N-day patch-diff writeups?  ANSWERED (one genuine patch-first writeup found; others are tool tutorials)
- Q10 Candidate Linux userland N-day targets with advisory and fix fetched?  ANSWERED (5 targets, plus 1 rejected)
- Q11 Which techniques and tools should be excluded?  ANSWERED

## Why it matters
Terminal outcomes served: **rootcause** and **map** (RE-01, RE-02), **find** (RE-03: recovering parsers is how the attack surface of a closed binary becomes auditable), **rootcause + find** (RE-04: an N-day recovered from a binary diff). The track feeds BX-05 (first real N-day exploit) and BX-10. Where real bugs in this domain show up: every closed-source or stripped target (vendor firmware, distro binaries, patched releases where only the binary changed), and every "silent fix" where the advisory says little. The cited study of 16 working reverse engineers (11 vulnerability discovery, 4 malware, 1 both) found no significant difference in core process between the two groups; they differed mainly in which APIs and functions they chased (Votipka et al., ar5iv rendering). So one RE track serves both employment routes.

## Concepts / Facts / Procedures

### Concepts (understand)
- **Three-phase RE loop** (Votipka et al.): overview (what is this program), sub-component scanning (skim prioritised code for beacons without reading line by line), focused experimentation (test one hypothesis, usually dynamically); results feed back into scanning.
- **Beacons**: strings, imported APIs, constants, control-flow shapes, compiler idioms, a function's place in the call graph. Hypotheses come from pattern-matching to past experience; absent experience, experts fall back on heuristics like "largest function first".
- **Approximate vs precise views**: decompiler output is an approximation; disassembly is the ground truth. Skilled analysts choose between them and verify the approximate one.
- **Decompilation is lossy and can be wrong**: Cao et al. (ISSTA 2024) report about 55% semantic accuracy for Hex-Rays at almost all optimisation levels and say this contradicts the common belief that decompilers are usually accurate. Failure families are in section "Rate-determining steps".
- **Calling conventions, stack frames, and data layout** as the basis of type recovery (System V AMD64 for the track).
- **Static vs dynamic information is complementary**: static scales across all paths but is imprecise; dynamic is precise for one path. The Votipka participants found moving information between the two costly and manual (their guideline G3).
- **Diffing is a search-space reduction, not an answer**: a patch diff gives candidate changed functions; most changes are noise (renames, refactors, compiler layout shifts). The security-relevant change must be separated by reading, then proved by a trigger. Hawkes's WebP writeup shows the flow: identify the patch from the bug ID, read what the change implies about the old code, then build a trigger and confirm that the patched build rejects it.
- **Function matching correlators** (hash, name, call-graph, structural): why matches fail and what "similarity/confidence" scores mean.
- **Structure recovery**: a struct is a hypothesis about offsets, sizes and lifetimes, confirmed by uses across many functions and by runtime memory.
- **File-format / protocol grammar**: fields, length/offset/count relationships, tag-length-value, state machines. Length-count-offset fields are where parsers fail, hence the link to `find`.

### Facts (memorise)
- Ghidra 12.2 (released 2026-10-22, Apache-2.0) requires JDK 25 minimum; Python 3.9 to 3.14 needed for the Debugger or a source build; 12.2 enforces TLS server authentication for Ghidra Server and BSim server connections.
- Ghidra 12.2 Debugger gained "timeless" trace support (TENET-format traces recorded with a Pin tool) per the 12.2 release notes.
- Binary Ninja Free (version 6.0 "Krypton" is the current release): non-commercial only; decompiles x86, x86_64, ARMv7/Thumb2 and AArch64 only; no API or plugin access; only Disassembly, HLIL and Pseudo C views; has an integrated debugger.
- IDA Free: non-commercial; x86-32/64 only; decompiler is cloud-only; no IDAPython/SDK per the FAQ (the feature table on the page contradicts this for the C++ SDK; treat as `unverified`).
- BinDiff (Apache-2.0) is open source; last tagged release v8 (2023-09-25) but the repository has commits through 2026-09-18; it ships with IDA Pro, Binary Ninja and Ghidra support (Ghidra via the BinExport extension).
- Diaphora 3.5.0 (2026-10-25, AGPL-3.0) is an IDA plugin (supports IDA >= 7.4); it needs IDA, so it is not free-tier friendly.
- ghidriff (clearbluejar) uses Ghidra via pyghidra; default engine VersionTrackingDiff; outputs JSON and Markdown; development target is Ghidra 12.2 with pyghidra 3.x and CI also covers 12.0.4 and 12.1.4. Repo active 2026-11-09.
- Cutter 2.5.0 (2026-06-30, GPL-3.0), rizin 0.9.1 (2026-06-29, LGPL-3.0), radare2 6.2.6 (2026-11-05) are all actively maintained.
- Frida 17.26.2 (2026-11-07); Stalker supports AArch64 and Intel 64/IA-32 only; frida-trace generates per-function JavaScript handlers with `onEnter` and `onLeave` and can trace unexported functions by module offset (`-a "libjpeg.so!0x4793c"` form on the docs page).
- DynamoRIO: supports Windows, Linux, Android (experimental macOS) on IA-32, AMD64, ARM, AArch64; tools drcov (coverage), Dr. Memory, drcachesim. Intel Pin 4.x: free under the ISSL, Linux and Windows, x86 and x86-64 only (Pin does not cover AArch64).
- gdb latest tag fetched: gdb-18.1-release (git tags on sourceware). pwndbg, GEF, rr, angr all had commits within the past 3 days (2026-11-08 to 2026-11-11).
- ltrace upstream (gitlab.com/cespedes/ltrace) last commit 2026-08-25, last tag 0.8.1: alive but slow.
- Debian snapshot (snapshot.debian.org) keeps old binary packages and `-dbgsym` packages (verified for curl 8.3.0-3 and 8.4.0-1 and for sudo 1.9.5p1-1 and 1.9.5p2-1), which gives patch-diff labs real stripped distro binaries and an answer key.

### Procedures (automate)
1. Triage a new binary: `file`, `readelf`/`checksec`-style mitigation review, strings, imports, section sizes, then decompiler auto-analysis (overview phase).
2. Navigate by beacons: string/import xrefs to candidate functions; rename and retype as you go (the Votipka participants annotated heavily).
3. Fix the decompiler: set function signatures and calling conventions, define struct types, mark `noreturn`, fix array/pointer confusion, then re-read.
4. Hypothesis-driven dynamic check: gdb break/watch at a chosen function with a chosen input; Frida hook to log arguments and return values; strace/ltrace to confirm syscalls/library calls.
5. Coverage-guided orientation: record basic-block coverage (drcov/Frida Stalker) for two inputs and diff the covered functions to locate the code that handles a field.
6. Struct recovery loop: infer layout from allocation size plus offset accesses, apply the type, re-decompile, validate by watching memory at runtime.
7. Format/protocol recovery: capture samples, locate the parse entry, identify length/count/offset fields, write a grammar (Kaitai Struct or equivalent), round-trip real samples through it.
8. Patch diff: fetch old and new binaries, run the differ, filter to changed functions, read the pseudocode diff, form the bug hypothesis, find the input path to the changed function, write the trigger, confirm it crashes (ideally under ASan or with a debug build) on old and is rejected on new.

## Mitigation landscape
RE does not itself depend on exploit mitigations, but three things interact with RE labs (all `needs-lab-verification` for specific defaults in the pinned distro):
- **PIE/ASLR** change the addresses in gdb and Frida sessions; learners must read load-base-relative offsets. Debuggers disable ASLR by default in gdb; real targets do not.
- **Stripped, hardened distro builds** (Debian snapshot binaries) are what the patch-diff lab uses; they carry hardening flags that add instruction noise (stack protector prologues, fortify) to diffs.
- **Anti-analysis (packing, obfuscation, anti-debug)** is the one place mitigations hit RE directly. The Votipka study lists it as a source of difficulty, but the track's real targets (distro userland binaries) have none. Keep to a short unit via pwn.college's Yan85 VM challenges or exclude (see Exclude).

## Rate-determining steps (what experts say is hardest; cite)
- **RE-01 (recovering intent and correcting the decompiler)**: Votipka et al. report that decompiler output can be wrong in specific ways and requires verification, and that experts pick between approximate and precise views. Cao et al. measured about 55% semantic accuracy for Hex-Rays (ISSTA 2024). A search lead (not fetched; `verified: null`) reports D-Helix, USENIX Security 2024, finding that most Ghidra bugs it found were in function prototype recovery, literal recovery and type recovery. Treat "function prototype and type recovery" as the drill target. Provenance: the module's RDS in skill-tree.yaml is consistent with these sources.
- **RE-02 (hooks that answer one question)**: Votipka report that switching between static and dynamic tools is hard because information must be transferred manually, and that environment setup (e.g. embedded firmware) can be costly. So the learner skill is stating a falsifiable question before touching the debugger. This is a derivation from the study, not an expert quote.
- **RE-03 (structure and field semantics)**: Votipka: complex variable manipulation is hard to track mentally, so REs take notes and reconstruct structures. No direct expert statement on protocol recovery was found; `needs-lab-verification` through the pilot (time to recover a struct on an unseen parser).
- **RE-04 (isolating the security-relevant change)**: the writeup evidence is thin; Hawkes's post starts from the bug ID and patch, not from a blind diff. ghidriff's author frames the output as added/deleted/modified function lists plus pseudo-code diffs for reading. Practical consequence: the hardest step is deciding which of many changed functions matters, and then reaching it with an input. The learner should practise both with and without the advisory text.

## Emphasise (things experts rely on that tutorials skip)
- Hypothesis-first dynamic work: write the question, then the breakpoint (Votipka phase 3).
- Annotation as the main work product: rename, retype, comment, and keep the database; experts "heavily annotate" (Votipka).
- Verify the decompiler against disassembly at any line that matters (signedness, integer width, pointer arithmetic, sign extension, noreturn calls, jump tables).
- Reading compiler idioms (division by constant, switch tables, stack protector epilogues, inlined memcpy) so noise is recognised.
- Using symbols and answer keys: practise on a binary with `-dbgsym` first to see the truth, then strip.
- Patch diff from both directions: from the advisory to the function, and from the diff to the bug.
- Always validate a diff candidate with a trigger on the old build and a rejection on the new one (Hawkes's check).
- Source-assisted RE for open-source targets: compare against upstream source and the fix commit (all five shortlisted targets have source and a tiny fix commit).

## Exclude (popular but outdated or low-yield; say why, cite)
- **Packers, obfuscation and anti-debug as the core of RE-01**: popular in CTFs and malware courses, but the study found vulnerability researchers and malware analysts share the core process; obfuscation is an additional layer, and the track's targets are plain distro binaries. Limit to one optional stretch (Yan85 VM challenges in the pwn.college RE dojo).
- **Windows-first RE (PE, WinDbg, kernel diffing)**: the track is Linux userland; a Windows track is separate (WIN). Most published patch-diff tutorials are Windows; learners will find them, so say why they are not used here.
- **radare2 as the primary tool**: maintained, but the learning curve is command-line-only and the track already needs a decompiler. Keep as an alternative card (Cutter is its GUI sibling through rizin).
- **Hex-Rays/IDA Pro, Binary Ninja commercial and BinDiff-with-IDA workflows as required tooling**: paid. Diaphora needs IDA. Free path: Ghidra + ghidriff + BinDiff (via BinExport).
- **Tutorials on Ghidra versions before 11 (e.g. a 2020 post on Ghidra 9.1.2)**: UI and scripting changed (PyGhidra); the post also targeted a toy `gets()` program on Windows with no CVE. Use as concept reference only.
- **Reading a Ghidra book chapter-by-chapter before practice**: tutorial hell risk, per CLAUDE.md failure modes; use as reference.
- **Pin as primary DBI**: x86/x86-64 only and proprietary-licensed (free). Fine for coverage, but Frida and DynamoRIO cover AArch64 too.

## Candidate direct targets
All five are Linux userland, public CVE, public tiny fix commit, old and new binaries obtainable from snapshot.debian.org or buildable from tagged source. Build step: `build: unverified` for every target (I did not download or build binaries). Fix commits and file lists were confirmed by cloning each upstream repo (blobless bare clone) on 2026-11-10. CWE and KEV flag from NVD API.

| # | Target | CVE / class | Affected -> fixed | Fix commit (verified in upstream git) | Diff size and noise | Diff pair for lab | Suitability notes |
|---|---|---|---|---|---|---|---|
| 1 | sudo | CVE-2021-3156 "Baron Samedit", heap overflow in `set_cmnd()` unescape (NVD CWE-193, KEV) | 1.8.2-1.8.31p2 and 1.9.0-1.9.5p1 -> 1.8.32, 1.9.5p2 | `1f863857` (2021-01-23, "Fix potential buffer overflow when unescaping backslashes in user_args"); related `b301b46b`, `c4d38408` (sudoedit flag checks) | Release diff p1->p2 touches 12 files, 119 insertions and 44 deletions, incl. noise (pam.c, log_client.c, timestamp.c, progname.c). The security change is in sudoers.c and policy.c plus parse_args.c. | Debian `sudo_1.9.5p1-1_amd64.deb` vs `sudo_1.9.5p2-1_amd64.deb` (both in snapshot.debian.org; listing fetched) | Best first target: small change, real noise, and a two-part fix (front-end plus plugin) that teaches "patch blocks one path" lessons. Trigger needs the `sudoedit -s` path with a trailing backslash (advisory). Exploit stays out of scope until BX-05. |
| 2 | glibc ld.so | CVE-2023-4911 "Looney Tunables", `parse_tunables()` overflow (NVD CWE-122/787, KEV) | glibc 2.34 era -> fixed in 2.39 tag set (commit contained in glibc-2.39 and later tags) | `1056e5b4c3f2d90ed2b4a55f96add28da2f4c8fa` (2023-10-02, "tunables: Terminate if end of input is reached (CVE-2023-4911)") | Commit touches NEWS, `elf/dl-tunables.c` (17 lines) and a test. A tiny fix inside a huge binary: good for learning to find a small change in a loader. | Debian/Ubuntu libc6 packages before/after the fix (exact package versions unverified) | Strong BX-05 bridge (setuid GLIBC_TUNABLES reachable locally). Affected default installs per Qualys: Fedora 37/38, Ubuntu 22.04/23.04, Debian 12/13 (Qualys). Lab caveat: ld.so differences across distro glibc builds are large; pick one distro pair. |
| 3 | curl/libcurl | CVE-2023-38545, SOCKS5 heap overflow (NVD CWE-787; vendor lists CWE-122) | libcurl 7.69.0-8.3.0 -> 8.4.0 | `fb4415d8aee6c1045be932a34fe6107c2f5ed147` (2023-10-11, "socks: return error if hostname too long for remote resolve") | 8 lines in `lib/socks.c` plus a test; advisory notes the curl tool is not vulnerable by default (larger buffer), so the harness is libcurl with a SOCKS5 proxy. | Debian `curl_8.3.0-3` vs `curl_8.4.0-1` amd64, plus `-dbgsym` for answer key (all in snapshot.debian.org; listing fetched) | Needs a small SOCKS5 server stub for a trigger (slow-handshake state-machine bug, which is a good lesson in why a trigger can need a staged peer). Fits RE-03 too. |
| 4 | polkit pkexec | CVE-2021-4034 "pwnkit", argc==0 OOB read/write (NVD CWE-787/125, KEV) | vulnerable since the 2009 first commit per Qualys -> 0.121 | `a2bf5c9c83b6ae46cbd5c779d3055bff81ded683` (2022-01-25, "pkexec: local privilege escalation (CVE-2021-4034)") | 2 files, +25/-3: very small. Fix is `argc < 1` check. | Debian `policykit-1` 0.105-31 vs 0.105-31+deb11u1 (both listed on snapshot.debian.org; the +deb11u1 package assumed to carry the fix: `unverified`) | Easiest diff, probably too easy once the learner has seen sudo: use as the "no hints" retrieval target. Trigger is an `execve` with empty argv (advisory describes it). |
| 5 | libwebp | CVE-2023-4863, OOB write in `BuildHuffmanTable` (NVD CWE-787, KEV) | 0.5.0-1.3.1 -> 1.3.2 | `2af26267cdfcb63a88e5c74a85927a12d6ca1d76` (2023-09-07, "Fix OOB write in BuildHuffmanTable"); Hawkes's post cites commit `902bc91` for the patch (also exists in the repo) | 4 files, +129/-43: larger, algorithmic change (two-pass size computation). | Debian or Ubuntu libwebp7 before/after (package versions not checked) or tagged-source builds v1.3.1 and v1.3.2 | Has a first-class patch-first writeup (Hawkes). Harder trigger (crafted lossless bitstream). Good RE-04 stretch and RE-03 link (format recovery), but the CVE exploits a codec, so keep trigger-only. |

Rejected: **OpenSSH CVE-2024-6387 "regreSSHion"** (fixed in 9.8p1, fix commit 81c1099 per Qualys). The bug is a signal-handler race and the fix is a restructure (moves logging out of the signal handler, with a larger related change 03e3de4), so the diff does not point at a single bug line, and Qualys demonstrates exploitation only on 32-bit i386 with hours of attempts. Poor RE-04 fit; may suit a later race-condition module.

All fix commits confirmed by `git show` on local blobless clones, not from the advisories (the Qualys advisories for CVE-2021-3156, CVE-2023-4911 and CVE-2021-4034 do not list fix commits).

## Resources
Format per templates/resource-card.yaml. `role` is left to the module-builder. Sorted by tier then rough overall score.

```yaml
# ---- T1 ----
- title: "An Observational Investigation of Reverse Engineers' Processes"
  url: "https://arxiv.org/abs/1912.00317"
  author: "Votipka, Rabin, Micinski, Foster, Mazurek"
  kind: paper
  tier: T1
  cost: free
  published: 2019-12-01
  targets: "interviews of 16 professional reverse engineers (2018-10 to 2019-01)"
  covers: "three-phase model of RE (overview, sub-component scanning, focused experimentation), difficulties, five tool-design guidelines"
  assumes: "none"
  scores: {directness: 3, currency: 4, depth: 5, activity: 1, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-10   # abstract page fetched; body read via an ar5iv rendering of the same paper (the raw PDF could not be text-extracted in this environment)
  status: ok

- title: "Evaluating the Effectiveness of Decompilers"
  url: "https://2024.issta.org/details/issta-2024-papers/40/Evaluating-the-Effectiveness-of-Decompilers"
  author: "Ying Cao, Runze Zhang, Ruigang Liang, Kai Chen"
  kind: paper
  tier: T1
  cost: free
  published: 2024
  targets: "mainstream decompilers incl. Hex-Rays"
  covers: "measures semantic consistency and readability; roughly 55% semantic accuracy for Hex-Rays; why analysts still read assembly"
  assumes: "decompilation vocabulary"
  scores: {directness: 3, currency: 4, depth: 4, activity: 1, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-10   # abstract page only; full paper not read
  status: ok

- title: "The WebP 0day"
  url: "https://blog.isosceles.com/the-webp-0day/"
  author: "Ben Hawkes (Isosceles Blog)"
  kind: writeup
  tier: T1
  cost: free
  published: 2023-09-21
  targets: "libwebp, CVE-2023-4863, vulnerable commit 7ba44f80 built with ASan"
  covers: "patch-first analysis: map bug ID to the libwebp patch, infer vulnerable allocation logic, build a trigger, confirm the patched first pass rejects it"
  assumes: "C, Huffman coding basics, ASan"
  scores: {directness: 5, currency: 4, depth: 4, activity: 2, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-10   # content summarised via fetch tool; the fetched page did not describe a binary-level diff (source-level patch reading)
  status: ok

- title: "Ghidra release 12.2 (What's New, Getting Started)"
  url: "https://github.com/NationalSecurityAgency/ghidra/releases/tag/Ghidra_12.2_build"
  author: "NSA Research Directorate"
  kind: tool
  tier: T1
  cost: free
  published: 2026-10-22
  targets: "Ghidra 12.2; needs JDK 25"
  covers: "current release, new Debugger trace features, requirements"
  assumes: "none"
  scores: {directness: 5, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-10
  status: ok

- title: "ghidriff: Ghidra Binary Diffing Engine"
  url: "https://clearbluejar.github.io/posts/ghidriff-ghidra-binary-diffing-engine"
  author: "clearbluejar"
  kind: writeup
  tier: T1   # tool author's own writeup; the repo (README) was also fetched
  cost: free
  published: 2023-12-20
  targets: "ghidriff v0.5.0 (post); repo README says development target Ghidra 12.2 + pyghidra 3.x"
  covers: "patch diffing via Ghidra API, function matching correlators, Markdown/JSON/side-by-side output; CLI usage"
  assumes: "Ghidra install, Python"
  scores: {directness: 5, currency: 4, depth: 3, activity: 4, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-10
  status: ok

- title: "BinDiff (google/bindiff README and releases)"
  url: "https://github.com/google/bindiff"
  author: "Google LLC"
  kind: tool
  tier: T1
  cost: free
  published: 2023-09-25   # v8 release; commits through 2026-09-18
  targets: "BinDiff 8 with IDA Pro, Binary Ninja and Ghidra"
  covers: "open-source binary comparison; vulnerability-fix isolation; port symbols/comments"
  assumes: "a disassembler export (BinExport)"
  scores: {directness: 5, currency: 3, depth: 3, activity: 3, cost: 5, accessibility: 3}
  role: alternative
  verified: 2026-11-10
  status: ok

- title: "Diaphora (README)"
  url: "https://github.com/joxeankoret/diaphora"
  author: "Joxean Koret"
  kind: tool
  tier: T1
  cost: free   # AGPL, but requires IDA
  published: 2026-10-25   # 3.5.0
  targets: "IDA >= 7.4 through 9.5"
  covers: "program diffing with vulnerability-fix detection heuristic and pseudo-code diffing"
  assumes: "IDA licence"
  scores: {directness: 4, currency: 5, depth: 3, activity: 3, cost: 2, accessibility: 2}
  role: alternative
  verified: 2026-11-10
  status: ok

- title: "Frida docs: frida-trace and Stalker"
  url: "https://frida.re/docs/frida-trace/"
  author: "Frida project"
  kind: docs
  tier: T1
  cost: free
  published: unknown
  targets: "Frida 17.26.2 current release"
  covers: "tracing functions with generated onEnter/onLeave handlers; Stalker code tracing (AArch64 and Intel only)"
  assumes: "JavaScript basics"
  scores: {directness: 4, currency: 5, depth: 3, activity: 4, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-10
  status: ok

- title: "DynamoRIO"
  url: "https://dynamorio.org/"
  author: "DynamoRIO project"
  kind: tool
  tier: T1
  cost: free
  published: unknown
  targets: "Linux/Windows/Android on x86, ARM, AArch64; version 11.91.x"
  covers: "DBI framework; drcov coverage; drcachesim"
  assumes: "C"
  scores: {directness: 3, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 2}
  role: alternative
  verified: 2026-11-10
  status: ok

- title: "Advisories used for the shortlist (vendor or researcher): sudo, curl, Qualys x3"
  url: "https://www.sudo.ws/security/advisories/unescape_overflow/"
  author: "Todd C. Miller (sudo); also Qualys at https://www.qualys.com/2021/01/26/cve-2021-3156/baron-samedit-heap-based-overflow-sudo.txt, https://www.qualys.com/2023/10/03/cve-2023-4911/looney-tunables-local-privilege-escalation-glibc-ld-so.txt, https://www.qualys.com/2022/01/25/cve-2021-4034/pwnkit.txt; curl at https://curl.se/docs/CVE-2023-38545.html"
  kind: advisory
  tier: T1
  cost: free
  published: 2021-01-26
  targets: "see candidate target table"
  covers: "affected/fixed versions and bug mechanism for each target"
  assumes: "none"
  scores: {directness: 5, currency: 4, depth: 4, activity: 1, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-10
  status: ok

# ---- T2 ----
- title: "pwn.college Program Security: Reverse Engineering"
  url: "https://pwn.college/program-security/reverse-engineering/"
  author: "pwn.college (ASU)"
  kind: wargame
  tier: T2
  cost: free
  published: unknown
  targets: "Linux x86-64 crackmes, patching, custom VM (Yan85), Cows and Bulls"
  covers: "slide lectures (functions and frames, data access, static and dynamic tools, real-world applications), crackme, patching and VM-reversing challenges with Easy/Hard variants"
  assumes: "gdb basics; page points to a Debugging Refresher module (that URL returned 404 on direct fetch)"
  scores: {directness: 3, currency: 4, depth: 3, activity: 5, cost: 5, accessibility: 4}
  role: core
  verified: 2026-11-10
  status: ok

- title: "Debuggers 1102: Introductory Ghidra (OpenSecurityTraining2)"
  url: "https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Dbg1102_IntroGhidra+2024_v2/about"
  author: "OpenSecurityTraining2"
  kind: course
  tier: T2
  cost: free
  published: 2024
  targets: "Ghidra as static analyser and debugger, Windows and Linux userspace"
  covers: "install, default static/debugger UIs, basic debugging; hours not stated"
  assumes: "WinDbg or GDB knowledge and assembly for the target ISA"
  scores: {directness: 3, currency: 3, depth: 2, activity: 4, cost: 5, accessibility: 3}
  role: core
  verified: 2026-11-10   # about page only; course body needs login
  status: ok

- title: "Debuggers 1012: Introductory GDB; Architecture 1001: x86-64 Assembly; Reverse Engineering 3011: Reversing C++ Binaries; Reverse Engineering 3201: Symbolic Analysis (OST2 short URLs)"
  url: "https://ost2.fyi/Dbg1012"
  author: "OpenSecurityTraining2"
  kind: course
  tier: T2
  cost: free
  published: unknown
  targets: "short-URL pages for each course; titles confirmed (Dbg1012, Arch1001, RE3011, RE3201); other ost2.fyi/<code> guesses for RE1xxx/RE2xxx returned empty"
  covers: "titles only confirmed from redirect pages; syllabus, hours and prerequisites not read (login needed). Also exist: Dbg1101 Introductory IDA, Dbg1011 Introductory WinDbg, Arch2001 x86-64 OS Internals, Arch1005 RISC-V Assembly"
  assumes: "unknown"
  scores: {directness: 3, currency: 3, depth: 4, activity: 4, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-10   # existence and titles only
  status: changed        # syllabus content unverified

- title: "Nightmare (guyinatuxedo)"
  url: "https://guyinatuxedo.github.io/"
  author: "guyinatuxedo"
  kind: wargame
  tier: T2
  cost: free
  published: unknown
  targets: "CTF challenges; RE sections 1.2-1.6 (assembly, Ghidra, gdb, pwntools, beginner reversing), 11.3-11.6 (.NET, obfuscation, custom architecture, emulation)"
  covers: "walkthrough-based CTF course; repo last commit 2026-02-08"
  assumes: "none"
  scores: {directness: 2, currency: 3, depth: 3, activity: 3, cost: 5, accessibility: 4}
  role: alternative
  verified: 2026-11-10
  status: ok

- title: "crackmes.one"
  url: "https://crackmes.one/"
  author: "crackmes.one community"
  kind: wargame
  tier: T2
  cost: free
  published: unknown
  targets: "community crackmes; site shows 4,852 crackmes and 6,853 writeups; filters not verified"
  covers: "practice binaries; spoilers via writeups"
  assumes: "registration for submissions"
  scores: {directness: 1, currency: 3, depth: 2, activity: 4, cost: 5, accessibility: 4}
  role: alternative
  verified: 2026-11-10   # homepage only; per-binary safety not assessed (run in a VM)
  status: ok

- title: "Reverse Engineering for Beginners"
  url: "https://beginners.re/"
  author: "Dennis Yurichev"
  kind: book
  tier: T2
  cost: free   # CC BY-SA 4.0, PDFs; exercises moved to challenges.re
  published: unknown
  targets: "assembly across architectures (the landing page does not list them)"
  covers: "compiler idioms and assembly reading; self-published"
  assumes: "C"
  scores: {directness: 2, currency: 3, depth: 4, activity: 2, cost: 5, accessibility: 3}
  role: reference
  verified: 2026-11-10   # landing page only
  status: ok

- title: "The Ghidra Book, 2nd Edition"
  url: "https://nostarch.com/GhidraBook"
  author: "Kara Nance and Chris Eagle (No Starch Press)"
  kind: book
  tier: T2
  cost: paid   # $63.99 ebook or $79.99 print + ebook
  published: 2026-03
  targets: "modern Ghidra incl. BSim and PyGhidra (no exact version stated)"
  covers: "Ghidra from basics through scripting, decompiler, compiler variations, obfuscation, patching, BSim"
  assumes: "assembly basics"
  scores: {directness: 4, currency: 5, depth: 5, activity: 2, cost: 2, accessibility: 3}
  role: reference
  verified: 2026-11-10   # product page; content not read
  status: ok

- title: "Ghidra course slides (Beginner and Intermediate: Version Tracking, Scripting, Headless Analyzer)"
  url: "https://github.com/NationalSecurityAgency/ghidra/tree/Ghidra_12.2_build/GhidraDocs/GhidraClass/Intermediate"
  author: "NSA Research Directorate"
  kind: docs
  tier: T1
  cost: free
  published: 2026-10-22   # shipped with 12.2 tag
  targets: "Ghidra 12.2 docs"
  covers: "directory listing confirmed (VersionTracking.html, Scripting.html, HeadlessAnalyzer.html, Student Guides); the slide text is JavaScript-rendered and was not read"
  assumes: "none"
  scores: {directness: 4, currency: 5, depth: 3, activity: 3, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-10
  status: changed   # existence confirmed, content unverified

# ---- T3 (gap fillers) ----
- title: "Patch Diffing with Ghidra"
  url: "https://ihack4falafel.github.io/Patch-Diffing-with-Ghidra"
  author: "Hashim Jawad"
  kind: writeup
  tier: T3
  cost: free
  published: 2020-05-11   # updated date; original date not shown
  targets: "Ghidra 9.1.2, BinExport + BinDiff, a toy Windows program"
  covers: "end-to-end BinExport/BinDiff workflow including reading match/unmatched tables; shows BinDiff did not flag an operand-only change"
  assumes: "none"
  scores: {directness: 1, currency: 2, depth: 2, activity: 2, cost: 5, accessibility: 4}
  role: reference
  verified: 2026-11-10   # T3 used only because no Linux, BinDiff-with-Ghidra primary tutorial was found; the operand-only blind spot is a useful concept
  status: ok

# ---- Structure and protocol tooling (maintenance only, usage docs not read) ----
- title: "Kaitai Struct, ImHex, Netzob, Wireshark (repositories)"
  url: "https://github.com/kaitai-io/kaitai_struct"
  author: "Kaitai project; WerWolv; Netzob; Wireshark"
  kind: tool
  tier: T2
  cost: free
  published: unknown
  targets: "last commits: Kaitai 2026-10-20, ImHex 2026-10-08, Wireshark 2026-11-10, Netzob 2023-01-08 (stale)"
  covers: "binary format description language, hex editor with pattern language, dissector, protocol inference; usage docs not fetched"
  assumes: "unknown"
  scores: {directness: 3, currency: 3, depth: 2, activity: 3, cost: 5, accessibility: 3}
  role: alternative
  verified: 2026-11-10   # recency only
  status: changed

# ---- Unverified leads (cannot satisfy D7) ----
- title: "D-Helix: decompiler correctness vetting (USENIX Security 2024)"
  url: "https://www.usenix.org/system/files/usenixsecurity24_slides-zou.pdf"
  author: "Zou et al. (from URL only)"
  kind: paper
  tier: T1
  cost: free
  published: 2024
  targets: "Ghidra, angr"
  covers: "search-result summary claims 4,515 wrong functions in about 93K and 17 new bugs; not confirmed because the fetched PDF could not be text-extracted"
  assumes: "unknown"
  scores: {directness: 3, currency: 4, depth: 4, activity: 1, cost: 5, accessibility: 2}
  role: reference
  verified: null
  status: unverified
```

## Open questions / conflicting sources
- IDA Free page: FAQ says no IDAPython or C++ SDK, feature table lists "C++ SDK" for Free. `unverified`; do not require IDA Free.
- OST2: the learning-path map is an image/PDF, so which RE courses form the path was not confirmed; course codes confirmed only through ost2.fyi short URLs. Syllabi need a manual fetch (login). A third-party PDF mentioned "Reverse Engineering 2102: Intermediate Ghidra" but `ost2.fyi/RE2102` returned nothing; treat as unconfirmed.
- Hawkes's patch hash `902bc91` differs from the repository log hash `2af26267` for the same titled fix; both exist in the repo clone but I did not establish which branch each lies on.
- The Qualys glibc advisory says 2.34 may not be exploitable, but vulnerable-version range as the fix tag set shows (commit contained from glibc-2.39 onwards) needs a per-distro check (`needs-lab-verification`).
- No independent T1 evidence that a free-tool Linux binary diff (ghidriff or BinDiff via BinExport) reliably isolates these five fixes on Debian binaries: `needs-lab-verification`; this is the first thing the lab-engineer should prove.
- Whether RE labs should teach `-dbgsym` "answer key" workflows is a pedagogical suggestion; no source.
- No verified first-person account of how experts learned structure/protocol recovery; field-level benchmarks (research/benchmarks/expert-paths.md) were not re-read.
- Not reached: pwn.college Debugging Refresher (404), OST2 course syllabi (login), NVD HTML (JS; API used instead), sourceware gitweb (Anubis block; GitHub mirror used), Ghidra Version Tracking slide text (JS), IDA/Hex-Rays licence text beyond the product page, strace upstream, Wireshark and Kaitai docs.

## Implications for the architect (suggestions, accept or reject)
1. Use sudo CVE-2021-3156 (p1 vs p2 Debian binaries) as the RE-04 anchor and keep CVE-2021-4034 (pkexec) as the no-hint retrieval case. Use curl or libwebp as the stretch; BX-05 can reuse the same sudo or ld.so target after RE-04.
2. Drill the RDS of RE-01 on type and prototype recovery: give a stripped function, the decompiler output with a known defect class (wrong signedness, wrong prototype, missed noreturn), and compare to a `-dbgsym` build. The Votipka and Cao et al. results support teaching "verify the approximate view" as a first-class step.
3. Add a RE-02 requirement to write the question before the hook (hypothesis log), which comes from the Votipka phase 3 description; and include the static-to-dynamic transfer problem (names and addresses between Ghidra and gdb or Frida) as an explicit drill.
4. Free-tool stack for the track: Ghidra 12.2 (needs JDK 25), ghidriff, BinDiff via BinExport, gdb with pwndbg or GEF, Frida, rr. Avoid IDA, Binary Ninja commercial and Diaphora as requirements.
5. Add a lab-engineer task: prove each shortlisted diff pair (download, strip check, run ghidriff, record where the fix appears in the ranked output). Until then every target stays `build: unverified`.

## Sources
All fetched 2026-11-10 (verified unless noted).
- https://api.github.com/repos/* release and push metadata for NationalSecurityAgency/ghidra, rizinorg/rizin, rizinorg/cutter, radareorg/radare2, google/bindiff, joxeankoret/diaphora, frida/frida, DynamoRIO/dynamorio, Vector35/binaryninja-api (before rate limit); recency of pwndbg, rr, ghidriff, gef, angr, ImHex, kaitai_struct, netzob, frida-tools, wireshark, ltrace read by shallow clone log
- https://raw.githubusercontent.com/NationalSecurityAgency/ghidra/Ghidra_12.2_build/Ghidra/Configurations/Public_Release/src/global/docs/WhatsNew.md
- https://binary.ninja/free/
- https://hex-rays.com/ida-free
- https://www.zynamics.com/bindiff.html ; https://raw.githubusercontent.com/google/bindiff/main/README.md
- https://raw.githubusercontent.com/joxeankoret/diaphora/master/README.md
- https://raw.githubusercontent.com/radareorg/radare2/master/README.md
- https://raw.githubusercontent.com/clearbluejar/ghidriff/main/README.md ; https://clearbluejar.github.io/posts/ghidriff-ghidra-binary-diffing-engine
- https://frida.re/docs/home/ ; https://frida.re/docs/frida-trace/ ; https://frida.re/docs/stalker/
- https://dynamorio.org/
- https://www.intel.com/content/www/us/en/developer/articles/tool/pin-a-dynamic-binary-instrumentation-tool.html
- https://arxiv.org/abs/1912.00317 ; https://ar5iv.labs.arxiv.org/html/1912.00317 (first 100,000 of 130,154 characters read)
- https://2024.issta.org/details/issta-2024-papers/40/Evaluating-the-Effectiveness-of-Decompilers
- https://pwn.college/program-security/reverse-engineering/
- https://guyinatuxedo.github.io/ ; https://crackmes.one/ ; https://beginners.re/ ; https://nostarch.com/GhidraBook
- https://opensecuritytraining.info/ ; https://ost2.fyi/{Dbg1102,Dbg1101,Dbg1011,Dbg1012,Arch1001,Arch1005,Arch2001,RE3011,RE3201} ; https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Dbg1102_IntroGhidra+2024_v2/about
- https://github.com/NationalSecurityAgency/ghidra/tree/Ghidra_12.2_build/GhidraDocs/GhidraClass/{Beginner,Intermediate}
- https://ihack4falafel.github.io/Patch-Diffing-with-Ghidra
- https://blog.isosceles.com/the-webp-0day/
- https://www.sudo.ws/security/advisories/unescape_overflow/ ; https://www.qualys.com/2021/01/26/cve-2021-3156/baron-samedit-heap-based-overflow-sudo.txt ; https://www.qualys.com/2023/10/03/cve-2023-4911/looney-tunables-local-privilege-escalation-glibc-ld-so.txt ; https://www.qualys.com/2022/01/25/cve-2021-4034/pwnkit.txt ; https://www.qualys.com/2024/07/01/cve-2024-6387/regresshion.txt ; https://www.openwall.com/lists/oss-security/2024/07/01/3 ; https://curl.se/docs/CVE-2023-38545.html
- NVD CVE API for CVE-2021-3156, CVE-2021-4034, CVE-2023-4911, CVE-2023-38545, CVE-2023-4863 (CWE and KEV fields); https://cveawg.mitre.org/api/cve/CVE-2023-4863
- Upstream git (blobless clones): github.com/sudo-project/sudo, github.com/bminor/glibc, github.com/curl/curl, gitlab.freedesktop.org/polkit/polkit, chromium.googlesource.com/webm/libwebp; gitlab.com/cespedes/ltrace; sourceware.org binutils-gdb tags (ls-remote)
- https://snapshot.debian.org/package/{sudo,curl,policykit-1}/ and version pages for sudo 1.9.5p1-1, 1.9.5p2-1, curl 8.3.0-3, 8.4.0-1
- Unfetched or failed: pwn.college debugging-refresher (404), https://p.ost2.fyi/catalog (404), sourceware gitweb (blocked), usenixsecurity24_slides-zou.pdf (unreadable binary), nvd.nist.gov HTML (JS)
