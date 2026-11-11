# Benchmark: vulnerability research / exploit development job market
Researched: 2026-11-10   Questions answered: 7/8 (Q8 partial)
Scope note: this file covers job postings only. Expert learning paths and training syllabi are in other files (see `expert-paths.md`).

## Questions planned (written before searching)
1. Which employers currently advertise VR / exploit-dev / offensive-research / product-security-bug-finding roles, in the US and Europe, on primary ATS or career pages?
2. What do the postings require vs prefer (skills, languages, platforms)?
3. How often is a degree required, "or equivalent", or absent? Clearance or citizenship gates?
4. What portfolio signals are asked for (CVEs, CTFs, talks, OSS)?
5. What is the entry-level bar, and what skills appear at junior level?
6. How do senior postings differ?
7. Which postings are closed or expired?
8. Which hiring channels could not be reached (so the maintainer can fetch manually)?

## Method and source integrity
- Postings were pulled from primary hosts where possible: Greenhouse public board API (`boards-api.greenhouse.io`), Workable widget API (Trail of Bits), Workday CxS JSON endpoints (NVIDIA, CrowdStrike), Microsoft's careers API (`apply.careers.microsoft.com/api/pcsx`), Google Careers HTML (embedded data), Teamtailor pages (Interrupt Labs, Breakpoint), Taleez (Quarkslab).
- All 37 postings below were fetched on **2026-11-10** (`verified: 2026-11-10`). 31 are live and form the tally set (N=31). 6 are closed, expired or stale and are excluded from tallies.
- Where a posting page was JS-only I used the ATS JSON. Leads I could not fetch from a primary source are listed in "Unverified leads" and are not tallied.
- Postings are summarised, not pasted. Salary figures are given only where they help calibrate.
- Limitation: the sample is what the search tooling and ATS boards exposed. Defence primes and government-adjacent exploit shops rarely post on open ATS boards, so that segment is under-represented (see Q8).

## Posting catalogue (live, tally set, N=31)
Columns: ID, employer, title, location, seniority, degree, clearance/gate. URL column holds the primary posting URL.
Seniority = stated years or level. "n/s" = not stated.

| ID | Employer | Title | Location | Seniority | Degree | Clearance / gate | URL |
|---|---|---|---|---|---|---|---|
| P01 | VulnCheck | Sr. Exploit Developer (UK) | Cheltenham UK, 100% remote | Senior, yrs n/s | not mentioned | export-control authorisation note | https://job-boards.greenhouse.io/vulncheck/jobs/4009149009 |
| P02 | VulnCheck | Sr. Exploit Developer (US) | Maryland US ($200-235k) | Senior, yrs n/s; closes 2026-12-31 | not mentioned | export-control authorisation note | https://job-boards.greenhouse.io/vulncheck/jobs/4229803009 |
| P03 | Interrupt Labs | Experienced Vulnerability Researcher | Basingstoke/London, fully remote | Experienced, yrs n/s | "No formal education or certifications required" | UK permanent resident, UK-based | https://interruptlabs.teamtailor.com/jobs/8198199-experienced-vulnerability-researcher |
| P04 | Interrupt Labs | Embedded Systems Vulnerability Researcher | Basingstoke, onsite | mid/senior, n/s | not mentioned | eligible for UK SC | https://interruptlabs.teamtailor.com/jobs/8401108-embedded-systems-vulnerability-researcher |
| P05 | Interrupt Labs | Vulnerability Research Summer Internship 2027 | Basingstoke, onsite | Intern | currently in penultimate/final university year | eligible for UK SC | https://interruptlabs.teamtailor.com/jobs/8546434-vulnerability-research-summer-internship-2027 |
| P06 | Google (Project Zero) | Senior Security Engineer, Security Research | Munich, DE | Senior, 5 yrs RE | Bachelor's "or equivalent practical experience" | none stated | https://google.com/about/careers/applications/jobs/results/136445532154274502 |
| P07 | Microsoft | Principal Security Researcher (Cloud & AI) | US multi-location | Principal, 3-6 yrs by degree | degree-ladder OR equivalent experience | US citizenship verification (gov customers); export control | https://apply.careers.microsoft.com/careers/job/1970393557054084 |
| P08 | Microsoft | Principal Security Researcher, Red Team | Redmond WA | Principal, 3-6 yrs by degree | degree-ladder OR equivalent experience | background check | https://apply.careers.microsoft.com/careers/job/1970393557048172 |
| P09 | Microsoft | Security Researcher II / Senior | US multi-location | 1-2 yrs (II) up to 4 yrs | degree-ladder OR equivalent experience | citizenship/export verification | https://apply.careers.microsoft.com/careers/job/1970393557053911 |
| P10 | Microsoft | Senior Security Researcher (Linux emphasis) | Redmond WA | 4 yrs with Bachelor's | degree-ladder OR equivalent experience | background check | https://apply.careers.microsoft.com/careers/job/1970393557050370 |
| P11 | Microsoft | Senior Security Researcher, CTJ, TS/SCI | Reston VA / Redmond WA | 4 yrs with Bachelor's | degree-ladder OR equivalent experience | **TS/SCI + US citizenship** | https://apply.careers.microsoft.com/careers/job/1970393557050359 |
| P12 | CrowdStrike | Sr. Vulnerability Researcher (Remote, DEU) | Germany remote (+4 more countries) | 4+ yrs | M.A./M.Sc. "or equivalent professional experience" | none stated | https://crowdstrike.wd5.myworkdayjobs.com/crowdstrikecareers/job/Germany---Remote/Sr-Security-Researcher-II--Remote--DEU-_R28953 |
| P13 | CrowdStrike | Sr. Security Researcher (exploit intelligence) | US remote | Senior, yrs n/s | MA/MS "or equivalent experience" | none stated | https://crowdstrike.wd5.myworkdayjobs.com/crowdstrikecareers/job/USA---Remote/Sr-Security-Researcher--Remote-_R29549 |
| P14 | NVIDIA | Offensive Hardware Security Researcher | Santa Clara CA | 6+ yrs | BS/BA "or equivalent experience" | none stated | https://nvidia.wd5.myworkdayjobs.com/NVIDIAExternalCareerSite/job/US-CA-Santa-Clara/Offensive-Hardware-Security-Researcher_JR2016209 |
| P15 | NVIDIA | Senior Offensive Security Engineer, Automotive | Santa Clara CA | 7+ yrs; **page says accepted "at least until 2026-11-03", still listed** | B.S. "or equivalent experience" | none stated | https://nvidia.wd5.myworkdayjobs.com/NVIDIAExternalCareerSite/job/US-CA-Santa-Clara/Senior-Offensive-Security-Engineer--Automotive_JR2022838-1 |
| P16 | NVIDIA | Security Engineer, GPU Kernel Driver | Santa Clara CA | 5+ yrs; same nominal 2026-11-03 window | Bachelor's/Master's "or equivalent experience" | none stated | https://nvidia.wd5.myworkdayjobs.com/NVIDIAExternalCareerSite/job/US-CA-Santa-Clara/Security-Engineer--GPU-Kernel-Driver_JR2026525 |
| P17 | Elastic | Senior Security Research Engineer | Spain (also US, Canada variants) | 6+ yrs | not mentioned | none | https://jobs.elastic.co/jobs?gh_jid=8161837 |
| P18 | Huntress | Principal Security Researcher, EDR (Windows) | US remote | Principal, yrs n/s | not mentioned | none | https://job-boards.greenhouse.io/huntress/jobs/7807467003 |
| P19 | Trail of Bits | Security Engineer I, Application Security | US remote | **1+ yr; early career** | not mentioned; experience may come from CTFs, independent research, OSS | none | https://apply.workable.com/j/BA9F2FCDA6 |
| P20 | Trail of Bits | Security Engineer II, Application Security | US remote ($140-180k) | 2+ yrs | not mentioned | none | https://apply.workable.com/j/C7FEA82CF5 |
| P21 | Trail of Bits | Senior Security Engineer, Research & Engineering | UK remote | Senior, yrs n/s | not mentioned | none | https://apply.workable.com/j/82AEBAB99A |
| P22 | Anthropic | Security Engineer, Offensive Security | US (SF/NYC/Seattle/DC/remote), $300k+ | 5+ yrs | Bachelor's "or equivalent combination of education, training, experience" | none stated | https://job-boards.greenhouse.io/anthropic/jobs/5418977008 |
| P23 | Cloudflare | AI Security Research & Red Team Engineer | Hybrid (NY salary quoted) | 4+ yrs | not mentioned | none | https://boards.greenhouse.io/cloudflare/jobs/8097321 |
| P24 | Cloudflare | Vulnerability Defense Software Engineer, Cloudforce One | Austin / Washington DC | 5+ yrs (listed under "Desirable") | not mentioned | none | https://boards.greenhouse.io/cloudflare/jobs/8245503 |
| P25 | Okta | Staff Product Security Engineer, Offensive Security | Dublin IE (EUR 90-123k) | Staff, 5+ yrs preferred | not mentioned | none | https://www.okta.com/company/careers/opportunity/8281124 |
| P26 | Stripe | Offensive Security Engineer | US remote | 5+ yrs | not mentioned | none | https://stripe.com/jobs/search?gh_jid=8233889 |
| P27 | Stripe | Security Engineer, New Grad | Dublin IE | New grad | **enrolled in Bachelor's/Master's** | none | https://stripe.com/jobs/search?gh_jid=8257892 |
| P28 | Robinhood | Offensive Security Engineer | Bellevue WA | 3+ yrs | not mentioned | none | https://boards.greenhouse.io/robinhood/jobs/7460167 |
| P29 | Robinhood | Senior Offensive Security Engineer | Bellevue / Denver / Menlo Park / NYC | 6+ yrs | not mentioned | none | https://boards.greenhouse.io/robinhood/jobs/8202858 |
| P30 | MongoDB | Senior Product Security Engineer, Assessments | NYC / Seattle / US | 7+ yrs | not mentioned | none | https://www.mongodb.com/careers/job/?gh_jid=8268264 |
| P31 | GitLab | Principal Security Researcher | Remote US/CA/UK/IL | 10+ yrs | not mentioned | none | https://job-boards.greenhouse.io/gitlab/jobs/8731718002 |

## Per-posting skills, languages, platforms, portfolio (as read)
R = required / minimum, P = preferred / bonus / "desirable". Anything not listed was not stated.

| ID | Required (R) | Preferred (P) | Languages named | Platforms / targets | Portfolio signals |
|---|---|---|---|---|---|
| P01/P02 | RE to root-cause vulns; write original exploits for unauthenticated RCE with little public PoC; detections (Suricata/Snort/YARA), ASM queries (Shodan/Censys) as duties | prior vendor/government cyber work; able to share exploit code | none named (maintains open-source "go-exploit") | enterprise network-facing software (initial access) | sample exploit code |
| P03 | experience in one or more of VR, RE, exploit dev; develop PoCs that bypass modern mitigations; reason about root causes alone | n/s | none | platform teams: Android, iOS, browsers, hypervisors, embedded | none stated |
| P04 | direct RE + VR on embedded devices; interest in exploit dev | n/s | none | firmware, custom protocols, IoT, drones, vehicles, networking gear; hardware lab | none stated |
| P05 | basic VR understanding; interest in low-level HW/SW | RE on Android/iOS/embedded/hypervisor | none | Android, iOS, embedded, hypervisor | none |
| P06 | 5 yrs RE; vulnerability and exploitation experience; technical writing | depth in a VR field; track record of **published** research | none | security-critical software (vendor-agnostic) | published research (P) |
| P07-P11 | degree ladder + years in SDLC / large-scale computing / threat analysis / cybersecurity / VR / anomaly detection (any-of); P10 R only | P10: 4 yrs RE, C/C++, Python/PowerShell, Linux internals, debuggers/disassemblers/file formats/firmware, macOS+mobile; P08: offensive/agent/cloud/identity/app security, exploit prototypes, LLM and agent testing, mitigation engineering | C, C++, Python, PowerShell (P10 P) | Windows/Linux/macOS, cloud, AI agents | none stated |
| P12 | 4+ yrs infosec; VR + exploit dev; RE; Windows and Linux internals; software dev (Python preferred); use of GenAI/LLMs for VR | CTFs; Android/iOS; macOS; Go or Rust; threat intel | Python (R), Go/Rust (P) | Windows, Linux (+mobile, macOS) | CTFs (P); publish on blog/conferences (duty) |
| P13 | exploitation techniques for userspace and kernel bugs; network-service and web exploitation; 2 OS platforms incl. Windows; RE tools; Python; LLM-assisted VR; excellent writing | attribution, intel writing, Snort/YARA | Python | Windows + one more OS; userland and kernel | writing quality |
| P14 | 6+ yrs security; ARM/RISC-V asm, Verilog, low-level C; SoC/ASIC architecture; firmware security code review; two or more of: side channels, TEE/microarchitectural, symbolic execution/fuzzing, JTAG/ChipWhisperer, RE (IDA/Ghidra); **track record via vuln discoveries, publications or tools** | pre-silicon design, GPU/AI accelerator architecture | asm (ARM/RISC-V), C, Verilog | SoC, GPU firmware, TEE | VD/publications/tools (R) |
| P15 | 7+ yrs C/C++; OS internals, kernels, hypervisors, firmware; embedded; building fuzzers/sanitizers/analysis; Linux; x86 + ARM; agentic AI systems | CTFs, bug bounty, published research; Rust/formal methods; RISC-V | C/C++ (R); Python, Rust (P) | Linux, embedded automotive, hypervisors, firmware | CTF / bug bounty / publications (P) |
| P16 | 5+ yrs SWE; C and low-level driver experience; OS and architecture fundamentals; security analysis of complex systems | static analysis, fuzzing (AFL/Peach), AI/LLM tools, **vulnerability research**, SDL | C | GPU kernel driver | VR experience (P) |
| P17 | 6+ yrs TTP/detection; 6+ yrs C/C++/Python; kernel and user-mode OS internals (Windows depth most needed); RE and malware analysis; AI-assisted development | **VR/exploit dev with responsible-disclosure record to platform vendors**; red team; kernel drivers; maintain an OSS security tool; conference speaking | C, C++, Python | Windows (most), macOS, Linux; endpoint | disclosures, OSS tool, talks (P) |
| P18 | Windows internals/APIs; kernel code and drivers; EDR testing/bypass; RE + debuggers; scripting; AI use; ATT&CK/Sigma/YARA | n/s | C/C++/C#, PowerShell, Python | Windows endpoint | CFPs/CTFs/blogs (duty) |
| P19 | 1+ yr; **demonstrable personally-found vuln** (CVE, CTF, bug bounty, OSS accepted as evidence); code reading and data-flow tracing; 2+ languages; **memory corruption and mitigations (UAF, canaries, ASLR, NX, CFI, MTE) at early-career level**; OS concepts, IPC, privilege boundaries | CTFs; CVEs/bug bounty/writeups; OSS tool contributions; mobile; cloud; kernel/drivers/RE/fuzzing | any 2 of Rust, Go, C, C++, Python, JS, TS | application code, systems internals | CVEs, CTFs, bug bounty, writeups, OSS |
| P20 | 2+ yrs; as P19 but scoping an assessment workstream and building/adapting tooling; mitigation knowledge | same P list plus conference talks, symbolic execution | as P19 | as P19 | as P19 |
| P21 | red-teaming production software with working exploits; **built** AI bug-finding tooling (agent harnesses, triage, exploit generation); formal methods (Lean/Rocq/F*/Dafny/Verus); systems-domain depth; Python/C++/Rust; expert-grade reports; disclosure ethics | n/s | Python, C++, Rust | protocol impls, OS internals, crypto, AI infra | publish tooling/blog |
| P22 | 5+ yrs red team; 2 of macOS/Linux/cloud/K8s/CI-CD; track record chaining novel attack vectors; Python/Go | state-actor background, AI/ML testing, detection side, hardware attacks | Python, Go | macOS, Linux, cloud, K8s, bare metal | none |
| P23 | 4+ yrs offensive/AppSec; AI/agent attack vectors; pentest or exploit dev or cloud; ATT&CK; BAS/C2 | n/s | none | AI/agents, cloud, WAF/EDR efficacy | none |
| P24 | (all under "Desirable") 5+ yrs large-scale software; Go/TS; APIs; SQL; | practical VR/exploit dev; AI-assisted dev; app-sec | Go, TypeScript (Rust in stack) | internal tooling, threat ops | none |
| P25 | web/network pentest (5+ preferred); SAML/OAuth/OIDC; AI/LLM attack; offensive tooling beyond scripts; Linux/macOS; GCP; K8s/Terraform; crypto | n/s | none named | identity platforms, SaaS, cloud | external publication encouraged |
| P26 | 5+ yrs offsec; Python/Go with tools/custom exploits; web (OWASP/ASVS); cloud; Burp/Cobalt Strike/Sliver/BloodHound; ATT&CK | fintech; **VR/exploit dev/CVE discovery**; OSS tools, published research, talks | Python, Go | web, API, cloud, mobile, internal | CVEs, OSS, talks (P) |
| P27 | enrolled in degree; some programming; learn unfamiliar systems; attacker mindset | CTF events, OWASP, code review, cloud | Java/Ruby/Python/JS/Scala/Go (context) | product security | CTFs (P) |
| P28/P29 | 3+/6+ yrs offsec/red team; comms; DNS/TCP-IP; macOS/Linux; CI/K8s/cloud; EDR evasion and ATT&CK (P29) | fintech, tech lead | Python, Go, JS (P29) | cloud, enterprise | none |
| P30 | 7+ yrs AppSec/pentest; threat modelling, red team, code review; cloud; K8s | n/s | Python or Go ("some") | MongoDB Atlas, Ops Manager, K8s operator, MongoDB Server | none |
| P31 | 10+ yrs; **find and exploit vulns in large codebases**; read many languages; AI attack vectors; remediation leadership; writing | published research or conference talks; distributed-systems background | 2 of Ruby/Go/Python/TS/Rust | GitLab codebase, OSS dependencies | publications/talks (P) |

## Closed, expired or stale (excluded from tallies)
| ID | Employer / title | Status as fetched 2026-11-10 | What it asked (still useful for calibration) |
|---|---|---|---|
| C1 | REDLattice, Vulnerability Researcher / Exploit Developer (Maryland), https://www.career.com/job/redlattice/vulnerability-researcher-exploit-developer/j202507230717468534188 | **Expired** (posted 2026-02-16, closed 2026-03-20; fetched via career.com board, not employer ATS) | 10 yrs exploit R&D; Linux kernel dev; IDA/Ghidra/Binary Ninja; ASLR/DEP/PXN/canaries and bypasses; SELinux/AppArmor; C/C++/asm/Python; Bachelor's CS (Master's preferred); **TS/SCI with polygraph**; no portfolio signals |
| C2 | Quarkslab, Senior iOS/macOS kernel Vulnerability Researcher (France, remote), https://taleez.com/apply/senior-ios-macos-kernel-vulnerability-researcher-quarkslab-cdi | **Closed** ("not available anymore") | XNU VR via RE and audit; fuzzers; exploit PoCs and mitigation bypass; AArch64/x86_64; IDA/Ghidra plug-ins; hypervisors/browsers a plus; degree not mentioned |
| C3 | Quarkslab, Senior Reverse Engineer - Vulnerability researcher (France, remote), https://taleez.com/apply/3qun394uhrejo | **Closed** | SoC/bootchain/baseband/TEE RE and exploitation; C/C++, ARM/AArch64 asm, Python; IDA/Ghidra/radare2/Frida; AFL++/libFuzzer/syzkaller; QEMU/Unicorn emulation; **French and English required**; blog/GitHub writeups a plus |
| C4 | Breakpoint Research, Experienced Vulnerability Researcher (UK), https://breakpointresearchlimited.teamtailor.com/jobs/7995187-experienced-vulnerability-researcher | **Closed**; careers board shows "No open positions right now" | content not retrievable |
| C5 | Nightwing, Linux Reverse Engineer / Vulnerability Researcher (Sterling VA), https://www.clearancejobs.com/jobs/8747909/linux-reverse-engineer-vulnerability-researcher | **Stale / unknown** (aggregator page, "posted over 6 months ago", "contingent upon contract award") | 3+ yrs C/C++/Python; Linux internals; GDB/IDA/Ghidra; ARM/MIPS exploitation preferred; **TS/SCI + poly**; degree not stated |
| C6 | Google "Senior Security Engineer" / "Security Engineer" / "Staff Security Engineer" pages surfaced by search (IDs 104683719914070726, 132534755320046278, 117841477853160134) | **Unavailable**: the pages return a generic jobs search, no posting body | not recorded |

Also noted but not tallied: Interrupt Labs iOS Vulnerability Researcher (Australia, remote, https://interruptlabs.teamtailor.com/jobs/7755757-ios-vulnerability-researcher) asks for Python/Rust tooling, ARM64 RE with IDA/Binary Ninja/Frida, XNU/IOKit as desirable (outside US/EU scope). Okta Staff PSIRT (Barcelona, https://www.okta.com/company/careers/opportunity/8087739) and Coinbase Product Security Engineer (Canada) are program-management / AI-tooling roles, not bug-finding. Anthropic Platform Hardware Security is secure-boot design with firmware assessment as one duty. Screened out as not bug-finding: Anthropic Staff Software Security (London), Asana Product Security Engineer (Warsaw, not fully read).

## Policy statements from firms without a current posting (not tallied)
- Doyensec careers page (https://doyensec.com/careers.html, fetched 2026-11-10): states it does not care about education, background or certifications; asks for public research, code or advisories and top-notch web security; 25% research time. No specific open role seen.
- Synacktiv "Join us" page (https://synacktiv.com/en/join-us, fetched 2026-11-10): requires a proven first experience in pentest and security research, code review, RE, Python; personal projects, CTFs, publications and blog posts "highly valued"; professional English **and French** required; France-based offices.
- Trail of Bits hiring process page (https://www.trailofbits.com/careers/): four stages, take-home about two hours, "weighted toward real work".

## Tally tables (N=31 live postings, P01-P31)
Counts are postings where the item appears, split by required (R) / preferred (P). A posting may count once per row. "Opt" = named as one option in an "any N of these languages" list. Hand-counted from the table above; treat +-1 as rounding of ambiguous wording.

### Skill frequency
| Skill | R | P | Comment |
|---|---|---|---|
| Written reports / communicating findings to engineers | ~13 (approximate; counted from postings that state a comms requirement) | 0 | Appears in nearly every offensive-security (non-VR) posting and in P06, P13 |
| Reverse engineering | 7 (P03, P04, P06, P12, P13, P17, P18) | 5 (P05, P10, P14 any-of, P19, P20) | Core in low-level roles, absent from web/cloud roles |
| Vulnerability research / discovery (generic wording) | 10 (P03, P06, P07, P09, P10, P11, P12, P19, P21, P31) | 5 (P16, P24, P26, P17, P01/P02 duty) | Microsoft lists it as an any-of among threat analysis etc. |
| Exploit development / exploitation | 6 (P01, P02, P03, P06, P12, P13) | 4 (P17, P24, P26, P22 chaining) | Under half of postings require writing exploits |
| Memory-corruption + mitigation knowledge (ASLR, NX, CFI, MTE etc.) named | 2 (P19, P20) +1 as a duty (P03) | 0 | Almost no posting names mitigations; ToB I is the clearest junior statement |
| OS internals (kernel/user, Windows or Linux) | 8 (P12, P13, P15, P17, P18, P19, P20, P21) | 2 (P10, P16 fundamentals) | |
| Kernel / driver code | 3 (P16, P18, P15 kernels) | 3 (P17, P19, P20) | Linux kernel exploitation is explicitly required in 0 live postings (only in expired C1) |
| Fuzzing / sanitizers / static analysis tooling | 2 (P15, P14 any-of) | 4 (P16, P19, P20, P05 desirable RE/fuzz work) | Built fuzzers are required at NVIDIA; "AFL++/syzkaller" required in closed C3 |
| Code audit / source review / data-flow | 5 (P19, P20, P30, P31, P14) | 0 | |
| Web / API / app pentesting | 7 (P13, P23, P25, P26, P30, P31, P19/P20 appsec) | 0 | |
| Cloud / Kubernetes / CI-CD | 7 (P22, P23, P25, P26, P28, P29, P30) | 2 (P19, P20) | Dominant in offensive-security (non-VR) roles |
| Red teaming / adversary emulation / ATT&CK | 6 (P22, P23, P26, P28, P29, P18) | 1 (P17) | |
| Building offensive tooling / automation | 5 (P25, P26, P21, P20, P15) | 1 (P17 OSS tool) | "Beyond ad-hoc scripts" (P25) |
| **AI/LLM security or AI-assisted VR as a requirement** | **9** (P12, P13, P15, P17, P18, P21, P23, P25, P31) | 4 (P08, P16, P22, P24) | 13 of 31. New since typical pre-2025 postings; see Implications |
| Hardware / firmware / embedded | 4 (P04, P14, P15, P21 domain) | 2 (P03, P12) | |
| Reading/writing assembly (x86/ARM) | 3 (P14, P15 x86/ARM, P03 implied) | 1 | |

### Language frequency (named in the posting)
| Language | R (named) | Opt (any-N list) | P |
|---|---|---|---|
| Python | 9 (P12, P17, P18, P13, P21, P22, P26, P29, P30) +P31 opt | 3 (P19, P20, P31) | 2 (P10, P15) |
| C | 5 (P14, P15, P16, P17, P18) | 2 (P19, P20) | 1 (P10) |
| C++ | 4 (P15, P17, P18, P21) | 2 | 1 (P10) |
| Go | 5 (P22, P26, P29, P30; P24 desirable) | 3 (P19, P20, P31) | 2 (P12, P24) |
| Rust | 1 (P21) | 3 (P19, P20, P31) | 2 (P12, P15) |
| JavaScript/TypeScript | 1 (P29) | 3 (P19, P20, P31) | 1 (P24) |
| Assembly (ARM/RISC-V/x86) | 1 (P14) +P15 architecture knowledge | 0 | 0 |
| C#, PowerShell | 1 (P18) | 0 | 1 (P10) |
| Verilog | 1 (P14) | 0 | 0 |
| Ruby, Java, Scala | 0 | 1 (P31 Ruby) | 0 |
| No language named | P03, P04, P05, P06, P07-P09, P11, P23, P25, P28 | | |

### Platform / target frequency (named as a target in requirements, preferences or core duties)
| Platform | Postings | Note |
|---|---|---|
| Cloud / K8s / CI-CD | 9 | P22, P23, P25, P26, P28, P29, P30, plus P19/P20 preferred |
| Web / API / SaaS | 8 | includes P19/P20 application security |
| Linux (userland / internals) | 8 | P10, P12, P15, P17, P22, P25, P28, P29 |
| macOS / iOS | 7 | mostly as "also"; Apple-specific VR appears only in Interrupt platform teams and closed C2 |
| Embedded / firmware / hardware / SoC | 6 | P03, P04, P05, P14, P15, P21 |
| Kernel-mode / drivers | 5 | P13, P15, P16, P17, P18 |
| Windows | 4 | P12, P13, P17, P18 |
| AI / agent systems | 8 as target | P08, P22, P23, P25, P31 plus tooling in others |
| Hypervisors | 3 | P03, P05, P15 |
| Network-facing enterprise appliances / services | 3 | P01, P02, P13 |
| Mobile (Android/iOS) | 4 | P03, P05, P12 (P), P19/P20 (P) |
| Browsers | 1 | P03 only (Interrupt platform team). Closed C2 lists browsers as a plus |

### Degree requirement breakdown (N=31)
| Category | Count | Postings |
|---|---|---|
| Degree required, no equivalence | 2 | P05 (intern, enrolled), P27 (new grad, enrolled) |
| Degree "or equivalent experience" | 12 | P06, P07, P08, P09, P10, P11, P12, P13, P14, P15, P16, P22 |
| Explicit "no formal education or certifications required" | 1 | P03 |
| Not mentioned | 16 | P01, P02, P04, P17, P18, P19, P20, P21, P23, P24, P25, P26, P28, P29, P30, P31 |
Reading: in this sample **no experienced-hire role hard-requires a degree**. The two that do are student pipelines. Large vendors (Microsoft, NVIDIA, Google, CrowdStrike, Anthropic) write "or equivalent". Closed C1 (defence contractor) required a Bachelor's. Clearance is the real gate for US government-adjacent work.

### Clearance / citizenship / gates
| Gate | Count (live) | Postings |
|---|---|---|
| Active clearance (TS/SCI) | 1 | P11. Closed C1 and stale C5 also TS/SCI + polygraph |
| UK security clearance (SC) eligibility | 2 | P04, P05; P03 requires UK permanent residency |
| Citizenship / export-control verification | 4 | P07, P09 (Microsoft), P01, P02 (VulnCheck, export-control authorisation) |
| Background check only | 3 | P08, P10 and similar |
| French language | 0 live (2 closed Quarkslab; Synacktiv policy page) | France-based firms require French |
| None stated | remainder | |

### Portfolio signals
| Signal | Required | Preferred / accepted | Postings |
|---|---|---|---|
| Vulnerability finds / CVEs / disclosures | 2 (P14 track record; P19 demonstrable personal find, CVEs and CTFs accepted as evidence) | 6 | P15, P16, P17, P20, P24, P26 |
| CTF results | 0 | 5 | P12, P15, P19, P20, P27 |
| Published research / blog / writeups | 0 | 6 | P06, P17, P19, P20, P26, P31 |
| Conference talks | 0 | 4 | P17, P20, P26, P31 |
| Open-source security tool contributions | 0 | 4 | P17, P19, P20, P26 |
| Bug bounty results | 0 | 3 | P15, P19, P20 |
| Sample exploit code | 1 (P01/P02 "able to share") | 0 | P01, P02 |
| Certifications required | 0 | 0 | none seen in the sections reviewed; Stripe only funds certifications |

## Entry-level vs senior
- Stated years across 18 postings: 1, 2, 2 (II with Bachelor's), 3, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 7, 7, 10. Median 5.
- Only 5 of 31 live postings are genuinely junior: P05 (intern), P27 (new grad), P19 (1+ yr), P09 (II, 1-2 yrs), P28 (3 yrs, pentest). P20 is 2+ yrs.
- **Junior postings that are about memory-corruption VR are rare**: P19 (Trail of Bits Security Engineer I) and P05 (Interrupt internship). The Interrupt "Experienced" role names no years and no degree.
- Skills at junior level (P19, P05, P27, P28): code reading and data-flow tracing; two languages; named memory-corruption bugs and mitigations (UAF, ASLR, NX/DEP, canaries, CFI, MTE); OS concepts and privilege boundaries; evidence of one real finding (CVE, CTF, bug bounty, OSS, "independent research" explicitly accepted); clear writing. Interrupt internship wants "basic understanding" of VR plus low-level interest.
- Skills that appear only mid/senior: kernel or driver development (P16, P18), SoC/side-channel (P14), fuzzer building (P15), AI-tooling authorship (P21), leading remediation programmes (P31), identity/cloud depth (P25).
- Senior postings (P06, P14, P15, P17, P29, P30, P31) add: building tooling or automation, mentoring, publication/talk track record, vendor-disclosure history, cross-platform OS internals. P31 (10+ yrs) and P21 weight AI tooling heavily.
- Compensation signal for calibration: ToB II $140-180k; VulnCheck US $200-235k; Anthropic offensive security $300k+; Okta Dublin EUR 90-123k. Microsoft IC4 base $119.8-234.7k (US).

## Observations
1. The market is two markets. **(A) Low-level VR / exploit dev** (P01-P06, P12-P21, closed C1-C5): small employer set, few postings, few junior slots, specific platform teams. **(B) Offensive / product security** (P22-P31): web, cloud, identity, red team, AI; many postings, 3-10 yrs typical. About 16 of 31 postings are category A or adjacent (kernel, firmware, exploit dev, RE), the rest B.
2. "Vulnerability researcher" at Microsoft (P07-P11) is a broad any-of requirement (threat analysis, VR, anomaly detection) and does not demand exploit skills in the minimum quals.
3. Mitigations are almost never named in live postings. The exceptions are ToB I/II (ASLR, NX, CFI, MTE listed) and Interrupt ("bypassing modern exploit mitigations", duty-level). Closed C1 listed ASLR/DEP/PXN/canaries.
4. Linux kernel exploitation as an explicit requirement appears in zero live postings in the sample; it appears in closed C1 and, as general OS internals, in P12/P15/P17. Browser exploitation is in one (P03). The common thread is **OS internals plus RE plus a real find**, not a specific target.
5. AI appears in 13 of 31 postings, in two ways: AI systems as a target (prompt injection, agent abuse: P08, P22, P23, P25, P31) and AI as a research accelerant (P12, P13, P15, P17, P18, P21: "leverage LLMs to aid vulnerability research", "built agentic harnesses, exploit generation").
6. Several postings explicitly say experience from independent sources counts: Trail of Bits (CTFs, CVEs, OSS, "independent research"), Interrupt ("No formal education or certifications required"), Doyensec (policy page), Synacktiv (policy page: CTFs and publications "highly valued").

## Unverified leads (not tallied; could not reach a primary page)
| Lead | What blocked | How to fetch manually |
|---|---|---|
| NCC Group, Lead Security Researcher / Senior Exploit Researcher, Exploit Development Group (Cheltenham, Manchester, Madrid variants; Pwn2Own work) | Only aggregators surfaced; `careers.nccgroup.com` unreachable from the sandbox (`https://www.nccgroup.com/careers/` returned 200 but no listing data) | NCC Group careers site, search "Exploit Development Group" |
| grsecurity (Open Source Security), Security Researcher - Linux Kernel (5+ yrs exploit dev, 3+ on Linux kernel per search snippet) | https://opensrcsec.com/security_researcher_linux_kernel returned HTTP 500 on 2026-11-10 | retry later; this is the only explicit Linux-kernel exploit role found |
| Apple SEAR, Offensive Security Researcher / Vulnerability Researcher / Kernel & Embedded (Cupertino, Seattle, NYC, Paris) | jobs.apple.com search is JS-rendered; a fetched search page showed only a fuzzing-infrastructure DevOps role (Paris, posted 2026-11-10); other hits are aggregators | jobs.apple.com, team filter SEAR |
| Intel, Offensive Security Researcher (Paris) | page body empty (JS) | jobs.intel.com |
| Arm, SoC Offensive Security (Austin) | Workday query returned HTTP 422 | Arm careers |
| Palo Alto Cortex, Principal/Senior Linux Security Researcher; Oligo Security Linux Security Researcher | aggregator HTTP 403 / no primary page | vendor career pages |
| Google, Android Product Security; Google Threat Intelligence Group exploits | Google pages returned generic search | careers.google.com |
| Quarkslab, Synacktiv, Doyensec current openings | Quarkslab `careers-jobs` page 404; Synacktiv job list not fetched; Doyensec page shows no named role | firm career pages |
| US defence exploit shops (e.g. REDLattice, Nightwing and similar) | postings appear on ClearanceJobs/Dice/BuiltIn, mostly stale | ClearanceJobs requires login for full coverage |

## Implications for OSVR
Suggestions for the architect to accept or reject.
1. **Anchor the portfolio spec to what hiring managers actually ask for: one real, explainable find.** Trail of Bits I demands being able to talk through a vulnerability you personally found, naming CVEs, CTFs, bug bounty, OSS and "independent research" as equally valid evidence. Interrupt Labs and Doyensec say education and certifications are irrelevant. Define the `find` + `rootcause` + `disclose` capstone deliverable as exactly this artefact: a public writeup of a personally-found bug with root cause to the line.
2. **Do not teach to a single exploit target.** No live posting in this sample requires Linux kernel or browser exploitation specifically. The recurring requirement is OS internals + reverse engineering + code audit + at least one demonstrated find. Keep kernel/browser tracks as depth options (they feed Interrupt-style platform teams and P0), but make FND/RE/BX/VD the hiring-critical spine. Flag as `needs-confirmation`: the sample is small and misses defence primes.
3. **Make AI a cross-cutting skill, not a track.** 13 of 31 postings expect AI either as target or as a research accelerant (LLM-assisted VR, agent harnesses, triage pipelines, exploit generation: P12, P13, P15, P17, P21). Add a small module or recurring drill: build an LLM-assisted triage/harness for a fuzzing or audit workflow, and validate its findings independently. Also consider a short "attacking agentic/LLM systems" module for category-B roles (P08, P22, P23, P25, P31).
4. **Name mitigations in outcomes language the way hiring managers do.** Postings that list them use: ASLR, NX/DEP, stack canaries, CFI, MTE (ToB), PXN (closed C1), plus "bypass modern mitigations" (Interrupt). Keep the D9 mitigation-era requirement and ensure CFI and MTE are covered at least at reasoning level, since a junior posting names them.
5. **Target the realistic first jobs.** The attainable first roles for a no-degree learner in this sample are: Trail of Bits Security Engineer I/II (US remote), Interrupt Labs (UK, residency and SC eligibility needed), Doyensec and Synacktiv-style small consultancies (Synacktiv requires French), and bug-finding product-security roles at 3-5 yrs in B-category. The big vendors say "or equivalent experience" but expect 4-6+ yrs. Consider a PRO-track module on mapping a portfolio to specific postings and to citizenship/clearance/language gates (US TS/SCI, UK SC, French) that no curriculum can fix.
6. **Add a "hiring evidence" checklist to the PRO track:** public writeups, 1-3 CVEs or accepted bug-bounty reports, CTF results, an OSS security tool or fuzz harness with real users, and a conference or blog talk. These are the signals that recur in preferred lists (6, 5, 6, 4, 4 postings respectively).
7. **Written communication is the most commonly required skill (about 13 postings, approximate count), above any technical item.** Strengthen the rubric weighting for advisory and report quality (the disclose outcome) and make clear that writing is graded, not optional.
8. **Language policy:** Python is near-universal (9 required, 3 any-of); C/C++ is required wherever low-level work is core (P14-P18, P21); Go and Rust appear as tooling languages and as options in ToB. Suggest Python + C early, assembly (x86-64 and AArch64) for RE/BX, then Rust or Go for tooling. Treat assembly as required only for the hardware/embedded and RE branch (P14, closed C3).
9. **Time-to-hire reality check for the target learner:** the median stated experience is 5 years. Frame OSVR's outcome as "credible junior-to-mid evidence in 12-24 months of part-time study" rather than "qualified for a senior VR role". The shortest documented bridge to employment is a public portfolio plus a junior or intern-style programme (ToB I; Interrupt's development programme history; intern roles that require enrolment are not available to non-students).
10. **Maintenance cadence:** postings turn over in weeks (6 of 37 examined were already closed or stale, including two "found by search" Google pages). Treat this file as a snapshot; re-run in 90 days before using counts to justify scope changes. Re-fetch the unverified leads above (particularly grsecurity, the only explicit Linux-kernel exploit role).

## Sources (all fetched 2026-11-10 unless noted)
- Greenhouse board APIs: https://boards-api.greenhouse.io/v1/boards/{anthropic,cloudflare,okta,stripe,robinhood,coinbase,elastic,gitlab,mongodb,huntress,vulncheck}/jobs (listings and per-job content for IDs in the catalogue)
- Workable API for Trail of Bits: https://apply.workable.com/api/v1/widget/accounts/trailofbits?details=true ; careers page https://www.trailofbits.com/careers/
- Workday CxS: https://nvidia.wd5.myworkdayjobs.com/wday/cxs/nvidia/NVIDIAExternalCareerSite/jobs ; https://crowdstrike.wd5.myworkdayjobs.com/wday/cxs/crowdstrike/crowdstrikecareers/jobs
- Microsoft careers API: https://apply.careers.microsoft.com/api/pcsx/search and position_details (IDs in catalogue)
- Google Careers: https://google.com/about/careers/applications/jobs/results/136445532154274502
- Interrupt Labs Teamtailor: https://interruptlabs.teamtailor.com/jobs (and the job URLs in the catalogue)
- Breakpoint Research Teamtailor: https://breakpointresearchlimited.teamtailor.com/jobs
- Quarkslab Taleez pages (URLs in C2/C3)
- Doyensec: https://doyensec.com/careers.html ; Synacktiv: https://synacktiv.com/en/join-us
- Aggregator pages used for closed/stale items only: https://www.career.com/job/redlattice/vulnerability-researcher-exploit-developer/j202507230717468534188 ; https://www.clearancejobs.com/jobs/8747909/linux-reverse-engineer-vulnerability-researcher
- Search leads (aggregators; not sources for claims): web search results for NCC Group EDG, grsecurity, Apple SEAR, Arm/NVIDIA/Intel, Interrupt Labs, Nightwing.
