# OSVR: Open Security Vulnerability Research

A path through existing, mostly free resources that takes you from "can use a terminal" to finding, root-causing, exploiting and disclosing previously unknown vulnerabilities. Nothing here is original course material: OSVR picks the best existing courses, wargames, books and papers, puts them in order, and says why each one is there.

See [FAQ.md](FAQ.md) and [CONTRIBUTING.md](CONTRIBUTING.md).

## Contents

- [How to use this](#how-to-use-this)
- [Curriculum](#curriculum)
  - [1. Foundations](#1-foundations)
  - [2. Reverse engineering](#2-reverse-engineering)
  - [3. Binary exploitation](#3-binary-exploitation)
  - [4. Vulnerability discovery](#4-vulnerability-discovery)
  - [5. Disclosure and professional practice](#5-disclosure-and-professional-practice)
  - [6. Specialisations](#6-specialisations)
  - [7. Final project](#7-final-project)
- [Extras](#extras)

## How to use this

- Go top to bottom. Within a section, do the **Core** rows in order. **Alt** rows replace the row above them; **Ref** rows are references to keep open, not to read cover to cover.
- **Cost**: most core rows are free. Where a paid resource is clearly the best option it is listed and marked, with a free alternative where one exists.
- **Effort**: shown only where the provider states it (challenge counts, stated hours). Providers rarely publish hours, so OSVR does not invent them.
- Every section ends with a **milestone**: something you build or find, using the material above, that proves you can move on.
- **Ethics**: do hands-on work only in your own lab, on CTF or wargame infrastructure, on archived vulnerable versions, or inside a published bug-bounty scope. Never against systems you do not own.
- Links were last checked 2026-11-10/11. Dead link? Open an issue (see CONTRIBUTING).

## Curriculum

### 1. Foundations

Programming, Linux, how a C program becomes a running process, x86-64 assembly and a debugger. Every expert path in the [research](research/benchmarks/expert-paths.md) starts here before touching memory corruption.

**Programming** (skip if you can already write a 100-line program without a tutorial)

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [CS50x](https://cs50.harvard.edu/x/) (Harvard) | Free (certificate paid) | 11 weeks + final project | C first, then Python. Teaches pointers and memory in-course |
| Alt | [Python Programming MOOC](https://programming-24.mooc.fi/) (U. Helsinki) | Free | 14 parts | Python only; 2024 edition, check for a newer one |
| Alt | [Python for Everybody](https://www.py4e.com/) | Free | | Autograded assignments |
| Practice | [Exercism C track](https://exercism.org/tracks/c) | Free | | Mentored exercises |

**Linux and the command line**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Linux Luminarium](https://pwn.college/linux-luminarium/) (pwn.college) | Free | Challenge-based | Shell, files, processes, permissions |
| Core | [Computing 101](https://pwn.college/computing-101/) (pwn.college) | Free | Challenge-based | Assembly and how computers run programs |

**C and undefined behaviour**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Modern C](https://gustedt.gitlabpages.inria.fr/modern-c/) (Jens Gustedt) | Free | Book | C23 edition |
| Ref | [Beej's Guide to C: Pointers](https://beej.us/guide/bgc/html/split/pointers.html) | Free | Chapter | The clearest short pointer explanation |
| Ref | [What Every C Programmer Should Know About Undefined Behavior](https://blog.llvm.org/2011/05/what-every-c-programmer-should-know.html) (LLVM blog) | Free | Article | Why the compiler can break your "obvious" code |

**Systems, assembly and debugging**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Architecture 1001: x86-64 Assembly](https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Arch1001_x86-64_Asm+2021_v1/about) (OST2) | Free | | Read assembly fluently |
| Core | [Debuggers 1012: Introductory GDB](https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Dbg1012_IntroGDB+2024_v1/about) (OST2) | Free | | |
| Core | [CS:APP3e labs](https://csapp.cs.cmu.edu/3e/labs.html) (Bryant & O'Hallaron, CMU) | Labs free; book paid | 11 labs | Do Data, Bomb and Attack labs at minimum. Attack Lab is your first exploit |
| Core | [Operating Systems: Three Easy Pieces](https://pages.cs.wisc.edu/~remzi/OSTEP/) | Free online | Book | Virtual memory, processes, concurrency. Assumes some C |
| Alt | [Nand to Tetris](https://www.nand2tetris.org/) | Free | | Gentler bottom-up path if CS:APP is too steep |
| Ref | [AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html) (Clang docs) | Free | | You will build everything with ASan from here on |
| Ref | [pwndbg](https://github.com/pwndbg/pwndbg) or [GEF](https://github.com/hugsy/gef) | Free | | GDB plugins for exploitation work |
| Ref | [pwntools docs](https://docs.pwntools.com/en/stable/) | Free | | Python exploit scripting library |

**Milestone**: finish [Intro to Cybersecurity](https://pwn.college/intro-to-cybersecurity/) (pwn.college, 7 modules, 183 challenges) and the CS:APP Bomb and Attack labs.

### 2. Reverse engineering

Read compiled code you did not write. Required in nearly every low-level research job posting ([job-market research](research/benchmarks/job-market.md)).

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Debuggers 1102: Introductory Ghidra](https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Dbg1102_IntroGhidra+2024_v2/about) (OST2) | Free | | |
| Core | [pwn.college Reverse Engineering](https://pwn.college/program-security/reverse-engineering/) | Free | 36 challenges | |
| Core | [Reverse Engineering for Beginners](https://beginners.re/) (Dennis Yurichev) | Free | Book | Read alongside; how compilers emit each C construct |
| Paid | [The Ghidra Book, 2nd ed.](https://nostarch.com/GhidraBook) (No Starch) | Paid | Book | Best single Ghidra reference |
| Paid | [Practical Binary Analysis](https://nostarch.com/binaryanalysis) (Andriesse, No Starch, 2018) | $49.99 ebook | Book, exercises | ELF internals, instrumentation, taint, symbolic execution |
| Ref | [Ghidra releases](https://github.com/NationalSecurityAgency/ghidra/releases/tag/Ghidra_12.2_build) and [Ghidra class slides](https://github.com/NationalSecurityAgency/ghidra/tree/Ghidra_12.2_build/GhidraDocs/GhidraClass/Intermediate) | Free | | Scripting, headless analysis, version tracking |
| Ref | [Frida: frida-trace](https://frida.re/docs/frida-trace/) | Free | | Dynamic instrumentation |
| Practice | [crackmes.one](https://crackmes.one/) | Free | | Unlimited practice binaries, sorted by difficulty |

**Milestone**: solve 10 crackmes.one binaries of rising difficulty without reading their solutions, and write up one in full.

### 3. Binary exploitation

Turn a memory bug into control of a program, against the mitigations that are on by default today.

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [pwn.college Program Security](https://pwn.college/program-security/) | Free | 5 modules, 162 challenges | Memory errors, shellcode, ROP, allocator misuse |
| Core | [ROP Emporium](https://ropemporium.com/) | Free | 8 challenges | Return-oriented programming, ret2win to ret2csu |
| Core | [pwn.college Software Exploitation](https://pwn.college/software-exploitation/) | Free | 5 modules, 90 challenges | Format strings, FILE structs, primitives, heap, kernel intro |
| Core | [how2heap](https://github.com/shellphish/how2heap) (shellphish) | Free | One demo per technique | glibc heap techniques, organised by glibc version (2.23 to 2.43). Always check which version a technique still works on |
| Alt | [Exploit Education Phoenix](https://exploit.education/phoenix/) | Free | Stack, Format, Heap, Net, Final levels | Gentler, but mitigations are deliberately off: not a picture of current defaults |
| Ref | [Nightmare](https://guyinatuxedo.github.io/) (guyinatuxedo) | Free | 90+ CTF challenges with writeups | Look up a technique by CTF example |
| Ref | [RPISEC Modern Binary Exploitation](https://github.com/RPISEC/MBE) | Free | 15 lectures, 10 labs, 2 projects | Complete 2015 university course. Good structure, dated mitigations |
| Ref | [OpenSSF Compiler Options Hardening Guide](https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html) | Free | | What each mitigation flag does |
| Ref | [glibc NEWS](https://raw.githubusercontent.com/bminor/glibc/master/NEWS) | Free | | Allocator hardening by release |
| Paid | [Hacking: The Art of Exploitation, 2nd ed.](https://nostarch.com/hacking2.htm) (Erickson, 2008) | $39.99 ebook | Book | Classic intro, but 2008-era mitigations. Optional |

**Milestone**: finish Program Security and Software Exploitation through Dynamic Allocator Exploitation, then exploit one how2heap technique on the newest glibc it supports, with ASLR, PIE, NX and full RELRO on.

### 4. Vulnerability discovery

Find bugs nobody gave you: code audit, fuzzing, variant analysis, patch diffing. Most free curricula skip this or leave it to the end ([curricula research](research/benchmarks/curricula-and-trainings.md)). Here it is core.

**Bug classes and code audit**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Vulnerabilities 1001: C-Family Implementation Vulns](https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Vulns1001_C-family+2023_v1/about) (OST2) | Free | | Overflows, OOB writes, integer bugs, each with real CVEs |
| Core | [Web Security Academy](https://portswigger.net/web-security) (PortSwigger) | Free | Labs per topic | Injection, auth and access-control bugs: about half of real-world 0-days ([field research](research/domain-maps/field-overview.md)) |
| Ref | [OWASP Web Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/) | Free | | |
| Paid | [From Day Zero to Zero Day](https://nostarch.com/zero-day) (Eugene Lim, No Starch, 2025) | $47.99 ebook | 344 pp | The only book covering the whole find workflow: attack surface, taint, variant analysis, fuzzing, PoC |

**Fuzzing**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Fuzzing 1001: Intro to AFL++](https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Fuzz1001_Intro_AFL+2025_v1/about) (OST2) | Free | | Coverage-guided fuzzing, ASan, instrumentation modes |
| Core | [Fuzzing101](https://github.com/antonio-morales/Fuzzing101) (GitHub Security Lab) | Free | 10 exercises, 2 to 8 h each | Rediscover real CVEs in Xpdf, libexif, tcpdump, libxml2 and more. Last updated 2022 |
| Core | [Testing Handbook: Fuzzing](https://appsec.guide/docs/fuzzing/) (Trail of Bits) | Free | "An afternoon" per section | Writing harnesses, libFuzzer, AFL++, LibAFL, OSS-Fuzz |
| Ref | [The Fuzzing Book](https://www.fuzzingbook.org/) (Zeller et al.) | Free | Book, Jupyter | Theory: grammar, greybox, symbolic fuzzing |
| Ref | [libFuzzer](https://llvm.org/docs/LibFuzzer.html), [AFL++ fuzzing in depth](https://raw.githubusercontent.com/AFLplusplus/AFLplusplus/stable/docs/fuzzing_in_depth.md), [OSS-Fuzz new project guide](https://google.github.io/oss-fuzz/getting-started/new-project-guide/) | Free | | |

**Static analysis, variant analysis and patch diffing**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [CodeQL for C and C++](https://codeql.github.com/docs/codeql-language-guides/codeql-for-cpp) | Free | | Query code for variants of a known bug |
| Practice | [GitHub Security Lab CTFs](https://securitylab.github.com/ctf/) | Free | 6 challenges | Contests are closed but U-Boot and SEGV Hunt still work as CodeQL exercises |
| Ref | [Semgrep taint mode](https://docs.semgrep.dev/writing-rules/data-flow/taint-mode/overview) | Freemium | | |
| Core | [Patch Diffing with Ghidra](https://ihack4falafel.github.io/Patch-Diffing-with-Ghidra) | Free | Article | From a vendor patch back to the bug |
| Ref | [ghidriff](https://clearbluejar.github.io/posts/ghidriff-ghidra-binary-diffing-engine), [BinDiff](https://github.com/google/bindiff), [Diaphora](https://github.com/joxeankoret/diaphora) | Free | | Diffing tools |

**Root-causing crashes**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Ref | [rr](https://rr-project.org/) | Free | | Record and replay; step backwards from a crash |
| Ref | [CASR](https://github.com/ispras/casr) | Free | | Crash triage and deduplication |
| Read | [Root Cause Analyses for 0-days In-the-Wild](https://projectzero.google/2020/07/root-cause-analyses-for-0-day-in-wild.html) (Project Zero) | Free | | What a real root-cause analysis looks like |
| Read | [The WebP 0day](https://blog.isosceles.com/the-webp-0day/) (Isosceles) | Free | | Worked root cause of a famous parser bug |
| Read | [Windows Registry Adventure #7: Attack surface analysis](https://projectzero.google/2025/05/the-windows-registry-adventure-7-attack-surface.html) (Project Zero) | Free | | How an expert maps attack surface |

**Milestone**: rediscover a known CVE with a fuzzer you set up yourself (any Fuzzing101 exercise), root-cause it to the line, then find the same bug from the patch alone by diffing.

### 5. Disclosure and professional practice

Turn a bug into a fix, a CVE and a public writeup.

| | Resource | Cost | Notes |
|---|---|---|---|
| Core | [CERT Guide to Coordinated Vulnerability Disclosure](https://certcc.github.io/CERT-Guide-to-CVD/) | Free | How disclosure works end to end |
| Core | [CWE root cause mapping guidance](https://cwe.mitre.org/documents/cwe_usage/guidance.html) | Free | Pick the right CWE for your bug |
| Core | [CVSS v4.0 specification](https://www.first.org/cvss/v4.0/specification-document) | Free | Score severity |
| Core | [MITRE CNA of Last Resort](https://mitre.github.io/mitre-cve-roles/CNA-LR/) and [CVE ID request form](https://mitre.github.io/mitre-cve-roles/cve-id-request) | Free | Getting a CVE when the vendor is not a CNA |
| Ref | [Project Zero disclosure policy](https://projectzero.google/vulnerability-disclosure-policy.html), [ZDI disclosure policy](https://www.zerodayinitiative.com/advisories/disclosure_policy/) | Free | Two reference policies and timelines |
| Ref | [Linux kernel: security bugs](https://docs.kernel.org/process/security-bugs.html) | Free | Example of a project's own reporting process |
| Ref | [HackerOne: duplicate reports](https://docs.hackerone.com/en/articles/8475030-duplicate-reports), [Gold Standard Safe Harbor](https://docs.hackerone.com/organizations/safe-harbor-statement.html) | Free | Bounty-platform rules |
| Read | [The end of the curl bug-bounty](https://daniel.haxx.se/blog/2026/01/26/the-end-of-the-curl-bug-bounty/) (Daniel Stenberg, 2026) | Free | Why report quality and validation matter more than volume |

Laws differ by country. Read your local computer-misuse law and any programme's safe-harbour terms yourself; this list is not legal advice.

**Milestone**: write a full advisory (summary, affected versions, root cause, CWE, CVSS, PoC, fix) for the CVE you rediscovered in section 4, as if you were reporting it.

### 6. Specialisations

Pick one after section 5. Each assumes sections 1 to 5.

**Linux kernel**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Architecture 2001: x86-64 OS Internals](https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Arch2001_x86-64_OS_Internals+2024_v1/about) (OST2) | Free | | Rings, paging, interrupts |
| Core | [pwn.college System Security](https://pwn.college/system-security/) | Free | 6 modules, 95 challenges | Sandboxing, races, Kernel Security |
| Core | [Learning Linux Kernel Exploitation, Part 1](https://lkmidas.github.io/posts/20210123-linux-kernel-pwn-part-1/) (Midas, 2021) | Free | Series | QEMU setup, mitigations, first kernel ROP |
| Core | [pwn.college Kernel Exploitation](https://pwn.college/software-exploitation/kernel-exploitation/) | Free | 8 levels | Slab allocators up to hardened freelists. Do after Kernel Security |
| Ref | [xairy/linux-kernel-exploitation](https://github.com/xairy/linux-kernel-exploitation) (Andrey Konovalov) | Free | | The reference link collection, updated bimonthly |
| Ref | [kernelCTF rules](https://google.github.io/security-research/kernelctf/rules.html) and [published kernelCTF exploits](https://github.com/google/security-research/tree/master/pocs/linux/kernelctf) (Google) | Free | | The current bar for hardened targets, plus real exploits to study |
| Paid | [Exploiting the Linux Kernel](https://www.offensivecon.org/trainings/2026/exploiting-the-linux-kernel.html) (Konovalov, OffensiveCon) | €4,800 | 4 days | Best structured course; ran May 2026, 2027 dates not announced |

**Windows**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Windows Internals, 7th ed.](https://learn.microsoft.com/en-us/sysinternals/resources/windows-internals) (Yosifovich, Ionescu, Russinovich, Solomon) | Paid | Book | No free substitute |
| Core | [HackSys Extreme Vulnerable Driver](https://github.com/hacksysteam/HackSysExtremeVulnerableDriver) | Free | | Intentionally vulnerable driver: overflow, UAF, type confusion, races |
| Core | [Exploitation 4011: Windows Kernel Race + UAF in KTM](https://p.ost2.fyi/courses/course-v1:OpenSecurityTraining2+Exp4011_Windows_Kernel_UAF_KTM+2023_v1/about) (OST2) | Free | | Full exploit for CVE-2018-8611. Needs OST2 Dbg3011 first |
| Ref | [Connor McGarr's blog](https://connormcgarr.github.io/) | Free | | Windows kernel exploitation, SMEP, HVCI, kCFG |

**Browsers**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Chrome Browser Exploitation series](https://jhalon.github.io/chrome-browser-exploitation-1/) (Jack Halon) | Free | Series | Free path into V8 internals and exploitation |
| Ref | [V8 docs](https://v8.dev/docs) | Free | | Engine internals, building and debugging V8 |
| Ref | [Chromium security FAQ](https://chromium.googlesource.com/chromium/src/+/main/docs/security/faq.md) | Free | | What Chrome counts as a security bug |
| Practice | [Fuzzilli](https://github.com/googleprojectzero/fuzzilli) (Project Zero) | Free | | JavaScript engine fuzzer |
| Paid | [RET2 Fundamentals of Browser Exploitation](https://ret2.io/trainings) | $3,499 | 1 to 2 weeks full time | Ends on a Chrome N-day |
| Paid | [Zero Day Engineering trainings](https://zerodayengineering.com/training/) | Price not listed | 4 days live or 3 months self-paced | Includes a Chrome full-chain course |

**Embedded and firmware**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Azeria Labs: ARM assembly](https://azeria-labs.com/writing-arm-assembly-part-1/) | Free | 7 parts | 32-bit ARM, 2017. Leads into ARM exploit development |
| Core | [Architecture 4001](https://ost2.fyi/Arch4001) (OST2) | Free | | Firmware course |
| Core | [binwalk](https://github.com/ReFirmLabs/binwalk) | Free | | Firmware extraction |
| Core | [FirmAE](https://github.com/pr0v3rbs/FirmAE) | Free | | Emulate extracted firmware so you can test it on a laptop |
| Ref | [EMBA](https://github.com/e-m-b-a/emba) | Free | | Automated firmware analysis |
| Practice | [Damn Vulnerable Router Firmware](https://github.com/praetorian-inc/DVRF) | Free | | Intentionally vulnerable router firmware |
| Paid | [The Hardware Hacking Handbook](https://nostarch.com/hardwarehacking) (No Starch) | Paid | Book | Physical attacks and hardware interfaces |

**Mobile (Android first)**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [Android security overview](https://source.android.com/docs/security/overview) | Free | | Platform security model |
| Core | [OWASP MASTG](https://mas.owasp.org/MASTG/) | Free | | Mobile app testing guide |
| Practice | [Android security bulletins](https://source.android.com/docs/security/bulletin) | Free | Monthly | Pick a fixed bug, diff the patch, reproduce it |
| Paid | [Hexacon trainings](https://www.hexacon.fr/trainings/) | Price not listed | | 2026 list included Exploiting the Android Kernel |

**Hypervisors**

| | Resource | Cost | Effort | Notes |
|---|---|---|---|---|
| Core | [QEMU developer docs](https://www.qemu.org/docs/master/devel/index.html) | Free | | Device emulation code is the main attack surface |
| Ref | [google/security-research PoCs](https://github.com/google/security-research/tree/master/pocs) | Free | | Published exploits to study |
| Paid | [Zero Day Engineering trainings](https://zerodayengineering.com/training/) | Price not listed | 4 days live or 3 months self-paced | Hypervisor VR and exploit-engineering courses |
| Paid | [Hexacon trainings](https://www.hexacon.fr/trainings/) | Price not listed | | 2026 list included Bug Hunting in Hypervisors |

Embedded, mobile and hypervisor rows were checked by hand on 2026-11-11. Their descriptions are thin and need filling in: see [CONTRIBUTING.md](CONTRIBUTING.md).

### 7. Final project

Find, root-cause and disclose a previously unknown bug in real software.

1. **Pick a target** you are allowed to test: an open-source library or service you build locally, firmware you emulate, or a target inside a published bounty scope. [research/targets/VD.md](research/targets/VD.md) lists candidate open-source libraries and network services, with notes on how heavily each is already fuzzed.
2. **Map** its attack surface and write down your top three entry points and why.
3. **Find** a bug by audit, fuzzing or variant analysis. Check it is new: not fixed upstream, not already in the issue tracker, not a known OSS-Fuzz crash.
4. **Root-cause** it to the line, name the CWE, and say what primitive it gives.
5. **Prove impact**: a reliable PoC in your own lab. For memory bugs, aim for an exploit and measure reliability (kernelCTF scores stability over 20 runs and requires 70%; that is a good bar).
6. **Disclose** through the vendor, their CNA or the MITRE CNA of Last Resort, then publish a writeup once the timeline allows.

## Extras

**AI-assisted vulnerability research**: read these, and validate everything a model claims yourself.

- [Project Naptime](https://projectzero.google/2024/06/project-naptime.html) and [From Naptime to Big Sleep](https://projectzero.google/2024/10/from-naptime-to-big-sleep.html) (Project Zero)
- [How I used o3 to find CVE-2025-37899](https://sean.heelan.io/2025/05/22/how-i-used-o3-to-find-cve-2025-37899/) (Sean Heelan)
- [Evaluating and mitigating the growing risk of LLM-discovered 0-days](https://www.anthropic.com/research/zero-days) (Anthropic)

**Research behind the ordering**: [research/](research/) holds the evidence: how [experts learned](research/benchmarks/expert-paths.md), what [existing curricula cover](research/benchmarks/curricula-and-trainings.md), what [employers ask for](research/benchmarks/job-market.md), and [where 0-days are found today](research/domain-maps/field-overview.md).
