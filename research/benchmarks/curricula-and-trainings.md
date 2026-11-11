# Benchmark: structure and sequencing of existing curricula and trainings
Researched: 2026-11-10   Scope: syllabi part only (expert paths and job postings live in other files). Structure only; no course content reproduced.

## Question list (written before searching)
1. What do the free paths (pwn.college, OST2, Exploit Education, Nightmare, how2heap, RPISEC MBE) cover and in what order?
2. What do university courses with public syllabi cover and in what order (UCR CS 250, GT CS 6265, ASU CSE 598, RPI MBE)?
3. What do certification-linked OffSec courses (EXP-301, EXP-312, EXP-401) cover, cost, require?
4. What do commercial and conference trainings cover (SANS SEC760, RET2, Margin Research, Zero Day Engineering, OffensiveCon 2026, Hexacon 2026, Corellium/8kSec)?
5. Cross-curricula: canonical order, universal inclusions, common omissions, hour totals zero to heap/kernel.
6. Which of Ret2 Wargames, Signal Labs, Dataflow Security exist and publish syllabi?

Answered: 1-5 mostly; 6 partly (see "Could not reach"). Many syllabi are PDFs the fetch tool could not decode, so several rows are partial. Status flag per row: V = page fetched and read; P = partial (page fetched but lacks the field); U = not read.

## 1. Comparison table

Cost "free" = no payment for material. "Real?" = do learners end on real software/CVEs (R) or toy/CTF challenges (T).

### Free

| Curriculum (provider) | Cost | Topics in order | Hours/duration | Prerequisites | Mitigation era | Real? | Assessment | Status |
|---|---|---|---|---|---|---|---|---|
| pwn.college official dojos (ASU) | Free | Start Here (2 modules) -> Linux Luminarium (17) -> Computing 101 (13) -> Playing With Programs (4) -> Intro to Cybersecurity (7) -> Program Security (5) -> System Security (6) -> Software Exploitation (5). | Not stated | None stated | Not stated on page. Titles show ASLR/ROP/allocator era, plus Kernel and Microarchitecture modules | T (challenge dojos; ASU AVR course targets XNU, see below) | Flags (automated), belts | V |
| pwn.college Program Security | Free | Program Security -> Reverse Engineering -> Return Oriented Programming -> Dynamic Allocator Misuse -> Program Exploitation (39/36/30/40/14 challenges as listed) | Not stated | Not stated | Not stated | T | Flags | V |
| pwn.college Software Exploitation (blue belt) | Free | Format String Exploits -> File Struct Exploits -> Exploitation Primitives -> Dynamic Allocator Exploitation -> Kernel Exploitation | Not stated | Not stated | Not stated | T | Flags | V |
| pwn.college System Security (green belt) | Free | Introduction -> Sandboxing -> Race Conditions -> Kernel Security -> Microarchitecture Exploitation -> System Exploitation | Not stated | Not stated | Not stated | T | Flags | V |
| pwn.college community dojos (listed) | Free | Fuzz Dojo (4 modules, 80 challenges), Kernel Exercise Collection (1 module, 6 challenges), x86 Exploitation, Intro RE & BinExp, "Reversing Hell" course dojo | Not stated | Not stated | Not stated | T | Flags | V (listing only) |
| ASU CSE 598 Applied Vulnerability Research, F2024 (on pwn.college) | University course; pwn.college material free | Target selection -> recon -> analysis planning -> vulnerability detection -> PoC -> exploit development -> responsible disclosure. Centred on Apple XNU | Weekly 2h45 meeting, 7-14 modules of 1-2 weeks each | CSE 466 or equivalent: x86_64 RE, shellcode, kernel C | Not stated | R (real kernel) | Module flags only, no exams; extra credit for disclosing issues in course infrastructure | V |
| OpenSecurityTraining2 (OST2) | Free | Catalogue (not a prescribed order on the page): Arch1001 x86-64 asm, Arch2001 OS internals, Dbg1012 GDB, Dbg1101-1103 IDA/Ghidra/Binja, Vulns1001/1002 C-family implementation vulns, Fuzz1001 AFL++, SecDev1001/1002, RE3011 C++, RE3201 symbolic analysis, Exp4011 Windows kernel race+UAF in KTM, Arch4001 firmware | Not found | Not found | Not found | Mixed (Exp4011 is a named real bug class; details not read) | Not found | P (catalogue only; learning-path pages returned truncated or 404; third-party PDF copy of the path seen in search, not used) |
| Exploit Education (Phoenix/Nebula/Fusion/Protostar) | Free | Phoenix: stack zero-six, format zero-four, heap zero-three, net zero-two, final zero-two. Nebula: Linux privesc, scripting, FS races (levels 00-19). Fusion: advanced memory corruption/format/heap (00-14), "modern protection systems". Protostar archived, replaced by Phoenix | Not stated | Phoenix/Nebula "starting point"; Fusion for those familiar with Linux exploitation | Phoenix: explicitly old-style, no modern mitigations; Fusion: modern protections (era not dated on page) | T | None (self-check) | V |
| Nightmare (guyinatuxedo) | Free | Beginner tooling (asm, Ghidra, GDB, pwntools) -> stack BOF (+ASLR/PIE/NX/canary/RELRO intros) -> format strings -> array indexing -> bad seed -> Z3/angr -> ROP (partial overwrite, pivot, SROP, ret2csu) -> heap (double free, UAF, unlink, fastbin, unsorted, large, tcache, House of ...) -> integer overflow -> FILE exploitation -> grab bag -> auto pwning | Not stated | None stated | Not dated; only a "GLibc Tcache" heading, no versions | T (CTF challenges) | None | V |
| how2heap (shellcode-factory / shellphish) | Free | One .c per technique per glibc version dir (2.23 to 2.43). Basics -> fastbin -> tcache -> safe-linking -> unsorted/small/large bins -> top chunk -> overflow-based (unlink, poison null byte, einherjar) -> arena. No stated reading order | Not stated | Not stated | Explicit per-glibc-version; safe-linking (2.32+) included; techniques marked fixed by patch | T (isolated demos) | None | V |
| RPISEC Modern Binary Exploitation (RPI, Spring 2015) | Free (BSD-2 code, CC BY-NC slides) | 15 lectures: RE x2 -> memory corruption -> shellcode -> format strings -> DEP/ROP -> consoles -> ASLR -> heap -> stack cookies/misc -> C++ -> Linux kernel -> 64-bit/ARM/Windows -> automation and fuzzing. 10 labs + 2 comprehensive projects | Two sessions per week for a semester | Not stated in repo; syllabus (secondary source) suggested a text | 2015-era (NX, ASLR, canaries; ASLR enabled from Lab 06) | T plus term projects exploiting real vulns (per a secondary summary, not primary) | Weekly labs, 2 projects | V (lecture/lab order); era check: dated |
| GT CS 6265 Info Sec Lab (Taesoo Kim) Spring 2025 | Free to read; course tuition if enrolled | Warm-up x86/GDB -> shellcode -> stack overflow -> pwntools -> canaries -> DEP/ASLR + format string -> ROP -> advanced ROP -> remote exploitation -> integer/race -> heap allocator design and exploitation -> fuzzing / symbolic execution / hybrid fuzzing -> online CTF | ~15 weeks; weekly hours not stated | OS course (e.g. GT CS 3210); aimed at seniors/grad students | Modern userland (canary, DEP, ASLR) | T (labs); fuzzing appears in last week | All labs (flags), no exams, no projects | V |
| UCR CS 250 Software Security, Spring 2025 | Free to read | Binary code comprehension -> dynamic binary instrumentation -> taint analysis -> symbolic execution -> fuzzing -> exploit generation -> hardening -> binary rewriting -> static analysis -> pointer analysis; then student paper presentations | ~10 weeks of lectures plus paper weeks | Not listed | Research-oriented | T (3 labs: exploit construction, symex/fuzz, CFI) plus term paper | Labs 30, presentation 20, paper reviews 10, term paper 30, participation 10 | V |
| From Day Zero to Zero Day (E. Lim, No Starch, 2025) | Book, $47.99 ebook / $59.99 print+ebook | Target selection -> code analysis (taint, attack surface) -> RE (Ghidra, Frida, angr) -> bug discovery (fuzzing, symbolic execution, variant analysis) -> exploitation and PoC validation | 344 pages | Not stated | Not stated | R (per publisher blurb; not read) | None | P (publisher page only) |

### Paid, certification-linked and commercial

| Curriculum (provider) | Cost (public) | Topics in order | Hours/duration | Prerequisites | Mitigation era | Real? | Assessment | Status |
|---|---|---|---|---|---|---|---|---|
| OffSec EXP-301 / OSED (Windows user mode) | $1,749 course+cert bundle (90 days access, 1 exam try); Learn One $2,749 list or $2,199/yr | Page lists skill areas only: stack overflows, RE with IDA + debugger, dynamic analysis, custom shellcode, advanced stack overflow/SEH, format string read primitive. 13 modules + 3 challenge labs. Module titles not obtainable (PDF not decodable) | Page states "932 hours of content", which looks like a typo (possibly pages); treat as unreliable | None formal; recommends debuggers, 32-bit exploitation basics, Python 3 | DEP, ASLR (32-bit Windows focus) | T-like lab apps (some real software per community accounts, not verified here) | 48h proctored exam, 3 tasks, proof file | V (page), P (syllabus) |
| OffSec EXP-401 / OSEE | Price not on page | Page: user-mode mitigation bypass -> advanced heap manipulation -> WDEG disarm, version independence -> kernel mitigation bypass. A third-party review (VoidSec) gives a 5-day order: custom shellcode + VMware internals -> VMware guest-host escape + Edge/Chakra internals -> Edge type confusion, CFG/CET/ACG, sandbox escape -> Windows kernel driver callback overwrite -> Win32k with VBS/HVCI/CET/kCFG | Review: 5 days; hours not stated by OffSec | OSED required but "in no way sufficient" per reviewer, who suggests ~1 year of study before the exam | Modern Windows: EAF, CFG, CET, ACG, VBS, HVCI, kCFG | R (VMware Workstation, Edge/Chakra, third-party drivers, Win32k) | 72h proctored exam; find and exploit unknown vulns, plus report | V (page), V (review, T3 secondary) |
| OffSec EXP-312 / OSMR (macOS) | Not found | Search snippet of the official syllabus PDF (2023): kernel code execution/KEXT, injection and dylib hijacking, interposing, Mach IPC and task port injection, XPC, TCC internals, two named CVE case studies, Ventura mitigations chain, macOS pentest | Not found | Not found | macOS Ventura | R (CVE case studies) | 48h proctored (search summary) | U (official URL redirects; PDF redirected; only search snippets) |
| SANS SEC760 Advanced Exploit Development | $8,780 OnDemand (4 months) | IDA/mitigations/Windows kernel debugging -> advanced Linux exploitation (heap, tcache, V8 intro) -> advanced fuzzing (coverage-guided, WinAFL, full-system) -> patch diffing and 1-day exploits -> Windows kernel exploitation (token stealing) | 5 days live; 40 h self-paced; 20 labs | SEC660 only true prerequisite (DEP/ASLR/canary bypass, fuzzers, x86 reading) | WDEG; "sample" of mitigations | Patch-diff 1-day section implies real patches (not detailed) | No capstone listed | V |
| RET2 "Fundamentals of Browser Exploitation" | $3,499 per seat | Browser architecture (V8/JSC, GC) -> JS engine vulns (primitives, JIT overwrite) -> JIT compilation and vuln classes -> exploit engineering (browser mitigations, SOP bypass, sandbox overview, fuzzing, Chrome N-day exercise) | 1-2 weeks full time / 2-4 part time; 30 days instructor access, 90 days VM | DEP/ASLR/ROP, good C++ and JS, assembly debugging, Linux CLI | Browser mitigations (versions not stated) | R (Chrome N-day) | Exercises; none formal stated | V |
| RET2 Wargames | Price not on page; free demo | 2 courses: Fundamentals of Software Exploitation (x86-64) and ARM; 10 chapters, 50+ lab binaries, browser-based | Not stated | Not stated | Not stated | T | Gamified checkpoints, certificate | V (price not read) |
| Margin Research / Vector 35 "Program Analysis for Vulnerability Research" (OffensiveCon 2024) | Not stated | Day 1 architecture + BN plugins -> D2 ILs, correctness -> D3 SSA/dominance, type analysis, abstract interpretation -> D4 constant propagation, fixed points, pointer/interprocedural analysis, batch processing; optional day heap analysis | 4 days + optional day | Python 3.8+, familiarity with vuln classes | n/a (analysis) | R-ish: "hundreds of real world targets" in batch, no named CVEs | Exercises | V |
| Zero Day Engineering | Not listed | Tiers: Foundations (Zero Day Vulnerability Research) -> Core (Hypervisor VR, Browser Exploit Design) -> Advanced (Hypervisor exploit engineering, Chrome full chain) | 4 days live or 3 months self-paced each | Foundations: "(almost) zero" stated on one page; Core/Advanced build on Foundations | Not stated | R ("grounded in real bugs", Pwn2Own reference) | Not stated | V (listing); P (syllabus PDF undecodable). Foundations topic order seen: linear stack overflow, linear heap overflow, non-linear OOB write, integer issues, each with prevention/detection/mitigation |
| OffensiveCon 2026 "Exploiting the Linux Kernel" (A. Konovalov) | 4.800 EUR (ticket page, via search snippet) | D1 internals, attack surface, vuln types, debugging setup, privesc basics -> D2 KASLR/SMEP/SMAP/KPTI bypass, in-kernel ROP, SLUB internals, OOB/UAF -> D3 cache merging, hardened usercopy, msg_msg/pipe_buffer, end-to-end N-day -> D4 cross-cache/cross-allocator, page pointer corruption; stretch: page-table exploitation, second N-day | 4 days | Working C, x86-64 asm, GDB, userland exploit techniques; no kernel internals needed | Modern x86-64 Linux: KASLR, SMEP, SMAP, KPTI, hardened usercopy, SLUB protections | R (N-day exploits) | Hands-on labs | V (page); price from search snippet only |
| OffensiveCon 2026 other trainings | Not stated | Advanced Fuzzing and Crash Analysis (R. Johnson), Hunting Zero-Days in Embedded Devices (Ribeiro/Domanski), Practical iOS RE (Classen, 4 days), Advanced Baseband Exploitation, AI-powered Bughunting, EDR course | Mostly not stated | Not stated | n/a | Mixed | n/a | V (listing only) |
| Hexacon 2026 trainings (Paris, 12-15 Oct) | Not stated | 8 trainings: IM apps attacks, Bug Hunting in Hypervisors, Exploiting the Android Kernel, iOS for Security Engineers, Malware OPSEC, Baseband, Software Deobfuscation, Windows Internals for Security Engineers | Not stated | Not stated | n/a | Mixed | n/a | V (listing only) |
| Corellium / 8kSec (iOS) | 8kSec on-demand Offensive iOS Internals: 17 h, 104 videos (search snippet) | iOS architecture -> lab setup -> sandbox escape, entitlements, XPC, kernel and PAC case studies | 17 h on-demand | Jailbroken device or Corellium | iOS 16+ with PAC etc. | R (case studies) | Certification exam (8kSec) | P (search snippets only; Corellium page redirected to Cellebrite and was not read) |
| HeapLAB (Max Kamper, Udemy) | Not read | glibc heap exploitation, two parts (search snippet) | Not read | Not read | Not read | Not read | Not read | U (Udemy 403) |

## 2. Cross-curricula analysis

### Canonical ordering (observed in RPISEC MBE, GT CS 6265, Nightmare, pwn.college program-security, Phoenix)
1. Tooling and low-level fluency: assembly, debugger, disassembler, scripting (pwntools).
2. Reverse-engineering practice (crackmes, "bomb" labs).
3. Stack overflow and shellcode with no mitigations.
4. Format strings.
5. Mitigations introduced one at a time with their bypass: canaries, then DEP/ROP, then ASLR/leaks, then PIE/RELRO.
6. Heap: allocator theory, then bug classes (UAF, double free, overflow), then allocator-version-specific techniques.
7. Odds and ends: integers, races, C++.
8. Kernel as an advanced, optional, last unit (MBE lecture 13, pwn.college Kernel modules).
9. Automation (fuzzing, symbolic execution) last or as a side module.

Observation: in all the free courses, fuzzing sits at the end (MBE lecture 15, GT week 15, UCR middle), never earlier as a way of finding bugs. pwn.college keeps it only in a community dojo.

### What almost everyone includes
Stack overflow, ROP, format strings, heap exploitation, mitigations and bypasses, GDB plus a disassembler, Python scripting. Flag-based automatic checking is the dominant feedback form (pwn.college, GT, ASU).

### Commonly missing
- **Finding bugs in real code.** Free paths give the learner a known-vulnerable binary. Only ASU CSE 598 (full find-to-disclose pipeline), UCR (research-style), Margin Research, and OffSec EXP-401 exam (find unknown vulns) test discovery. Fuzzing as a primary discovery skill appears in SANS SEC760, OffensiveCon fuzzing training, OST2 Fuzz1001, pwn.college Fuzz Dojo (community).
- **Variant analysis and patch diffing.** Only SEC760 (1-day via patch diffing), a Recon training seen in search results (not fetched), and Lim's book. Absent from all free syllabi read.
- **Disclosure and advisory writing.** Only ASU CSE 598 lists "responsible disclosure" as a topic, and only EXP-401 requires a report. No syllabus read teaches CVE assignment or advisory writing.
- **Attack-surface mapping and target selection.** Present in ASU CSE 598 (target selection, recon, analysis planning), Lim's book, Zero Day Engineering. Absent elsewhere.
- **Modern-mitigation era.** Phoenix, Protostar, RPISEC (2015) are explicitly old-style. Only how2heap (per-glibc), OffensiveCon kernel, EXP-401 and RET2 browser name modern mitigations.
- **Ending on real software.** Most free paths end on challenge binaries. The paid advanced tier (EXP-401, Konovalov, RET2 browser, Zero Day Engineering) ends on N-days or real products.

### Gaps OSVR could fill
1. A path that continues from "solved the toy" to "find a bug in real code" with fuzzing introduced in the first third, not as an appendix.
2. Variant analysis / patch diffing as a core skill, not seen in any free course read.
3. Disclosure workflow with real practice (advisory draft, vendor contact), only ASU names it.
4. Explicit per-mitigation-era labelling (how2heap does this for glibc; nobody does it for the whole path).
5. A free, laptop-feasible kernel step comparable in structure to the OffensiveCon course (internals, mitigations, SLUB, N-day).
6. Feedback beyond flags: assessor rubrics and public writeups (only OffSec exams and ASU extra credit approximate this).

### Hour totals from zero (what the sources support)
No source states total hours from zero to "can exploit modern glibc heap" or "kernel". Anchors that are sourced:
- Konovalov kernel: 4 days (about 32-36 h) assuming userland exploitation already learned.
- RET2 browser: 1-2 weeks full time (about 40-80 h) assuming ROP/ASLR knowledge.
- SANS SEC760: 40 h self-paced plus lab time, after SEC660.
- EXP-401 reviewer: suggests about a year of self-study beyond OSED before the exam; 5-day course.
- 8kSec on-demand iOS: 17 h video.
- University: a semester (about 14-15 weeks) reaches heap exploitation and a taste of fuzzing (GT CS 6265, RPISEC).

Inference (not sourced, needs adjudication): at 10 h/week, a one-semester-equivalent path (~15 weeks, roughly 150 h plus lab time) reaches classic stack/ROP/heap; modern-glibc heap plus a kernel track plausibly adds 100-200 h. Treat as a design assumption, `needs-lab-verification` with real learners.

## 3. Implications for OSVR
Suggestions the architect may accept or reject.
1. **Adopt the canonical order as the first third of the tree, but compress it.** Tooling, RE, stack, format string, mitigation-by-mitigation, heap, with how2heap's per-glibc-version convention used for the heap module and an explicit mitigation-era line per module (D9).
2. **Move fuzzing and variant analysis earlier.** Every free syllabus puts fuzzing last; this matches none of the "find" outcome. Suggest a short fuzzing module right after ROP, run against a real library at a pinned version.
3. **Add patch-diff / N-day work as the bridge to real targets**, mirroring Konovalov D3-D4 (N-day exploit end to end) and SEC760 patch-diffing, since an N-day is a legal, reproducible direct target.
4. **Put disclosure and advisory writing in every track's capstone**, modelled on ASU CSE 598's target selection through responsible disclosure and EXP-401's report requirement; nobody else teaches this.
5. **Treat kernel (Linux) as a later track gated on heap, with a 4-day-equivalent core** (internals, mitigations, SLUB, msg_msg/pipe_buffer, cross-cache). Windows kernel and browsers are later-tier and mostly paid elsewhere; consider deferring.
6. **Use flag checkers for drills (pwn.college-style) and assessor rubrics for projects.** Flags alone never test "find" or "disclose".
7. **Do not base the hour budget on provider claims.** None exist from zero. Run the first pilot and log actual hours; seed estimates with the anchors above.
8. **Use OST2 for foundations (x86-64 asm, GDB, Ghidra, Vulns1001/Fuzz1001) only after reading each course page**, because hours and prerequisites could not be retrieved here.

## Could not reach (verified: null, status: unverified)
- OffSec EXP-301 syllabus PDFs (offsec.com/documentation/EXP301-syllabus.pdf and manage.offsec.com 2026 version): fetched but content is compressed PDF, text undecodable; module titles not obtained. Page stated "932 hours", questionable.
- OffSec EXP-312 course page (301 redirect to course index) and 2023 syllabus PDF (302 redirect): only search-snippet summary.
- OffSec help-centre FAQs for EXP-301 and EXP-401: 403.
- OffSec EXP-401 official syllabus and price: not found; only reseller PDFs.
- OST2 learning-path pages, Vulns1001 and Fuzz1001 course pages (404), hours and prerequisites: not obtained.
- GT CS 6265 syllabus PDF, UMass CS 390R syllabus PDF, TUM Binary Exploitation I PDF: PDFs not decodable (GT's HTML schedule was read instead).
- 8kSec applied-fuzzing syllabus PDF, Zero Day Engineering syllabus PDF: image-only or undecodable.
- RET2 Wargames price and level list; Ringzer0 Windows VR page (404).
- Udemy HeapLAB (403); Black Hat USA 2026 training schedule (403).
- Hexacon and OffensiveCon durations/prices (not on listing pages).
- Signal Labs and Dataflow Security: searches returned nothing confirming either; not asserted to exist.
- Corellium course page (redirects to Cellebrite; not read).

Manual fetch suggestion for the user: the EXP-301/312 PDFs, OST2 learning-path pages with a browser, and Black Hat training listings.

## Sources (fetched 2026-11-10 unless noted)
Fetched and read (V/P):
- https://pwn.college/ ; https://pwn.college/dojos ; https://pwn.college/program-security/ ; https://pwn.college/software-exploitation/ ; https://pwn.college/system-security/ ; https://pwn.college/dojo/cse598-avr-f2024/course/identity
- https://p.ost2.fyi/ (catalogue only)
- https://www.offsec.com/courses/exp-301/ ; https://www.offsec.com/courses/exp-401/ ; https://www.offsec.com/courses/
- https://voidsec.com/?p=4457 (T3 secondary review of EXP-401)
- https://exploit.education/ ; https://guyinatuxedo.github.io/ ; https://github.com/shellphish/how2heap ; https://github.com/RPISEC/MBE
- https://tc.gts3.org/cs6265/2025-spring/cal.html ; https://tc.gts3.org/cs6265/2025-spring/info.html
- https://www.cs.ucr.edu/~heng/teaching/cs250-sp25/index.html
- https://ret2.io/trainings ; https://wargames.ret2.systems/
- https://www.sans.org/cyber-security-courses/advanced-exploit-development-penetration-testers
- https://margin.re/training/ ; https://zerodayengineering.com/training/ ; https://zerodayengineering.com/training/universal-vulnerability-research.html
- https://www.offensivecon.org/trainings/2026/ ; https://www.offensivecon.org/trainings/2026/exploiting-the-linux-kernel.html
- https://www.hexacon.fr/trainings/
- https://nostarch.com/zero-day
Search-snippet only (not fetched, unverified): EXP-312 syllabus PDF, 8kSec/Corellium pages, RPISEC secondary summaries, Dataflow-related results, ticket page price for Konovalov course.
