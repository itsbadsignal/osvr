# Domain map: Field overview, where 0-days are found today
Researched: 2026-11-10   Questions answered: 9/12 fully, 3/12 partially (see Q status)
Mode: BUILD / metalearning. Author: researcher agent. All figures below were read from a fetched page unless marked `unverified` or `needs-lab-verification`.

## Question plan (written before searching)
- Q1 Which bug classes dominate in-the-wild 0-days, and how is the mix changing? (GTIG 2024/2025, Project Zero, CISA KEV)  ANSWERED
- Q2 Which classes dominate in competition and bounty output (Pwn2Own Berlin/Ireland 2025, kernelCTF, Chrome VRP)?  ANSWERED
- Q3 Browsers: bug class, mitigations (V8 sandbox, Chromium memory-safety data), trend.  ANSWERED
- Q4 Linux kernel: default mitigations, hardened-target config, CVE volume, bounty path.  PARTIAL (no authoritative "distro defaults" table reached)
- Q5 Windows 11 defaults (HVCI, CET stack protection, Rust).  PARTIAL (HVCI default confirmed; CET and Rust-in-kernel not confirmed from T1)
- Q6 Apple (XNU/iOS/macOS) and Android defaults (MIE, MTE, Scudo, Rust).  ANSWERED for MIE and Android; XNU source availability not fetched
- Q7 Embedded/IoT/firmware mitigation state and bug classes.  PARTIAL (2019/2020 measurements only)
- Q8 Hypervisors: what falls at Pwn2Own, bug classes.  ANSWERED
- Q9 Enterprise appliances and edge: bug classes, vendors.  ANSWERED
- Q10 Open-source libraries: OSS-Fuzz scale, AI-driven discovery, bounty/CVE friction.  ANSWERED
- Q11 Userland Linux (glibc) defaults.  NOT ANSWERED from T1 (glibc NEWS fetch truncated, sourceware blocked): `needs-lab-verification`, deferred to a BX domain map
- Q12 Time-to-first-bug evidence for self-taught learners.  NOT ANSWERED: no verified first-person beginner account found; only a vendor testimonial (rejected as marketing)

## Why it matters
The OSVR terminal outcome is a first 0-day found, root-caused, exploited and disclosed by a part-time self-taught learner. Target class determines everything downstream: setup cost, available source, mitigation difficulty, competition, and whether a CVE path exists. The field data below show that the mix of real-world 0-days is much broader than "memory corruption in browsers and kernels", and that the class where exploit difficulty is highest (browsers, current iPhone, current Android) is also where hardening has most recently cut yield.

## Concepts / Facts / Procedures

### Concepts
- **0-day in the wild vs. 0-day found by a researcher.** GTIG counts exploited-before-patch; Pwn2Own and kernelCTF reward researcher-found bugs. They differ in class mix (see below).
- **Bug-class mix by target.** Memory corruption (UAF, OOB write) dominates OS/mobile/browser; injection, deserialization, path traversal, auth bypass and logic dominate enterprise/edge appliances.
- **Mitigation-era gradient.** Hardening is strongest on newest Apple silicon, Chrome and Android first-party code, weakest in embedded firmware and in non-first-party code paths.
- **Containment vs. prevention.** The V8 sandbox and process sandboxes assume the bug exists and contain it; MTE/MIE and Rust try to prevent or kill the bug class.
- **Attack-surface reduction as a mitigation.** The kernelCTF hardened target disables whole subsystems rather than patching bugs.
- **Variant analysis.** Finding siblings of a patched bug; Project Zero's Big Sleep write-up frames it as the most tractable mode for LLM agents.

### Facts (each with source in Sources)
- GTIG: 90 zero-days exploited in 2025 (78 in 2024, 100 in 2023, per the 2025 review). 43 enterprise (48%), 47 end-user. OS bugs 39 (44%), mobile 15, browsers under 10%. Memory safety roughly 35% overall, mainly UAF and OOB write. Enterprise zero-days: security and networking products 21, edge devices 14. [GTIG-2025]
- GTIG 2024 (original review, 75 counted then, later revised to 78): 33 enterprise (44%), browsers 11, mobile 9, desktop OS 22; most common types UAF 8, command injection 8, XSS 6. [GTIG-2024]
- Project Zero tracking page: memory corruption is root cause of 68% of listed CVEs; RCAs published for 86% of listed CVEs; a detected in-the-wild exploit about every 17 days (dataset year not stated on page). [PZ-0day]
- CISA KEV, my own tally of the JSON feed fetched 2026-11-10 (1,779 entries; CWE grouping is mine, groups overlap, entries without a CWE excluded): of 506 entries added in 2025-2026 that carry a CWE, 90 have a memory-corruption CWE, 183 have an injection/deserialization/path-traversal/upload/SSRF-type CWE, 95 have an authentication/access-control CWE. Top 2025 CWEs: CWE-78 (18), CWE-502 (15), CWE-22 (13), CWE-787 (11), CWE-416 (11). Microsoft is the top vendor every year (39 in 2025, 41 in 2026 to date); Cisco, Fortinet, Ivanti, Citrix, SonicWall, Apple, Google, Linux are recurrent. KEV lists exploited CVEs, not necessarily 0-days. [KEV]
- Chromium: about 70% of high/critical bugs are memory safety, about half of those UAF (912 bugs since 2015). [CHR-MS]
- Microsoft: about 70% of CVEs were memory safety issues (2019 MSRC estimate, company-wide). [MSRC-2019 via search, see unverified list]
- Android: memory-safety vulnerabilities fell below 20% of total in 2025 for the first time; Rust density claim about 1000x lower than C/C++ (about 0.2 per MLOC estimate from roughly 5 MLOC Rust, with one vulnerability found and fixed before release; authors call it conservative). Android 6.12 kernel is the first with Rust support enabled. [AND-RUST]
- Pwn2Own Berlin 2025: $1,078,750, 28 unique 0-days (7 AI category). Targets that fell: VMware ESXi (integer overflow, $150k), VirtualBox (OOB write, guest-to-host), VMware Workstation (heap overflow), Firefox (OOB write; separate integer overflow in renderer), Redis (UAF), RHEL (UAF LPE), Windows 11 (race condition, other), SharePoint (auth bypass plus deserialization), NVIDIA Container Toolkit, Triton. The ZDI day-three text does not mention Chrome, Safari or Docker. [P2O-B2, P2O-B3]
- Pwn2Own Ireland 2025 (via secondary reporting for totals; ZDI day-one fetched): 73 unique 0-days, $1,024,750 total (secondary). Day-one fetched entries: printers (stack and heap overflows, $10-20k), NAS (stack overflow, injections, $40-100k), Philips Hue Bridge (OOB, auth bypass), Sonos Era 300 (single OOB access, $50k), Home Assistant Green (SSRF, command injection, arbitrary file write). One bug collision cut a payout from $40k to $12.5k; another entry was a withdrawal. [P2O-I1]
- Chrome VRP (Help Net Security, 2026-10-14): memory-corruption base reward quadrupled to $2,000; up to $20,000 for controlled writes in browser/network/GPU processes from web content; renderer writes/UAF up to $8,000; V8 sandbox issues flat $5,000; V8 logic bugs $4,000; fuzzer bonus $2,000 reinstated. Secondary reporting (not fetched) lists a $250,000 sandbox-escape payment for CVE-2025-4609. [CHR-VRP]
- kernelCTF (rules page, effective 2026-09-04): $71,337 flat per eligible exploit on the hardened target; hardened target is Linux 7.2-rc5 with COS-derived config, kCFI, IBT, SLAB_VIRTUAL, KMALLOC_PARTITION_TYPED, SLAB_MERGE_DEFAULT off; IO_URING, USER_NS, TLS, CRYPTO_USER_API_AEAD, AF_UNIX_OOB disabled; exploit run 20 times, minimum pass score 140; one eligible submission per researcher per slot; report to security@kernel.org within 7 days; exploit publication within 90 days of patch. [KCTF]
- Linux kernel CNA: Kroah-Hartman says the kernel went from no CVEs to number 3 in 2024 to number 1 by volume in 2025 (LWN excerpt). Phoronix (403, not fetched) is cited by a search summary for 1,500+ fixes per release at 7.2. Treat the per-release numbers as `unverified`. [LWN-GKH]
- Apple Memory Integrity Enforcement: shipped on iPhone 17 and iPhone Air (A19/A19 Pro), always on for the kernel and over 70 userland processes; synchronous EMTE, secure typed allocators (kalloc_type, xzone malloc, libpas), Tag Confidentiality Enforcement; Apple's own claim that it could not rebuild six real mercenary-spyware chains around it (self-reported). [APPLE-MIE]
- Apple Security Bounty: up to $2M for exploit chains, over $5M with bonuses; requires proof of concept, Target Flags available. [APPLE-BOUNTY]
- Android MTE (AOSP docs): hardware Arm v9 feature, disabled by default, opt-in per process or app; modes SYNC/ASYNC/ASYMM; GKI kernels have MTE-based KASAN from Android 12-5.10. The page does not say which consumer devices ship it on. [AND-MTE]
- Windows: memory integrity (HVCI) is on by default on clean installs of Windows 11 on qualifying hardware (Intel 8th gen+ from 22H2, AMD Zen 2+, 8 GB RAM, 64 GB SSD, compatible drivers); not applied on upgrades; always final user/IT control. [WIN-HVCI]
- V8 sandbox (v8.dev, 2024-04-04): software in-process sandbox assuming arbitrary R/W inside the V8 heap; enabled by default on 64-bit desktop and Android for about two years at the time of writing; post says most V8 bugs are subtle logic errors leading to memory corruption, which is why MTE and memory-safe languages do not address them well. [V8-SBX]
- Embedded: 42 embedded OSes surveyed, mitigation adoption significantly behind general-purpose systems (EuroS&P 2019, abstract fetched). A 2019 CITL survey (secondary, via search only) reported vendor updates removing hardening flags. Both are old; treat "embedded is weakly mitigated" as probable but `needs-lab-verification` per device. [EMB-2019]
- OSS-Fuzz: over 13,000 vulnerabilities and 50,000 bugs across about 1,000 projects as of May 2025 (search summary quoting Google's tally; project page not fetched, so `unverified`).
- Anthropic Frontier Red Team (2026-02-05): more than 500 high-severity memory-corruption vulnerabilities found and validated in open-source projects (GhostScript, OpenSC, CGIF named), validated by Anthropic researchers then external researchers; not a formal exploitability assessment. [ANTH-0D]
- curl ended its HackerOne bounty effective 2026-01-31: confirmed-vulnerability rate fell from above 15% in earlier years to below 5% from 2025; 87 confirmed, over $100,000 paid over the programme's life. [CURL]
- Project Zero Big Sleep (2024-11-01): LLM agent found an exploitable stack buffer underflow in SQLite via variant analysis from recent commits; authors say a target-specific fuzzer would likely do at least as well at that time. [PZ-BS]

### Procedures (field-level skills the learner needs to choose a target)
1. Pull the vendor's last 12 months of advisories and tally CWE classes before choosing a target.
2. Check source availability and build cost (open source at a pinned commit vs. firmware blob vs. closed binary).
3. Check the disclosure path (vendor VRP, CNA, security@kernel.org, ZDI, MITRE CNA-LR) and AI-report policy before spending time.
4. Check the mitigation set the target runs with by default, not the tutorial's.
5. Check Project Zero RCAs / KEV for the same product to see what real bugs look like.

## Mitigation landscape (default state per platform, with triangulation status)

| Platform | Default state today | Since | Evidence | Triangulated? |
|---|---|---|---|---|
| Chrome desktop/Android | V8 sandbox on for 64-bit builds; process sandbox, site isolation | V8 sandbox: "about two years" before Apr 2024 per post | [V8-SBX], [CHR-MS], [CHR-VRP] (VRP pays for V8 sandbox issues, confirming it is a boundary) | Yes (2 T1) for "V8 sandbox is a rewarded boundary"; exact ship version `needs-lab-verification` |
| Apple iPhone 17 / Air | MIE (sync EMTE, typed allocators) always on in kernel + 70 userland processes | Sept 2025 | [APPLE-MIE] plus [APPLE-BOUNTY] ($2M+ ceiling consistent with highest difficulty); independent evaluation not found | One T1 only (vendor claim). Flag: unverified vendor claim |
| Earlier Apple devices / macOS | PAC and typed allocators are described in the MIE post as pre-existing building blocks; MIE not on pre-A19 hardware | n/a | [APPLE-MIE] | `needs-lab-verification` for exact per-device state |
| Android | Scudo hardened allocator, Rust in new code, MTE opt-in per process/app, MTE-KASAN on GKI | Rust/Scudo narrative to 2025; MTE docs Android 12 | [AND-RUST], [AND-MTE] | Yes (2 T1) for "MTE is opt-in, not blanket default in AOSP docs"; consumer-device default `needs-lab-verification` |
| Windows 11 | HVCI on for clean installs on qualifying hardware; kernel-mode hardware-enforced stack protection requires CET-capable CPU and memory integrity (secondary guides only) | 21H2/22H2 (hardware list) | [WIN-HVCI] (T1); CET claim from consumer guides only | HVCI: one T1 plus a second T1 how-to page [WIN-HVCI2] that confirms the feature but not defaults. CET default: `unverified` |
| Linux kernel (upstream/distro) | KASLR, strict kernel RWX, stack protector configurable; hardened-target adds kCFI, IBT, SLAB_VIRTUAL, typed kmalloc partitions, disables io_uring/userns | n/a | [KSP] (kernel docs list features, does not state defaults) and [KCTF] | Distro defaults not triangulated: `needs-lab-verification` |
| glibc/Linux userland | Safe-linking, tcache key etc. | glibc 2.32 (recollection, not verified) | none fetched | `needs-lab-verification` / `unverified`; defer to BX domain map |
| Embedded/IoT | Frequently no ASLR, no canaries, mixed NX; can regress across updates | n/a | [EMB-2019] (abstract) plus secondary CITL summary | Two sources but both 2019-2020: flagged dated, `needs-lab-verification` per device |

Bypass families (from sources read): intra-allocation overflows survive MIE per Apple's own caveat; logic bugs in JIT compilers corrupt memory inside the V8 sandbox, then need a separate sandbox bypass (V8 post); type-confusion/logic bugs in kernel subsystems (kernelCTF's disabled-subsystem list shows which surfaces produced the most bugs); non-memory bugs (command injection, auth bypass, deserialization) are unaffected by any memory-safety mitigation, which is why the appliance class stays productive.

## Trend direction
- Memory safety: Android first-party share below 20% [AND-RUST]; Chromium moving to bounds-checked C++ libraries, MTE and safer languages [CHR-MS]; Apple hardware enforcement [APPLE-MIE]; Windows Rust effort is mentioned only via secondary results (unverified).
- Where yield moved: GTIG says browser 0-days fell to historical lows and enterprise/edge hit a record 48% [GTIG-2025]; GTIG attributes browser decline to hardening but also notes better attacker opsec could reduce observed counts, so it is not a clean causal result.
- Kernel: volume of fixes and CVEs is rising sharply, driven by CNA policy and, per secondary reporting, AI-aided scanning (unverified).
- AI: an LLM-driven flood of reports hit open-source maintainers (curl) while the same technology found hundreds of validated bugs in OSS (Anthropic). Net effect for a human newcomer: shallow-bug discovery in popular, well-fuzzed OSS is the most contested space.
- CHERI: not researched in this pass. Open item.

## Rate-determining steps (field-level, what the evidence says is hard)
- Picking a target class where the learner can reach the "exploit" outcome: mitigated platforms (iPhone 17, Chrome) need chains of 2-3 bugs plus sandbox escapes (V8 post; Apple bounty ceiling; Chrome VRP separates V8 sandbox issues from renderer bugs).
- Getting bugs that are not already found: curl's falling confirmed-report rate and the OSS-Fuzz scale both indicate that easy bugs in popular parsers are exhausted or contested. (curl's own interpretation: easy bugs may be exhausted.)
- Reliability: kernelCTF scores stability over 20 runs with a pass line of 70%; Pwn2Own shows failed entries ("did not work in the allotted time") and collisions, so reliability and novelty are both gating.
- Test-harness / setup effort for embedded (acquisition, emulation): not measured here; open question.

## Emphasise (things experts rely on that tutorials skip)
- Reading advisories and RCAs to learn real bug distributions before choosing what to audit (Project Zero RCAs for 86% of listed CVEs; free).
- Non-memory-corruption classes: command injection, deserialization, path traversal, auth bypass are the top CWEs in the CISA KEV feed in 2025-2026 and top Pwn2Own Ireland outcomes.
- Variant analysis from patch diffs (Big Sleep, Anthropic GhostScript case both used commit history).
- Validation discipline: ASan-confirmed, minimal PoC, no fabricated findings (Anthropic validates every report; curl's experience punishes unvalidated reports).
- Collision awareness: Pwn2Own entries reduced or voided by prior knowledge of bugs.

## Exclude (or de-emphasise) with reasons
- Classic glibc heap-technique catalogues as the main path to a first 0-day: yield is in libraries and appliances, not in generic libc; and version-specific; `needs-lab-verification` for which techniques survive current glibc.
- Browser JIT exploitation as a first target: sandbox layering and the 2026 VRP structure show multi-stage requirement; GTIG shows browser exploitation at historic lows.
- Targeting iPhone 17 / MIE devices: unreachable without cost and research devices; vendor claims that chains are blocked.
- Cold-reporting AI-style scanner output to popular OSS projects: curl ended its bounty over this; HackerOne/Bugcrowd measures cited only by secondary sources (unverified).

## Candidate direct targets (field-level pointers; specific CVE shortlists belong in research/targets/)
- Open-source parsers and codecs with maintainer-friendly CNAs (OSS-Fuzz participants): suitable for fuzz-harness work. Need per-project verification of build and disclosure policy. Not shortlisted here.
- Pwn2Own-class consumer/SOHO devices with downloadable firmware (printers, NAS, bridges): public ZDI writeups exist for feedback. Lab feasibility depends on firmware availability and emulation, `build: unverified`.
- QEMU/VirtualBox device emulation (hypervisor class): VirtualBox fell to an OOB write in Berlin 2025; both are open-source and run on a laptop with nested virtualisation. Lab feasibility `unverified`.
- Linux kernel subsystems: kernelCTF provides a free, clear, rewarded target but on a hardened config; learner would need an exploit for current mainline, which is a stretch for a first bug.

## Ranked: suitability as a FIRST 0-day target for this learner
Criteria: cost of setup, source availability, size/complexity, disclosure/CVE path, competition, mitigation difficulty, evidence of time-to-first-bug (weak everywhere; see Open questions). Scores are my judgement from the evidence cited, not a measured quantity.

| Rank | Class | Reasoning | Key citations |
|---|---|---|---|
| 1 | Enterprise/edge appliances and SOHO/IoT devices with obtainable firmware (web admin and daemon surfaces) | Dominant real-world bug classes are command injection, deserialization, path traversal, auth bypass: no heap exploitation prerequisite for a first win; 48% of 2025 in-the-wild 0-days; Pwn2Own Ireland 2025 rewards simple classes (stack overflow, injection, auth bypass) on cheap devices; mitigations weak (2019-2020 data); CVE via vendor, ZDI or MITRE CNA-LR. Costs: firmware acquisition and emulation friction, vendor non-responsiveness, legal care. Learner must test only own devices or emulated images. | [GTIG-2025], [KEV], [P2O-I1], [EMB-2019] |
| 2 | Open-source libraries (parsers, codecs, compression, image) | Source available, builds on a laptop, OSS-Fuzz-style harnesses are free, CVE path is direct, ideal for fuzz-find-root-cause-disclose loop and the full pipeline. But high competition from fuzzers and LLMs and falling confirmed-report rates; first bug likely in less-fuzzed, smaller projects or new features. Memory-safety exploitation of libs is modern-mitigation dependent (embedding application decides). | [OSSFUZZ-unverified], [ANTH-0D], [CURL], [PZ-BS] |
| 3 | Hypervisors/device emulation (QEMU, VirtualBox) | Open source (QEMU), classic memory bugs (OOB write, heap overflow) in device models, Pwn2Own validated; but steep prerequisite stack and larger codebase; guest-to-host exploit needs mature heap skills. Good second target. | [P2O-B2], [P2O-B3] |
| 4 | Linux kernel | Source plus QEMU free, kernelCTF gives rewards and clear scoring, kernel CNA ensures CVEs for fixes; but hardened-config bar is high, subsystem attack surface (io_uring, userns) is disabled in the benchmark, heavy competition and AI-assisted volume. Better as bug-finding (fuzzing syzkaller-style) with a CVE via fix than as an exploit-first path. | [KCTF], [LWN-GKH] |
| 5 | Windows user-mode/kernel | Large closed-source surface, patch diffing is free, Microsoft is the top KEV vendor; but closed-source tooling, Windows licence/VM, HVCI/CET era mitigations, high competition from established researchers. | [KEV], [WIN-HVCI] |
| 6 | Android (AOSP/apps/vendor drivers) | AOSP is open, emulator is free; but first-party memory-safety share dropping (<20%), Scudo and MTE opt-in, vendor drivers need hardware; bounty exists. | [AND-RUST], [AND-MTE] |
| 7 | Browsers (Chrome/V8, Firefox, WebKit) | Source open, VRP pays, but extremely high competition and multi-stage mitigation, GTIG shows exploitation at historical lows; V8 bugs are logic-then-memory, steep prerequisites. Appropriate as a late capstone only. | [V8-SBX], [CHR-VRP], [GTIG-2025] |
| 8 | iOS/macOS/XNU on current hardware | Source for XNU partially open (not fetched, `unverified`), but MIE on newest devices, closed userland, hardware cost, research-device programme; highest ceiling bounty reflects difficulty. | [APPLE-MIE], [APPLE-BOUNTY] |

Rank-1 vs rank-2 is a judgement call; the evidence base for "time-to-first-bug" is missing, so this should be validated with a pilot learner.

## Resources (field-level cards; verified 2026-11-10)
T1 (all fetched). Scores: D directness, C currency, De depth, A activity, Co cost, Ac accessibility (1-5).

- GTIG 2025 zero-day review. https://cloud.google.com/blog/topics/threat-intelligence/2025-zero-day-review/ . Published 2026-03-05. D4 C5 De3 A1 Co5 Ac4. Assumes familiarity with CVE/vendor terms. Detailed counts only in figures not readable by fetch.
- GTIG 2024 zero-day trends. https://cloud.google.com/blog/topics/threat-intelligence/2024-zero-day-trends/ . D4 C4 De3 A1 Co5 Ac4. Note it reports 75; the 2025 review restates 2024 as 78.
- Project Zero 0day-in-the-wild page and RCA collection. https://projectzero.google/0day.html (RCAs at googleprojectzero.github.io/0days-in-the-wild/rca.html, linked from the page, RCA page itself not fetched). D5 C4 De5 A3 Co5 Ac3.
- CISA KEV JSON feed. https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json . D4 C5 De2 A3 (self-tallying is itself an exercise) Co5 Ac4.
- Chromium memory safety. https://www.chromium.org/Home/chromium-security/memory-safety/ . No date on page; D3 C3 De3.
- V8 sandbox post. https://v8.dev/blog/sandbox . D4 C3 (2024) De4 A1 Co5 Ac2.
- Apple MIE. https://security.apple.com/blog/memory-integrity-enforcement . D3 C5 De4 Co5 Ac3. Vendor self-assessment.
- Apple Security Bounty. https://security.apple.com/bounty/ . D3 C4 De1.
- Android Rust post. https://blog.google/security/rust-in-android-move-fast-fix-things/ . D3 C5 De3.
- AOSP MTE docs. https://source.android.com/docs/security/test/memory-safety/arm-mte . D4 C3 (no date) De4.
- kernelCTF rules. https://google.github.io/security-research/kernelctf/rules.html . D5 C5 De4 A5 Co5 Ac2. Silently assumes kernel exploit development competence.
- Chrome VRP update (secondary, Help Net Security). https://www.helpnetsecurity.com/2026/10/14/google-chrome-vulnerability-rewards-program-updates/ . T2/T3; primary Chrome VRP FAQ not fetched.
- ZDI Pwn2Own Berlin 2025 day two and day three; Ireland 2025 day one: URLs in Sources. D5 C5 De2 (results lists; per-bug writeups are linked elsewhere).
- Anthropic zero-days post. https://www.anthropic.com/research/zero-days . D3 C5 De3. Vendor self-report.
- curl bounty end post. https://daniel.haxx.se/blog/2026/01/26/the-end-of-the-curl-bug-bounty/ . D4 C5 De3.
- Project Zero Big Sleep. https://projectzero.google/2024/10/from-naptime-to-big-sleep.html . D3 C4 De4. URL slug says 2024/10, page states 2024-Nov-01.
- Microsoft Learn: memory integrity enablement and enable-memory-integrity how-to (URLs in Sources). T1.
- Embedded: Abbasi et al., arXiv:2007.02307 (abstract page). T1 peer-reviewed (EuroS&P 2019). D3 C2 De4.

## Open questions / conflicting sources
1. Time-to-first-bug for self-taught learners: no verified first-person account found. This is the biggest evidence gap for OSVR; a benchmark pass on practitioners' own blogs (not training-vendor testimonials) is needed.
2. GTIG counts: 2024 is 75 in the original review and 78 in the 2025 review; 2023 is 98 vs 100. Both fetched; use "as restated" when comparing years.
3. Whether browser decline is hardening or reduced detection (GTIG itself hedges).
4. Linux kernel CVE volume: counts in secondary reports (5,681 for 2025; 2,308 for H1 2026; about 2,000 per release) unverified; LWN excerpt confirms only the ranking claim. Interpretation disputed: counts reflect CNA policy as much as bug density.
5. AI impact on competition: Anthropic and Google report large AI-discovered bug sets (self-reported); curl experienced a flood of low-quality reports. TechTarget-reported figure (1,061 AI-attributed, 14 exploited in the wild as of June 2026) is secondary and unchecked.
6. Embedded mitigation data is 2019-2020; no recent large-scale measurement found.
7. Windows kernel-mode hardware-enforced stack protection default and Rust-in-Windows claims lack T1 support in this pass (Microsoft Learn pages for them returned 404).
8. CHERI and XNU open-source status not researched.
9. Pwn2Own Ireland 2025 totals and Berlin dollar figures: ZDI pages fetched for Berlin day 2/3 and Ireland day 1; Ireland final totals come from secondary press.

## Sources (fetched pages, verified: 2026-11-10)
- https://cloud.google.com/blog/topics/threat-intelligence/2025-zero-day-review/  [GTIG-2025]
- https://cloud.google.com/blog/topics/threat-intelligence/2024-zero-day-trends/  [GTIG-2024]
- https://projectzero.google/0day.html  [PZ-0day]
- https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json  [KEV] (catalogVersion 2026.11.10, 1,779 entries; tally computed locally)
- https://www.chromium.org/Home/chromium-security/memory-safety/  [CHR-MS]
- https://v8.dev/blog/sandbox  [V8-SBX]
- https://www.helpnetsecurity.com/2026/10/14/google-chrome-vulnerability-rewards-program-updates/  [CHR-VRP]
- https://security.apple.com/blog/memory-integrity-enforcement  [APPLE-MIE]
- https://security.apple.com/bounty/  [APPLE-BOUNTY]
- https://blog.google/security/rust-in-android-move-fast-fix-things/  [AND-RUST]
- https://source.android.com/docs/security/test/memory-safety/arm-mte  [AND-MTE]
- https://google.github.io/security-research/kernelctf/rules.html  [KCTF]
- https://www.kernel.org/doc/html/latest/security/self-protection.html  [KSP]
- https://lwn.net/Articles/1049963/  [LWN-GKH]
- https://www.thezdi.com/blog/2025/5/16/pwn2own-berlin-2025-day-two-results  [P2O-B2]
- https://www.zerodayinitiative.com/blog/2025/5/17/pwn2own-berlin-2025-day-three-results  [P2O-B3]
- https://www.thezdi.com/blog/2025/10/21/pwn2own-ireland-2025-day-one-results  [P2O-I1]
- https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/oem-hvci-enablement  [WIN-HVCI]
- https://learn.microsoft.com/en-us/windows/security/hardware-security/enable-virtualization-based-protection-of-code-integrity  [WIN-HVCI2]
- https://www.anthropic.com/research/zero-days  [ANTH-0D]
- https://daniel.haxx.se/blog/2026/01/26/the-end-of-the-curl-bug-bounty/  [CURL]
- https://projectzero.google/2024/10/from-naptime-to-big-sleep.html  [PZ-BS]
- https://arxiv.org/abs/2007.02307  [EMB-2019]
- https://raw.githubusercontent.com/bminor/glibc/glibc-2.32/NEWS  fetched but first 100,000 characters only; no safe-linking mention found in that portion (inconclusive).

## Could not reach / unverified (verified: null, status: unverified)
- https://phoronix.com/news/Linux-Kernel-CVEs-Nearly-2000  (HTTP 403) , kernel per-release CVE figures
- https://wiki.ubuntu.com/Security/Features  (404), distro default hardening table
- https://learn.microsoft.com/en-us/windows/security/hardware-security/kernel-mode-hardware-enforced-stack-protection  (404)
- https://sourceware.org/git/?p=glibc.git... (Anubis block)
- MSRC 2019 70% claim (msrc-blog.microsoft.com/2019/07/16/a-proactive-approach-to-more-secure-code/): seen only in search results, not fetched.
- OSS-Fuzz 13,000 vulnerabilities / 50,000 bugs figure: search summary only; project page not fetched.
- Pwn2Own Ireland 2025 totals ($1,024,750; 73 zero-days) and Berlin day one: secondary press only.
- CyberITL 2019 firmware study; Binarly UEFI 2025; AISLE, Glasswing, TechTarget, HackerOne/Bugcrowd AI-slop policy changes: search summaries only.
- Google Docs 0day spreadsheet and the Chrome sandbox-escape $250,000 payment (CVE-2025-4609): not fetched.
- Phoronix-reported kernel Recipes 2026 slide; Luca Berton 5,681 figure: secondary blog.
