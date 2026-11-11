# Field synthesis: zero-to-0-day metalearning sweep
Written: 2026-11-10   Mode: BUILD / metalearning   Inputs: the five files below. Nothing here is new evidence; every claim traces to one of them, which hold the fetched sources.

| Key | File |
|---|---|
| [EXP] | `research/benchmarks/expert-paths.md` |
| [CUR] | `research/benchmarks/curricula-and-trainings.md` |
| [JOB] | `research/benchmarks/job-market.md` |
| [FLD] | `research/domain-maps/field-overview.md` |
| [LSC] | `research/benchmarks/learning-science.md` |

Status: proposals for the architect. Anything that changes `CLAUDE.md`, the DoD or `skill-tree.yaml` needs a decision record and the owner's approval first.

---

## 1. Ten findings that should shape the design

1. **Real 0-day volume is not mostly heap exploitation.** In 2025, Google's 0-day review (GTIG) counted 90 in-the-wild 0-days. 48% were enterprise or edge products, and memory safety was about 35% overall. In CISA KEV entries added in 2025-26, injection, deserialization, traversal and SSRF types (183) and authentication or access-control types (95) outnumber memory corruption (90). Pwn2Own Ireland 2025 rewarded stack overflows, injection and auth bypass on cheap devices. *Design consequence:* teach logic, injection and auth bug classes as first-class content in VD, not only memory corruption in BX. [FLD]

2. **Free curricula all share one order, and all stop at the same point.** The order is tooling/RE, stack, format strings, mitigations one at a time, heap, then kernel. They end on toy binaries. Only paid advanced trainings end on real N-days or products. *Consequence:* keep the canonical order for the first third, compressed, then go to real targets. OSVR's free advantage is the stretch after that. [CUR]

3. **Fuzzing, variant analysis and disclosure are the clearest gaps.** Fuzzing is last or absent in every free syllabus read. Patch diffing and variant analysis appear only in SANS SEC760 and one book. Disclosure appears only in ASU CSE 598. These map onto the `find` and `disclose` outcomes nobody else trains. *Consequence:* put fuzzing in the first third, make N-day patch diffing the bridge to real targets, and put a disclosure deliverable in every track capstone. [CUR], [FLD], [EXP]

4. **Hiring asks for one real, explainable find, not a degree and not a specific platform.** Of 31 live postings, only the two student pipelines hard-require a degree. Twelve say "or equivalent", Interrupt Labs says no education needed, and the rest do not mention one. No live posting requires Linux-kernel or browser exploitation specifically. The recurring core is OS internals, RE, code audit and a demonstrated find. Written reporting is the most frequently required skill. The real barriers are clearance, residency and language. *Consequence:* FND, RE, BX, VD and PRO are the hiring-critical spine; kernel, hypervisor and browser are depth options. Grade writing as a core skill. [JOB]

5. **Setting up the environment costs more than finding the bug.** Hyper-V harness setup took months, and the bug came two hours after the harness was stable. A kernel exploit had a remote-vs-local divergence that cost days. One router researcher spent a year with bugs they could not trigger, plus reboot loops. *Consequence:* add a dedicated lab-parity and debugging module (emulation, debugger attach, harness stability, remote/local parity) before the first 0-day attempt. Treat the harness as a rate-determining step in VD. [EXP]

6. **Finding bugs and writing exploits are different skills.** Hypr says so explicitly and uses 1-days for exploit practice. Curricula hand learners known-vulnerable binaries, so they train exploitation only. *Consequence:* use separate drill sets and separate rubrics. N-days feed exploit practice; audit, fuzzing and variant work feed finding. [EXP], [CUR]

7. **The easiest discovery space is now contested by AI and fuzzers.** Anthropic reported more than 500 validated OSS memory bugs (self-reported). Big Sleep found a SQLite bug via variant analysis. curl ended its bounty after its confirmed-report rate fell below 5%. 13 of 31 postings expect AI as a target or as a research accelerant. Collisions are real: CVE-2022-0185 had two finders and an untriaged fuzzer hit. *Consequence:* weight validation, root cause, reliability, novelty checks and report quality over raw bug count. Teach AI-assisted VR as a cross-cutting skill, with independent validation of every finding. [FLD], [JOB], [EXP]

8. **"Struggle before the walkthrough" helps only once the learner has prior knowledge.** This is a direct conflict with DoD D5. For novices, unassisted discovery lost to explicit instruction (d = -0.38), while guided discovery and worked examples won (d = +0.30). Problem-solving before instruction helped (g = 0.36) only with consolidation, and it reversed for some populations. Expertise reversal cuts the other way for advanced learners. *Consequence:* make D5 conditional. Use a worked example with subgoal labels for a never-seen technique, then a closed-book challenge once a short prerequisite check passes, then a comparison to the reference solution. Needs a DR. [LSC]

9. **Retrieval and spacing are strong for facts and concepts, but weak for transfer unless cards ask for application.** Classroom quizzing gives g ≈ 0.5. Transfer is weakest to untested material. The optimal spacing gap is a fraction of the retention horizon (Cepeda 2008), so the "15 min daily vs 2 h weekly" figure has no source. Subgoal-labelled worked examples and Parsons-style reordering are the best programming-education evidence. Feedback hurt performance in over a third of interventions when aimed at the person rather than the task. *Consequence:* rewrite the D4 card guidance toward "next step on a fresh case". Add reorder and complete drills for exploit steps. Keep assessor feedback at task level. [LSC]

10. **Much of the contract is assumption, not evidence, and must be measured.** The 2026 GRADE review rates CTF effectiveness evidence Low to Very Low. Deliberate practice is contested (<1% of variance in professions). No source was found for the ~10% planning budget, 50/10 timeboxes, the 20-minute struggle rule or the six-rung hint ladder. Time-to-first-bug data are anecdotes: about 3 months for web, about 6 months for a hypervisor fuzzing project, more than a year for browser JIT, about a year for a router. No provider publishes hours from zero to modern heap or kernel. *Consequence:* label these as tunable pilot parameters in docs. Instrument the pilot: time-to-first-hint, retention at 4 and 12 weeks on fresh binaries, weeks active, and actual hours per module. Do not market time-to-0-day claims. [LSC], [EXP], [CUR]

---

## 2. Proposed track set and order

The seed set in CLAUDE.md mostly holds. Changes: order by hiring value and first-0-day reachability, widen EMB to cover appliances, and treat PRO as woven through all tracks rather than placed at the end.

| Order | Track | Role | Rationale |
|---|---|---|---|
| 0 | **FND** foundations | Spine | C, Python, Linux, x86-64 and AArch64 assembly, debugger, plus a short self-regulated-learning primer in module 1 ([LSC] attrition). Every expert path starts with programming and assembly before memory corruption [EXP]. |
| 1 | **RE** reverse engineering | Spine | Required in nearly all low-level postings [JOB]. RE-first is the dominant employed path into VR [EXP]. |
| 2 | **BX** binary exploitation, userland | Spine | Canonical order compressed, with mitigation-era labelling per glibc version in the how2heap style [CUR]. Exploit drills come from N-days (finding 6). |
| 2' | **VD** vulnerability discovery | Spine, starts in parallel with mid-BX | Code audit, fuzzing with harness engineering, patch diffing and variant analysis, logic, injection and auth classes. It starts in the first third, not at the end (findings 1, 3, 5). Includes the lab-parity module. |
| 3 | **EMB** embedded, firmware and **appliances** | First-0-day track | Firmware extraction and emulation, web-admin and daemon surfaces, memory bugs in daemons. This is where the first 0-day capstone lives (section 4). Changing EMB's scope needs a DR. |
| ∥ | **PRO** professional practice | Woven, with a capstone | Disclosure, CVE and CNA paths, advisory writing, collision and novelty checks, the portfolio-to-posting map, and clearance, residency and language gates [JOB]. One PRO module attaches to each track capstone. |
| 4 | **LK** Linux kernel | Depth | Gated on BX heap. Model it on the structure of the 4-day OffensiveCon kernel course: internals, KASLR/SMEP/SMAP/KPTI, SLUB, msg_msg/pipe_buffer, cross-cache, end-to-end N-day [CUR]. Teach the kernelCTF hardened config as the current bar [FLD]. |
| 5 | **HV** hypervisors | Depth | QEMU and VirtualBox device models. Classic memory bugs, open source, laptop-feasible with nested virtualisation (`needs-lab-verification`) [FLD]. Good second 0-day class. |
| 6 | **WIN** Windows | Depth | Microsoft is the top KEV vendor, and patch diffing is free. The closed toolchain, HVCI default and high competition put it later [FLD]. |
| 7 | **MOB** mobile | Late | Android memory-safety share is below 20% and MTE is opt-in. Current iOS has MIE (Apple's always-on hardware memory tagging) [FLD]. |
| 8 | **BRW** browsers | Capstone-tier only | Chains of multiple bugs plus sandbox escape. In-the-wild browser 0-days are at historic lows. Prerequisites are steep [FLD]. |

Cross-cutting, not a track: **AI-assisted VR** (LLM triage, harness generation, independent validation) as a recurring VD and PRO module or drill, plus a short "attacking agentic systems" module for product-security roles [JOB]. CHERI and XNU were not researched.

Rough hours, to be verified by pilot logs: FND through mid-BX is about one university semester, about 150 h [CUR, inference]. The VD and EMB first-0-day capstone comes after that. At 10 h/week, the target is "credible junior evidence in 12-24 months" [JOB].

---

## 3. Terminal outcomes: proposed wording changes

Keep five outcomes. Three wording changes are supported by the evidence:

1. **Find**: "...discover a previously unknown bug through manual audit, fuzzing or variant analysis, **and check it is novel** (not a duplicate or a known fuzzer hit) before reporting." Why: collision risk and AI-volume contention (finding 7).
2. **Exploit**: "Build a reliable exploit against modern mitigations on a current target, in a lab they control. **For non-memory bug classes, a reliable proof of concept that demonstrates the real impact** (e.g. pre-auth RCE via command injection)." Why: about half of real 0-days are logic or injection bugs where "against modern mitigations" does not apply (finding 1). Also add measurable reliability, e.g. a kernelCTF-style stability threshold [FLD].
3. **Disclose**: "Write a vendor-grade advisory, run coordinated disclosure through to a CVE or fix, **and publish a technical writeup that explains the bug to the line**." Why: the public writeup is the single portfolio artefact hiring asks for (finding 4).

Separately, and **needing your approval and a DR**: make DoD **D5** conditional on prior knowledge (finding 8), and revise the **D4** card guidance toward application on fresh cases (finding 9).

---

## 4. Realistic first 0-day target class

**Recommendation: SOHO, IoT and network appliance firmware, using devices the learner owns or emulated firmware images, attacked through the web-admin and network-daemon surfaces.**

Reasoning:
- **Bug classes need no heap prerequisite for a first win.** Command injection, auth bypass, path traversal and stack overflows in daemons are the dominant classes in KEV and at Pwn2Own Ireland [FLD].
- **Mitigations are weak.** Embedded mitigation adoption lags general-purpose systems. This rests on 2019-20 data, so it is `needs-lab-verification` per device [FLD].
- **There is a feedback loop and a CVE path.** Public ZDI and Pwn2Own writeups give feedback. The CVE path runs through the vendor, ZDI or the MITRE CNA of last resort [FLD].
- **It exercises the whole pipeline** (map, find, root-cause, exploit, disclose) on a laptop, with a cheap device as an optional extra.

Risks and mitigations:
- **Emulation and acquisition friction.** One researcher spent a year with bugs they could not trigger [EXP]. The lab-parity module (finding 5) is the counter.
- **Unresponsive vendors.** PRO teaches the CNA and ZDI fallback.
- **Legal scope.** The learner works only on devices they own or on emulated images, never on deployed devices (CLAUDE.md ethics).

**Runner-up / parallel option:** small, under-fuzzed open-source C libraries (parsers, codecs). They are source-available, OSS-Fuzz-style harnesses are free, and the CVE path is direct. But competition from fuzzers and AI is highest there [FLD]. Use this option when the learner's goal is low-level VR hiring, which leans toward memory corruption and code audit [JOB].

Choosing between the two rests on judgement, not data. Validate with a pilot learner.

---

## 5. Conflicts between sources and open questions

| # | Conflict / question | Sources | Proposed handling |
|---|---|---|---|
| C1 | **Hiring vs field.** The field's 0-day volume is logic and injection bugs on appliances, while low-level VR hiring centres on memory corruption, RE and OS internals. | [FLD] vs [JOB] | Teach both. The first-0-day track (EMB) should include at least one daemon memory-corruption project. |
| C2 | **CTFs.** Experts credit CTFs as an on-ramp, but the effectiveness evidence is Low or Very Low, and Hypr says real bugs teach more. | [EXP] vs [LSC] | Treat CTFs as a labelled ramp with an explicit exit criterion. |
| C3 | **Struggle-first.** The contract puts the struggle first; the evidence says worked examples first for novices. | CLAUDE.md D5 vs [LSC] | DR needed (section 3). |
| C4 | **The no-degree premise.** Hiring supports it, but documented no-degree careers in native-code VR are thin (the only self-described dropout found works in web). | [JOB] vs [EXP] | Do not market it as well documented. Fetch MalwareTech's essay and more profiles. |
| C5 | **Browser decline.** Is it hardening or better attacker opsec? GTIG itself hedges. | [FLD] | Placement late is unaffected either way. |
| C6 | **Kernel CVE volume.** Does it reflect CNA policy or bug density? | [FLD] | Don't use CVE counts to argue LK priority. |
| C7 | **Deliberate practice.** Ericsson and Macnamara disagree on definitions. | [LSC] | Use "targeted, feedback-rich practice"; avoid hour claims. |

Open questions:
- **Q1. Time-to-first-bug for self-taught, part-time learners.** No data exists. The pilot must produce it.
- **Q2. glibc userland defaults** (safe-linking, tcache key, distro hardening flags) were not T1-verified. Run a BX domain map before `/design BX`.
- **Q3. Embedded mitigation state after 2020.** No recent measurement was found.
- **Q4. Windows defaults.** The CET and kernel stack-protection defaults and the Rust-in-Windows status were not verified.
- **Q5. CHERI and XNU.** Not researched (CHERI is a hardware memory-safety architecture; XNU is Apple's kernel). XNU source availability is unknown.
- **Q6. Hour budgets from zero.** None published; only inferred anchors.
- **Q7. Junior role sample.** The sample is small and under-represents defence and government-adjacent employers. Re-run in 90 days.

---

## 6. Sources that could not be reached (please fetch manually)

**Highest value first**
1. MalwareTech, "Infosec Without a Degree": `malwaretech.com/2016/05/infosec-without-degree.html` (403). Bears directly on C4. [EXP]
2. OffSec EXP-301, EXP-312 and EXP-401 syllabus PDFs and FAQs. The PDFs were fetched but are undecodable without `pdftotext`. [CUR]
3. OpenSecurityTraining2 learning-path pages, plus the Vulns1001 and Fuzz1001 course pages (404 or truncated), for hours and prerequisites. [CUR]
4. grsecurity "Security Researcher - Linux Kernel": `opensrcsec.com/security_researcher_linux_kernel` (HTTP 500). The only explicit kernel-exploit role found. [JOB]
5. glibc NEWS on sourceware (bot-blocked) and the Ubuntu Security/Features wiki (404), for userland defaults (Q2). [FLD]

**PDFs already downloaded but unreadable** (install `poppler` for `pdftotext`; treat them as untrusted downloads)
- Silvanovich USENIX *;login:* interview: `/home/miguel/.claude/projects/-home-miguel-Repos-osvr/a28ace43-37bc-48d3-a261-9a2ce487b821/tool-results/webfetch-1794344375568-mg4wpv.pdf`
- HITCON 2025 "Compromising Linux the Right Way": `/home/miguel/.claude/projects/-home-miguel-Repos-osvr/a28ace43-37bc-48d3-a261-9a2ce487b821/tool-results/webfetch-1794344522641-cdz3aq.pdf`
- The GT CS 6265, UMass CS 390R, TUM Binary Exploitation, 8kSec fuzzing and Zero Day Engineering syllabus PDFs [CUR]

**Other**
- Field data [FLD]:
  - Phoronix kernel CVE article (403)
  - Microsoft Learn kernel-mode hardware-enforced stack protection page (404)
  - MSRC 2019 "70%" post
  - OSS-Fuzz project page
  - Project Zero 0-day spreadsheet
  - Chrome VRP FAQ (primary)
  - Pwn2Own Ireland 2025 day 2 and 3 pages, and Berlin day 1
- Expert paths [EXP]: Cashdollar's CVE.org story, the 35C3 subtitles (amara.org), Dark Reading "Strange Journey", and the Guided Hacking podcast.
- Job market [JOB]:
  - NCC Group Exploit Development Group roles
  - Apple SEAR (Apple's security research team), Intel Paris, Arm, Palo Alto, Oligo
  - Google Android Product Security and Google Threat Intelligence Group (GTIG) exploit roles
  - Quarkslab and Synacktiv current openings
- Learning science [LSC], full text: Bisra et al. 2018 (self-explanation meta-analysis), Barbieri et al. 2023 (worked examples), Latimier et al. 2021 (spacing and retrieval), Dunlosky et al. 2013 (full PDF). The PubMed/PMC captcha blocked these, and the Springer, SAGE and ACM pages returned 403.
- Commercial trainings [CUR]: RET2 Wargames pricing, the Black Hat USA 2026 training schedule (403), and Udemy HeapLAB (403).
